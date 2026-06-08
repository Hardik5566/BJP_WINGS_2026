<%@ Page Language="C#" AutoEventWireup="true" CodeFile="app_alert_page.aspx.cs" Inherits="app_alert_page" %>

<!DOCTYPE html>

<html xmlns="http://www.w3.org/1999/xhtml">
<head runat="server">
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0, maximum-scale=1.0, user-scalable=no">
    <title>Event Alert</title>
    <style>
        @import url('https://fonts.googleapis.com/css2?family=Hind+Gujarati:wght@400;600;700&family=Outfit:wght@800&display=swap');

        :root {
            --rally-orange: #FF4D00;
            --rally-dark: #1A1A1A;
        }

        body {
            font-family: 'Hind Gujarati', sans-serif;
            margin: 0;
            padding: 0;
            background: #fff;
            color: var(--rally-dark);
        }

        /* High Impact Top Alert */
        .alert-banner {
            background: var(--rally-orange);
            color: white;
            padding: 12px;
            text-align: center;
            font-weight: bold;
            text-transform: uppercase;
            letter-spacing: 1px;
            font-size: 14px;
            position: sticky;
            top: 0;
            z-index: 100;
        }

        /* Hero Image Section */
        .hero-container {
            width: 100%;
            height: 250px;
            position: relative;
            overflow: hidden;
        }

        .hero-image {
            width: 100%;
            height: 100%;
            object-fit: cover;
            filter: brightness(0.8);
        }

        .hero-overlay {
            position: absolute;
            bottom: 0;
            left: 0;
            right: 0;
            background: linear-gradient(transparent, rgba(0,0,0,0.8));
            padding: 20px;
            color: white;
        }

        /* Event Details */
        .content {
            padding: 25px;
            margin-top: -30px;
        }

        .info-card {
            background: white;
            border-radius: 24px;
            padding: 25px;
            box-shadow: 0 15px 35px rgba(0,0,0,0.1);
            position: relative;
        }

        .date-box {
            display: inline-block;
            background: #FEE2E2;
            color: #DC2626;
            padding: 8px 16px;
            border-radius: 50px;
            font-weight: 700;
            margin-bottom: 15px;
        }

        h1 {
            font-size: 28px;
            margin: 0 0 15px 0;
            line-height: 1.3;
            color: #000;
        }

        p {
            font-size: 16px;
            color: #4B5563;
            line-height: 1.6;
        }

        /* Icon List for Info */
        .details-list {
            margin: 25px 0;
        }

        .detail-item {
            display: flex;
            align-items: center;
            margin-bottom: 15px;
            background: #F9FAFB;
            padding: 12px;
            border-radius: 12px;
        }

        .icon-circle {
            width: 40px;
            height: 40px;
            background: white;
            border-radius: 10px;
            display: flex;
            align-items: center;
            justify-content: center;
            margin-right: 15px;
            font-size: 20px;
            box-shadow: 0 2px 5px rgba(0,0,0,0.05);
        }

        /* Action Button */
        .btn-action {
            display: block;
            padding: 18px;
            background: var(--rally-orange);
            color: white;
            text-align: center;
            text-decoration: none;
            border-radius: 16px;
            font-size: 18px;
            font-weight: 700;
            box-shadow: 0 10px 20px rgba(255, 77, 0, 0.3);
            margin-top: 20px;
        }

        .footer-text {
            text-align: center;
            margin-top: 20px;
            font-size: 12px;
            color: #9CA3AF;
        }
    </style>
</head>
<body>
    <form id="form1" runat="server">
      
        <div class="hero-container">
            <img src="img/popup/LoksabhaelectionBanner.jpg" class="hero-image" alt="Rally Image">
            <div class="hero-overlay">
                <div style="font-size: 14px; opacity: 0.9;">મહા આયોજન</div>
                <div style="font-size: 22px; font-weight: 700;">બાઇક રેલી અને જાહેર સભા</div>
            </div>
        </div>

        <div class="content">
            <div class="info-card">
                <div class="date-box">📅 આગામી 30 તારીખ</div>

                <h1>બાઇક રેલી અને સભાનું ભવ્ય આયોજન</h1>

                <p>તમામ કાર્યકર્તા મિત્રો અને નાગરિકોને નમ્ર વિનંતી કે આ વિરાટ આયોજનમાં જોડાઈને કાર્યક્રમને સફળ બનાવે.</p>

                <div class="details-list">
                    <div class="detail-item">
                        <div class="icon-circle">📍</div>
                        <div>
                            <div style="font-size: 12px; color: #999;">સ્થળ</div>
                            <strong style="font-size: 14px;">મુખ્ય બજારથી ટાઉન હોલ સુધી</strong>
                        </div>
                    </div>
                    <div class="detail-item">
                        <div class="icon-circle">🕒</div>
                        <div>
                            <div style="font-size: 12px; color: #999;">સમય</div>
                            <strong style="font-size: 14px;">સવારે ૦૯:૦૦ કલાકે</strong>
                        </div>
                    </div>
                </div>

                <a href="#" class="btn-action">રજીસ્ટ્રેશન કરો</a>
            </div>

            <div class="footer-text">વધુ માહિતી માટે સંપર્ક કરો: +91 98XXX XXXXX</div>
        </div>
    </form>
</body>
</html>
