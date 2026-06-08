using System;
using System.Collections.Generic;
using System.IO;
using System.Data;
using System.Net.Http.Headers;
using System.Net.Http;
using System.Text;

public partial class Bulk_Slip_send_bulk_slip : System.Web.UI.Page
{
    protected void Page_Load(object sender, EventArgs e)
    {

        //SendWhatsApp("919558001712", "https://maharashtra.bjpwings.com/VoterCards/Card_YKB7855299.jpg", "52", "1", "156", "Hardik Vaghasiya", "Patel");
        //// Use QueryString to track which voter we are on
        int index = 0;
        if (!string.IsNullOrEmpty(Request.QueryString["idx"]))
            int.TryParse(Request.QueryString["idx"], out index);

        if (!IsPostBack)
        {
            if (Request.QueryString["status"] != "finished")
                LoadVoter(index);
        }
        else if (!string.IsNullOrEmpty(Request.Form["hfImageData"]))
        {
            ProcessImageAndSendWhatsApp(index);
        }
    }

    private void LoadVoter(int index)
    {
        // Replace with your actual BAL parameters
        DataSet ds = BAL_Voter.dis_booth_wise_search("1", "1");

        if (ds.Tables.Count > 0 && ds.Tables[0].Rows.Count > index)
        {
            DataRow row = ds.Tables[0].Rows[index];
            lblAcNo.Text = "1";
            lblBooth.Text = row["part_no"].ToString();
            lblSrNo.Text = row["slnoinpart"].ToString();
            lblName.Text = row["eng_f_name"].ToString();
            lblFather.Text = row["eng_m_name"].ToString();
            lblID.Text = row["idcard_no"].ToString();
            lblLocation.Text = row["eng_localityid"].ToString();

            // Assuming mobile column exists. Important: Must have country code (e.g. 91)
            hfVoterMobile.Value ="919662715197";
        }
        else
        {
            Response.Redirect(Request.Url.AbsolutePath + "?status=finished");
        }
    }

    private void ProcessImageAndSendWhatsApp(int index)
    {
        try
        {
            // 1. SAVE IMAGE LOCALLY
            string base64 = Request.Form["hfImageData"].Replace("data:image/jpeg;base64,", "");
            byte[] bytes = Convert.FromBase64String(base64);

            string folder = "VoterCards";
            string path = Server.MapPath("~/" + folder + "/");
            if (!Directory.Exists(path)) Directory.CreateDirectory(path);

            string fileName = "Card_" + lblID.Text + ".jpg";
            File.WriteAllBytes(Path.Combine(path, fileName), bytes);

            // 2. CONSTRUCT PUBLIC URL (WhatsApp needs this)

            //string publicUrl = "https://maharashtra.bjpwings.com/" + ResolveUrl("~/" + folder + "/" + fileName);
            string publicUrl = "https://maharashtra.bjpwings.com/VoterCards/Card_YKB2121762.jpg";
            // 3. SEND VIA META API
            SendWhatsApp(hfVoterMobile.Value, publicUrl,lblAcNo.Text, lblBooth.Text, lblSrNo.Text, lblName.Text, lblFather.Text);

            // 4. GO TO NEXT VOTER
            Response.Redirect(Request.Url.AbsolutePath + "?idx=" + (index + 1));
        }
        catch (Exception ex) { Response.Write("Error: " + ex.Message); }
    }

   

    public string SendWhatsApp(
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
}