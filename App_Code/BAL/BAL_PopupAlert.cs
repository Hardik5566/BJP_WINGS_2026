using System;
using System.Collections.Generic;
using System.Data;
using System.Data.SqlClient;
using System.Linq;
using System.Web;

/// <summary>
/// Summary description for BAL_PopupAlert
/// </summary>
public class BAL_PopupAlert
{
    public BAL_PopupAlert()
    {
        //
        // TODO: Add constructor logic here
        //
    }

    public static DataSet ins_popup_alert_with_media_sp(string app_id, string userId, string title, string content, string show_status, string isActive, DataTable mediaList)
    {
        SqlCommand cmd = new SqlCommand();
        cmd.CommandText = "ins_popup_alert_with_media_sp";
        cmd.CommandType = CommandType.StoredProcedure;

        parameter param = new parameter();
        cmd.Parameters.Add(param.intparam("@app_id", app_id));
        cmd.Parameters.Add(param.intparam("@UserId", userId));
        cmd.Parameters.Add(param.stringparam("@Title", title));
        cmd.Parameters.Add(param.stringparam("@Content", content));
        cmd.Parameters.Add(param.intparam("@show_status", show_status));
        cmd.Parameters.Add(param.intparam("@IsActive", isActive));
        cmd.Parameters.Add(param.TableParam("@MediaList", mediaList, "dbo.MediaTypeTable"));

        return command.ExtQueryDS(cmd);
    }

    // 2. UPDATE POPUP ALERT WITH MEDIA
    public static DataSet upd_popup_alert_with_media_sp(string app_id, string userId, string popupId, string title, string content, string show_status, string isActive, DataTable mediaList)
    {
        SqlCommand cmd = new SqlCommand();
        cmd.CommandText = "upd_popup_alert_with_media_sp";
        cmd.CommandType = CommandType.StoredProcedure;

        parameter param = new parameter();
        cmd.Parameters.Add(param.intparam("@app_id", app_id));
        cmd.Parameters.Add(param.intparam("@UserId", userId));
        cmd.Parameters.Add(param.intparam("@PopupId", popupId));
        cmd.Parameters.Add(param.stringparam("@Title", title));
        cmd.Parameters.Add(param.stringparam("@Content", content));
        cmd.Parameters.Add(param.intparam("@show_status", show_status));
        cmd.Parameters.Add(param.intparam("@IsActive", isActive));
        cmd.Parameters.Add(param.TableParam("@MediaList", mediaList, "dbo.MediaTypeTable"));

        return command.ExtQueryDS(cmd);
    }

    // 3. SOFT DELETE POPUP ALERT
    public static DataSet dlt_popup_alert_sp(string app_id, string userId, string popupId)
    {
        SqlCommand cmd = new SqlCommand();
        cmd.CommandText = "dlt_popup_alert_sp";
        cmd.CommandType = CommandType.StoredProcedure;

        parameter param = new parameter();
        cmd.Parameters.Add(param.intparam("@app_id", app_id));
        cmd.Parameters.Add(param.intparam("@UserId", userId));
        cmd.Parameters.Add(param.intparam("@PopupId", popupId));

        return command.ExtQueryDS(cmd);
    }

    // 4. SELECT FOR EDIT
    public static DataSet sel_popup_alert_for_edit_sp(string app_id, string popupId)
    {
        SqlCommand cmd = new SqlCommand();
        cmd.CommandText = "sel_popup_alert_for_edit_sp";
        cmd.CommandType = CommandType.StoredProcedure;

        parameter param = new parameter();
        cmd.Parameters.Add(param.intparam("@app_id", app_id));
        cmd.Parameters.Add(param.intparam("@PopupId", popupId));

        return command.ExtQueryDS(cmd);
    }

    // 5. DISPLAY ALL POPUP ALERTS
    public static DataSet dis_popup_alert_all_sp(string app_id)
    {
        SqlCommand cmd = new SqlCommand();
        cmd.CommandText = "dis_popup_alert_all_sp";
        cmd.CommandType = CommandType.StoredProcedure;

        parameter param = new parameter();
        cmd.Parameters.Add(param.intparam("@app_id", app_id));

        return command.ExtQueryDS(cmd);
    }

    public static DataSet dlt_popup_alert_media(string media_id, string delete_by)
    {
        SqlCommand cmd = new SqlCommand();
        cmd.CommandText = "dlt_popup_alert_media_sp";

        parameter param = new parameter();
        cmd.Parameters.Add(param.intparam("@media_id", media_id));
        cmd.Parameters.Add(param.intparam("@delete_by", delete_by));

        return command.ExtQueryDS(cmd); // Returns dataset containing the 'ok' row
    }
}