using System;
using System.Collections.Generic;
using System.Data.SqlClient;
using System.Data;
using System.Linq;
using System.Threading.Tasks;
using System.Web;
using System.Web.UI;
using System.Web.UI.WebControls;
using Newtonsoft.Json;
using System.Net.Http;
using System.Text;
using WebGrease.Activities;
using System.Text.RegularExpressions;

public partial class AI_Voter_Record_AI : System.Web.UI.Page
{
    string sqlConn = System.Configuration.ConfigurationManager.ConnectionStrings["myConnectionString"].ConnectionString;
    int currentAppId = 1;

    public class ChatBubble
    {
        public string UserQuestion { get; set; }
        public string FriendlyAnswer { get; set; }
        public string GeneratedSQL { get; set; }
        public DataTable Data { get; set; }
    }

    private List<ChatBubble> Conversation
    {
        get { return Session["Conversation"] as List<ChatBubble> ?? new List<ChatBubble>(); }
        set { Session["Conversation"] = value; }
    }

    protected void Page_Load(object sender, EventArgs e)
    {
        if (!IsPostBack && Session["Conversation"] == null)
        {
            Conversation = new List<ChatBubble>();
        }
    }

    protected void btnAsk_Click(object sender, EventArgs e)
    {
        Page.RegisterAsyncTask(new PageAsyncTask(ProcessVoterAI));
    }

    private async Task ProcessVoterAI()
    {
        string question = txtQuestion.Text.Trim();
        if (string.IsNullOrEmpty(question)) return;

        // ૧૦૦% તમારા અસલી ૧૩ નિયમો
        string systemPrompt = $@"You are a Master SQL Expert. Return ONLY JSON: {{ ""sql"": ""Query"", ""sentence"": ""Friendly response"" }}
        [TARGET]: vw_voter_search_AI
        [COLUMNS]: ac_no, part_no, slnoinpart, house_no, eng_house_no, localityid, eng_localityid, f_name, eng_f_name, f_surname, f_eng_surname, m_name, eng_m_name, surname, eng_surname, idcard_no, sex, age, contact_no, polling_location, eng_polling_location, family_id, app_id, sleep_send

        [MANDATORY RULES]:
        1. SEARCH (SINGLE): Search across f_name, f_surname, idcard_no, polling_location using OR logic.
        2. SEARCH (MULTI-WORD): Split words. Use AND logic across groups.
        3. BOOTH/SERIAL: Booth No is [part_no], Serial No is [slnoinpart].
        4. APP ISOLATION: Always filter by app_id = {currentAppId}.
        5. NO STATUS: [STRICT: NO status column exists]. NEVER use it.
        6. SLIPS: 'Received' (sleep_send = 1), 'Not received' (sleep_send = 0).
        7. FAMILY: Filter by [family_id] and ORDER BY slnoinpart.
        8. AGGREGATE: Use COUNT(*) for 'how many' or 'total'.
        9. SURNAME SPECIFIC: Use surname or f_surname.
        10. SYNTAX: Use TOP 1000 and ALWAYS place 'WITH (NOLOCK)' after the view name.
        11. LANGUAGE: Respond in the user's language (Gujarati/English).
        12. COUNT PLACEHOLDER: Use 'TOTAL_COUNT_HERE' in the sentence.
        13. POLLING LOCATION: Handle all location queries dynamically.

        Return ONLY raw SQL string inside JSON.";

        try
        {
            string aiResponse = await CallAzureOpenAI(systemPrompt, question);
            var result = JsonConvert.DeserializeObject<dynamic>(CleanJson(aiResponse));
            string sql = result.sql;
            string sentence = result.sentence.ToString();

            DataTable dt = GetDataTable(sql);

            // ૧. તપાસો કે આ COUNT ક્વેરી છે કે લિસ્ટ ક્વેરી?
            bool isSimpleCount = sql.ToUpper().Contains("COUNT(") && !sql.ToUpper().Contains("GROUP BY");

            if (isSimpleCount)
            {
                // સાદી COUNT ક્વેરીમાં અસલી આંકડો dt.Rows[0][0] માં હોય છે.
                string actualCount = (dt != null && dt.Rows.Count > 0) ? dt.Rows[0][0].ToString() : "0";
                sentence = sentence.Replace("TOTAL_COUNT_HERE", actualCount);

                // કાઉન્ટમાં ડેટા ટેબલ બતાવવાની જરૂર નથી એટલે Data = null
                Conversation.Add(new ChatBubble { UserQuestion = question, FriendlyAnswer = sentence, GeneratedSQL = sql, Data = null });
            }
            else
            {
                // લિસ્ટ અથવા GROUP BY ક્વેરીમાં dt.Rows.Count એટલે કેટલી લાઈનો આવી તે.
                sentence = sentence.Replace("TOTAL_COUNT_HERE", dt.Rows.Count.ToString());

                // અહીં ડેટા પાસ કરવો ફરજિયાત છે જેથી ગ્રીડમાં દેખાય
                Conversation.Add(new ChatBubble { UserQuestion = question, FriendlyAnswer = sentence, GeneratedSQL = sql, Data = dt });
            }
        }
        catch (Exception ex)
        {
            Conversation.Add(new ChatBubble { UserQuestion = question, FriendlyAnswer = "❌ Error: " + ex.Message, GeneratedSQL = "", Data = null });
        }

        // ૨. બાઈન્ડિંગ અને અપડેટ
        rptChat.DataSource = Conversation;
        rptChat.DataBind();
        upChat.Update();
        txtQuestion.Text = "";
    }

    protected void rptChat_ItemDataBound(object sender, RepeaterItemEventArgs e)
    {
        // ચેક કરો કે આ આઈટમ (Row) છે કે નહીં
        if (e.Item.ItemType == ListItemType.Item || e.Item.ItemType == ListItemType.AlternatingItem)
        {
            // અસલી ડેટા ઓબ્જેક્ટ મેળવો
            ChatBubble bubble = (ChatBubble)e.Item.DataItem;

            // ગ્રીડ અને પેનલ શોધો
            Panel pnlData = (Panel)e.Item.FindControl("pnlData");
            GridView gvData = (GridView)e.Item.FindControl("gvData");

            // જો ડેટા ટેબલ ખાલી ન હોય
            if (bubble.Data != null && bubble.Data.Rows.Count > 0)
            {
                pnlData.Visible = true; // પેનલ બતાવો
                gvData.DataSource = bubble.Data; // ડેટા અસાઇન કરો
                gvData.DataBind(); // ડેટા બાઈન્ડ કરો (આ લાઈન મહત્વની છે)
            }
            else
            {
                pnlData.Visible = false; // જો ડેટા ન હોય તો છુપાવો
            }
        }
    }

    private void BindChatRepeater()
    {
        rptChat.DataSource = Conversation;
        rptChat.DataBind();

        // UpdatePanel ને અપડેટ કરો જેથી નવો ડેટા દેખાય
        upChat.Update();
    }

    private DataTable GetDataTable(string sql)
    {
        DataTable dt = new DataTable();
        using (SqlConnection conn = new SqlConnection(sqlConn))
        {
            new SqlDataAdapter(sql, conn).Fill(dt);
        }
        return dt;
    }

    private string CleanJson(string input)
    {
        input = input.Trim();
        if (input.StartsWith("```json")) input = input.Substring(7);
        if (input.EndsWith("```")) input = input.Substring(0, input.Length - 3);
        return input.Trim();
    }

    private async Task<string> CallAzureOpenAI(string sys, string user)
    {
        string endpoint = System.Configuration.ConfigurationManager.AppSettings["AzureOpenAIEndpoint"];
        string apiKey = System.Configuration.ConfigurationManager.AppSettings["AzureOpenAIKey"];
        string deployment = System.Configuration.ConfigurationManager.AppSettings["AzureDeployment"];
        string url = $"{endpoint.TrimEnd('/')}/openai/deployments/{deployment}/chat/completions?api-version=2024-05-01-preview";
        using (HttpClient client = new HttpClient())
        {
            client.DefaultRequestHeaders.Add("api-key", apiKey);
            var body = new { messages = new[] { new { role = "system", content = sys }, new { role = "user", content = user } }, temperature = 0.1 };
            var response = await client.PostAsync(url, new StringContent(JsonConvert.SerializeObject(body), Encoding.UTF8, "application/json"));
            dynamic data = JsonConvert.DeserializeObject(await response.Content.ReadAsStringAsync());
            return data.choices[0].message.content.ToString();
        }
    }
}