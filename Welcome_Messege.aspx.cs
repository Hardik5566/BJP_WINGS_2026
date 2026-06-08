using System;
using System.Collections.Generic;
using System.Linq;
using System.Net.Http.Headers;
using System.Net.Http;
using System.Text;
using System.Web;
using System.Web.UI;
using System.Web.UI.WebControls;

public partial class Welcome_Messege : System.Web.UI.Page
{
    protected void Page_Load(object sender, EventArgs e)
    {
        SendWhatsAppMessage("919558001712", "Hardik Vaghasiya");
    }

    public string SendWhatsAppMessage(string mobile, string name)
    {
        using (HttpClient client = new HttpClient())
        {
            var url = "https://crmapi.lifeweblink.com/api/meta/v19.0/942640248936966/messages";

            client.DefaultRequestHeaders.Clear();
            client.DefaultRequestHeaders.Authorization =
                new AuthenticationHeaderValue(
                    "Bearer",
                    "o1AxaHT71HuhroksM27aenbaqhEn4MfwBp2NEFETe5itVvRcedL2RhmKX9F7nvND4RHkVuZ7rRVU5ERVJTQ09SRQIM9v9z1mPl1HCd7BUjqra0HKBAnow0y31q1y1zwCeqq6LI9U"
                );

            string json = @"{
            ""messaging_product"": ""whatsapp"",
            ""recipient_type"": ""individual"",
            ""to"": """ + mobile + @""",
            ""type"": ""template"",
            ""template"": {
                ""language"": {
                    ""policy"": ""deterministic"",
                    ""code"": ""en""
                },
                ""name"": ""info"",
                ""components"": [
                    {
                        ""type"": ""body"",
                        ""parameters"": [
                            {
                                ""type"": ""text"",
                                ""text"": """ + name + @"""
                            }
                        ]
                    }
                ]
            }
        }";

            var content = new ByteArrayContent(Encoding.UTF8.GetBytes(json));
            content.Headers.ContentType = new MediaTypeHeaderValue("application/json");

            var response = client.PostAsync(url, content).Result;
            return response.Content.ReadAsStringAsync().Result;
        }
    }
}