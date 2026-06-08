using System;
using System.Collections.Generic;
using System.Data;
using System.IO;
using System.Linq;
using System.Web;
using System.Web.UI;
using System.Web.UI.WebControls;

public partial class MasterAdmin_App_Master : System.Web.UI.Page
{
    public enum MessageType { Success, Error, Info, Warning };

    protected void ShowMessage(string Message, MessageType type)
    {
        ScriptManager.RegisterStartupScript(this, this.GetType(), System.Guid.NewGuid().ToString(), "ShowMessage('" + Message + "','" + type + "');", true);
    }

    protected void Page_Load(object sender, EventArgs e)
    {
        if (!IsPostBack)
        {
            bind_data();
        }
    }

    public void bind_data()
    {
        DataSet ds = BAL_App_Setting.dis_all_App();
        if (ds != null && ds.Tables.Count > 0)
        {
            rep_apps.DataSource = ds.Tables[0];
            rep_apps.DataBind();
        }
    }


    protected void btn_save_Click(object sender, EventArgs e)
    {
        try
        {
            // 1. Collect basic data from TextBoxes
            string v_no = txt_v_no.Text.Trim();
            string v_name = txt_v_name.Text.Trim();
            string total_voter = txt_total_voter.Text.Trim();
            string c_no = txt_c_no.Text.Trim();
            string c_name = txt_c_name.Text.Trim();
            string p_short = txt_p_short.Text.Trim();
            string p_full = txt_p_full.Text.Trim();
            string logo_png = txt_logo_png.Text.Trim();
            string logo_jpg = txt_logo_jpg.Text.Trim();
            string slip_msg = txt_slip_msg.Text.Trim();
            string sms_msg = txt_sms_slip_msg.Text.Trim();
            string inv_msg = txt_inv_msg.Text.Trim();
            string off_status = ddl_off_status.SelectedValue;
            string db_url = txt_db_url.Text.Trim();
            string off_ver = txt_offline_ver.Text; // Or from a textbox
            string app_link = txt_app_link.Text.Trim();
            string app_ver = txt_app_ver.Text.Trim();
            string pop_status = ddl_popup_status.SelectedValue;
            string pop_url = txt_popup_url.Text.Trim();
            string user_id = "1"; // Replace with Session["user_id"]

            // Splash Image Logic (simplified)
            string splace_url = "";
            if (fu_splace.HasFile)
            {
                try
                {
                    // 1. Get the file extension (e.g., .jpg, .png)
                    string extension = System.IO.Path.GetExtension(fu_splace.FileName).ToLower();

                    // 2. Validate extension (Optional but recommended)
                    if (extension == ".jpg" || extension == ".png" || extension == ".jpeg")
                    {
                        // 3. Create a unique filename using timestamp to avoid overwriting
                        string fileName = "Splash_" + DateTime.Now.ToString("yyyyMMddHHmmss") + extension;

                        // 4. Define the server path (Ensure 'uploads' folder exists in your project)
                        string folderPath = Server.MapPath("~/img/splace/");

                        // 5. Create directory if it doesn't exist
                        if (!System.IO.Directory.Exists(folderPath))
                        {
                            System.IO.Directory.CreateDirectory(folderPath);
                        }

                        // 6. Save the physical file
                        fu_splace.SaveAs(folderPath + fileName);

                        // 7. Store the relative URL to save in the Database
                        splace_url = fileName;
                    }
                }
                catch (Exception ex)
                {
                    // Log error or show message if upload fails
                    Response.Write("<script>alert('Image Upload Failed: " + ex.Message + "');</script>");
                }
            }
            else
            {
                // If updating and no NEW file is selected, keep the existing URL
                // You would pull this from a HiddenField or the database
                if (ViewState["splace_url"] != null)
                {
                    splace_url = ViewState["splace_url"].ToString();
                }

            }

            DataSet ds;

            // 2. Decide: Insert or Update?
            if (hd_action.Value == "save")
            {
                // CALL INSERT
                ds = BAL_App_Setting.insert_app(
                    v_no, v_name, total_voter, c_no, c_name, p_short, p_full,
                    logo_png, logo_jpg, slip_msg, sms_msg, inv_msg, off_status,
                    db_url, off_ver, splace_url, app_link, app_ver, pop_status,
                    pop_url, user_id,
                    ddl_call_center.SelectedValue, ddl_prachar.SelectedValue,
                    ddl_aachar_sahita.SelectedValue, ddl_live_voting.SelectedValue,
                    ddl_sleep_send.SelectedValue, ddl_meta_wtsp.SelectedValue, ddl_ai.SelectedValue
                );
            }
            else
            {
                // CALL UPDATE
                ds = BAL_App_Setting.update_app(
                    hd_action.Value, // Pass the ID for Update
                    v_no, v_name, total_voter, c_no, c_name, p_short, p_full,
                    logo_png, logo_jpg, slip_msg, sms_msg, inv_msg, off_status,
                    db_url, off_ver, splace_url, app_link, app_ver, pop_status,
                    pop_url, user_id,
                    ddl_call_center.SelectedValue, ddl_prachar.SelectedValue,
                    ddl_aachar_sahita.SelectedValue, ddl_live_voting.SelectedValue,
                    ddl_sleep_send.SelectedValue, ddl_meta_wtsp.SelectedValue, ddl_ai.SelectedValue
                );
            }

            // 3. UI Response
            if (ds != null)
            {
                // Success: Clear fields and hide modal
                hd_action.Value = "";
                Response.Write("<script>alert('Data Saved Successfully!'); location.href=location.href;</script>");
            }
        }
        catch (Exception ex)
        {
            Response.Write("<script>alert('Error: " + ex.Message + "');</script>");
        }
    }




    protected void rep_apps_ItemCommand(object source, RepeaterCommandEventArgs e)
    {
        if (e.CommandName == "btn_edit")
        {
            string app_id = e.CommandArgument.ToString();

            // 1. Fetch data for this specific ID
            // Assuming you have a function like 'get_app_by_id(id)'
            DataSet ds = BAL_App_Setting.sel_by_app_id(app_id);

            if (ds != null && ds.Tables[0].Rows.Count > 0)
            {
                DataRow dr = ds.Tables[0].Rows[0];

                // 2. Fill the HiddenField (Crucial for the Update logic)
                hd_action.Value = app_id;

                // 3. Populate TextBoxes
                txt_v_no.Text = dr["vidhansabha_no"].ToString();
                txt_v_name.Text = dr["vidhansabha_name"].ToString();
                txt_total_voter.Text = dr["total_voter"].ToString();
                txt_c_no.Text = dr["candidate_no"].ToString();
                txt_c_name.Text = dr["candidate_name"].ToString();
                txt_p_short.Text = dr["party_short_name"].ToString();
                txt_p_full.Text = dr["party_full_name"].ToString();
                txt_logo_png.Text = dr["party_logo_png"].ToString();
                txt_logo_jpg.Text = dr["party_logo_jpg"].ToString();
                txt_slip_msg.Text = dr["slip_message"].ToString();
                txt_sms_slip_msg.Text = dr["sms_slip_message"].ToString();
                txt_inv_msg.Text = dr["invitation_message"].ToString();
                txt_db_url.Text = dr["offline_db_url"].ToString();
                txt_app_link.Text = dr["app_link"].ToString();
                txt_app_ver.Text = dr["app_ver"].ToString();
                txt_popup_url.Text = dr["popup_url"].ToString();
                txt_offline_ver.Text = dr["offline_ver"].ToString();
                ViewState["splace_url"] = dr["splace_url"].ToString();

                // 4. Populate DropDownLists (0/1 Logic)
                ddl_off_status.SelectedValue = dr["offline_status"].ToString();
                ddl_popup_status.SelectedValue = dr["popup_status"].ToString();

                // Module Rights
                ddl_call_center.SelectedValue = dr["call_center"].ToString();
                ddl_prachar.SelectedValue = dr["prachar"].ToString();
                ddl_aachar_sahita.SelectedValue = dr["aachar_sahita"].ToString();
                ddl_live_voting.SelectedValue = dr["live_voting"].ToString();
                ddl_sleep_send.SelectedValue = dr["sleep_send"].ToString();
                ddl_meta_wtsp.SelectedValue = dr["meta_wtsp"].ToString();
                ddl_ai.SelectedValue = dr["AI"].ToString();

                // 5. Open the Modal via JavaScript
                ScriptManager.RegisterStartupScript(this, this.GetType(), "Pop", "showModal();", true);
            }
        }
    }

    // Helper to get the Text Label based on integer value
    // Updated Helper for Status Text
    public string GetStatusText(object status)
    {
        string s = status.ToString();
        switch (s)
        {
            case "0": return "ONLINE"; // Added Online
            case "1": return "OFFLINE";
            case "2": return "FORCE OFFLINE";
            case "3": return "AUTO OFFLINE";
            default: return "UNKNOWN";
        }
    }

    // Updated Helper for Professional Subtle Styling
    public string GetStatusClass(object status)
    {
        string s = status.ToString();
        switch (s)
        {
            case "0": return "bg-success text-white shadow-sm"; // Solid Green for Online
            case "1": return "bg-success-subtle text-success border border-success-subtle";
            case "2": return "bg-danger-subtle text-danger border border-danger-subtle";
            case "3": return "bg-warning-subtle text-warning border border-warning-subtle";
            default: return "bg-light text-secondary border";
        }
    }
}