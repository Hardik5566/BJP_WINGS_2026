using System;
using System.Collections.Generic;

/// <summary>
/// Configuration for Election AI (isolated module under App_Code/AI).
/// </summary>
public static class ElectionAIConfig
{
    public const int MaxRows = 100;
    public const int CommandTimeoutSeconds = 20;
    public const int SqlConnectTimeoutSeconds = 15;
    // Keep low while TPM quota is small (prevents 429).
    public const int AzureMaxTokens = 250;
    public const int AzureTimeoutSeconds = 45;

    public static readonly string[] AllowedViews = new[]
    {
        "ai_voter",
        "ai_user",
        "ai_user_booth_flat",
        "ai_voter_survey",
        "ai_user_activity_log",
        "ai_booth_dashboard",
        "ai_vc_voter_range"
    };

    public static readonly string[] ForbiddenSqlTokens = new[]
    {
        "INSERT", "UPDATE", "DELETE", "DROP", "TRUNCATE", "ALTER", "CREATE",
        "EXEC", "EXECUTE", "MERGE", "GRANT", "REVOKE", "xp_", "sp_",
        "INTO", "OPENROWSET", "OPENDATASOURCE"
    };

    public static readonly string[] BlockedTablePrefixes = new[]
    {
        "tbl_", "dbo.tbl_"
    };
}
