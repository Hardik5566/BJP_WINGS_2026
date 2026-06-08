<%@ Page Language="C#" AutoEventWireup="true" CodeFile="Video_Help.aspx.cs" Inherits="Video_Help" %>

<!DOCTYPE html>
<html xmlns="http://www.w3.org/1999/xhtml">
<head runat="server">
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0, maximum-scale=1.0, user-scalable=no">
    <title>Video Help Center</title>
    <style>
        @import url('https://fonts.googleapis.com/css2?family=Outfit:wght@400;700;800&family=Hind+Gujarati:wght@500;700&display=swap');

        :root {
            --primary: #FF4D00;
            --bg: #0F172A;
            --card: #1E293B;
            --text-main: #F8FAFC;
        }

        body { 
            font-family: 'Outfit', 'Hind Gujarati', sans-serif; 
            margin: 0; padding: 0; background: var(--bg); color: var(--text-main);
            -webkit-font-smoothing: antialiased;
        }

        .header {
            padding: 40px 20px 20px;
            background: linear-gradient(180deg, rgba(255,77,0,0.1) 0%, rgba(15,23,42,0) 100%);
        }
        .header h1 { font-size: 32px; margin: 0; font-weight: 800; }
        .header p { color: #94A3B8; margin-top: 5px; font-size: 15px; }

        .filter-wrapper {
            display: flex; overflow-x: auto; padding: 10px 20px; gap: 10px;
            scrollbar-width: none; position: sticky; top: 0; background: var(--bg); z-index: 10;
        }
        .filter-wrapper::-webkit-scrollbar { display: none; }

        .chip {
            white-space: nowrap; padding: 10px 20px; border-radius: 50px;
            background: var(--card); border: 1px solid #334155;
            color: #94A3B8; font-size: 14px; font-weight: 600; cursor: pointer; transition: 0.3s;
        }
        .chip.active {
            background: var(--primary); color: white; border-color: var(--primary);
            box-shadow: 0 4px 15px rgba(255, 77, 0, 0.3);
        }

        .video-grid { padding: 20px; }
        
        /* Video Card styling */
        .video-item { display: block; margin-bottom: 25px; transition: 0.3s; }
        
        .category-label { 
            font-size: 13px; text-transform: uppercase; color: var(--primary); 
            letter-spacing: 2px; font-weight: 800; margin-bottom: 10px; display: block;
        }

        .video-card {
            background: var(--card); border-radius: 20px; overflow: hidden;
            border: 1px solid rgba(255,255,255,0.05);
            box-shadow: 0 10px 20px rgba(0,0,0,0.2);
            cursor: pointer;
        }

        .thumbnail-area {
            width: 100%; height: 180px; background: #000; position: relative;
        }
        .thumbnail-area img { width: 100%; height: 100%; object-fit: cover; opacity: 0.8; }
        
        .play-btn {
            position: absolute; top: 50%; left: 50%; transform: translate(-50%, -50%);
            width: 50px; height: 50px; background: var(--primary);
            border-radius: 50%; display: flex; align-items: center; justify-content: center;
            font-size: 20px; color: white; box-shadow: 0 0 20px rgba(255, 77, 0, 0.5);
        }

        .video-info { padding: 15px; }
        .video-info h3 { margin: 0; font-size: 18px; line-height: 1.4; }
        .video-info p { font-size: 13px; color: #94A3B8; margin: 8px 0 0; }

        /* Full Screen Overlay for Video Player */
        #videoOverlay {
            display: none; position: fixed; top: 0; left: 0; width: 100%; height: 100%;
            background: rgba(0,0,0,0.95); z-index: 1000; justify-content: center; align-items: center;
        }
        .player-container { width: 90%; max-width: 800px; position: relative; }
        .close-btn { 
            position: absolute; top: -40px; right: 0; color: white; font-size: 30px; cursor: pointer; 
        }
        iframe { width: 100%; aspect-ratio: 16/9; border-radius: 10px; border: none; }
    </style>
</head>
<body>
    <form id="form1" runat="server">
        <div class="header">
            <h1>વિડિયો હેલ્પ સેન્ટર</h1>
            <p>શીખો કે કેવી રીતે એપનો ઉપયોગ કરવો</p>
        </div>

        <div class="filter-wrapper" id="filterChips">
            <div class="chip active" data-category="all">બધા વિડિયો</div>
            <div class="chip" data-category="admin">Admin</div>
            <div class="chip" data-category="booth">Booth Pramukh</div>
            <div class="chip" data-category="shakti">Shaktikendra</div>
            <div class="chip" data-category="volunteer">Volunteer</div>
        </div>

        <div class="video-grid" id="videoGrid">
            
            <div class="video-item" data-category="admin" onclick="playVideo('vVS-894uPyc')">
                <span class="category-label">Admin Help</span>
                <div class="video-card">
                    <div class="thumbnail-area">
                        <img src="https://img.youtube.com/vi/vVS-894uPyc/maxresdefault.jpg" alt="Thumb">
                        <div class="play-btn">▶</div>
                    </div>
                    <div class="video-info">
                        <h3>એડમિન ડેશબોર્ડનો ઉપયોગ કેવી રીતે કરવો</h3>
                        <p>બધા કાર્યકર્તાઓનું લિસ્ટ જોવા અને મેનેજ કરવાની સંપૂર્ણ રીત.</p>
                    </div>
                </div>
            </div>

            <div class="video-item" data-category="booth" onclick="playVideo('vVS-894uPyc')">
                <span class="category-label">Booth Pramukh</span>
                <div class="video-card">
                    <div class="thumbnail-area">
                        <img src="https://img.youtube.com/vi/vVS-894uPyc/maxresdefault.jpg" alt="Thumb">
                        <div class="play-btn">▶</div>
                    </div>
                    <div class="video-info">
                        <h3>બૂથ લેવલ એન્ટ્રી અને વોટર સર્ચ</h3>
                        <p>બૂથ પ્રમુખ માટે વોટર લિસ્ટ ચેક કરવાની અને માર્ક કરવાની રીત.</p>
                    </div>
                </div>
            </div>

            <div class="video-item" data-category="shakti" onclick="playVideo('vVS-894uPyc')">
                <span class="category-label">Shaktikendra</span>
                <div class="video-card">
                    <div class="thumbnail-area">
                        <img src="https://img.youtube.com/vi/vVS-894uPyc/maxresdefault.jpg" alt="Thumb">
                        <div class="play-btn">▶</div>
                    </div>
                    <div class="video-info">
                        <h3>શક્તિકેન્દ્ર સંચાલન માર્ગદર્શિકા</h3>
                        <p>તમારા કેન્દ્ર હેઠળ આવતા તમામ બૂથનું મોનિટરિંગ કઈ રીતે કરવું.</p>
                    </div>
                </div>
            </div>

        </div>

        <div id="videoOverlay">
            <div class="player-container">
                <span class="close-btn" onclick="closePlayer()">&times;</span>
                <div id="playerFrame"></div>
            </div>
        </div>

        <div style="padding: 20px; text-align: center;">
            <p style="font-size: 12px; color: #475569;">વધારે મદદ માટે સપોર્ટ ટીમનો સંપર્ક કરો</p>
        </div>
    </form>

    <script>
        // 1. FILTER FUNCTIONALITY
        const chips = document.querySelectorAll('.chip');
        const videos = document.querySelectorAll('.video-item');

        chips.forEach(chip => {
            chip.addEventListener('click', () => {
                // Active chip class change
                document.querySelector('.chip.active').classList.remove('active');
                chip.classList.add('active');

                const category = chip.getAttribute('data-category');

                videos.forEach(video => {
                    if (category === 'all' || video.getAttribute('data-category') === category) {
                        video.style.display = 'block';
                    } else {
                        video.style.display = 'none';
                    }
                });
            });
        });

        // 2. PLAY VIDEO FUNCTIONALITY
        function playVideo(id) {
            const overlay = document.getElementById('videoOverlay');
            const frame = document.getElementById('playerFrame');
            
            // YouTube embed with Autoplay
            frame.innerHTML = `<iframe src="https://www.youtube.com/embed/${id}?autoplay=1" allow="autoplay; encrypted-media" allowfullscreen></iframe>`;
            overlay.style.display = 'flex';
        }

        function closePlayer() {
            const overlay = document.getElementById('videoOverlay');
            const frame = document.getElementById('playerFrame');
            frame.innerHTML = ''; // Stop video
            overlay.style.display = 'none';
        }
    </script>
</body>
</html>