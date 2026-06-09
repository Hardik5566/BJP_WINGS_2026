using System;
using System.Collections.Generic;
using System.Data;
using System.Data.SqlClient;
using System.Globalization;
using System.Text;
using System.Web;
using System.Web.Script.Serialization;
using System.Web.UI;
using System.Web.UI.WebControls;

public partial class BulkPrachar : Page
{
    public const string WhatsAppNumber = "919998092970";

    protected List<PracharServiceItem> ServiceItems { get; private set; }
    protected string RateDataJson { get; private set; }
    protected string AppId { get; private set; }
    protected string TotalMobileDisplay { get; private set; }
    protected string TotalVotersDisplay { get; private set; }

    protected void Page_Load(object sender, EventArgs e)
    {
        AppId = Request.QueryString["app_id"] ?? "1";
        LoadPageData(AppId);

        if (!IsPostBack)
        {
            rptServices.DataSource = ServiceItems;
            rptServices.DataBind();
        }
    }

    private void LoadPageData(string appId)
    {
        string vidhansabhaLabel = "Vidhansabha Name";
        TotalVotersDisplay = "—";
        TotalMobileDisplay = "—";
        int voterCountRaw = 0;
        int mobileCountRaw = 0;

        try
        {
            DataSet appDs = BAL_App_Setting.sel_by_app_id(appId);
            if (appDs != null && appDs.Tables.Count > 0 && appDs.Tables[0].Rows.Count > 0)
            {
                DataRow appRow = appDs.Tables[0].Rows[0];
                string vNo = appRow["vidhansabha_no"].ToString().Trim();
                string vName = appRow["vidhansabha_name"].ToString().Trim();
                vidhansabhaLabel = string.IsNullOrWhiteSpace(vNo)
                    ? vName
                    : vNo + " - " + vName;

                int.TryParse(appRow["total_voter"].ToString(), out voterCountRaw);
            }
        }
        catch
        {
            // App info unavailable — continue with voter/mobile DB counts.
        }

        try
        {
            if (voterCountRaw <= 0)
                voterCountRaw = GetVoterCount(appId);

            mobileCountRaw = GetMobileCount(appId);

            if (voterCountRaw > 0)
                TotalVotersDisplay = voterCountRaw.ToString("N0", CultureInfo.InvariantCulture);

            if (mobileCountRaw > 0)
                TotalMobileDisplay = mobileCountRaw.ToString("N0", CultureInfo.InvariantCulture);
        }
        catch
        {
            // Keep display defaults if count queries fail.
        }

        ServiceItems = BuildServiceItems();
        var rateMap = BuildRateMap(vidhansabhaLabel, TotalVotersDisplay, TotalMobileDisplay, voterCountRaw, mobileCountRaw, ServiceItems);
        RateDataJson = new JavaScriptSerializer().Serialize(rateMap);
    }

    private static int GetVoterCount(string appId)
    {
        SqlCommand cmd = new SqlCommand();
        cmd.CommandText = @"
SELECT COUNT(*)
FROM tbl_voting_record WITH (NOLOCK)
WHERE app_id = @app_id";

        parameter param = new parameter();
        cmd.Parameters.Add(param.intparam("@app_id", appId));

        DataSet ds = command.ExtQueryDS(cmd);
        if (ds == null || ds.Tables.Count == 0 || ds.Tables[0].Rows.Count == 0)
            return 0;

        int count;
        return int.TryParse(ds.Tables[0].Rows[0][0].ToString(), out count) ? count : 0;
    }

    private static int GetMobileCount(string appId)
    {
        SqlCommand cmd = new SqlCommand();
        cmd.CommandText = @"
SELECT COUNT(*)
FROM tbl_voting_record WITH (NOLOCK)
WHERE app_id = @app_id
  AND contact_no IS NOT NULL
  AND LEN(LTRIM(RTRIM(contact_no))) >= 10
  AND LTRIM(RTRIM(contact_no)) NOT IN ('0', '00', '0000000000', 'NA', 'N/A', '-', 'NULL')";

        parameter param = new parameter();
        cmd.Parameters.Add(param.intparam("@app_id", appId));

        DataSet ds = command.ExtQueryDS(cmd);
        if (ds == null || ds.Tables.Count == 0 || ds.Tables[0].Rows.Count == 0)
            return 0;

        int count;
        if (!int.TryParse(ds.Tables[0].Rows[0][0].ToString(), out count) || count <= 0)
        {
            // Fallback: count any non-empty contact_no
            SqlCommand fallbackCmd = new SqlCommand();
            fallbackCmd.CommandText = @"
SELECT COUNT(*)
FROM tbl_voting_record WITH (NOLOCK)
WHERE app_id = @app_id
  AND contact_no IS NOT NULL
  AND LTRIM(RTRIM(contact_no)) <> ''";

            parameter fallbackParam = new parameter();
            fallbackCmd.Parameters.Add(fallbackParam.intparam("@app_id", appId));

            DataSet fallbackDs = command.ExtQueryDS(fallbackCmd);
            if (fallbackDs == null || fallbackDs.Tables.Count == 0 || fallbackDs.Tables[0].Rows.Count == 0)
                return 0;

            int.TryParse(fallbackDs.Tables[0].Rows[0][0].ToString(), out count);
        }

        return count;
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

    /// <summary>
    /// Type-wise unit cost — ahiya badlo: kok 0.50, kok 1.00, aevi rite.
    /// </summary>
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
        int voterCountRaw,
        int mobileCountRaw,
        List<PracharServiceItem> serviceItems)
    {
        var map = new Dictionary<string, PracharRateCardDto>(StringComparer.OrdinalIgnoreCase);
        var configs = GetRateConfigs();
        var serviceByKey = new Dictionary<string, PracharServiceItem>(StringComparer.OrdinalIgnoreCase);
        if (serviceItems != null)
        {
            foreach (PracharServiceItem item in serviceItems)
                serviceByKey[item.RateKey] = item;
        }

        foreach (var entry in configs)
        {
            string rateKey = entry.Key;
            PracharRateConfig cfg = entry.Value;
            string unitCostText = FormatUnitCost(cfg);
            string totalCost = CalculateTotalCost(cfg, voterCountRaw, mobileCountRaw);
            string waText = BuildWaText(rateKey, cfg, vidhansabhaLabel, totalVotersDisplay, totalMobileDisplay, unitCostText, totalCost);

            PracharServiceItem svc;
            serviceByKey.TryGetValue(rateKey, out svc);

            map[rateKey] = new PracharRateCardDto
            {
                vidhansabhaIdName = vidhansabhaLabel,
                totalVoters = totalVotersDisplay,
                totalMobileNos = totalMobileDisplay,
                unitCostLabel = cfg.Label,
                unitCostValue = unitCostText,
                totalCost = totalCost,
                status = "Contact to Start Campaign",
                waText = waText,
                description = svc != null ? svc.Description : "",
                videoTitle = svc != null ? svc.VideoTitle : "",
                videoSubtitle = svc != null ? svc.VideoSubtitle : ""
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

    private static string BuildWaText(
        string rateKey,
        PracharRateConfig cfg,
        string vidhansabhaLabel,
        string totalVoters,
        string totalMobileNos,
        string unitCostText,
        string totalCost)
    {
        string serviceName = GetServiceNameForWa(rateKey);
        return string.Format(
            CultureInfo.InvariantCulture,
            "Hello BJP WINGS,%0AI want {0}.%0AVidhansabha: {1}%0ATotal Voter: {2}%0ATotal Mobile No: {3}%0AUnit Cost: {4}%0AEstimated Total: {5}",
            serviceName, vidhansabhaLabel, totalVoters, totalMobileNos, unitCostText, totalCost);
    }

    private static string GetServiceNameForWa(string rateKey)
    {
        switch (rateKey.ToLowerInvariant())
        {
            case "sleep": return "Bulk Slip Prachar (Sleep Send)";
            case "slipprint": return "Bulk Slip Print";
            case "photo": return "Bulk Photo Prachar";
            case "video": return "Bulk Video Prachar";
            case "call": return "Bulk Call Prachar";
            case "roadholding": return "Road Holding Prachar";
            case "socialmedia": return "Social Media Prachar";
            case "vehiclebanner": return "Vehicle Banner Prachar";
            case "pamphlet": return "Pamphlet Distribution";
            default: return "Bulk Prachar";
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
    public string waText { get; set; }
    public string description { get; set; }
    public string videoTitle { get; set; }
    public string videoSubtitle { get; set; }
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
