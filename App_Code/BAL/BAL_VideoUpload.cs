using System;
using System.Data;
using System.Data.SqlClient;

/// <summary>
/// File and video upload — save and display.
/// </summary>
public class BAL_VideoUpload
{
    public static DataSet ins_video_upload_sp(string app_id, string user_id, string video_path, string file_name, string file_ext, string file_type)
    {
        if (string.IsNullOrWhiteSpace(app_id))
            throw new ArgumentException("app_id is required");
        if (string.IsNullOrWhiteSpace(user_id))
            throw new ArgumentException("user_id is required");

        SqlCommand cmd = new SqlCommand();
        cmd.CommandText = "ins_video_upload_sp";
        cmd.CommandType = CommandType.StoredProcedure;

        parameter param = new parameter();
        cmd.Parameters.Add(param.stringparam("@video_path", video_path));
        cmd.Parameters.Add(param.stringparam("@file_name", file_name));
        cmd.Parameters.Add(param.stringparam("@file_ext", file_ext));
        cmd.Parameters.Add(param.stringparam("@file_type", file_type));

        return command.ExtQueryDS(cmd);
    }

    public static DataSet dis_all_video_sp()
    {
        SqlCommand cmd = new SqlCommand();
        cmd.CommandText = "dis_all_video_sp";
        cmd.CommandType = CommandType.StoredProcedure;

        return command.ExtQueryDS(cmd);
    }
}
