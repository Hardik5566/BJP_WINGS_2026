<%@ WebHandler Language="C#" Class="GroupChatHandler" %>

using System;
using System.Data;
using System.Text;
using System.Web;
using System.Web.Script.Serialization;

/// <summary>
/// JSON API for group chat — messages, send, delete, users/members.
/// POST: action, app_id, user_id, ...
/// </summary>
public class GroupChatHandler : IHttpHandler
{
    public void ProcessRequest(HttpContext context)
    {
        context.Response.ContentType = "application/json; charset=utf-8";
        context.Response.ContentEncoding = Encoding.UTF8;
        context.Response.HeaderEncoding = Encoding.UTF8;
        context.Response.Charset = "utf-8";
        context.Request.ContentEncoding = Encoding.UTF8;
        context.Response.Cache.SetCacheability(HttpCacheability.NoCache);

        var js = new JavaScriptSerializer { MaxJsonLength = int.MaxValue };

        if (!string.Equals(context.Request.HttpMethod, "POST", StringComparison.OrdinalIgnoreCase))
        {
            context.Response.StatusCode = 405;
            context.Response.Write(js.Serialize(new { Success = "0", message = "POST required." }));
            return;
        }

        try
        {
            string action = GetParam(context, "action").ToLowerInvariant();
            string appId = GetParam(context, "app_id");
            string userId = GetParam(context, "user_id");

            switch (action)
            {
                case "messages":
                    WriteJson(context, js, GetMessages(appId, context));
                    break;
                case "send":
                    WriteJson(context, js, SendMessage(appId, userId, context));
                    break;
                case "delete":
                    WriteJson(context, js, DeleteMessage(appId, userId, context));
                    break;
                case "users":
                case "members":
                    WriteJson(context, js, GetUsers(appId, action == "users"));
                    break;
                default:
                    context.Response.Write(js.Serialize(new { Success = "0", message = "Invalid action." }));
                    break;
            }
        }
        catch (Exception ex)
        {
            context.Response.StatusCode = 500;
            context.Response.Write(js.Serialize(new { Success = "0", message = ex.Message }));
        }
    }

    private static string GetParam(HttpContext context, string key)
    {
        return (context.Request.Form[key] ?? context.Request[key] ?? "").Trim();
    }

    private static void WriteJson(HttpContext context, JavaScriptSerializer js, object data)
    {
        context.Response.Write(js.Serialize(data));
    }

    private static object GetMessages(string appId, HttpContext context)
    {
        if (!IsValidId(appId))
            return Fail("Invalid app_id.");

        string after = GetParam(context, "after_msg_id");
        string before = GetParam(context, "before_msg_id");
        string limit = GetParam(context, "limit");
        if (string.IsNullOrEmpty(limit)) limit = "50";

        DataSet ds = BAL_GroupChat.dis_group_chat_messages_sp(appId, after, before, limit);
        return new
        {
            Success = "1",
            messages = TableToList(ds, 0)
        };
    }

    private static object SendMessage(string appId, string userId, HttpContext context)
    {
        if (!IsValidId(appId) || !IsValidId(userId))
            return Fail("Invalid app_id or user_id.");

        string msgType = GetParam(context, "msg_type");
        if (string.IsNullOrEmpty(msgType)) msgType = "TEXT";

        DataSet ds = BAL_GroupChat.ins_group_chat_message_sp(
            appId,
            userId,
            msgType,
            GetParam(context, "message_text"),
            GetParam(context, "file_path"),
            GetParam(context, "file_name"),
            GetParam(context, "file_ext"),
            GetParam(context, "file_size"),
            GetParam(context, "file_type"),
            GetParam(context, "reply_to_msg_id"));

        if (ds.Tables.Count == 0 || ds.Tables[0].Rows.Count == 0)
            return Fail("Send failed.");

        DataRow status = ds.Tables[0].Rows[0];
        string code = status.Table.Columns.Contains("SuccessCode")
            ? status["SuccessCode"].ToString()
            : "0";

        if (code != "1")
        {
            return new
            {
                Success = "0",
                message = status.Table.Columns.Contains("Msg") ? status["Msg"].ToString() : "Send failed."
            };
        }

        object message = null;
        if (ds.Tables.Count > 1 && ds.Tables[1].Rows.Count > 0)
            message = RowToDict(ds.Tables[1].Rows[0]);

        return new { Success = "1", message = message };
    }

    private static object DeleteMessage(string appId, string userId, HttpContext context)
    {
        if (!IsValidId(appId) || !IsValidId(userId))
            return Fail("Invalid app_id or user_id.");

        string messageId = GetParam(context, "message_id");
        if (string.IsNullOrEmpty(messageId))
            return Fail("message_id required.");

        DataSet ds = BAL_GroupChat.del_group_chat_message_sp(messageId, appId, userId);
        if (ds.Tables.Count == 0 || ds.Tables[0].Rows.Count == 0)
            return Fail("Delete failed.");

        DataRow row = ds.Tables[0].Rows[0];
        string code = row.Table.Columns.Contains("SuccessCode") ? row["SuccessCode"].ToString() : "0";
        if (code != "1")
        {
            return new
            {
                Success = "0",
                message = row.Table.Columns.Contains("Msg") ? row["Msg"].ToString() : "Delete failed."
            };
        }

        return new { Success = "1", message = row.Table.Columns.Contains("Msg") ? row["Msg"].ToString() : "Deleted." };
    }

    /// <summary>Load active users via BAL_Admin.dis_all_user (dis_all_user_sp).</summary>
    private static object GetUsers(string appId, bool asUsersKey)
    {
        if (!IsValidId(appId))
            return Fail("Invalid app_id.");

        DataSet ds = BAL_Admin.dis_all_user(appId);
        var list = TableToList(ds, 0);

        if (asUsersKey)
            return new { Success = "1", users = list };

        return new { Success = "1", members = list };
    }

    private static bool IsValidId(string value)
    {
        int id;
        return int.TryParse(value, out id) && id > 0;
    }

    private static object Fail(string msg)
    {
        return new { Success = "0", message = msg };
    }

    private static System.Collections.Generic.List<System.Collections.Generic.Dictionary<string, object>> TableToList(DataSet ds, int tableIndex)
    {
        var list = new System.Collections.Generic.List<System.Collections.Generic.Dictionary<string, object>>();
        if (ds == null || ds.Tables.Count <= tableIndex) return list;

        foreach (DataRow row in ds.Tables[tableIndex].Rows)
            list.Add(RowToDict(row));

        return list;
    }

    private static System.Collections.Generic.Dictionary<string, object> RowToDict(DataRow row)
    {
        var dict = new System.Collections.Generic.Dictionary<string, object>();
        foreach (DataColumn col in row.Table.Columns)
        {
            object val = row[col];
            if (val == DBNull.Value)
                dict[col.ColumnName] = null;
            else if (val is DateTime)
                dict[col.ColumnName] = ((DateTime)val).ToString("yyyy-MM-ddTHH:mm:ss");
            else
                dict[col.ColumnName] = val;
        }
        return dict;
    }

    public bool IsReusable { get { return false; } }
}
