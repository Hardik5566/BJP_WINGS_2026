using System;
using System.IO;
using System.Net;
using System.Text;
using Newtonsoft.Json;

/// <summary>
/// Azure OpenAI HTTP client for Election AI module.
/// Uses HttpWebRequest for better compatibility on ASP.NET 4.8 / IIS.
/// </summary>
public static class ElectionAIClient
{
    private static bool _tlsInitialized;

    static ElectionAIClient()
    {
        EnsureTls();
    }

    private static void EnsureTls()
    {
        if (_tlsInitialized) return;
        try
        {
            ServicePointManager.SecurityProtocol =
                SecurityProtocolType.Tls12 |
                SecurityProtocolType.Tls11 |
                SecurityProtocolType.Tls;
        }
        catch
        {
            ServicePointManager.SecurityProtocol = SecurityProtocolType.Tls12;
        }

        ServicePointManager.Expect100Continue = false;
        ServicePointManager.DefaultConnectionLimit = 100;
        _tlsInitialized = true;
    }

    public static string GenerateSql(string systemPrompt, string userQuestion)
    {
        return CallChat(systemPrompt, userQuestion, 0);
    }

    public static string FixSql(string systemPrompt, string userQuestion, string badSql, string errorMessage)
    {
        string fixPrompt = userQuestion + "\n\nPrevious SQL:\n" + badSql
            + "\n\nSQL Server error:\n" + errorMessage
            + "\n\nReturn ONLY corrected SELECT using @app_id and ai_* views.";
        return CallChat(systemPrompt, fixPrompt, 0);
    }

    private static string CallChat(string systemMsg, string userMsg)
    {
        return CallChat(systemMsg, userMsg, 0);
    }

    private static string CallChat(string systemMsg, string userMsg, int retry429Count)
    {
        EnsureTls();

        string endpoint = System.Configuration.ConfigurationManager.AppSettings["AzureOpenAIEndpoint"];
        string apiKey = System.Configuration.ConfigurationManager.AppSettings["AzureOpenAIKey"];
        string deployment = System.Configuration.ConfigurationManager.AppSettings["AzureDeployment"];

        if (string.IsNullOrWhiteSpace(endpoint) || string.IsNullOrWhiteSpace(apiKey) || string.IsNullOrWhiteSpace(deployment))
            throw new Exception("Azure OpenAI is not configured in Web.config (AzureOpenAIEndpoint, AzureOpenAIKey, AzureDeployment).");

        string url = endpoint.TrimEnd('/') + "/openai/deployments/" + deployment
            + "/chat/completions?api-version=2024-05-01-preview";

        var payload = new
        {
            messages = new[]
            {
                new { role = "system", content = systemMsg },
                new { role = "user", content = userMsg }
            },
            temperature = 0,
            max_tokens = ElectionAIConfig.AzureMaxTokens
        };

        string jsonBody = JsonConvert.SerializeObject(payload);
        byte[] bodyBytes = Encoding.UTF8.GetBytes(jsonBody);

        HttpWebRequest request = null;
        try
        {
            request = (HttpWebRequest)WebRequest.Create(url);
            request.Method = "POST";
            request.ContentType = "application/json; charset=utf-8";
            request.Accept = "application/json";
            request.Timeout = ElectionAIConfig.AzureTimeoutSeconds * 1000;
            request.ReadWriteTimeout = ElectionAIConfig.AzureTimeoutSeconds * 1000;
            request.KeepAlive = false;
            request.ProtocolVersion = HttpVersion.Version11;
            request.Headers.Add("api-key", apiKey);
            request.ContentLength = bodyBytes.Length;
            request.Proxy = WebRequest.DefaultWebProxy;
            if (request.Proxy != null) request.Proxy.Credentials = CredentialCache.DefaultCredentials;

            using (Stream reqStream = request.GetRequestStream())
            {
                reqStream.Write(bodyBytes, 0, bodyBytes.Length);
            }

            using (HttpWebResponse response = (HttpWebResponse)request.GetResponse())
            using (StreamReader reader = new StreamReader(response.GetResponseStream(), Encoding.UTF8))
            {
                string body = reader.ReadToEnd();

                if ((int)response.StatusCode < 200 || (int)response.StatusCode >= 300)
                    throw new Exception("Azure OpenAI HTTP " + (int)response.StatusCode + ": " + body);

                try
                {
                    dynamic json = JsonConvert.DeserializeObject(body);
                    return json.choices[0].message.content.ToString().Trim();
                }
                catch (Exception ex)
                {
                    throw new Exception("Failed to parse Azure response: " + ex.Message + "\nBody: " + body);
                }
            }
        }
        catch (WebException wex)
        {
            string detail = ReadWebException(wex);

            if (wex.Status == WebExceptionStatus.NameResolutionFailure)
            {
                throw new Exception(
                    "Azure OpenAI hostname could not be resolved (DNS failed).\n" +
                    "The URL in Web.config is wrong or the Azure resource was deleted/renamed.\n\n" +
                    "Fix:\n" +
                    "1. Azure Portal -> your Azure OpenAI resource -> Keys and Endpoint\n" +
                    "2. Copy the Endpoint (e.g. https://YOUR-NAME.openai.azure.com/)\n" +
                    "3. Update Web.config: AzureOpenAIEndpoint, AzureOpenAIKey, AzureDeployment\n\n" +
                    "Current URL: " + url + "\n" + detail,
                    wex);
            }

            // If Azure returned an HTTP status (auth/deployment/quota), show the correct reason.
            if (wex.Response is HttpWebResponse http)
            {
                int code = (int)http.StatusCode;
                if (code == 401)
                    throw new Exception("Azure OpenAI authentication failed (401). Check AzureOpenAIKey in Web.config.\nURL: " + url + "\n" + detail, wex);
                if (code == 403)
                    throw new Exception("Azure OpenAI access forbidden (403). Check subscription/quota/role for this resource.\nURL: " + url + "\n" + detail, wex);
                if (code == 404)
                    throw new Exception("Azure OpenAI deployment not found (404). Check AzureDeployment name and that the deployment exists in this resource.\nURL: " + url + "\n" + detail, wex);
                if (code == 429)
                {
                    if (retry429Count < 1)
                    {
                        System.Threading.Thread.Sleep(5000);
                        return CallChat(systemMsg, userMsg, retry429Count + 1);
                    }
                    throw new Exception("Azure OpenAI rate limit/quota exceeded (429). Increase deployment TPM in Azure Portal.\nURL: " + url + "\n" + detail, wex);
                }

                throw new Exception("Azure OpenAI HTTP " + code + ".\nURL: " + url + "\n" + detail, wex);
            }

            throw new Exception(
                "Azure OpenAI network error. URL: " + url + "\n" + detail + "\n\n" +
                "Check: server internet access, firewall allows outbound HTTPS to *.openai.azure.com, TLS 1.2 enabled.",
                wex);
        }
        catch (Exception ex)
        {
            throw new Exception("Azure OpenAI request failed: " + GetDeepMessage(ex), ex);
        }
    }

    private static string ReadWebException(WebException wex)
    {
        if (wex == null) return "";

        var sb = new StringBuilder();
        sb.AppendLine("WebException: " + wex.Message);
        sb.AppendLine("Status: " + wex.Status);

        if (wex.Response is HttpWebResponse errResp)
        {
            try
            {
                using (StreamReader reader = new StreamReader(errResp.GetResponseStream(), Encoding.UTF8))
                {
                    string errBody = reader.ReadToEnd();
                    if (!string.IsNullOrWhiteSpace(errBody))
                        sb.AppendLine("Response: " + errBody);
                }
            }
            catch { }
        }

        if (wex.InnerException != null)
            sb.AppendLine("Inner: " + GetDeepMessage(wex.InnerException));

        return sb.ToString();
    }

    public static string GetDeepMessage(Exception ex)
    {
        if (ex == null) return "";
        string msg = ex.Message;
        Exception inner = ex.InnerException;
        int depth = 0;
        while (inner != null && depth < 5)
        {
            msg += " --> " + inner.Message;
            inner = inner.InnerException;
            depth++;
        }
        return msg;
    }

    /// <summary>
    /// Short message for chat UI (non-technical users).
    /// </summary>
    public static string GetUserFriendlyMessage(Exception ex)
    {
        string deep = GetDeepMessage(ex);
        string type = GetErrorType(ex, deep);

        if (type == "azure_dns")
        {
            return "AI service connect thai shakyo nathi. Admin ne kaho: Web.config ma Azure OpenAI Endpoint, Key ane Deployment name sacho karo (Azure Portal mathi).";
        }

        if (type == "azure_config")
        {
            return "AI service configure nathi. Admin ne Web.config check karava kaho.";
        }

        if (type == "azure_network")
        {
            return "Server par thi Azure sudhi internet / network problem che. Admin ne firewall ane internet check karava kaho.";
        }

        if (type == "azure_auth")
        {
            return "AI key khotu che. Admin ne kaho: AzureOpenAIKey (Web.config) new Key thi update karo.";
        }

        if (type == "azure_deployment")
        {
            return "AI deployment name khotu che. Admin ne kaho: AzureDeployment (Web.config) exact deployment name mukavo.";
        }

        if (type == "azure_quota")
        {
            return "AI quota/TPM limit puri thai gai che. Admin ne kaho: TPM quota vadharo ane pachi try karo.";
        }

        if (deep.Length > 220)
            return deep.Substring(0, 220) + "...";

        return string.IsNullOrWhiteSpace(deep) ? "Unknown error." : deep;
    }

    /// <summary>
    /// Error category for UI styling: azure_dns, azure_config, azure_network, sql, generic.
    /// </summary>
    public static string GetErrorType(Exception ex, string deepMessage)
    {
        string deep = deepMessage ?? GetDeepMessage(ex);
        if (string.IsNullOrWhiteSpace(deep)) return "generic";

        if (deep.IndexOf("could not be resolved", StringComparison.OrdinalIgnoreCase) >= 0
            || deep.IndexOf("NameResolutionFailure", StringComparison.OrdinalIgnoreCase) >= 0)
            return "azure_dns";

        if (deep.IndexOf("not configured in Web.config", StringComparison.OrdinalIgnoreCase) >= 0)
            return "azure_config";

        if (deep.IndexOf("authentication failed (401)", StringComparison.OrdinalIgnoreCase) >= 0
            || deep.IndexOf("HTTP 401", StringComparison.OrdinalIgnoreCase) >= 0)
            return "azure_auth";

        if (deep.IndexOf("deployment not found (404)", StringComparison.OrdinalIgnoreCase) >= 0
            || deep.IndexOf("HTTP 404", StringComparison.OrdinalIgnoreCase) >= 0)
            return "azure_deployment";

        if (deep.IndexOf("rate limit", StringComparison.OrdinalIgnoreCase) >= 0
            || deep.IndexOf("HTTP 429", StringComparison.OrdinalIgnoreCase) >= 0)
            return "azure_quota";

        if (deep.IndexOf("Azure OpenAI", StringComparison.OrdinalIgnoreCase) >= 0
            && (deep.IndexOf("network", StringComparison.OrdinalIgnoreCase) >= 0
                || deep.IndexOf("WebException", StringComparison.OrdinalIgnoreCase) >= 0
                || deep.IndexOf("timed out", StringComparison.OrdinalIgnoreCase) >= 0))
            return "azure_network";

        return "generic";
    }

    /// <summary>
    /// Admin/debug detail (full technical message).
    /// </summary>
    public static string GetAdminDetail(Exception ex)
    {
        return GetDeepMessage(ex);
    }
}
