<%@ WebHandler Language="C#" Class="AzureCheckHandler" %>

using System;
using System.Configuration;
using System.Net;
using System.Net.Sockets;
using System.Text;
using System.Web;

/// <summary>
/// Admin: test Azure OpenAI DNS + config (open /AI/AzureCheck.ashx in browser).
/// </summary>
public class AzureCheckHandler : IHttpHandler
{
    public void ProcessRequest(HttpContext context)
    {
        context.Response.ContentType = "text/html; charset=utf-8";
        context.Response.ContentEncoding = Encoding.UTF8;

        string endpoint = ConfigurationManager.AppSettings["AzureOpenAIEndpoint"] ?? "";
        string deployment = ConfigurationManager.AppSettings["AzureDeployment"] ?? "";
        string key = ConfigurationManager.AppSettings["AzureOpenAIKey"] ?? "";
        bool hasKey = !string.IsNullOrWhiteSpace(key);

        var sb = new StringBuilder();
        sb.Append("<html><head><meta charset='utf-8'/><title>Azure AI Check</title>");
        sb.Append("<style>body{font-family:Segoe UI,sans-serif;margin:24px;max-width:720px}");
        sb.Append(".ok{color:#0a7}.bad{color:#c00}pre{background:#f4f4f4;padding:12px;overflow:auto}</style></head><body>");
        sb.Append("<h2>Azure OpenAI configuration check</h2>");

        if (string.IsNullOrWhiteSpace(endpoint))
        {
            sb.Append("<p class='bad'><b>AzureOpenAIEndpoint</b> is empty in Web.config.</p>");
            context.Response.Write(sb.ToString() + "</body></html>");
            return;
        }

        sb.Append("<p><b>Endpoint:</b> ").Append(WebUtility.HtmlEncode(endpoint)).Append("</p>");
        sb.Append("<p><b>Deployment:</b> ").Append(WebUtility.HtmlEncode(deployment)).Append("</p>");
        sb.Append("<p><b>API Key:</b> ").Append(hasKey ? "set (hidden)" : "<span class='bad'>missing</span>").Append("</p>");

        string host = "";
        try
        {
            var uri = new Uri(endpoint.Trim());
            host = uri.Host;
        }
        catch (Exception ex)
        {
            sb.Append("<p class='bad'>Invalid endpoint URL: ").Append(WebUtility.HtmlEncode(ex.Message)).Append("</p>");
            context.Response.Write(sb.ToString() + "</body></html>");
            return;
        }

        sb.Append("<p><b>Hostname:</b> ").Append(WebUtility.HtmlEncode(host)).Append("</p>");

        try
        {
            IPHostEntry entry = Dns.GetHostEntry(host);
            sb.Append("<p class='ok'><b>DNS OK</b> resolved to: ");
            for (int i = 0; i < entry.AddressList.Length; i++)
            {
                if (i > 0) sb.Append(", ");
                sb.Append(entry.AddressList[i]);
            }
            sb.Append("</p>");
        }
        catch (SocketException ex)
        {
            sb.Append("<p class='bad'><b>DNS FAILED</b> - hostname could not be resolved.</p>");
            sb.Append("<pre>").Append(WebUtility.HtmlEncode(ex.Message)).Append("</pre>");
            sb.Append("<h3>Fix</h3><ol>");
            sb.Append("<li>Azure Portal &rarr; your <b>Azure OpenAI</b> resource &rarr; <b>Keys and Endpoint</b></li>");
            sb.Append("<li>Copy the <b>Endpoint</b> (example: https://YOUR-NAME.openai.azure.com/)</li>");
            sb.Append("<li>Update <b>Web.config</b>: AzureOpenAIEndpoint, AzureOpenAIKey, AzureDeployment</li>");
            sb.Append("<li>Recycle IIS / restart app pool</li>");
            sb.Append("</ol>");
            sb.Append("<p>Current hostname <code>").Append(WebUtility.HtmlEncode(host));
            sb.Append("</code> does not exist on the internet (resource deleted, renamed, or typo).</p>");
        }

        sb.Append("<p><a href='Chat.aspx'>Back to Chat</a></p></body></html>");
        context.Response.Write(sb.ToString());
    }

    public bool IsReusable { get { return false; } }
}
