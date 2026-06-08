using System;
using System.Collections.Generic;
using System.Data;
using System.IO;
using System.Web;
using System.Web.UI;
using System.Web.UI.WebControls;

public partial class VideoUploadDemo : Page
{
    protected void Page_Load(object sender, EventArgs e)
    {
        if (!IsPostBack)
            BindFiles();
    }

    protected void btnUpload_Click(object sender, EventArgs e)
    {
        lblMessage.CssClass = "msg";
        lblMessage.Text = "";

        string appId = txtAppId.Text.Trim();
        string userId = txtUserId.Text.Trim();

        List<HttpPostedFile> files = new List<HttpPostedFile>();
        HttpFileCollection posted = Request.Files;
        for (int i = 0; i < posted.Count; i++)
        {
            HttpPostedFile f = posted[i];
            if (f != null && f.ContentLength > 0 && !string.IsNullOrWhiteSpace(f.FileName))
                files.Add(f);
        }

        if (files.Count == 0)
        {
            lblMessage.CssClass = "err";
            lblMessage.Text = "Please select one or more files.";
            return;
        }

        if (files.Count > FileUploadHelper.MaxFilesPerRequest)
        {
            lblMessage.CssClass = "err";
            lblMessage.Text = "Max " + FileUploadHelper.MaxFilesPerRequest + " files per upload.";
            return;
        }

        string physicalFolder = Server.MapPath("~/uploads/files/");
        string urlFolder = "uploads/files";
        int ok = 0;

        try
        {
            foreach (HttpPostedFile file in files)
            {
                string originalName = Path.GetFileName(file.FileName);

                if (file.ContentLength > FileUploadHelper.MaxFileBytes)
                    continue;

                string validateError;
                if (!FileUploadHelper.IsAllowed(originalName, out validateError))
                    continue;

                string relativePath = FileUploadHelper.SavePostedFile(file, physicalFolder, urlFolder);
                string ext = Path.GetExtension(originalName).ToLower();
                string fileType = FileUploadHelper.GetFileCategory(ext);

                DataSet ds = BAL_VideoUpload.ins_video_upload_sp(appId, userId, relativePath, originalName, ext, fileType);
                if (ds.Tables.Count > 0 && ds.Tables[0].Rows.Count > 0)
                    ok++;
            }

            if (ok > 0)
            {
                lblMessage.Text = ok + " file(s) uploaded successfully.";
                BindFiles();
            }
            else
            {
                lblMessage.CssClass = "err";
                lblMessage.Text = "No files uploaded. Check type and size (max 100 MB each).";
            }
        }
        catch (Exception ex)
        {
            lblMessage.CssClass = "err";
            lblMessage.Text = ex.Message;
        }
    }

    private void BindFiles()
    {
        DataSet ds = BAL_VideoUpload.dis_all_video_sp();
        if (ds.Tables.Count > 0 && ds.Tables[0].Rows.Count > 0)
        {
            rptFiles.DataSource = ds.Tables[0];
            rptFiles.DataBind();
            lblEmpty.Visible = false;
        }
        else
        {
            rptFiles.DataSource = null;
            rptFiles.DataBind();
            lblEmpty.Visible = true;
        }
    }

    protected void rptFiles_ItemDataBound(object sender, RepeaterItemEventArgs e)
    {
        if (e.Item.ItemType != ListItemType.Item && e.Item.ItemType != ListItemType.AlternatingItem)
            return;

        DataRowView row = (DataRowView)e.Item.DataItem;
        string fileType = row["file_type"] == DBNull.Value ? "" : row["file_type"].ToString();
        string path = row["video_path"].ToString();

        Panel pnlVideo = (Panel)e.Item.FindControl("pnlVideo");
        HyperLink lnk = (HyperLink)e.Item.FindControl("lnkFile");

        if (fileType == "video")
        {
            pnlVideo.Visible = true;
        }
        else
        {
            lnk.NavigateUrl = ResolveUrl("~/" + path);
            lnk.Visible = true;
        }
    }
}
