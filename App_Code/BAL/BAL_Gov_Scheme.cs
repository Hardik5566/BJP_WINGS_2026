using System;
using System.Collections.Generic;
using System.Data;
using System.Data.SqlClient;
using System.Linq;
using System.Web;

/// <summary>
/// Summary description for BAL_Gov_Scheme
/// </summary>
public class BAL_Gov_Scheme
{
    public BAL_Gov_Scheme()
    {
        //
        // TODO: Add constructor logic here
        //
    }


    public static DataSet dis_scheme_beneficiary_dash_sp(string app_id)
    {
        SqlCommand cmd = new SqlCommand();
        cmd.CommandText = "dis_scheme_beneficiary_dash_sp"; // અથવા તમારી પ્રોસિજરનું જે નામ હોય તે
        cmd.CommandType = CommandType.StoredProcedure;

        parameter param = new parameter();
        cmd.Parameters.Add(param.intparam("@app_id", app_id));

        return command.ExtQueryDS(cmd);
    }

    public static DataSet dis_booth_wise_beneficiary_dash_sp(string app_id)
    {
        SqlCommand cmd = new SqlCommand();
        cmd.CommandText = "dis_booth_wise_beneficiary_dash_sp";
        cmd.CommandType = CommandType.StoredProcedure;

        parameter param = new parameter();
        cmd.Parameters.Add(param.intparam("@app_id", app_id));

        return command.ExtQueryDS(cmd);
    }

    public static DataSet sel_scheme_beneficiary_by_booth_sp(string app_id, string booth_no)
    {
        SqlCommand cmd = new SqlCommand();
        cmd.CommandText = "sel_scheme_beneficiary_by_booth_sp";
        cmd.CommandType = CommandType.StoredProcedure;

        parameter param = new parameter();
        cmd.Parameters.Add(param.intparam("@app_id", app_id));
        cmd.Parameters.Add(param.stringparam("@booth_no", booth_no));

        return command.ExtQueryDS(cmd);
    }


    public static DataSet dis_address_wise_beneficiary_dash_sp(string app_id)
    {
        SqlCommand cmd = new SqlCommand();
        cmd.CommandText = "dis_address_wise_beneficiary_dash_sp";
        cmd.CommandType = CommandType.StoredProcedure;

        parameter param = new parameter();
        cmd.Parameters.Add(param.intparam("@app_id", app_id));

        return command.ExtQueryDS(cmd);
    }


    public static DataSet sel_scheme_beneficiary_by_address_sp(string app_id, string address_text)
    {
        SqlCommand cmd = new SqlCommand();
        cmd.CommandText = "sel_scheme_beneficiary_by_address_sp";
        cmd.CommandType = CommandType.StoredProcedure;

        parameter param = new parameter();
        cmd.Parameters.Add(param.intparam("@app_id", app_id));
        cmd.Parameters.Add(param.stringparam("@address_text", address_text));

        return command.ExtQueryDS(cmd);
    }

}