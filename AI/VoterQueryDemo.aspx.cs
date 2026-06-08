using Newtonsoft.Json;
using System;
using System.Collections.Generic;
using System.Data;
using System.Data.SqlClient;
using System.Net.Http;
using System.Net;
using System.Text;
using System.Threading.Tasks;
using System.Web.UI;

public partial class AI_VoterQueryDemo : Page
{
    private readonly string sqlConn = System.Configuration.ConfigurationManager.ConnectionStrings["myConnectionString"].ConnectionString;

    protected void Page_Load(object sender, EventArgs e)
    {
    }

    protected void btnAsk_Click(object sender, EventArgs e)
    {
        lblError.Text = "";
        lblSummary.Text = "";
        litParsedJson.Text = "";
        litSql.Text = "";
        gvResults.DataSource = null;
        gvResults.DataBind();

        Page.RegisterAsyncTask(new PageAsyncTask(ProcessQuestion));
    }

    private async Task ProcessQuestion()
    {
        try
        {
            string question = (txtQuestion.Text ?? "").Trim();
            if (string.IsNullOrWhiteSpace(question))
            {
                lblError.Text = "Please enter a question.";
                return;
            }

            int appId;
            if (!int.TryParse((txtAppId.Text ?? "").Trim(), out appId) || appId <= 0)
            {
                lblError.Text = "Invalid App ID.";
                return;
            }

            // 1) Ask AI to only parse intent+parameters (no SQL).
            string parsedJson = await CallAzureOpenAI(ParseSystemPrompt(), question);
            litParsedJson.Text = Server.HtmlEncode(parsedJson);

            IntentRequest req;
            try
            {
                req = JsonConvert.DeserializeObject<IntentRequest>(parsedJson);
            }
            catch
            {
                lblError.Text = "AI JSON parse failed. Ensure AI returns valid JSON.";
                return;
            }

            if (req == null || string.IsNullOrWhiteSpace(req.intent))
            {
                lblError.Text = "No intent detected.";
                return;
            }

            // 2) Build safe SQL (parameterized) against tbl_voting_record only.
            var build = BuildSql(appId, req);
            litSql.Text = Server.HtmlEncode(build.SqlForDisplay);

            // 3) Execute and bind.
            ExecuteAndBind(build);
        }
        catch (Exception ex)
        {
            lblError.Text = "Error: " + Server.HtmlEncode(ex.Message);
        }
    }

    private static string ParseSystemPrompt()
    {
        // IMPORTANT:
        // - We only allow a small intent set (single table demo).
        // - We do not allow SQL output from AI.
        // - Gujarati/Hinglish/English all ok.
        return @"
You are an intent parser for an Election voter database.
Return ONLY strict JSON. No markdown. No explanation.

Database: SQL Server
Table: tbl_voting_record (single table demo)
Tenant isolation column: app_id (always required, but do NOT include it in JSON; server will inject app_id)

Column mapping for user language:
- 'name' / 'first name' / 'f_name' refers to f_name OR eng_f_name (search both)
- 'surname' refers to surname OR eng_surname (search both)
- 'booth' refers to part_no
- 'age' refers to age (stored as text; server will TRY_CONVERT(int, age))

Supported intents (choose one):
1) voter_list_by_name
   parameters: { ""name"": ""Hardik"", ""match"": ""contains|exact"" }
2) voter_list_by_name_and_surname
   parameters: { ""name"": ""Hardik"", ""surname"": ""Patel"", ""match"": ""contains|exact"" }
3) voter_list_by_age_between
   parameters: { ""age_min"": 20, ""age_max"": 25 }
4) voter_count_by_booth
   parameters: { ""booth_no"": 5 }
5) voter_count_by_age_groups
   parameters: { ""groups"": [ { ""min"": 20, ""max"": 30 }, { ""min"": 31, ""max"": 40 }, { ""min"": 41, ""max"": 50 } ] }
6) voter_list_young
   parameters: { ""age_max"": 25 }   // default 25 if not specified

Rules:
- If user asks for 'ketla' / 'count' / 'no of voters', choose a count intent.
- If user writes Gujarati like 'Hardik nam vala voter aapo', treat as name search contains.
- If user says 'Hardik Patel', treat as name+surname contains.
- Always output JSON like: { ""intent"": ""..."", ""parameters"": { ... } }
";
    }

    private SqlBuildResult BuildSql(int appId, IntentRequest req)
    {
        var res = new SqlBuildResult();
        res.Parameters = new List<SqlParameter>();

        // Always enforce tenant isolation
        res.Parameters.Add(new SqlParameter("@app_id", SqlDbType.Int) { Value = appId });

        string intent = (req.intent ?? "").Trim().ToLowerInvariant();
        var p = req.parameters ?? new Dictionary<string, object>();

        // NOTE: tbl_voting_record.part_no is booth number in your schema
        // NOTE: age is NVARCHAR, so use TRY_CONVERT(int, age)

        if (intent == "voter_list_by_name")
        {
            string name = GetString(p, "name");
            string match = GetString(p, "match");
            if (string.IsNullOrWhiteSpace(name)) throw new Exception("Missing parameter: name");

            bool exact = string.Equals(match, "exact", StringComparison.OrdinalIgnoreCase);
            string op = exact ? "=" : "LIKE";
            string val = exact ? name : "%" + name + "%";

            res.Sql =
@"SELECT TOP 200
    id, app_id, part_no, slnoinpart,
    f_name, eng_f_name, surname, eng_surname,
    idcard_no, sex, age, contact_no, polling_location, eng_polling_location
FROM tbl_voting_record WITH (NOLOCK)
WHERE app_id = @app_id
  AND (
        f_name " + op + @" @name
     OR eng_f_name " + op + @" @name
  )
ORDER BY part_no, slnoinpart;";

            res.Parameters.Add(new SqlParameter("@name", SqlDbType.NVarChar, 200) { Value = val });
            res.SqlForDisplay = res.Sql;
            res.SummaryText = "Voter list by name";
            return res;
        }

        if (intent == "voter_list_by_name_and_surname")
        {
            string name = GetString(p, "name");
            string surname = GetString(p, "surname");
            string match = GetString(p, "match");
            if (string.IsNullOrWhiteSpace(name)) throw new Exception("Missing parameter: name");
            if (string.IsNullOrWhiteSpace(surname)) throw new Exception("Missing parameter: surname");

            bool exact = string.Equals(match, "exact", StringComparison.OrdinalIgnoreCase);
            string op = exact ? "=" : "LIKE";
            string nameVal = exact ? name : "%" + name + "%";
            string surVal = exact ? surname : "%" + surname + "%";

            res.Sql =
@"SELECT TOP 200
    id, app_id, part_no, slnoinpart,
    f_name, eng_f_name, surname, eng_surname,
    idcard_no, sex, age, contact_no, polling_location, eng_polling_location
FROM tbl_voting_record WITH (NOLOCK)
WHERE app_id = @app_id
  AND (
        f_name " + op + @" @name
     OR eng_f_name " + op + @" @name
  )
  AND (
        surname " + op + @" @surname
     OR eng_surname " + op + @" @surname
  )
ORDER BY part_no, slnoinpart;";

            res.Parameters.Add(new SqlParameter("@name", SqlDbType.NVarChar, 200) { Value = nameVal });
            res.Parameters.Add(new SqlParameter("@surname", SqlDbType.NVarChar, 200) { Value = surVal });
            res.SqlForDisplay = res.Sql;
            res.SummaryText = "Voter list by name and surname";
            return res;
        }

        if (intent == "voter_list_by_age_between")
        {
            int ageMin = GetInt(p, "age_min");
            int ageMax = GetInt(p, "age_max");
            if (ageMin <= 0 || ageMax <= 0) throw new Exception("Invalid age range.");
            if (ageMax < ageMin) { int t = ageMin; ageMin = ageMax; ageMax = t; }

            res.Sql =
@"SELECT TOP 200
    id, app_id, part_no, slnoinpart,
    f_name, eng_f_name, surname, eng_surname,
    idcard_no, sex, age, contact_no, polling_location, eng_polling_location
FROM tbl_voting_record WITH (NOLOCK)
WHERE app_id = @app_id
  AND TRY_CONVERT(int, age) BETWEEN @age_min AND @age_max
ORDER BY TRY_CONVERT(int, age), part_no, slnoinpart;";

            res.Parameters.Add(new SqlParameter("@age_min", SqlDbType.Int) { Value = ageMin });
            res.Parameters.Add(new SqlParameter("@age_max", SqlDbType.Int) { Value = ageMax });
            res.SqlForDisplay = res.Sql;
            res.SummaryText = $"Voter list age between {ageMin} and {ageMax}";
            return res;
        }

        if (intent == "voter_count_by_booth")
        {
            int boothNo = GetInt(p, "booth_no");
            if (boothNo <= 0) throw new Exception("Invalid booth number.");

            res.Sql =
@"SELECT COUNT(1) AS voter_count
FROM tbl_voting_record WITH (NOLOCK)
WHERE app_id = @app_id
  AND part_no = @booth_no;";

            res.Parameters.Add(new SqlParameter("@booth_no", SqlDbType.Int) { Value = boothNo });
            res.SqlForDisplay = res.Sql;
            res.SummaryText = $"Voter count in booth {boothNo}";
            return res;
        }

        if (intent == "voter_count_by_age_groups")
        {
            // groups is an array; we keep it simple (only up to 6 groups)
            var groups = GetGroups(p);
            if (groups.Count == 0) throw new Exception("Missing parameter: groups");
            if (groups.Count > 6) throw new Exception("Too many groups (max 6).");

            var sbCase = new StringBuilder();
            sbCase.AppendLine("CASE");
            for (int i = 0; i < groups.Count; i++)
            {
                var g = groups[i];
                string label = $"{g.Min}-{g.Max}";
                sbCase.AppendLine($"    WHEN TRY_CONVERT(int, age) BETWEEN @g{i}_min AND @g{i}_max THEN '{label}'");
                res.Parameters.Add(new SqlParameter($"@g{i}_min", SqlDbType.Int) { Value = g.Min });
                res.Parameters.Add(new SqlParameter($"@g{i}_max", SqlDbType.Int) { Value = g.Max });
            }
            sbCase.AppendLine("    ELSE 'Other'");
            sbCase.Append("END");

            res.Sql =
$@"SELECT
    {sbCase.ToString()} AS age_group,
    COUNT(1) AS voter_count
FROM tbl_voting_record WITH (NOLOCK)
WHERE app_id = @app_id
GROUP BY {sbCase.ToString()}
ORDER BY age_group;";

            res.SqlForDisplay = res.Sql;
            res.SummaryText = "Voter count by age groups";
            return res;
        }

        if (intent == "voter_list_young")
        {
            int ageMax = 25;
            int parsed = TryGetInt(p, "age_max");
            if (parsed > 0) ageMax = parsed;

            res.Sql =
@"SELECT TOP 200
    id, app_id, part_no, slnoinpart,
    f_name, eng_f_name, surname, eng_surname,
    idcard_no, sex, age, contact_no, polling_location, eng_polling_location
FROM tbl_voting_record WITH (NOLOCK)
WHERE app_id = @app_id
  AND TRY_CONVERT(int, age) BETWEEN 18 AND @age_max
ORDER BY TRY_CONVERT(int, age), part_no, slnoinpart;";

            res.Parameters.Add(new SqlParameter("@age_max", SqlDbType.Int) { Value = ageMax });
            res.SqlForDisplay = res.Sql;
            res.SummaryText = $"Young voter list (18 to {ageMax})";
            return res;
        }

        throw new Exception("Unsupported intent: " + req.intent);
    }

    private void ExecuteAndBind(SqlBuildResult build)
    {
        using (SqlConnection conn = new SqlConnection(sqlConn))
        using (SqlCommand cmd = new SqlCommand(build.Sql, conn))
        {
            foreach (var prm in build.Parameters)
                cmd.Parameters.Add(prm);

            using (SqlDataAdapter da = new SqlDataAdapter(cmd))
            {
                DataTable dt = new DataTable();
                da.Fill(dt);
                gvResults.DataSource = dt;
                gvResults.DataBind();

                lblSummary.Text = build.SummaryText + " | Rows: " + dt.Rows.Count;
            }
        }
    }

    private async Task<string> CallAzureOpenAI(string systemMsg, string userMsg)
    {
        string endpoint = System.Configuration.ConfigurationManager.AppSettings["AzureOpenAIEndpoint"];
        string apiKey = System.Configuration.ConfigurationManager.AppSettings["AzureOpenAIKey"];
        string deployment = System.Configuration.ConfigurationManager.AppSettings["AzureDeployment"];
        string url = $"{endpoint.TrimEnd('/')}/openai/deployments/{deployment}/chat/completions?api-version=2024-05-01-preview";

        // Some Windows/.NET environments require TLS 1.2 explicitly for HTTPS calls.
        ServicePointManager.SecurityProtocol = SecurityProtocolType.Tls12;

        using (HttpClient client = new HttpClient())
        {
            client.Timeout = TimeSpan.FromSeconds(60);
            client.DefaultRequestHeaders.Add("api-key", apiKey);

            var payload = new
            {
                messages = new[] {
                    new { role = "system", content = systemMsg },
                    new { role = "user", content = userMsg }
                },
                temperature = 0,
                max_tokens = 400
            };

            var content = new StringContent(JsonConvert.SerializeObject(payload), Encoding.UTF8, "application/json");
            HttpResponseMessage response;
            string result = "";
            try
            {
                response = await client.PostAsync(url, content);
                result = await response.Content.ReadAsStringAsync();
            }
            catch (Exception ex)
            {
                // Bubble up inner exception details for debugging.
                throw new Exception("Azure OpenAI request failed: " + ex.ToString(), ex);
            }

            if (!response.IsSuccessStatusCode)
            {
                throw new Exception(
                    "Azure OpenAI HTTP " + (int)response.StatusCode + " (" + response.ReasonPhrase + ").\n" +
                    "URL: " + url + "\n" +
                    "Response: " + result
                );
            }

            try
            {
                dynamic json = JsonConvert.DeserializeObject(result);
                return json.choices[0].message.content.ToString().Trim();
            }
            catch (Exception ex)
            {
                throw new Exception("Failed to parse Azure OpenAI response JSON.\nResponse: " + result + "\n" + ex.Message);
            }
        }
    }

    private static string GetString(Dictionary<string, object> p, string key)
    {
        if (p == null || !p.ContainsKey(key) || p[key] == null) return "";
        return Convert.ToString(p[key]) ?? "";
    }

    private static int GetInt(Dictionary<string, object> p, string key)
    {
        int val = TryGetInt(p, key);
        if (val <= 0) throw new Exception("Missing/invalid parameter: " + key);
        return val;
    }

    private static int TryGetInt(Dictionary<string, object> p, string key)
    {
        if (p == null || !p.ContainsKey(key) || p[key] == null) return 0;

        try
        {
            if (p[key] is long) return (int)(long)p[key];
            if (p[key] is int) return (int)p[key];
            if (p[key] is double) return (int)(double)p[key];

            int parsed;
            if (int.TryParse(Convert.ToString(p[key]) ?? "", out parsed)) return parsed;
        }
        catch { }

        return 0;
    }

    private static List<AgeGroup> GetGroups(Dictionary<string, object> p)
    {
        var res = new List<AgeGroup>();
        if (p == null || !p.ContainsKey("groups") || p["groups"] == null) return res;

        try
        {
            // When deserialized into Dictionary<string, object>, arrays usually become JArray.
            var jarr = p["groups"] as Newtonsoft.Json.Linq.JArray;
            if (jarr == null) return res;

            foreach (var item in jarr)
            {
                // Avoid JToken.Value<int>() overload differences across Newtonsoft versions.
                int min = 0;
                int max = 0;

                var minTok = item["min"];
                var maxTok = item["max"];
                if (minTok != null) min = SafeTokenToInt(minTok);
                if (maxTok != null) max = SafeTokenToInt(maxTok);
                if (min > 0 && max > 0)
                {
                    if (max < min) { int t = min; min = max; max = t; }
                    res.Add(new AgeGroup { Min = min, Max = max });
                }
            }
        }
        catch
        {
            // ignore
        }

        return res;
    }

    private static int SafeTokenToInt(Newtonsoft.Json.Linq.JToken tok)
    {
        try
        {
            return tok.ToObject<int>();
        }
        catch
        {
            int parsed;
            if (int.TryParse(Convert.ToString(tok) ?? "", out parsed)) return parsed;
            return 0;
        }
    }

    private class AgeGroup
    {
        public int Min { get; set; }
        public int Max { get; set; }
    }

    private class SqlBuildResult
    {
        public string Sql { get; set; }
        public string SqlForDisplay { get; set; }
        public List<SqlParameter> Parameters { get; set; }
        public string SummaryText { get; set; }
    }

    private class IntentRequest
    {
        public string intent { get; set; }
        public Dictionary<string, object> parameters { get; set; }
    }
}

