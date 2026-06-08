using Newtonsoft.Json;
using System;
using System.Collections.Generic;
using System.Data;
using System.Data.SqlClient;
using System.Linq;
using System.Net.Http;
using System.Text;
using System.Threading.Tasks;
using System.Web;
using System.Web.UI;
using System.Web.UI.WebControls;

public partial class AI_Voters_AI_Self_Train : System.Web.UI.Page
{
    protected void Page_Load(object sender, EventArgs e)
    {

    }

    // કનેક્શન સ્ટ્રિંગ અને ગ્લોબલ વેરીએબલ્સ
    string sqlConn = System.Configuration.ConfigurationManager.ConnectionStrings["myConnectionString"].ConnectionString;
    int currentAppId = 1;

    protected void btnSearch_Click(object sender, EventArgs e)
    {
        // એસિંક્રોનસ પ્રોસેસિંગ શરૂ કરો
        Page.RegisterAsyncTask(new PageAsyncTask(ProcessZeroTrainingRequest));
    }

    private async Task ProcessZeroTrainingRequest()
    {
        try
        {
            string userQuestion = txtQuestion.Text.Trim();
            if (string.IsNullOrEmpty(userQuestion)) return;

            // --- STEP 1: ROUTER (ટેબલ પસંદગી) ---
            // તમારા ૧૦૦ ટેબલના નામનું લિસ્ટ અહીં મુકવું
            string allTables = "tbl_user, tbl_voting_record, tbl_log, tbl_booth, tbl_user_booth, tbl_app";
            string routerPrompt = $@"You are a SQL Router. Based on the question: '{userQuestion}', return ONLY a comma-separated list of needed table names from this list: {allTables}. Do not explain.";

            string selectedTables = await CallAzureOpenAI(routerPrompt, "Identify required tables.");
            selectedTables = selectedTables.Replace(" ", ""); // સ્પેસ દૂર કરો

            // --- STEP 2: DYNAMIC SAMPLING (લાઈવ ડેટા સેમ્પલિંગ) ---
            StringBuilder dataContext = new StringBuilder();
            foreach (string table in selectedTables.Split(','))
            {
                string tableName = table.Trim();
                if (string.IsNullOrEmpty(tableName)) continue;

                string sampleData = GetTableSampleAsJson(tableName);
                dataContext.AppendLine($"### Table: {tableName}\nData Sample (First 3 rows):\n{sampleData}\n");
            }

            // --- STEP 3: SMART SQL GENERATION (ડેટા જોઈને ક્વેરી બનાવવી) ---
            // --- STEP 3: SMART SQL GENERATION (વધુ સ્પષ્ટ સૂચનાઓ સાથે) ---
            string generatorPrompt = $@"You are a professional SQL Expert for an Election Management System.
Analyze the provided LIVE DATA SAMPLES and follow these CRITICAL MAPPINGS:

[ENTITY MAPPING]
1. 'Voter List', 'Voters', or 'Names of people in booth' ALWAYS refers to 'tbl_voting_record'.
2. 'Booth Pramukh', 'Sakti Kendra', 'Worker' refers to 'tbl_user'.
3. 'Booth Stats' refers to 'tbl_booth'.

[RELATIONSHIP RULES]
- To get Voters under a Booth Pramukh: 
  Find the 'booth_no' of the user in 'tbl_user', then JOIN with 'tbl_voting_record' ON 'tbl_user.booth_no = tbl_voting_record.part_no'.
- 'tbl_voting_record.part_no' IS the Booth Number.
- 'tbl_voting_record.slnoinpart' IS the Voter Serial Number.

[SQL SERVER DATA TYPE RULES]
1. BIT/BOOLEAN: SQL Server does not support 'true' or 'false'. 
   - Use 'status = 1' or 'status <> 0' for True/Active.
   - Use 'status = 0' for False/Deleted.
2. JOIN: Always match 'app_id' when joining tables to ensure data isolation.
3. GUJARATI: Use N prefix for Unicode strings.

[LIVE DATA SAMPLES]
{dataContext.ToString()}

[STRICT EXECUTION RULES]
1. DETECT ROLES: If the query mentions 'Booth Pramukh', filter 'user_type = 'BP''.
2. STATUS: Only use 'status <> 0' if the column 'status' exists in that specific table's sample.
3. UNIQUENESS: Use 'DISTINCT' if multiple joins create duplicate voter rows.
4. GUJARATI: Always use N prefix for names like N'Krupali'.
5. APP ISOLATION: Always include 'app_id = {currentAppId}'.

Return ONLY raw SQL string.";

            string finalSql = await CallAzureOpenAI(generatorPrompt, userQuestion);
            string cleanSql = finalSql.Replace("```sql", "").Replace("```", "").Trim();

            // ડેબગિંગ અને એક્ઝિક્યુશન
            lblSqlOutput.Text = cleanSql;
            ExecuteAndBind(cleanSql);
        }
        catch (Exception ex)
        {
            lblError.Text = "Error: " + ex.Message;
        }
    }

    // ડેટાબેઝમાંથી લાઈવ ૩ રો (Rows) ખેંચવાનું લોજિક
    private string GetTableSampleAsJson(string tableName)
    {
        try
        {
            using (SqlConnection conn = new SqlConnection(sqlConn))
            {
                // TOP 3 રેકોર્ડ્સ લેવાથી AI ને ડેટાનો પ્રકાર ખબર પડશે
                string sql = $"SELECT TOP 3 * FROM {tableName} WITH (NOLOCK)";
                SqlDataAdapter da = new SqlDataAdapter(sql, conn);
                DataTable dt = new DataTable();
                da.Fill(dt);
                return JsonConvert.SerializeObject(dt, Formatting.Indented);
            }
        }
        catch { return "Error fetching sample for " + tableName; }
    }

    private async Task<string> CallAzureOpenAI(string systemMsg, string userMsg)
    {
        string endpoint = System.Configuration.ConfigurationManager.AppSettings["AzureOpenAIEndpoint"];
        string apiKey = System.Configuration.ConfigurationManager.AppSettings["AzureOpenAIKey"];
        string deployment = System.Configuration.ConfigurationManager.AppSettings["AzureDeployment"];
        string url = $"{endpoint.TrimEnd('/')}/openai/deployments/{deployment}/chat/completions?api-version=2024-05-01-preview";

        using (HttpClient client = new HttpClient())
        {
            client.DefaultRequestHeaders.Add("api-key", apiKey);
            var payload = new
            {
                messages = new[] {
                    new { role = "system", content = systemMsg },
                    new { role = "user", content = userMsg }
                },
                temperature = 0, // ફરજિયાત 0 રાખવું જેથી AI અનુમાન ન કરે
                max_tokens = 800
            };

            var content = new StringContent(JsonConvert.SerializeObject(payload), Encoding.UTF8, "application/json");
            var response = await client.PostAsync(url, content);
            string result = await response.Content.ReadAsStringAsync();
            dynamic json = JsonConvert.DeserializeObject(result);
            return json.choices[0].message.content.ToString();
        }
    }

    private void ExecuteAndBind(string sql)
    {
        using (SqlConnection conn = new SqlConnection(sqlConn))
        {
            SqlDataAdapter da = new SqlDataAdapter(sql, conn);
            DataTable dt = new DataTable();
            da.Fill(dt);
            gvResults.DataSource = dt;
            gvResults.DataBind();
        }
    }
}