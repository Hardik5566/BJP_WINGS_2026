using System;
using System.Collections.Generic;
using System.Data.SqlClient;
using System.Data;
using System.Linq;
using System.Web;

/// <summary>
/// Summary description for BAL_Surname_Group
/// </summary>
public class BAL_Surname_Group
{
    public BAL_Surname_Group()
    {
    }

    public static DataSet ins_surname_group(
        string app_id,
        string user_id,
        string group_name,
        string seed_surname,
        string surname_list,
        string idcard_list,
        string create_by)
    {
        SqlCommand cmd = new SqlCommand();
        cmd.CommandText = "ins_surname_group_sp";
        parameter param = new parameter();
        cmd.Parameters.Add(param.intparam("@app_id", app_id));
        cmd.Parameters.Add(param.intparam("@user_id", user_id));
        cmd.Parameters.Add(param.stringparam("@group_name", group_name ?? string.Empty));
        cmd.Parameters.Add(param.stringparam("@seed_surname", seed_surname ?? string.Empty));
        cmd.Parameters.Add(param.stringparam("@surname_list", surname_list ?? string.Empty));
        cmd.Parameters.Add(param.stringparam("@idcard_list", idcard_list ?? string.Empty));
        cmd.Parameters.Add(param.intparam("@create_by", create_by ?? user_id));
        return command.ExtQueryDS(cmd);
    }

    public static DataSet insert_surname_group(string app_id, string user_id, string surname_list)
    {
        return ins_surname_group(app_id, user_id, string.Empty, string.Empty, surname_list, string.Empty, user_id);
    }

    public static DataSet upd_surname_group(
        string app_id,
        string user_id,
        string group_id,
        string group_name,
        string seed_surname,
        string surname_list,
        string idcard_list,
        string modify_by)
    {
        SqlCommand cmd = new SqlCommand();
        cmd.CommandText = "upd_surname_group_sp";
        parameter param = new parameter();
        cmd.Parameters.Add(param.intparam("@app_id", app_id));
        cmd.Parameters.Add(param.intparam("@user_id", user_id));
        cmd.Parameters.Add(param.intparam("@group_id", group_id));
        cmd.Parameters.Add(param.stringparam("@group_name", group_name ?? string.Empty));
        cmd.Parameters.Add(param.stringparam("@seed_surname", seed_surname ?? string.Empty));
        cmd.Parameters.Add(param.stringparam("@surname_list", surname_list ?? string.Empty));
        cmd.Parameters.Add(param.stringparam("@idcard_list", idcard_list ?? string.Empty));
        cmd.Parameters.Add(param.intparam("@modify_by", modify_by ?? user_id));
        return command.ExtQueryDS(cmd);
    }

    public static DataSet dis_my_surname_group(string app_id, string user_id)
    {
        SqlCommand cmd = new SqlCommand();
        cmd.CommandText = "dis_my_surname_group_sp";
        parameter param = new parameter();
        cmd.Parameters.Add(param.intparam("@app_id", app_id));
        cmd.Parameters.Add(param.intparam("@user_id", user_id));
        return command.ExtQueryDS(cmd);
    }

    public static DataSet dis_surname_group_wise_voter(string app_id, string user_id, string group_id)
    {
        SqlCommand cmd = new SqlCommand();
        cmd.CommandText = "dis_surname_group_wise_voter_sp";
        parameter param = new parameter();
        cmd.Parameters.Add(param.intparam("@app_id", app_id));
        cmd.Parameters.Add(param.intparam("@user_id", user_id));
        cmd.Parameters.Add(param.intparam("@group_id", group_id));
        return command.ExtQueryDS(cmd);
    }

    public static DataSet dlt_surname_group(string app_id, string user_id, string group_id, string delete_by)
    {
        SqlCommand cmd = new SqlCommand();
        cmd.CommandText = "dlt_surname_group_sp";
        parameter param = new parameter();
        cmd.Parameters.Add(param.intparam("@app_id", app_id));
        cmd.Parameters.Add(param.intparam("@user_id", user_id));
        cmd.Parameters.Add(param.intparam("@group_id", group_id));
        cmd.Parameters.Add(param.intparam("@delete_by", delete_by ?? user_id));
        return command.ExtQueryDS(cmd);
    }

    public static DataSet dis_surname_group_edit(string app_id, string user_id, string group_id)
    {
        SqlCommand cmd = new SqlCommand();
        cmd.CommandText = "dis_surname_group_edit_sp";
        parameter param = new parameter();
        cmd.Parameters.Add(param.intparam("@app_id", app_id));
        cmd.Parameters.Add(param.intparam("@user_id", user_id));
        cmd.Parameters.Add(param.intparam("@group_id", group_id));
        return command.ExtQueryDS(cmd);
    }

    public static DataSet display_surname_group_sp(string app_id, string user_id)
    {
        SqlCommand cmd = new SqlCommand();
        cmd.CommandText = "dis_surname_group_sp";
        parameter param = new parameter();
        cmd.Parameters.Add(param.intparam("@app_id", app_id));
        cmd.Parameters.Add(param.intparam("@user_id", user_id));
        return command.ExtQueryDS(cmd);
    }

    public static DataSet display_surname_match_admin(string app_id)
    {
        SqlCommand cmd = new SqlCommand();
        cmd.CommandText = "dis_surname_match_admin_sp";
        parameter param = new parameter();
        cmd.Parameters.Add(param.intparam("@app_id", app_id));
        return command.ExtQueryDS(cmd);
    }
}
