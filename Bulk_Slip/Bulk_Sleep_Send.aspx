<%@ Page Language="C#" AutoEventWireup="true" CodeFile="Bulk_Sleep_Send.aspx.cs" Inherits="Bulk_Sleep_Send" %>

<!DOCTYPE html>

<html xmlns="http://www.w3.org/1999/xhtml">
<head runat="server">

    <meta name="viewport" content="width=device-width, initial-scale=1.0" />
    <title>Bulk Engine - Live Monitor</title>
    <link href="https://fonts.googleapis.com/css2?family=Poppins:wght@400;600;700&display=swap" rel="stylesheet" />
    <script src="https://cdnjs.cloudflare.com/ajax/libs/html2canvas/1.4.1/html2canvas.min.js"></script>
    <script src="https://code.jquery.com/jquery-3.6.0.min.js"></script>

    <style>
        /* DASHBOARD STYLING */
        body {
            background: #0f172a;
            color: #fff;
            font-family: 'Poppins', sans-serif;
            margin: 0;
            padding: 15px;
        }

        /* --- NEW HEADER STYLING --- */
        .top-navbar {
            display: flex;
            align-items: center;
            justify-content: space-between;
            background: #1e293b;
            padding: 15px 20px;
            border-radius: 12px;
            border: 1px solid #334155;
            margin-bottom: 20px;
            box-shadow: 0 4px 6px -1px rgba(0, 0, 0, 0.1);
        }

        .logo-title-wrap {
            display: flex;
            align-items: center;
            gap: 15px;
        }

        .company-logo {
            height: 45px; /* Adjust based on your actual logo */
            width: auto;
            border-radius: 6px;
        }

        .portal-title {
            font-size: 20px;
            font-weight: 700;
            color: #f8fafc;
            margin: 0;
            letter-spacing: 0.5px;
        }

        .booth-badge {
            background: rgba(45, 212, 191, 0.1);
            color: #2dd4bf;
            border: 1px solid rgba(45, 212, 191, 0.3);
            padding: 8px 16px;
            border-radius: 8px;
            font-size: 16px;
            font-weight: 600;
        }
        /* -------------------------- */

        .header-stats {
            background: #1e293b;
            padding: 20px;
            border-radius: 12px;
            border: 1px solid #334155;
            margin-bottom: 20px;
        }

        .progress-info {
            display: flex;
            justify-content: space-between;
            margin-bottom: 10px;
            font-weight: 600;
        }

        .main-progress-bg {
            background: #334155;
            height: 12px;
            border-radius: 6px;
            overflow: hidden;
        }

        #mainBar {
            background: linear-gradient(90deg, #3b82f6, #2dd4bf);
            width: 0%;
            height: 100%;
            transition: 0.3s;
        }

        .generation-stage {
            text-align: center;
            background: #1e293b;
            padding: 20px;
            border-radius: 12px;
            border: 1px dashed #475569;
            min-height: 450px;
        }

        .counter-box {
            font-size: 24px;
            color: #2dd4bf;
        }

        /* EXACT SLIP DESIGN FROM YOUR REFERENCE */
        .slip-wrapper {
            max-width: 500px;
            margin: 0 auto;
            background: #fff;
            padding: 10px;
            text-align: left;
            transform: scale(0.9);
            transform-origin: top center;
        }

        .voter-slip-card {
            width: 100%;
            background: #ffffff;
            border: 2px solid #333;
            color: #000;
            overflow: hidden;
            position: relative;
        }

        .slip-header-img {
            width: 100%;
            border-bottom: 1px solid #333;
        }

        .slip-content {
            padding: 15px;
        }

        .info-row {
            margin-bottom: 8px;
            padding-bottom: 4px;
            border-bottom: 1px dotted #999;
            font-size: calc(12px + 0.2vw);
            line-height: 1.4;
        }


        .polling-station-container span {
           
            display: inline-block !important; /* Ensures the width is calculated properly */
            letter-spacing: 0.5px !important; /* Forces a gap between Hindi characters */
            word-spacing: 5px !important;
        }

        .info-row strong,
        .info-row span {
           
            display: inline-block !important; /* Ensures the width is calculated properly */
            letter-spacing: 0.5px !important; /* Forces a gap between Hindi characters */
            word-spacing: 5px !important; /* Ensures "वोटર આઈડી નંબર" stays separated */
        }

        /* Specific fix for the Hindi text to ensure it doesn't look squashed in the image */
        .label-text {
            min-width: 120px; /* Gives the label a fixed area so it can't be squished */
        }

        .info-row strong {
            color: #d35400;
            display: inline-block;
            font-size: 1.1em;
        }

        .polling-station-container {
            margin-top: 15px;
            background: #fdf2e9;
            border: 1px solid #e67e22;
            padding: 10px;
            border-radius: 4px;
        }

        .booth-container {
            display: flex;
            color: black;
            border-bottom: 1px solid #333;
        }

        .booth-item {
            flex: 1;
            text-align: center;
            padding: 5px 5px;
            font-size: 13px;
            font-weight: 600;
            border-right: 1px solid #555;
        }

            .booth-item:last-child {
                border-right: none;
            }

        .booth-label {
            display: block;
            font-size: 10px;
            text-transform: uppercase;
            color: #515151;
        }

        /* --- LIVE ANIMATIONS --- */
        .scanning-effect::after {
            content: "";
            position: absolute;
            top: -100%;
            left: 0;
            width: 100%;
            height: 100%;
            background: linear-gradient(rgba(59, 130, 246, 0) 0%, rgba(59, 130, 246, 0.4) 50%, rgba(59, 130, 246, 0) 100%);
            animation: scan 2s infinite linear;
        }

        @keyframes scan {
            0% {
                top: -100%;
            }

            100% {
                top: 100%;
            }
        }

        /* Class to hide scanner during capture */
        .hide-scanner::after {
            display: none !important;
            animation: none !important;
        }

        .success-pulse {
            animation: pulse 0.5s ease-out;
        }

        @keyframes pulse {
            0% {
                transform: scale(0.9);
            }

            70% {
                transform: scale(0.95);
                box-shadow: 0 0 0 20px rgba(45, 212, 191, 0);
            }

            100% {
                transform: scale(0.9);
            }
        }
    </style>

</head>
<body>
    <form id="form1" runat="server">
        <div class="top-navbar">
            <div class="logo-title-wrap">
                <img src="img/bjp_logo.png" alt="Company Logo" class="company-logo" />
                <h1 class="portal-title">BJP WINGS</h1>
            </div>
            <div class="booth-badge">
                Booth No: <span id="displayBoothNo">--</span>
            </div>
        </div>
        <div class="header-stats">
            <div class="progress-info">
                <span>Live Sending Engine...</span>
                <span class="counter-box"><span id="currCount">0</span> / <span id="totalCount">0</span></span>
            </div>
            <div class="main-progress-bg">
                <div id="mainBar"></div>
            </div>
            <div id="statusMsg" style="margin-top: 10px; font-size: 14px; color: #94a3b8;">Awaiting Start...</div>
        </div>

        <div class="generation-stage">
            <div id="live-preview-container" style="display: none;">
                <div class="slip-wrapper">
                    <div id="voter-card" class="voter-slip-card">
                        <img src="../img/10.jpeg" class="slip-header-img" />
                        <div class="booth-container">
                            <div class="booth-item"><span class="booth-label">બૂથ</span><span id="slipBooth"></span></div>
                            <div class="booth-item"><span class="booth-label">ક્રમ</span><span id="slipSr"></span></div>
                        </div>
                        <div class="slip-content">
                            <div class="info-row"><strong>નામ : </strong>&nbsp;<span id="slipName"></span></div>
                            <div class="info-row"><strong>પિતા/પતિ : </strong>&nbsp;<span id="slipFather"></span></div>
                            <div class="info-row"><strong>જાતિ/ઉમર : </strong>&nbsp;<span id="slipSexAge"></span></div>
                            <div class="info-row"><strong>આઈડીકાર્ડ નંબર : </strong>&nbsp;<span id="slipID"></span></div>
                            <div class="polling-station-container">
                                <strong style="width: 100%; border-bottom: 1px solid #e67e22; margin-bottom: 5px; display: block;">મતદાન સ્થળ :</strong>
                                <span style="font-size: 12px;" id="slipLoc"></span>
                            </div>
                        </div>
                    </div>
                </div>
            </div>

            <button type="button" id="btnStart" onclick="startProcess()"
                style="margin-top: 100px; background: #3b82f6; color: white; border: none; padding: 15px 50px; border-radius: 30px; font-weight: bold; font-size: 18px;">
                START BULK SENDING
       
            </button>
        </div>

    </form>
    <script src="https://code.jquery.com/jquery-3.6.0.min.js"></script>

    <script>
        // Fetch Booth Number from URL Query String on Load
        document.addEventListener("DOMContentLoaded", () => {
            const urlParams = new URLSearchParams(window.location.search);
            // Checks for ?booth=X or ?Booth=X
            const boothNo = urlParams.get('Booth') || urlParams.get('booth') || "All";
            document.getElementById('displayBoothNo').innerText = boothNo;
        });

        // Your existing data setup
        const voters = <%= GetVoterDataJson() %>;
        document.getElementById('totalCount').innerText = voters.length;

        async function startProcess() {
            document.getElementById('btnStart').style.display = 'none';
            const previewContainer = document.getElementById('live-preview-container');
            const voterCard = document.getElementById('voter-card');
            previewContainer.style.display = 'block';

            // IMPORTANT: Using v.length for full loop instead of hardcoded 3 if needed, 
            // but left at 3 based on your original perfect code snippet.
            for (let i = 0; i < voters.length; i++) {
                const v = voters[i];

                // 1. SHOW DATA & START SCANNER
                voterCard.classList.remove('hide-scanner');
                voterCard.classList.add('scanning-effect');
                document.getElementById('statusMsg').innerHTML = `🔍 Scanning Data: <b>${v.Name}</b>`;

                /*document.getElementById('slipAc').innerText = v.AcNo;*/
                document.getElementById('slipBooth').innerText = v.Booth;
                document.getElementById('slipSr').innerText = v.SrNo;
                document.getElementById('slipName').innerText = v.Name;
                document.getElementById('slipFather').innerText = v.Father;
                document.getElementById('slipSexAge').innerText = v.SexAge || "N/A";
                document.getElementById('slipID').innerText = v.ID;
                document.getElementById('slipLoc').innerText = v.Loc;

                // 2. WAIT FOR "LIVE FEEL" (2.5 seconds)
                await new Promise(r => setTimeout(r, 2500));

                // 3. REMOVE SCANNER FOR CLEAN CAPTURE
                voterCard.classList.add('hide-scanner');
                document.getElementById('statusMsg').innerHTML = `📸 Capturing Clean Slip...`;
                await new Promise(r => setTimeout(r, 150)); // Tiny delay for CSS to apply

                // 4. CAPTURE IMAGE
                const canvas = await html2canvas(voterCard, { scale: 3, useCORS: true });
                const base64 = canvas.toDataURL("image/jpeg", 0.9);

                // 5. SEND VIA AJAX
                try {
                    document.getElementById('statusMsg').innerHTML = `📤 Sending WhatsApp...`;
                    await $.ajax({
                        type: "POST",
                        url: "VoterHandler.ashx",
                        data: JSON.stringify({
                            CmpId: v.CmpId,
                            AppID: v.AppID,
                            uid: v.UserID,
                            id: v.ID,
                            mobile: v.Mobile,
                            img: base64,
                            name: v.Name,
                            booth: v.Booth,
                            sr: v.SrNo
                        }),
                        contentType: "application/json"
                    });

                    // 6. SUCCESS FEEDBACK
                    voterCard.classList.add('success-pulse');
                    setTimeout(() => voterCard.classList.remove('success-pulse'), 500);

                    let count = i + 1;
                    document.getElementById('currCount').innerText = count;
                    document.getElementById('mainBar').style.width = (count / voters.length * 100) + "%";

                } catch (error) {
                    console.error("Failed for:", v.Name);
                    document.getElementById('statusMsg').innerHTML = `<span style="color:#ff4444">❌ Error sending to ${v.Name}</span>`;
                    await new Promise(r => setTimeout(r, 1000)); // Pause so user sees the error
                }
            }

            voterCard.classList.add('hide-scanner');
            document.getElementById('statusMsg').innerHTML = "<span style='color:#2dd4bf; font-size:18px;'>🏁 All Slips Processed!</span>";
        }
    </script>
</body>
</html>
