<%@ Page Language="C#" AutoEventWireup="true" CodeFile="OpenAI.aspx.cs" Inherits="OpenAI" %>

<!DOCTYPE html>

<html xmlns="http://www.w3.org/1999/xhtml">
<head runat="server">
    <title></title>
</head>
<body>
    <form id="form1" runat="server">
        <div>
            <asp:TextBox ID="txtQuestion" runat="server" Width="500" />
            <asp:Button ID="btnAsk" runat="server" Text="Ask AI" OnClick="btnAsk_Click" />
            <br />
            <br />
            <asp:Label ID="lblResult" runat="server" />

        </div>
    </form>
</body>
</html>
