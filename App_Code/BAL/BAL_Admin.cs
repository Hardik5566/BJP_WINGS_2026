using System;
using System.Collections.Generic;
using System.Data;
using System.Data.SqlClient;
using System.Linq;
using System.Web;

/// <summary>
/// Summary description for BAL_Admin
/// </summary>
public class BAL_Admin
{
    public BAL_Admin()
    {
        //
        // TODO: Add constructor logic here
        //
    }

    public static DataSet dis_all_app()
    {
        SqlCommand cmd = new SqlCommand();
        cmd.CommandText = "dis_all_app";
        return command.ExtQueryDS(cmd);
    }

    public static DataSet dis_all_rajkot_App()
    {
        SqlCommand cmd = new SqlCommand();
        cmd.CommandText = "dis_all_rajkot_App";
        return command.ExtQueryDS(cmd);
    }

    public static DataSet display_admin(string app_id)
    {
        SqlCommand cmd = new SqlCommand();
        cmd.CommandText = "dis_admin_sp";
        parameter param = new parameter();
        cmd.Parameters.Add(param.intparam("@app_id", app_id));
        return command.ExtQueryDS(cmd);
    }

    public static DataSet display_sub_admin(string app_id)
    {
        SqlCommand cmd = new SqlCommand();
        cmd.CommandText = "dis_sub_admin_sp";
        parameter param = new parameter();
        cmd.Parameters.Add(param.intparam("@app_id", app_id));
        return command.ExtQueryDS(cmd);
    }

    public static DataSet display_karyakarta(string app_id)
    {
        SqlCommand cmd = new SqlCommand();
        cmd.CommandText = "dis_karyakarta_sp";
        parameter param = new parameter();
        cmd.Parameters.Add(param.intparam("@app_id", app_id));
        return command.ExtQueryDS(cmd);
    }

    public static DataSet insert_user(string app_id, string name, string mobile_no, string user_type, string booth_no, string booth_list, string start_voter_no, string end_voter_no , string create_by)
    {
        SqlCommand cmd = new SqlCommand();
        cmd.CommandText = "ins_user_sp";

        parameter param = new parameter();
        cmd.Parameters.Add(param.intparam("@app_id", app_id));
        cmd.Parameters.Add(param.stringparam("@name", name));
        cmd.Parameters.Add(param.stringparam("@mobile_no", mobile_no));
        cmd.Parameters.Add(param.stringparam("@user_type", user_type));
        if (General_Class.is_int(booth_no))
        {
            cmd.Parameters.Add(param.intparam("@booth_no", booth_no));
        }
        
        cmd.Parameters.Add(param.stringparam("@booth_list", booth_list));
        if (General_Class.is_int(start_voter_no))
        {
            cmd.Parameters.Add(param.intparam("@start_voter_no", start_voter_no));
        }
        if (General_Class.is_int(end_voter_no))
        {
            cmd.Parameters.Add(param.intparam("@end_voter_no", end_voter_no));
        }
        if (General_Class.is_int(create_by))
        {
            cmd.Parameters.Add(param.intparam("@create_by", create_by));
        }

        return command.ExtQueryDS(cmd);
    }

    public static DataSet upd_user(string user_id, string app_id, string name, string mobile_no, string user_type, string booth_no, string booth_list, string start_voter_no, string end_voter_no, string modify_by)
    {
        SqlCommand cmd = new SqlCommand();
        cmd.CommandText = "upd_user_sp";

        parameter param = new parameter();
        cmd.Parameters.Add(param.intparam("@user_id", user_id));
        cmd.Parameters.Add(param.intparam("@app_id", app_id));
        cmd.Parameters.Add(param.stringparam("@name", name));
        cmd.Parameters.Add(param.stringparam("@mobile_no", mobile_no));
        cmd.Parameters.Add(param.stringparam("@user_type", user_type));
        if (General_Class.is_int(booth_no))
        {
            cmd.Parameters.Add(param.intparam("@booth_no", booth_no));
        }
        cmd.Parameters.Add(param.stringparam("@booth_list", booth_list));
        if (General_Class.is_int(start_voter_no))
        {
            cmd.Parameters.Add(param.intparam("@start_voter_no", start_voter_no));
        }
        if (General_Class.is_int(end_voter_no))
        {
            cmd.Parameters.Add(param.intparam("@end_voter_no", end_voter_no));
        }
        if (General_Class.is_int(modify_by))
        {
            cmd.Parameters.Add(param.intparam("@modify_by", modify_by));
        }

        return command.ExtQueryDS(cmd);
    }

    public static DataSet user_login(string mobile_no, string device_id)
    {
        SqlCommand cmd = new SqlCommand();
        cmd.CommandText = "user_login_sp";

        parameter param = new parameter();
        cmd.Parameters.Add(param.stringparam("@mobile_no", mobile_no));
        cmd.Parameters.Add(param.stringparam("@device_id", device_id));

        return command.ExtQueryDS(cmd);
    }


    public static DataSet dis_booth_pramukh_and_total_booth_list(string app_id)
    {
        SqlCommand cmd = new SqlCommand();
        cmd.CommandText = "dis_booth_pramukh_and_total_booth_list_sp";
        parameter param = new parameter();
        cmd.Parameters.Add(param.intparam("@app_id", app_id));
        return command.ExtQueryDS(cmd);
    }

    public static DataSet dis_booth_pramukh(string app_id)
    {
        SqlCommand cmd = new SqlCommand();
        cmd.CommandText = "dis_booth_pramukh_sp";
        parameter param = new parameter();
        cmd.Parameters.Add(param.intparam("@app_id", app_id));
        return command.ExtQueryDS(cmd);
    }

    public static DataSet dis_booth_captain(string app_id)
    {
        SqlCommand cmd = new SqlCommand();
        cmd.CommandText = "dis_booth_captain_sp";
        parameter param = new parameter();
        cmd.Parameters.Add(param.intparam("@app_id", app_id));
        return command.ExtQueryDS(cmd);
    }

    public static DataSet sel_user(string app_id,string user_id)
    {
        SqlCommand cmd = new SqlCommand();
        cmd.CommandText = "sel_user_sp";
        parameter param = new parameter();
        cmd.Parameters.Add(param.intparam("@app_id", app_id));
        cmd.Parameters.Add(param.intparam("@user_id", user_id));
        return command.ExtQueryDS(cmd);
    }

    public static DataSet dis_total_booth(string app_id)
    {
        SqlCommand cmd = new SqlCommand();
        cmd.CommandText = "dis_total_booth_sp";
        parameter param = new parameter();
        cmd.Parameters.Add(param.intparam("@app_id", app_id));
        return command.ExtQueryDS(cmd);
    }

    public static DataSet dis_saktikendra(string app_id)
    {
        SqlCommand cmd = new SqlCommand();
        cmd.CommandText = "dis_saktikendra_sp";
        parameter param = new parameter();
        cmd.Parameters.Add(param.intparam("@app_id", app_id));
        return command.ExtQueryDS(cmd);
    }

    public static DataSet dis_party_cadre_dash(string app_id)
    {
        SqlCommand cmd = new SqlCommand();
        cmd.CommandText = "dis_party_cadre_dash_sp";
        parameter param = new parameter();
        cmd.Parameters.Add(param.intparam("@app_id", app_id));
        return command.ExtQueryDS(cmd);
    }

    public static DataSet dis_personal_cadre_dash(string app_id)
    {
        SqlCommand cmd = new SqlCommand();
        cmd.CommandText = "dis_personal_cadre_dash_sp";
        parameter param = new parameter();
        cmd.Parameters.Add(param.intparam("@app_id", app_id));
        return command.ExtQueryDS(cmd);
    }

    public static DataSet dis_cadre_dash(string app_id, string user_id)
    {
        SqlCommand cmd = new SqlCommand();
        cmd.CommandText = "dis_cadre_dash_sp";
        parameter param = new parameter();
        cmd.Parameters.Add(param.intparam("@app_id", app_id));
        cmd.Parameters.Add(param.intparam("@user_id", user_id));
        return command.ExtQueryDS(cmd);
    }

    public static DataSet dis_war_pramukh(string app_id)
    {
        SqlCommand cmd = new SqlCommand();
        cmd.CommandText = "dis_war_pramukh_sp";
        parameter param = new parameter();
        cmd.Parameters.Add(param.intparam("@app_id", app_id));
        return command.ExtQueryDS(cmd);
    }

    public static DataSet dlt_user(string user_id, string delete_by)
    {
        SqlCommand cmd = new SqlCommand();
        cmd.CommandText = "dlt_user_sp";
        parameter param = new parameter();
        cmd.Parameters.Add(param.intparam("@user_id", user_id));
        cmd.Parameters.Add(param.intparam("@delete_by", delete_by));
        return command.ExtQueryDS(cmd);
    }

    public static DataSet dis_call_center_user(string app_id)
    {
        SqlCommand cmd = new SqlCommand();
        cmd.CommandText = "dis_call_center_user_sp";
        parameter param = new parameter();
        cmd.Parameters.Add(param.intparam("@app_id", app_id));
        return command.ExtQueryDS(cmd);
    }

    public static DataSet dis_booth_list_for_sakti_creation(string app_id,string type)
    {
        SqlCommand cmd = new SqlCommand();
        cmd.CommandText = "dis_booth_list_for_sakti_creation_sp";
        parameter param = new parameter();
        cmd.Parameters.Add(param.intparam("@app_id", app_id));
        cmd.Parameters.Add(param.stringparam("@user_type", type));
        return command.ExtQueryDS(cmd);
    }

    public static DataSet dis_booth_pramukh_cadre_with_voter(string app_id,string booth_no)
    {
        SqlCommand cmd = new SqlCommand();
        cmd.CommandText = "dis_booth_pramukh_cadre_with_voter_sp";
        parameter param = new parameter();
        cmd.Parameters.Add(param.intparam("@app_id", app_id));
        cmd.Parameters.Add(param.intparam("@booth_no", booth_no));
        return command.ExtQueryDS(cmd);
    }

    public static DataSet dis_booth_captain_cadre_with_voter(string app_id, string booth_no)
    {
        SqlCommand cmd = new SqlCommand();
        cmd.CommandText = "dis_booth_captain_cadre_with_voter_sp";
        parameter param = new parameter();
        cmd.Parameters.Add(param.intparam("@app_id", app_id));
        cmd.Parameters.Add(param.intparam("@booth_no", booth_no));
        return command.ExtQueryDS(cmd);
    }

    public static DataSet dis_booth_captain_cadre(string app_id, string booth_no)
    {
        SqlCommand cmd = new SqlCommand();
        cmd.CommandText = "dis_booth_captain_cadre_sp";
        parameter param = new parameter();
        cmd.Parameters.Add(param.intparam("@app_id", app_id));
        cmd.Parameters.Add(param.intparam("@booth_no", booth_no));
        return command.ExtQueryDS(cmd);
    }

    public static DataSet dis_booth_captain_voter(string app_id, string booth_no)
    {
        SqlCommand cmd = new SqlCommand();
        cmd.CommandText = "dis_booth_captain_voter_sp";
        parameter param = new parameter();
        cmd.Parameters.Add(param.intparam("@app_id", app_id));
        cmd.Parameters.Add(param.intparam("@booth_no", booth_no));
        return command.ExtQueryDS(cmd);
    }

    public static DataSet dis_booth_pramukh_cadre(string app_id, string booth_no)
    {
        SqlCommand cmd = new SqlCommand();
        cmd.CommandText = "dis_booth_pramukh_cadre_sp";
        parameter param = new parameter();
        cmd.Parameters.Add(param.intparam("@app_id", app_id));
        cmd.Parameters.Add(param.intparam("@booth_no", booth_no));
        return command.ExtQueryDS(cmd);
    }

    public static DataSet dis_voter_captain_voter(string app_id, string user_id)
    {
        SqlCommand cmd = new SqlCommand();
        cmd.CommandText = "dis_voter_captain_voter_sp";
        parameter param = new parameter();
        cmd.Parameters.Add(param.intparam("@app_id", app_id));
        cmd.Parameters.Add(param.intparam("@user_id", user_id));
        return command.ExtQueryDS(cmd);
    }



    public static DataSet dis_booth_pramukh_voter(string app_id, string booth_no)
    {
        SqlCommand cmd = new SqlCommand();
        cmd.CommandText = "dis_booth_pramukh_voter_sp";
        parameter param = new parameter();
        cmd.Parameters.Add(param.intparam("@app_id", app_id));
        cmd.Parameters.Add(param.intparam("@booth_no", booth_no));
        return command.ExtQueryDS(cmd);
    }

    public static DataSet dis_voter_capation_wise_voter(string app_id, string user_id)
    {
        SqlCommand cmd = new SqlCommand();
        cmd.CommandText = "dis_voter_capation_wise_voter_sp";
        parameter param = new parameter();
        cmd.Parameters.Add(param.intparam("@app_id", app_id));
        cmd.Parameters.Add(param.intparam("@user_id", user_id));
        return command.ExtQueryDS(cmd);
    }

    public static DataSet display_booth_pramukh_by_sakti_pramuk(string app_id, string user_id)
    {
        SqlCommand cmd = new SqlCommand();
        cmd.CommandText = "display_booth_pramukh_by_sakti_pramukh";
        parameter param = new parameter();
        cmd.Parameters.Add(param.intparam("@app_id", app_id));
        cmd.Parameters.Add(param.intparam("@user_id", user_id));
        return command.ExtQueryDS(cmd);
    }

    public static DataSet dis_all_user(string app_id)
    {
        SqlCommand cmd = new SqlCommand();
        cmd.CommandText = "dis_all_user_sp";
        parameter param = new parameter();
        cmd.Parameters.Add(param.intparam("@app_id", app_id));
        return command.ExtQueryDS(cmd);
    }

    public static DataSet dis_admin_dash(string app_id, string user_id)
    {
        SqlCommand cmd = new SqlCommand();
        cmd.CommandText = "dis_admin_dash_sp";
        parameter param = new parameter();
        cmd.Parameters.Add(param.intparam("@app_id", app_id));
        cmd.Parameters.Add(param.intparam("@user_id", user_id));
        return command.ExtQueryDS(cmd);
    }

    public static DataSet change_profile_photo(string user_id, string photo)
    {
        SqlCommand cmd = new SqlCommand();
        cmd.CommandText = "change_profile_photo_sp";
        parameter param = new parameter();
        cmd.Parameters.Add(param.intparam("@user_id", user_id));
        cmd.Parameters.Add(param.stringparam("@photo", photo));
        return command.ExtQueryDS(cmd);
    }

    public static DataSet user_login_for_splace(string app_id,string user_id, string device_id)
    {
        SqlCommand cmd = new SqlCommand();
        cmd.CommandText = "user_login_for_splace_sp";
        parameter param = new parameter();
        cmd.Parameters.Add(param.intparam("@app_id", app_id));
        cmd.Parameters.Add(param.intparam("@user_id", user_id));
        cmd.Parameters.Add(param.stringparam("@device_id", device_id));
        return command.ExtQueryDS(cmd);
    }

    public static DataSet dis_live_voting_user(string app_id)
    {
        SqlCommand cmd = new SqlCommand();
        cmd.CommandText = "dis_live_voting_user_sp";
        parameter param = new parameter();
        cmd.Parameters.Add(param.intparam("@app_id", app_id));
        return command.ExtQueryDS(cmd);
    }

    public static DataSet change_user_temp_status(string app_id,string user_id,string modify_by)
    {
        SqlCommand cmd = new SqlCommand();
        cmd.CommandText = "change_user_temp_status_sp";
        parameter param = new parameter();
        cmd.Parameters.Add(param.intparam("@app_id", app_id));
        cmd.Parameters.Add(param.intparam("@user_id", user_id));
        cmd.Parameters.Add(param.intparam("@modify_by", modify_by));
        return command.ExtQueryDS(cmd);
    }

    public static DataSet dis_star_karykarta(string app_id)
    {
        SqlCommand cmd = new SqlCommand();
        cmd.CommandText = "dis_star_karykarta_sp";
        parameter param = new parameter();
        cmd.Parameters.Add(param.intparam("@app_id", app_id));
        return command.ExtQueryDS(cmd);
    }

    public static DataSet view_star_karykarta_detail(string app_id,string user_id)
    {
        SqlCommand cmd = new SqlCommand();
        cmd.CommandText = "view_star_karykarta_detail_sp";
        parameter param = new parameter();
        cmd.Parameters.Add(param.intparam("@app_id", app_id));
        cmd.Parameters.Add(param.intparam("@user_id", user_id));
        return command.ExtQueryDS(cmd);
    }


    public static DataSet dis_booth_pramukh_by_sakti_pramukh(string app_id, string user_id)
    {
        SqlCommand cmd = new SqlCommand();
        cmd.CommandText = "dis_booth_pramukh_by_sakti_pramukh_sp";
        parameter param = new parameter();
        cmd.Parameters.Add(param.intparam("@app_id", app_id));
        cmd.Parameters.Add(param.intparam("@user_id", user_id));
        return command.ExtQueryDS(cmd);
    }

    public static DataSet dis_booth_captain_by_warroom_pramukh(string app_id, string user_id)
    {
        SqlCommand cmd = new SqlCommand();
        cmd.CommandText = "dis_booth_captain_by_warroom_pramukh_sp";
        parameter param = new parameter();
        cmd.Parameters.Add(param.intparam("@app_id", app_id));
        cmd.Parameters.Add(param.intparam("@user_id", user_id));
        return command.ExtQueryDS(cmd);
    }
    public static DataSet ins_offline_user(string app_id, string user_id)
    {
        SqlCommand cmd = new SqlCommand();
        cmd.CommandText = "ins_offline_user_sp";
        parameter param = new parameter();
        cmd.Parameters.Add(param.intparam("@app_id", app_id));
        cmd.Parameters.Add(param.intparam("@user_id", user_id));
        return command.ExtQueryDS(cmd);
    }

    public static DataSet offline_syc_complete(string syc_id)
    {
        SqlCommand cmd = new SqlCommand();
        cmd.CommandText = "offline_syc_complete_sp";
        parameter param = new parameter();
        cmd.Parameters.Add(param.intparam("@syc_id", syc_id));
        return command.ExtQueryDS(cmd);
    }

}
