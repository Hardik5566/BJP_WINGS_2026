<%@ Page Language="C#" AutoEventWireup="true" CodeFile="BulkPrachar.aspx.cs" Inherits="BulkPrachar" %>
<!DOCTYPE html>
<html lang="en">
<head runat="server">
  <meta charset="UTF-8" />
  <meta name="viewport" content="width=device-width, initial-scale=1.0, maximum-scale=1.0" />
  <title>Bulk Prachar — BJP WINGS</title>
  <link href="https://fonts.googleapis.com/css2?family=Noto+Sans+Gujarati:wght@400;500;600;700&family=Source+Sans+3:wght@400;500;600;700&display=swap" rel="stylesheet">
  <style>
    :root{
      --gold:#b8860b;
      --gold-dark:#8b6914;
      --saffron:#e67e22;
      --green:#1e7a3a;
      --bg:#f4f6f9;
      --surface:#ffffff;
      --text:#1a1f2e;
      --muted:#5c6370;
      --border:#d8dde6;
      --shadow:0 4px 14px rgba(26,31,46,.08);
    }
    *,*::before,*::after{box-sizing:border-box;margin:0;padding:0}
    html,body{height:100%}
    body{
      max-width:430px;
      margin:0 auto;
      min-height:100vh;
      background:var(--bg);
      color:var(--text);
      font-family:'Source Sans 3',system-ui,sans-serif;
      -webkit-font-smoothing:antialiased;
      overflow-x:hidden;
    }
    a{color:inherit;text-decoration:none}
    .wrap{padding:16px 14px 28px}
    .brand{display:flex;align-items:center;gap:12px;padding:6px 2px 4px}
    .brand img{width:48px;height:auto}
    .brand-title{font-family:'Source Sans 3',sans-serif;font-weight:700;font-size:22px;line-height:1.1;letter-spacing:-0.02em;color:var(--text)}
    .brand-sub{margin-top:4px;font-family:'Source Sans 3',sans-serif;font-size:11px;font-weight:600;letter-spacing:.12em;text-transform:uppercase;color:var(--muted)}
    .tricolor{display:flex;height:3px;margin:12px 2px 14px;border:1px solid var(--border)}
    .tricolor span{flex:1;height:100%}
    .tricolor .t1{background:#ff9933}
    .tricolor .t2{background:#ffffff}
    .tricolor .t3{background:#138808}
    .sec-h{margin:4px 2px 12px}
    .kicker{font-family:'Source Sans 3',sans-serif;font-size:10px;font-weight:700;letter-spacing:.18em;text-transform:uppercase;color:var(--gold-dark)}
    .sec-title{margin-top:6px;font-family:'Source Sans 3',sans-serif;font-size:20px;font-weight:700;color:var(--text);line-height:1.2}
    .card{border:1px solid var(--border);background:var(--surface);border-radius:0;box-shadow:var(--shadow);overflow:hidden}
    .svc-icon{flex-shrink:0;width:36px;height:36px;display:flex;align-items:center;justify-content:center;color:var(--gold-dark);background:var(--surface);border:1px solid var(--border)}
    .svc-icon svg{width:20px;height:20px;display:block}
    .svc-icon svg path{fill:currentColor}
    .list-card{display:flex;align-items:center;justify-content:space-between;gap:10px;padding:14px 12px;cursor:pointer;-webkit-tap-highlight-color:transparent;user-select:none}
    .list-left{display:flex;align-items:center;gap:10px;min-width:0}
    .list-title{font-family:'Noto Sans Gujarati',sans-serif;font-size:15px;font-weight:800;line-height:1.4;color:var(--text);white-space:nowrap;overflow:hidden;text-overflow:ellipsis}
    .chev{flex-shrink:0;width:34px;height:34px;display:flex;align-items:center;justify-content:center;border:1px solid var(--border);background:#f8f9fb;color:var(--gold-dark)}
    .chev svg{width:18px;height:18px;display:block}
    .chev svg path{fill:currentColor}
    .modal{position:fixed;inset:0;background:rgba(26,31,46,.65);display:none;align-items:center;justify-content:center;padding:16px;z-index:999}
    .modal.show{display:flex}
    .modal-card{width:100%;max-width:430px;border-radius:0;overflow:hidden;border:1px solid var(--border);background:var(--surface);box-shadow:0 20px 50px rgba(26,31,46,.2);position:relative}
    .modal-top{padding:11px 12px;border-bottom:1px solid var(--border);display:flex;align-items:center;justify-content:space-between;gap:10px;background:#eef1f6}
    .modal-top .t{font-family:'Source Sans 3',sans-serif;font-weight:700;letter-spacing:.1em;text-transform:uppercase;font-size:10px;color:var(--text)}
    .close{border-radius:0;padding:8px 12px;cursor:pointer;background:var(--surface);border:1px solid var(--border);color:var(--text);font-family:'Source Sans 3',sans-serif;font-weight:700;letter-spacing:.08em;text-transform:uppercase;font-size:10px}
    .modal-body{padding:12px}
    .yt{width:100%;aspect-ratio:16/9;border:1px solid var(--border);border-radius:0;overflow:hidden;background:#000}
    .yt iframe{width:100%;height:100%;border:0;display:block}
    .rate{border:1px solid var(--border);border-radius:0;overflow:hidden;background:var(--surface)}
    .rate .row{display:flex;align-items:center;justify-content:space-between;gap:12px;padding:11px 12px;border-bottom:1px solid var(--border);font-family:'Source Sans 3',sans-serif;letter-spacing:.04em}
    .rate .row:last-child{border-bottom:none}
    .rate .k{color:var(--muted);font-size:11px;font-weight:700;text-transform:uppercase}
    .rate .v{color:var(--gold-dark);font-size:12px;font-weight:700}
    .note{margin-top:10px;font-family:'Source Sans 3',sans-serif;font-size:13px;line-height:1.5;color:var(--muted)}
    .modal-footer{padding:12px;border-top:1px solid var(--border);display:grid;grid-template-columns:1fr auto;gap:10px;background:#f8f9fb}
    .modal-footer .btn{width:100%}
    .btn{border:none;border-radius:0;padding:12px 8px;font-family:'Source Sans 3',sans-serif;font-size:11px;font-weight:700;letter-spacing:.1em;text-transform:uppercase;cursor:pointer;display:flex;align-items:center;justify-content:center;gap:6px;user-select:none;-webkit-tap-highlight-color:transparent}
    .btn-wa{color:#fff;background:var(--green);border:1px solid #16632d}
    .btn-ghost{background:var(--surface);border:1px solid var(--border);color:var(--text)}
    .btn:active{opacity:.88}
    .btn svg{width:17px;height:17px;flex-shrink:0}
    .btn-wa svg path{fill:#fff}
    .card-spaced{margin-top:12px}
    .svc-desc{margin-bottom:12px;font-family:'Noto Sans Gujarati',sans-serif;font-size:14px;line-height:1.55;color:var(--muted)}
    .video-wrap{position:relative;border:1px solid var(--border);background:#000}
    .video-cap{position:absolute;left:10px;right:10px;bottom:8px;z-index:2;display:flex;flex-direction:column;gap:3px;pointer-events:none}
    .video-cap .cap-title{font-family:'Source Sans 3',sans-serif;font-size:9px;font-weight:700;letter-spacing:.18em;text-transform:uppercase;color:rgba(255,255,255,.92)}
    .video-cap .cap-sub{font-family:'Noto Sans Gujarati',sans-serif;font-size:12px;line-height:1.45;color:#fff;font-weight:600}
  </style>
</head>
<body>
  <form id="form1" runat="server">
    <div class="wrap">
      <div class="brand">
        <img src="OtherPage/bjp_only_logo.png" alt="Logo" />
        <div>
          <div class="brand-title">BJP WINGS</div>
          <div class="brand-sub">Bulk Prachar Module</div>
        </div>
      </div>
      <div class="tricolor" aria-hidden="true"><span class="t1"></span><span class="t2"></span><span class="t3"></span></div>

      <div class="sec-h">
        <div class="kicker">Services</div>
        <div class="sec-title">Bulk Prachar Types</div>
      </div>

      <asp:Repeater ID="rptServices" runat="server">
        <ItemTemplate>
          <div class="card<%# Container.ItemIndex > 0 ? " card-spaced" : "" %>">
            <div class="list-card" role="button" tabindex="0"
                 data-open-detail
                 data-title='<%# Eval("Title") %>'
                 data-video='<%# Eval("VideoId") %>'
                 data-rate='<%# Eval("RateKey") %>'>
              <div class="list-left">
                <span class="svc-icon" aria-hidden="true"><%# Eval("IconSvg") %></span>
                <div class="list-title"><%# Eval("Title") %></div>
              </div>
              <span class="chev" aria-hidden="true">
                <svg viewBox="0 0 24 24" xmlns="http://www.w3.org/2000/svg"><path d="M9 6l6 6-6 6"/></svg>
              </span>
            </div>
          </div>
        </ItemTemplate>
      </asp:Repeater>
    </div>

    <div class="modal" id="detailModal" aria-hidden="true">
      <div class="modal-card" role="dialog" aria-modal="true" aria-label="Bulk Prachar Detail">
        <div class="modal-top">
          <div class="t" id="detailTitle">DETAIL</div>
          <button class="close" type="button" data-close>Close</button>
        </div>
        <div class="modal-body">
          <div class="svc-desc" id="detailDescription"></div>
          <div class="video-wrap yt">
            <iframe id="detailVideoFrame" src="" title="YouTube video" allow="accelerometer; autoplay; clipboard-write; encrypted-media; gyroscope; picture-in-picture; web-share" allowfullscreen></iframe>
            <div class="video-cap">
              <div class="cap-title" id="detailVideoTitle">Sample Video</div>
              <div class="cap-sub" id="detailVideoSubtitle"></div>
            </div>
          </div>
          <div class="note" id="detailHint">If video does not play, tap "Open in YouTube".</div>
          <div style="margin-top:12px;">
            <div class="rate" id="detailRateBox"></div>
          </div>
        </div>
        <div class="modal-footer">
          <a class="btn btn-wa" id="detailWhatsApp" href="#" target="_blank" rel="noopener">
            <svg viewBox="0 0 24 24" xmlns="http://www.w3.org/2000/svg" aria-hidden="true"><path d="M20.52 3.48A11.91 11.91 0 0 0 12.06 0C5.5 0 .16 5.34.16 11.9c0 2.1.55 4.14 1.6 5.95L0 24l6.31-1.65a11.88 0 0 0 5.75 1.47h.01c6.56 0 11.9-5.34 11.9-11.9 0-3.18-1.24-6.16-3.45-8.44zm-8.46 18.3h-.01a9.9 9.9 0 0 1-5.04-1.38l-.36-.21-3.74.98.99-3.65-.23-.38a9.85 0  1 1 8.39 4.64z" fill="rgba(0,0,0,.9)"/></svg>
            WhatsApp Now
          </a>
          <a class="btn btn-ghost" id="detailYouTube" href="#" target="_blank" rel="noopener">Open in YouTube</a>
        </div>
      </div>
    </div>
  </form>

  <script type="text/javascript">
    window.pracharRateData = JSON.parse('<%= HttpUtility.JavaScriptStringEncode(RateDataJson ?? "{}", true) %>');
    window.pracharWhatsApp = '<%= BulkPrachar.WhatsAppNumber %>';
    window.pracharTotalMobile = '<%= TotalMobileDisplay %>';
    window.pracharTotalVoters = '<%= TotalVotersDisplay %>';

    (function () {
      var rateData = window.pracharRateData || {};
      var waNumber = window.pracharWhatsApp || '919998092970';
      var globalMobile = window.pracharTotalMobile || '—';
      var globalVoters = window.pracharTotalVoters || '—';

      var detailModal = document.getElementById('detailModal');
      var detailTitle = document.getElementById('detailTitle');
      var detailVideoFrame = document.getElementById('detailVideoFrame');
      var detailHint = document.getElementById('detailHint');
      var detailWhatsApp = document.getElementById('detailWhatsApp');
      var detailYouTube = document.getElementById('detailYouTube');
      var detailRateBox = document.getElementById('detailRateBox');
      var detailDescription = document.getElementById('detailDescription');
      var detailVideoTitle = document.getElementById('detailVideoTitle');
      var detailVideoSubtitle = document.getElementById('detailVideoSubtitle');

      function showModal(m) {
        m.classList.add('show');
        document.body.style.overflow = 'hidden';
      }
      function hideModal(m) {
        m.classList.remove('show');
        document.body.style.overflow = '';
      }

      function closeDetail() {
        if (!detailModal) return;
        hideModal(detailModal);
        if (detailVideoFrame) detailVideoFrame.src = '';
        if (detailHint) detailHint.textContent = 'If video does not play, tap "Open in YouTube".';
        if (detailWhatsApp) detailWhatsApp.href = '#';
        if (detailYouTube) detailYouTube.href = '#';
        if (detailRateBox) detailRateBox.innerHTML = '';
        if (detailDescription) detailDescription.textContent = '';
        if (detailVideoTitle) detailVideoTitle.textContent = 'Sample Video';
        if (detailVideoSubtitle) detailVideoSubtitle.textContent = '';
      }

      function extractYouTubeId(input) {
        if (!input) return '';
        var s = String(input).trim();
        if (!/[/?=&]/.test(s)) return s;
        var m = s.match(/youtu\.be\/([a-zA-Z0-9_-]{6,})/);
        if (m && m[1]) return m[1];
        m = s.match(/[?&]v=([a-zA-Z0-9_-]{6,})/);
        if (m && m[1]) return m[1];
        m = s.match(/youtube\.com\/shorts\/([a-zA-Z0-9_-]{6,})/);
        if (m && m[1]) return m[1];
        m = s.match(/youtube\.com\/embed\/([a-zA-Z0-9_-]{6,})/);
        if (m && m[1]) return m[1];
        return '';
      }

      function buildRateHtml(data) {
        if (!data) return '';
        var rows = [
          ['Vidhansabha', data.vidhansabhaIdName || '—'],
          ['Total Voter', data.totalVoters || globalVoters],
          ['Total Mobile No', data.totalMobileNos || globalMobile],
          [data.unitCostLabel || 'Unit Cost', data.unitCostValue || '—'],
          ['Total Cost', data.totalCost || '—'],
          ['Status', data.status || 'Contact to Start Campaign']
        ];
        return rows.map(function (row) {
          return '<div class="row"><div class="k">' + row[0] + '</div><div class="v">' + row[1] + '</div></div>';
        }).join('');
      }

      function openDetail(titleText, videoId, rateType) {
        if (!detailModal) return;
        var id = extractYouTubeId(videoId);
        if (!id) {
          if (detailHint) detailHint.textContent = 'Invalid YouTube link/ID. Please check and try again.';
          return;
        }

        var rate = rateData[rateType] || rateData.sleep;

        if (detailTitle) detailTitle.textContent = titleText || 'DETAIL';
        if (detailDescription) detailDescription.textContent = rate.description || '';
        if (detailVideoTitle) detailVideoTitle.textContent = rate.videoTitle || 'Sample Video';
        if (detailVideoSubtitle) detailVideoSubtitle.textContent = rate.videoSubtitle || '';
        if (detailHint) detailHint.textContent = 'If video does not play, tap "Open in YouTube".';
        if (detailYouTube) detailYouTube.href = 'https://www.youtube.com/watch?v=' + encodeURIComponent(id);
        if (detailVideoFrame) {
          detailVideoFrame.src = 'https://www.youtube-nocookie.com/embed/' + encodeURIComponent(id) + '?rel=0&playsinline=1&autoplay=1';
        }
        if (detailRateBox) detailRateBox.innerHTML = buildRateHtml(rate);
        if (detailWhatsApp && rate) detailWhatsApp.href = 'https://wa.me/' + waNumber + '?text=' + (rate.waText || '');

        showModal(detailModal);
      }

      document.addEventListener('click', function (e) {
        if (e.target.closest('[data-close]')) {
          if (detailModal && detailModal.classList.contains('show')) closeDetail();
          return;
        }
        if (detailModal && e.target === detailModal) closeDetail();

        var listCard = e.target.closest('[data-open-detail]');
        if (listCard) {
          openDetail(
            listCard.getAttribute('data-title') || 'DETAIL',
            listCard.getAttribute('data-video') || '',
            listCard.getAttribute('data-rate') || 'sleep'
          );
        }
      });

      window.addEventListener('keydown', function (e) {
        if (e.key === 'Escape' && detailModal && detailModal.classList.contains('show')) closeDetail();
      });
    })();
  </script>
</body>
</html>
