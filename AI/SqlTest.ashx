<%@ WebHandler Language="C#" Class="SqlTestHandler" %>

using System;
using System.Configuration;
using System.Data.SqlClient;
using System.Text;
using System.Web;

/// <summary>
/// Admin: test SQL Server reachability for AI module. /AI/SqlTest.ashx?app_id=1
/// </summary>
public class SqlTestHandler : IHttpHandler
{
    public void ProcessRequest(HttpContext context)
    {
        context.Response.ContentType = "text/plain; charset=utf-8";
        context.Response.ContentEncoding = Encoding.UTF8;

        int appId = 1;
        int.TryParse(context.Request["app_id"], out appId);
        if (appId <= 0) appId = 1;

        context.Response.Write("Testing SQL for app_id=" + appId + "\n\n");

        string cs = ConfigurationManager.ConnectionStrings["myConnectionString"].ConnectionString;
        var builder = new SqlConnectionStringBuilder(cs)
        {
            ConnectTimeout = ElectionAIConfig.SqlConnectTimeoutSeconds
        };

        try
        {
            using (SqlConnection conn = new SqlConnection(builder.ConnectionString))
            {
                conn.Open();
                context.Response.Write("SQL CONNECT: OK\n");

                string sql = "SELECT COUNT(*) FROM ai_voter WITH (NOLOCK) WHERE app_id = @app_id";
                using (SqlCommand cmd = new SqlCommand(sql, conn))
                {
                    cmd.CommandTimeout = ElectionAIConfig.CommandTimeoutSeconds;
                    cmd.Parameters.AddWithValue("@app_id", appId);
                    object val = cmd.ExecuteScalar();
                    context.Response.Write("ai_voter count for app_id " + appId + ": " + val + "\n");
                    context.Response.Write("\nSUCCESS - database OK for Chat.\n");
                }
            }
        }
        catch (Exception ex)
        {
            context.Response.Write("FAILED:\n");
            context.Response.Write(ex.Message);
            context.Response.Write("\n\nFix: check myConnectionString in Web.config and that ai_voter view exists on server.\n");
        }
    }

    public bool IsReusable { get { return false; } }
}
