using System;
using System.Linq;
using System.Text.RegularExpressions;

/// <summary>
/// Validates and normalizes AI-generated SQL before execution.
/// </summary>
public static class ElectionAISqlValidator
{
    public static string CleanRawSql(string raw)
    {
        if (string.IsNullOrWhiteSpace(raw)) return "";

        string sql = raw.Trim();
        sql = Regex.Replace(sql, @"^```sql\s*", "", RegexOptions.IgnoreCase);
        sql = Regex.Replace(sql, @"^```\s*", "", RegexOptions.IgnoreCase);
        sql = Regex.Replace(sql, @"```\s*$", "", RegexOptions.IgnoreCase);
        sql = sql.Trim().TrimEnd(';').Trim();

        // Take first statement only
        int semi = sql.IndexOf(';');
        if (semi >= 0)
            sql = sql.Substring(0, semi).Trim();

        return sql;
    }

    public static void Validate(string sql, int appId)
    {
        if (string.IsNullOrWhiteSpace(sql))
            throw new Exception("Empty SQL from AI.");

        string upper = sql.ToUpperInvariant();

        if (!upper.StartsWith("SELECT"))
            throw new Exception("Only SELECT queries are allowed.");

        foreach (string token in ElectionAIConfig.ForbiddenSqlTokens)
        {
            if (Regex.IsMatch(upper, @"\b" + Regex.Escape(token) + @"\b"))
                throw new Exception("Forbidden SQL keyword: " + token);
        }

        foreach (string prefix in ElectionAIConfig.BlockedTablePrefixes)
        {
            if (upper.Contains(prefix.ToUpperInvariant()))
                throw new Exception("Direct table access is not allowed. Use ai_* views only.");
        }

        bool hasAllowedView = ElectionAIConfig.AllowedViews
            .Any(v => Regex.IsMatch(sql, @"\b" + Regex.Escape(v) + @"\b", RegexOptions.IgnoreCase));

        if (!hasAllowedView)
            throw new Exception("Query must use at least one allowed ai_* view.");

        if (!Regex.IsMatch(sql, @"\bapp_id\s*=", RegexOptions.IgnoreCase))
            throw new Exception("Query must filter by app_id = @app_id.");

        // Normalize literal app_id = 123 to parameter
        if (Regex.IsMatch(sql, @"\bapp_id\s*=\s*\d+", RegexOptions.IgnoreCase)
            && !sql.Contains("@app_id"))
        {
            throw new Exception("Use app_id = @app_id parameter, not a numeric literal.");
        }
    }

    public static string Normalize(string sql)
    {
        sql = CleanRawSql(sql);

        // Ensure TOP on plain SELECT lists without aggregate
        string upper = sql.ToUpperInvariant();
        if (upper.StartsWith("SELECT")
            && !upper.Contains(" TOP ")
            && !upper.Contains("COUNT(")
            && !upper.Contains("SUM(")
            && !upper.Contains("AVG(")
            && !upper.Contains("MIN(")
            && !upper.Contains("MAX("))
        {
            sql = Regex.Replace(sql, @"^\s*SELECT\s+", "SELECT TOP " + ElectionAIConfig.MaxRows + " ", RegexOptions.IgnoreCase);
        }

        return sql;
    }
}
