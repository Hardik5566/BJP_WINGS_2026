using System;
using System.Collections.Generic;
using System.Data.SqlClient;
using System.Data;
using System.Linq;
using System.Web;

/// <summary>
/// Summary description for BAL_Prachar_Setting
/// </summary>
public class BAL_Prachar_Setting
{
    public BAL_Prachar_Setting()
    {
        //
        // TODO: Add constructor logic here
        //
    }

    public static DataSet ins_prachar_master(
    string app_id,
    string prachar_type,
    string content,
    string create_by
)
    {
        SqlCommand cmd = new SqlCommand();
        cmd.CommandText = "ins_prachar_master_sp";

        parameter param = new parameter();
        cmd.Parameters.Add(param.intparam("@app_id", app_id));
        cmd.Parameters.Add(param.stringparam("@prachar_type", prachar_type));
        cmd.Parameters.Add(param.stringparam("@content", content));
        cmd.Parameters.Add(param.intparam("@create_by", create_by));

        return command.ExtQueryDS(cmd);
    }

    public static DataSet dis_prachar_master(
    string app_id,
    string prachar_type
)
    {
        SqlCommand cmd = new SqlCommand();
        cmd.CommandText = "dis_prachar_master_sp";

        parameter param = new parameter();
        cmd.Parameters.Add(param.intparam("@app_id", app_id));
        cmd.Parameters.Add(param.stringparam("@prachar_type", prachar_type));

        return command.ExtQueryDS(cmd);
    }


    public static DataSet del_prachar_master(
    string app_id,
    string id,
    string delete_by
)
    {
        SqlCommand cmd = new SqlCommand();
        cmd.CommandText = "del_prachar_master_sp";

        parameter param = new parameter();
        cmd.Parameters.Add(param.intparam("@app_id", app_id));
        cmd.Parameters.Add(param.intparam("@id", id));
        cmd.Parameters.Add(param.intparam("@delete_by", delete_by));

        return command.ExtQueryDS(cmd);
    }


}