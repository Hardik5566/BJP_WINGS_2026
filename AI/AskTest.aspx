<%@ Page Language="C#" AutoEventWireup="true" CodeFile="AskTest.aspx.cs" Inherits="AI_AskTest" %>
<!DOCTYPE html>
<html xmlns="http://www.w3.org/1999/xhtml">
<head runat="server">
    <title>Election AI Test (New Module)</title>
    <style>
        body { font-family: Segoe UI, Arial; margin: 18px; }
        .row { margin-bottom: 12px; }
        .label { display: inline-block; width: 90px; font-weight: 600; }
        .box { width: 720px; max-width: 95vw; }
        .mono { font-family: Consolas, monospace; white-space: pre-wrap; background: #f4f4f4; border: 1px solid #ddd; padding: 10px; font-size: 12px; }
        .hint { color: #555; font-size: 12px; }
        .ok { color: #0a7; }
        .err { color: #c00; }
    </style>
</head>
<body>
    <form id="form1" runat="server">
        <h2>Election AI — New Module Test</h2>
        <p class="hint">Uses App_Code/AI + ai_* views only. Old GetAIElectionData is not used.</p>

        <div class="row">
            <span class="label">App ID</span>
            <asp:TextBox ID="txtAppId" runat="server" Text="1" Width="80" />
        </div>
        <div class="row">
            <span class="label">Question</span>
            <asp:TextBox ID="txtQuestion" runat="server" CssClass="box" />
            <asp:Button ID="btnAsk" runat="server" Text="Ask AI" OnClick="btnAsk_Click" />
        </div>

        <div class="row">
            <asp:Label ID="lblStatus" runat="server" />
        </div>
        <div class="row">
            <b>Generated SQL</b>
            <asp:Literal ID="litSql" runat="server" />
        </div>
        <div class="row">
            <b>JSON Response</b>
            <asp:Literal ID="litJson" runat="server" />
        </div>
        <div class="row">
            <b>Results</b>
            <asp:GridView ID="gvResults" runat="server" />
        </div>

        <p class="hint">Examples: booth 5 ma ketla voter | booth 3 positive negative | Hardik voter | booth 5 slip nathi mali</p>
    </form>
</body>
</html>
