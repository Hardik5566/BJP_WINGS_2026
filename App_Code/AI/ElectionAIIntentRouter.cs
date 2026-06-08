using System;
using System.Collections.Generic;
using System.Text.RegularExpressions;

/// <summary>
/// Stage 1: route question to intent + required ai_* views (no LLM needed for common patterns).
/// </summary>
public static class ElectionAIIntentRouter
{
    public enum Intent
    {
        Unknown,
        BoothVoterCount,
        BoothSlipNotSent,
        BoothSurveyBreakdown,
        VoterNameSearch,
        StaffByBooth,
        StaffAdminList,
        UserSlipToday,
        BoothDashboard,
        BoothPramukhList
    }

    public class RouteResult
    {
        public Intent Intent { get; set; }
        public string[] Views { get; set; }
        public int? BoothNo { get; set; }
        public string SearchName { get; set; }
        public int? UserId { get; set; }
    }

    public static RouteResult Route(string question)
    {
        var r = new RouteResult { Intent = Intent.Unknown, Views = new string[0] };
        if (string.IsNullOrWhiteSpace(question)) return r;

        string q = question.Trim().ToLowerInvariant();
        r.BoothNo = ExtractBoothNo(q);
        r.UserId = ExtractUserId(q);
        r.SearchName = ExtractPersonName(question);

        // Survey: booth 3 positive negative
        if (r.BoothNo.HasValue && Regex.IsMatch(q, @"positive|negative|doubtful|survey|cant\s*say"))
        {
            r.Intent = Intent.BoothSurveyBreakdown;
            r.Views = new[] { "ai_voter_survey", "ai_booth_dashboard" };
            return r;
        }

        // Slip not sent
        if (r.BoothNo.HasValue && Regex.IsMatch(q, @"slip|sleep|nathi\s*mali"))
        {
            r.Intent = Intent.BoothSlipNotSent;
            r.Views = new[] { "ai_booth_dashboard" };
            return r;
        }

        // Booth voter count
        if (r.BoothNo.HasValue && Regex.IsMatch(q, @"ketla\s*voter|total\s*voter|voter\s*count|voter\s*ketla|ma\s*ketla"))
        {
            r.Intent = Intent.BoothVoterCount;
            r.Views = new[] { "ai_booth_dashboard", "ai_voter" };
            return r;
        }

        // Name search
        if (!string.IsNullOrEmpty(r.SearchName) && Regex.IsMatch(q, @"voter|nam\s*na|name"))
        {
            r.Intent = Intent.VoterNameSearch;
            r.Views = new[] { "ai_voter" };
            return r;
        }

        // Booth Pramukh (BP) list — user_type = 'BP'
        if (Regex.IsMatch(q, @"pramukh|booth\s*president|\bbp\s*list|\bbp\b.*list|list.*\bbp\b"))
        {
            r.Intent = Intent.BoothPramukhList;
            r.Views = new[] { "ai_user" };
            return r;
        }

        // Staff BP at specific booth
        if (r.BoothNo.HasValue && Regex.IsMatch(q, @"\bbp\b|booth\s*president|kon\s*che|pramukh"))
        {
            r.Intent = Intent.StaffByBooth;
            r.Views = new[] { "ai_user", "ai_user_booth_flat" };
            return r;
        }

        // Generic staff list (not BP/pramukh)
        if (Regex.IsMatch(q, @"staff\s*list|user\s*list|karmchari") && !Regex.IsMatch(q, @"pramukh|\bbp\b"))
        {
            r.Intent = Intent.StaffAdminList;
            r.Views = new[] { "ai_user" };
            return r;
        }

        // User slip today
        if (r.UserId.HasValue && Regex.IsMatch(q, @"slip|sleep|ketli"))
        {
            r.Intent = Intent.UserSlipToday;
            r.Views = new[] { "ai_user_activity_log" };
            return r;
        }

        // Generic booth dashboard
        if (r.BoothNo.HasValue)
        {
            r.Intent = Intent.BoothDashboard;
            r.Views = new[] { "ai_booth_dashboard" };
            return r;
        }

        // LLM fallback views guess from keywords
        r.Views = GuessViewsFromKeywords(q);
        return r;
    }

    private static string[] GuessViewsFromKeywords(string q)
    {
        var list = new List<string>();
        if (Regex.IsMatch(q, @"voter|idcard|surname|family")) list.Add("ai_voter");
        if (Regex.IsMatch(q, @"survey|positive|negative")) list.Add("ai_voter_survey");
        if (Regex.IsMatch(q, @"slip|sleep|prachar|activity")) list.Add("ai_user_activity_log");
        if (Regex.IsMatch(q, @"staff|user|bp|sp|k\b|admin|mobile")) list.Add("ai_user");
        if (Regex.IsMatch(q, @"booth|ketla|count|summary|dashboard")) list.Add("ai_booth_dashboard");
        if (list.Count == 0) list.Add("ai_voter");
        return list.ToArray();
    }

    private static int? ExtractBoothNo(string q)
    {
        var m = Regex.Match(q, @"booth\s*[#:]?\s*(\d+)", RegexOptions.IgnoreCase);
        if (m.Success) return int.Parse(m.Groups[1].Value);
        m = Regex.Match(q, @"(\d+)\s*ma\s");
        if (m.Success) return int.Parse(m.Groups[1].Value);
        return null;
    }

    private static int? ExtractUserId(string q)
    {
        var m = Regex.Match(q, @"user[_\s-]*id\s*(\d+)", RegexOptions.IgnoreCase);
        if (m.Success) return int.Parse(m.Groups[1].Value);
        return null;
    }

    private static string ExtractPersonName(string question)
    {
        if (string.IsNullOrWhiteSpace(question)) return null;
        var m = Regex.Match(question, @"([A-Za-z\u0A80-\u0AFF]+)\s+nam\s+na", RegexOptions.IgnoreCase);
        if (m.Success) return m.Groups[1].Value.Trim();
        m = Regex.Match(question, @"nam\s+na\s+([A-Za-z\u0A80-\u0AFF]+)", RegexOptions.IgnoreCase);
        if (m.Success) return m.Groups[1].Value.Trim();
        return null;
    }
}
