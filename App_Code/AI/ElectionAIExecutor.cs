using System;
using System.Configuration;
using System.Data;
using System.Data.SqlClient;

/// <summary>
/// Executes validated AI SQL against SQL Server (short timeouts for chat UI).
/// </summary>
public static class ElectionAIExecutor
{
    public static DataTable Execute(string sql, int appId)
    {
        sql = ElectionAISqlValidator.Normalize(sql);
        ElectionAISqlValidator.Validate(sql, appId);

        using (SqlConnection conn = OpenAiConnection())
        using (SqlCommand cmd = new SqlCommand(sql, conn))
        {
            cmd.CommandTimeout = ElectionAIConfig.CommandTimeoutSeconds;
            cmd.Parameters.Add(new SqlParameter("@app_id", SqlDbType.Int) { Value = appId });

            using (SqlDataAdapter da = new SqlDataAdapter(cmd))
            {
                DataTable dt = new DataTable();
                da.Fill(dt);
                return dt;
            }
        }
    }

    private static SqlConnection OpenAiConnection()
    {
        string cs = ConfigurationManager.ConnectionStrings["myConnectionString"].ConnectionString;
        var builder = new SqlConnectionStringBuilder(cs)
        {
            ConnectTimeout = ElectionAIConfig.SqlConnectTimeoutSeconds
        };
        return new SqlConnection(builder.ConnectionString);
    }
}
