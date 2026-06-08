using System;
using System.Data;
using System.Data.SqlClient;

/// <summary>Business layer — live voting (bulk insert via TVP).</summary>
public class BAL_LiveVoting
{
    /// <summary>
    /// Calls dbo.ins_live_voting_bulk_sp. Pass a DataTable with columns app_id, part_no, slnoinpart (same as dbo.tt_live_voting_bulk).
    /// </summary>
    /// <param name="rows">One row per vote; null is treated as empty table.</param>
    /// <param name="created_by">Optional user id string; invalid / empty becomes NULL in SQL.</param>
    public static DataSet ins_live_voting_bulk_sp(DataTable rows, string created_by)
    {
        if (rows == null)
        {
            rows = new DataTable();
            rows.Columns.Add("app_id", typeof(int));
            rows.Columns.Add("part_no", typeof(int));
            rows.Columns.Add("slnoinpart", typeof(int));
        }

        SqlCommand cmd = new SqlCommand();
        cmd.CommandText = "ins_live_voting_bulk_sp";

        parameter param = new parameter();
        cmd.Parameters.Add(param.TableParam("@rows", rows, "dbo.tt_live_voting_bulk"));
        cmd.Parameters.Add(param.intparam("@created_by", created_by ?? string.Empty));

        return command.ExtQueryDS(cmd);
    }

    public static DataSet get_LiveVoting_Dashboard_for_admin(string app_id, string user_id)
    {
        SqlCommand cmd = new SqlCommand();
        cmd.CommandText = "get_LiveVoting_Dashboard_for_admin_sp";

        parameter param = new parameter();
        cmd.Parameters.Add(param.intparam("@app_id", app_id));
        cmd.Parameters.Add(param.intparam("@user_id", user_id));

        return command.ExtQueryDS(cmd);
    }

    public static DataSet dis_booth_wise_voting_report(string app_id)
    {
        SqlCommand cmd = new SqlCommand();
        cmd.CommandText = "dis_booth_wise_voting_report_sp";

        parameter param = new parameter();
        cmd.Parameters.Add(param.intparam("@app_id", app_id));

        return command.ExtQueryDS(cmd);
    }

    public static DataSet dis_polling_location_wise_voting_report(string app_id)
    {
        SqlCommand cmd = new SqlCommand();
        cmd.CommandText = "dis_polling_location_wise_voting_report_sp";

        parameter param = new parameter();
        cmd.Parameters.Add(param.intparam("@app_id", app_id));

        return command.ExtQueryDS(cmd);
    }

    public static DataSet dis_phonebook_wise_voting_report(string app_id)
    {
        SqlCommand cmd = new SqlCommand();
        cmd.CommandText = "dis_phonebook_wise_voting_report_sp";

        parameter param = new parameter();
        cmd.Parameters.Add(param.intparam("@app_id", app_id));

        return command.ExtQueryDS(cmd);
    }

    public static DataSet dis_booth_wise_live_voting_voter(string app_id, string booth_no)
    {
        SqlCommand cmd = new SqlCommand();
        cmd.CommandText = "dis_booth_wise_live_voting_voter_sp";

        parameter param = new parameter();
        cmd.Parameters.Add(param.intparam("@app_id", app_id));
        cmd.Parameters.Add(param.intparam("@booth_no", booth_no));

        return command.ExtQueryDS(cmd);
    }

    public static DataSet dis_polling_location_wise_live_voting_voter(string app_id, string polling_location)
    {
        SqlCommand cmd = new SqlCommand();
        cmd.CommandText = "dis_polling_location_wise_live_voting_voter_sp";

        parameter param = new parameter();
        cmd.Parameters.Add(param.intparam("@app_id", app_id));
        cmd.Parameters.Add(param.stringparam("@polling_location", polling_location));

        return command.ExtQueryDS(cmd);
    }

    public static DataSet dis_phonebook_wise_live_voting_voter(string app_id, string user_id)
    {
        SqlCommand cmd = new SqlCommand();
        cmd.CommandText = "dis_phonebook_wise_live_voting_voter_sp";

        parameter param = new parameter();
        cmd.Parameters.Add(param.intparam("@app_id", app_id));
        cmd.Parameters.Add(param.intparam("@user_id", user_id));

        return command.ExtQueryDS(cmd);
    }
}
