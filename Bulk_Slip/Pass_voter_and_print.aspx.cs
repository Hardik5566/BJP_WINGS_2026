using Newtonsoft.Json.Linq;
using System;
using System.Collections.Generic;
using System.Data;
using System.IO;
using System.Linq;
using System.Text;
using System.Web;
using System.Web.UI;
using System.Web.UI.WebControls;

public partial class Bulk_Slip_Pass_voter_and_print : System.Web.UI.Page
{
    //protected void Page_Load(object sender, EventArgs e)
    //{
    //    try
    //    {
    //        string jsonData = Request.Form["voters"];

    //        if (!string.IsNullOrEmpty(jsonData))
    //        {
    //            // ✅ Decode (IMPORTANT for Android)
    //            jsonData = HttpUtility.UrlDecode(jsonData);

    //            StringBuilder sb = new StringBuilder();

    //            jsonData = jsonData.Trim();

    //            // ✅ Handle ARRAY
    //            if (jsonData.StartsWith("["))
    //            {
    //                JArray arr = JArray.Parse(jsonData);

    //                foreach (JObject item in arr)
    //                {
    //                    sb.Append("<div style='border:1px solid #ccc;padding:10px;margin:10px;'>");

    //                    foreach (var prop in item.Properties())
    //                    {
    //                        sb.Append("<b>" + prop.Name + ":</b> " + prop.Value + "<br/>");
    //                    }

    //                    sb.Append("</div>");
    //                }
    //            }
    //            // ✅ Handle OBJECT
    //            else if (jsonData.StartsWith("{"))
    //            {
    //                JObject obj = JObject.Parse(jsonData);

    //                sb.Append("<div style='border:1px solid #ccc;padding:10px;margin:10px;'>");

    //                foreach (var prop in obj.Properties())
    //                {
    //                    sb.Append("<b>" + prop.Name + ":</b> " + prop.Value + "<br/>");
    //                }

    //                sb.Append("</div>");
    //            }

    //            // ✅ SHOW IN ASPX UI
    //            litData.Text = sb.ToString();
    //        }
    //        else
    //        {
    //            litData.Text = "<b>No data received</b>";
    //        }
    //    }
    //    catch (Exception ex)
    //    {
    //        litData.Text = "<b>Error:</b> " + ex.Message;
    //    }
    //}

    protected void Page_Load(object sender, EventArgs e)
    {
        string logPath = Server.MapPath("~/log.txt");
        string jsonData = "";
        string raw = "";

        try
        {
            // FIRST TIME LOAD (POST)
            if (!IsPostBack)
            {
                using (var reader = new StreamReader(Request.InputStream))
                {
                    raw = reader.ReadToEnd();
                }

                // LOG RAW DATA
                File.AppendAllText(logPath, "\n\n----- RAW DATA -----\n" + raw);

                if (!string.IsNullOrEmpty(raw))
                {
                    // Case 1: voters= JSON string (form-style POST)
                    if (raw.StartsWith("voters="))
                    {
                        jsonData = HttpUtility.UrlDecode(raw.Substring(7));
                        File.AppendAllText(logPath, "\n\n----- JSON DATA (form-style) -----\n" + jsonData);
                        ViewState["json"] = jsonData;
                    }
                    else
                    {
                        // Case 2: proper JSON {"voters":[...]} (JSON-style POST)
                        JObject obj = JObject.Parse(raw);

                        if (obj["voters"] != null)
                        {
                            JArray arr = (JArray)obj["voters"];
                            jsonData = arr.ToString();
                            File.AppendAllText(logPath, "\n\n----- JSON DATA (json-style) -----\n" + jsonData);
                            ViewState["json"] = jsonData;
                        }
                        else
                        {
                            File.AppendAllText(logPath, "\n\n----- NO voters KEY FOUND IN JSON -----\n");
                        }
                    }
                }
                else
                {
                    File.AppendAllText(logPath, "\n\n----- RAW DATA EMPTY -----\n");
                }
            }
            else
            {
                // POSTBACK: retrieve from ViewState
                jsonData = ViewState["json"] as string;
                File.AppendAllText(logPath, "\n\n----- POSTBACK VIEWSTATE DATA -----\n" + jsonData);
            }

            // DISPLAY DATA
            if (!string.IsNullOrEmpty(jsonData))
            {
                StringBuilder sb = new StringBuilder();

                JArray arr = JArray.Parse(jsonData);

                foreach (JObject item in arr)
                {
                    sb.Append("<div style='border:1px solid #ccc;padding:10px;margin:10px;'>");

                    foreach (var prop in item.Properties())
                    {
                        sb.Append("<b>" + prop.Name + ":</b> " + prop.Value + "<br/>");
                    }

                    sb.Append("</div>");
                }

                litData.Text = sb.ToString();
            }
            else
            {
                litData.Text = "<b>No data received</b>";
            }
        }
        catch (Exception ex)
        {
            File.AppendAllText(logPath, "\n\n----- ERROR -----\n" + ex.Message);
            litData.Text = "Error: " + ex.Message;
        }
    }

}