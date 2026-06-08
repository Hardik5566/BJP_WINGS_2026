using System;
using System.Collections.Generic;
using System.Data;
using Newtonsoft.Json;

/// <summary>
/// Response models for AskElectionAI API.
/// </summary>
public class ElectionAIResponse
{
    public string status { get; set; }
    public string message { get; set; }
    public string error_type { get; set; }
    public string detail { get; set; }
    public string sql { get; set; }
    public int row_count { get; set; }
    public List<string> columns { get; set; }
    public List<List<object>> rows { get; set; }

    public static ElectionAIResponse Ok(DataTable dt, string sql)
    {
        var res = new ElectionAIResponse
        {
            status = "1",
            message = "OK",
            sql = sql,
            row_count = dt != null ? dt.Rows.Count : 0,
            columns = new List<string>(),
            rows = new List<List<object>>()
        };

        if (dt == null) return res;

        foreach (DataColumn col in dt.Columns)
            res.columns.Add(col.ColumnName);

        foreach (DataRow row in dt.Rows)
        {
            var line = new List<object>();
            foreach (DataColumn col in dt.Columns)
            {
                object val = row[col];
                line.Add(val == DBNull.Value ? null : val);
            }
            res.rows.Add(line);
        }

        return res;
    }

    public static ElectionAIResponse Fail(string message, string sql)
    {
        return Fail(message, sql, null, null);
    }

    public static ElectionAIResponse Fail(string message, string sql, string errorType, string detail)
    {
        return new ElectionAIResponse
        {
            status = "0",
            message = message ?? "Error",
            error_type = errorType ?? "",
            detail = detail ?? "",
            sql = sql ?? "",
            row_count = 0,
            columns = new List<string>(),
            rows = new List<List<object>>()
        };
    }

    public string ToJson()
    {
        return JsonConvert.SerializeObject(this);
    }

    public static string ToJsonFail(string message)
    {
        return JsonConvert.SerializeObject(Fail(message, ""));
    }

    public static string ToJsonFail(string message, string errorType, string detail)
    {
        return JsonConvert.SerializeObject(Fail(message, "", errorType, detail));
    }
}
