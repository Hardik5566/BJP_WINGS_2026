using System;
using System.Collections.Generic;
using System.Linq;
using System.Web;
using System.Web.UI;
using System.Web.UI.WebControls;

public partial class app : System.Web.UI.Page
{
    protected void Page_Load(object sender, EventArgs e)
    {

    }

    protected void btnDownload_Click(object sender, EventArgs e)
    {
        // ── PASTE YOUR EXISTING C# DOWNLOAD CODE BELOW ──
        // Example structure (replace with your actual code):

        string filePath = Server.MapPath("~/apk/BJP2026.apk");
        string fileName = "BJP2026.apk";

        Response.Clear();
        Response.ContentType = "application/vnd.android.package-archive";
        Response.AddHeader("Content-Disposition", "attachment; filename=" + fileName);
        Response.AddHeader("Content-Length", new System.IO.FileInfo(filePath).Length.ToString());
        Response.Flush();
        Response.TransmitFile(filePath);
        Response.End();
    }
}