using System;
using System.Collections.Generic;
using System.Data.SqlClient;
using System.Data;
using System.Linq;
using System.Web;

/// <summary>
/// Summary description for BAL_My_Voter
/// </summary>
public class BAL_My_Voter
{
    public BAL_My_Voter()
    {
        //
        // TODO: Add constructor logic here
        //
    }

    public static DataSet ins_my_group(string app_id, string user_id,string idcard)
    {
        SqlCommand cmd = new SqlCommand();
        cmd.CommandText = "ins_my_group_sp";
        parameter param = new parameter();
        cmd.Parameters.Add(param.intparam("@app_id", app_id));
        cmd.Parameters.Add(param.intparam("@user_id", user_id));
        cmd.Parameters.Add(param.stringparam("@idcard", idcard));
        return command.ExtQueryDS(cmd);
    }

    public static DataSet dis_my_group_member(string app_id, string user_id)
    {
        SqlCommand cmd = new SqlCommand();
        cmd.CommandText = "dis_my_group_member_sp";
        parameter param = new parameter();
        cmd.Parameters.Add(param.intparam("@app_id", app_id));
        cmd.Parameters.Add(param.intparam("@user_id", user_id));
        return command.ExtQueryDS(cmd);
    }

    public static DataSet del_my_group_member(string id)
    {
        SqlCommand cmd = new SqlCommand();
        cmd.CommandText = "del_my_group_member_sp";
        parameter param = new parameter();
        cmd.Parameters.Add(param.intparam("@id", id));
        return command.ExtQueryDS(cmd);
    }

    public static DataSet dis_user_list_by_create_group(string app_id)
    {
        SqlCommand cmd = new SqlCommand();
        cmd.CommandText = "dis_user_list_by_create_group_sp";
        parameter param = new parameter();
        cmd.Parameters.Add(param.intparam("@app_id", app_id));
        return command.ExtQueryDS(cmd);
    }
}