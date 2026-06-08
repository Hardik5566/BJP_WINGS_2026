<%@ Page Language="C#" AutoEventWireup="true" CodeFile="Chat.aspx.cs" Inherits="AI_Chat" ResponseEncoding="utf-8" %>
<!DOCTYPE html>
<html xmlns="http://www.w3.org/1999/xhtml" lang="gu">
<head runat="server">
    <meta charset="utf-8" />
    <meta http-equiv="Content-Type" content="text/html; charset=utf-8" />
    <meta name="viewport" content="width=device-width, initial-scale=1, maximum-scale=1, viewport-fit=cover" />
    <meta name="theme-color" content="#0f0f10" />
    <title>Election AI</title>
    <link rel="preconnect" href="https://fonts.googleapis.com" />
    <link rel="preconnect" href="https://fonts.gstatic.com" crossorigin="anonymous" />
    <link href="https://fonts.googleapis.com/css2?family=Inter:wght@400;500;600;700&amp;display=swap" rel="stylesheet" />
    <style>
        :root {
            --bg: #0f0f10;
            --bg2: #161618;
            --surface: #1e1e22;
            --surface2: #27272c;
            --text: #f4f4f5;
            --muted: #a1a1aa;
            --border: rgba(255,255,255,.08);
            --accent: #ff7a1a;
            --accent-glow: rgba(255,122,26,.35);
            --user: linear-gradient(135deg, #ff7a1a 0%, #ff5722 100%);
            --max: 820px;
            --header-h: 56px;
            --composer-min: 72px;
        }

        * { box-sizing: border-box; margin: 0; padding: 0; }

        html, body {
            height: 100%;
            overflow: hidden;
            font-family: "Inter", system-ui, -apple-system, sans-serif;
            background: var(--bg);
            color: var(--text);
            -webkit-font-smoothing: antialiased;
        }

        #form1 {
            height: 100%;
            width: 100%;
        }

        .shell {
            position: fixed;
            inset: 0;
            display: flex;
            flex-direction: column;
            background:
                radial-gradient(ellipse 80% 50% at 50% -20%, rgba(255,122,26,.12), transparent),
                radial-gradient(ellipse 60% 40% at 100% 100%, rgba(99,102,241,.08), transparent),
                var(--bg);
        }

        /* ---- Header ---- */
        .bar {
            height: var(--header-h);
            flex-shrink: 0;
            display: flex;
            align-items: center;
            justify-content: center;
            padding: 0 20px;
            border-bottom: 1px solid var(--border);
            background: rgba(15,15,16,.85);
            backdrop-filter: blur(16px);
            -webkit-backdrop-filter: blur(16px);
            z-index: 10;
        }

        .bar-inner {
            width: 100%;
            max-width: var(--max);
            display: flex;
            align-items: center;
            gap: 12px;
        }

        .logo {
            width: 36px;
            height: 36px;
            border-radius: 10px;
            background: var(--user);
            display: flex;
            align-items: center;
            justify-content: center;
            font-weight: 700;
            font-size: 14px;
            color: #fff;
            box-shadow: 0 4px 16px var(--accent-glow);
        }

        .bar-text h1 {
            font-size: 15px;
            font-weight: 600;
            letter-spacing: -.02em;
        }

        .bar-text p {
            font-size: 12px;
            color: var(--muted);
            margin-top: 1px;
        }

        /* ---- Chat (full screen scroll) ---- */
        .messages {
            flex: 1;
            overflow-y: auto;
            overflow-x: hidden;
            -webkit-overflow-scrolling: touch;
            scroll-behavior: smooth;
            padding: 20px 16px calc(var(--composer-min) + 24px);
        }

        .messages-inner {
            max-width: var(--max);
            margin: 0 auto;
            display: flex;
            flex-direction: column;
            gap: 20px;
            min-height: 100%;
        }

        .row {
            display: flex;
            gap: 12px;
            align-items: flex-start;
            animation: fadeUp .35s ease;
        }

        @keyframes fadeUp {
            from { opacity: 0; transform: translateY(8px); }
            to { opacity: 1; transform: translateY(0); }
        }

        .row.user {
            flex-direction: row-reverse;
        }

        .av {
            width: 32px;
            height: 32px;
            border-radius: 50%;
            flex-shrink: 0;
            display: flex;
            align-items: center;
            justify-content: center;
            font-size: 11px;
            font-weight: 700;
        }

        .row.ai .av {
            background: var(--surface2);
            border: 1px solid var(--border);
            color: var(--accent);
        }

        .row.user .av {
            background: var(--surface2);
            color: var(--muted);
        }

        .content {
            max-width: min(100%, 640px);
            font-size: 15px;
            line-height: 1.65;
            word-break: break-word;
        }

        .row.user .content {
            background: var(--user);
            color: #fff;
            padding: 12px 16px;
            border-radius: 20px 20px 4px 20px;
            box-shadow: 0 4px 20px var(--accent-glow);
        }

        .row.ai .content {
            padding: 4px 0;
            color: #e4e4e7;
        }

        .row.ai .content.thinking {
            color: var(--muted);
        }

        .dots span {
            display: inline-block;
            width: 6px;
            height: 6px;
            margin: 0 2px;
            background: var(--muted);
            border-radius: 50%;
            animation: bounce 1.2s infinite;
        }
        .dots span:nth-child(2) { animation-delay: .15s; }
        .dots span:nth-child(3) { animation-delay: .3s; }

        @keyframes bounce {
            0%, 60%, 100% { transform: translateY(0); opacity: .4; }
            30% { transform: translateY(-5px); opacity: 1; }
        }

        .answerList {
            margin: 10px 0 0;
            padding-left: 20px;
            color: #d4d4d8;
        }
        .answerList li { margin: 6px 0; }

        .welcome-card {
            text-align: center;
            padding: 48px 24px 32px;
            margin: auto 0;
        }

        .welcome-card .big-icon {
            width: 64px;
            height: 64px;
            margin: 0 auto 20px;
            border-radius: 20px;
            background: var(--user);
            display: flex;
            align-items: center;
            justify-content: center;
            font-size: 28px;
            box-shadow: 0 8px 32px var(--accent-glow);
        }

        .welcome-card h2 {
            font-size: 22px;
            font-weight: 600;
            margin-bottom: 8px;
        }

        .welcome-card p {
            color: var(--muted);
            font-size: 15px;
            max-width: 360px;
            margin: 0 auto;
            line-height: 1.5;
        }

        /* ---- Fixed bottom composer (full width) ---- */
        .composer-wrap {
            position: fixed;
            left: 0;
            right: 0;
            bottom: 0;
            z-index: 20;
            padding: 12px 16px calc(12px + env(safe-area-inset-bottom));
            background: linear-gradient(180deg, transparent 0%, var(--bg) 28%);
            pointer-events: none;
        }

        .composer-box {
            max-width: var(--max);
            margin: 0 auto;
            pointer-events: auto;
            display: flex;
            align-items: flex-end;
            gap: 10px;
            padding: 8px 8px 8px 18px;
            background: var(--surface);
            border: 1px solid var(--border);
            border-radius: 28px;
            box-shadow:
                0 0 0 1px rgba(255,255,255,.04) inset,
                0 12px 40px rgba(0,0,0,.45);
            transition: border-color .2s, box-shadow .2s;
        }

        .composer-box:focus-within {
            border-color: rgba(255,122,26,.45);
            box-shadow:
                0 0 0 1px rgba(255,122,26,.15) inset,
                0 0 0 4px rgba(255,122,26,.12),
                0 12px 40px rgba(0,0,0,.45);
        }

        #q {
            flex: 1;
            border: none;
            background: transparent;
            color: var(--text);
            font-family: inherit;
            font-size: 16px;
            line-height: 1.45;
            resize: none;
            max-height: 140px;
            min-height: 24px;
            padding: 10px 0;
            outline: none;
        }

        #q::placeholder { color: #71717a; }

        .send {
            width: 44px;
            height: 44px;
            border: none;
            border-radius: 50%;
            flex-shrink: 0;
            cursor: pointer;
            background: var(--user);
            color: #fff;
            display: flex;
            align-items: center;
            justify-content: center;
            transition: transform .15s, opacity .15s;
            box-shadow: 0 4px 14px var(--accent-glow);
        }

        .send:hover:not(:disabled) { transform: scale(1.05); }
        .send:disabled { opacity: .45; cursor: not-allowed; transform: none; }

        .send svg {
            width: 20px;
            height: 20px;
            fill: currentColor;
        }

        /* ---- Result table ---- */
        .row.ai .content.has-table {
            max-width: min(100%, var(--max));
            width: 100%;
        }

        .result-meta {
            margin-bottom: 10px;
            color: #a1a1aa;
            font-size: 13px;
        }

        .result-meta b { color: #fff; }

        .data-table-wrap {
            overflow-x: auto;
            border-radius: 12px;
            border: 1px solid rgba(255,255,255,.1);
            background: rgba(0,0,0,.22);
            -webkit-overflow-scrolling: touch;
        }

        .data-table {
            width: 100%;
            border-collapse: collapse;
            font-size: 13px;
            min-width: 280px;
        }

        .data-table thead th {
            position: sticky;
            top: 0;
            z-index: 1;
            text-align: left;
            padding: 10px 12px;
            background: #1a1a1f;
            color: #f4f4f5;
            font-weight: 600;
            font-size: 12px;
            letter-spacing: .02em;
            border-bottom: 1px solid rgba(255,255,255,.12);
            white-space: nowrap;
        }

        .data-table tbody td {
            padding: 9px 12px;
            border-bottom: 1px solid rgba(255,255,255,.06);
            color: #e4e4e7;
            vertical-align: top;
            max-width: 220px;
            word-break: break-word;
        }

        .data-table tbody tr:last-child td {
            border-bottom: none;
        }

        .data-table tbody tr:hover td {
            background: rgba(255,122,26,.06);
        }

        .result-more {
            margin-top: 8px;
            color: #71717a;
            font-size: 12px;
        }
    </style>
</head>
<body>
    <form id="form1" runat="server">
        <input type="hidden" id="appId" value="1" />

        <div class="shell">
            <header class="bar">
                <div class="bar-inner">
                    <div class="logo">AI</div>
                    <div class="bar-text">
                        <h1>Election AI</h1>
                        <p id="subTitle"></p>
                    </div>
                </div>
            </header>

            <main id="chat" class="messages" aria-live="polite">
                <div id="chatInner" class="messages-inner"></div>
            </main>

            <footer class="composer-wrap">
                <div class="composer-box">
                    <textarea id="q" rows="1" placeholder="" onkeydown="handleKey(event)" oninput="autoGrow(this)"></textarea>
                    <button type="button" id="sendBtn" class="send" onclick="send()" title="Send">
                        <svg viewBox="0 0 24 24"><path d="M3.4 20.4l17.45-7.48c.81-.35.81-1.49 0-1.84L3.4 3.6c-.66-.29-1.39.2-1.35.86l.65 7.2c.03.37.28.68.63.78l5.3 1.5-5.3 1.5c-.35.1-.6.41-.63.78l-.65 7.2c-.04.66.69 1.15 1.35.86z"/></svg>
                    </button>
                </div>
            </footer>
        </div>

        <script>
            var T = {
                subTitle: '\u0AA4\u0AAE\u0ABE\u0AB0\u0ACB \u0AAA\u0ACD\u0AB0\u0AB6\u0ACD\u0AA8 \u0AAA\u0AC2\u0A9B\u0ACB',
                placeholder: '\u0AA4\u0AAE\u0ABE\u0AB0\u0ACB \u0AAA\u0ACD\u0AB0\u0AB6\u0ACD\u0AA8 \u0A85\u0AB9\u0AC0\u0A82 \u0AB2\u0A96\u0ACB...',
                welcome: '\u0A9C\u0AAE\u0AB8\u0ACD\u0AA4\u0AC7! voter, booth, slip \u0A85\u0AA5\u0AB5\u0ABE survey \u0AB5\u0ABF\u0AB6\u0AC7 \u0AAA\u0ACD\u0AB0\u0AB6\u0ACD\u0AA8 \u0AAA\u0AC2\u0A9B\u0AC0 \u0AB6\u0A95\u0ACB \u0A9B\u0ACB.',
                thinking: '\u0AB5\u0ABF\u0A9A\u0ABE\u0AB0\u0AC0 \u0AB0\u0AB9\u0ACD\u0AAF\u0ABE \u0A9B\u0AC0\u0A8F',
                errGeneric: '\u0A95\u0A82\u0A88\u0A95 \u0A96\u0ACB\u0A9F\u0AC1\u0A82 \u0AA5\u0AA4\u0AC1\u0A82. \u0AAB\u0AB0\u0AC0 \u0AAA\u0ACD\u0AB0\u0AAF\u0ABE\u0AB8 \u0A95\u0AB0\u0ACB.',
                noData: '\u0A95\u0ACB\u0A88 \u0AAE\u0ABE\u0AB9\u0ABF\u0AA4\u0AC0 \u0AAE\u0AB3\u0AC0 \u0A8F\u0AA8\u0AC0.',
                total: '\u0A95\u0AC1\u0AB2',
                results: '\u0AAA\u0AB0\u0ABF\u0AA3\u0ABE\u0AAE',
                more: '\u0A85\u0AA8\u0AC7',
                moreEnd: '\u0AB5\u0AA7\u0AC1...',
                badResponse: '\u0A9C\u0AB5\u0ABE\u0AAC \u0AAE\u0AB3\u0ACD\u0AAF\u0ACB \u0A8F\u0AA8\u0AC0. \u0AAB\u0AB0\u0AC0 \u0AAA\u0ACD\u0AB0\u0AAF\u0ABE\u0AB8 \u0A95\u0AB0\u0ACB.',
                netError: '\u0A87\u0AA8\u0ACD\u0A9F\u0AB0\u0AA8\u0AC7\u0A9F \u0A85\u0AA5\u0AB5\u0ABE \u0AB8\u0AB0\u0ACD\u0AB5\u0AB0 \u0AB8\u0AAE\u0AB8\u0ACD\u0AAF\u0ABE. \u0AAB\u0AB0\u0AC0 \u0AAA\u0ACD\u0AB0\u0AAF\u0ABE\u0AB8 \u0A95\u0AB0\u0ACB.',
                serverError: '\u0AB8\u0AB0\u0ACD\u0AB5\u0AB0 \u0AD6\u0AC2\u0AB2'
            };

            (function init() {
                var params = new URLSearchParams(window.location.search);
                var fromUrl = params.get('app_id');
                if (fromUrl && parseInt(fromUrl, 10) > 0) {
                    document.getElementById('appId').value = fromUrl;
                }
                document.getElementById('subTitle').textContent = T.subTitle;
                document.getElementById('q').placeholder = T.placeholder;

                var inner = document.getElementById('chatInner');
                inner.innerHTML =
                    '<div class="welcome-card">' +
                    '<div class="big-icon">&#10024;</div>' +
                    '<h2>Election AI</h2>' +
                    '<p>' + esc(T.welcome) + '</p>' +
                    '</div>';
            })();

            function chatInner() { return document.getElementById('chatInner'); }
            function chatScroll() { return document.getElementById('chat'); }
            function q() { return document.getElementById('q'); }
            function sendBtn() { return document.getElementById('sendBtn'); }
            function appId() { return document.getElementById('appId').value || '1'; }

            function esc(s) {
                if (s == null) return '';
                return ('' + s).replace(/&/g,'&amp;').replace(/</g,'&lt;').replace(/>/g,'&gt;');
            }

            function autoGrow(el) {
                el.style.height = '24px';
                el.style.height = Math.min(el.scrollHeight, 140) + 'px';
            }

            function scrollToBottom() {
                var el = chatScroll();
                el.scrollTop = el.scrollHeight;
            }

            function clearWelcome() {
                var w = chatInner().querySelector('.welcome-card');
                if (w) w.remove();
            }

            function addMessage(role, html, extraClass) {
                clearWelcome();
                var row = document.createElement('div');
                row.className = 'row ' + role;

                var av = document.createElement('div');
                av.className = 'av';
                av.textContent = role === 'user' ? 'You' : 'AI';

                var content = document.createElement('div');
                content.className = 'content' + (extraClass ? ' ' + extraClass : '');
                if (extraClass === 'thinking') {
                    content.innerHTML = '<span class="dots"><span></span><span></span><span></span></span>';
                } else {
                    content.innerHTML = html;
                }

                row.appendChild(av);
                row.appendChild(content);
                chatInner().appendChild(row);
                scrollToBottom();
                return content;
            }

            function handleKey(e) {
                if (e.key === 'Enter' && !e.shiftKey) {
                    e.preventDefault();
                    send();
                }
            }

            function parseApiJson(text) {
                var s = (text || '').trim();
                if (!s || (s.charAt(0) !== '{' && s.charAt(0) !== '[')) throw new Error('Invalid');
                return JSON.parse(s);
            }

            function prettifyHeader(name) {
                if (!name) return '';
                return esc(String(name).replace(/_/g, ' '));
            }

            function makeDataTable(cols, rows, total) {
                if (!cols || !cols.length) return esc(T.noData);
                var max = Math.min(rows ? rows.length : 0, 100);
                var html = '';
                if (total > 1) {
                    html += '<div class="result-meta">' + esc(T.total) + ' <b>' + total + '</b> ' + esc(T.results) + '</div>';
                }
                html += '<div class="data-table-wrap"><table class="data-table"><thead><tr>';
                for (var i = 0; i < cols.length; i++) {
                    html += '<th>' + prettifyHeader(cols[i]) + '</th>';
                }
                html += '</tr></thead><tbody>';
                for (var r = 0; r < max; r++) {
                    html += '<tr>';
                    var line = rows[r] || [];
                    for (var c = 0; c < cols.length; c++) {
                        var val = line[c];
                        html += '<td>' + (val != null && val !== '' ? esc(String(val)) : '—') + '</td>';
                    }
                    html += '</tr>';
                }
                html += '</tbody></table></div>';
                if (total > max) {
                    html += '<div class="result-more">' + esc(T.more) + ' ' + (total - max) + ' ' + esc(T.moreEnd) + '</div>';
                }
                return html;
            }

            function formatAnswer(res) {
                if (!res || res.status !== '1') {
                    var msg = esc((res && res.message) ? res.message : T.errGeneric);
                    var isAzure = res && (res.error_type === 'azure_dns' || res.error_type === 'azure_config' || res.error_type === 'azure_network');
                    if (isAzure) {
                        return '<div style="color:#fca5a5">' + msg + '</div>';
                    }
                    return msg;
                }
                var n = res.row_count || 0;
                if (n === 0) return esc(T.noData);

                var cols = res.columns || [];
                var rows = res.rows || [];

                // Multiple records -> always table with headers
                if (n > 1) {
                    return makeDataTable(cols, rows, n);
                }

                // Single value (one column)
                if (n === 1 && cols.length === 1) {
                    return '<div style="font-size:28px;font-weight:600;">' + esc(String(rows[0][0] != null ? rows[0][0] : '')) + '</div>';
                }

                // Single row, multiple columns -> table (one row with headers)
                if (n === 1 && cols.length > 1) {
                    return makeDataTable(cols, rows, n);
                }

                return esc(T.noData);
            }

            function send() {
                var question = (q().value || '').trim();
                if (!question) { q().focus(); return; }

                addMessage('user', esc(question));
                q().value = '';
                autoGrow(q());
                sendBtn().disabled = true;

                var placeholder = addMessage('ai', '', 'thinking');

                var controller = (window.AbortController ? new AbortController() : null);
                var signal = controller ? controller.signal : undefined;
                var timedOut = false;
                var t = setTimeout(function () {
                    timedOut = true;
                    try { if (controller) controller.abort(); } catch (e) { }
                }, 120000); // 120s (Azure + SQL)

                // after 12s, show "still working" text under dots
                var slow = setTimeout(function () {
                    if (placeholder && placeholder.className.indexOf('thinking') >= 0) {
                        placeholder.innerHTML =
                            '<span class="dots"><span></span><span></span><span></span></span>' +
                            '<div style="margin-top:10px;color:#a1a1aa;font-size:13px">' +
                            esc(T.thinking) + '...' +
                            '</div>';
                    }
                }, 12000);

                var params = new URLSearchParams(window.location.search);
                var debug = params.get('debug') === '1';
                var apiUrl = debug ? 'ElectionAIHandler.ashx?debug=1' : 'ElectionAIHandler.ashx';

                fetch(apiUrl, {
                    method: 'POST',
                    headers: { 'Content-Type': 'application/x-www-form-urlencoded; charset=UTF-8' },
                    body: 'user_question=' + encodeURIComponent(question) + '&app_id=' + encodeURIComponent(appId()),
                    credentials: 'same-origin',
                    signal: signal
                })
                .then(function (r) {
                    return r.text().then(function (text) {
                        if (!r.ok) throw new Error(T.serverError);
                        return text;
                    });
                })
                .then(function (text) {
                    try {
                        placeholder.className = 'content';
                        var html = formatAnswer(parseApiJson(text));
                        placeholder.innerHTML = html;
                        if (html.indexOf('data-table') >= 0) {
                            placeholder.classList.add('has-table');
                        }
                    } catch (ex) {
                        placeholder.className = 'content';
                        placeholder.textContent = T.badResponse;
                    }
                    clearTimeout(t);
                    clearTimeout(slow);
                    sendBtn().disabled = false;
                    q().focus();
                    scrollToBottom();
                })
                .catch(function (err) {
                    placeholder.className = 'content';
                    if (timedOut) {
                        placeholder.textContent = 'Timeout. Server no response. Please try again.';
                    } else if (err && ('' + err).toLowerCase().indexOf('abort') >= 0) {
                        placeholder.textContent = 'Timeout. Please try again.';
                    } else {
                        placeholder.textContent = T.netError;
                    }
                    clearTimeout(t);
                    clearTimeout(slow);
                    sendBtn().disabled = false;
                    q().focus();
                    scrollToBottom();
                });
            }

            q().focus();
        </script>
    </form>
</body>
</html>
