<%@ Page Language="C#" AutoEventWireup="true" CodeFile="VideoUploadDemo.aspx.cs" Inherits="VideoUploadDemo" %>
<!DOCTYPE html>
<html xmlns="http://www.w3.org/1999/xhtml">
<head runat="server">
    <title>File Upload Demo</title>
    <style>
        body { font-family: Arial, sans-serif; margin: 20px; }
        .card { border: 1px solid #ddd; padding: 16px; margin-bottom: 20px; border-radius: 6px; max-width: 800px; }
        .row { margin-bottom: 12px; }
        .msg { color: green; font-weight: bold; }
        .err { color: red; }
        video { width: 100%; max-width: 640px; margin-top: 8px; background: #000; }
        .file-item { border-bottom: 1px solid #eee; padding: 12px 0; }
        .hint { color: #666; font-size: 13px; }
    </style>
</head>
<body>
    <form id="form1" runat="server" enctype="multipart/form-data">
        <h2>File Upload Demo (multiple)</h2>

        <div class="card">
            <h3>Upload files</h3>
            <p class="hint">PDF, Word, Excel, images, video, zip — max 20 files, 100 MB each</p>
            <div class="row">
                <span>App ID</span>
                <asp:TextBox ID="txtAppId" runat="server" Text="1" Width="80" />
                &nbsp;&nbsp;
                <span>User ID</span>
                <asp:TextBox ID="txtUserId" runat="server" Text="1" Width="80" />
            </div>
            <div class="row">
                <input type="file" name="files" id="files" multiple="multiple" />
            </div>
            <div class="row">
                <asp:Button ID="btnUpload" runat="server" Text="Upload" OnClick="btnUpload_Click" />
            </div>
            <asp:Label ID="lblMessage" runat="server" CssClass="msg" />
        </div>

        <div class="card">
            <h3>Uploaded files</h3>
            <asp:Repeater ID="rptFiles" runat="server" OnItemDataBound="rptFiles_ItemDataBound">
                <ItemTemplate>
                    <div class="file-item">
                        <div>
                            <b>ID:</b> <%# Eval("video_id") %>
                            | <b><%# Eval("file_name") %></b> (<%# Eval("file_type") %>)
                        </div>
                        <asp:Panel ID="pnlVideo" runat="server" Visible="false">
                            <video controls preload="metadata" src='<%# ResolveUrl("~/" + Eval("video_path")) %>'></video>
                        </asp:Panel>
                        <asp:HyperLink ID="lnkFile" runat="server" Target="_blank" Visible="false" Text="Open / Download" />
                    </div>
                </ItemTemplate>
            </asp:Repeater>
            <asp:Label ID="lblEmpty" runat="server" Text="No files uploaded yet." Visible="false" />
        </div>
    </form>
</body>
</html>
