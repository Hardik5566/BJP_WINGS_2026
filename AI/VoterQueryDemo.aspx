<%@ Page Language="C#" AutoEventWireup="true" Async="true" CodeFile="VoterQueryDemo.aspx.cs" Inherits="AI_VoterQueryDemo" %>
<!DOCTYPE html>
<html xmlns="http://www.w3.org/1999/xhtml">
<head runat="server">
    <title>Voter AI Demo (Single Table)</title>
    <style>
        body { font-family: Arial; margin: 18px; }
        .row { margin-bottom: 10px; }
        .label { display: inline-block; width: 90px; }
        .box { width: 680px; max-width: 95vw; }
        .mono { font-family: Consolas, 'Courier New', monospace; white-space: pre-wrap; background: #f6f6f6; border: 1px solid #ddd; padding: 10px; }
        .hint { color: #555; font-size: 12px; }
    </style>
</head>
<body>
    <form id="form1" runat="server">
        <div class="row">
            <div class="hint">
                Examples: "Hardik nam vala voter aapo", "Hardik Patel", "age 20 to 25", "booth 5 ma ketla voter", "age group 20-30 31-40 41-50", "young voter"
            </div>
        </div>

        <div class="row">
            <span class="label">App ID</span>
            <asp:TextBox ID="txtAppId" runat="server" Text="1" Width="80" />
            <span class="hint">(tenant isolation)</span>
        </div>

        <div class="row">
            <span class="label">Question</span>
            <asp:TextBox ID="txtQuestion" runat="server" CssClass="box" />
            <asp:Button ID="btnAsk" runat="server" Text="Ask" OnClick="btnAsk_Click" />
        </div>

        <div class="row">
            <asp:Label ID="lblError" runat="server" ForeColor="Red" />
        </div>

        <div class="row">
            <b>AI Parsed JSON</b>
            <div class="mono">
                <asp:Literal ID="litParsedJson" runat="server" />
            </div>
        </div>

        <div class="row">
            <b>SQL (generated safely)</b>
            <div class="mono">
                <asp:Literal ID="litSql" runat="server" />
            </div>
        </div>

        <div class="row">
            <asp:Label ID="lblSummary" runat="server" Font-Bold="true" />
        </div>

        <div class="row">
            <asp:GridView ID="gvResults" runat="server" AutoGenerateColumns="true" />
        </div>
    </form>
</body>
</html>

