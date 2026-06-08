using System;
using System.Collections.Generic;
using System.Data.SqlClient;
using System.Data;
using System.Linq;
using System.Web;

/// <summary>
/// Summary description for BAL_Phonebook
/// </summary>
public class BAL_Phonebook
{
    public BAL_Phonebook()
    {
        //
        // TODO: Add constructor logic here
        //
    }

    public static DataSet add_contact_group_member(string app_id, string user_id,string contact_no_list)
    {
        SqlCommand cmd = new SqlCommand();
        cmd.CommandText = "add_contact_group_member_sp";
        cmd.CommandTimeout = 120;
        parameter param = new parameter();
        cmd.Parameters.Add(param.intparam("@app_id", app_id));
        cmd.Parameters.Add(param.intparam("@user_id", user_id));
        cmd.Parameters.Add(param.stringparam("@string", contact_no_list));
        return command.ExtQueryDS(cmd);
    }

    public static DataSet dis_all_contact_match_admin(string app_id)
    {
        SqlCommand cmd = new SqlCommand();
        cmd.CommandText = "dis_all_contact_match_admin_sp";
        parameter param = new parameter();
        cmd.Parameters.Add(param.intparam("@app_id", app_id));
        return command.ExtQueryDS(cmd);
    }

    public static DataSet dis_contact_group_member(string app_id,string user_id)
    {
        SqlCommand cmd = new SqlCommand();
        cmd.CommandText = "dis_contact_group_member_sp";
        parameter param = new parameter();
        cmd.Parameters.Add(param.intparam("@app_id", app_id));
        cmd.Parameters.Add(param.intparam("@user_id", user_id));
        return command.ExtQueryDS(cmd);
    }

    public static DataSet dis_no_phonebook_match_user(string app_id)
    {
        SqlCommand cmd = new SqlCommand();
        cmd.CommandText = "dis_no_phonebook_match_user_sp";
        parameter param = new parameter();
        cmd.Parameters.Add(param.intparam("@app_id", app_id));
        return command.ExtQueryDS(cmd);
    }

    public static DataSet dis_booth_wise_phonebook(string app_id)
    {
        SqlCommand cmd = new SqlCommand();
        cmd.CommandText = "dis_booth_wise_phonebook_sp";
        parameter param = new parameter();
        cmd.Parameters.Add(param.intparam("@app_id", app_id));
        return command.ExtQueryDS(cmd);
    }

    public static DataSet dis_booth_wise_phonebook_member(string app_id,string booth_no)
    {
        SqlCommand cmd = new SqlCommand();
        cmd.CommandText = "dis_booth_wise_phonebook_member_sp";
        parameter param = new parameter();
        cmd.Parameters.Add(param.intparam("@app_id", app_id));
        cmd.Parameters.Add(param.intparam("@booth_no", booth_no));
        return command.ExtQueryDS(cmd);
    }
}