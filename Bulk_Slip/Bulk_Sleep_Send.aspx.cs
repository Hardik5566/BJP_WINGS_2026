using System;
using System.Collections.Generic;
using System.Data;
using System.Drawing.Imaging;
using System.Drawing;
using System.Linq;
using System.Net.Http.Headers;
using System.Net.Http;
using System.Text;
using System.Web;
using System.Web.UI;
using System.Web.UI.WebControls;
using System.IO;
using System.Web.Script.Serialization;
using System.Web.Services;
using System.Web.Script.Services;

public partial class Bulk_Sleep_Send : System.Web.UI.Page
{
    protected void Page_Load(object sender, EventArgs e)
    {
        if (!IsPostBack)
        {
            if (Request.QueryString["booth"] != null)
            {
                ViewState["booth"] = Request.QueryString["booth"].ToString();
                ViewState["uid"] = Request.QueryString["uid"].ToString();
                ViewState["appid"] = Request.QueryString["appid"].ToString();

            }
            else
            {

            }
        }
    }

    // Fetches entire database for the JS loop
    public string GetVoterDataJson()
    {


        DataSet ds = BAL_Voter.dis_booth_wise_voter_for_bulk_sleep_send(ViewState["uid"].ToString(),ViewState["appid"].ToString(), ViewState["booth"].ToString());
        var list = new List<object>();

        string cmp_id = ds.Tables[0].Rows[0]["GeneratedCampaignID"].ToString();

        foreach (DataRow row in ds.Tables[1].Rows)
        {
            list.Add(new
            {
                CmpId = cmp_id,
                UserID = ViewState["uid"].ToString(),
                AppID = ViewState["appid"].ToString(),
                ID = row["idcard_no"].ToString(),
                Name = row["f_name"].ToString()+ " " + row["f_surname"].ToString(),
                Father = row["m_name"].ToString() + " " + row["f_surname"].ToString(),
                Booth = row["part_no"].ToString(),
                SrNo = row["slnoinpart"].ToString(),
                SexAge= row["sex_age"].ToString(),
                AcNo = "3",
                Loc = row["polling_location"].ToString(),
                Mobile = row["contact_no"].ToString()
                //Mobile = "9558001712"
            });
        }
        return new JavaScriptSerializer().Serialize(list);
    }

}