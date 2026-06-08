using System;
using System.Collections.Generic;
using System.Linq;
using System.Web;
using System.Web.UI;
using System.Web.UI.WebControls;
using System.Data;

public partial class WebSleep_Default : System.Web.UI.Page
{
    protected void Page_Load(object sender, EventArgs e)
    {
        try
        {
            if (!IsPostBack)
            {
                bind_assembly();
            }
        }
        catch (Exception)
        {

            throw;
        }
    }

    public void bind_assembly()
    {
        try
        {
            DataSet ds = BAL_Admin.dis_all_rajkot_App();
            if (ds.Tables.Count > 0)
            {
                ddl_assembly.DataSource = ds.Tables[0];
                ddl_assembly.DataBind();
                ddl_assembly.Items.Insert(0, new ListItem("select", "0"));
            }
        }
        catch (Exception)
        {

            throw;
        }
    }

    protected void btn_submit_search_Click(object sender, EventArgs e)
    {
        try
        {
            // 1. Validate Captcha
            //if (txt_captcha_input.Text != lbl_captcha_code.Text)
            //{
            //    // Handle invalid captcha
            //    return;
            //}

            // 2. Fetch Data (Replace with your BAL_Voter call)
            // You should fetch the family based on the EPIC number or address
            DataSet ds = BAL_Voter.get_receipt_in_all_family_for_web_sleep_sp(ddl_assembly.SelectedValue.ToString(), txt_epic_no.Text, "0");

            if (ds.Tables[0].Rows.Count > 0)
            {
                list_slip.DataSource = ds.Tables[0];
                list_slip.DataBind();

                div_idcard.Visible = false; // Hide search form
                pnl_results.Visible = true; // Show results
            }
        }
        catch (Exception)
        {

            throw;
        }
    }

    protected void btn_back_Click(object sender, EventArgs e)
    {
        div_idcard.Visible = true;
        pnl_results.Visible = false;
    }
}