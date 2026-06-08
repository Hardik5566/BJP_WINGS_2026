<%@ Page Language="C#" AutoEventWireup="true" CodeFile="Phonepay_Payment_Gateway_Test.aspx.cs" Inherits="Phonepay_Payment_Gateway_Test" %>

<!DOCTYPE html>

<html xmlns="http://www.w3.org/1999/xhtml">
<head runat="server">
    <title></title>
</head>
<body>
    <form id="form1" runat="server">
      <div>
            <h2>PhonePe Integration Test</h2>
            <p>Amount to Pay: ₹1.00</p>
            <asp:Button ID="btnPay" runat="server" Text="Pay Now" OnClick="btnPay_Click" />
            <br /><br />
            <asp:Label ID="lblStatus" runat="server" ForeColor="Red"></asp:Label>
        </div>
    </form>
</body>
</html>
