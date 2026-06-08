using System;
using System.Collections.Generic;
using System.Text;

/// <summary>
/// Exact ai_* view column lists for LLM schema injection (Stage 2).
/// </summary>
public static class ElectionAISchemaRegistry
{
    private static readonly Dictionary<string, string> ViewSchemas = new Dictionary<string, string>(StringComparer.OrdinalIgnoreCase)
    {
        {
            "ai_voter",
            @"ai_voter columns:
booth_no, voter_sr_no, f_name, eng_f_name, m_name, eng_m_name, surname, eng_surname,
voter_name_gu, voter_name_en, idcard_no, age, age_int, gender, contact_no, family_id,
sleep_send, slip_send_count, polling_location, house_no
NEVER: voter_name, part_no, result"
        },
        {
            "ai_user",
            @"ai_user columns:
user_id, name, mobile_no, user_type, role_name, booth_list, primary_booth_no,
last_login, days_since_login, start_voter_no, end_voter_no
Staff name search: name LIKE N'%text%'
Booth Pramukh = user_type 'BP', use primary_booth_no as booth_no"
        },
        {
            "ai_user_booth_flat",
            @"ai_user_booth_flat columns:
user_id, user_name, user_type, role_name, booth_no, mobile_no, last_login"
        },
        {
            "ai_voter_survey",
            @"ai_voter_survey columns:
booth_no, voter_sr_no, idcard_no, f_name, eng_f_name, surname, eng_surname,
voter_status (P/N/D/C), voter_status_label (Positive/Negative/Doubtful/Cant Say),
survey_date, survey_by_name, visit_count
Survey breakdown:
SELECT voter_status_label, COUNT(*) AS total FROM ai_voter_survey ... GROUP BY voter_status_label
NEVER: result, status_label"
        },
        {
            "ai_booth_dashboard",
            @"ai_booth_dashboard columns:
booth_no, total_voters, slip_sent_count, slip_not_sent_count,
survey_done_count, survey_pending_count,
positive_count, negative_count, doubtful_count, cant_say_count"
        },
        {
            "ai_user_activity_log",
            @"ai_user_activity_log columns:
user_id, user_name, user_type, role_name, voter_idcard, booth_no, voter_sr_no,
prachar_type, activity_date
Slip types: prachar_type IN ('SLEEP','SMS SLEEP','PRINT','WEB','W-SLEEP')"
        },
        {
            "ai_vc_voter_range",
            @"ai_vc_voter_range columns:
user_id, vc_name, mobile_no, booth_no, voter_sr_no, f_name, eng_f_name, surname, eng_surname, age, gender"
        }
    };

    public static string GetSchema(params string[] viewNames)
    {
        if (viewNames == null || viewNames.Length == 0)
            return GetAllSchemasCompact();

        var sb = new StringBuilder();
        foreach (string v in viewNames)
        {
            string key = (v ?? "").Trim();
            if (ViewSchemas.ContainsKey(key))
                sb.AppendLine(ViewSchemas[key]).AppendLine();
        }
        return sb.ToString().Trim();
    }

    public static string GetAllSchemasCompact()
    {
        var sb = new StringBuilder();
        foreach (var kv in ViewSchemas)
            sb.AppendLine(kv.Value).AppendLine();
        return sb.ToString().Trim();
    }

    public static bool IsKnownView(string viewName)
    {
        return ViewSchemas.ContainsKey(viewName ?? "");
    }
}
