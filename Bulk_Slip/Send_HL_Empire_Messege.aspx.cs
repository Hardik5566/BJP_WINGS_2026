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

public partial class Send_HL_Empire_Messege : System.Web.UI.Page
{
    protected void Page_Load(object sender, EventArgs e)
    {
        if (!IsPostBack)
        {
            ViewState["mobile_no"] = "919558001712";
            if (Request.QueryString["no"] != null)
            {
                ViewState["mobile_no"] = "91" + Request.QueryString["no"].ToString();
            }
        }
    }
    // Fetches entire database for the JS loop
    public string GetVoterDataJson()
    {
        string mobile_no = ViewState["mobile_no"].ToString();
        if (Request.QueryString["no"] != null)
        {
            mobile_no = Request.QueryString["no"].ToString();
        }


        DataTable dt = new DataTable();
        dt.Columns.AddRange(
                new DataColumn[6] {
                        new DataColumn("name"),
                    new DataColumn("inq_no"),
                    new DataColumn("product"),
                    new DataColumn("protype"),
                    new DataColumn("size"),
                    new DataColumn("mobile")
                });

        dt.Rows.Add("Hardik Vaghasiya", "HL-1001", "Silica Sand", "Dry", "45-50 AFS", "9558001712");
        //dt.Rows.Add("Vishal Bhai", "HL-1002", "Silica Sand", "Wet", "35-40 AFS", "8866228391");
        dt.Rows.Add("Prasant Bhai", "HL-1003", "Silica Sand", "Dry", "40-45 AFS", "9737949291");
        dt.Rows.Add("Mayur Bhai", "HL-1004", "Silica Sand", "Wet", "50-55 AFS", "8989833331");
        dt.Rows.Add("Jaydeep Bhai", "HL-1005", "Silica Sand", "Dry", "55-60 AFS", "9099304119");
        dt.Rows.Add("Kalu Bhai", "HL-1006", "Silica Sand", "Wet", "45-50 AFS", "7041135312");
        dt.Rows.Add("Nilesh Vasava", "HL-1007", "Silica Sand", "Dry", "35-40 AFS", "9824252763");
        dt.Rows.Add("Jignesh Bhai", "HL-1008", "Silica Sand", "Wet", "40-45 AFS", "9327365197");
        dt.Rows.Add("Vinitbhai Rughani", "HL-1009", "Silica Sand", "Dry", "50-55 AFS", "8080001078");
        dt.Rows.Add("Dr. Hiren Ghelani", "HL-1010", "Silica Sand", "Wet", "55-60 AFS", "9998092970");
        dt.Rows.Add("Savanbhai", "HL-1011", "Silica Sand", "Dry", "45-50 AFS", "9033388388");
        dt.Rows.Add("Ketan Bhai", "HL-1012", "Silica Sand", "Wet", "35-40 AFS", "9824212799");
        dt.Rows.Add("Nikhil Thummar", "HL-1013", "Silica Sand", "Dry", "40-45 AFS", "9558111155");

        var list = new List<object>();
        foreach (DataRow row in dt.Rows)
        {
            list.Add(new
            {
                name = row["name"].ToString(),
                inq_no = row["inq_no"].ToString(),
                product = row["product"].ToString(),
                protype = row["protype"].ToString(),
                size = row["size"].ToString(),
                Mobile = "91" + row["mobile"] // Replace with row["mobile"]
            });
        }
        return new JavaScriptSerializer().Serialize(list);
    }

}