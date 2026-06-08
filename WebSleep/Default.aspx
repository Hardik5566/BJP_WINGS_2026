<%@ Page Language="C#" AutoEventWireup="true" CodeFile="Default.aspx.cs" Inherits="WebSleep_Default" %>

<!DOCTYPE html>

<html xmlns="http://www.w3.org/1999/xhtml">
<head runat="server">
    <meta charset="UTF-8" />
    <meta name="viewport" content="width=device-width, initial-scale=1.0" />

    <title>રાજકોટ મહાનગરપાલિકા ચૂંટણી - 2026</title>

    <link rel="preconnect" href="https://fonts.googleapis.com" />
    <link rel="preconnect" href="https://fonts.gstatic.com" crossorigin />
    <link href="https://fonts.googleapis.com/css2?family=Poppins:ital,wght@0,100;0,200;0,300;0,400;0,500;0,600;0,700;0,800;0,900;1,100;1,200;1,300;1,400;1,500;1,600;1,700;1,800;1,900&display=swap" rel="stylesheet" />


    <style>
        * {
            box-sizing: border-box;
        }

        body {
            margin: 0;
            background: #f4f7f6;
            font-family: 'Poppins', sans-serif !important;
        }

        .page-wrapper {
            background: linear-gradient(rgba(255, 102, 0, 0.9), rgba(255, 102, 0, 0.9)), url('img/crowd_bg.jpg') no-repeat center center fixed;
            background-size: cover;
            min-height: 100vh;
            display: flex;
            justify-content: center;
            align-items: center;
            padding: 15px;
        }

        /* Base Container: Mobile first (Top-Bottom) */
        .voter-card-container {
            background: #ffffff;
            width: 100%;
            max-width: 450px; /* Small on mobile */
            border-radius: 15px;
            box-shadow: 0 10px 30px rgba(0,0,0,0.25);
            overflow: hidden;
            display: flex;
            flex-direction: column; /* Top-bottom for mobile */
        }

        /* Left Side (Banner) */
        .banner-box {
            flex: 1;
            background: #fff;
            display: flex;
            align-items: center;
            justify-content: center;
        }

            .banner-box img {
                width: 100%;
                display: block;
                padding: 20px;
            }

        /* Right Side (Form) */
        .form-padding {
            flex: 1;
            padding: 25px;
            background: #fff;
        }

        .campaign-title {
            font-size: 22px;
            font-weight: 700;
            color: #000;
            text-align: center;
            margin: 0 0 10px 0;
        }

        .campaign-desc {
            font-size: 13px;
            color: #444;
            text-align: center;
            line-height: 1.6;
            margin-bottom: 20px;
        }

        .input-style {
            width: 100%;
            padding: 12px 15px;
            margin-bottom: 15px;
            border: 1px solid #ced4da;
            border-radius: 8px;
            background: #fdfdfd;
            font-size: 14px;
            font-family: 'Poppins', sans-serif !important;
        }

        .captcha-section {
            display: flex;
            gap: 10px;
            margin-bottom: 20px;
        }

        .captcha-code {
            flex: 1;
            background: #eeeeee;
            border: 1px dashed #777;
            border-radius: 8px;
            display: flex;
            align-items: center;
            justify-content: center;
            font-weight: bold;
            letter-spacing: 4px;
            font-size: 18px;
        }

        .submit-btn {
            width: 100%;
            padding: 15px;
            background: #007bff;
            color: white;
            border: none;
            font-weight: 600;
            font-size: 16px;
            cursor: pointer;
            transition: 0.3s;
        }

            .submit-btn:hover {
                background: #0056b3;
            }


        .or-divider {
            display: flex;
            align-items: center;
            text-align: center;
            margin: 10px 0 20px 0;
            color: #888;
            font-size: 14px;
            font-weight: 600;
        }

            .or-divider::before,
            .or-divider::after {
                content: '';
                flex: 1;
                border-bottom: 1px solid #ddd;
            }

            .or-divider:not(:empty)::before {
                margin-right: .5em;
            }

            .or-divider:not(:empty)::after {
                margin-left: .5em;
            }

        /* DESKTOP RESPONSIVENESS (Side by Side) */
        @media (min-width: 768px) {
            .voter-card-container {
                max-width: 900px; /* Wider for desktop */
                flex-direction: row; /* Side-by-side for PC/Laptop */
                align-items: stretch;
            }

            .banner-box {
                border-right: 1px solid #eee; /* Separator line */
                padding: 20px;
            }

            .form-padding {
                padding: 40px; /* More breathing room on PC */
            }
        }

        @media (max-width: 480px) {
            .form-padding {
                padding: 15px;
            }

            .campaign-title {
                font-size: 18px;
            }
        }
    </style>

    <style>
        /* Container for the downloaded slip area */
        .slip-wrapper {
            max-width: 500px;
            margin: 20px auto;
            background: #fff;
            padding: 10px;
        }

        /* The actual card to be captured as an image */
        .voter-slip-card {
            width: 100%;
            background: #ffffff;
            border: 2px solid #333; /* Strong border for the card */
            font-family: 'Poppins', sans-serif;
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
            font-size: 14px;
            line-height: 1.4;
        }

            .info-row strong {
                color: #d35400; /* Subtle orange for labels */
                display: inline-block;
                width: auto;
            }

        .polling-station-container {
            margin-top: 15px;
            background: #fdf2e9; /* Very light orange background for location */
            border: 1px solid #e67e22;
            padding: 10px;
            border-radius: 4px;
        }

        .booth-container {
            display: flex;
            /*background: #333;*/ /* Dark background like your reference */
            color: black;
        }

        .booth-item {
            flex: 1; /* Equal width for all 3 items */
            text-align: center;
            padding: 5px 5px;
            font-size: 13px;
            font-weight: 600;
            border-right: 1px solid #555; /* Subtle separator */
        }

        .booth-sub-item {
            /*  border: 1px solid #000000;
            border-radius: 5px;
            padding: 10px;*/
        }

        .booth-item:last-child {
            border-right: none; /* Remove border from the last item */
        }

        .booth-label {
            display: block;
            font-size: 10px;
            text-transform: uppercase;
            color: #515151;
        }

        /* Style for the Download button below each card */
        .download-card-btn {
            background: #28a745;
            color: #fff;
            border: none;
            padding: 10px 20px;
            cursor: pointer;
            font-weight: 600;
            margin-top: 10px;
            width: 100%;
        }
    </style>


    <style>
        /* Footer Logo Container */
        .slip-footer {
            display: flex;
            align-items: center;
            justify-content: center;
            padding: 10px;
            background: black;
            border-top: 1px solid #ddd;
            gap: 10px;
        }

        .footer-logo {
            height: 35px; /* તમારી જરૂરિયાત મુજબ સાઈઝ બદલી શકાય */
            width: auto;
            display: block;
        }

        .footer-text {
            font-size: 11px;
            color: #555;
            font-weight: 500;
        }
    </style>
</head>
<body>
    <form id="form1" runat="server">
        <div class="page-wrapper">
            <div class="voter-card-container" id="div_idcard" runat="server">

                <%-- <div class="banner-box">
                    <asp:Image ImageUrl="img/cadre.png" runat="server" />
                </div>--%>

                <div class="form-padding">
                    <h3 class="campaign-title">મતદાન જાગૃતિ અભિયાન</h3>
                    <p style="text-align: center; font-weight: 700; color: #ff6600; margin-top: -5px; font-size: 16px;">
              રાજકોટ મહાનગરપાલિકા ચૂંટણી - 2026
          </p>
                    <p class="campaign-desc">
                        અમે તમારા અને તમારા પરિવારની મતદાન સ્લિપ ડાઉનલોડ કરવા માટે આ વેબસાઇટ પ્રદાન કરીએ છીએ. 
                    </p>

                    <div class="search-group">
                        <asp:DropDownList ID="ddl_assembly" DataTextField="ward_no" DataValueField="app_id" CssClass="input-style" runat="server">
                        </asp:DropDownList>
                        <%-- <asp:TextBox runat="server" ID="txt_firstname" placeholder="First Name" CssClass="input-style" />
                        <asp:TextBox runat="server" ID="txt_middlename" placeholder="Middle Name" CssClass="input-style" />
                        <asp:TextBox runat="server" ID="txt_lastname" placeholder="Last Name" CssClass="input-style" />--%>
                    </div>

                    <%--<div class="or-divider">OR</div>--%>

                    <div class="search-group">
                        <asp:TextBox runat="server" ID="txt_epic_no" placeholder="ચૂટણીકાર્ડ નંબર" CssClass="input-style" />
                    </div>



                    <%-- <div class="captcha-section">
                        <div class="captcha-code">
                            <asp:Label ID="lbl_captcha_code" runat="server" Text="4X9B2" />
                        </div>
                        <div style="flex: 1;">
                            <asp:TextBox runat="server" ID="txt_captcha_input" placeholder="Captcha" CssClass="input-style" Style="margin-bottom: 0;" />
                        </div>
                    </div>--%>

                    <asp:Button ID="btn_submit" runat="server" Text="સ્લીપ ડાઉનલોડ કરો" CssClass="submit-btn" OnClick="btn_submit_search_Click" />
                    <br />
                    <div style="background-color: black; padding: 8px 90px; margin-top: 15px;">
                        <img src="img/logo%20web.png" style="width: 100%" />
                    </div>
                </div>
            </div>

            <asp:Panel ID="pnl_results" runat="server" Visible="false">
                <div style="text-align: center; margin-bottom: 40px;">
                    <asp:LinkButton ID="btn_back" runat="server" OnClick="btn_back_Click" Style="color: #fff; font-weight: bold;">← ફરીથી સર્ચ કરો</asp:LinkButton>
                </div>
                <asp:ListView ID="list_slip" runat="server">
                    <ItemTemplate>
                        <div class="slip-wrapper">
                            <div id='<%# "slip_" + Eval("id") %>' class="voter-slip-card">
                                <%--<img src="img/cadre.png" class="slip-header-img" />--%>
                                <%--<asp:Image ID="img_candidate_sleep" class="slip-header-img" runat="server" />--%>

                                <div class="booth-container">
                                    <%--<div class="booth-item">
                                        <div class="booth-sub-item">
                                            <span class="booth-label">भाग</span>
                                            <%# Eval("ac_no") %>
                                        </div>
                                    </div>--%>
                                    <div class="booth-item">
                                        <span class="booth-label">બુથ</span>
                                        <%# Eval("part_no") %>
                                    </div>
                                    <div class="booth-item">
                                        <span class="booth-label">ક્રમ</span>
                                        <%# Eval("slnoinpart") %>
                                    </div>
                                </div>

                                <div class="slip-content">
                                    <div class="info-row"><strong>નામ : </strong>&nbsp<%# Eval("full_name") %></div>
                                    <div class="info-row"><strong>પિતા/પતિ : </strong>&nbsp<%# Eval("middle_name") %></div>
                                    <div class="info-row"><strong>જાતિ/ઉમર : </strong>&nbsp<%# Eval("sex_age") %></div>
                                    <div class="info-row"><strong>આઇડિકાર્ડ નં : </strong>&nbsp<%# Eval("idcard_no") %></div>

                                    <div class="polling-station-container">
                                        <strong style="width: 100%; border-bottom: 1px solid #e67e22; margin-bottom: 5px;">મતદાન સ્થળ :</strong><br />
                                        <span style="font-size: 12px;"><%# Eval("polling_location") %></span>
                                    </div>
                                </div>
                                <div class="slip-footer">
                                    <img src="img/logo web.png" class="footer-logo" alt="Company Logo" />

                                </div>
                            </div>

                            <button type="button" class="submit-btn" style="margin-top: 10px; background: #27ae60;"
                                onclick='<%# "captureSlip(\"slip_" + Eval("id") + "\", \"Slip_" + Eval("idcard_no") + "\")" %>'>
                                સ્લીપ ડાઉનલોડ કરો
               
                            </button>
                        </div>
                    </ItemTemplate>
                </asp:ListView>


            </asp:Panel>
        </div>


    </form>

    <script src="https://cdnjs.cloudflare.com/ajax/libs/html2canvas/1.4.1/html2canvas.min.js"></script>
    <script>
        function captureSlip(divId, fileName) {
            const element = document.getElementById(divId);
            // Use scale: 3 for crystal clear text in the image
            html2canvas(element, { scale: 3, useCORS: true }).then(canvas => {
                const link = document.createElement('a');
                link.download = fileName + ".jpg";
                link.href = canvas.toDataURL("image/jpeg", 0.9);
                link.click();
            });
        }
</script>
</body>
</html>
