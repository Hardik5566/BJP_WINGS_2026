using System;
using System.Collections.Generic;
using System.Configuration;
using System.Data;
using System.Data.OleDb;
using System.IO;
using System.Linq;
using System.Net;
using System.Text.RegularExpressions;
using System.Web;

/// <summary>
/// Summary description for General_Class
/// </summary>
public class General_Class
{
    public General_Class()
    {
        //
        // TODO: Add constructor logic here
        //
    }
    public static string rename_file_name(string file_name)
    {

        if (file_name != "")
        {
            string ext = Path.GetExtension(file_name);
            file_name = Path.GetFileNameWithoutExtension(file_name);

            file_name = DateTime.Now.ToString("ddMMyyyyhhmmss") + "_" + System.Text.RegularExpressions.Regex.Replace(file_name, @"[^0-9a-zA-Z]+", "") + ext;
        }

        return file_name;
    }

    public static string get_domain_name()
    {
        try
        {
            string server_url = System.Configuration.ConfigurationManager.ConnectionStrings["server_url"].ToString();
            return server_url;
        }
        catch (Exception)
        {

            throw;
        }
    }


    public static string save_file_from_base64(string file_name, string base64, string save_path)
    {
        string name = "";

        if (file_name != "")
        {
            string ext = Path.GetExtension(file_name);
            file_name = Path.GetFileNameWithoutExtension(file_name);

            file_name = DateTime.Now.ToString("ddMMyyyyhhmmss") + "_" + System.Text.RegularExpressions.Regex.Replace(file_name, @"[^0-9a-zA-Z]+", "") + ext;

            byte[] bytes = Convert.FromBase64String(base64);

            string path = save_path + file_name;
            File.WriteAllBytes(path, bytes);

            name = file_name;
        }
        return name;
    }


    public static byte[] local_image_to_byte(string photo_path)
    {
        System.Drawing.Image img = System.Drawing.Image.FromFile(photo_path);

        //ImageConverter Class convert Image object to Byte array.
        byte[] bytes = (byte[])(new System.Drawing.ImageConverter()).ConvertTo(img, typeof(byte[]));

        return bytes;
    }

    public static void send_sms(string mobile_no, string sms)
    {

        string SEND_URL = "http://sms.lifeweblink.com/vb/apikey.php?apikey=jun5mj4zX4FzyEq2&senderid=CQPPLE&number="+mobile_no+"&message=" + sms;

        HttpWebRequest req = (HttpWebRequest)WebRequest.Create(SEND_URL);
        HttpWebResponse resp = (HttpWebResponse)req.GetResponse();
        StreamReader sr = new StreamReader(resp.GetResponseStream());
        string results = sr.ReadToEnd();
        sr.Close();
    }

    public static string generat_otp()
    {
        Random generator = new Random();
        String r = generator.Next(0, 1000000).ToString("D6");

        return r;
    }

    public static bool IsDate(string dateString)
    {
        DateTime parsedDate;
        return DateTime.TryParse(dateString, out parsedDate);

    }


    public static bool is_int(string value)
    {
        int temp;
        return int.TryParse(value, out temp);
    }


}

/// <summary>
/// Shared file upload validation and save (documents, images, video).
/// </summary>
public static class FileUploadHelper
{
    public const long MaxFileBytes = 104857600; // 100 MB per file
    public const int MaxFilesPerRequest = 20;

    private static readonly string[] BlockedExt = {
        ".exe", ".bat", ".cmd", ".com", ".msi", ".dll", ".scr", ".ps1", ".vbs", ".js", ".jar", ".asp", ".aspx", ".ashx", ".config"
    };

    private static readonly string[] AllowedExt = {
        ".pdf", ".doc", ".docx", ".xls", ".xlsx", ".ppt", ".pptx", ".txt", ".csv", ".rtf",
        ".jpg", ".jpeg", ".png", ".gif", ".webp", ".bmp",
        ".mp4", ".mov", ".3gp", ".webm", ".avi", ".mkv",
        ".zip", ".rar", ".7z"
    };

    public static bool IsAllowed(string fileName, out string error)
    {
        error = "";
        if (string.IsNullOrWhiteSpace(fileName))
        {
            error = "Invalid file name.";
            return false;
        }

        string ext = Path.GetExtension(fileName).ToLower();
        if (string.IsNullOrEmpty(ext))
        {
            error = "File must have an extension.";
            return false;
        }

        if (BlockedExt.Contains(ext))
        {
            error = "File type not allowed: " + ext;
            return false;
        }

        if (!AllowedExt.Contains(ext))
        {
            error = "File type not allowed: " + ext;
            return false;
        }

        return true;
    }

    public static string GetFileCategory(string ext)
    {
        ext = (ext ?? "").ToLower();
        if (ext == ".mp4" || ext == ".mov" || ext == ".3gp" || ext == ".webm" || ext == ".avi" || ext == ".mkv")
            return "video";
        if (ext == ".jpg" || ext == ".jpeg" || ext == ".png" || ext == ".gif" || ext == ".webp" || ext == ".bmp")
            return "image";
        return "document";
    }

    public static string SavePostedFile(HttpPostedFile file, string physicalFolder, string urlFolder)
    {
        string ext = Path.GetExtension(file.FileName).ToLower();
        string baseName = Path.GetFileNameWithoutExtension(file.FileName);
        baseName = Regex.Replace(baseName, @"[^0-9a-zA-Z._-]+", "_");
        if (baseName.Length > 80) baseName = baseName.Substring(0, 80);

        string safeName = DateTime.Now.ToString("ddMMyyyyhhmmssfff") + "_" + baseName + ext;

        if (!Directory.Exists(physicalFolder))
            Directory.CreateDirectory(physicalFolder);

        string fullPath = Path.Combine(physicalFolder, safeName);
        file.SaveAs(fullPath);

        return urlFolder.TrimEnd('/') + "/" + safeName;
    }

    public static string BuildPublicUrl(HttpRequest request, string relativePath)
    {
        string baseUrl = request.Url.GetLeftPart(UriPartial.Authority) + request.ApplicationPath.TrimEnd('/');
        return baseUrl + "/" + relativePath.Replace("\\", "/");
    }
}