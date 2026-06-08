using Newtonsoft.Json;
using System;
using System.Collections.Generic;
using System.Linq;
using System.Net;
using System.Net.Http;
using System.Security.Cryptography;
using System.Text;
using System.Threading.Tasks;
using System.Web;
using System.Web.UI;
using System.Web.UI.WebControls;

public partial class Phonepay_Payment_Gateway_Test : System.Web.UI.Page
{
    protected void Page_Load(object sender, EventArgs e)
    {

    }


    protected void btnPay_Click(object sender, EventArgs e)
    {
        try
        {
            // 1. Setup Your Credentials
            string myClientId = "M23MHA5ANSJSD_2603121437";
            string myClientSecret = "NGQ4NmRmMWYtZGI3ZC00Mzc2LWIwZjItNzcyYzE0YjQ3YWQz";
            string merchantId = "M23MHA5ANSJSD";

            // 2. Get the Bearer Token
            string token = GetAuthToken(myClientId, myClientSecret);

            // 3. Prepare Payment Payload
            var payload = new
            {
                merchantId = merchantId,
                merchantTransactionId = "TXN" + DateTime.Now.Ticks,
                merchantUserId = "U12345",
                amount = 100, // ₹1.00
                redirectUrl = "https://yourdomain.com/callback",
                redirectMode = "POST",
                paymentInstrument = new { type = "PAY_PAGE" }
            };

            string jsonPayload = JsonConvert.SerializeObject(payload);

            // 4. Call the Checkout API
            string checkoutUrl = "https://api-preprod.phonepe.com/apis/pg-sandbox/checkout/v2/pay";

            using (WebClient client = new WebClient())
            {
                client.Headers[HttpRequestHeader.ContentType] = "application/json";
                client.Headers[HttpRequestHeader.Authorization] = "Bearer " + token;

                string response = client.UploadString(checkoutUrl, "POST", jsonPayload);
                var result = JsonConvert.DeserializeObject<dynamic>(response);

                if (result.success == true)
                {
                    // Redirect user to the payment page
                    Response.Redirect(result.data.instrumentResponse.redirectInfo.url.ToString());
                }
            }
        }
        catch (WebException webEx)
        {
            // Capture specific API error messages
            using (var reader = new System.IO.StreamReader(webEx.Response.GetResponseStream()))
            {
                lblStatus.Text = "API Error: " + reader.ReadToEnd();
            }
        }
    }

    private string GenerateSha256(string input)
    {
        using (SHA256 sha256Hash = SHA256.Create())
        {
            byte[] bytes = sha256Hash.ComputeHash(Encoding.UTF8.GetBytes(input));
            StringBuilder builder = new StringBuilder();
            for (int i = 0; i < bytes.Length; i++)
            {
                builder.Append(bytes[i].ToString("x2"));
            }
            return builder.ToString();
        }
    }

    private string GetAuthToken(string clientId, string clientSecret)
    {
        string authUrl = "https://api-preprod.phonepe.com/apis/pg-sandbox/v1/oauth/token";

        using (WebClient client = new WebClient())
        {
            client.Headers[HttpRequestHeader.ContentType] = "application/x-www-form-urlencoded";

            // Prepare parameters
            string postData = $"client_id={clientId}&client_secret={clientSecret}&grant_type=client_credentials&client_version=1";

            string response = client.UploadString(authUrl, "POST", postData);
            var jsonResponse = JsonConvert.DeserializeObject<dynamic>(response);

            return jsonResponse.access_token; // This is your Bearer token
        }
    }
}