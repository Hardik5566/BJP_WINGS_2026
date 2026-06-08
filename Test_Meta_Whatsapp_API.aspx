<%@ Page Language="C#" AutoEventWireup="true" CodeFile="Test_Meta_Whatsapp_API.aspx.cs" Inherits="Test_Meta_Whatsapp_API" %>

<!DOCTYPE html>

<html xmlns="http://www.w3.org/1999/xhtml">
<head runat="server">
    <title></title>
</head>
<body>
    <form id="form1" runat="server">
        <div>
            <asp:Button ID="btnSendMessage" runat="server" Text="Send WhatsApp Message" OnClick="btnSendMessage_Click" />
            <asp:Button ID="btnSendImage" runat="server" Text="Send WhatsApp Image" OnClick="btnSendImage_Click" />
            <br /><br />
            <asp:Label ID="lblResult" runat="server" Text=""></asp:Label>
            

            <asp:Image ID="imgCaptcha" runat="server" ImageUrl="~/Code_Test.aspx" />

<br /><br />

<asp:TextBox ID="txtCaptcha" runat="server" placeholder="Enter Captcha"></asp:TextBox>

<br /><br />


<br />

<asp:Label ID="lblMessage" runat="server" ForeColor="Red"></asp:Label>

        </div>
    </form>
</body>
</html>
