using System;
using System.Data;
using System.Data.SqlClient;

/// <summary>Business layer — fixed group chat (tbl_group_chat_message).</summary>
public class BAL_GroupChat
{
    public static DataSet ins_group_chat_message_sp(
        string app_id,
        string sender_user_id,
        string msg_type,
        string message_text,
        string file_path,
        string file_name,
        string file_ext,
        string file_size,
        string file_type,
        string reply_to_msg_id)
    {
        SqlCommand cmd = new SqlCommand();
        cmd.CommandText = "ins_group_chat_message_sp";

        parameter param = new parameter();
        cmd.Parameters.Add(param.intparam("@app_id", app_id));
        cmd.Parameters.Add(param.intparam("@sender_user_id", sender_user_id));
        cmd.Parameters.Add(param.stringparam("@msg_type", msg_type));
        cmd.Parameters.Add(param.stringparam("@message_text", message_text));
        cmd.Parameters.Add(param.stringparam("@file_path", file_path));
        cmd.Parameters.Add(param.stringparam("@file_name", file_name));
        cmd.Parameters.Add(param.stringparam("@file_ext", file_ext));
        cmd.Parameters.Add(param.bigintparam("@file_size", file_size));
        cmd.Parameters.Add(param.stringparam("@file_type", file_type));
        cmd.Parameters.Add(param.bigintparam("@reply_to_msg_id", reply_to_msg_id));

        return command.ExtQueryDS(cmd);
    }

    public static DataSet dis_group_chat_messages_sp(
        string app_id,
        string after_msg_id,
        string before_msg_id,
        string limit)
    {
        SqlCommand cmd = new SqlCommand();
        cmd.CommandText = "dis_group_chat_messages_sp";

        parameter param = new parameter();
        cmd.Parameters.Add(param.intparam("@app_id", app_id));
        cmd.Parameters.Add(param.bigintparam("@after_msg_id", after_msg_id));
        cmd.Parameters.Add(param.bigintparam("@before_msg_id", before_msg_id));
        cmd.Parameters.Add(param.intparam("@limit", limit));

        return command.ExtQueryDS(cmd);
    }

    public static DataSet del_group_chat_message_sp(string message_id, string app_id, string delete_by)
    {
        SqlCommand cmd = new SqlCommand();
        cmd.CommandText = "del_group_chat_message_sp";

        parameter param = new parameter();
        cmd.Parameters.Add(param.bigintparam("@message_id", message_id));
        cmd.Parameters.Add(param.intparam("@app_id", app_id));
        cmd.Parameters.Add(param.intparam("@delete_by", delete_by));

        return command.ExtQueryDS(cmd);
    }

    public static DataSet dis_group_chat_user_list_sp(string app_id)
    {
        SqlCommand cmd = new SqlCommand();
        cmd.CommandText = "dis_group_chat_user_list_sp";

        parameter param = new parameter();
        cmd.Parameters.Add(param.intparam("@app_id", app_id));

        return command.ExtQueryDS(cmd);
    }

    public static DataSet dis_group_chat_message_count_sp(string app_id, string after_msg_id)
    {
        SqlCommand cmd = new SqlCommand();
        cmd.CommandText = "dis_group_chat_message_count_sp";

        parameter param = new parameter();
        cmd.Parameters.Add(param.intparam("@app_id", app_id));
        cmd.Parameters.Add(param.bigintparam("@after_msg_id", after_msg_id));

        return command.ExtQueryDS(cmd);
    }
}
