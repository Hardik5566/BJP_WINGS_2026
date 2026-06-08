<%@ Page Language="C#" AutoEventWireup="true" CodeFile="send_bulk_slip.aspx.cs" Inherits="Bulk_Slip_send_bulk_slip" %>

<!DOCTYPE html>

<html xmlns="http://www.w3.org/1999/xhtml">
<head runat="server">
   <title>Automated Voter Card Generator</title>
    <script src="https://cdnjs.cloudflare.com/ajax/libs/html2canvas/1.4.1/html2canvas.min.js"></script>
    
    <style>
        #voter-card {
            width: 500px; padding: 20px; border: 2px solid #000; 
            font-family: Arial, sans-serif; background: #fff; color: #000;
            margin: 20px auto;
        }
        .header { text-align: center; border-bottom: 2px solid #333; padding-bottom: 10px; }
        .flex-row { display: flex; justify-content: space-between; margin: 15px 0; font-weight: bold; }
        .data-row { margin-bottom: 10px; font-size: 1.1em; line-height: 2; }
        .underline { border-bottom: 1px dotted #000; display: inline-block; }
    </style>
</head>
<body>
    <form id="form1" runat="server">
     <asp:HiddenField ID="hfImageData" runat="server" />
        <asp:HiddenField ID="hfVoterMobile" runat="server" />

        <div id="voter-card" style="width: 500px; padding: 20px; border: 2px solid #000; font-family: Arial, sans-serif; background: #fff; color: #000; margin: 0 auto;">
            <h2 style="text-align: center; margin-top: 0; border-bottom: 2px solid #333; padding-bottom: 10px;">VOTER INFORMATION</h2>
            
            <div style="display: flex; justify-content: space-between; margin-bottom: 15px; font-weight: bold;">
                <span>Ac No: <asp:Label ID="lblAcNo" runat="server" /></span>
                <span>Booth No: <asp:Label ID="lblBooth" runat="server" /></span>
                <span>Sr No: <asp:Label ID="lblSrNo" runat="server" /></span>
            </div>

            <div style="line-height: 2; font-size: 1.1em;">
                <div><strong>Voter Name:</strong> <span style="border-bottom: 1px dotted #000; width: 330px; display: inline-block;"><asp:Label ID="lblName" runat="server" /></span></div>
                <div><strong>Father Name:</strong> <span style="border-bottom: 1px dotted #000; width: 320px; display: inline-block;"><asp:Label ID="lblFather" runat="server" /></span></div>
                <div><strong>ID Card No:</strong> <span style="border-bottom: 1px dotted #000; width: 340px; display: inline-block;"><asp:Label ID="lblID" runat="server" /></span></div>
                <div style="margin-top: 10px;"><strong>Polling Location:</strong></div>
                <div style="height: 50px; border: 1px solid #ccc; padding: 5px; margin-top: 5px;">
                    <asp:Label ID="lblLocation" runat="server" />
                </div>
            </div>
        </div>
    </form>

 <script>
     window.onload = function () {
         // Stop if the process is finished
         if (window.location.search.indexOf("status=finished") > -1) return;

         const card = document.getElementById('voter-card');

         // Wait for rendering, then capture
         setTimeout(() => {
             html2canvas(card, { scale: 3, backgroundColor: "#ffffff" }).then(canvas => {
                 document.getElementById('<%= hfImageData.ClientID %>').value = canvas.toDataURL("image/jpeg", 0.9);
                    // Automatic Postback to C#
                    document.forms[0].submit();
                });
            }, 1000);
     };
    </script>
</body>
</html>
