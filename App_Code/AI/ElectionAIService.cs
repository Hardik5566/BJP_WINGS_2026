using System;
using System.Data;

/// <summary>
/// Orchestrates: route -> template OR LLM+schema -> validate -> execute.
/// </summary>
public static class ElectionAIService
{
    public static ElectionAIResponse Ask(string question, int appId)
    {
        if (string.IsNullOrWhiteSpace(question))
            return ElectionAIResponse.Fail("Please enter a question.", "");

        if (appId <= 0)
            return ElectionAIResponse.Fail("Invalid app_id.", "");

        question = question.Trim();

        // Stage 1: Route intent + views
        ElectionAIIntentRouter.RouteResult route = ElectionAIIntentRouter.Route(question);

        // Stage 2a: Safe template SQL (no wrong columns, no extra Azure tokens)
        string sql = ElectionAIQueryTemplates.TryBuild(route);
        string source = "template";

        // Stage 2b: LLM with injected schema for unknown / complex questions
        if (string.IsNullOrEmpty(sql))
        {
            source = "ai";
            string systemPrompt = ElectionAIPrompt.GetSystemPromptForViews(route.Views);
            try
            {
                sql = ElectionAISqlValidator.CleanRawSql(
                    ElectionAIClient.GenerateSql(systemPrompt, question));
            }
            catch (Exception ex)
            {
                string deep = ElectionAIClient.GetDeepMessage(ex);
                return ElectionAIResponse.Fail(
                    ElectionAIClient.GetUserFriendlyMessage(ex),
                    "",
                    ElectionAIClient.GetErrorType(ex, deep),
                    deep);
            }
        }

        return ExecuteWithOptionalFix(question, appId, sql, route.Views, source);
    }

    private static ElectionAIResponse ExecuteWithOptionalFix(
        string question, int appId, string sql, string[] views, string source)
    {
        string lastError = "";
        string systemPrompt = ElectionAIPrompt.GetSystemPromptForViews(views);

        for (int attempt = 0; attempt < 2; attempt++)
        {
            try
            {
                DataTable dt = ElectionAIExecutor.Execute(sql, appId);
                var res = ElectionAIResponse.Ok(dt, sql);
                if (source == "template")
                    res.message = "OK (template)";
                return res;
            }
            catch (Exception ex)
            {
                lastError = ElectionAIClient.GetDeepMessage(ex);
                if (attempt == 0)
                {
                    try
                    {
                        sql = ElectionAISqlValidator.CleanRawSql(
                            ElectionAIClient.FixSql(systemPrompt, question, sql, lastError));
                        source = "ai-fix";
                    }
                    catch (Exception fixEx)
                    {
                        lastError = ElectionAIClient.GetDeepMessage(fixEx);
                        break;
                    }
                }
                else
                {
                    break;
                }
            }
        }

        return ElectionAIResponse.Fail(
            ElectionAIClient.GetUserFriendlyMessage(new Exception(lastError)),
            sql,
            ElectionAIClient.GetErrorType(null, lastError),
            lastError);
    }
}
