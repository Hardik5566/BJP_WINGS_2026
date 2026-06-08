<%@ Page Language="C#" AutoEventWireup="true" CodeFile="PublicAI.aspx.cs" Inherits="PublicAI" Async="true" %>

<!DOCTYPE html>
<html>
<head runat="server">
    <title>Public AI Assistant</title>
    <link href="https://cdn.jsdelivr.net/npm/bootstrap@5.3.0/dist/css/bootstrap.min.css" rel="stylesheet" />
    <style>
        body { background: #f0f2f5; }
        .chat-container { max-width: 800px; margin: 50px auto; height: 80vh; display: flex; flex-direction: column; background: white; border-radius: 12px; box-shadow: 0 4px 15px rgba(0,0,0,0.1); }
        .chat-header { background: #0d6efd; color: white; padding: 15px; border-radius: 12px 12px 0 0; text-align: center; font-weight: bold; }
        .chat-box { flex: 1; overflow-y: auto; padding: 20px; border-bottom: 1px solid #eee; }
        .message { margin-bottom: 15px; padding: 10px 15px; border-radius: 18px; max-width: 75%; line-height: 1.5; }
        .user-msg { background: #0d6efd; color: white; align-self: flex-end; margin-left: auto; }
        .ai-msg { background: #e9ecef; color: #333; align-self: flex-start; }
        .input-area { padding: 15px; display: flex; gap: 10px; }
    </style>
</head>
<body>
    <form id="form1" runat="server">
        <asp:ScriptManager runat="server" />
        <div class="chat-container">
            <div class="chat-header">Public AI Knowledge Assistant</div>
            <div class="chat-box" id="chatWindow">
                <asp:UpdatePanel ID="upChat" runat="server">
                    <ContentTemplate>
                        <asp:PlaceHolder ID="phChat" runat="server" />
                    </ContentTemplate>
                </asp:UpdatePanel>
            </div>
            <div class="input-area">
                <asp:TextBox ID="txtInput" runat="server" CssClass="form-control" placeholder="Ask anything..." />
                <asp:Button ID="btnAsk" runat="server" Text="Send" CssClass="btn btn-primary" OnClick="btnAsk_Click" />
            </div>
        </div>
    </form>
</body>
</html>