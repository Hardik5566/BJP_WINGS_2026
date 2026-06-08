using System;
using System.Collections.Generic;
using System.Net.Http;
using System.Text;
using System.Threading.Tasks;
using System.Web.UI;
using System.Web.UI.WebControls;
using Newtonsoft.Json;

public partial class PublicAI : System.Web.UI.Page
{
    // Configuration from Web.config
    private string endpoint = System.Configuration.ConfigurationManager.AppSettings["AzureOpenAIEndpoint"];
    private string apiKey = System.Configuration.ConfigurationManager.AppSettings["AzureOpenAIKey"];
    private string deployment = System.Configuration.ConfigurationManager.AppSettings["AzureDeployment"];

    protected void btnAsk_Click(object sender, EventArgs e)
    {
        string userQuestion = txtInput.Text.Trim();
        if (string.IsNullOrEmpty(userQuestion)) return;

        // Display user message immediately
        AddMessageToUI("User", userQuestion, "user-msg");

        // Call AI Asynchronously
        Page.RegisterAsyncTask(new PageAsyncTask(() => GetAIResponse(userQuestion)));
        txtInput.Text = "";
    }

    private async Task GetAIResponse(string question)
    {
        try
        {
            string url = $"{endpoint.TrimEnd('/')}/openai/deployments/{deployment}/chat/completions?api-version=2024-02-01";

            using (HttpClient client = new HttpClient())
            {
                client.DefaultRequestHeaders.Add("api-key", apiKey);

                var requestBody = new
                {
                    messages = new[]
                    {
                        new { role = "system", content = "You are a helpful assistant for public inquiries. Provide clear, accurate, and safe answers." },
                        new { role = "user", content = question }
                    },
                    max_tokens = 800,
                    temperature = 0.7
                };

                var content = new StringContent(JsonConvert.SerializeObject(requestBody), Encoding.UTF8, "application/json");
                var response = await client.PostAsync(url, content);

                if (response.IsSuccessStatusCode)
                {
                    string jsonResponse = await response.Content.ReadAsStringAsync();
                    dynamic result = JsonConvert.DeserializeObject(jsonResponse);
                    string aiText = result.choices[0].message.content;

                    AddMessageToUI("AI", aiText, "ai-msg");
                }
                else
                {
                    AddMessageToUI("System", "Error connecting to AI service.", "ai-msg text-danger");
                }
            }
        }
        catch (Exception ex)
        {
            AddMessageToUI("System", "Error: " + ex.Message, "ai-msg text-danger");
        }
    }

    private void AddMessageToUI(string sender, string message, string cssClass)
    {
        Panel pnl = new Panel();
        pnl.CssClass = "message " + cssClass;
        pnl.Controls.Add(new LiteralControl($"<strong>{sender}:</strong><br/>{message.Replace("\n", "<br/>")}"));
        phChat.Controls.Add(pnl);
    }
}