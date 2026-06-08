using Newtonsoft.Json;
using System;
using System.Collections.Generic;
using System.Linq;
using System.Net.Http;
using System.Text;
using System.Threading.Tasks;

public class AIQueryEngine
{
    private static readonly string endpoint = System.Configuration.ConfigurationManager.AppSettings["AzureOpenAIEndpoint"];
    private static readonly string apiKey = System.Configuration.ConfigurationManager.AppSettings["AzureOpenAIKey"];
    private static readonly string deployment = System.Configuration.ConfigurationManager.AppSettings["AzureDeployment"];

    public static async Task<string> GetGeneratedSql(string userQuestion, string appId)
    {
        // 1. MASTER TABLE REGISTRY (આ તમારા 100 ટેબલનો નકશો છે)
        var registry = new Dictionary<string, string>
        {
            { "vw_voter_search_AI", "Voter details, age math, booth (part_no), slip status (sleep_send). Standard 7-column list." },
            { "vw_get_all_user", "Staff, Workers, Booth Pramukh (BP), Sakti Kendra (SP), login activity, and names." },
            { "vw_user_latest_voter_survey", "Survey status (Positive, Negative, Doubtful, Cant Say), visits, religion, caste." }
        };

        // STEP 1: ROUTING - AI ને પૂછવું કે કયા ટેબલ વાપરવા
        string tableContext = string.Join("\n", registry.Select(x => $"- {x.Key}: {x.Value}"));
        string routerPrompt = $@"Identify which table(s) are needed for: '{userQuestion}'. Return ONLY table names separated by comma.\nTables:\n{tableContext}";
        string neededTables = await CallAzureOpenAI(routerPrompt, "");

        // STEP 2: DYNAMIC PROMPT BUILDING (તમારા બધા રૂલ્સ અહીં છે)
        StringBuilder sb = new StringBuilder();

        // --- GLOBAL SECURITY & SYNTAX (ક્યારેય નહીં બદલાય) ---
        sb.AppendLine("You are a strict T-SQL Expert. Output ONLY raw T-SQL. No JSON, no markdown, no explanations.");
        sb.AppendLine($"[GLOBAL PERMANENT RULES]");
        sb.AppendLine($"- Always use 'app_id = {appId}' and 'WITH (NOLOCK)'.");
        sb.AppendLine("- Always use 'SELECT TOP 1000'. NEVER use 'LIMIT'.");
        sb.AppendLine("- Use N'' for Unicode strings. Use TRY_CAST(NULLIF(age, '-') AS INT) for age.");
        sb.AppendLine("- PERCENTAGE: ALWAYS use FORMAT(value, 'N2').");

        // --- GLOBAL JOIN AXIOMS (100 ટેબલ જોડવા માટેનો પાયો) ---
        sb.AppendLine("[GLOBAL JOIN RELATIONSHIPS]");
        sb.AppendLine("- Voter(v) <-> Survey(s): v.idcard_no = s.voter_idcard");
        sb.AppendLine("- Voter(v) <-> Staff(u): v.part_no = CAST(u.booth_no AS INT)");
        sb.AppendLine("- Survey(s) <-> Staff(u): s.survey_by = u.user_id");

        // --- GLOBAL STATUS MAPPING (Positive/Negative Fix) ---
        sb.AppendLine("[STATUS DEFINITIONS]");
        sb.AppendLine("- 'Positive' -> s.voter_status = 'P' | 'Negative' -> s.voter_status = 'N'");
        sb.AppendLine("- 'Doubtful' -> s.voter_status = 'D' | 'Cant Say' -> s.voter_status = 'C'");
        sb.AppendLine("- MANDATORY: If Positive/Negative/Doubtful/Survey is asked, JOIN vw_user_latest_voter_survey AND s.is_latest = 1.");
        sb.AppendLine("- CRITICAL: NEVER use 'sleep_send' for survey status.");

        // --- INJECT SPECIFIC VIEW RULES ---
        if (neededTables.Contains("vw_voter_search_AI"))
        {
            sb.AppendLine(@"[VOTER RULES]
- COLUMN LIST: part_no AS [Booth No], slnoinpart AS [Voter Sr No], (f_name + ' ' + m_name + ' ' + f_surname) AS [Voter Name Gujarati], (eng_f_name + ' ' + eng_m_name + ' ' + eng_surname) AS [Voter Name English], age AS [Age], sex AS [Gender], polling_location AS [Polling Address].
- SLIP: 'not received sleep' -> (sleep_send = 0 OR sleep_send IS NULL).
- RANGE: Use UNION ALL for multiple age ranges.");
        }

        if (neededTables.Contains("vw_get_all_user"))
        {
            sb.AppendLine(@"[WORKER RULES]
- BOOTH PRAMUKH: user_type = 'BP'. Filter BP by name in subquery or join.
- LOGIN: Use DATEDIFF(DAY, last_login, GETDATE()) AS [Days Since Last Login].");
        }

        // STEP 3: GENERATION
        return await CallAzureOpenAI(sb.ToString(), userQuestion);
    }

    //    public static async Task<string> GetGeneratedSql(string userQuestion, string appId)
    //    {
    //        // 1. DYNAMIC REGISTRY (Add all 100+ tables/views here)
    //        var registry = new Dictionary<string, string>
    //        {
    //            { "vw_voter_search_AI", "Voter/citizen search, age, booth (part_no), polling locations, and slip (sleep_send) status." },
    //            { "vw_get_all_user", "App users/workers: Admin (A), Booth Pramukh (BP), Sakti Kendra (SP), Karyakarta (K), etc. assigned to booths." },
    //            { "vw_user_latest_voter_survey", "Voter survey results, availability, religion, caste, and voter_status (P/N/D/C)." }
    //        };

    //        // 2. STEP 1: ROUTING (Identifies which table schema to load)
    //        string tableContext = string.Join("\n", registry.Select(x => $"- {x.Key}: {x.Value}"));
    //        string routerPrompt = $@"Identify which table(s) are needed for: '{userQuestion}'.
    //Return ONLY comma-separated table names.
    //Available:
    //{tableContext}";

    //        string neededTables = await CallAzureOpenAI(routerPrompt, "");

    //        // 3. STEP 2: BUILD DYNAMIC SYSTEM PROMPT (Restoring every single word of your rules)
    //        StringBuilder sb = new StringBuilder();
    //        sb.AppendLine("You are a strict T-SQL Expert. Output ONLY raw T-SQL. No JSON, no markdown, no explanations, no 'answer' text.");
    //        sb.AppendLine($"[SECURITY RULE - CRITICAL]\n- ONLY 'SELECT' queries are allowed.\n- NEVER generate INSERT, UPDATE, DELETE, DROP, TRUNCATE, ALTER, or EXECUTE statements.");
    //        sb.AppendLine($"[GLOBAL PERMANENT RULES]\n1. APP ID: Every query MUST have 'app_id = {appId}'.\n2. SECURITY: Use 'WITH (NOLOCK)'. No 'SELECT *'. List explicit columns.\n3. SQL SYNTAX: ALWAYS use 'SELECT TOP 1000'. NEVER use 'LIMIT'. Using 'LIMIT' is strictly forbidden.\n4. IDENTIFIER FIX: NEVER use double quotes (\"\") for strings. Always use single quotes N'' (e.g. N'Value').\n5. PERCENTAGE RULE: ALWAYS return values formatted to exactly two decimal places (e.g., FORMAT(value, 'N2') or ROUND(value, 2)).");

    //        // --- INJECT VOTER RULES (Word-for-Word from your original) ---
    //        if (neededTables.Contains("vw_voter_search_AI"))
    //        {
    //            sb.AppendLine($@"You are a strict T-SQL Expert. Output ONLY raw T-SQL. No JSON, no markdown, no explanations, no 'answer' text.

    //[DATABASE SCHEMA]
    //View: vw_voter_search_AI
    //- ac_no (int): Assembly No
    //- part_no (int): Booth/Part Number (This is BOOTH)
    //- slnoinpart (int): Serial No
    //- f_name (nvarchar): First Name Unicode
    //- eng_f_name (nvarchar): First Name English
    //- m_name (nvarchar): Father/Middle Name Unicode
    //- eng_m_name (nvarchar): Father/Middle Name English
    //- f_surname (nvarchar): Surname Unicode
    //- idcard_no (nvarchar): Voter ID
    //- sex (nvarchar): Gender (M/F)
    //- age (nvarchar): Age (Needs CAST)
    //- contact_no (nvarchar): Mobile
    //- family_id (bigint): Family ID
    //- sleep_send (int): 1 = Received Slip, 0 = Not Received
    //- polling_location (nvarchar): Voting Place Name (Unicode / Matdan Sthal)
    //- eng_polling_location (nvarchar): Voting Place Name (English)
    //- app_id (int): {appId}

    //[SECURITY RULE - CRITICAL]
    //- ONLY 'SELECT' queries are allowed. 
    //- NEVER generate INSERT, UPDATE, DELETE, DROP, TRUNCATE, ALTER, or EXECUTE statements.

    //[PERMANENT RULES]
    //1. APP ID: Every query MUST have 'app_id = {appId}'.
    //2. SLIP/SLEEP: 'voter not received sleep' means: (sleep_send = 0 OR sleep_send IS NULL).
    //3. SLIP/SLEEP: 'voter received sleep' means: sleep_send = 1.
    //4. NAMES: Search both f_name (N'') and eng_f_name using OR.
    //5. AGE: Use TRY_CAST(NULLIF(age, '-') AS INT) for any age math.
    //6. SECURITY: Use 'WITH (NOLOCK)'. No 'SELECT *'. List explicit columns.
    //7. COUNT: If user says 'how many' or 'total', use SELECT COUNT(*).
    //8. LIMIT: Use 'TOP 1000' for list queries.
    //9. BOOTH: 'part_no' is the booth number.
    //10. FIRST TIME VOTERS: If user asks for 'First time' or 'Nava' (New) voters, filter by age BETWEEN 18 AND 23.
    //11. IDENTIFIER FIX: NEVER use double quotes ("") for strings. Always use single quotes N'' (e.g. N'Value').
    //12. COLUMN LIST RULE: Every list query MUST include these columns in this order:
    //   - part_no AS [Booth No]
    //   - slnoinpart AS [Voter Sr No]
    //   - (f_name + ' ' + m_name + ' ' + f_surname) AS [Voter Name Gujarati]
    //   - (eng_f_name + ' ' + eng_m_name + ' ' + eng_surname) AS [Voter Name English]
    //   - age AS [Age]
    //   - sex AS [Gender]
    //   - polling_location AS [Polling Address]
    //13. SQL SYNTAX: ALWAYS use 'SELECT TOP 1000'. NEVER use 'LIMIT'. Using 'LIMIT' is strictly forbidden and will break the system.
    //14. PERCENTAGE RULE: If the user asks for percentages, ALWAYS return the value formatted to exactly two decimal places (e.g., FORMAT(value, 'N2') or ROUND(value, 2)).
    //15. SLIP/SLEEP: ONLY use 'sleep_send' if the user explicitly asks for 'slip' or 'sleep'.

    //[NEW: RANGE & GROUPING RULE - CRITICAL]
    //10. If the user asks for multiple age ranges (e.g., '18-22, 23-25'), you MUST use UNION ALL to show them as separate rows with a label.
    //    Example Format:
    //    SELECT '18-22' AS [Age Range], COUNT(*) AS [Total Voters] FROM vw_voter_search_AI WITH (NOLOCK) WHERE app_id = {appId} AND TRY_CAST(NULLIF(age, '-') AS INT) BETWEEN 18 AND 22
    //    UNION ALL
    //    SELECT '23-25' AS [Age Range], COUNT(*) AS [Total Voters] FROM vw_voter_search_AI WITH (NOLOCK) WHERE app_id = {appId} AND TRY_CAST(NULLIF(age, '-') AS INT) BETWEEN 23 AND 25

    //[STRICT RULES]
    //1. DUPLICATE VOTER RULE: 
    //   If the user asks for ""duplicates"", you MUST find voters with the SAME idcard_no.
    //   Example Logic:
    //   SELECT idcard_no, COUNT(*) as [Total Occurrences] FROM vw_voter_search_AI WITH (NOLOCK) WHERE app_id = {appId} GROUP BY idcard_no HAVING COUNT(*) > 1;

    //2. FULL NAMES: When displaying names, concatenate them as:
    //   - (f_name + ' ' + m_name + ' ' + f_surname) AS [Voter Name Gujarati]
    //   - (eng_f_name + ' ' + eng_m_name + ' ' + eng_surname) AS [Voter Name English]

    //[Family]
    //FAMILY LIST RULE: If asked for ""family list"" of a specific voter, you MUST find their family_id first and then show all members.
    //   Example: 
    //   SELECT f_name, eng_f_name, eng_m_name, f_surname, idcard_no, age, part_no 
    //   FROM vw_voter_search_AI WITH (NOLOCK) 
    //   WHERE family_id = (SELECT TOP 1 family_id FROM vw_voter_search_AI WHERE idcard_no = 'QUERY_ID' AND app_id = {appId}) 
    //   AND app_id = {appId}

    //[POLLING LOCATION RULE]
    //- If a user mentions a place, school, or location:
    //  - Use: [polling_location] LIKE N'%keyword%' OR [eng_polling_location] LIKE '%keyword%'
    //  - Use only the core name (e.g., if user says 'Saraswati Primary School', search '%SARASWATI PRIMARY%').

    //[PIVOT/SIDE-BY-SIDE EXAMPLE]
    //User: ""booth wise sleep send and not send voter count""
    //SQL:
    //SELECT part_no AS [Booth No], SUM(CASE WHEN sleep_send = 1 THEN 1 ELSE 0 END) AS [Total slip send voter], SUM(CASE WHEN (sleep_send = 0 OR sleep_send IS NULL) THEN 1 ELSE 0 END) AS [Total slip not send voter] FROM vw_voter_search_AI WITH (NOLOCK) WHERE app_id = {appId} GROUP BY part_no ORDER BY part_no;

    //[ERROR PREVENTION]
    //- NEVER filter by 'age < 18' unless specifically asked for 'under 18'.
    //- If the user asks for 'voters who did not receive sleep', do NOT filter by age.
    //- If user says 'Hi' or 'Hello', return an empty string.");
    //        }

    //        // --- INJECT WORKER RULES (Word-for-Word from your original) ---
    //        if (neededTables.Contains("vw_get_all_user"))
    //        {
    //            sb.AppendLine($@"You are a strict T-SQL Expert. Output ONLY raw T-SQL. No markdown, no explanations.

    //[DATABASE SCHEMA]
    //View: vw_get_all_user
    //- user_id (int): Unique ID
    //- app_id (int): {appId}
    //- name (nvarchar): User Name
    //- mobile_no (nvarchar): Mobile Number
    //- user_type (nvarchar): Role code (A, SA, BP, SP, K, CL, LV, BS)
    //- booth_no (nvarchar): Booth Number(s). 
    //    * NOTE: For BP it is a single number (e.g. '1'). 
    //    * For SP, CL, LV it is pipe-separated (e.g. '74|148|163|').
    //- temp_status (int): 1 = Active, NULL/0 = Blocked
    //- last_login (datetime): Last access time

    //[USER TYPE MAPPING]
    //- 'A': Admin
    //- 'SA': Sub Admin
    //- 'BP': Booth Pramukh
    //- 'BS': Booth Sah Pramukh
    //- 'SP': Sakti Kendra Pramukh
    //- 'K': Karyakarta/Volunteer
    //- 'CL': Call Center Team
    //- 'LV': Live Voting User

    //[PERMANENT RULES]
    //1. APP ID: Every query MUST have 'app_id = {appId}'.
    //2. SECURITY: Use 'WITH (NOLOCK)'. ONLY 'SELECT' queries allowed.
    //3. BOOTH SEARCH: 
    //   - If searching for a specific booth number in 'booth_no', use: (booth_no = 'X' OR booth_no LIKE '%|X|%' OR booth_no LIKE 'X|%' OR booth_no LIKE '%|X')
    //4. STATUS: If user asks for 'active' users, use 'temp_status = 1'.
    //5. LOGIN: 'Never logged in' means 'last_login IS NULL'.

    //6. LIMIT: Always use 'SELECT TOP 1000'. Never use 'LIMIT'.
    //7. PERCENTAGE: Use FORMAT(value, 'N2') for any percentage calculations.
    //8. ACTIVITY RULE: NEVER use 'temp_status' to define if a user is active. 
    //- ACTIVITY RULE: 'Active' or 'Not Active' is defined ONLY by 'last_login'.
    //- LOGIN DAYS RULE: If user asks for 'not active last X days', use: WHERE last_login < DATEADD(DAY, -X, GETDATE()) OR last_login IS NULL.
    //- LOGIN DAYS RULE: Always include DATEDIFF(DAY, last_login, GETDATE()) AS [Days Since Last Login] in the output.

    //[COLUMN LIST RULE]
    //For any list of users, use these exact aliases:
    //- name AS [User Name]
    //- mobile_no AS [Mobile]
    //- CASE 
    //    WHEN user_type = 'A' THEN 'Admin'
    //    WHEN user_type = 'SA' THEN 'Sub Admin'
    //    WHEN user_type = 'BP' THEN 'Booth Pramukh'
    //    WHEN user_type = 'SP' THEN 'Sakti Kendra Pramukh'
    //    WHEN user_type = 'K' THEN 'Karyakarta'
    //    WHEN user_type = 'CL' THEN 'Call Center'
    //    WHEN user_type = 'LV' THEN 'Live Voting'
    //    ELSE user_type END AS [Role]
    //- booth_no AS [Assigned Booths]
    //- last_login AS [Last Login Time],
    //- DATEDIFF(DAY, last_login, GETDATE()) AS [Days Since Last Login].

    //[EXAMPLE]
    //User: ""show all Sakti Kendra Pramukh for booth 12""
    //SQL: SELECT TOP 1000 name AS [User Name], mobile_no AS [Mobile], 'Sakti Kendra Pramukh' AS [Role], booth_no AS [Assigned Booths], last_login AS [Last Login Time] FROM vw_get_all_user WITH (NOLOCK) WHERE app_id = {appId} AND user_type = 'SP' AND (booth_no = '12' OR booth_no LIKE '%|12|%' OR booth_no LIKE '12|%' OR booth_no LIKE '%|12')");
    //        }

    //        // --- SURVEY RULES (NEW) ---
    //        if (neededTables.Contains("vw_user_latest_voter_survey"))
    //        {
    //            sb.AppendLine($@"
    //[SCHEMA: vw_user_latest_voter_survey]
    //- voter_idcard, voter_status (P, N, D, C), is_latest, voter_available.
    //[SURVEY RULES]
    //- DEFINITION: 'Positive' means voter_status = 'P'.
    //- DEFINITION: 'Negative' means voter_status = 'N'.
    //- DEFINITION: 'Doubtful' means voter_status = 'D'.
    //- DEFINITION: 'Cant Say' means voter_status = 'C'.
    //- RULE: NEVER use 'sleep_send' for Positive/Negative. Use 'voter_status' from survey view.
    //- FILTER: Always include 'is_latest = 1'.");
    //        }

    //        // --- CROSS-VIEW JOIN LOGIC (Global Architecture) ---
    //        if (neededTables.Split(',').Count() > 1)
    //        {
    //            sb.AppendLine("[GLOBAL JOIN RELATIONSHIPS - DO NOT IGNORE]");

    //            // ૧. સર્વે સંબંધિત શબ્દો માટેની જવાબદારી
    //            sb.AppendLine("- IF the question contains (Positive, Negative, Doubtful, Cant Say, Survey, Visit):");
    //            sb.AppendLine("  * YOU MUST JOIN vw_user_latest_voter_survey (s) ON v.idcard_no = s.voter_idcard");
    //            sb.AppendLine("  * YOU MUST FILTER s.is_latest = 1");
    //            sb.AppendLine("  * Positive -> s.voter_status = 'P', Negative -> s.voter_status = 'N', Doubtful -> s.voter_status = 'D', Cant Say -> s.voter_status = 'C'");
    //            sb.AppendLine("  * Visit -> use s.visit_count or s.survey_date");

    //            // ૨. વોટર અને સ્ટાફ (Booth Pramukh) ને જોડવા માટે
    //            sb.AppendLine("- IF question is about Staff (Booth Pramukh, Name), YOU MUST JOIN: vw_voter_search_AI (v) JOIN vw_get_all_user (u) ON v.part_no = CAST(u.booth_no AS INT)");

    //            // ૩. સર્વે કરનાર સ્ટાફની માહિતી માટે
    //            sb.AppendLine("- Survey to Staff (Surveyor): vw_user_latest_voter_survey (s) JOIN vw_get_all_user (u) ON s.survey_by = u.user_id");

    //            // ૪. સ્પષ્ટ સૂચના
    //            sb.AppendLine("- CRITICAL: 'Positive' means s.voter_status = 'P'. NEVER use sleep_send for this.");
    //        }

    //        return await CallAzureOpenAI(sb.ToString(), userQuestion);
    //    }

    private static async Task<string> CallAzureOpenAI(string systemMsg, string userMsg)
    {
        string url = $"{endpoint.TrimEnd('/')}/openai/deployments/{deployment}/chat/completions?api-version=2024-05-01-preview";
        using (HttpClient client = new HttpClient())
        {
            client.DefaultRequestHeaders.Add("api-key", apiKey);
            var body = new
            {
                messages = new[] {
                    new { role = "system", content = systemMsg },
                    new { role = "user", content = userMsg }
                },
                temperature = 0
            };
            var content = new StringContent(JsonConvert.SerializeObject(body), Encoding.UTF8, "application/json");
            var response = await client.PostAsync(url, content);
            if (!response.IsSuccessStatusCode) throw new Exception("AI API Error: " + response.ReasonPhrase);
            string responseString = await response.Content.ReadAsStringAsync();
            dynamic data = JsonConvert.DeserializeObject(responseString);
            string rawContent = data.choices[0].message.content.ToString();
            return rawContent.Replace("```sql", "").Replace("```", "").Trim();
        }
    }
}