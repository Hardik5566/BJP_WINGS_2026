using Newtonsoft.Json;
using System;
using System.Collections.Generic;
using System.Linq;
using System.Net.Http;
using System.Text;
using System.Web;
using System.Web.UI;
using System.Web.UI.WebControls;

public partial class Own_Data_Open_AI : System.Web.UI.Page
{
    protected void Page_Load(object sender, EventArgs e)
    {

    }

    protected void btnAsk_Click(object sender, EventArgs e)
    {
        string question = txtQuestion.Text.Trim();

        string endpoint = System.Configuration.ConfigurationManager.AppSettings["AzureOpenAIEndpoint"];
        string apiKey = System.Configuration.ConfigurationManager.AppSettings["AzureOpenAIKey"];
        string deployment = System.Configuration.ConfigurationManager.AppSettings["AzureDeployment"];

        string url = endpoint.TrimEnd('/') +
                     "/openai/deployments/" + deployment +
                     "/chat/completions?api-version=2024-05-01-preview";

        using (HttpClient client = new HttpClient())
        {
            client.DefaultRequestHeaders.Add("api-key", apiKey);

            var body = new
            {
                messages = new[]
                {
                new { role = "system", content = "You are an assistant for election data. " +
                    "Extract the intent and parameters from the user's question. Return JSON only." },
                new { role = "user", content = question }
            },
                max_tokens = 200
            };

            string json = JsonConvert.SerializeObject(body);
            var content = new StringContent(json, Encoding.UTF8, "application/json");

            HttpResponseMessage response = client.PostAsync(url, content).Result;
            string result = response.Content.ReadAsStringAsync().Result;

            dynamic data = JsonConvert.DeserializeObject(result);
            string aiReply = data.choices[0].message.content.ToString();

            lblResult.Text = "AI Response:<br/>" + aiReply;

            try
            {
                dynamic intentData = JsonConvert.DeserializeObject(aiReply);
                string intent = intentData.intent;

                // ✅ Example: call SP dynamically based on intent
                if (intent == "get_voter_count")
                {
                    int boothNo = intentData.parameters.booth_number;
                    //int count = GetVoterCountFromDB(boothNo);
                    int count = 100;
                    lblResult.Text += "<br/>Total Voters: " + count;
                }
            }
            catch
            {
                lblResult.Text += "<br/>Failed to parse JSON.";
            }
        }
    }
}