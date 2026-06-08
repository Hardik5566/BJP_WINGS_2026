using System;
using System.Collections.Generic;
using System.Data.SqlClient;
using System.Data;
using System.Linq;
using System.Web;

/// <summary>
/// Summary description for BAL_Rajkot
/// </summary>
public class BAL_Rajkot
{
    public BAL_Rajkot()
    {
        //
        // TODO: Add constructor logic here
        //
    }

    public static DataSet quick_search_from_all_rajkot_ward(string app_id, string search)
    {
        SqlCommand cmd = new SqlCommand();
        cmd.CommandText = "quick_search_from_all_rajkot_ward_sp";
        parameter param = new parameter();
        cmd.Parameters.Add(param.intparam("@app_id", app_id));
        cmd.Parameters.Add(param.stringparam("@search", search));
        return command.ExtQueryDS(cmd);
    }

    public static DataSet rajkot_master_admin_login(string mobile_no, string device_id)
    {
        SqlCommand cmd = new SqlCommand();
        cmd.CommandText = "rajkot_master_admin_login_sp";
        parameter param = new parameter();
        cmd.Parameters.Add(param.stringparam("@mobile_no", mobile_no));
        cmd.Parameters.Add(param.stringparam("@device_id", device_id));
        return command.ExtQueryDS(cmd);
    }

}