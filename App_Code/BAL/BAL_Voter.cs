using System;
using System.Collections.Generic;
using System.Data.SqlClient;
using System.Data;
using System.Linq;
using System.Web;
using System.Net;

/// <summary>
/// Summary description for BAL_Voter
/// </summary>
public class BAL_Voter
{
    public BAL_Voter()
    {
        //
        // TODO: Add constructor logic here
        //
    }
    public static DataSet master_search(string app_id,string f_name,string m_name,string surname,string mobile_no,string id_card_no)
    {
        SqlCommand cmd = new SqlCommand();
        cmd.CommandText = "master_search_sp";
        parameter param = new parameter();
        cmd.Parameters.Add(param.intparam("@app_id", app_id));
        cmd.Parameters.Add(param.stringparam("@f_name", f_name));
        cmd.Parameters.Add(param.stringparam("@m_name", m_name));
        cmd.Parameters.Add(param.stringparam("@surname", surname));
        cmd.Parameters.Add(param.stringparam("@mobile_no", mobile_no));
        cmd.Parameters.Add(param.stringparam("@id_card_no", id_card_no));
        return command.ExtQueryDS(cmd);
    }

    public static DataSet speak_and_search_sp(string app_id, string search)
    {
        SqlCommand cmd = new SqlCommand();
        cmd.CommandText = "speak_and_search_sp";
        parameter param = new parameter();
        cmd.Parameters.Add(param.intparam("@app_id", app_id));
        cmd.Parameters.Add(param.stringparam("@search", search));
        return command.ExtQueryDS(cmd);
    }

    public static DataSet scan_and_search(string app_id, string id_card_no)
    {
        SqlCommand cmd = new SqlCommand();
        cmd.CommandText = "scan_and_search_sp";
        parameter param = new parameter();
        cmd.Parameters.Add(param.intparam("@app_id", app_id));
        cmd.Parameters.Add(param.stringparam("@id_card_no", id_card_no));
        return command.ExtQueryDS(cmd);
    }

    public static DataSet age_wise_search(string app_id, string from_age,string to_age)
    {
        SqlCommand cmd = new SqlCommand();
        cmd.CommandText = "age_wise_search_sp";
        parameter param = new parameter();
        cmd.Parameters.Add(param.intparam("@app_id", app_id));
        cmd.Parameters.Add(param.intparam("@from_age", from_age));
        cmd.Parameters.Add(param.intparam("@to_age", to_age));
        return command.ExtQueryDS(cmd);
    }

    public static DataSet dis_all_surname(string app_id)
    {
        SqlCommand cmd = new SqlCommand();
        cmd.CommandText = "dis_all_surname_sp";
        parameter param = new parameter();
        cmd.Parameters.Add(param.intparam("@app_id", app_id));
        return command.ExtQueryDS(cmd);
    }

    public static DataSet get_all_match_surname_list(string app_id, string search_input)
    {
        SqlCommand cmd = new SqlCommand();
        cmd.CommandText = "get_all_match_surname_list";
        parameter param = new parameter();
        cmd.Parameters.Add(param.intparam("@app_id", app_id));
        cmd.Parameters.Add(param.stringparam("@search_input", search_input));
        return command.ExtQueryDS(cmd);
    }

    public static DataSet surname_wise_search(string app_id,string surname_list)
    {
        SqlCommand cmd = new SqlCommand();
        cmd.CommandText = "surname_wise_search_sp";
        parameter param = new parameter();
        cmd.Parameters.Add(param.intparam("@app_id", app_id));
        cmd.Parameters.Add(param.stringparam("@surname_list", surname_list));
        return command.ExtQueryDS(cmd);
    }

    public static DataSet dis_all_polling_location(string app_id)
    {
        SqlCommand cmd = new SqlCommand();
        cmd.CommandText = "dis_all_polling_location_sp";
        parameter param = new parameter();
        cmd.Parameters.Add(param.intparam("@app_id", app_id));
        return command.ExtQueryDS(cmd);
    }

    public static DataSet dis_polling_location_wise_voter(string app_id,string polling_location)
    {
        SqlCommand cmd = new SqlCommand();
        cmd.CommandText = "dis_polling_location_wise_voter_sp";
        parameter param = new parameter();
        cmd.Parameters.Add(param.intparam("@app_id", app_id));
        cmd.Parameters.Add(param.stringparam("@polling_location", polling_location));
        return command.ExtQueryDS(cmd);
    }

    public static DataSet dis_booth_wise_search(string app_id, string booth_no)
    {
        SqlCommand cmd = new SqlCommand();
        cmd.CommandText = "dis_booth_wise_search_sp";
        parameter param = new parameter();
        cmd.Parameters.Add(param.intparam("@app_id", app_id));
        cmd.Parameters.Add(param.intparam("@booth_no", booth_no));
        return command.ExtQueryDS(cmd);
    }

    public static DataSet dis_booth_wise_voter_for_bulk_sleep_send(string user_id,string app_id, string booth_no)
    {
        SqlCommand cmd = new SqlCommand();
        cmd.CommandText = "dis_booth_wise_voter_for_bulk_sleep_send_sp";
        parameter param = new parameter();
        cmd.Parameters.Add(param.intparam("@user_id", user_id));
        cmd.Parameters.Add(param.intparam("@app_id", app_id));
        cmd.Parameters.Add(param.intparam("@booth_no", booth_no));
        return command.ExtQueryDS(cmd);
    }

    public static DataSet get_receipt_in_all_family_for_web_sleep_sp (string app_id, string idcard,string user_id)
    {
        SqlCommand cmd = new SqlCommand();
        cmd.CommandText = "get_receipt_in_all_family_for_web_sleep_sp";
        parameter param = new parameter();
        cmd.Parameters.Add(param.intparam("@app_id", app_id));
        cmd.Parameters.Add(param.stringparam("@idcard", idcard));
        cmd.Parameters.Add(param.intparam("@user_id", user_id));
        return command.ExtQueryDS(cmd);
    }

    public static DataSet dis_family_member(string app_id, string voter_id)
    {
        SqlCommand cmd = new SqlCommand();
        cmd.CommandText = "dis_family_member_sp";
        parameter param = new parameter();
        cmd.Parameters.Add(param.intparam("@app_id", app_id));
        cmd.Parameters.Add(param.intparam("@voter_id", voter_id));
        return command.ExtQueryDS(cmd);
    }

    public static DataSet get_family_slip_photo_with_log(string app_id,string voter_id ,string user_id)
    {
        SqlCommand cmd = new SqlCommand();
        cmd.CommandText = "get_family_slip_photo_with_log_sp";
        parameter param = new parameter();
        cmd.Parameters.Add(param.intparam("@app_id", app_id));
        cmd.Parameters.Add(param.intparam("@voter_id", voter_id));
        cmd.Parameters.Add(param.intparam("@user_id", user_id));
        return command.ExtQueryDS(cmd);
    }

    public static DataSet get_slip_photo_with_log(string app_id, string voter_id, string user_id)
    {
        SqlCommand cmd = new SqlCommand();
        cmd.CommandText = "get_slip_photo_with_log_sp";
        parameter param = new parameter();
        cmd.Parameters.Add(param.intparam("@app_id", app_id));
        cmd.Parameters.Add(param.intparam("@voter_id", voter_id));
        cmd.Parameters.Add(param.intparam("@user_id", user_id));
        return command.ExtQueryDS(cmd);
    }

    public static DataSet dis_all_address(string app_id)
    {
        SqlCommand cmd = new SqlCommand();
        cmd.CommandText = "dis_all_address_sp";
        parameter param = new parameter();
        cmd.Parameters.Add(param.intparam("@app_id", app_id));
        return command.ExtQueryDS(cmd);
    }

    public static DataSet dis_address_wise_voter(string app_id,string address)
    {
        SqlCommand cmd = new SqlCommand();
        cmd.CommandText = "dis_address_wise_voter_sp";
        parameter param = new parameter();
        cmd.Parameters.Add(param.intparam("@app_id", app_id));
        cmd.Parameters.Add(param.stringparam("@address", address));
        return command.ExtQueryDS(cmd);
    }

    public static DataSet upd_voter_mobile(string app_id, string voter_id,string mobile_no,string modify_by)
    {
        SqlCommand cmd = new SqlCommand();
        cmd.CommandText = "upd_voter_mobile_sp";
        parameter param = new parameter();
        cmd.Parameters.Add(param.intparam("@app_id", app_id));
        cmd.Parameters.Add(param.stringparam("@voter_id", voter_id));
        cmd.Parameters.Add(param.stringparam("@mobile_no", mobile_no));
        cmd.Parameters.Add(param.intparam("@modify_by", modify_by));
        return command.ExtQueryDS(cmd);
    }

    public static DataSet dis_booth_wise_social_media_summary(string app_id)
    {
        SqlCommand cmd = new SqlCommand();
        cmd.CommandText = "dis_booth_wise_social_media_summary_sp";
        parameter param = new parameter();
        cmd.Parameters.Add(param.intparam("@app_id", app_id));
        return command.ExtQueryDS(cmd);
    }

    public static DataSet dis_booth_wise_facebook_users(string app_id, string booth_no)
    {
        SqlCommand cmd = new SqlCommand();
        cmd.CommandText = "dis_booth_wise_facebook_users_sp";

        parameter param = new parameter();
        cmd.Parameters.Add(param.intparam("@app_id", app_id));
        cmd.Parameters.Add(param.intparam("@booth_no", booth_no));

        return command.ExtQueryDS(cmd);
    }

    public static DataSet dis_booth_wise_insta_users(string app_id, string booth_no)
    {
        SqlCommand cmd = new SqlCommand();
        cmd.CommandText = "dis_booth_wise_insta_users_sp";

        parameter param = new parameter();
        cmd.Parameters.Add(param.intparam("@app_id", app_id));
        cmd.Parameters.Add(param.intparam("@booth_no", booth_no));

        return command.ExtQueryDS(cmd);
    }

    public static DataSet print_bulk_receipt_in_printer(string app_id, string booth_no,string user_id)
    {
        SqlCommand cmd = new SqlCommand();
        cmd.CommandText = "print_bulk_receipt_in_printer_sp";

        parameter param = new parameter();
        cmd.Parameters.Add(param.intparam("@app_id", app_id));
        cmd.Parameters.Add(param.intparam("@booth_no", booth_no));
        cmd.Parameters.Add(param.intparam("@user_id", user_id));

        return command.ExtQueryDS(cmd);
    }
}