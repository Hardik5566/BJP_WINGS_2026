<%@ Page Language="C#" AutoEventWireup="true" CodeFile="Send_bulk_slip_2.aspx.cs" Inherits="Bulk_Slip_Send_bulk_slip_2" %>

<!DOCTYPE html>

<html xmlns="http://www.w3.org/1999/xhtml">
<head runat="server">

    <meta name="viewport" content="width=device-width, initial-scale=1.0, maximum-scale=1.0" />


  <title>Bulk Voter Slip Sender</title>
    <script src="https://cdnjs.cloudflare.com/ajax/libs/html2canvas/1.4.1/html2canvas.min.js"></script>
    <style>
        #voter-card { width: 500px; padding: 20px; border: 2px solid #000; font-family: Arial; background: #fff; margin: 20px auto; }
        .status-box { text-align: center; font-size: 20px; font-weight: bold; color: blue; margin: 20px; }
    </style>
</head>
<body>
    <form id="form1" runat="server">
        <asp:TextBox ID="txt_mobile_no" runat="server"></asp:TextBox>
        <div class="status-box" id="statusMsg">Ready to start...</div>
        <button type="button" id="btnStart" onclick="startProcess()">START SENDING BULK</button>

        <div id="voter-card">
            <h2 style="text-align: center; border-bottom: 2px solid #333;">VOTER INFORMATION</h2>
            <div style="display: flex; justify-content: space-between; font-weight: bold;">
                <span>Ac No: <span id="slipAc"></span></span>
                <span>Booth No: <span id="slipBooth"></span></span>
                <span>Sr No: <span id="slipSr"></span></span>
            </div>
            <div style="line-height: 2; margin-top:15px;">
                <div><strong>Voter Name:</strong> <span id="slipName" style="border-bottom: 1px dotted #000; width: 300px; display: inline-block;"></span></div>
                <div><strong>Father Name:</strong> <span id="slipFather" style="border-bottom: 1px dotted #000; width: 300px; display: inline-block;"></span></div>
                <div><strong>ID Card No:</strong> <span id="slipID" style="border-bottom: 1px dotted #000; width: 300px; display: inline-block;"></span></div>
                <div style="margin-top: 10px;"><strong>Polling Location:</strong></div>
                <div id="slipLoc" style="height: 50px; border: 1px solid #ccc; padding: 5px;"></div>
            </div>
        </div>
    </form>
    <script src="https://code.jquery.com/jquery-3.6.0.min.js"></script>
   
    <script>
        const voters = <%= GetVoterDataJson() %>;

        async function startProcess() {
            const msg = document.getElementById('statusMsg');

            for (let i = 0; i < 5; i++) {
                const v = voters[i];
                msg.innerText = `Processing ${i + 1} of ${voters.length}: ${v.Name}`;

                // Update UI
                document.getElementById('slipAc').innerText = "Ac: " + v.AcNo;
                document.getElementById('slipBooth').innerText = "Booth: " + v.Booth;
                document.getElementById('slipSr').innerText = "Sr: " + v.SrNo;
                document.getElementById('slipName').innerText = v.Name;
                document.getElementById('slipID').innerText = v.ID;
                document.getElementById('slipLoc').innerText = v.Loc;

                // Capture Image
                const canvas = await html2canvas(document.getElementById('voter-card'), { scale: 3 });
                const base64 = canvas.toDataURL("image/jpeg", 0.9);

                // Ajax call to Handler
                await new Promise((resolve) => {
                    $.ajax({
                        type: "POST",
                        url: "VoterHandler.ashx",
                        data: JSON.stringify({ id: v.ID, mobile: v.Mobile, img: base64, name: v.Name, booth: v.Booth, sr: v.SrNo }),
                        contentType: "application/json",
                        success: (res) => resolve(res),
                        error: (err) => { console.error(err); resolve(); }
                    });
                });
            }
            msg.innerText = "All Finished!";
        }
    </script>
</body>
</html>
