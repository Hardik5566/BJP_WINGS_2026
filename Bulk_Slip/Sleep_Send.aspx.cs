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

public partial class Sleep_Send : System.Web.UI.Page
{
    protected void Page_Load(object sender, EventArgs e)
    {
        if (!IsPostBack)
        {
           
            if (Request.QueryString["no"] != null)
            {
                ViewState["booth_no"] = Request.QueryString["booth"].ToString();
                ViewState["mobile_no"] = "91" + Request.QueryString["no"].ToString();
            }
        }
    }
    // Fetches entire database for the JS loop
    public string GetVoterDataJson()
    {
        string mobile_no = ViewState["mobile_no"].ToString();

        DataSet ds = BAL_Voter.dis_booth_wise_search("3", ViewState["booth_no"].ToString());
        var list = new List<object>();
        foreach (DataRow row in ds.Tables[0].Rows)
        {
            list.Add(new
            {
                ID = row["idcard_no"].ToString(),
                Name = row["eng_f_name"].ToString(),
                Father = row["eng_m_name"].ToString(),
                SexAge = row["sex_age"].ToString(),
                Booth = row["part_no"].ToString(),
                SrNo = row["slnoinpart"].ToString(),
                AcNo = "1",
                Loc = row["eng_localityid"].ToString(),
                Mobile = mobile_no // Replace with row["mobile"]
            });
        }
        return new JavaScriptSerializer().Serialize(list);
    }

}