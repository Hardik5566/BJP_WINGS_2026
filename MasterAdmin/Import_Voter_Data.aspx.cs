using System;
using System.Collections.Generic;
using System.Data.SqlClient;
using System.Data;
using System.IO;
using System.Linq;
using System.Text;
using System.Web;
using System.Web.UI;
using System.Web.UI.WebControls;
using ExcelDataReader;
using System.Configuration;
using System.Threading.Tasks;

public partial class MasterAdmin_Import_Voter_Data : System.Web.UI.Page
{
    protected void Page_Load(object sender, EventArgs e)
    {
        
    }


    // FULL LIST OF COLUMNS
    string[] sqlColumns = {
        "ac_no", "part_no", "slnoinpart", "house_no", "eng_house_no",
        "localityid", "eng_localityid", "f_name", "eng_f_name", "f_surname",
        "f_eng_surname", "m_name", "eng_m_name", "surname", "eng_surname",
        "idcard_no", "sex", "age", "contact_no", "polling_location", "eng_polling_location"
    };

    protected void btnPreview_Click(object sender, EventArgs e)
    {
        if (!fileExcel.HasFile) return;

        string path = Server.MapPath("~/Uploads/" + Guid.NewGuid() + Path.GetExtension(fileExcel.FileName));
        fileExcel.SaveAs(path);

        using (var stream = File.Open(path, FileMode.Open, FileAccess.Read))
        {
            using (var reader = ExcelReaderFactory.CreateReader(stream))
            {
                var result = reader.AsDataSet(new ExcelDataSetConfiguration() { ConfigureDataTable = (_) => new ExcelDataTableConfiguration() { UseHeaderRow = true } });
                DataTable dt = result.Tables[0];
                Session["ImportData"] = dt;

                rptMapping.DataSource = sqlColumns;
                rptMapping.DataBind();

                foreach (RepeaterItem item in rptMapping.Items)
                {
                    var ddl = (DropDownList)item.FindControl("ddlExcelCol");
                    string sqlCol = ((HiddenField)item.FindControl("hfSqlCol")).Value;
                    ddl.Items.Add(new ListItem("-- Skip --", ""));
                    foreach (DataColumn dc in dt.Columns)
                    {
                        ddl.Items.Add(new ListItem(dc.ColumnName, dc.ColumnName));
                        if (dc.ColumnName.ToLower().Replace(" ", "") == sqlCol.ToLower().Replace("_", ""))
                            ddl.SelectedValue = dc.ColumnName;
                    }
                }
            }
        }
        ScriptManager.RegisterStartupScript(this, GetType(), "Pop", "showMappingModal();", true);
    }

    protected void btnStartImport_Click(object sender, EventArgs e)
    {
        DataTable dt = (DataTable)Session["ImportData"];
        if (dt == null) return;

        // Setup Progress Tracking
        Session["TotalRows"] = dt.Rows.Count;
        Session["ProcessedRows"] = 0;
        lblTotal.Text = dt.Rows.Count.ToString();
        divProgress.Visible = true;
        Timer1.Enabled = true;

        // Run Import
        Task.Run(() => DoBulkCopy(dt, GetMappings()));
    }

    private Dictionary<string, string> GetMappings()
    {
        var mappings = new Dictionary<string, string>();
        foreach (RepeaterItem item in rptMapping.Items)
        {
            string sql = ((HiddenField)item.FindControl("hfSqlCol")).Value;
            string excel = ((DropDownList)item.FindControl("ddlExcelCol")).SelectedValue;

            // FIX: Only add if Excel column is selected AND not already mapped
            if (!string.IsNullOrEmpty(excel))
            {
                if (!mappings.ContainsKey(excel))
                {
                    mappings.Add(excel, sql);
                }
                else
                {
                    // Optional: Alert user that Excel column is used twice
                }
            }
        }
        return mappings;
    }

    private void DoBulkCopy(DataTable dt, Dictionary<string, string> mappings)
    {
        using (SqlConnection conn = connection.open_connection())
        {
            conn.Open();
            using (SqlBulkCopy bc = new SqlBulkCopy(conn))
            {
                bc.DestinationTableName = "tbl_voting_record";
                bc.BatchSize = 5000;
                bc.NotifyAfter = 5000;
                bc.SqlRowsCopied += (s, ev) => { Session["ProcessedRows"] = (int)ev.RowsCopied; };

                foreach (var m in mappings) bc.ColumnMappings.Add(m.Key, m.Value);

                // app_id Logic
                if (!dt.Columns.Contains("app_id")) dt.Columns.Add("app_id").DefaultValue = 0;
                bc.ColumnMappings.Add("app_id", "app_id");

                bc.WriteToServer(dt);
            }
        }
        Session["ProcessedRows"] = Session["TotalRows"]; // Done
    }

    protected void Timer1_Tick(object sender, EventArgs e)
    {
        int processed = Session["ProcessedRows"] != null ? (int)Session["ProcessedRows"] : 0;
        int total = Session["TotalRows"] != null ? (int)Session["TotalRows"] : 1;

        double percentage = ((double)processed / total) * 100;
        pbImport.Style["width"] = percentage.ToString("0") + "%";
        pbImport.InnerText = percentage.ToString("0") + "%";
        lblCount.Text = processed.ToString("N0");

        if (processed >= total)
        {
            Timer1.Enabled = false;
            ScriptManager.RegisterStartupScript(this, GetType(), "Done", "alert('Import Finished Successfully!');", true);
        }
    }
}