using System;
using System.Data;
using System.Globalization;
using System.Web.UI;

public partial class MasterAdmin_Prachar_Dashboard : System.Web.UI.Page
{
    protected void Page_Load(object sender, EventArgs e)
    {
        if (!IsPostBack)
            BindDashboard();
    }

    private void BindDashboard()
    {
        try
        {
            DataSet ds = BAL_Prachar.dis_bulk_prachar_dashboard();
            if (ds == null || ds.Tables.Count == 0 || ds.Tables[0].Rows.Count == 0)
                return;

            DataRow dr = ds.Tables[0].Rows[0];

            long totalEnquiry = ToLong(dr["total_enquiry"]);
            long pendingCount = ToLong(dr["pending_count"]);
            long finishedCount = ToLong(dr["finished_count"]);
            long cancelledCount = ToLong(dr["cancelled_count"]);

            lbl_total_enquiry.Text = FormatCount(totalEnquiry);
            lbl_pending_count.Text = FormatCount(pendingCount);
            lbl_finished_count.Text = FormatCount(finishedCount);
            lbl_cancelled_count.Text = FormatCount(cancelledCount);

            lbl_pending_pct.Text = FormatPercent(pendingCount, totalEnquiry);
            lbl_finished_pct.Text = FormatPercent(finishedCount, totalEnquiry);
            lbl_cancelled_pct.Text = FormatPercent(cancelledCount, totalEnquiry);

            lbl_pending_summary.Text = FormatCount(pendingCount);
            lbl_finished_summary.Text = FormatCount(finishedCount);
            lbl_cancelled_summary.Text = FormatCount(cancelledCount);

            int pendingWidth = CalcPercentWidth(pendingCount, totalEnquiry);
            int finishedWidth = CalcPercentWidth(finishedCount, totalEnquiry);
            int cancelledWidth = CalcPercentWidth(cancelledCount, totalEnquiry);

            pending_bar.Style["width"] = pendingWidth + "%";
            finished_bar.Style["width"] = finishedWidth + "%";
            cancelled_bar.Style["width"] = cancelledWidth + "%";
        }
        catch (Exception ex)
        {
            lbl_total_enquiry.Text = "—";
            lbl_pending_count.Text = "—";
            lbl_finished_count.Text = "—";
            lbl_cancelled_count.Text = "—";
        }
    }

    private static long ToLong(object value)
    {
        if (value == null || value == DBNull.Value)
            return 0;

        long result;
        return long.TryParse(value.ToString(), out result) ? result : 0;
    }

    private static string FormatCount(long value)
    {
        return value.ToString("N0", CultureInfo.InvariantCulture);
    }

    private static string FormatPercent(long part, long total)
    {
        if (total <= 0)
            return "0%";

        decimal pct = Math.Round((decimal)part * 100m / total, 1);
        return pct.ToString("0.#", CultureInfo.InvariantCulture) + "%";
    }

    private static int CalcPercentWidth(long part, long total)
    {
        if (total <= 0)
            return 0;

        return (int)Math.Round((decimal)part * 100m / total, 0);
    }
}
