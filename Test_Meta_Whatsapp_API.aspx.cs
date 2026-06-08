using Newtonsoft.Json;
using System;
using System.Collections.Generic;
using System.Configuration;
using System.IO;
using System.Linq;
using System.Net;
using System.Text;
using System.Web;
using System.Web.UI;
using System.Web.UI.WebControls;
using System.Net.Http;
using System.Net.Http.Headers;

public partial class Test_Meta_Whatsapp_API : System.Web.UI.Page
{
    protected void Page_Load(object sender, EventArgs e)
    {
        if (Session["CaptchaCode"] != null &&
        txtCaptcha.Text.Trim().ToUpper() == Session["CaptchaCode"].ToString())
        {
            lblMessage.ForeColor = System.Drawing.Color.Green;
            lblMessage.Text = "Captcha Verified Successfully!";
        }
        else
        {
            lblMessage.ForeColor = System.Drawing.Color.Red;
            lblMessage.Text = "Invalid Captcha. Please try again.";
            imgCaptcha.ImageUrl = "CaptchaImage.aspx?" + DateTime.Now.Ticks;
        }
    }

    protected void btnSendMessage_Click(object sender, EventArgs e)
    {
        //SendWhatsAppMessage();

        SendBulkWhatsApp();

    }




    public void SendBulkWhatsApp()
    {
        var contacts = new List<(string Mobile, string Name)>
    {
        ("919558001712", "Hardik Vaghasiya"),
        ("919909345328", "Mr. Hardik Patel"),
        ("917990524896", "Priya Savaliya")
    };

        foreach (var c in contacts)
        {
            try
            {
                string result = SendWhatsAppMessage(c.Mobile, c.Name);

                // Log success
                // Save to DB: mobile, status=sent, response=result
            }
            catch (Exception ex)
            {
                // Log failure
                // Save to DB: mobile, status=failed, error=ex.Message
            }

            // 🔴 IMPORTANT: Rate limit safety
            System.Threading.Thread.Sleep(2500); // 1 msg / second safe
        }
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


    public string SendTemplateWithImageHeader(
        string mobile,
        string imgUrl,
        string v1,
        string v2,
        string v3,
        string v4,
        string v5
    )
    {
        using (HttpClient client = new HttpClient())
        {
            var url = "https://crmapi.lifeweblink.com/api/meta/v19.0/942640248936966/messages";

            client.DefaultRequestHeaders.Clear();
            client.DefaultRequestHeaders.Authorization =
                new AuthenticationHeaderValue("Bearer", "o1AxaHT71HuhroksM27aenbaqhEn4MfwBp2NEFETe5itVvRcedL2RhmKX9F7nvND4RHkVuZ7rRVU5ERVJTQ09SRQIM9v9z1mPl1HCd7BUjqra0HKBAnow0y31q1y1zwCeqq6LI9U");

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
            ""name"": ""reminder2"",
            ""components"": [
                {
                    ""type"": ""header"",
                    ""parameters"": [
                        {
                            ""type"": ""image"",
                            ""image"": {
                                ""link"": """ + imgUrl + @"""
                            }
                        }
                    ]
                },
                {
                    ""type"": ""body"",
                    ""parameters"": [
                        { ""type"": ""text"", ""text"": """ + v1 + @""" },
                        { ""type"": ""text"", ""text"": """ + v2 + @""" },
                        { ""type"": ""text"", ""text"": """ + v3 + @""" },
                        { ""type"": ""text"", ""text"": """ + v4 + @""" },
                        { ""type"": ""text"", ""text"": """ + v5 + @""" }
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

    protected void btnSendImage_Click(object sender, EventArgs e)
    {
        string result = SendTemplateWithImageHeader(
     "917990524896",
     "https://apmcgondal.scmsolution.in//Admin//image/gallery/31012026094642_WhatsAppImage20260130at53127PM.jpeg",
     "Hardik",
     "Invoice #1023",
     "₹2,500",
     "Due 25 Jan",
     "Thank you"
 );

    }
}