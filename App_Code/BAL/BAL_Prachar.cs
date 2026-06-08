using System;
using System.Collections.Generic;
using System.Data.SqlClient;
using System.Data;
using System.Linq;
using System.Web;

/// <summary>
/// Summary description for BAL_Prachar
/// </summary>
public class BAL_Prachar
{
    public BAL_Prachar()
    {
        //
        // TODO: Add constructor logic here
        //
    }

    public static DataSet print_receipt_in_printer(string app_id,string voter_id,string idcard_no, string user_id)
    {
        SqlCommand cmd = new SqlCommand();
        cmd.CommandText = "print_receipt_in_printer_sp";
        parameter param = new parameter();
        cmd.Parameters.Add(param.intparam("@app_id", app_id));
        cmd.Parameters.Add(param.intparam("@voter_id", voter_id));
        cmd.Parameters.Add(param.stringparam("@idcard_no", idcard_no));
        cmd.Parameters.Add(param.intparam("@user_id", user_id));
        return command.ExtQueryDS(cmd);
    }

    public static DataSet get_receipt_in_all_family_for_wtsp(string app_id, string voter_id, string user_id)
    {
        SqlCommand cmd = new SqlCommand();
        cmd.CommandText = "get_receipt_in_all_family_for_wtsp_sp";
        parameter param = new parameter();
        cmd.Parameters.Add(param.intparam("@app_id", app_id));
        cmd.Parameters.Add(param.intparam("@voter_id", voter_id));
        cmd.Parameters.Add(param.intparam("@user_id", user_id));
        return command.ExtQueryDS(cmd);
    }

    public static DataSet get_receipt_in_single_for_wtsp(string app_id, string voter_id, string user_id)
    {
        SqlCommand cmd = new SqlCommand();
        cmd.CommandText = "get_receipt_in_single_for_wtsp_sp";
        parameter param = new parameter();
        cmd.Parameters.Add(param.intparam("@app_id", app_id));
        cmd.Parameters.Add(param.intparam("@voter_id", voter_id));
        cmd.Parameters.Add(param.intparam("@user_id", user_id));
        return command.ExtQueryDS(cmd);
    }

    public static DataSet get_receipt_in_all_family_for_sms(string app_id, string voter_id, string user_id)
    {
        SqlCommand cmd = new SqlCommand();
        cmd.CommandText = "get_receipt_in_all_family_for_sms_sp";
        parameter param = new parameter();
        cmd.Parameters.Add(param.intparam("@app_id", app_id));
        cmd.Parameters.Add(param.intparam("@voter_id", voter_id));
        cmd.Parameters.Add(param.intparam("@user_id", user_id));
        return command.ExtQueryDS(cmd);
    }

    public static DataSet get_receipt_in_single_for_sms(string app_id, string voter_id, string user_id)
    {
        SqlCommand cmd = new SqlCommand();
        cmd.CommandText = "get_receipt_in_single_for_sms_sp";
        parameter param = new parameter();
        cmd.Parameters.Add(param.intparam("@app_id", app_id));
        cmd.Parameters.Add(param.intparam("@voter_id", voter_id));
        cmd.Parameters.Add(param.intparam("@user_id", user_id));
        return command.ExtQueryDS(cmd);
    }

    public static DataSet dis_prachar_with_log(string app_id, string user_id,string prachar_type,string idcard)
    {
        SqlCommand cmd = new SqlCommand();
        cmd.CommandText = "dis_prachar_with_log_sp";
        parameter param = new parameter();
        cmd.Parameters.Add(param.intparam("@app_id", app_id));
        cmd.Parameters.Add(param.intparam("@user_id", user_id));
        cmd.Parameters.Add(param.stringparam("@prachar_type", prachar_type));
        cmd.Parameters.Add(param.stringparam("@idcard", idcard));
        return command.ExtQueryDS(cmd);
    }

    public static DataSet ins_log(string app_id, string user_id, string prachar_type, string idcard)
    {
        SqlCommand cmd = new SqlCommand();
        cmd.CommandText = "ins_log_sp";
        parameter param = new parameter();
        cmd.Parameters.Add(param.intparam("@app_id", app_id));
        cmd.Parameters.Add(param.intparam("@user_id", user_id));
        cmd.Parameters.Add(param.stringparam("@prachar_type", prachar_type));
        cmd.Parameters.Add(param.stringparam("@idcard", idcard));
        return command.ExtQueryDS(cmd);
    }

    public static DataSet dis_analytics_dash(string app_id)
    {
        SqlCommand cmd = new SqlCommand();
        cmd.CommandText = "dis_analytics_dash_sp";
        parameter param = new parameter();
        cmd.Parameters.Add(param.intparam("@app_id", app_id));
        return command.ExtQueryDS(cmd);
    }

    public static DataSet get_total_slip_distribution_count(string app_id)
    {
        SqlCommand cmd = new SqlCommand();
        cmd.CommandText = "get_total_slip_distribution_count_sp";

        parameter param = new parameter();

        cmd.Parameters.Add(param.intparam("@app_id", app_id));

        return command.ExtQueryDS(cmd);
    }


    public static DataSet phonebook_wise_slip_sending(string app_id, string user_id)
    {
        SqlCommand cmd = new SqlCommand();
        cmd.CommandText = "phonebook_wise_slip_sending_sp";

        parameter param = new parameter();

        cmd.Parameters.Add(param.intparam("@app_id", app_id));
        cmd.Parameters.Add(param.intparam("@user_id", user_id));

        return command.ExtQueryDS(cmd);
    }


    public static DataSet dis_phonebook_wise_slip_send_dash(string app_id)
    {
        SqlCommand cmd = new SqlCommand();
        cmd.CommandText = "dis_phonebook_wise_slip_send_dash_sp";

        parameter param = new parameter();

        cmd.Parameters.Add(param.intparam("@app_id", app_id));

        return command.ExtQueryDS(cmd);
    }

    public static DataSet dis_booth_wise_slip_send_dash(string app_id)
    {
        SqlCommand cmd = new SqlCommand();
        cmd.CommandText = "dis_booth_wise_slip_send_dash_sp";

        parameter param = new parameter();

        cmd.Parameters.Add(param.intparam("@app_id", app_id));

        return command.ExtQueryDS(cmd);
    }

    public static DataSet dis_booth_wise_slip_send_dash_for_saktikendra(string app_id, string booth_no)
    {
        SqlCommand cmd = new SqlCommand();
        cmd.CommandText = "dis_booth_wise_slip_send_dash_for_saktikendra_sp";
        parameter param = new parameter();
        cmd.Parameters.Add(param.intparam("@app_id", app_id));
        cmd.Parameters.Add(param.stringparam("@booth_no", booth_no));
        return command.ExtQueryDS(cmd);
    }

    public static DataSet dis_volunteer_slip_sending_count(string app_id)
    {
        SqlCommand cmd = new SqlCommand();
        cmd.CommandText = "dis_volunteer_slip_sending_count_sp";
        parameter param = new parameter();
        cmd.Parameters.Add(param.intparam("@app_id", app_id));
        return command.ExtQueryDS(cmd);
    }

    public static DataSet dis_saktikendra_wise_total_slip_distribution_count(string app_id,string booth_no)
    {
        SqlCommand cmd = new SqlCommand();
        cmd.CommandText = "dis_saktikendra_wise_total_slip_distribution_count";
        parameter param = new parameter();
        cmd.Parameters.Add(param.intparam("@app_id", app_id));
        cmd.Parameters.Add(param.stringparam("@booth_no", booth_no));
        return command.ExtQueryDS(cmd);
    }

    public static DataSet dis_booth_wise_total_slip_distribution_count(string app_id, string booth_no)
    {
        SqlCommand cmd = new SqlCommand();
        cmd.CommandText = "dis_booth_wise_total_slip_distribution_count_sp";
        parameter param = new parameter();
        cmd.Parameters.Add(param.intparam("@app_id", app_id));
        cmd.Parameters.Add(param.intparam("@booth_no", booth_no));
        return command.ExtQueryDS(cmd);
    }

    public static DataSet ins_sleep_log(string app_id, string voter_id,string user_id)
    {
        SqlCommand cmd = new SqlCommand();
        cmd.CommandText = "ins_sleep_log_sp";
        parameter param = new parameter();
        cmd.Parameters.Add(param.intparam("@app_id", app_id));
        cmd.Parameters.Add(param.stringparam("@voter_id", user_id));
        cmd.Parameters.Add(param.intparam("@user_id", voter_id));
        return command.ExtQueryDS(cmd);
    }
}