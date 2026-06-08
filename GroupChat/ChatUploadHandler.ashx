<%@ WebHandler Language="C#" Class="ChatUploadHandler" %>



using System;

using System.Collections.Generic;

using System.IO;

using System.Web;

using System.Web.Script.Serialization;



/// <summary>

/// Upload chat media (image, video, file) for group chat.

/// POST multipart: app_id, user_id, file

/// </summary>

public class ChatUploadHandler : IHttpHandler

{

    public void ProcessRequest(HttpContext context)

    {

        context.Response.ContentType = "application/json; charset=utf-8";

        context.Response.Cache.SetCacheability(HttpCacheability.NoCache);



        var js = new JavaScriptSerializer { MaxJsonLength = int.MaxValue };



        try

        {

            string appId = (context.Request.Form["app_id"] ?? "").Trim();

            string userId = (context.Request.Form["user_id"] ?? "").Trim();



            int appIdNum, userIdNum;

            if (!int.TryParse(appId, out appIdNum) || appIdNum <= 0)

                throw new Exception("Invalid app_id.");

            if (!int.TryParse(userId, out userIdNum) || userIdNum <= 0)

                throw new Exception("Invalid user_id.");



            HttpPostedFile file = context.Request.Files["file"];

            if (file == null || file.ContentLength == 0)

            {

                if (context.Request.Files.Count > 0)

                    file = context.Request.Files[0];

            }



            if (file == null || file.ContentLength == 0)

                throw new Exception("No file received.");



            if (file.ContentLength > FileUploadHelper.MaxFileBytes)

                throw new Exception("File too large. Max 100 MB.");



            string originalName = Path.GetFileName(file.FileName);

            string validateError;

            if (!FileUploadHelper.IsAllowed(originalName, out validateError))

                throw new Exception(validateError);



            string urlFolder = "uploads/chat/" + appId;

            string physicalFolder = context.Server.MapPath("~/" + urlFolder + "/");

            string relativePath = FileUploadHelper.SavePostedFile(file, physicalFolder, urlFolder);



            string ext = Path.GetExtension(originalName).ToLower();

            string fileType = FileUploadHelper.GetFileCategory(ext);

            string msgType = "FILE";

            if (fileType == "image") msgType = "IMAGE";

            else if (fileType == "video") msgType = "VIDEO";



            string fileUrl = FileUploadHelper.BuildPublicUrl(context.Request, relativePath);



            context.Response.Write(js.Serialize(new

            {

                Success = "1",

                file_path = relativePath,

                file_url = fileUrl,

                file_name = originalName,

                file_ext = ext,

                file_size = file.ContentLength,

                file_type = fileType,

                msg_type = msgType

            }));

        }

        catch (Exception ex)

        {

            context.Response.StatusCode = 500;

            context.Response.Write(js.Serialize(new { Success = "0", message = ex.Message }));

        }

    }



    public bool IsReusable { get { return false; } }

}

