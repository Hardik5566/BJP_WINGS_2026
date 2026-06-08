using System;
using System.Collections.Generic;
using System.Data.SqlClient;
using System.Data;
using System.Linq;
using System.Web;

/// <summary>
/// Summary description for BAL_App_Setting
/// </summary>
public class BAL_App_Setting
{
    public BAL_App_Setting()
    {
        //
        // TODO: Add constructor logic here
        //
    }


    public static DataSet insert_app(
     string v_no, string v_name, string total_voter, string c_no, string c_name,
     string p_short, string p_full, string logo_png, string logo_jpg,
     string slip_msg, string sms_slip_msg, string inv_msg, // Added sms_slip_msg
     string off_status, string db_url, string off_ver,     // Added off_ver
     string splace_url, string app_link,   // Added links
     string app_ver, string popup_status, string popup_url, string create_by,
     // Module Rights Parameters
     string call_center, string prachar, string aachar_sahita,
     string live_voting, string sleep_send, string meta_wtsp, string AI)
    {
        SqlCommand cmd = new SqlCommand();
        cmd.CommandText = "ins_app_sp";
        cmd.CommandType = CommandType.StoredProcedure; // Good practice to set this
        parameter param = new parameter();

        // --- tbl_app Parameters ---
        cmd.Parameters.Add(param.stringparam("@vidhansabha_no", v_no));
        cmd.Parameters.Add(param.stringparam("@vidhansabha_name", v_name));
        cmd.Parameters.Add(param.intparam("@total_voter", total_voter));
        cmd.Parameters.Add(param.stringparam("@candidate_no", c_no));
        cmd.Parameters.Add(param.stringparam("@candidate_name", c_name));
        cmd.Parameters.Add(param.stringparam("@party_short_name", p_short));
        cmd.Parameters.Add(param.stringparam("@party_full_name", p_full));
        cmd.Parameters.Add(param.stringparam("@party_logo_png", logo_png));
        cmd.Parameters.Add(param.stringparam("@party_logo_jpg", logo_jpg));
        cmd.Parameters.Add(param.stringparam("@slip_message", slip_msg));
        cmd.Parameters.Add(param.stringparam("@sms_slip_message", sms_slip_msg));
        cmd.Parameters.Add(param.stringparam("@invitation_message", inv_msg));
        cmd.Parameters.Add(param.intparam("@offline_status", off_status));
        cmd.Parameters.Add(param.stringparam("@offline_db_url", db_url));
        cmd.Parameters.Add(param.stringparam("@offline_ver", off_ver));
        cmd.Parameters.Add(param.stringparam("@splace_url", splace_url));
        cmd.Parameters.Add(param.stringparam("@app_link", app_link));
        cmd.Parameters.Add(param.stringparam("@app_ver", app_ver));
        cmd.Parameters.Add(param.intparam("@popup_status", popup_status));
        cmd.Parameters.Add(param.stringparam("@popup_url", popup_url));
        cmd.Parameters.Add(param.intparam("@create_by", create_by));

        // --- Module Rights Parameters ---
        cmd.Parameters.Add(param.intparam("@call_center", call_center));
        cmd.Parameters.Add(param.intparam("@prachar", prachar));
        cmd.Parameters.Add(param.intparam("@aachar_sahita", aachar_sahita));
        cmd.Parameters.Add(param.intparam("@live_voting", live_voting));
        cmd.Parameters.Add(param.intparam("@sleep_send", sleep_send));
        cmd.Parameters.Add(param.intparam("@meta_wtsp", meta_wtsp));
        cmd.Parameters.Add(param.intparam("@AI", AI));

        return command.ExtQueryDS(cmd);
    }

    public static DataSet update_app(
    string app_id, // Added to identify the record
    string v_no, string v_name, string total_voter, string c_no, string c_name,
    string p_short, string p_full, string logo_png, string logo_jpg,
    string slip_msg, string sms_slip_msg, string inv_msg,
    string off_status, string db_url, string off_ver,
    string splace_url, string app_link,
    string app_ver, string popup_status, string popup_url, string update_by,
    // Module Rights Parameters
    string call_center, string prachar, string aachar_sahita,
    string live_voting, string sleep_send, string meta_wtsp, string AI)
    {
        SqlCommand cmd = new SqlCommand();
        cmd.CommandText = "upd_app_sp"; // Pointing to your new Update SP
        cmd.CommandType = CommandType.StoredProcedure;
        parameter param = new parameter();

        // --- ID Parameter ---
        cmd.Parameters.Add(param.intparam("@app_id", app_id));

        // --- tbl_app Parameters ---
        cmd.Parameters.Add(param.stringparam("@vidhansabha_no", v_no));
        cmd.Parameters.Add(param.stringparam("@vidhansabha_name", v_name));
        cmd.Parameters.Add(param.intparam("@total_voter", total_voter));
        cmd.Parameters.Add(param.stringparam("@candidate_no", c_no));
        cmd.Parameters.Add(param.stringparam("@candidate_name", c_name));
        cmd.Parameters.Add(param.stringparam("@party_short_name", p_short));
        cmd.Parameters.Add(param.stringparam("@party_full_name", p_full));
        cmd.Parameters.Add(param.stringparam("@party_logo_png", logo_png));
        cmd.Parameters.Add(param.stringparam("@party_logo_jpg", logo_jpg));
        cmd.Parameters.Add(param.stringparam("@slip_message", slip_msg));
        cmd.Parameters.Add(param.stringparam("@sms_slip_message", sms_slip_msg));
        cmd.Parameters.Add(param.stringparam("@invitation_message", inv_msg));
        cmd.Parameters.Add(param.intparam("@offline_status", off_status));
        cmd.Parameters.Add(param.stringparam("@offline_db_url", db_url));
        cmd.Parameters.Add(param.stringparam("@offline_ver", off_ver));
        cmd.Parameters.Add(param.stringparam("@splace_url", splace_url));
        cmd.Parameters.Add(param.stringparam("@app_link", app_link));
        cmd.Parameters.Add(param.stringparam("@app_ver", app_ver));
        cmd.Parameters.Add(param.intparam("@popup_status", popup_status));
        cmd.Parameters.Add(param.stringparam("@popup_url", popup_url));
        cmd.Parameters.Add(param.intparam("@update_by", update_by));

        // --- Module Rights Parameters ---
        cmd.Parameters.Add(param.intparam("@call_center", call_center));
        cmd.Parameters.Add(param.intparam("@prachar", prachar));
        cmd.Parameters.Add(param.intparam("@aachar_sahita", aachar_sahita));
        cmd.Parameters.Add(param.intparam("@live_voting", live_voting));
        cmd.Parameters.Add(param.intparam("@sleep_send", sleep_send));
        cmd.Parameters.Add(param.intparam("@meta_wtsp", meta_wtsp));
        cmd.Parameters.Add(param.intparam("@AI", AI));

        return command.ExtQueryDS(cmd);
    }

    public static DataSet sel_by_app_id(string app_id)
    {
        SqlCommand cmd = new SqlCommand();
        cmd.CommandText = "sel_app_sp";
        parameter param = new parameter();
        cmd.Parameters.Add(param.intparam("@app_id", app_id));
        return command.ExtQueryDS(cmd);
    }


    public static DataSet dis_all_App()
    {
        SqlCommand cmd = new SqlCommand();
        cmd.CommandText = "[dis_all_App]";
        return command.ExtQueryDS(cmd);
    }
}