using System;
using System.IO;
using System.Web;

/// <summary>
/// System prompt for Azure OpenAI SQL generation (Stage 2 with schema injection).
/// </summary>
public static class ElectionAIPrompt
{
    private static string _cachedFullGuide;

    public static string GetSystemPrompt()
    {
        return GetSystemPromptForViews(null);
    }

    public static string GetSystemPromptForViews(string[] viewNames)
    {
        try
        {
            string useFull = System.Configuration.ConfigurationManager.AppSettings["ElectionAIUseFullGuide"];
            if (string.Equals(useFull, "true", StringComparison.OrdinalIgnoreCase))
                return BuildFullGuidePrompt(viewNames);
        }
        catch { }

        return BuildCompactPrompt(viewNames);
    }

    public static void ClearCache()
    {
        _cachedFullGuide = null;
    }

    private static string BuildCompactPrompt(string[] viewNames)
    {
        string schema = (viewNames != null && viewNames.Length > 0)
            ? ElectionAISchemaRegistry.GetSchema(viewNames)
            : ElectionAISchemaRegistry.GetAllSchemasCompact();

        return @"
You are a T-SQL generator for BJP Wings election data.
Output ONLY one SELECT statement. No markdown. No comments.

GLOBAL RULES:
- MUST include: WHERE app_id = @app_id (parameter @app_id only)
- SELECT only. Lists: SELECT TOP 100. Aggregates: COUNT/SUM ok without TOP.
- Use WITH (NOLOCK). Booth column is booth_no (never part_no).
- String filters: LIKE N'%text%'
- Use ONLY columns listed below. NEVER invent column names like voter_name or result.

" + schema;
    }

    private static string BuildFullGuidePrompt(string[] viewNames)
    {
        if (string.IsNullOrEmpty(_cachedFullGuide))
        {
            _cachedFullGuide = "";
            try
            {
                if (HttpContext.Current != null)
                {
                    string path = HttpContext.Current.Server.MapPath("~/Database/AI/AI_Schema_Guide.txt");
                    if (File.Exists(path))
                        _cachedFullGuide = File.ReadAllText(path) + "\n\n";
                }
            }
            catch { }
            _cachedFullGuide += BuildCompactPrompt(null);
        }

        if (viewNames != null && viewNames.Length > 0)
        {
            return _cachedFullGuide + "\n\nFOCUS VIEWS FOR THIS QUESTION:\n"
                + ElectionAISchemaRegistry.GetSchema(viewNames);
        }

        return _cachedFullGuide;
    }
}
