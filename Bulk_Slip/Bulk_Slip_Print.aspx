<%@ Page Language="C#" AutoEventWireup="true" CodeFile="Bulk_Slip_Print.aspx.cs" Inherits="Bulk_Slip_Bulk_Slip_Print" %>
<!DOCTYPE html>
<html lang="gu">
<head runat="server">
    <meta charset="UTF-8" />
    <meta name="viewport" content="width=device-width, initial-scale=1.0, maximum-scale=1.0, user-scalable=no" />
    <title>Bulk Slip Print — Booth <%= BoothDisplay %></title>
    <link href="https://fonts.googleapis.com/css2?family=Noto+Sans+Devanagari:wght@400&display=swap" rel="stylesheet" />
    <script src="https://cdnjs.cloudflare.com/ajax/libs/html2canvas/1.4.1/html2canvas.min.js"></script>
    <style>
        :root { --bg: #0f172a; --card: #1e293b; --line: #334155; --accent: #2dd4bf; --warn: #f59e0b; }
        *, *::before, *::after { box-sizing: border-box; margin: 0; padding: 0; }
        body {
            max-width: 430px; margin: 0 auto; min-height: 100vh;
            background: var(--bg); color: #e2e8f0;
            font-family: "Noto Sans Devanagari", sans-serif;
            padding-bottom: calc(110px + env(safe-area-inset-bottom, 0px));
        }
        .top-bar {
            padding: 14px 16px; padding-top: max(14px, env(safe-area-inset-top));
            background: var(--card); border-bottom: 1px solid var(--line);
        }
        .top-bar h1 { font-size: 1rem; font-weight: 700; }
        .top-bar p { font-size: 0.72rem; color: #94a3b8; margin-top: 4px; }
        .booth-tag {
            display: inline-block; margin-top: 8px; padding: 6px 12px;
            background: rgba(45, 212, 191, 0.15); color: var(--accent);
            border: 1px solid rgba(45, 212, 191, 0.35); border-radius: 8px; font-size: 0.85rem;
        }
        .section { padding: 12px 14px 0; }
        .card {
            background: var(--card); border-radius: 12px; padding: 12px;
            border: 1px solid var(--line); margin-bottom: 12px;
        }
        .progress-row { display: flex; justify-content: space-between; font-size: 0.82rem; margin-bottom: 8px; }
        .progress-bg { background: #334155; height: 10px; border-radius: 5px; overflow: hidden; }
        #mainBar { width: 0%; height: 100%; background: linear-gradient(90deg, #3b82f6, var(--accent)); transition: width 0.3s; }
        .status-live {
            min-height: 48px; padding: 10px; margin-top: 10px;
            background: #0f172a; border-radius: 8px; font-size: 0.88rem;
            border: 1px dashed var(--line); text-align: center;
        }
        .status-live.printing { border-color: var(--warn); color: #fcd34d; }
        .status-live.done { border-color: var(--accent); color: var(--accent); }
        .bt-dot { width: 8px; height: 8px; border-radius: 50%; background: #ef4444; display: inline-block; margin-right: 8px; }
        .bt-dot.on { background: #22c55e; }
        .bt-dropdown, .btn-connect {
            width: 100%; margin-top: 8px; padding: 12px; border-radius: 10px;
            font-family: inherit; font-size: 0.86rem; font-weight: 600;
        }
        .bt-dropdown { border: 1.5px solid var(--line); background: #0f172a; color: #fff; }
        .btn-connect { border: none; background: #fff; color: #111; }
        .preview-wrap {
            background: #d4d4d4; border-radius: 12px; padding: 14px 10px;
            display: flex; justify-content: center; overflow-x: auto;
        }
        .thermal-paper {
            width: auto; max-width: 325px; flex-shrink: 0;
            background: #fff; box-shadow: 0 4px 14px rgba(0,0,0,.15);
        }
        .slip, .slip * { font-weight: 400; }
        #slipPrintBoost, #slipPrintBoost * { font-weight: 400; }
        .slip {
            position: relative; overflow: hidden;
            padding: 14px 10px; color: #000; font-size: 18px; line-height: 1.45;
        }
        .slip-head { display: flex; align-items: center; justify-content: space-between; gap: 8px; margin-bottom: 10px; }
        .slip-logo { width: 52px; height: 52px; object-fit: contain; }
        .slip-party {
            flex: 1; min-width: 0; text-align: center;
            font-size: 16px; line-height: 1.25;
            display: -webkit-box; -webkit-box-orient: vertical;
            -webkit-line-clamp: 2; overflow: hidden;
            word-break: break-word;
        }
        .slip-dash-box { border: 2px dashed #000; padding: 12px 8px; text-align: center; margin: 10px 0 12px; }
        .slip-dash-box .corp { font-size: 17px; }
        .slip-dash-box .panel { font-size: 22px; margin-top: 5px; }
        .slip-meta-box { display: flex; border: 1px solid #000; margin-bottom: 12px; }
        .slip-meta-item { flex: 1; text-align: center; padding: 10px 5px; border-right: 1px solid #000; }
        .slip-meta-item:last-child { border-right: none; }
        .slip-meta-lbl { display: block; font-size: 13px; margin-bottom: 5px; }
        .slip-meta-val { display: block; font-size: 20px; }
        .slip-line { margin-bottom: 9px; font-size: 17px; }
        .slip-loc { margin-top: 8px; font-size: 16px; line-height: 1.45; }
        .cand-row { display: flex; border: 1px solid #000; margin-bottom: 8px; min-height: 48px; }
        .cand-num { width: 36px; display: flex; align-items: center; justify-content: center; font-size: 18px; border-right: 1px solid #000; }
        .cand-name { flex: 1; padding: 8px 10px; font-size: 15px; display: flex; align-items: center; }
        .slip-msg { text-align: center; font-size: 14px; margin: 10px 0; }
        .slip-thanks { text-align: center; font-size: 26px; }
        .slip-cut-line {
            display: flex; align-items: center; justify-content: center;
            gap: 8px; margin-top: 12px; padding: 6px 2px 4px;
            font-size: 16px; color: #000;
        }
        .slip-cut-line .cut-dash { flex: 1; border-top: 2px dashed #000; height: 0; }
        .slip-cut-line .cut-scissors { flex-shrink: 0; font-size: 20px; line-height: 1; }
        .scanning-effect::after {
            content: ""; position: absolute; top: -100%; left: 0; width: 100%; height: 100%;
            background: linear-gradient(rgba(59,130,246,0) 0%, rgba(59,130,246,0.35) 50%, rgba(59,130,246,0) 100%);
            animation: scan 1.8s infinite linear; pointer-events: none;
        }
        @keyframes scan { 0% { top: -100%; } 100% { top: 100%; } }
        .hide-scanner::after { display: none !important; }
        .success-pulse { animation: slipPulse 0.45s ease-out; }
        @keyframes slipPulse {
            0% { box-shadow: 0 0 0 0 rgba(34,197,94,0.5); }
            100% { box-shadow: 0 0 0 16px rgba(34,197,94,0); }
        }
        .action-bar {
            position: fixed; left: 50%; transform: translateX(-50%); bottom: 0;
            width: 100%; max-width: 430px; padding: 12px 14px;
            padding-bottom: max(12px, env(safe-area-inset-bottom));
            background: var(--card); border-top: 1px solid var(--line);
        }
        .btn-row { display: flex; gap: 8px; }
        .btn-start, .btn-stop {
            flex: 1; padding: 14px; border: none; border-radius: 12px;
            font-weight: 700; font-size: 0.9rem; font-family: inherit; cursor: pointer;
        }
        .btn-start { background: var(--accent); color: #0f172a; }
        .btn-stop { background: #ef4444; color: #fff; display: none; }
        .btn-start:disabled { opacity: 0.45; cursor: not-allowed; }
        .toast {
            position: fixed; left: 50%; transform: translateX(-50%) translateY(10px);
            bottom: 96px; width: calc(100% - 32px); max-width: 360px;
            padding: 10px 14px; background: #111; color: #fff; border-radius: 10px;
            font-size: 0.8rem; opacity: 0; transition: 0.25s; z-index: 60;
        }
        .toast.show { opacity: 1; transform: translateX(-50%) translateY(0); }
    </style>
</head>
<body>
    <form id="form1" runat="server">
        <header class="top-bar">
            <h1>Bulk Slip Print</h1>
            <p>App <%= AppIdDisplay %> · Bluetooth thermal · Hindi/Gujarati</p>
            <span class="booth-tag">બૂથ નં. <%= BoothDisplay %></span>
        </header>

        <div class="section">
            <div class="card">
                <div><span class="bt-dot" id="btDot"></span><span id="btStatusText">Printer not connected</span></div>
                <select class="bt-dropdown" id="deviceSelect"><option value="">— Select printer —</option></select>
                <button type="button" class="btn-connect" id="btnConnect">Connect Printer</button>
            </div>

            <div class="card">
                <div class="progress-row">
                    <span>Printed: <b id="currCount">0</b> / <b id="totalCount">0</b></span>
                    <span id="pctLabel">0%</span>
                </div>
                <div class="progress-bg"><div id="mainBar"></div></div>
                <div class="status-live" id="statusLive">Connect printer, then tap Start Bulk Print</div>
            </div>

            <div class="preview-wrap">
                <div class="thermal-paper">
                    <div class="slip" id="slipPreview">
                        <div class="slip-head">
                            <img src="img/bjp_only_logo.png" alt="" class="slip-logo" id="logoL" />
                            <div class="slip-party" id="pParty"></div>
                            <img src="img/bjp_only_logo.png" alt="" class="slip-logo" id="logoR" />
                        </div>
                        <div class="slip-dash-box">
                            <div class="panel" id="pAssembly"></div>
                        </div>
                        <div class="slip-meta-box">
                            <div class="slip-meta-item"><span class="slip-meta-lbl">ભાગ</span><span class="slip-meta-val" id="pBhag"></span></div>
                            <div class="slip-meta-item"><span class="slip-meta-lbl">વિભાગ</span><span class="slip-meta-val" id="pVibhag"></span></div>
                            <div class="slip-meta-item"><span class="slip-meta-lbl">ક્રમાંક</span><span class="slip-meta-val" id="pKram"></span></div>
                        </div>
                        <p class="slip-line" id="pLineName"></p>
                        <p class="slip-line" id="pLineFather"></p>
                        <p class="slip-line" id="pLineSexAge"></p>
                        <p class="slip-line" id="pLineId"></p>
                        <div class="slip-loc"><span id="pLineLoc"></span></div>
                        <div class="slip-cands" id="pCands"></div>
                        <p class="slip-msg" id="pMsg"></p>
                        <div class="slip-thanks" id="pThanks"></div>
                    </div>
                </div>
            </div>
        </div>

        <footer class="action-bar">
            <div class="btn-row">
                <button type="button" class="btn-start" id="btnStart" disabled>Start Bulk Print</button>
                <button type="button" class="btn-stop" id="btnStop">Stop</button>
            </div>
        </footer>
        <div class="toast" id="toast"></div>
    </form>

    <script>
        (function () {
            const bulkData = <%= BulkDataJson %>;
            const GAP_MS = 2800;
            const PREVIEW_MS = 1800;
            const STORAGE_KEY = 'bjp_thermal_printers';
            const SCAN = '__scan__';
            const ESC = 0x1B, GS = 0x1D;
            const SLIP_PREVIEW_W = 325;
            const PRINTER_WIDTH = 384;

            let bleDevice = null, bleChar = null, devices = [], selectedId = null;
            let bleChunkSize = 180, bleChunkDelay = 4, connecting = false;
            let bulkRunning = false, bulkStop = false;
            const voters = bulkData.voters || [];

            const $ = id => document.getElementById(id);

            function toast(msg) {
                const t = $('toast');
                t.textContent = msg;
                t.classList.add('show');
                clearTimeout(toast._t);
                toast._t = setTimeout(() => t.classList.remove('show'), 2800);
            }

            function setStatus(msg, cls) {
                const el = $('statusLive');
                el.textContent = msg;
                el.className = 'status-live' + (cls ? ' ' + cls : '');
            }

            function setProgress(i, total) {
                $('currCount').textContent = i;
                $('totalCount').textContent = total;
                const pct = total ? Math.round((i / total) * 100) : 0;
                $('mainBar').style.width = pct + '%';
                $('pctLabel').textContent = pct + '%';
            }

            function initHeader() {
                const h = bulkData.header || {};
                $('pParty').textContent = h.party || '';
                $('pAssembly').textContent = h.assembly || '';
                $('pMsg').textContent = h.msg || '';
                $('pThanks').textContent = h.thanks || 'ધન્યવાદ';
                const logo = h.logo || 'img/bjp_only_logo.png';
                $('logoL').src = logo;
                $('logoR').src = logo;
                $('logoL').onerror = function () { this.src = 'img/bjp_only_logo.png'; };
                $('logoR').onerror = function () { this.src = 'img/bjp_only_logo.png'; };
                const box = $('pCands');
                box.innerHTML = '';
                (bulkData.candidates || []).forEach(c => {
                    const row = document.createElement('div');
                    row.className = 'cand-row';
                    row.innerHTML = '<div class="cand-num">' + c.num + '</div>' +
                        '<div class="cand-name">' + (c.name || '') + '</div>';
                    box.appendChild(row);
                });
            }

            function fillSlip(v) {
                $('pBhag').textContent = v.ac_no || '';
                $('pVibhag').textContent = v.part_no || '';
                $('pKram').textContent = v.slnoinpart || '';
                $('pLineName').textContent = v.full_name || '';
                $('pLineFather').textContent = v.middle_name || '';
                $('pLineSexAge').textContent = v.sex_age || '';
                $('pLineId').textContent = v.idcard_no || '';
                $('pLineLoc').textContent = v.polling_location || '';
            }

            function voterDisplayName(v) {
                const t = v.full_name || '';
                return t.replace(/^નામ\s*:\s*/i, '').trim() || t;
            }

            /* --- Bluetooth (same as Thermal_Print_Sample) --- */
            const BLE_WRITE_UUIDS = ['0000ffe1-0000-1000-8000-00805f9b34fb','0000fff2-0000-1000-8000-00805f9b34fb','49535343-8841-43f4-a8d4-ecbe34729bb3','49535343-fe7d-4ae5-8fa9-9fafd205e455','e7810a71-73ae-499d-8c15-faa9aef0c3f2','0000fff1-0000-1000-8000-00805f9b34fb'];
            const BLE_SERVICES = ['0000ffe0-0000-1000-8000-00805f9b34fb','0000fff0-0000-1000-8000-00805f9b34fb','49535343-fe7d-4ae5-8fa9-9fafd205e455','e7810a71-73ae-499d-8c15-faa9aef0c3f2','000018f0-0000-1000-8000-00805f9b34fb','0000ff00-0000-1000-8000-00805f9b34fb'];
            const sel = $('deviceSelect');

            function setBtUi(on, name) {
                $('btDot').classList.toggle('on', on);
                $('btStatusText').textContent = on ? ('Connected: ' + (name || '')) : 'Printer not connected';
                $('btnStart').disabled = !on || bulkRunning || !voters.length;
            }

            function loadDevices() {
                try { const r = localStorage.getItem(STORAGE_KEY); if (r) devices = JSON.parse(r); } catch (_) { devices = []; }
            }
            function saveDevices() { localStorage.setItem(STORAGE_KEY, JSON.stringify(devices)); }
            function renderDropdown() {
                sel.innerHTML = '<option value="">— Select printer —</option>';
                devices.forEach(d => { const o = document.createElement('option'); o.value = d.id; o.textContent = d.name; sel.appendChild(o); });
                const scan = document.createElement('option'); scan.value = SCAN; scan.textContent = '+ Scan & connect'; sel.appendChild(scan);
                if (selectedId) sel.value = selectedId;
            }

            async function findWriteChar(server) {
                for (const svcUuid of BLE_SERVICES) {
                    try {
                        const svc = await server.getPrimaryService(svcUuid);
                        for (const chUuid of BLE_WRITE_UUIDS) {
                            try {
                                const ch = await svc.getCharacteristic(chUuid);
                                if (ch.properties.write || ch.properties.writeWithoutResponse) return ch;
                            } catch (_) { }
                        }
                    } catch (_) { }
                }
                for (const svc of await server.getPrimaryServices()) {
                    for (const ch of await svc.getCharacteristics()) {
                        if (ch.properties.write || ch.properties.writeWithoutResponse) return ch;
                    }
                }
                return null;
            }

            async function connect(device) {
                if (connecting) return;
                connecting = true;
                $('btnConnect').disabled = true;
                try {
                    if (bleDevice && bleDevice.gatt.connected && bleDevice.id !== device.id) bleDevice.gatt.disconnect();
                    bleDevice = device;
                    device.addEventListener('gattserverdisconnected', onDisc);
                    if (!device.gatt.connected) await device.gatt.connect();
                    bleChar = await findWriteChar(device.gatt);
                    if (!bleChar) throw new Error('No write port on printer');
                    if (bleChar.properties.writeWithoutResponse) { bleChunkSize = 180; bleChunkDelay = 4; }
                    else { bleChunkSize = 100; bleChunkDelay = 8; }
                    selectedId = device.id;
                    const name = device.name || 'Printer';
                    if (!devices.some(d => d.id === device.id)) { devices.unshift({ id: device.id, name }); saveDevices(); }
                    renderDropdown(); sel.value = device.id;
                    setBtUi(true, name);
                    toast('Printer connected');
                } catch (e) {
                    bleChar = null; setBtUi(false); toast(e.message || 'Connect failed');
                } finally {
                    connecting = false;
                    $('btnConnect').disabled = !navigator.bluetooth;
                }
            }

            async function scanConnect() {
                if (!navigator.bluetooth) { toast('Use Chrome Android + HTTPS'); return; }
                try {
                    const device = await navigator.bluetooth.requestDevice({ acceptAllDevices: true, optionalServices: BLE_SERVICES });
                    await connect(device);
                } catch (e) { if (e.name !== 'NotFoundError') toast(e.message || 'Failed'); }
            }

            async function doConnect() {
                if (bleDevice && bleDevice.gatt.connected) return;
                const val = sel.value;
                if (val && val !== SCAN && navigator.bluetooth.getDevices) {
                    const list = await navigator.bluetooth.getDevices();
                    const saved = list.find(d => d.id === val);
                    if (saved) { await connect(saved); return; }
                }
                await scanConnect();
            }

            function onDisc() { bleChar = null; bleDevice = null; setBtUi(false); toast('Disconnected'); }

            function cat(arr) {
                const n = arr.reduce((a, b) => a + b.length, 0);
                const o = new Uint8Array(n);
                let i = 0;
                arr.forEach(b => { o.set(b, i); i += b.length; });
                return o;
            }

            async function writeRaw(buf) {
                if (!buf || !buf.length) return;
                const wnr = bleChar.properties.writeWithoutResponse;
                for (let i = 0; i < buf.length; i += bleChunkSize) {
                    const slice = buf.subarray(i, Math.min(i + bleChunkSize, buf.length));
                    if (wnr) await bleChar.writeValueWithoutResponse(slice);
                    else await bleChar.writeValue(slice);
                    if (bleChunkDelay > 0) await new Promise(r => setTimeout(r, bleChunkDelay));
                }
            }

            async function waitSlipImages(root) {
                const imgs = root.querySelectorAll('img');
                await Promise.all([...imgs].map(img => {
                    if (img.complete && img.naturalWidth > 0) return Promise.resolve();
                    return new Promise(done => { img.onload = img.onerror = done; });
                }));
            }

            function appendCutLine(parent) {
                const cut = document.createElement('div');
                cut.className = 'slip-cut-line';
                cut.innerHTML = '<span class="cut-dash"></span><span class="cut-scissors" aria-hidden="true">&#9986;</span><span class="cut-dash"></span>';
                parent.appendChild(cut);
            }

            async function captureSlipCanvas(withCutLine) {
                const el = $('slipPreview');
                const clone = el.cloneNode(true);
                clone.id = 'slipPrintBoost';
                clone.style.cssText = 'width:' + SLIP_PREVIEW_W + 'px;max-width:' + SLIP_PREVIEW_W + 'px;background:#fff;';
                if (withCutLine) appendCutLine(clone);
                const box = document.createElement('div');
                box.style.cssText = 'position:fixed;left:-9999px;top:0;width:' + SLIP_PREVIEW_W + 'px;background:#fff;';
                box.appendChild(clone);
                document.body.appendChild(box);
                await new Promise(r => requestAnimationFrame(() => requestAnimationFrame(r)));
                try {
                    await waitSlipImages(clone);
                    const shot = await html2canvas(clone, { scale: 1, backgroundColor: '#ffffff', useCORS: true, allowTaint: true, logging: false });
                    const targetW = PRINTER_WIDTH;
                    const scaleUp = targetW / shot.width;
                    const c = document.createElement('canvas');
                    c.width = targetW;
                    c.height = Math.max(1, Math.round(shot.height * scaleUp));
                    const ctx = c.getContext('2d');
                    ctx.fillStyle = '#fff';
                    ctx.fillRect(0, 0, targetW, c.height);
                    ctx.imageSmoothingEnabled = true;
                    ctx.drawImage(shot, 0, 0, targetW, c.height);
                    return c;
                } finally {
                    document.body.removeChild(box);
                }
            }

            function packRaster(canvas) {
                const w = canvas.width, h = canvas.height;
                const px = canvas.getContext('2d').getImageData(0, 0, w, h).data;
                const rowBytes = Math.ceil(w / 8);
                const data = new Uint8Array(rowBytes * h);
                for (let y = 0; y < h; y++) {
                    for (let x = 0; x < w; x++) {
                        const i = (y * w + x) * 4;
                        const lum = 0.299 * px[i] + 0.587 * px[i + 1] + 0.114 * px[i + 2];
                        if (px[i + 3] > 40 && lum < 185) data[y * rowBytes + (x >> 3)] |= (0x80 >> (x % 8));
                    }
                }
                return { rowBytes, height: h, data };
            }

            async function printSlipImage(withCutLine) {
                const canvas = await captureSlipCanvas(!!withCutLine);
                const { rowBytes, height, data } = packRaster(canvas);
                const prevC = bleChunkSize, prevD = bleChunkDelay;
                bleChunkSize = 100; bleChunkDelay = 8;
                try {
                    await writeRaw(new Uint8Array([ESC, 0x40]));
                    const band = 24;
                    for (let y = 0; y < height; y += band) {
                        if (bulkStop) break;
                        const bandH = Math.min(band, height - y);
                        const slice = data.subarray(y * rowBytes, (y + bandH) * rowBytes);
                        const head = new Uint8Array([GS, 0x76, 0x30, 0x00, rowBytes & 0xff, (rowBytes >> 8) & 0xff, bandH & 0xff, (bandH >> 8) & 0xff]);
                        await writeRaw(head);
                        await writeRaw(slice);
                        await new Promise(r => setTimeout(r, 20));
                    }
                    if (!bulkStop) await writeRaw(new Uint8Array([ESC, 0x4A, 60, 0x0A, 0x0A, 0x0A]));
                } finally {
                    bleChunkSize = prevC; bleChunkDelay = prevD;
                }
            }

            async function startBulk() {
                if (!bleChar) { toast('Connect printer first'); return; }
                if (!voters.length) { toast('No voters for this booth'); return; }
                bulkRunning = true;
                bulkStop = false;
                $('btnStart').style.display = 'none';
                $('btnStop').style.display = 'block';
                const slip = $('slipPreview');
                const total = voters.length;

                for (let i = 0; i < total; i++) {
                    if (bulkStop) break;
                    const v = voters[i];
                    fillSlip(v);
                    const name = voterDisplayName(v);

                    slip.classList.remove('hide-scanner', 'success-pulse');
                    slip.classList.add('scanning-effect');
                    setStatus('🔍 ' + (i + 1) + '/' + total + ' — ' + name, 'printing');

                    await waitSlipImages(slip);
                    await new Promise(r => setTimeout(r, PREVIEW_MS));

                    slip.classList.add('hide-scanner');
                    slip.classList.remove('scanning-effect');
                    setStatus('🖨 Printing: ' + name, 'printing');

                    try {
                        await printSlipImage(i < total - 1);
                        slip.classList.add('success-pulse');
                        setProgress(i + 1, total);
                        setStatus('✓ Printed: ' + name, 'done');
                    } catch (e) {
                        setStatus('✗ Error: ' + name, '');
                        toast(e.message || 'Print failed');
                        await new Promise(r => setTimeout(r, 1500));
                        continue;
                    }

                    if (i < total - 1 && !bulkStop) {
                        setStatus('⏳ Next voter in ' + (GAP_MS / 1000) + ' sec...', '');
                        await new Promise(r => setTimeout(r, GAP_MS));
                    }
                }

                slip.classList.remove('scanning-effect', 'hide-scanner');
                bulkRunning = false;
                $('btnStart').style.display = 'block';
                $('btnStop').style.display = 'none';
                $('btnStart').disabled = !bleChar;
                if (bulkStop) setStatus('Stopped at ' + $('currCount').textContent + ' / ' + total, '');
                else setStatus('🏁 All ' + total + ' slips printed!', 'done');
            }

            function stopBulk() {
                bulkStop = true;
                setStatus('Stopping after current print...', '');
            }

            $('btnConnect').onclick = doConnect;
            sel.onchange = async () => {
                if (sel.value === SCAN) { await scanConnect(); if (selectedId) sel.value = selectedId; }
            };
            $('btnStart').onclick = startBulk;
            $('btnStop').onclick = stopBulk;

            initHeader();
            if (voters.length) fillSlip(voters[0]);
            setProgress(0, voters.length);
            if (bulkData.error) toast('DB: ' + bulkData.error);
            else if (!voters.length) setStatus('No voters found for booth ' + (bulkData.boothNo || ''));
            else setStatus(voters.length + ' voters loaded. Preview shows voter 1. Connect printer & Start.');

            loadDevices();
            renderDropdown();
            setBtUi(false);
            $('btnConnect').disabled = !navigator.bluetooth;
            if (!navigator.bluetooth) toast('Chrome on Android + HTTPS required');
        })();
    </script>
</body>
</html>
