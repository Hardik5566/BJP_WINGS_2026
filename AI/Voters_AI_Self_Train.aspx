<%@ Page Language="C#" AutoEventWireup="true" Async="true" CodeFile="Voters_AI_Self_Train.aspx.cs" Inherits="AI_Voters_AI_Self_Train" %>

<!DOCTYPE html>

<html xmlns="http://www.w3.org/1999/xhtml">
<head runat="server">
    <title></title>

    <style>
        .container {
            max-width: 1000px;
            margin: 30px auto;
            font-family: sans-serif;
        }

        .search-box {
            width: 75%;
            padding: 12px;
            font-size: 16px;
            border: 2px solid #ddd;
            border-radius: 5px;
        }

        .btn {
            padding: 12px 25px;
            background: #007bff;
            color: white;
            border: none;
            border-radius: 5px;
            cursor: pointer;
        }

        .sql-panel {
            background: #2d2d2d;
            color: #9cdcfe;
            padding: 15px;
            border-radius: 5px;
            margin: 20px 0;
            font-family: 'Consolas', monospace;
            overflow-x: auto;
        }

        .grid-view {
            width: 100%;
            border-collapse: collapse;
            margin-top: 20px;
        }

            .grid-view th {
                background: #f8f9fa;
                padding: 10px;
                border: 1px solid #dee2e6;
                text-align: left;
            }

            .grid-view td {
                padding: 10px;
                border: 1px solid #dee2e6;
            }
    </style>

</head>
<body>
    <form id="form1" runat="server">
        <div class="container">
            <h2>Election Data AI Explorer</h2>
            <asp:TextBox ID="txtQuestion" runat="server" CssClass="search-box" Placeholder="Ask anything: Who are the Sakti Kendra Pramukhs in Booth 5?" />
            <asp:Button ID="btnSearch" runat="server" Text="Get Data" CssClass="btn" OnClick="btnSearch_Click" />

            <asp:Label ID="lblError" runat="server" ForeColor="Red" Style="display: block; margin-top: 10px;" />

            <div class="sql-panel">
                <strong>Generated SQL:</strong><br />
                <asp:Label ID="lblSqlOutput" runat="server" Text="-- Waiting for query..." />
            </div>

            <asp:GridView ID="gvResults" runat="server" CssClass="grid-view" EmptyDataText="No records found." />
        </div>
    </form>

</body>
</html>
