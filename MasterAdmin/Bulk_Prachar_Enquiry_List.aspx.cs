using System;
using System.Collections.Generic;
using System.Data;
using System.Globalization;
using System.Linq;
using System.Web;
using System.Web.UI;
using System.Web.UI.WebControls;



public partial class MasterAdmin_Bulk_Prachar_Enquiry_List : System.Web.UI.Page

{

    protected void Page_Load(object sender, EventArgs e)

    {

        if (!IsPostBack)

        {
            InitStatusFilters();
            ApplyQueryStringFilters();
        }



        LoadAndBindEnquiries();

    }



    private void ApplyQueryStringFilters()

    {
        string pracharStatus = Request.QueryString["prachar_status"];
        if (!string.IsNullOrWhiteSpace(pracharStatus))
        {
            pracharStatus = pracharStatus.Trim();
            ListItem pracharItem = ddl_prachar_status.Items.FindByValue(pracharStatus);
            if (pracharItem != null)
                ddl_prachar_status.SelectedValue = pracharStatus;
        }

        string paymentStatus = Request.QueryString["payment_status"];
        if (!string.IsNullOrWhiteSpace(paymentStatus))
        {
            paymentStatus = paymentStatus.Trim();
            ListItem paymentItem = ddl_payment_status.Items.FindByValue(paymentStatus);
            if (paymentItem != null)
                ddl_payment_status.SelectedValue = paymentStatus;
        }

        string pracharType = Request.QueryString["prachar_type"];
        if (!string.IsNullOrWhiteSpace(pracharType))
            ViewState["QsPracharType"] = pracharType.Trim();
    }



    private void InitStatusFilters()

    {

        ddl_payment_status.Items.Clear();
        ddl_payment_status.Items.Add(new ListItem("All Payment Status", ""));
        ddl_payment_status.Items.Add(new ListItem("Received", "Received"));
        ddl_payment_status.Items.Add(new ListItem("Not Received", "Not Received"));
        ddl_prachar_status.Items.Clear();
        ddl_prachar_status.Items.Add(new ListItem("All Prachar Status", ""));
        ddl_prachar_status.Items.Add(new ListItem("Pending", "Pending"));
        ddl_prachar_status.Items.Add(new ListItem("Finished", "Finished"));
        ddl_prachar_status.Items.Add(new ListItem("Cancelled", "Cancelled"));

    }



    protected void FilterChanged(object sender, EventArgs e)

    {
        LoadAndBindEnquiries();
    }



    protected void btn_reset_filter_Click(object sender, EventArgs e)

    {
        ddl_payment_status.SelectedIndex = 0;
        ddl_prachar_status.SelectedIndex = 0;
        ddl_prachar_type.SelectedIndex = 0;
        ViewState["QsPracharType"] = null;
        LoadAndBindEnquiries();
    }



    protected void btn_update_prachar_status_Click(object sender, EventArgs e)

    {
        try
        {
            string pracharId = hf_prachar_id.Value.Trim();
            string status = hf_selected_status.Value.Trim();

            if (string.IsNullOrEmpty(pracharId) || string.IsNullOrEmpty(status))
            {
                ShowUpdateMessage("Please select a prachar status.", false);
                return;
            }

            BAL_Prachar.upd_bulk_prachar_status(pracharId, status, GetModifyBy());
            ShowUpdateMessage("Prachar status updated successfully.", true);
            LoadAndBindEnquiries();
        }
        catch (Exception ex)
        {
            ShowUpdateMessage("Unable to update prachar status: " + ex.Message, false);
        }
    }



    protected void btn_update_payment_status_Click(object sender, EventArgs e)

    {
        try
        {
            string pracharId = hf_prachar_id.Value.Trim();
            string status = hf_selected_status.Value.Trim();

            if (string.IsNullOrEmpty(pracharId) || string.IsNullOrEmpty(status))
            {
                ShowUpdateMessage("Please select a payment status.", false);
                return;
            }

            BAL_Prachar.upd_bulk_prachar_payment_status(pracharId, status, GetModifyBy());
            ShowUpdateMessage("Payment status updated successfully.", true);
            LoadAndBindEnquiries();
        }
        catch (Exception ex)
        {
            ShowUpdateMessage("Unable to update payment status: " + ex.Message, false);
        }
    }



    private string GetModifyBy()

    {
        if (Session["user_id"] != null)
            return Session["user_id"].ToString();

        return "1";
    }



    private void ShowUpdateMessage(string message, bool isSuccess)

    {
        lbl_update_msg.Text = message;
        lbl_update_msg.CssClass = isSuccess
            ? "alert alert-success status-alert"
            : "alert alert-danger status-alert";
        lbl_update_msg.Visible = true;
    }



    private void LoadAndBindEnquiries()

    {

        try

        {

            lbl_error.Text = "";

            DataSet ds = BAL_Prachar.dis_bulk_prachar_enquiry();

            if (ds == null || ds.Tables.Count == 0)

            {

                ShowEmpty("0");

                return;

            }

            DataTable allRows = ds.Tables[0];

            BindPracharTypeFilter(allRows);

            DataTable filtered = ApplyFilters(allRows);

            lbl_total_records.Text = filtered.Rows.Count.ToString("N0", CultureInfo.InvariantCulture);

            if (filtered.Rows.Count == 0)

            {

                pnl_empty.Visible = true;

                pnl_table.Visible = false;

                lbl_error.Text = allRows.Rows.Count > 0

                    ? "No records match the selected filters."

                    : "";

                return;

            }



            pnl_empty.Visible = false;

            pnl_table.Visible = true;

            rptEnquiries.DataSource = filtered;

            rptEnquiries.DataBind();

        }

        catch (Exception ex)

        {

            ShowEmpty("0");

            lbl_error.Text = "Unable to load enquiries: " + ex.Message;

        }

    }



    private void BindPracharTypeFilter(DataTable dt)

    {

        string selected = ddl_prachar_type.SelectedValue;

        ddl_prachar_type.Items.Clear();

        ddl_prachar_type.Items.Add(new ListItem("All Prachar Types", ""));



        if (dt == null || dt.Rows.Count == 0)

            return;



        var types = dt.AsEnumerable()

            .Select(r => Convert.ToString(r["prachar"]).Trim())

            .Where(t => !string.IsNullOrEmpty(t))

            .Distinct(StringComparer.OrdinalIgnoreCase)

            .OrderBy(t => t);



        foreach (string type in types)

            ddl_prachar_type.Items.Add(new ListItem(type, type));



        if (string.IsNullOrEmpty(selected) && ViewState["QsPracharType"] != null)

            selected = ViewState["QsPracharType"].ToString();



        ListItem existing = ddl_prachar_type.Items.FindByValue(selected);

        if (existing != null)

            ddl_prachar_type.SelectedValue = selected;

    }



    private DataTable ApplyFilters(DataTable source)

    {

        if (source == null)

            return new DataTable();



        IEnumerable<DataRow> rows = source.AsEnumerable();



        if (!string.IsNullOrWhiteSpace(ddl_prachar_type.SelectedValue))

        {

            string type = ddl_prachar_type.SelectedValue;

            rows = rows.Where(r => string.Equals(

                Convert.ToString(r["prachar"]).Trim(),

                type,

                StringComparison.OrdinalIgnoreCase));

        }



        if (!string.IsNullOrWhiteSpace(ddl_prachar_status.SelectedValue))

        {

            string status = ddl_prachar_status.SelectedValue;

            rows = rows.Where(r => string.Equals(

                Convert.ToString(r["prachar_status"]).Trim(),

                status,

                StringComparison.OrdinalIgnoreCase));

        }



        if (!string.IsNullOrWhiteSpace(ddl_payment_status.SelectedValue))

        {

            string payment = ddl_payment_status.SelectedValue;

            rows = rows.Where(r => string.Equals(

                Convert.ToString(r["payment_status"]).Trim(),

                payment,

                StringComparison.OrdinalIgnoreCase));

        }



        if (!rows.Any())

            return source.Clone();



        return rows.CopyToDataTable();

    }



    private void ShowEmpty(string count)

    {

        lbl_total_records.Text = count;

        pnl_empty.Visible = true;

        pnl_table.Visible = false;

    }



    protected string FormatNumber(object value)

    {

        if (value == null || value == DBNull.Value)

            return "—";



        decimal number;

        if (decimal.TryParse(value.ToString(), NumberStyles.Any, CultureInfo.InvariantCulture, out number))

            return number.ToString("N0", CultureInfo.InvariantCulture);



        return value.ToString();

    }



    protected string FormatCostPerVoter(object value)

    {

        if (value == null || value == DBNull.Value)

            return "—";



        decimal number;

        if (decimal.TryParse(value.ToString(), NumberStyles.Any, CultureInfo.InvariantCulture, out number))

            return "₹ " + number.ToString("0.##", CultureInfo.InvariantCulture);



        return value.ToString();

    }



    protected string FormatTotalCost(object value)

    {

        if (value == null || value == DBNull.Value)

            return "—";



        decimal number;

        if (decimal.TryParse(value.ToString(), NumberStyles.Any, CultureInfo.InvariantCulture, out number))

            return "₹ " + number.ToString("N0", CultureInfo.InvariantCulture);



        return value.ToString();

    }



    protected string FormatDate(object value)

    {

        if (value == null || value == DBNull.Value)

            return "—";



        DateTime dt;

        if (DateTime.TryParse(value.ToString(), out dt))

            return dt.ToString("dd-MMM-yyyy HH:mm", CultureInfo.InvariantCulture);



        return value.ToString();

    }



    protected string GetStatusBadgeClass(object status)

    {

        string text = Convert.ToString(status).Trim().ToLowerInvariant();



        if (text == "finished" || text == "completed" || text == "done" || text == "received" || text == "paid")

            return "status-badge status-success";



        if (text == "cancelled" || text == "canceled" || text == "rejected" || text == "failed")

            return "status-badge status-danger";



        if (text == "pending" || text == "new" || text == "open" || text == "not received")

            return "status-badge status-warning";



        return "status-badge status-muted";

    }



    protected string SafeText(object value)

    {

        if (value == null || value == DBNull.Value)

            return "—";



        string text = value.ToString().Trim();

        return string.IsNullOrEmpty(text) ? "—" : text;

    }



    protected string AttrEncode(object value)

    {

        if (value == null || value == DBNull.Value)

            return string.Empty;

        return HttpUtility.HtmlAttributeEncode(Convert.ToString(value).Trim());

    }

}


