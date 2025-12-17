const app = {
    sets: [],
    currentSet: null,
    currentMode: 'flashcards',

    // Study State
    cardIndex: 0,
    isFlipped: false,

    // Progress State
    progress: {}, // { "A1_part_1": true }

    // Match State
    matchTimer: null,
    startTime: 0,
    selectedTile: null,

    init() {
        // Load Sets & Progress
        const savedSets = localStorage.getItem('quiz_sets_v2');
        const savedProgress = localStorage.getItem('quiz_progress');

        if (savedProgress) {
            this.progress = JSON.parse(savedProgress);
        }

        let loadedSets = [];

        if (savedSets) {
            loadedSets = JSON.parse(savedSets);
        }

        // AUTO-UPDATE CHECK
        // If we have the big Oxford file loaded
        if (window.OXFORD_DATA) {
            let needsUpdate = false;

            // 1. If no local data, use Oxford
            if (!loadedSets || loadedSets.length === 0) {
                needsUpdate = true;
            }
            // 2. Check for "Stale" data (e.g. A1 has fewer words than new source)
            else {
                const localA1 = loadedSets.find(s => s.id === 'A1');
                const newA1 = window.OXFORD_DATA.find(s => s.id === 'A1');

                if (localA1 && newA1 && localA1.cards.length < newA1.cards.length) {
                    console.log("Detecting old data. Force updating...");
                    needsUpdate = true;
                }
                // 3. Or if local data is just Missing the Oxford sets
                else if (!localA1 && newA1) {
                    needsUpdate = true;
                }
            }

            if (needsUpdate) {
                loadedSets = window.OXFORD_DATA;
                // Preserve user created sets? (Advanced: separate user sets from system sets)
                // For now, let's just overwrite to ensure they get the dict.
                // If user really wants to keep custom sets, we'd filter them out. 
                // Assuming currently user strictly wants the Oxford list fixed.

                localStorage.setItem('quiz_sets', JSON.stringify(loadedSets));
            }
        }

        this.sets = loadedSets;
        this.nav('home');
        this.loadVoices();
    },

    markComplete(setId) {
        if (!setId) return;
        this.progress[setId] = true;
        localStorage.setItem('quiz_progress', JSON.stringify(this.progress));

        // Visual feedback if inside a set? Optional. 
        // For now, it just saves so when you go back to level view it is green.
    },

    saveStorage() {
        localStorage.setItem('quiz_sets_v2', JSON.stringify(this.sets));
    },

    nav(view) {
        document.querySelectorAll('.view').forEach(el => el.classList.add('hidden'));
        document.getElementById(`view-${view}`).classList.remove('hidden');
        document.querySelectorAll('.view').forEach(el => el.classList.remove('active'));
        document.getElementById(`view-${view}`).classList.add('active');

        if (view === 'home') this.renderHome();
        if (view === 'create') this.renderCreate();
    },

    /* --- LEVEL DETAILS (SUB-SETS) --- */
    currentLevel: null,

    openLevel(set) {
        this.currentLevel = set;
        document.getElementById('level-title').textContent = set.id.length <= 2 ? `Level ${set.id}` : set.title;

        const grid = document.getElementById('subsets-grid');
        grid.innerHTML = '';

        // Chunking Logic (25 items per chunk)
        const chunkSize = 25;
        const totalCards = set.cards.length;
        const totalParts = Math.ceil(totalCards / chunkSize);

        if (totalCards === 0) {
            grid.innerHTML = '<p style="color:#aaa;">No terms in this level yet.</p>';
        }

        for (let i = 0; i < totalParts; i++) {
            const start = i * chunkSize;
            const end = Math.min(start + chunkSize, totalCards);
            const chunk = set.cards.slice(start, end);

            // ID generation must be consistent
            const partId = `${set.id}_part_${i + 1}`;
            const isDone = this.progress[partId];

            const el = document.createElement('div');
            el.className = 'video-card micro-card'; // Reusing card styling
            // Custom styling for these smaller parts
            el.style.minHeight = '140px';

            // Visual style for DONE state
            const doneStyle = isDone ? 'border: 2px solid #4CAF50; background: rgba(76, 175, 80, 0.1);' : '';
            const color = isDone ? '#4CAF50' : (set.thumbColor || '#666');

            el.innerHTML = `
                <div class="thumbnail" style="background: linear-gradient(135deg, ${color}cc, ${color}33); border-bottom: 2px solid ${color}; display:flex; align-items:center; justify-content:center; flex-direction:column; height:100%; border-radius:12px;">
                     <h2 style="font-size: 28px; margin:0; color:white;">Part ${i + 1}</h2>
                     <span style="font-size:14px; opacity:0.7; color:white;">${start + 1} - ${end}</span>
                     ${isDone ? '<div style="margin-top:10px; color:#4CAF50; font-weight:bold; background:#121212; padding:4px 12px; border-radius:20px;">✓ Done</div>' : ''}
                </div>
            `;

            // Create a temporary "Set" object for this chunk
            const subSet = {
                id: partId,
                title: `${set.title} (Part ${i + 1})`,
                desc: `Terms ${start + 1} - ${end}`,
                cards: chunk,
                thumbColor: color,
                parentSet: set // Reference to go back
            };

            el.onclick = () => this.openStudy(subSet);
            grid.appendChild(el);
        }

        this.nav('level');
    },

    /* --- HOME --- */
    renderHome() {
        const grid = document.getElementById('sets-grid');
        grid.innerHTML = '';

        if (!this.sets || this.sets.length === 0) {
            grid.innerHTML = '<p style="color:#aaa; text-align:center; grid-column:1/-1;">No vocabulary sets found.</p>';
            return;
        }

        this.sets.forEach(set => {
            const el = document.createElement('div');
            el.className = 'video-card';

            const levelCode = String(set.id).slice(0, 2).toUpperCase();
            const color = set.thumbColor || '#666';

            el.innerHTML = `
                <div class="thumbnail" style="background: linear-gradient(135deg, ${color}aa, ${color}); border-bottom: 4px solid ${color}; display:flex; align-items:center; justify-content:center; flex-direction: column; height: 100%; border-radius: 12px; cursor:pointer; transition: transform 0.2s;">
                     <h1 style="font-size: 60px; margin:0; opacity:0.9; text-shadow:0 4px 10px rgba(0,0,0,0.3); color:white;">${levelCode}</h1>
                     <span style="font-size:14px; opacity:0.8; letter-spacing:1px; color:white;">LEVEL</span>
                    <div class="duration">${set.cards ? set.cards.length : 0} Terms</div>
                </div>
            `;
            // CLICK OPENS LEVEL VIEW NOW
            el.onclick = () => this.openLevel(set);

            // Hover effect logic handled by CSS usually, but adding transform here if needed or relying on CSS.
            grid.appendChild(el);
        });
    },

    /* --- CREATE --- */
    renderCreate() {
        document.getElementById('set-title').value = '';
        document.getElementById('set-desc').value = '';
        document.getElementById('cards-editor').innerHTML = '';
        for (let i = 0; i < 3; i++) this.addCardRow();
    },

    addCardRow() {
        const row = document.createElement('div');
        row.className = 'card-row';
        row.innerHTML = `
            <div class="field">
                <span class="label">Term</span>
                <input type="text" class="input-term" placeholder="e.g. Hello">
            </div>
            <div class="field">
                <span class="label">Definition</span>
                <input type="text" class="input-def" placeholder="e.g. Merhaba">
            </div>
        `;
        document.getElementById('cards-editor').appendChild(row);
    },

    toggleStar(e) {
        if (e) {
            e.stopPropagation();
            e.preventDefault();
        }

        const card = this.currentSet.cards[this.cardIndex];
        // Ensure property exists
        if (typeof card.starred === 'undefined') card.starred = false;

        card.starred = !card.starred;

        // Update Button UI directly
        const btn = document.getElementById('btn-star');
        if (btn) {
            if (card.starred) btn.classList.add('active');
            else btn.classList.remove('active');
        }

        this.saveStorage();
    },

    filterFavorites() {
        // Collect all starred cards
        const starred = [];
        this.sets.forEach(set => {
            if (set.cards) {
                set.cards.forEach(c => {
                    if (c.starred) starred.push(c);
                });
            }
        });

        if (starred.length === 0) {
            alert("No favorites yet! Star some cards first.");
            return;
        }

        const favSet = {
            id: 'favs',
            title: '⭐ My Favorites',
            desc: 'Your starred items',
            cards: starred,
            thumbColor: '#FFD700',
            isFavorites: true // Marker
        };

        this.openStudy(favSet);
    },

    saveSet() {
        const title = document.getElementById('set-title').value;
        const desc = document.getElementById('set-desc').value;
        const rows = document.querySelectorAll('.card-row');

        const cards = [];
        rows.forEach(row => {
            const term = row.querySelector('.input-term').value;
            const def = row.querySelector('.input-def').value;
            if (term && def) cards.push({ term, def });
        });

        if (!title || cards.length === 0) {
            alert("Please enter a title and at least one card.");
            return;
        }

        this.sets.push({
            id: Date.now(),
            title,
            desc,
            cards
        });

        this.saveStorage();
        this.nav('home');
    },

    /* --- STUDY --- */
    openStudy(set) {
        this.currentSet = set;
        document.getElementById('study-title').textContent = set.title;

        // Configure Back Button Logic
        const backBtn = document.querySelector('.btn-back');
        if (backBtn) {
            // Remove old listeners
            const newBtn = backBtn.cloneNode(true);
            backBtn.parentNode.replaceChild(newBtn, backBtn);

            newBtn.onclick = () => {
                if (set.parentSet) {
                    // It's a subset, go back to Level View
                    this.openLevel(set.parentSet);
                } else {
                    // It's a regular set or favorites, go to Home
                    this.nav('home');
                }
            };
        }

        this.cardIndex = 0;
        this.switchMode('flashcards');
        this.nav('study');
        // this.startSession(); // Only track full sessions if desired, but fine for now
    },

    switchMode(mode) {
        this.currentMode = mode;
        document.querySelectorAll('.mode-tab').forEach(b => b.classList.remove('active'));
        // Highlight active tab logic needed if button refs are tracked, 
        // but for now relying on inline onclick update or simple redraw, 
        // to keep it simple let's just highlight the text matches in tabs if needed.
        // Actually simplest is to find button with text content match or index.
        // Let's assume user clicks button, button logic can add active class if passed `this`.
        // For now, removing active from all is fine.

        document.querySelectorAll('.study-mode').forEach(el => el.classList.add('hidden'));
        document.getElementById(`mode-${mode}`).classList.remove('hidden');

        if (mode === 'flashcards') this.renderFlashcard();
        if (mode === 'quiz') this.startQuiz();
        if (mode === 'match') this.startMatch();
    },

    // Helper for formatting text styling (White Definition, Yellow Example)
    formatText(text) {
        if (!text) return '';
        // Check for Example marker
        if (text.includes('(Ex:')) {
            const parts = text.split('(Ex:');
            const def = parts[0].trim();
            const ex = parts[1].replace(')', '').trim(); // Remove trailing ')'

            return `
                <span class="def-text" style="color: #ffffff; display:block; margin-bottom:15px; font-weight:500;">${def}</span>
                <span class="ex-text" style="color: #FFD700; display:block; font-style:italic; font-size:0.9em;">Ex: ${ex}</span>
            `;
        }
        return `<span>${text}</span>`;
    },

    /* Mode: Flashcards */
    renderFlashcard() {
        const card = this.currentSet.cards[this.cardIndex];
        document.getElementById('fc-front').textContent = card.term;

        // Use INNERHTML for styled text
        document.getElementById('fc-back').innerHTML = this.formatText(card.def);

        // Sync Star Button
        const starBtn = document.getElementById('btn-star');
        if (starBtn) {
            if (card.starred) starBtn.classList.add('active');
            else starBtn.classList.remove('active');
        }

        const progEl = document.getElementById('fc-progress');
        if (progEl) progEl.textContent = `${this.cardIndex + 1} / ${this.currentSet.cards.length}`;

        const el = document.querySelector('.flashcard');
        el.classList.remove('flipped');
        this.isFlipped = false;
    },

    /* Mode: Quiz */
    quizScore: 0,

    startQuiz() {
        this.cardIndex = 0;
        this.quizScore = 0;
        // Shuffle for random order
        this.quizSet = [...this.currentSet.cards].sort(() => Math.random() - 0.5);
        this.renderQuestion();
    },

    renderQuestion() {
        if (this.cardIndex >= this.quizSet.length) {
            this.finishQuiz();
            return;
        }

        const current = this.quizSet[this.cardIndex];
        document.getElementById('quiz-progress').textContent = `${this.cardIndex + 1}/${this.quizSet.length}`;
        document.getElementById('quiz-question').textContent = current.term;
        document.getElementById('quiz-result').textContent = '';

        // Play audio for the question (Immersion)
        // this.speak('front'); // Removed as per instruction

        // Generate Options
        // Correct answer
        let options = [current.def];
        // 3 Wrong answers
        const allDefs = this.currentSet.cards.map(c => c.def).filter(d => d !== current.def);
        // Shuffle wrong answers to pick random ones
        const wrong = allDefs.sort(() => Math.random() - 0.5).slice(0, 3);
        options = options.concat(wrong);
        // Shuffle options so correct isn't always first
        options.sort(() => Math.random() - 0.5);

        const optsContainer = document.getElementById('quiz-options');
        optsContainer.innerHTML = '';

        options.forEach(opt => {
            const btn = document.createElement('button');
            btn.className = 'quiz-btn'; // We need to add css for this
            btn.style.cssText = `
                padding: 20px;
                font-size: 18px;
                background: #333;
                color: white;
                border: 1px solid #444;
                border-radius: 8px;
                cursor: pointer;
                transition: all 0.2s;
                text-align: left;
            `;
            btn.textContent = opt;
            btn.onclick = () => this.checkAnswer(btn, opt, current.def);

            // Hover effect via JS since inline styles are tricky for hover
            btn.onmouseover = () => btn.style.background = '#444';
            btn.onmouseout = () => btn.style.background = '#333';

            optsContainer.appendChild(btn);
        });
    },

    checkAnswer(btn, selected, correct) {
        // Disable all buttons
        const all = document.querySelectorAll('#quiz-options button');
        all.forEach(b => b.onclick = null);

        if (selected === correct) {
            btn.style.background = '#2e7d32'; // Green
            btn.style.borderColor = '#4caf50';
            this.quizScore++;
            document.getElementById('quiz-result').textContent = '✅ Correct!';
            document.getElementById('quiz-result').style.color = '#4caf50';
        } else {
            btn.style.background = '#c62828'; // Red
            btn.style.borderColor = '#f44336';
            document.getElementById('quiz-result').textContent = `❌ Correct: ${correct}`;
            document.getElementById('quiz-result').style.color = '#f44336';

            // Highlight correct one
            all.forEach(b => {
                if (b.textContent === correct) {
                    b.style.background = '#2e7d32';
                    b.style.borderColor = '#4caf50';
                }
            });
        }

        // Auto advance
        setTimeout(() => {
            this.cardIndex++;
            this.renderQuestion();
        }, 2000);
    },

    finishQuiz() {
        const grid = document.getElementById('quiz-options');
        grid.innerHTML = '';
        document.getElementById('quiz-question').textContent = "Quiz Completed! 🎉";
        document.getElementById('quiz-result').textContent = `Score: ${this.quizScore} / ${this.quizSet.length}`;
        document.getElementById('quiz-result').style.color = 'white';

        // Add Retry Button
        const btn = document.createElement('button');
        btn.textContent = "Try Again";
        btn.onclick = () => this.startQuiz();
        btn.style.cssText = "margin-top:20px; padding:10px 20px; font-size:18px; cursor:pointer;";
        grid.appendChild(btn);
    },

    flipCard() {
        document.querySelector('.flashcard').classList.toggle('flipped');
        this.isFlipped = !this.isFlipped;
    },

    toggleStar(e) {
        if (e) {
            e.stopPropagation();
            e.preventDefault();
        }

        const card = this.currentSet.cards[this.cardIndex];
        // Ensure property exists
        if (typeof card.starred === 'undefined') card.starred = false;

        card.starred = !card.starred;

        // Update Button UI directly
        const btn = document.getElementById('btn-star');
        if (btn) {
            if (card.starred) btn.classList.add('active');
            else btn.classList.remove('active');
        }

        this.saveStorage();
    },

    nextCard() {
        if (this.cardIndex < this.currentSet.cards.length - 1) {
            this.cardIndex++;
            this.renderFlashcard();
        } else {
            // End of Set Logic
            this.markComplete(this.currentSet.id);
        }
    },

    prevCard() {
        if (this.cardIndex > 0) {
            this.cardIndex--;
            this.renderFlashcard();
        }
    },

    // Voice State
    voices: [],
    preferredVoiceURI: null,

    loadVoices() {
        // Chrome loads async
        const run = () => {
            this.voices = speechSynthesis.getVoices();
            // Restore preference
            this.preferredVoiceURI = localStorage.getItem('quiz_voice_pref');
        };

        run();
        speechSynthesis.onvoiceschanged = run;
    },

    /* --- SETTINGS --- */
    openSettings() {
        const modal = document.getElementById('settings-modal');
        const select = document.getElementById('voice-select');

        modal.classList.remove('hidden');
        select.innerHTML = '';

        if (this.voices.length === 0) this.voices = speechSynthesis.getVoices();

        // 1. Add "Force US English" Option (Failsafe)
        const defaultOpt = document.createElement('option');
        defaultOpt.value = 'force_us';
        // Friendly name for the user
        defaultOpt.textContent = "🇺🇸 Universal US English (Auto-Detect)";
        select.appendChild(defaultOpt);

        // 2. Add detected voices
        const englishVoices = this.voices.filter(v => v.lang.startsWith('en'));
        const sorted = [...englishVoices].sort((a, b) => a.name.localeCompare(b.name));

        sorted.forEach(v => {
            const opt = document.createElement('option');
            opt.value = v.voiceURI;
            opt.textContent = `${v.name} (${v.lang})`;
            select.appendChild(opt);
        });

        // Restore Selection
        if (this.preferredVoiceURI) {
            select.value = this.preferredVoiceURI;
        } else {
            // Default to the failsafe if nothing selected
            select.value = 'force_us';
        }
    },

    closeSettings() {
        const select = document.getElementById('voice-select');
        this.preferredVoiceURI = select.value;
        localStorage.setItem('quiz_voice_pref', this.preferredVoiceURI);
        document.getElementById('settings-modal').classList.add('hidden');
    },

    testVoice() {
        const select = document.getElementById('voice-select');
        const uri = select.value;

        speechSynthesis.cancel();
        const ut = new SpeechSynthesisUtterance("Hello! I am an American woman speaking English.");
        ut.lang = 'en-US';
        ut.rate = 1.0;

        if (uri !== 'force_us') {
            const voice = this.voices.find(v => v.voiceURI === uri);
            if (voice) ut.voice = voice;
        }

        speechSynthesis.speak(ut);
    },

    // Helper to find best voice
    getBestVoice(lang) {
        if (this.voices.length === 0) this.voices = speechSynthesis.getVoices();

        // 1. Check User Preference
        if (this.preferredVoiceURI && this.preferredVoiceURI !== 'force_us') {
            const pref = this.voices.find(v => v.voiceURI === this.preferredVoiceURI);
            if (pref) return pref;
        }

        // 2. Auto-Detect Best Quality
        // Prioritize "Google" voices as they are usually most human-like on Web
        const candidates = this.voices.filter(v => v.lang === lang || v.lang.startsWith(lang.split('-')[0]));
        if (candidates.length === 0) return null;

        const priorities = ['Google', 'Premium', 'Enhanced', 'Zira', 'Samantha', 'United States', 'UK'];

        for (const keyword of priorities) {
            const found = candidates.find(v => v.name.includes(keyword));
            if (found) return found;
        }
        return candidates[0];
    },

    async speak(side, e) {
        if (e) e.stopPropagation();
        const card = this.currentSet.cards[this.cardIndex];
        const text = side === 'front' ? card.term : card.def;

        speechSynthesis.cancel();

        // STRATEGY 1: Real Human Audio (Dictionary API) - English Only
        if (side === 'front') {
            // Clean term (e.g. "A/An" -> "A", "Go!" -> "Go")
            // Also URL Encode for safety
            const cleanTerm = text.split('/')[0].replace(/[^a-zA-Z\s-]/g, '').trim().toLowerCase(); // Allowed hyphens

            try {
                const res = await fetch(`https://api.dictionaryapi.dev/api/v2/entries/en/${encodeURIComponent(cleanTerm)}`);
                if (res.ok) {
                    const data = await res.json();
                    let audioUrl = null;

                    // Look for US audio specifically
                    for (const entry of data) {
                        for (const phon of entry.phonetics) {
                            if (phon.audio && phon.audio.includes('-us.mp3')) {
                                audioUrl = phon.audio;
                                break;
                            }
                        }
                        if (audioUrl) break;
                    }

                    // If no US, take any audio
                    if (!audioUrl) {
                        for (const entry of data) {
                            for (const phon of entry.phonetics) {
                                if (phon.audio) {
                                    audioUrl = phon.audio;
                                    break;
                                }
                            }
                            if (audioUrl) break;
                        }
                    }

                    if (audioUrl) {
                        console.log("Playing real audio:", audioUrl);
                        const audio = new Audio(audioUrl);
                        audio.play();
                        return; // Success! Skip TTS
                    }
                }
            } catch (err) {
                console.warn("Audio fetch failed, falling back to TTS", err);
            }
        }

        // STRATEGY 2: Fallback to TTS (Browser Engine)
        const ut = new SpeechSynthesisUtterance(text);
        const targetLang = side === 'front' ? 'en-US' : 'tr-TR';
        ut.lang = targetLang;

        if (side === 'front' && this.preferredVoiceURI) {
            if (this.preferredVoiceURI !== 'force_us') {
                const voice = this.voices.find(v => v.voiceURI === this.preferredVoiceURI);
                if (voice) ut.voice = voice;
            }
        } else if (side === 'front') {
            const voice = this.getBestVoice('en-US');
            if (voice) ut.voice = voice;
        } else if (side === 'back') {
            const trVoice = this.voices.find(v => v.lang === 'tr-TR');
            if (trVoice) ut.voice = trVoice;
        }

        ut.rate = 0.9;
        ut.pitch = 1.0;

        speechSynthesis.speak(ut);
    },

    /* Mode: Match Game */
    startMatch() {
        const grid = document.getElementById('match-grid');
        grid.innerHTML = '';
        this.selectedTile = null;

        // Take top 8 cards (to make 16 tiles)
        const sub = this.currentSet.cards.slice(0, 8);
        let tiles = [];
        sub.forEach((c, i) => {
            tiles.push({ id: i, text: c.term, type: 'term' });
            tiles.push({ id: i, text: c.def, type: 'def' });
        });

        // Shuffle
        tiles.sort(() => Math.random() - 0.5);

        tiles.forEach(t => {
            const el = document.createElement('div');
            el.className = 'tile';
            el.textContent = t.text;
            el.onclick = () => this.clickTile(el, t);
            grid.appendChild(el);
        });

        // Timer
        this.startTime = Date.now();
        if (this.matchTimer) clearInterval(this.matchTimer);
        this.matchTimer = setInterval(() => {
            const diff = (Date.now() - this.startTime) / 1000;
            document.getElementById('match-timer').textContent = diff.toFixed(1) + 's';
        }, 100);
    },

    clickTile(el, data) {
        if (el.classList.contains('matched')) return;
        if (this.selectedTile && this.selectedTile.el === el) {
            // Deselect
            el.classList.remove('selected');
            this.selectedTile = null;
            return;
        }

        el.classList.add('selected');

        if (!this.selectedTile) {
            this.selectedTile = { el, data };
        } else {
            // Check Match
            const first = this.selectedTile;
            if (first.data.id === data.id) {
                // Match!
                first.el.classList.add('matched');
                el.classList.add('matched');
                this.selectedTile = null;
                this.checkWin();
            } else {
                // Wrong
                el.classList.add('wrong');
                first.el.classList.add('wrong');
                setTimeout(() => {
                    el.classList.remove('selected', 'wrong');
                    first.el.classList.remove('selected', 'wrong');
                }, 500);
                this.selectedTile = null;
            }
        }
    },

    checkWin() {
        const remaining = document.querySelectorAll('.tile:not(.matched)');
        if (remaining.length === 0) {
            clearInterval(this.matchTimer);
            alert(`Finished in ${document.getElementById('match-timer').textContent}!`);
        }
    },

    /* --- FEEDBACK SYSTEM --- */
    feedbackTimer: null,

    showToast(text, type = 'info') {
        let toast = document.getElementById('app-toast');
        if (!toast) {
            toast = document.createElement('div');
            toast.id = 'app-toast';
            toast.style.cssText = `
                position: fixed;
                bottom: 30px;
                left: 50%;
                transform: translateX(-50%) translateY(20px);
                background: rgba(30, 30, 30, 0.95);
                color: white;
                padding: 12px 24px;
                border-radius: 30px;
                font-size: 15px;
                font-weight: 500;
                opacity: 0;
                transition: all 0.3s cubic-bezier(0.175, 0.885, 0.32, 1.275);
                z-index: 1000;
                box-shadow: 0 5px 20px rgba(0,0,0,0.3);
                border: 1px solid rgba(255,255,255,0.1);
                display: flex;
                align-items: center;
                gap: 10px;
                pointer-events: none;
            `;
            document.body.appendChild(toast);
        }

        // Icon based on type
        let icon = '';
        if (type === 'success') icon = '✨';
        if (type === 'star') icon = '⭐';
        if (type === 'nav') icon = '👉';

        toast.innerHTML = `<span style="font-size:1.2em">${icon}</span> <span>${text}</span>`;

        // Animate In
        requestAnimationFrame(() => {
            toast.style.transform = 'translateX(-50%) translateY(0)';
            toast.style.opacity = '1';
        });

        if (this.feedbackTimer) clearTimeout(this.feedbackTimer);
        this.feedbackTimer = setTimeout(() => {
            toast.style.transform = 'translateX(-50%) translateY(20px)';
            toast.style.opacity = '0';
        }, 2000);
    },

    getRandomPhrase(type) {
        const phrases = {
            next: ['Excellent', 'Keep going', 'Good progress', 'Moving on', 'Nice work'],
            prev: ['Reviewing', 'Double check', 'Going back'],
            star: ['Saved to favorites', 'Marked as important', 'Added to list']
        };
        const list = phrases[type] || ['OK'];
        return list[Math.floor(Math.random() * list.length)];
    }
};

app.init();

