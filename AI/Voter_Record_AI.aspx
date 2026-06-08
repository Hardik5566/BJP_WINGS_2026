<%@ Page Language="C#" Async="true" AutoEventWireup="true" CodeFile="Voter_Record_AI.aspx.cs" Inherits="AI_Voter_Record_AI" %>

<!DOCTYPE html>

<html xmlns="http://www.w3.org/1999/xhtml">
<head runat="server">
    <meta charset="UTF-8" />
    <meta name="viewport" content="width=device-width, initial-scale=1.0" />
    <style>
        body {
            font-family: 'Segoe UI', sans-serif;
            background-color: #e5ddd5;
            margin: 0;
        }

        .chat-container {
            max-width: 1000px;
            margin: 10px auto;
            background: white;
            height: 95vh;
            display: flex;
            flex-direction: column;
            border-radius: 8px;
            box-shadow: 0 2px 10px rgba(0,0,0,0.1);
        }

        .chat-header {
            background: #075e54;
            color: white;
            padding: 15px;
            display: flex;
            justify-content: space-between;
            align-items: center;
            border-radius: 8px 8px 0 0;
        }

        .chat-box {
            flex: 1;
            overflow-y: auto;
            padding: 20px;
            background-image: url('https://user-images.githubusercontent.com/15075759/28719144-86dc0f70-73b1-11e7-911d-60d70fcded21.png');
            display: flex;
            flex-direction: column;
            gap: 15px;
        }

        .message {
            max-width: 85%;
            padding: 10px 15px;
            border-radius: 10px;
            font-size: 14px;
            position: relative;
        }

        .user-message {
            background: #dcf8c6;
            align-self: flex-end;
            border-bottom-right-radius: 0;
        }

        .ai-message {
            background: #fff;
            align-self: flex-start;
            border-bottom-left-radius: 0;
            box-shadow: 0 1px 1px rgba(0,0,0,0.1);
            width: 95%;
        }

        .friendly-text {
            font-weight: bold;
            color: #075e54;
            display: block;
            margin-bottom: 5px;
        }

        .sql-debug {
            font-family: 'Consolas', monospace;
            background: #333;
            color: #00ff00;
            padding: 8px;
            border-radius: 5px;
            font-size: 11px;
            margin-top: 10px;
            overflow-x: auto;
        }

        .grid-container {
            width: 100%;
            overflow-x: auto;
            margin-top: 10px;
            border: 1px solid #ddd;
            border-radius: 5px;
        }

        .gvResults {
            width: 100%;
            border-collapse: collapse;
            font-size: 12px;
        }

            .gvResults th {
                background: #075e54;
                color: white;
                padding: 8px;
                text-align: left;
            }

            .gvResults td {
                padding: 8px;
                border: 1px solid #ddd;
            }

        .input-area {
            background: #f0f0f0;
            padding: 15px;
            display: flex;
            gap: 10px;
            border-radius: 0 0 8px 8px;
        }

        .txt-input {
            flex: 1;
            padding: 12px;
            border: 1px solid #ccc;
            border-radius: 25px;
            outline: none;
        }

        .btn-send {
            background: #075e54;
            color: white;
            border: none;
            padding: 0 25px;
            border-radius: 25px;
            cursor: pointer;
            font-weight: bold;
        }
    </style>

</head>
<body>
    <form id="form1" runat="server">
        <asp:ScriptManager ID="sm1" runat="server" />
        <div class="chat-container">
            <div class="chat-header">
                <h2>Election AI Assistant</h2>
            </div>
            <div class="chat-box" id="divChatBox">
                <asp:UpdatePanel ID="upChat" runat="server" UpdateMode="Conditional">
                    <ContentTemplate>
                        <asp:Repeater ID="rptChat" runat="server" OnItemDataBound="rptChat_ItemDataBound">
                            <ItemTemplate>
                                <div class="message user-message"><%# Eval("UserQuestion") %></div>

                                <div class="message ai-message">
                                    <span class="friendly-text"><%# Eval("FriendlyAnswer") %></span>

                                    <asp:Panel ID="pnlData" runat="server" Visible="false">
                                        <div class="grid-container">
                                            <asp:GridView ID="gvData" runat="server" CssClass="gvResults" AutoGenerateColumns="true" GridLines="None" />
                                        </div>
                                    </asp:Panel>

                                    <div class="sql-debug"><%# Eval("GeneratedSQL") %></div>
                                </div>
                            </ItemTemplate>
                        </asp:Repeater>
                    </ContentTemplate>
                </asp:UpdatePanel>
            </div>
            <div class="input-area">
                <asp:TextBox ID="txtQuestion" runat="server" CssClass="txt-input" Placeholder="તમારો પ્રશ્ન અહીં લખો..." />
                <asp:Button ID="btnAsk" runat="server" Text="Send" CssClass="btn-send" OnClick="btnAsk_Click" />
            </div>
        </div>
    </form>
    <script type="text/javascript">
        function scrollToBottom() {
            var div = document.getElementById('divChatBox');
            if (div) div.scrollTop = div.scrollHeight;
        }
        Sys.WebForms.PageRequestManager.getInstance().add_endRequest(scrollToBottom);
        window.onload = scrollToBottom;
    </script>
</body>
</html>
