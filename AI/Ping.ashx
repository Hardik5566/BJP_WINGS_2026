<%@ WebHandler Language="C#" Class="PingHandler" %>

using System;
using System.Text;
using System.Web;

public class PingHandler : IHttpHandler
{
    public void ProcessRequest(HttpContext context)
    {
        context.Response.ContentType = "application/json; charset=utf-8";
        context.Response.ContentEncoding = Encoding.UTF8;
        context.Response.Write("{\"ok\":true,\"ts\":\"" + DateTime.UtcNow.ToString("o") + "\"}");
    }

    public bool IsReusable { get { return true; } }
}

