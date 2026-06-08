<%@ WebHandler Language="C#" Class="ElectionAIHandler" %>

using System;
using System.Text;
using System.Web;

/// <summary>
/// JSON API for Election AI chat UI (application/json, no PageMethods wrapping).
/// POST: user_question, app_id
/// </summary>
public class ElectionAIHandler : IHttpHandler
{
    public void ProcessRequest(HttpContext context)
    {
        context.Response.ContentType = "application/json; charset=utf-8";
        context.Response.ContentEncoding = Encoding.UTF8;
        context.Response.HeaderEncoding = Encoding.UTF8;
        context.Response.Charset = "utf-8";
        context.Request.ContentEncoding = Encoding.UTF8;
        context.Response.Cache.SetCacheability(HttpCacheability.NoCache);

        if (!string.Equals(context.Request.HttpMethod, "POST", StringComparison.OrdinalIgnoreCase))
        {
            context.Response.StatusCode = 405;
            context.Response.Write(ElectionAIResponse.ToJsonFail("POST required."));
            return;
        }

        try
        {
            string question = (context.Request.Form["user_question"] ?? context.Request["user_question"] ?? "").Trim();
            string appIdStr = (context.Request.Form["app_id"] ?? context.Request["app_id"] ?? "").Trim();

            int appId;
            if (!int.TryParse(appIdStr, out appId) || appId <= 0)
            {
                context.Response.Write(ElectionAIResponse.ToJsonFail("Invalid app_id."));
                return;
            }

            if (string.IsNullOrWhiteSpace(question))
            {
                context.Response.Write(ElectionAIResponse.ToJsonFail("Please enter a question."));
                return;
            }

            ElectionAIResponse response = ElectionAIService.Ask(question, appId);
            context.Response.Write(response.ToJson());
        }
        catch (Exception ex)
        {
            string deep = ElectionAIClient.GetDeepMessage(ex);
            string friendly = ElectionAIClient.GetUserFriendlyMessage(ex);
            string errType = ElectionAIClient.GetErrorType(ex, deep);
            bool admin = "1".Equals(context.Request["debug"], StringComparison.OrdinalIgnoreCase);
            string detail = admin ? deep : "";
            context.Response.Write(ElectionAIResponse.ToJsonFail(friendly, errType, detail));
        }
    }

    public bool IsReusable
    {
        get { return false; }
    }
}
