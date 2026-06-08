using System;
using System.Collections.Generic;
using System.Net.Http;
using System.Web;
using System.Web.UI;
using System.Web.UI.WebControls;
using System.Net.Http;
using Newtonsoft.Json;
using System.Text;

public partial class OpenAI : System.Web.UI.Page
{
    protected void Page_Load(object sender, EventArgs e)
    {

    }

    protected void btnAsk_Click(object sender, EventArgs e)
    {
        string question = txtQuestion.Text;

        string endpoint = System.Configuration.ConfigurationManager.AppSettings["AzureOpenAIEndpoint"];
        string apiKey = System.Configuration.ConfigurationManager.AppSettings["AzureOpenAIKey"];
        string deployment = System.Configuration.ConfigurationManager.AppSettings["AzureDeployment"];

        string url = endpoint +
            "openai/deployments/" + deployment +
            "/chat/completions?api-version=2024-02-15-preview";

        using (HttpClient client = new HttpClient())
        {
            client.DefaultRequestHeaders.Add("api-key", apiKey);

            var body = new
            {
                messages = new[]
                {
                    new { role = "system", content = "You are a helpful assistant." },
                    new { role = "user", content = question }
                },
                max_tokens = 200
            };

            string json = JsonConvert.SerializeObject(body);
            var content = new StringContent(json, Encoding.UTF8, "application/json");

            // 🔴 SYNC CALL
            HttpResponseMessage response = client.PostAsync(url, content).Result;
            string result = response.Content.ReadAsStringAsync().Result;

            dynamic data = JsonConvert.DeserializeObject(result);
            lblResult.Text = data.choices[0].message.content;
        }
    }
}