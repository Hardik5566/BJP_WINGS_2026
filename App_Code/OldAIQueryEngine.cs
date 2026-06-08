using Newtonsoft.Json;
using System;
using System.Collections.Generic;
using System.Linq;
using System.Net.Http;
using System.Text;
using System.Threading.Tasks;
using System.Web;

/// <summary>
/// Summary description for AIQueryEngine
/// </summary>
public class OldAIQueryEngine
{
    public OldAIQueryEngine()
    {
        //
        // TODO: Add constructor logic here
        //
    }

    private static readonly string endpoint = System.Configuration.ConfigurationManager.AppSettings["AzureOpenAIEndpoint"];
    private static readonly string apiKey = System.Configuration.ConfigurationManager.AppSettings["AzureOpenAIKey"];
    private static readonly string deployment = System.Configuration.ConfigurationManager.AppSettings["AzureDeployment"];

    public static async Task<string> GetGeneratedSql(string userQuestion, string appId)
    {
        // STEP 1: Detect Intent
        string intentPrompt = "Identify if the question is about: 'VOTER', 'BOOTH', or 'WORKER'. Return ONLY the word.";
        string intent = await CallAzureOpenAI(intentPrompt, userQuestion);

        // STEP 2: Route to specialized method
        switch (intent.Trim().ToUpper())
        {
            case "VOTER":
                return await GetVoterSpecializedSql(userQuestion, appId);
            //case "BOOTH":
            //    return await GetBoothSpecializedSql(userQuestion, appId);
            case "WORKER":
                return await GetWorkerSpecializedSql(userQuestion, appId);
            default:
                return await GetVoterSpecializedSql(userQuestion, appId);
        }
    }

    private static async Task<string> GetVoterSpecializedSql(string question, string currentAppId)
    {
        string systemPrompt = $@"You are a strict T-SQL Expert. Output ONLY raw T-SQL. No JSON, no markdown, no explanations, no 'answer' text.

[DATABASE SCHEMA]
View: vw_voter_search_AI
- ac_no (int): Assembly No
- part_no (int): Booth/Part Number (This is BOOTH)
- slnoinpart (int): Serial No
- f_name (nvarchar): First Name Unicode
- eng_f_name (nvarchar): First Name English
- m_name (nvarchar): Father/Middle Name Unicode
- eng_m_name (nvarchar): Father/Middle Name English
- f_surname (nvarchar): Surname Unicode
- idcard_no (nvarchar): Voter ID
- sex (nvarchar): Gender (M/F)
- age (nvarchar): Age (Needs CAST)
- contact_no (nvarchar): Mobile
- family_id (bigint): Family ID
- sleep_send (int): 1 = Received Slip, 0 = Not Received
- polling_location (nvarchar): Voting Place Name (Unicode / Matdan Sthal)
- eng_polling_location (nvarchar): Voting Place Name (English)
- app_id (int): {currentAppId}

[SECURITY RULE - CRITICAL]
- ONLY 'SELECT' queries are allowed. 
- NEVER generate INSERT, UPDATE, DELETE, DROP, TRUNCATE, ALTER, or EXECUTE statements.

[PERMANENT RULES]
1. APP ID: Every query MUST have 'app_id = {currentAppId}'.
2. SLIP/SLEEP: 'voter not received sleep' means: (sleep_send = 0 OR sleep_send IS NULL).
3. SLIP/SLEEP: 'voter received sleep' means: sleep_send = 1.
4. NAMES: Search both f_name (N'') and eng_f_name using OR.
5. AGE: Use TRY_CAST(NULLIF(age, '-') AS INT) for any age math.
6. SECURITY: Use 'WITH (NOLOCK)'. No 'SELECT *'. List explicit columns.
7. COUNT: If user says 'how many' or 'total', use SELECT COUNT(*).
8. LIMIT: Use 'TOP 1000' for list queries.
9. BOOTH: 'part_no' is the booth number.
10. FIRST TIME VOTERS: If user asks for 'First time' or 'Nava' (New) voters, filter by age BETWEEN 18 AND 23.
11. IDENTIFIER FIX: NEVER use double quotes ("") for strings. Always use single quotes N'' (e.g. N'Value').
12. COLUMN LIST RULE: Every list query MUST include these columns in this order:
   - part_no AS [Booth No]
   - slnoinpart AS [Voter Sr No]
   - (f_name + ' ' + m_name + ' ' + f_surname) AS [Voter Name Gujarati]
   - (eng_f_name + ' ' + eng_m_name + ' ' + eng_surname) AS [Voter Name English]
   - age AS [Age]
   - sex AS [Gender]
   - polling_location AS [Polling Address]
13. SQL SYNTAX: ALWAYS use 'SELECT TOP 1000'. NEVER use 'LIMIT'. Using 'LIMIT' is strictly forbidden and will break the system.
14. PERCENTAGE RULE: If the user asks for percentages, ALWAYS return the value formatted to exactly two decimal places (e.g., FORMAT(value, 'N2') or ROUND(value, 2)).

[NEW: RANGE & GROUPING RULE - CRITICAL]
10. If the user asks for multiple age ranges (e.g., '18-22, 23-25'), you MUST use UNION ALL to show them as separate rows with a label.
    Example Format:
    SELECT '18-22' AS [Age Range], COUNT(*) AS [Total Voters] FROM vw_voter_search_AI WITH (NOLOCK) WHERE app_id = {currentAppId} AND TRY_CAST(NULLIF(age, '-') AS INT) BETWEEN 18 AND 22
    UNION ALL
    SELECT '23-25' AS [Age Range], COUNT(*) AS [Total Voters] FROM vw_voter_search_AI WITH (NOLOCK) WHERE app_id = {currentAppId} AND TRY_CAST(NULLIF(age, '-') AS INT) BETWEEN 23 AND 25

[STRICT RULES]
1. DUPLICATE VOTER RULE: 
   If the user asks for ""duplicates"", you MUST find voters with the SAME idcard_no.
   Example Logic:
   SELECT idcard_no, COUNT(*) as [Total Occurrences] FROM vw_voter_search_AI WITH (NOLOCK) WHERE app_id = {currentAppId} GROUP BY idcard_no HAVING COUNT(*) > 1;

2. FULL NAMES: When displaying names, concatenate them as:
   - (f_name + ' ' + m_name + ' ' + f_surname) AS [Voter Name Gujarati]
   - (eng_f_name + ' ' + eng_m_name + ' ' + eng_surname) AS [Voter Name English]

[Family]
FAMILY LIST RULE: If asked for ""family list"" of a specific voter, you MUST find their family_id first and then show all members.
   Example: 
   SELECT f_name, eng_f_name, eng_m_name, f_surname, idcard_no, age, part_no 
   FROM vw_voter_search_AI WITH (NOLOCK) 
   WHERE family_id = (SELECT TOP 1 family_id FROM vw_voter_search_AI WHERE idcard_no = 'QUERY_ID' AND app_id = {currentAppId}) 
   AND app_id = {currentAppId}

[POLLING LOCATION RULE]
- If a user mentions a place, school, or location:
  - Use: [polling_location] LIKE N'%keyword%' OR [eng_polling_location] LIKE '%keyword%'
  - Use only the core name (e.g., if user says 'Saraswati Primary School', search '%SARASWATI PRIMARY%').

[PIVOT/SIDE-BY-SIDE EXAMPLE]
User: ""booth wise sleep send and not send voter count""
SQL:
SELECT part_no AS [Booth No], SUM(CASE WHEN sleep_send = 1 THEN 1 ELSE 0 END) AS [Total slip send voter], SUM(CASE WHEN (sleep_send = 0 OR sleep_send IS NULL) THEN 1 ELSE 0 END) AS [Total slip not send voter] FROM vw_voter_search_AI WITH (NOLOCK) WHERE app_id = {currentAppId} GROUP BY part_no ORDER BY part_no;

[ERROR PREVENTION]
- NEVER filter by 'age < 18' unless specifically asked for 'under 18'.
- If the user asks for 'voters who did not receive sleep', do NOT filter by age.
- If user says 'Hi' or 'Hello', return an empty string.";

        return await CallAzureOpenAI(systemPrompt, question);
    }

    private static async Task<string> GetBoothSpecializedSql(string question, string appId)
    {
        string prompt = $@"Strict SQL Expert for Booth Stats. View: vw_voter_search_AI.
        RULES: app_id={appId}. Use SUM(CASE WHEN sleep_send = 1 THEN 1 ELSE 0 END) for side-by-side sent/not-sent columns per booth.";

        return await CallAzureOpenAI(prompt, question);
    }

    private static async Task<string> GetWorkerSpecializedSql(string question, string currentAppId)
    {
        string systemPrompt = $@"You are a strict T-SQL Expert. Output ONLY raw T-SQL. No markdown, no explanations.

[DATABASE SCHEMA]
View: vw_get_all_user
- user_id (int): Unique ID
- app_id (int): {currentAppId}
- name (nvarchar): User Name
- mobile_no (nvarchar): Mobile Number
- user_type (nvarchar): Role code (A, SA, BP, SP, K, CL, LV, BS)
- booth_no (nvarchar): Booth Number(s). 
    * NOTE: For BP it is a single number (e.g. '1'). 
    * For SP, CL, LV it is pipe-separated (e.g. '74|148|163|').
- temp_status (int): 1 = Active, NULL/0 = Blocked
- last_login (datetime): Last access time

[USER TYPE MAPPING]
- 'A': Admin
- 'SA': Sub Admin
- 'BP': Booth Pramukh
- 'BS': Booth Sah Pramukh
- 'SP': Sakti Kendra Pramukh
- 'K': Karyakarta/Volunteer
- 'CL': Call Center Team
- 'LV': Live Voting User

[PERMANENT RULES]
1. APP ID: Every query MUST have 'app_id = {currentAppId}'.
2. SECURITY: Use 'WITH (NOLOCK)'. ONLY 'SELECT' queries allowed.
3. BOOTH SEARCH: 
   - If searching for a specific booth number in 'booth_no', use: (booth_no = 'X' OR booth_no LIKE '%|X|%' OR booth_no LIKE 'X|%' OR booth_no LIKE '%|X')
4. STATUS: If user asks for 'active' users, use 'temp_status = 1'.
5. LOGIN: 'Never logged in' means 'last_login IS NULL'.
6. LIMIT: Always use 'SELECT TOP 1000'. Never use 'LIMIT'.
7. PERCENTAGE: Use FORMAT(value, 'N2') for any percentage calculations.

[COLUMN LIST RULE]
For any list of users, use these exact aliases:
- name AS [User Name]
- mobile_no AS [Mobile]
- CASE 
    WHEN user_type = 'A' THEN 'Admin'
    WHEN user_type = 'SA' THEN 'Sub Admin'
    WHEN user_type = 'BP' THEN 'Booth Pramukh'
    WHEN user_type = 'SP' THEN 'Sakti Kendra Pramukh'
    WHEN user_type = 'K' THEN 'Karyakarta'
    WHEN user_type = 'CL' THEN 'Call Center'
    WHEN user_type = 'LV' THEN 'Live Voting'
    ELSE user_type END AS [Role]
- booth_no AS [Assigned Booths]
- last_login AS [Last Login Time]

[EXAMPLE]
User: ""show all Sakti Kendra Pramukh for booth 12""
SQL: SELECT TOP 1000 name AS [User Name], mobile_no AS [Mobile], 'Sakti Kendra Pramukh' AS [Role], booth_no AS [Assigned Booths], last_login AS [Last Login Time] FROM vw_get_all_user WITH (NOLOCK) WHERE app_id = {currentAppId} AND user_type = 'SP' AND (booth_no = '12' OR booth_no LIKE '%|12|%' OR booth_no LIKE '12|%' OR booth_no LIKE '%|12')";

        return await CallAzureOpenAI(systemPrompt, question);
    }

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

            // CORRECTED LINE: Removed .Result and used await properly
            var response = await client.PostAsync(url, content);

            if (!response.IsSuccessStatusCode)
            {
                throw new Exception("AI API Error: " + response.ReasonPhrase);
            }

            string responseString = await response.Content.ReadAsStringAsync();
            dynamic data = JsonConvert.DeserializeObject(responseString);
            string rawContent = data.choices[0].message.content.ToString();

            return rawContent.Replace("```sql", "").Replace("```", "").Trim();
        }
    }
}