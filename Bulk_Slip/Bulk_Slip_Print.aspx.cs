using System;
using System.Collections.Generic;
using System.Data;
using System.Linq;
using System.Web.Script.Serialization;

public partial class Bulk_Slip_Bulk_Slip_Print : System.Web.UI.Page
{
    protected string BulkDataJson = "{}";
    protected string BoothDisplay = "1";
    protected string AppIdDisplay = "1";

    protected void Page_Load(object sender, EventArgs e)
    {
        string appId = Request.QueryString["app_id"] ?? "1";
        string boothNo = Request.QueryString["booth_no"] ?? "1";
        string userId = Request.QueryString["user_id"] ?? "1";

        AppIdDisplay = appId;
        BoothDisplay = boothNo;

        BulkDataJson = BuildBulkJson(appId, boothNo, userId);
    }

    private static string BuildBulkJson(string appId, string boothNo, string userId)
    {
        var js = new JavaScriptSerializer { MaxJsonLength = int.MaxValue };

        var result = new Dictionary<string, object>
        {
            ["boothNo"] = boothNo,
            ["appId"] = appId,
            ["userId"] = userId,
            ["voters"] = new List<object>(),
            ["candidates"] = new List<object>(),
            ["header"] = new Dictionary<string, string>()
        };

        try
        {
            DataSet ds = BAL_Voter.print_bulk_receipt_in_printer(appId, boothNo, userId);
            var header = (Dictionary<string, string>)result["header"];
            header["party"] = "";
            header["assembly"] = "";
            header["msg"] = "";
            header["thanks"] = "ધન્યવાદ";
            header["logo"] = "img/bjp_only_logo.png";

            string candidateCsv = "";

            if (ds.Tables.Count > 2 && ds.Tables[2].Rows.Count > 0)
            {
                DataRow h = ds.Tables[2].Rows[0];
                string vsNo = SafeStr(h, "vidhansabha_no");
                string vsName = SafeStr(h, "vidhansabha_name");
                header["party"] = SafeStr(h, "party_full_name");
                header["assembly"] = vsNo + " - " + vsName;
                candidateCsv = SafeStr(h, "candidate_name");
                string logo = SafeStr(h, "party_logo_png");
                if (!string.IsNullOrEmpty(logo))
                    header["logo"] = logo;
            }

            var voters = new List<object>();
            if (ds.Tables.Count > 0)
            {
                foreach (DataRow row in ds.Tables[0].Rows)
                {
                    voters.Add(new
                    {
                        ac_no = SafeStr(row, "ac_no"),
                        part_no = SafeStr(row, "part_no"),
                        slnoinpart = SafeStr(row, "slnoinpart"),
                        full_name = SafeStr(row, "full_name"),
                        middle_name = SafeStr(row, "middle_name"),
                        sex_age = SafeStr(row, "sex_age"),
                        idcard_no = SafeStr(row, "idcard_no"),
                        polling_location = SafeStr(row, "polling_location")
                    });
                }
            }
            result["voters"] = voters;

            string[] candNames = ParseCandidateNames(candidateCsv);
            var cands = new List<object>();
            for (int i = 0; i < candNames.Length; i++)
            {
                cands.Add(new
                {
                    num = i + 1,
                    name = candNames[i]
                });
            }
            result["candidates"] = cands;
        }
        catch (Exception ex)
        {
            result["error"] = ex.Message;
        }

        return js.Serialize(result);
    }

    private static string[] ParseCandidateNames(string candidateName)
    {
        if (string.IsNullOrWhiteSpace(candidateName))
            return new string[0];
        return candidateName
            .Split(new[] { ',' }, StringSplitOptions.RemoveEmptyEntries)
            .Select(s => s.Trim())
            .Where(s => s.Length > 0)
            .ToArray();
    }

    private static string SafeStr(DataRow row, string col)
    {
        return row.Table.Columns.Contains(col) && row[col] != DBNull.Value
            ? row[col].ToString().Trim()
            : "";
    }
}
