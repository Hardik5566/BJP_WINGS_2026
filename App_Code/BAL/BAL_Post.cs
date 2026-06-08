using System;
using System.Collections.Generic;
using System.Data.SqlClient;
using System.Data;
using System.Linq;
using System.Web;

/// <summary>
/// Summary description for BAL_Post
/// </summary>
public class BAL_Post
{
    public BAL_Post()
    {
        //
        // TODO: Add constructor logic here
        //
    }

    public static DataSet ins_post_sp(string app_id, string userId, string content, DataTable mediaList)
    {
        SqlCommand cmd = new SqlCommand();
        cmd.CommandText = "ins_post_sp";
        cmd.CommandType = CommandType.StoredProcedure;

        parameter param = new parameter();
        cmd.Parameters.Add(param.intparam("@app_id", app_id));
        cmd.Parameters.Add(param.intparam("@UserId", userId));
        cmd.Parameters.Add(param.stringparam("@Content", content));
        cmd.Parameters.Add(param.TableParam("@MediaList", mediaList, "dbo.MediaTypeTable"));

        return command.ExtQueryDS(cmd);
    }

    public static DataSet upd_post_sp(string userId, string postId, string content, DataTable mediaList)
    {
        SqlCommand cmd = new SqlCommand();
        cmd.CommandText = "upd_post_sp";
        cmd.CommandType = CommandType.StoredProcedure;

        parameter param = new parameter(); // Your helper class for SqlParameter

        // Add parameters exactly like your style
        cmd.Parameters.Add(param.intparam("@UserId", userId));
        cmd.Parameters.Add(param.intparam("@PostId", postId));
        cmd.Parameters.Add(param.stringparam("@Content", content));
        cmd.Parameters.Add(param.TableParam("@MediaList", mediaList, "dbo.MediaTypeTable"));

        // Execute stored procedure and return DataSet
        return command.ExtQueryDS(cmd);
    }

    public static DataSet dlt_post_sp(string userId, string postId)
    {
        SqlCommand cmd = new SqlCommand();
        cmd.CommandText = "dlt_post_sp";
        cmd.CommandType = CommandType.StoredProcedure;

        parameter param = new parameter(); // Your helper class for SqlParameter

        // Add parameters exactly like your style
        cmd.Parameters.Add(param.intparam("@UserId", userId));
        cmd.Parameters.Add(param.intparam("@PostId", postId));

        // Execute stored procedure and return DataSet
        return command.ExtQueryDS(cmd);
    }

    public static DataSet sel_post_by_id_sp(string postId)
    {
        SqlCommand cmd = new SqlCommand();
        cmd.CommandText = "sel_post_by_id_sp";
        cmd.CommandType = CommandType.StoredProcedure;

        parameter param = new parameter(); // Your helper class for SqlParameter

        // Add parameter
        cmd.Parameters.Add(param.intparam("@PostId", postId));

        // Execute and return DataSet
        return command.ExtQueryDS(cmd);
    }

    public static DataSet dis_post_sp(string app_id, string currentUserId, string offset, string fetch)
    {
        SqlCommand cmd = new SqlCommand();
        cmd.CommandText = "dis_post_sp";
        cmd.CommandType = CommandType.StoredProcedure;

        parameter param = new parameter(); // Your helper class for SqlParameter

        // Add parameters
        cmd.Parameters.Add(param.intparam("@app_id", app_id));
        cmd.Parameters.Add(param.intparam("@CurrentUserId", currentUserId));
        cmd.Parameters.Add(param.intparam("@Offset", offset));
        cmd.Parameters.Add(param.intparam("@Fetch", fetch));

        // Execute stored procedure and return DataSet
        return command.ExtQueryDS(cmd);
    }


    public static DataSet dis_post_timeline_sp(string app_id, string userId, string offset, string fetch)
    {
        SqlCommand cmd = new SqlCommand();
        cmd.CommandText = "dis_post_timeline_sp";
        cmd.CommandType = CommandType.StoredProcedure;

        parameter param = new parameter(); // Your helper class for SqlParameter

        // Add parameters
        cmd.Parameters.Add(param.intparam("@app_id", app_id));
        cmd.Parameters.Add(param.intparam("@UserId", userId));
        cmd.Parameters.Add(param.intparam("@Offset", offset));
        cmd.Parameters.Add(param.intparam("@Fetch", fetch));

        // Execute stored procedure and return DataSet
        return command.ExtQueryDS(cmd);
    }


    public static DataSet dlt_post_media(string media_id)
    {
        SqlCommand cmd = new SqlCommand();
        cmd.CommandText = "dlt_post_media_sp";
        cmd.CommandType = CommandType.StoredProcedure;

        parameter param = new parameter(); // Your helper class for SqlParameter

        // Add parameters
        cmd.Parameters.Add(param.intparam("@media_id", media_id));

        // Execute stored procedure and return DataSet
        return command.ExtQueryDS(cmd);
    }

}