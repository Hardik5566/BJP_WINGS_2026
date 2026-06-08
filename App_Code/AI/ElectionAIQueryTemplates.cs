using System;

/// <summary>
/// Safe pre-built SQL for common intents (no wrong columns — uses exact view columns).
/// </summary>
public static class ElectionAIQueryTemplates
{
    public static string TryBuild(ElectionAIIntentRouter.RouteResult route)
    {
        if (route == null || route.Intent == ElectionAIIntentRouter.Intent.Unknown)
            return null;

        switch (route.Intent)
        {
            case ElectionAIIntentRouter.Intent.BoothVoterCount:
                return BoothCountSql(route.BoothNo.Value);

            case ElectionAIIntentRouter.Intent.BoothSlipNotSent:
                return "SELECT booth_no, slip_not_sent_count FROM ai_booth_dashboard WITH (NOLOCK) "
                    + "WHERE app_id = @app_id AND booth_no = " + route.BoothNo.Value;

            case ElectionAIIntentRouter.Intent.BoothSurveyBreakdown:
                return "SELECT voter_status_label, COUNT(*) AS total FROM ai_voter_survey WITH (NOLOCK) "
                    + "WHERE app_id = @app_id AND booth_no = " + route.BoothNo.Value
                    + " AND voter_status IS NOT NULL GROUP BY voter_status_label";

            case ElectionAIIntentRouter.Intent.VoterNameSearch:
                return VoterNameSql(route.SearchName);

            case ElectionAIIntentRouter.Intent.BoothPramukhList:
                return BoothPramukhListSql(route.BoothNo);

            case ElectionAIIntentRouter.Intent.StaffByBooth:
                return "SELECT TOP 100 name, mobile_no, role_name, primary_booth_no FROM ai_user WITH (NOLOCK) "
                    + "WHERE app_id = @app_id AND user_type = 'BP' AND primary_booth_no = " + route.BoothNo.Value;

            case ElectionAIIntentRouter.Intent.StaffAdminList:
                return "SELECT TOP 100 user_id, name, mobile_no, user_type, role_name, booth_list FROM ai_user WITH (NOLOCK) "
                    + "WHERE app_id = @app_id ORDER BY name";

            case ElectionAIIntentRouter.Intent.UserSlipToday:
                return "SELECT COUNT(*) AS slip_count FROM ai_user_activity_log WITH (NOLOCK) "
                    + "WHERE app_id = @app_id AND user_id = " + route.UserId.Value
                    + " AND prachar_type IN ('SLEEP','SMS SLEEP','PRINT','WEB','W-SLEEP') "
                    + "AND activity_date = CAST(GETDATE() AS DATE)";

            case ElectionAIIntentRouter.Intent.BoothDashboard:
                return "SELECT booth_no, total_voters, slip_sent_count, slip_not_sent_count, "
                    + "positive_count, negative_count, doubtful_count, cant_say_count "
                    + "FROM ai_booth_dashboard WITH (NOLOCK) WHERE app_id = @app_id AND booth_no = "
                    + route.BoothNo.Value;

            default:
                return null;
        }
    }

    private static string BoothPramukhListSql(int? boothNo)
    {
        string sql = "SELECT TOP 100 user_id, name, mobile_no, role_name, primary_booth_no AS booth_no "
            + "FROM ai_user WITH (NOLOCK) WHERE app_id = @app_id AND user_type = 'BP'";
        if (boothNo.HasValue)
            sql += " AND primary_booth_no = " + boothNo.Value;
        sql += " ORDER BY primary_booth_no, name";
        return sql;
    }

    private static string BoothCountSql(int boothNo)
    {
        return "SELECT booth_no, total_voters FROM ai_booth_dashboard WITH (NOLOCK) "
            + "WHERE app_id = @app_id AND booth_no = " + boothNo;
    }

    private static string VoterNameSql(string name)
    {
        if (string.IsNullOrWhiteSpace(name)) return null;
        string n = name.Replace("'", "''");
        return "SELECT TOP 100 booth_no, voter_sr_no, voter_name_gu, voter_name_en, idcard_no, age, gender "
            + "FROM ai_voter WITH (NOLOCK) WHERE app_id = @app_id AND ("
            + "voter_name_gu LIKE N'%" + n + "%' OR voter_name_en LIKE N'%" + n + "%' "
            + "OR f_name LIKE N'%" + n + "%' OR eng_f_name LIKE N'%" + n + "%')";
    }
}
