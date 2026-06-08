 <%@ WebHandler Language="C#" Class="VoterHandler" %>

using System;
using System.Web;
using System.IO;
using System.Web.Script.Serialization;
using System.Net.Http;
using System.Net.Http.Headers;
using System.Text;

public class VoterHandler : IHttpHandler
{
    public void ProcessRequest(HttpContext context)
    {
        context.Response.ContentType = "application/json";
        var js = new JavaScriptSerializer();

        try
        {
            // 1. Read JSON from Request Body
            string json;
            using (var reader = new StreamReader(context.Request.InputStream))
            {
                json = reader.ReadToEnd();
            }

            var data = js.Deserialize<dynamic>(json);

            // Extracting variables sent from AJAX
            //string uid = data["uid"].ToString();
            //string CmpId = data["CmpId"].ToString();
            //string AppID = data["AppID"].ToString();
            string id = data["id"].ToString();
            string mobile = data["mobile"].ToString();
            string name = data["name"].ToString();
            string booth = data["booth"].ToString();
            string sr = data["sr"].ToString();
            string imgBase64 = data["img"].ToString().Replace("data:image/jpeg;base64,", "");

            // 2. Save Image locally (Scale 3 from JS makes this very clear)
            byte[] bytes = Convert.FromBase64String(imgBase64);
            //string fileName = "Sleep_" + id + ".jpg";
            string fileName = $"Card_{id}_{DateTime.Now:yyyyMMddHHmmssfff}.jpg";

            string folder = context.Server.MapPath("~/VoterCards/");
            if (!Directory.Exists(folder)) Directory.CreateDirectory(folder);

            string fullPath = Path.Combine(folder, fileName);
            File.WriteAllBytes(fullPath, bytes);

            // 3. Trigger WhatsApp API (Using your working logic)
            // Make sure the domain matches where you upload the files
            string publicUrl = "https://bulk.bjpwings.com/VoterCards/" + fileName;

            string sms_booth_no = "બૂથ: " + booth;
            string sms_kram = "ક્રમ: " + booth;
            string sms_voter_name = "નામ " + name;
            string apiResult = SendWhatsApp(mobile, publicUrl, "-", sms_booth_no, sms_kram, sms_voter_name, "Voter Slip");

            //----- Save Log
            //System.Data.DataSet ds = BAL_Bulk_Wtsp.ins_bulk_wtsp_log(AppID, uid, id, CmpId);

            context.Response.Write(js.Serialize(new
            {
                status = "Success",
                message = "Sent to " + name,
                apiResponse = apiResult
            }));
        }
        catch (Exception ex)
        {
            context.Response.StatusCode = 500;
            context.Response.Write(js.Serialize(new { status = "Error", message = ex.Message }));
        }
    }

    // YOUR WORKING METHOD INTEGRATED HERE
    public string SendWhatsApp(string mobile, string imgUrl, string v1, string v2, string v3, string v4, string v5)
    {
        using (HttpClient client = new HttpClient())
        {
            var url = "https://crmapi.lifeweblink.com/api/meta/v19.0/942640248936966/messages";
            client.DefaultRequestHeaders.Authorization = new AuthenticationHeaderValue("Bearer", "o1AxaHT71HuhroksM27aenbaqhEn4MfwBp2NEFETe5itVvRcedL2RhmKX9F7nvND4RHkVuZ7rRVU5ERVJTQ09SRQIM9v9z1mPl1HCd7BUjqra0HKBAnow0y31q1y1zwCeqq6LI9U");

            string json = $@"{{
                ""messaging_product"": ""whatsapp"",
                ""recipient_type"": ""individual"",
                ""to"": ""{mobile}"",
                ""type"": ""template"",
                ""template"": {{
                    ""language"": {{ ""policy"": ""deterministic"", ""code"": ""en"" }},
                    ""name"": ""reminder2"",
                    ""components"": [
                        {{
                            ""type"": ""header"",
                            ""parameters"": [ {{ ""type"": ""image"", ""image"": {{ ""link"": ""{imgUrl}"" }} }} ]
                        }},
                        {{
                            ""type"": ""body"",
                            ""parameters"": [
                                {{ ""type"": ""text"", ""text"": ""{v1}"" }},
                                {{ ""type"": ""text"", ""text"": ""{v2}"" }},
                                {{ ""type"": ""text"", ""text"": ""{v3}"" }},
                                {{ ""type"": ""text"", ""text"": ""{v4}"" }},
                                {{ ""type"": ""text"", ""text"": ""{v5}"" }}
                            ]
                        }}
                    ]
                }}
            }}";

            var content = new ByteArrayContent(Encoding.UTF8.GetBytes(json));
            content.Headers.ContentType = new MediaTypeHeaderValue("application/json");

            var response = client.PostAsync(url, content).Result;
            return response.Content.ReadAsStringAsync().Result;
        }
    }

    public bool IsReusable
    {
        get { return false; }
    }
}
