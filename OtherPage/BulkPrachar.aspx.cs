using Azure.Core;
using System;
using System.Collections.Generic;
using System.Data;
using System.Data.SqlClient;
using System.Globalization;
using System.Net.Http;
using System.Net.Http.Headers;
using System.Text;
using System.Threading.Tasks;
using System.Web;
using System.Web.Script.Serialization;
using System.Web.UI;
using System.Web.UI.WebControls;

public partial class BulkPrachar : Page
{
    public const string WhatsAppNumber = "919998092970";

    protected List<PracharServiceItem> ServiceItems { get; private set; }
    protected string RateDataJson { get; private set; }
    protected string TotalMobileDisplay { get; private set; }
    protected string TotalVotersDisplay { get; private set; }

    protected void Page_Load(object sender, EventArgs e)
    {
        string appId = Request.QueryString["app_id"] ?? "1";
        LoadPageData(appId);

        rptServices.DataSource = ServiceItems;
        rptServices.DataBind();
    }

    private void LoadPageData(string appId)
    {
        string vidhansabhaLabel = "Vidhansabha Name";
        TotalVotersDisplay = "—";
        TotalMobileDisplay = "—";
        string acNo = "0";

        try
        {
            DataSet appDs = BAL_Prachar.get_vidhansabha_and_total_voter(appId);
            if (appDs != null && appDs.Tables.Count > 0 && appDs.Tables[0].Rows.Count > 0)
            {
                DataRow appRow = appDs.Tables[0].Rows[0];
                string vNo = appRow["vidhansabha_no"].ToString().Trim();
                string vName = appRow["vidhansabha_name"].ToString().Trim();
                acNo = string.IsNullOrWhiteSpace(vNo) ? "0" : vNo;
                vidhansabhaLabel = string.IsNullOrWhiteSpace(vNo)
                    ? vName
                    : vNo + " - " + vName;

                TotalVotersDisplay = appRow["total_voter"].ToString().Trim();
                TotalMobileDisplay = appRow["total_number"].ToString().Trim();
            }
        }
        catch
        {
            // App info unavailable — continue with defaults.
        }

        ViewState["AcNo"] = acNo;
        ViewState["VoterCountRaw"] = TotalVotersDisplay;
        ViewState["MobileCountRaw"] = TotalMobileDisplay;

        // ✅ FIX: Parse display strings into int for cost calculation
        int.TryParse(TotalVotersDisplay.Replace(",", ""), out int vCount);
        int.TryParse(TotalMobileDisplay.Replace(",", ""), out int mCount);

        ServiceItems = BuildServiceItems();
        var rateMap = BuildRateMap(vidhansabhaLabel, TotalVotersDisplay, TotalMobileDisplay, vCount, mCount);
        RateDataJson = new JavaScriptSerializer().Serialize(rateMap);
    }


    private static List<PracharServiceItem> BuildServiceItems()
    {
        return new List<PracharServiceItem>
        {
            new PracharServiceItem
            {
                Title = "1. બલ્ક સ્લીપ પ્રચાર",
                RateKey = "sleep",
                VideoId = "dmqkwyXh8oE",
                Description = "તમારી વિધાનસભા માં આવતા દરેક મતદાર સુધી એમની સ્લીપ એક સાથે એમના વોટશેપ માં પહોચાડી શકીએ",
                VideoTitle = "બુલ્ક સ્લીપ પ્રચાર — Sample",
                VideoSubtitle = "બલ્ક સ્લીપ પ્રચાર ડેમો",
                IconSvg = "<svg viewBox=\"0 0 24 24\" xmlns=\"http://www.w3.org/2000/svg\"><path d=\"M14 2H6c-1.1 0-1.99.9-1.99 2L4 20c0 1.1.89 2 1.99 2H18c1.1 0 2-.9 2-2V8l-6-6zm2 16H8v-2h8v2zm0-4H8v-2h8v2zm-3-5V3.5L18.5 9H13z\"/></svg>"
            },
            new PracharServiceItem
            {
                Title = "2. બલ્ક સ્લીપ પ્રિન્ટ",
                RateKey = "slipprint",
                VideoId = "dmqkwyXh8oE",
                Description = "મતદાર સ્લીપની બલ્ક પ્રિન્ટ — તમારા વિસ્તાર મુજબ લિસ્ટ પરથી સ્લીપો પ્રિન્ટ કરી શકાય છે.",
                VideoTitle = "બલ્ક સ્લીપ પ્રિન્ટ — Sample",
                VideoSubtitle = "બલ્ક સ્લીપ પ્રિન્ટ ડેમો",
                IconSvg = "<svg viewBox=\"0 0 24 24\" xmlns=\"http://www.w3.org/2000/svg\"><path d=\"M19 8H5c-1.66 0-3 1.34-3 3v6h4v4h12v-4h4v-6c0-1.66-1.34-3-3-3zm-3 11H8v-5h8v5zm3-7c-.55 0-1-.45-1-1s.45-1 1-1 1 .45 1 1-.45 1-1 1zm-1-9H6v4h12V3z\"/></svg>"
            },
            new PracharServiceItem
            {
                Title = "3. બલ્ક ફોટો પ્રચાર",
                RateKey = "photo",
                VideoId = "dmqkwyXh8oE",
                Description = "તમારી વિધાનસભા માં આવતા દરેક મતદાર સુધી તમારા ફોટા/પોસ્ટર એક સાથે એમના વોટશેપ માં પહોચાડી શકીએ",
                VideoTitle = "બલ્ક ફોટો પ્રચાર — Sample",
                VideoSubtitle = "બલ્ક ફોટો પ્રચાર ડેમો",
                IconSvg = "<svg viewBox=\"0 0 24 24\" xmlns=\"http://www.w3.org/2000/svg\"><path d=\"M21 19V5c0-1.1-.9-2-2-2H5c-1.1 0-2 .9-2 2v14c0 1.1.9 2 2 2h14c1.1 0 2-.9 2-2zM8.5 13.5l2.5 3 3.5-4.5 4.5 6H5l3.5-4.5zM14.5 11a1.5 1.5 0 1 1 0-3 1.5 1.5 0 0 1 0 3z\"/></svg>"
            },
            new PracharServiceItem
            {
                Title = "4. બલ્ક વિડીયો પ્રચાર",
                RateKey = "video",
                VideoId = "dmqkwyXh8oE",
                Description = "તમારી વિધાનસભા માં આવતા દરેક મતદાર સુધી તમારો વિડીયો સંદેશ એક સાથે એમના વોટશેપ માં પહોચાડી શકીએ",
                VideoTitle = "બલ્ક વિડીયો પ્રચાર — Sample",
                VideoSubtitle = "બલ્ક વિડીયો પ્રચાર ડેમો",
                IconSvg = "<svg viewBox=\"0 0 24 24\" xmlns=\"http://www.w3.org/2000/svg\"><path d=\"M17 10.5V7c0-.55-.45-1-1-1H4c-.55 0-1 .45-1 1v10c0 .55.45 1 1 1h12c.55 0 1-.45 1-1v-3.5l4 4v-11l-4 4z\"/></svg>"
            },
            new PracharServiceItem
            {
                Title = "5. બલ્ક કોલ પ્રચાર",
                RateKey = "call",
                VideoId = "dmqkwyXh8oE",
                Description = "તમારી વિધાનસભા માં આવતા દરેક મતદાર સુધી એક સાથે કોલ દ્વારા તમારો સંદેશ પહોંચાડી શકીએ",
                VideoTitle = "બલ્ક કોલ પ્રચાર — Sample",
                VideoSubtitle = "બલ્ક કોલ પ્રચાર ડેમો",
                IconSvg = "<svg viewBox=\"0 0 24 24\" xmlns=\"http://www.w3.org/2000/svg\"><path d=\"M6.62 10.79c1.44 2.83 3.76 5.14 6.59 6.59l2.2-2.2c.27-.27.67-.36 1.02-.24 1.12.37 2.33.57 3.57.57.55 0 1 .45 1 1V20c0 .55-.45 1-1 1-9.39 0-17-7.61-17-17 0-.55.45-1 1-1h3.5c.55 0 1 .45 1 1 0 1.25.2 2.45.57 3.57.11.35.03.74-.25 1.02l-2.2 2.2z\"/></svg>"
            },
            new PracharServiceItem
            {
                Title = "6. રોડ હોલ્ડિંગ પ્રચાર",
                RateKey = "roadholding",
                VideoId = "dmqkwyXh8oE",
                Description = "રોડ હોલ્ડિંગ / બોર્ડ દ્વારા વિસ્તારમાં પ્રચાર.",
                VideoTitle = "રોડ હોલ્ડિંગ પ્રચાર — Sample",
                VideoSubtitle = "રોડ હોલ્ડિંગ પ્રચાર ડેમો",
                IconSvg = "<svg viewBox=\"0 0 24 24\" xmlns=\"http://www.w3.org/2000/svg\"><path d=\"M4 4h16v2H4V4zm0 4h10v10H4V8zm12 0h4v10h-4V8zM6 10h6v6H6v-6zm8 0h2v6h-2v-6z\"/></svg>"
            },
            new PracharServiceItem
            {
                Title = "7. સોસિયલ મીડિયા પ્રચાર",
                RateKey = "socialmedia",
                VideoId = "dmqkwyXh8oE",
                Description = "સોશિયલ મીડિયા પર ટાર્ગેટેડ પ્રચાર.",
                VideoTitle = "સોસિયલ મીડિયા પ્રચાર — Sample",
                VideoSubtitle = "સોસિયલ મીડિયા પ્રચાર ડેમો",
                IconSvg = "<svg viewBox=\"0 0 24 24\" xmlns=\"http://www.w3.org/2000/svg\"><path d=\"M18 16.08c-.76 0-1.44.3-1.96.77L8.91 12.7c.05-.23.09-.46.09-.7s-.04-.47-.09-.7l7.05-4.11c.54.5 1.25.81 2.04.81 1.66 0 3-1.34 3-3s-1.34-3-3-3-3 1.34-3 3c0 .24.04.47.09.7L8.04 9.81C7.5 9.31 6.79 9 6 9c-1.66 0-3 1.34-3 3s1.34 3 3 3c.79 0 1.5-.31 2.04-.81l7.12 4.16c-.05.21-.08.43-.08.65 0 1.61 1.31 2.92 2.92 2.92s2.92-1.31 2.92-2.92-1.31-2.92-2.92-2.92z\"/></svg>"
            },
            new PracharServiceItem
            {
                Title = "8. વાહન બેનર પ્રચાર",
                RateKey = "vehiclebanner",
                VideoId = "dmqkwyXh8oE",
                Description = "વાહન બેનર / રેલી દ્વારા પ્રચાર.",
                VideoTitle = "વાહન બેનર પ્રચાર — Sample",
                VideoSubtitle = "વાહન બેનર પ્રચાર ડેમો",
                IconSvg = "<svg viewBox=\"0 0 24 24\" xmlns=\"http://www.w3.org/2000/svg\"><path d=\"M18.92 6.01C18.72 5.42 18.16 5 17.5 5h-11c-.66 0-1.21.42-1.42 1.01L3 12v8c0 .55.45 1 1 1h1c.55 0 1-.45 1-1v-1h12v1c0 .55.45 1 1 1h1c.55 0 1-.45 1-1v-8l-2.08-5.99zM6.5 16c-.83 0-1.5-.67-1.5-1.5S5.67 13 6.5 13s1.5.67 1.5 1.5S7.33 16 6.5 16zm11 0c-.83 0-1.5-.67-1.5-1.5s.67-1.5 1.5-1.5 1.5.67 1.5 1.5-.67 1.5-1.5 1.5zM5 11l1.5-4.5h11L19 11H5z\"/></svg>"
            },
            new PracharServiceItem
            {
                Title = "9. પેમ્પલેટ વિતરણ",
                RateKey = "pamphlet",
                VideoId = "dmqkwyXh8oE",
                Description = "પેમ્ફલેટ / લીફલેટ વિતરણ પ્રચાર.",
                VideoTitle = "પેમ્ફલેટ વિતરણ — Sample",
                VideoSubtitle = "પેમ્પલેટ વિતરણ ડેમો",
                IconSvg = "<svg viewBox=\"0 0 24 24\" xmlns=\"http://www.w3.org/2000/svg\"><path d=\"M19 3H5c-1.1 0-2 .9-2 2v14c0 1.1.9 2 2 2h14c1.1 0 2-.9 2-2V5c0-1.1-.9-2-2-2zm-5 14H7v-2h7v2zm3-4H7v-2h10v2zm0-4H7V7h10v2z\"/></svg>"
            }
        };
    }

    private static Dictionary<string, PracharRateConfig> GetRateConfigs()
    {
        return new Dictionary<string, PracharRateConfig>(StringComparer.OrdinalIgnoreCase)
        {
            { "sleep",         new PracharRateConfig("Bulk Sleep Send Cost",         0.50m, RateBasis.Mobile, "Per Mobile") },
            { "slipprint",     new PracharRateConfig("Bulk Slip Print Cost",         1.00m, RateBasis.Voter,  "Per Voter") },
            { "photo",         new PracharRateConfig("Bulk Photo Send Cost",         1.00m, RateBasis.Mobile, "Per Mobile") },
            { "video",         new PracharRateConfig("Bulk Video Send Cost",         1.50m, RateBasis.Mobile, "Per Mobile") },
            { "call",          new PracharRateConfig("Bulk Call Cost",               2.00m, RateBasis.Mobile, "Per Mobile") },
            { "roadholding",   new PracharRateConfig("Road Holding Cost",            5.00m, RateBasis.Voter,  "Per Voter") },
            { "socialmedia",   new PracharRateConfig("Social Media Prachar Cost",    1.00m, RateBasis.Mobile, "Per Mobile") },
            { "vehiclebanner", new PracharRateConfig("Vehicle Banner Cost",          3.00m, RateBasis.Voter,  "Per Voter") },
            { "pamphlet",      new PracharRateConfig("Pamphlet Distribution Cost",   1.00m, RateBasis.Voter,  "Per Voter") }
        };
    }

    private static Dictionary<string, PracharRateCardDto> BuildRateMap(
        string vidhansabhaLabel,
        string totalVotersDisplay,
        string totalMobileDisplay,
        int voterCount,
        int mobileCount)
    {
        var map = new Dictionary<string, PracharRateCardDto>(StringComparer.OrdinalIgnoreCase);
        var configs = GetRateConfigs();

        foreach (var entry in configs)
        {
            string rateKey = entry.Key;
            PracharRateConfig cfg = entry.Value;
            string unitCostText = FormatUnitCost(cfg);
            string totalCost = CalculateTotalCost(cfg, voterCount, mobileCount);

            map[rateKey] = new PracharRateCardDto
            {
                vidhansabhaIdName = vidhansabhaLabel,
                totalVoters = totalVotersDisplay,
                totalMobileNos = totalMobileDisplay,
                unitCostLabel = cfg.Label,
                unitCostValue = unitCostText,
                totalCost = totalCost,
                status = "Contact to Start Campaign",
            };
        }

        return map;
    }

    private static string FormatUnitCost(PracharRateConfig cfg)
    {
        string amount = cfg.UnitCost.ToString("0.##", CultureInfo.InvariantCulture);
        return "₹ " + amount + " / " + cfg.UnitSuffix;
    }

    private static string CalculateTotalCost(PracharRateConfig cfg, int voterCount, int mobileCount)
    {
        int qty;
        switch (cfg.Basis)
        {
            case RateBasis.Mobile:
                qty = mobileCount;
                break;
            case RateBasis.Voter:
                qty = voterCount;
                break;
            default:
                qty = 0;
                break;
        }

        if (qty <= 0)
            return "—";

        decimal total = Math.Round(qty * cfg.UnitCost, 0);
        return "₹ " + total.ToString("N0", CultureInfo.InvariantCulture);
    }

    protected void btn_enquiry_Click(object sender, EventArgs e)
    {
        try
        {
            string pracharType = hfPracharType.Value;
            if (string.IsNullOrWhiteSpace(pracharType))
            {
                ShowEnquiryResult(false, "કૃપા કરીને પ્રચાર વિગત ખોલો અને પછી ઇન્ક્વાયરી મોકલો.");
                return;
            }

            string appId = Request.QueryString["app_id"] ?? "1";
            string createBy = Request.QueryString["create_by"] ?? Request.QueryString["uid"] ?? "0";
            string acNo = Convert.ToString(ViewState["AcNo"] ?? "0");

            // ✅ FIX: Parse from ViewState display strings
            int.TryParse(Convert.ToString(ViewState["VoterCountRaw"]).Replace(",", ""), out int voterCount);
            int.TryParse(Convert.ToString(ViewState["MobileCountRaw"]).Replace(",", ""), out int mobileCount);

            Dictionary<string, PracharRateConfig> configs = GetRateConfigs();
            PracharRateConfig cfg;
            if (!configs.TryGetValue(pracharType, out cfg))
            {
                ShowEnquiryResult(false, "અમાન્ય પ્રચાર પ્રકાર. કૃપા કરીને ફરી પ્રયાસ કરો.");
                return;
            }

            int qty = cfg.Basis == RateBasis.Mobile ? mobileCount : voterCount;
            long totalCost = (long)Math.Round(qty * cfg.UnitCost, 0);

         DataSet ds =   BAL_Prachar.ins_bulk_prachar_enquiry(
                pracharType,
                acNo,
                appId,
                voterCount.ToString(),
                mobileCount.ToString(),
                cfg.UnitCost.ToString(CultureInfo.InvariantCulture),
                totalCost.ToString(),
                "Pending",
                "Pending",
                createBy);

            if (ds != null && ds.Tables.Count > 0 && ds.Tables[0].Rows.Count > 0)
            {
                DataRow row = ds.Tables[0].Rows[0];
                try
                {
                   
                        SendWhatsAppMessage(
                            "919510418003",
                            Convert.ToString(row["vidhansabha_name"]),
                            Convert.ToString(row["enquiry_by"]),
                            Convert.ToString(row["mobile_no"]),
                            Convert.ToString(row["total_voter"]),
                            Convert.ToString(row["total_mobile_no"]),
                            Convert.ToString(row["enquiry_date"])
                        );
                   
                }
                catch
                {
                    // Enquiry is saved even if WhatsApp alert fails.
                }
            }

            ShowEnquiryResult(true);
        }
        catch (Exception ex)
        {
            ShowEnquiryResult(false, "Error: " + ex.Message);
        }
    }

    private void ShowEnquiryResult(bool success, string message = null)
    {
        var serializer = new JavaScriptSerializer();
        string mode = success ? "success" : "error";
        string defaultSuccess =
            "તમારી ઇન્ક્વાયરી સફળતાપૂર્વક મોકલાઈ ગઈ છે. અમારી ટીમ તમારી વિનંતીની સમીક્ષા કરશે અને ટૂંક સમયમાં તમારો સંપર્ક કરશે.";
        string text = success ? defaultSuccess : (message ?? "કંઈક ખોટું થયું. કૃપા કરીને ફરી પ્રયાસ કરો.");

        hfEnquiryResult.Value = serializer.Serialize(new Dictionary<string, string>
        {
            { "mode", mode },
            { "message", text }
        });
    }

    public string SendWhatsAppMessage(string mobile, string vidhansabha_name,string request_by,string mobile_no,string total_records,string total_mobile_no,string request_date)

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
        ""name"": ""bulk_prachar_request_from_bjp_wings"",
        ""language"": {
            ""code"": ""en""
        },
        ""components"": [
            {
                ""type"": ""body"",
                ""parameters"": [
                    { ""type"": ""text"", ""text"": ""Bulk Prachar"" },
                    { ""type"": ""text"", ""text"": """ + vidhansabha_name + @""" },
                    { ""type"": ""text"", ""text"": """ + request_by + @""" },
                    { ""type"": ""text"", ""text"": """ + mobile_no + @""" },
                    { ""type"": ""text"", ""text"": """ + total_records + @""" },
                    { ""type"": ""text"", ""text"": """ + total_mobile_no + @""" },
                    { ""type"": ""text"", ""text"": """ + request_date + @""" }
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

public class PracharRateCardDto
{
    public string vidhansabhaIdName { get; set; }
    public string totalVoters { get; set; }
    public string totalMobileNos { get; set; }
    public string unitCostLabel { get; set; }
    public string unitCostValue { get; set; }
    public string totalCost { get; set; }
    public string status { get; set; }
}

public enum RateBasis
{
    Mobile,
    Voter
}

public class PracharRateConfig
{
    public string Label { get; private set; }
    public decimal UnitCost { get; private set; }
    public RateBasis Basis { get; private set; }
    public string UnitSuffix { get; private set; }

    public PracharRateConfig(string label, decimal unitCost, RateBasis basis, string unitSuffix)
    {
        Label = label;
        UnitCost = unitCost;
        Basis = basis;
        UnitSuffix = unitSuffix;
    }
}

public class PracharServiceItem
{
    public string Title { get; set; }
    public string RateKey { get; set; }
    public string VideoId { get; set; }
    public string Description { get; set; }
    public string VideoTitle { get; set; }
    public string VideoSubtitle { get; set; }
    public string IconSvg { get; set; }
}
