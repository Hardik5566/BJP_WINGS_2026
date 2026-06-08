<%@ Page Language="C#" AutoEventWireup="true" CodeFile="GroupChat.aspx.cs" Inherits="GroupChat_GroupChat" ResponseEncoding="utf-8" %>
<!DOCTYPE html>
<html lang="gu">
<head runat="server">
    <meta charset="utf-8" />
    <meta name="viewport" content="width=device-width, initial-scale=1, maximum-scale=1, user-scalable=no, viewport-fit=cover" />
    <meta name="theme-color" content="#075e54" />
    <meta name="apple-mobile-web-app-capable" content="yes" />
    <title>Team Group Chat</title>
    <link rel="preconnect" href="https://fonts.googleapis.com" />
    <link href="https://fonts.googleapis.com/css2?family=Segoe+UI:wght@400;500;600;700&display=swap" rel="stylesheet" />
    <style>
        :root {
            --wa-header: #075e54;
            --wa-header-dark: #054640;
            --wa-accent: #25d366;
            --wa-bg: #e5ddd5;
            --wa-bg-pattern: url("data:image/svg+xml,%3Csvg width='60' height='60' viewBox='0 0 60 60' xmlns='http://www.w3.org/2000/svg'%3E%3Cg fill='none' fill-rule='evenodd'%3E%3Cg fill='%23d4cdc4' fill-opacity='0.45'%3E%3Cpath d='M36 34v-4h-2v4h-4v2h4v4h2v-4h4v-2h-4zm0-30V0h-2v4h-4v2h4v4h2V6h4V4h-4zM6 34v-4H4v4H0v2h4v4h2v-4h4v-2H6zM6 4V0H4v4H0v2h4v4h2V6h4V4H6z'/%3E%3C/g%3E%3C/g%3E%3C/svg%3E");
            --wa-in: #ffffff;
            --wa-out: #d9fdd3;
            --wa-text: #111b21;
            --wa-muted: #667781;
            --wa-border: #e9edef;
            --wa-shadow: 0 1px 0.5px rgba(11,20,26,.13);
            --safe-b: env(safe-area-inset-bottom, 0px);
        }

        * { box-sizing: border-box; margin: 0; padding: 0; }
        html, body { height: 100%; overflow: hidden; }
        body {
            font-family: "Segoe UI", system-ui, -apple-system, sans-serif;
            background: var(--wa-bg);
            color: var(--wa-text);
            -webkit-font-smoothing: antialiased;
            touch-action: manipulation;
        }

        #form1 { height: 100%; }

        .app {
            display: flex;
            flex-direction: column;
            height: 100%;
            max-width: 720px;
            margin: 0 auto;
            background: var(--wa-bg);
            position: relative;
        }

        /* ---- Login ---- */
        .login-screen {
            position: fixed; inset: 0; z-index: 100;
            display: flex; align-items: center; justify-content: center;
            background: linear-gradient(160deg, #075e54 0%, #128c7e 100%);
            padding: 24px;
        }
        .login-screen.hidden { display: none; }
        .login-card {
            width: 100%; max-width: 380px;
            background: #fff; border-radius: 12px;
            padding: 28px 24px; box-shadow: 0 8px 32px rgba(0,0,0,.2);
        }
        .login-card .logo {
            width: 64px; height: 64px; border-radius: 50%;
            background: var(--wa-header); color: #fff;
            display: flex; align-items: center; justify-content: center;
            font-size: 28px; margin: 0 auto 16px;
        }
        .login-card h2 { text-align: center; font-size: 20px; margin-bottom: 6px; }
        .login-card p { text-align: center; color: var(--wa-muted); font-size: 13px; margin-bottom: 20px; }
        .field { margin-bottom: 14px; }
        .field label { display: block; font-size: 12px; font-weight: 600; color: var(--wa-muted); margin-bottom: 6px; }
        .field input, .field select {
            width: 100%; padding: 12px 14px; border: 1px solid var(--wa-border);
            border-radius: 8px; font-size: 15px; outline: none;
        }
        .field input:focus, .field select:focus { border-color: var(--wa-header); }
        .btn-join {
            width: 100%; margin-top: 8px; padding: 14px;
            background: var(--wa-accent); color: #fff; border: none;
            border-radius: 8px; font-size: 16px; font-weight: 600; cursor: pointer;
        }
        .btn-join:active { opacity: .9; }
        .login-err { color: #e53935; font-size: 13px; text-align: center; margin-top: 10px; min-height: 18px; }

        /* ---- Header ---- */
        .header {
            flex-shrink: 0; height: 60px;
            background: var(--wa-header);
            color: #fff; display: flex; align-items: center;
            padding: 0 8px 0 4px; gap: 4px;
            box-shadow: 0 1px 3px rgba(0,0,0,.2);
            z-index: 10;
        }
        .header-btn {
            width: 40px; height: 40px; border: none; background: transparent;
            color: #fff; border-radius: 50%; cursor: pointer;
            display: flex; align-items: center; justify-content: center;
            font-size: 20px;
        }
        .header-btn:active { background: rgba(255,255,255,.1); }
        .header-info { flex: 1; min-width: 0; cursor: pointer; padding: 4px 8px; }
        .header-info h1 {
            font-size: 16px; font-weight: 500; white-space: nowrap;
            overflow: hidden; text-overflow: ellipsis;
        }
        .header-info p { font-size: 12px; opacity: .85; margin-top: 1px; }

        /* ---- Messages ---- */
        .messages-wrap {
            flex: 1; overflow-y: auto; overflow-x: hidden;
            background: var(--wa-bg) var(--wa-bg-pattern);
            padding: 8px 12px 12px;
            -webkit-overflow-scrolling: touch;
        }
        .load-more {
            text-align: center; padding: 8px;
            font-size: 12px; color: var(--wa-muted);
        }
        .load-more button {
            background: rgba(255,255,255,.9); border: none; border-radius: 16px;
            padding: 6px 14px; font-size: 12px; color: var(--wa-header);
            cursor: pointer; box-shadow: var(--wa-shadow);
        }
        .date-sep {
            text-align: center; margin: 12px 0;
            font-size: 12px; color: var(--wa-muted);
        }
        .date-sep span {
            background: rgba(255,255,255,.92); padding: 4px 12px;
            border-radius: 8px; box-shadow: var(--wa-shadow);
        }

        .msg-row {
            display: flex; margin-bottom: 2px;
        }
        .msg-row.msg-new {
            animation: fadeIn .2s ease;
        }
        @keyframes fadeIn { from { opacity: 0; transform: translateY(4px); } to { opacity: 1; transform: none; } }
        .msg-row.out { justify-content: flex-end; }
        .msg-row.in { justify-content: flex-start; }

        .bubble-wrap { max-width: 82%; position: relative; }
        .sender-name {
            font-size: 12px; font-weight: 600; color: #e542a3;
            margin: 0 8px 2px; padding-left: 2px;
        }
        .msg-row.out .sender-name { display: none; }

        .bubble {
            padding: 6px 8px 4px;
            border-radius: 8px;
            box-shadow: var(--wa-shadow);
            position: relative;
            word-wrap: break-word;
        }
        .msg-row.in .bubble { background: var(--wa-in); border-top-left-radius: 0; }
        .msg-row.out .bubble { background: var(--wa-out); border-top-right-radius: 0; }

        .reply-preview {
            border-left: 3px solid var(--wa-accent);
            background: rgba(0,0,0,.04);
            border-radius: 4px; padding: 4px 8px; margin-bottom: 4px;
            font-size: 12px;
        }
        .reply-preview .rp-name { color: var(--wa-header); font-weight: 600; }
        .reply-preview .rp-text { color: var(--wa-muted); white-space: nowrap; overflow: hidden; text-overflow: ellipsis; }

        .bubble-text { font-size: 14.2px; line-height: 1.35; white-space: pre-wrap; padding-right: 4px; }
        .bubble-media img {
            max-width: 100%; border-radius: 6px; display: block; cursor: pointer;
            max-height: 280px; object-fit: cover;
        }
        .bubble-media video { max-width: 100%; border-radius: 6px; display: block; max-height: 280px; }
        .file-card {
            display: flex; align-items: center; gap: 10px;
            background: rgba(0,0,0,.04); border-radius: 6px; padding: 8px;
            text-decoration: none; color: inherit;
        }
        .file-icon {
            width: 40px; height: 40px; background: var(--wa-header);
            border-radius: 6px; display: flex; align-items: center; justify-content: center;
            color: #fff; font-size: 18px; flex-shrink: 0;
        }
        .file-meta { min-width: 0; }
        .file-meta .fn { font-size: 13px; font-weight: 500; white-space: nowrap; overflow: hidden; text-overflow: ellipsis; }
        .file-meta .fs { font-size: 11px; color: var(--wa-muted); }

        .bubble-meta {
            display: flex; justify-content: flex-end; align-items: center;
            gap: 4px; margin-top: 2px;
        }
        .bubble-time { font-size: 11px; color: var(--wa-muted); }

        /* ---- Reply bar ---- */
        .reply-bar {
            display: none; align-items: center; gap: 8px;
            background: #f0f2f5; padding: 8px 12px;
            border-top: 1px solid var(--wa-border);
        }
        .reply-bar.show { display: flex; }
        .reply-bar-info { flex: 1; min-width: 0; border-left: 3px solid var(--wa-accent); padding-left: 10px; }
        .reply-bar-info .rb-name { font-size: 12px; color: var(--wa-header); font-weight: 600; }
        .reply-bar-info .rb-text { font-size: 13px; color: var(--wa-muted); white-space: nowrap; overflow: hidden; text-overflow: ellipsis; }
        .reply-bar-close { background: none; border: none; font-size: 20px; color: var(--wa-muted); cursor: pointer; padding: 4px; }

        /* ---- Composer ---- */
        .composer {
            flex-shrink: 0;
            background: #f0f2f5;
            padding: 6px 8px calc(6px + var(--safe-b));
            display: flex; align-items: flex-end; gap: 6px;
            border-top: 1px solid var(--wa-border);
        }
        .composer-btn {
            width: 42px; height: 42px; border: none; background: transparent;
            color: var(--wa-muted); border-radius: 50%; cursor: pointer;
            display: flex; align-items: center; justify-content: center;
            font-size: 22px; flex-shrink: 0;
        }
        .composer-btn:active { background: rgba(0,0,0,.06); }
        .composer-input-wrap {
            flex: 1; background: #fff; border-radius: 24px;
            padding: 4px 12px; min-height: 42px;
            display: flex; align-items: center;
        }
        #txtMessage {
            width: 100%; border: none; outline: none; resize: none;
            font-size: 15px; font-family: inherit;
            max-height: 100px; line-height: 1.4; padding: 8px 0;
            background: transparent;
        }
        .btn-send {
            width: 42px; height: 42px; border: none;
            background: var(--wa-header); color: #fff;
            border-radius: 50%; cursor: pointer;
            display: flex; align-items: center; justify-content: center;
            font-size: 18px; flex-shrink: 0;
        }
        .btn-send:disabled { opacity: .5; cursor: default; }
        .btn-send:not(:disabled):active { background: var(--wa-header-dark); }

        #fileInput { display: none; }

        /* ---- Members panel ---- */
        .overlay {
            position: fixed; inset: 0; background: rgba(0,0,0,.4);
            z-index: 50; opacity: 0; pointer-events: none; transition: opacity .2s;
        }
        .overlay.show { opacity: 1; pointer-events: auto; }
        .members-panel {
            position: fixed; top: 0; right: 0; bottom: 0; width: min(320px, 88vw);
            background: #fff; z-index: 51; transform: translateX(100%);
            transition: transform .25s ease; display: flex; flex-direction: column;
            box-shadow: -4px 0 20px rgba(0,0,0,.15);
        }
        .members-panel.show { transform: translateX(0); }
        .panel-head {
            background: var(--wa-header); color: #fff;
            padding: 16px; font-size: 16px; font-weight: 500;
        }
        .panel-list { flex: 1; overflow-y: auto; }
        .member-item {
            display: flex; align-items: center; gap: 12px;
            padding: 12px 16px; border-bottom: 1px solid var(--wa-border);
        }
        .member-av {
            width: 40px; height: 40px; border-radius: 50%;
            background: #dfe5e7; object-fit: cover; flex-shrink: 0;
            display: flex; align-items: center; justify-content: center;
            font-size: 16px; font-weight: 600; color: var(--wa-header);
        }
        .member-av img { width: 100%; height: 100%; border-radius: 50%; object-fit: cover; }
        .member-info { min-width: 0; }
        .member-info .mn { font-size: 15px; font-weight: 500; }
        .member-info .md { font-size: 12px; color: var(--wa-muted); }

        /* ---- Lightbox ---- */
        .lightbox {
            position: fixed; inset: 0; z-index: 200;
            background: rgba(0,0,0,.92); display: none;
            align-items: center; justify-content: center; padding: 16px;
        }
        .lightbox.show { display: flex; }
        .lightbox img { max-width: 100%; max-height: 100%; object-fit: contain; }
        .lightbox-close {
            position: absolute; top: 16px; right: 16px;
            background: rgba(255,255,255,.2); border: none; color: #fff;
            width: 40px; height: 40px; border-radius: 50%; font-size: 22px; cursor: pointer;
        }

        /* ---- Context menu ---- */
        .ctx-menu {
            position: fixed; z-index: 150; background: #fff;
            border-radius: 8px; box-shadow: 0 4px 20px rgba(0,0,0,.2);
            min-width: 140px; display: none; overflow: hidden;
        }
        .ctx-menu.show { display: block; }
        .ctx-menu button {
            display: block; width: 100%; text-align: left;
            padding: 12px 16px; border: none; background: #fff;
            font-size: 14px; cursor: pointer;
        }
        .ctx-menu button:active { background: #f0f2f5; }
        .ctx-menu .danger { color: #e53935; }

        .typing-hint { font-size: 11px; color: rgba(255,255,255,.7); }
        .hidden { display: none !important; }

        @media (min-width: 721px) {
            .app { box-shadow: 0 0 20px rgba(0,0,0,.12); height: 100vh; }
        }
    </style>
</head>
<body>
<form id="form1" runat="server">
    <!-- Login -->
    <div id="loginScreen" class="login-screen">
        <div class="login-card">
            <div class="logo">💬</div>
            <h2>Team Group Chat</h2>
            <p>Enter your App ID and User ID to join</p>
            <div class="field">
                <label>App ID</label>
                <input type="number" id="loginAppId" placeholder="e.g. 1" min="1" />
            </div>
            <div class="field">
                <label>User</label>
                <select id="loginUserId"><option value="">— Select user —</option></select>
            </div>
            <button type="button" class="btn-join" id="btnJoin">Join Chat</button>
            <div class="login-err" id="loginErr"></div>
        </div>
    </div>

    <div id="chatApp" class="app hidden">
        <!-- Header -->
        <header class="header">
            <button type="button" class="header-btn" id="btnMembers" title="Members">👥</button>
            <div class="header-info" id="btnHeaderInfo">
                <h1 id="groupTitle">Team Group</h1>
                <p id="groupSub"><span id="memberCount">0</span> members</p>
            </div>
            <button type="button" class="header-btn" id="btnLogout" title="Switch user">↩</button>
        </header>

        <!-- Messages -->
        <div class="messages-wrap" id="messagesWrap">
            <div class="load-more" id="loadMoreWrap">
                <button type="button" id="btnLoadOlder">Load older messages</button>
            </div>
            <div id="messagesList"></div>
        </div>

        <!-- Reply bar -->
        <div class="reply-bar" id="replyBar">
            <div class="reply-bar-info">
                <div class="rb-name" id="replyBarName"></div>
                <div class="rb-text" id="replyBarText"></div>
            </div>
            <button type="button" class="reply-bar-close" id="btnCancelReply">×</button>
        </div>

        <!-- Composer -->
        <div class="composer">
            <button type="button" class="composer-btn" id="btnAttach" title="Attach">📎</button>
            <input type="file" id="fileInput" accept="image/*,video/*,.pdf,.doc,.docx,.xls,.xlsx,.txt,.zip" />
            <div class="composer-input-wrap">
                <textarea id="txtMessage" rows="1" placeholder="Type a message"></textarea>
            </div>
            <button type="button" class="btn-send" id="btnSend" title="Send">➤</button>
        </div>
    </div>

    <!-- Members panel -->
    <div class="overlay" id="overlay"></div>
    <aside class="members-panel" id="membersPanel">
        <div class="panel-head">Group Members</div>
        <div class="panel-list" id="membersList"></div>
    </aside>

    <!-- Lightbox -->
    <div class="lightbox" id="lightbox">
        <button type="button" class="lightbox-close" id="btnLightboxClose">×</button>
        <img id="lightboxImg" src="" alt="" />
    </div>

    <!-- Context menu -->
    <div class="ctx-menu" id="ctxMenu">
        <button type="button" data-action="reply">Reply</button>
        <button type="button" data-action="delete" class="danger hidden" id="ctxDelete">Delete</button>
    </div>
</form>

<script>
(function () {
    'use strict';

    var API = 'GroupChatHandler.ashx';
    var UPLOAD = 'ChatUploadHandler.ashx';
    var POLL_MS = 2500;
    var PAGE_SIZE = 50;

    var state = {
        appId: '',
        userId: '',
        userName: '',
        messages: [],
        members: [],
        lastMsgId: 0,
        firstMsgId: 0,
        hasOlder: true,
        replyTo: null,
        pollTimer: null,
        ctxMsg: null,
        loading: false,
        sending: false,
        renderedIds: {}
    };

    var $ = function (id) { return document.getElementById(id); };

    function baseUrl() {
        var p = location.pathname.replace(/\/[^/]*$/, '/');
        return location.origin + p;
    }

    function resolveUrl(path) {
        if (!path) return '';
        if (/^https?:\/\//i.test(path)) return path;
        var root = location.pathname.split('/GroupChat/')[0] || '';
        return location.origin + root + '/' + path.replace(/^\/+/, '');
    }

    function avatarHtml(photo, name) {
        var letter = (name || '?').charAt(0).toUpperCase();
        if (photo) {
            return '<img src="' + esc(resolveUrl(photo)) + '" alt="" onerror="this.parentNode.textContent=\'' + esc(letter) + '\'" />';
        }
        return esc(letter);
    }

    function esc(s) {
        if (s == null) return '';
        return String(s).replace(/&/g,'&amp;').replace(/</g,'&lt;').replace(/>/g,'&gt;').replace(/"/g,'&quot;');
    }

    function fmtTime(dt) {
        if (!dt) return '';
        var d = new Date(dt);
        if (isNaN(d)) return dt;
        return d.toLocaleTimeString('en-IN', { hour: '2-digit', minute: '2-digit', hour12: true });
    }

    function fmtDate(dt) {
        if (!dt) return '';
        var d = new Date(dt);
        if (isNaN(d)) return dt;
        var today = new Date();
        if (d.toDateString() === today.toDateString()) return 'Today';
        var y = new Date(today); y.setDate(y.getDate() - 1);
        if (d.toDateString() === y.toDateString()) return 'Yesterday';
        return d.toLocaleDateString('en-IN', { day: 'numeric', month: 'short', year: 'numeric' });
    }

    function fmtSize(bytes) {
        if (!bytes) return '';
        if (bytes < 1024) return bytes + ' B';
        if (bytes < 1048576) return (bytes / 1024).toFixed(1) + ' KB';
        return (bytes / 1048576).toFixed(1) + ' MB';
    }

    function post(action, data) {
        var fd = new FormData();
        fd.append('action', action);
        fd.append('app_id', state.appId);
        fd.append('user_id', state.userId);
        Object.keys(data || {}).forEach(function (k) {
            if (data[k] != null && data[k] !== '') fd.append(k, data[k]);
        });
        return fetch(API, { method: 'POST', body: fd, credentials: 'same-origin' })
            .then(function (r) { return r.json(); });
    }

    function saveSession() {
        try {
            localStorage.setItem('bjp_chat_app', state.appId);
            localStorage.setItem('bjp_chat_user', state.userId);
            localStorage.setItem('bjp_chat_name', state.userName || '');
        } catch (e) {}
    }

    function loadSession() {
        try {
            return {
                appId: localStorage.getItem('bjp_chat_app') || '',
                userId: localStorage.getItem('bjp_chat_user') || '',
                userName: localStorage.getItem('bjp_chat_name') || ''
            };
        } catch (e) { return {}; }
    }

    function clearSession() {
        try {
            localStorage.removeItem('bjp_chat_app');
            localStorage.removeItem('bjp_chat_user');
            localStorage.removeItem('bjp_chat_name');
        } catch (e) {}
    }

    function showLogin() {
        stopPoll();
        $('chatApp').classList.add('hidden');
        $('loginScreen').classList.remove('hidden');
        state.appId = ''; state.userId = '';
    }

    function showChat() {
        $('loginScreen').classList.add('hidden');
        $('chatApp').classList.remove('hidden');
    }

    function getMsgById(id) {
        id = Number(id);
        for (var i = 0; i < state.messages.length; i++) {
            if (state.messages[i].message_id === id) return state.messages[i];
        }
        return null;
    }

    function loadUsersForLogin(appId) {
        var sel = $('loginUserId');
        sel.innerHTML = '<option value="">— Loading users... —</option>';
        $('loginErr').textContent = '';
        if (!appId) {
            sel.innerHTML = '<option value="">— Select user —</option>';
            return Promise.resolve();
        }
        var fd = new FormData();
        fd.append('action', 'users');
        fd.append('app_id', appId);
        return fetch(API, { method: 'POST', body: fd, credentials: 'same-origin' })
            .then(function (r) { return r.json(); })
            .then(function (res) {
                sel.innerHTML = '<option value="">— Select user —</option>';
                if (res.Success !== '1') {
                    $('loginErr').textContent = res.message || 'Could not load users.';
                    return;
                }
                var list = res.users || res.members || [];
                if (list.length === 0) {
                    $('loginErr').textContent = 'No active users found for this App ID.';
                    return;
                }
                list.forEach(function (m) {
                    var opt = document.createElement('option');
                    opt.value = m.user_id;
                    opt.textContent = m.name + (m.designation ? ' (' + m.designation + ')' : '');
                    sel.appendChild(opt);
                });
            })
            .catch(function () {
                sel.innerHTML = '<option value="">— Select user —</option>';
                $('loginErr').textContent = 'Network error loading users.';
            });
    }

    function joinChat(appId, userId) {
        $('loginErr').textContent = '';
        if (!appId || !userId) {
            $('loginErr').textContent = 'Please select App ID and User.';
            return;
        }
        state.appId = String(appId);
        state.userId = String(userId);
        saveSession();
        initChat();
    }

    function initChat() {
        showChat();
        state.messages = [];
        state.lastMsgId = 0;
        state.firstMsgId = 0;
        state.hasOlder = true;
        state.renderedIds = {};
        $('messagesList').innerHTML = '';
        loadMembers().then(function () {
            var me = state.members.find(function (m) { return String(m.user_id) === state.userId; });
            state.userName = me ? me.name : (loadSession().userName || 'You');
            saveSession();
            return loadMessages(false);
        }).then(function () {
            startPoll();
            scrollBottom();
        }).catch(function (e) {
            alert(e.message || 'Failed to load chat.');
            showLogin();
        });
    }

    function loadMembers() {
        return post('members', {}).then(function (res) {
            if (res.Success !== '1') throw new Error(res.message || 'Failed to load members.');
            state.members = res.members || res.users || [];
            $('memberCount').textContent = state.members.length;
            renderMembersPanel();
        });
    }

    function renderMembersPanel() {
        var html = state.members.map(function (m) {
            return '<div class="member-item">' +
                '<div class="member-av">' + avatarHtml(m.photo, m.name) + '</div>' +
                '<div class="member-info"><div class="mn">' + esc(m.name) + '</div>' +
                '<div class="md">' + esc(m.designation || m.user_type || '') + '</div></div></div>';
        }).join('');
        $('membersList').innerHTML = html || '<div style="padding:16px;color:#667781">No members</div>';
    }

    function loadMessages(older) {
        if (state.loading) return Promise.resolve();
        state.loading = true;
        var params = { limit: String(PAGE_SIZE) };
        if (older && state.firstMsgId > 0) {
            params.before_msg_id = String(state.firstMsgId);
        }
        return post('messages', params).then(function (res) {
            state.loading = false;
            if (res.Success !== '1') throw new Error(res.message || 'Load failed.');
            var batch = res.messages || [];
            if (older) {
                if (batch.length < PAGE_SIZE) state.hasOlder = false;
                if (batch.length === 0) { state.hasOlder = false; return; }
                var wrap = $('messagesWrap');
                var prevH = wrap.scrollHeight;
                mergeMessages(batch, true);
                prependMessagesToDom(batch);
                wrap.scrollTop = wrap.scrollHeight - prevH;
            } else {
                mergeMessages(batch, false);
                renderMessages();
                if (batch.length > 0) {
                    state.lastMsgId = Math.max(state.lastMsgId, batch[batch.length - 1].message_id);
                }
            }
            $('loadMoreWrap').style.display = state.hasOlder ? 'block' : 'none';
        }).catch(function (e) {
            state.loading = false;
            throw e;
        });
    }

    function pollNew() {
        if (!state.appId || state.loading) return;
        post('messages', { after_msg_id: String(state.lastMsgId), limit: '100' }).then(function (res) {
            if (res.Success !== '1') return;
            var batch = res.messages || [];
            var newOnes = batch.filter(function (m) { return !state.renderedIds[m.message_id]; });
            if (newOnes.length === 0) return;
            var atBottom = isNearBottom();
            mergeMessages(newOnes, false);
            appendMessagesToDom(newOnes);
            state.lastMsgId = newOnes[newOnes.length - 1].message_id;
            if (atBottom) scrollBottom();
        });
    }

    function mergeMessages(batch, prepend) {
        var map = {};
        state.messages.forEach(function (m) { map[m.message_id] = m; });
        batch.forEach(function (m) { map[m.message_id] = m; });
        state.messages = Object.keys(map).map(function (k) { return map[k]; });
        state.messages.sort(function (a, b) { return a.message_id - b.message_id; });
        if (state.messages.length) {
            state.firstMsgId = state.messages[0].message_id;
            state.lastMsgId = state.messages[state.messages.length - 1].message_id;
        }
    }

    function isNearBottom() {
        var w = $('messagesWrap');
        return w.scrollHeight - w.scrollTop - w.clientHeight < 80;
    }

    function scrollBottom() {
        var w = $('messagesWrap');
        requestAnimationFrame(function () { w.scrollTop = w.scrollHeight; });
    }

    function renderDateSep(dateLabel) {
        return '<div class="date-sep" data-date="' + esc(dateLabel) + '"><span>' + esc(dateLabel) + '</span></div>';
    }

    function getLastDateInList(listEl) {
        var seps = listEl.querySelectorAll('.date-sep');
        if (!seps.length) return '';
        return seps[seps.length - 1].getAttribute('data-date') || '';
    }

    function appendMessagesToDom(batch) {
        if (!batch || !batch.length) return;
        var list = $('messagesList');
        var lastDate = getLastDateInList(list);
        var html = '';
        batch.forEach(function (m) {
            if (state.renderedIds[m.message_id]) return;
            var dateLabel = fmtDate(m.create_date);
            if (dateLabel !== lastDate) {
                html += renderDateSep(dateLabel);
                lastDate = dateLabel;
            }
            html += renderBubble(m, true);
            state.renderedIds[m.message_id] = true;
        });
        if (html) list.insertAdjacentHTML('beforeend', html);
    }

    function prependMessagesToDom(batch) {
        if (!batch || !batch.length) return;
        var list = $('messagesList');
        var lastDate = '';
        var html = '';
        batch.forEach(function (m) {
            if (state.renderedIds[m.message_id]) return;
            var dateLabel = fmtDate(m.create_date);
            if (dateLabel !== lastDate) {
                html += renderDateSep(dateLabel);
                lastDate = dateLabel;
            }
            html += renderBubble(m, false);
            state.renderedIds[m.message_id] = true;
        });
        if (!html) return;

        var firstRow = list.querySelector('.msg-row');
        if (firstRow && lastDate) {
            var firstDate = firstRow.getAttribute('data-date');
            var firstSep = list.querySelector('.date-sep');
            if (firstSep && firstDate === lastDate && firstSep.getAttribute('data-date') === firstDate) {
                firstSep.parentNode.removeChild(firstSep);
            }
        }
        list.insertAdjacentHTML('afterbegin', html);
    }

    function renderMessages() {
        state.renderedIds = {};
        var html = '';
        var lastDate = '';
        state.messages.forEach(function (m) {
            var dateLabel = fmtDate(m.create_date);
            if (dateLabel !== lastDate) {
                html += renderDateSep(dateLabel);
                lastDate = dateLabel;
            }
            html += renderBubble(m, false);
            state.renderedIds[m.message_id] = true;
        });
        $('messagesList').innerHTML = html;
    }

    function renderBubble(m, isNew) {
        var isOut = String(m.sender_user_id) === state.userId;
        var cls = isOut ? 'out' : 'in';
        var anim = isNew ? ' msg-new' : '';
        var dateLabel = fmtDate(m.create_date);
        var html = '<div class="msg-row ' + cls + anim + '" data-id="' + m.message_id + '" data-date="' + esc(dateLabel) + '">';
        html += '<div class="bubble-wrap">';
        if (!isOut) html += '<div class="sender-name">' + esc(m.sender_name) + '</div>';
        html += '<div class="bubble" data-id="' + m.message_id + '">';

        if (m.reply_to_msg_id) {
            html += '<div class="reply-preview"><div class="rp-name">' + esc(m.reply_sender_name || '') + '</div>';
            html += '<div class="rp-text">' + esc(m.reply_message_text || m.reply_msg_type || '') + '</div></div>';
        }

        html += renderContent(m);
        html += '<div class="bubble-meta"><span class="bubble-time">' + esc(fmtTime(m.create_date)) + '</span></div>';
        html += '</div></div></div>';
        return html;
    }

    function renderContent(m) {
        var t = (m.msg_type || '').toUpperCase();
        if (t === 'TEXT') {
            return '<div class="bubble-text">' + esc(m.message_text) + '</div>';
        }
        var url = resolveUrl(m.file_path);
        if (t === 'IMAGE') {
            var cap = m.message_text ? '<div class="bubble-text">' + esc(m.message_text) + '</div>' : '';
            return '<div class="bubble-media"><img src="' + esc(url) + '" alt="" data-full="' + esc(url) + '" />' + cap + '</div>';
        }
        if (t === 'VIDEO') {
            var cap2 = m.message_text ? '<div class="bubble-text">' + esc(m.message_text) + '</div>' : '';
            return '<div class="bubble-media"><video src="' + esc(url) + '" controls playsinline preload="metadata"></video>' + cap2 + '</div>';
        }
        return '<a class="file-card" href="' + esc(url) + '" target="_blank" download>' +
            '<div class="file-icon">📄</div>' +
            '<div class="file-meta"><div class="fn">' + esc(m.file_name || 'File') + '</div>' +
            '<div class="fs">' + esc(fmtSize(m.file_size)) + '</div></div></a>' +
            (m.message_text ? '<div class="bubble-text">' + esc(m.message_text) + '</div>' : '');
    }

    function sendText() {
        var text = ($('txtMessage').value || '').trim();
        if (!text || state.sending) return;
        state.sending = true;
        $('btnSend').disabled = true;
        var data = { msg_type: 'TEXT', message_text: text };
        if (state.replyTo) data.reply_to_msg_id = String(state.replyTo.message_id);
        post('send', data).then(function (res) {
            state.sending = false;
            $('btnSend').disabled = false;
            if (res.Success !== '1') { alert(res.message || 'Send failed.'); return; }
            $('txtMessage').value = '';
            autoResizeInput();
            cancelReply();
            if (res.message) {
                mergeMessages([res.message], false);
                appendMessagesToDom([res.message]);
                state.lastMsgId = res.message.message_id;
                scrollBottom();
            }
        }).catch(function () {
            state.sending = false;
            $('btnSend').disabled = false;
            alert('Network error.');
        });
    }

    function sendFile(file) {
        if (!file || state.sending) return;
        state.sending = true;
        $('btnSend').disabled = true;
        var fd = new FormData();
        fd.append('app_id', state.appId);
        fd.append('user_id', state.userId);
        fd.append('file', file);
        fetch(UPLOAD, { method: 'POST', body: fd }).then(function (r) { return r.json(); }).then(function (up) {
            if (up.Success !== '1') throw new Error(up.message || 'Upload failed.');
            var data = {
                msg_type: up.msg_type,
                file_path: up.file_path,
                file_name: up.file_name,
                file_ext: up.file_ext,
                file_size: String(up.file_size),
                file_type: up.file_type,
                message_text: ($('txtMessage').value || '').trim()
            };
            if (state.replyTo) data.reply_to_msg_id = String(state.replyTo.message_id);
            return post('send', data);
        }).then(function (res) {
            state.sending = false;
            $('btnSend').disabled = false;
            $('txtMessage').value = '';
            autoResizeInput();
            cancelReply();
            if (res.Success !== '1') { alert(res.message || 'Send failed.'); return; }
            if (res.message) {
                mergeMessages([res.message], false);
                appendMessagesToDom([res.message]);
                state.lastMsgId = res.message.message_id;
                scrollBottom();
            }
        }).catch(function (e) {
            state.sending = false;
            $('btnSend').disabled = false;
            alert(e.message || 'Upload failed.');
        });
    }

    function deleteMessage(msg) {
        if (!confirm('Delete this message?')) return;
        post('delete', { message_id: String(msg.message_id) }).then(function (res) {
            if (res.Success !== '1') { alert(res.message || 'Delete failed.'); return; }
            state.messages = state.messages.filter(function (m) { return m.message_id !== msg.message_id; });
            delete state.renderedIds[msg.message_id];
            var row = $('messagesList').querySelector('.msg-row[data-id="' + msg.message_id + '"]');
            if (row) row.parentNode.removeChild(row);
        });
    }

    function setReply(msg) {
        state.replyTo = msg;
        $('replyBar').classList.add('show');
        $('replyBarName').textContent = msg.sender_name || '';
        var preview = msg.message_text || msg.file_name || msg.msg_type || '';
        $('replyBarText').textContent = preview;
        $('txtMessage').focus();
    }

    function cancelReply() {
        state.replyTo = null;
        $('replyBar').classList.remove('show');
    }

    function autoResizeInput() {
        var ta = $('txtMessage');
        ta.style.height = 'auto';
        ta.style.height = Math.min(ta.scrollHeight, 100) + 'px';
    }

    function startPoll() {
        stopPoll();
        state.pollTimer = setInterval(pollNew, POLL_MS);
    }

    function stopPoll() {
        if (state.pollTimer) clearInterval(state.pollTimer);
        state.pollTimer = null;
    }

    function showCtx(e, msg) {
        e.preventDefault();
        state.ctxMsg = msg;
        var menu = $('ctxMenu');
        var canDelete = String(msg.sender_user_id) === state.userId;
        $('ctxDelete').classList.toggle('hidden', !canDelete);
        menu.classList.add('show');
        menu.style.left = Math.min(e.clientX, window.innerWidth - 150) + 'px';
        menu.style.top = Math.min(e.clientY, window.innerHeight - 100) + 'px';
    }

    function hideCtx() {
        $('ctxMenu').classList.remove('show');
        state.ctxMsg = null;
    }

    /* ---- Events ---- */
    $('loginAppId').addEventListener('change', function () {
        loadUsersForLogin(this.value);
    });
    $('loginAppId').addEventListener('input', function () {
        loadUsersForLogin(this.value);
    });

    $('btnJoin').addEventListener('click', function () {
        joinChat($('loginAppId').value, $('loginUserId').value);
    });

    $('btnLogout').addEventListener('click', function () {
        clearSession();
        showLogin();
    });

    $('btnSend').addEventListener('click', sendText);
    $('txtMessage').addEventListener('keydown', function (e) {
        if (e.key === 'Enter' && !e.shiftKey) { e.preventDefault(); sendText(); }
    });
    $('txtMessage').addEventListener('input', autoResizeInput);

    $('btnAttach').addEventListener('click', function () { $('fileInput').click(); });
    $('fileInput').addEventListener('change', function () {
        if (this.files && this.files[0]) sendFile(this.files[0]);
        this.value = '';
    });

    $('btnLoadOlder').addEventListener('click', function () { loadMessages(true); });
    $('btnCancelReply').addEventListener('click', cancelReply);

    $('btnMembers').addEventListener('click', function () {
        $('overlay').classList.add('show');
        $('membersPanel').classList.add('show');
    });
    $('btnHeaderInfo').addEventListener('click', function () {
        $('overlay').classList.add('show');
        $('membersPanel').classList.add('show');
    });
    $('overlay').addEventListener('click', function () {
        $('overlay').classList.remove('show');
        $('membersPanel').classList.remove('show');
    });

    $('messagesList').addEventListener('click', function (e) {
        var img = e.target.closest('img[data-full]');
        if (img) {
            $('lightboxImg').src = img.getAttribute('data-full');
            $('lightbox').classList.add('show');
        }
    });
    $('btnLightboxClose').addEventListener('click', function () {
        $('lightbox').classList.remove('show');
    });
    $('lightbox').addEventListener('click', function (e) {
        if (e.target === $('lightbox')) $('lightbox').classList.remove('show');
    });

    $('messagesList').addEventListener('contextmenu', function (e) {
        var bubble = e.target.closest('.bubble');
        if (!bubble) return;
        var msg = getMsgById(bubble.getAttribute('data-id'));
        if (msg) showCtx(e, msg);
    });
    $('messagesList').addEventListener('touchstart', function (e) {
        var bubble = e.target.closest('.bubble');
        if (!bubble) return;
        var timer = setTimeout(function () {
            var msg = getMsgById(bubble.getAttribute('data-id'));
            if (!msg) return;
            var touch = e.touches[0];
            showCtx({ clientX: touch.clientX, clientY: touch.clientY, preventDefault: function () {} }, msg);
        }, 500);
        bubble.addEventListener('touchend', function () { clearTimeout(timer); }, { once: true });
        bubble.addEventListener('touchmove', function () { clearTimeout(timer); }, { once: true });
    });

    $('ctxMenu').addEventListener('click', function (e) {
        var btn = e.target.closest('button[data-action]');
        if (!btn || !state.ctxMsg) return;
        var action = btn.getAttribute('data-action');
        var msg = state.ctxMsg;
        hideCtx();
        if (action === 'reply') setReply(msg);
        if (action === 'delete') deleteMessage(msg);
    });
    document.addEventListener('click', function (e) {
        if (!$('ctxMenu').contains(e.target)) hideCtx();
    });

    /* ---- Boot ---- */
    var qs = new URLSearchParams(location.search);
    var sess = loadSession();
    var appId = qs.get('app_id') || sess.appId;
    var userId = qs.get('user_id') || sess.userId;

    if (appId) $('loginAppId').value = appId;

    if (appId && userId) {
        loadUsersForLogin(appId).then(function () {
            $('loginUserId').value = userId;
            joinChat(appId, userId);
        });
    } else if (appId) {
        loadUsersForLogin(appId);
        showLogin();
    } else {
        showLogin();
    }
})();
</script>
</body>
</html>
