<%@ WebHandler Language="C#" Class="AzureCallTestHandler" %>

using System;
using System.Configuration;
using System.Text;
using System.Web;

/// <summary>
/// Admin: test Azure OpenAI. Default = tiny call. ?full=1 = real election prompt (same as Chat).
/// </summary>
public class AzureCallTestHandler : IHttpHandler
{
    public void ProcessRequest(HttpContext context)
    {
        context.Response.ContentType = "text/plain; charset=utf-8";
        context.Response.ContentEncoding = Encoding.UTF8;

        string endpoint = ConfigurationManager.AppSettings["AzureOpenAIEndpoint"] ?? "";
        string deployment = ConfigurationManager.AppSettings["AzureDeployment"] ?? "";
        bool full = "1".Equals(context.Request["full"], StringComparison.OrdinalIgnoreCase);

        context.Response.Write("Endpoint: " + endpoint + "\n");
        context.Response.Write("Deployment: " + deployment + "\n");
        context.Response.Write("Mode: " + (full ? "FULL (same as Chat)" : "MINIMAL") + "\n\n");

        try
        {
            string system;
            string user;
            if (full)
            {
                ElectionAIPrompt.ClearCache();
                system = ElectionAIPrompt.GetSystemPrompt();
                user = "booth 5 ma ketla voter?";
                context.Response.Write("System prompt length: " + system.Length + " chars\n\n");
            }
            else
            {
                system = "You are a tester. Reply with OK.";
                user = "OK";
            }

            string r = ElectionAIClient.GenerateSql(system, user);
            context.Response.Write("SUCCESS. Response:\n" + r + "\n");
        }
        catch (Exception ex)
        {
            context.Response.Write("FAILED:\n");
            context.Response.Write(ElectionAIClient.GetAdminDetail(ex));
            context.Response.Write("\n\nUSER FRIENDLY:\n");
            context.Response.Write(ElectionAIClient.GetUserFriendlyMessage(ex));
            context.Response.Write("\n");
        }
    }

    public bool IsReusable { get { return false; } }
}
