<%@ WebHandler Language="C#" Class="VideoUploadHandler" %>

using System;
using System.Collections.Generic;
using System.Data;
using System.IO;
using System.Web;
using System.Web.Script.Serialization;

public class VideoUploadHandler : IHttpHandler
{
  public void ProcessRequest(HttpContext context)
  {
    context.Response.ContentType = "application/json";
    var js = new JavaScriptSerializer { MaxJsonLength = int.MaxValue };

    try
    {
      string appId = context.Request.Form["app_id"];
      string userId = context.Request.Form["user_id"];

      List<HttpPostedFile> incoming = CollectFiles(context);
      if (incoming.Count == 0)
        throw new Exception("No files received. Use form field 'files' (multiple) or 'file' / 'video' (single).");

      if (incoming.Count > FileUploadHelper.MaxFilesPerRequest)
        throw new Exception("Too many files. Max " + FileUploadHelper.MaxFilesPerRequest + " per request.");

      string physicalFolder = context.Server.MapPath("~/uploads/files/");
      string urlFolder = "uploads/files";

      var uploaded = new List<object>();
      var errors = new List<object>();

      foreach (HttpPostedFile file in incoming)
      {
        string originalName = Path.GetFileName(file.FileName);
        try
        {
          if (file.ContentLength == 0)
          {
            errors.Add(new { file_name = originalName, message = "Empty file." });
            continue;
          }

          if (file.ContentLength > FileUploadHelper.MaxFileBytes)
          {
            errors.Add(new { file_name = originalName, message = "File too large. Max 100 MB per file." });
            continue;
          }

          string validateError;
          if (!FileUploadHelper.IsAllowed(originalName, out validateError))
          {
            errors.Add(new { file_name = originalName, message = validateError });
            continue;
          }

          string relativePath = FileUploadHelper.SavePostedFile(file, physicalFolder, urlFolder);
          string ext = Path.GetExtension(originalName).ToLower();
          string fileType = FileUploadHelper.GetFileCategory(ext);

          DataSet ds = BAL_VideoUpload.ins_video_upload_sp(appId, userId, relativePath, originalName, ext, fileType);
          if (ds.Tables.Count == 0 || ds.Tables[0].Rows.Count == 0)
          {
            errors.Add(new { file_name = originalName, message = "Database save failed." });
            continue;
          }

          DataRow row = ds.Tables[0].Rows[0];
          string fileUrl = FileUploadHelper.BuildPublicUrl(context.Request, relativePath);

          uploaded.Add(new
          {
            file_id = row["video_id"].ToString(),
            file_name = originalName,
            file_path = relativePath,
            file_url = fileUrl,
            file_ext = ext,
            file_type = fileType,
            file_size = file.ContentLength
          });
        }
        catch (Exception exFile)
        {
          errors.Add(new { file_name = originalName, message = exFile.Message });
        }
      }

      if (uploaded.Count == 0 && errors.Count > 0)
        throw new Exception("No files uploaded successfully.");

      context.Response.Write(js.Serialize(new
      {
        Success = "1",
        app_id = appId,
        user_id = userId,
        uploaded_count = uploaded.Count,
        files = uploaded,
        errors = errors
      }));
    }
    catch (Exception ex)
    {
      context.Response.StatusCode = 500;
      context.Response.Write(js.Serialize(new { Success = "0", message = ex.Message }));
    }
  }

  private static List<HttpPostedFile> CollectFiles(HttpContext context)
  {
    var list = new List<HttpPostedFile>();
    var seen = new HashSet<string>();

    for (int i = 0; i < context.Request.Files.Count; i++)
    {
      HttpPostedFile f = context.Request.Files[i];
      if (f == null || f.ContentLength == 0 || string.IsNullOrWhiteSpace(f.FileName))
        continue;

      string key = f.FileName + "|" + f.ContentLength;
      if (seen.Add(key))
        list.Add(f);
    }

    return list;
  }

  public bool IsReusable
  {
    get { return false; }
  }
}
