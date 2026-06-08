using System;
using System.Collections.Generic;
using System.Data.SqlClient;
using System.Data;
using System.Linq;
using System.Web;

/// <summary>
/// Summary description for BAL_Bulk_Wtsp
/// </summary>
public class BAL_Bulk_Wtsp
{
    public BAL_Bulk_Wtsp()
    {
        //
        // TODO: Add constructor logic here
        //
    }

    public static DataSet AllocateUserBalance(string app_id,string user_id,string total_messege, string action_type,string remarks,string create_by)
    {
        SqlCommand cmd = new SqlCommand();
        cmd.CommandText = "sp_AllocateUserBalance";
        parameter param = new parameter();
        cmd.Parameters.Add(param.intparam("@app_id", app_id));
        cmd.Parameters.Add(param.intparam("@user_id", user_id));
        cmd.Parameters.Add(param.intparam("@total_messege", total_messege));
        cmd.Parameters.Add(param.stringparam("@action_type", action_type));
        cmd.Parameters.Add(param.stringparam("@remarks", remarks));
        cmd.Parameters.Add(param.intparam("@create_by", create_by));
        return command.ExtQueryDS(cmd);
    }

    public static DataSet dis_wtsp_msg_admin_dash(string app_id)
    {
        SqlCommand cmd = new SqlCommand();
        cmd.CommandText = "dis_wtsp_msg_admin_dash_sp";
        parameter param = new parameter();
        cmd.Parameters.Add(param.intparam("@app_id", app_id));
        return command.ExtQueryDS(cmd);
    }

    public static DataSet dis_wtsp_user_wallets(string app_id)
    {
        SqlCommand cmd = new SqlCommand();
        cmd.CommandText = "dis_wtsp_user_wallets_sp";
        parameter param = new parameter();
        cmd.Parameters.Add(param.intparam("@app_id", app_id));
        return command.ExtQueryDS(cmd);
    }

    public static DataSet sp_ins_wtsp_campaign(string app_id,string user_id,string remarks,string create_by)
    {
        SqlCommand cmd = new SqlCommand();
        cmd.CommandText = "sp_ins_wtsp_campaign";
        parameter param = new parameter();
        cmd.Parameters.Add(param.intparam("@app_id", app_id));
        cmd.Parameters.Add(param.intparam("@user_id", user_id));
        cmd.Parameters.Add(param.stringparam("@remarks", remarks));
        cmd.Parameters.Add(param.intparam("@create_by", create_by));
        return command.ExtQueryDS(cmd);
    }

    public static DataSet ins_bulk_wtsp_log(string app_id, string user_id, string idcard, string campaign_id)
    {
        SqlCommand cmd = new SqlCommand();
        cmd.CommandText = "ins_bulk_wtsp_log_sp";
        parameter param = new parameter();
        cmd.Parameters.Add(param.intparam("@app_id", app_id));
        cmd.Parameters.Add(param.intparam("@user_id", user_id));
        cmd.Parameters.Add(param.stringparam("@idcard", idcard));
        cmd.Parameters.Add(param.stringparam("@campaign_id", campaign_id));
        
        return command.ExtQueryDS(cmd);
    }

    public static DataSet dis_booth_list_for_send_bulk_sleep_wtsp(string app_id, string user_id, string type)
    {
        SqlCommand cmd = new SqlCommand();
        cmd.CommandText = "dis_booth_list_for_send_bulk_sleep_wtsp_sp";
        parameter param = new parameter();
        cmd.Parameters.Add(param.intparam("@app_id", app_id));
        cmd.Parameters.Add(param.intparam("@user_id", user_id));
        cmd.Parameters.Add(param.stringparam("@type", type));

        return command.ExtQueryDS(cmd);
    }


}