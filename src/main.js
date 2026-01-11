import * as THREE from 'three';
import { Piano } from './piano.js';
import { NotesSystem } from './notes.js';
import { MIDIParser } from './midi-parser.js';
import { EffectsSystem } from './effects.js';
import { AudioPlayer } from './audio-player.js';

class PianoVisualizer {
    constructor() {
        this.scene = null;
        this.camera = null;
        this.renderer = null;
        this.piano = null;
        this.notesSystem = null;
        this.effectsSystem = null;
        this.midiParser = null;
        this.audioPlayer = null;
        this.isPlaying = false;
        this.startTime = 0;
        this.currentTime = 0;
        this.animationId = null;

        this.config = {
            bgColor: 0x000000, // Pure black for high contrast
            pianoColor: 0x1a1a1a,
            whiteKeyColor: 0xffffff,
            blackKeyColor: 0x0a0a0a,
            activeKeyColor: 0xff0000, // Bright red for active keys
            noteColor: 0xff3300, // Vibrant red-orange for notes
            particleColor: 0xff4400, // Fiery red-orange for particles
            playLineColor: 0xff0000, // Bright red for play line
            particlesEnabled: true,
            glowIntensity: 2.0, // Increased for more dramatic glow
            noteSpeed: 1.0,
            cameraPreset: 'front',
            cameraDistance: 5
        };

        this.init();
        this.setupEventListeners();
    }

    init() {
        // Scene
        this.scene = new THREE.Scene();
        this.scene.background = new THREE.Color(this.config.bgColor);
        this.scene.fog = new THREE.Fog(this.config.bgColor, 15, 40); // Adjusted for better visibility

        // Camera
        this.camera = new THREE.PerspectiveCamera(
            75,
            window.innerWidth / window.innerHeight,
            0.1,
            1000
        );
        this.updateCameraPosition();

        // Renderer
        this.renderer = new THREE.WebGLRenderer({
            antialias: true,
            alpha: true
        });
        this.renderer.setSize(window.innerWidth, window.innerHeight);
        this.renderer.setPixelRatio(Math.min(window.devicePixelRatio, 2));
        this.renderer.shadowMap.enabled = true;
        this.renderer.shadowMap.type = THREE.PCFSoftShadowMap;

        document.getElementById('canvas-container').appendChild(this.renderer.domElement);

        // Initialize systems
        this.piano = new Piano(this.scene, this.config);
        this.notesSystem = new NotesSystem(this.scene, this.config);
        this.effectsSystem = new EffectsSystem(this.scene, this.config);
        this.midiParser = new MIDIParser();
        this.audioPlayer = new AudioPlayer();

        // Handle window resize
        window.addEventListener('resize', () => this.onWindowResize());

        // Start animation loop
        this.animate();
    }

    setupEventListeners() {
        const dropZone = document.getElementById('drop-zone');
        const fileInput = document.getElementById('file-input');

        // File input
        dropZone.addEventListener('click', () => fileInput.click());
        fileInput.addEventListener('change', (e) => this.handleFile(e.target.files[0]));

        // Drag and drop
        dropZone.addEventListener('dragover', (e) => {
            e.preventDefault();
            dropZone.classList.add('drag-over');
        });

        dropZone.addEventListener('dragleave', () => {
            dropZone.classList.remove('drag-over');
        });

        dropZone.addEventListener('drop', (e) => {
            e.preventDefault();
            dropZone.classList.remove('drag-over');
            const file = e.dataTransfer.files[0];
            if (file && (file.name.endsWith('.mid') || file.name.endsWith('.midi'))) {
                this.handleFile(file);
            }
        });

        // Color controls
        document.getElementById('bg-color').addEventListener('input', (e) => {
            this.config.bgColor = parseInt(e.target.value.replace('#', '0x'));
            this.scene.background = new THREE.Color(this.config.bgColor);
            this.scene.fog.color = new THREE.Color(this.config.bgColor);
        });

        document.getElementById('piano-color').addEventListener('input', (e) => {
            this.config.pianoColor = parseInt(e.target.value.replace('#', '0x'));
            this.piano.updateColors(this.config);
        });

        document.getElementById('white-keys-color').addEventListener('input', (e) => {
            this.config.whiteKeyColor = parseInt(e.target.value.replace('#', '0x'));
            this.piano.updateColors(this.config);
        });

        document.getElementById('black-keys-color').addEventListener('input', (e) => {
            this.config.blackKeyColor = parseInt(e.target.value.replace('#', '0x'));
            this.piano.updateColors(this.config);
        });

        document.getElementById('active-key-color').addEventListener('input', (e) => {
            this.config.activeKeyColor = parseInt(e.target.value.replace('#', '0x'));
        });

        document.getElementById('note-color').addEventListener('input', (e) => {
            this.config.noteColor = parseInt(e.target.value.replace('#', '0x'));
            this.notesSystem.updateColors(this.config);
        });

        document.getElementById('play-line-color').addEventListener('input', (e) => {
            this.config.playLineColor = parseInt(e.target.value.replace('#', '0x'));
            this.notesSystem.updatePlayLineColor(this.config.playLineColor);
        });

        // Effects controls
        document.getElementById('particles').addEventListener('input', (e) => {
            this.config.particlesEnabled = e.target.value === '1';
            document.getElementById('particles-value').textContent = this.config.particlesEnabled ? 'On' : 'Off';
            this.effectsSystem.setParticlesEnabled(this.config.particlesEnabled);
        });

        document.getElementById('glow-intensity').addEventListener('input', (e) => {
            this.config.glowIntensity = parseFloat(e.target.value);
            document.getElementById('glow-value').textContent = this.config.glowIntensity.toFixed(1);
            this.effectsSystem.setGlowIntensity(this.config.glowIntensity);
        });

        document.getElementById('note-speed').addEventListener('input', (e) => {
            this.config.noteSpeed = parseFloat(e.target.value);
            document.getElementById('speed-value').textContent = this.config.noteSpeed.toFixed(1) + 'x';
        });

        // Camera controls
        document.getElementById('camera-preset').addEventListener('change', (e) => {
            this.config.cameraPreset = e.target.value;
            this.updateCameraPosition();
        });

        document.getElementById('camera-distance').addEventListener('input', (e) => {
            this.config.cameraDistance = parseFloat(e.target.value);
            document.getElementById('distance-value').textContent = this.config.cameraDistance.toFixed(1);
            this.updateCameraPosition();
        });

        // Playback controls
        document.getElementById('volume').addEventListener('input', (e) => {
            const volume = parseInt(e.target.value);
            document.getElementById('volume-value').textContent = volume + '%';
            // Convert 0-100 to dB (-60 to 0)
            const volumeDb = volume === 0 ? -60 : ((volume / 100) * 60) - 60;
            this.audioPlayer.setVolume(volumeDb);
        });

        document.getElementById('play-pause').addEventListener('click', () => this.togglePlayPause());
        document.getElementById('restart').addEventListener('click', () => this.restart());
        document.getElementById('load-new').addEventListener('click', () => this.loadNewFile());
    }

    async handleFile(file) {
        if (!file) return;

        try {
            const arrayBuffer = await file.arrayBuffer();
            const midiData = await this.midiParser.parse(arrayBuffer);

            // Update UI
            document.getElementById('drop-zone').classList.add('hidden');
            document.getElementById('controls').classList.remove('hidden');
            document.getElementById('file-info').classList.remove('hidden');

            document.getElementById('file-name').textContent = file.name;
            document.getElementById('file-duration').textContent = this.formatTime(midiData.duration);
            document.getElementById('file-notes').textContent = midiData.notes.length;

            // Load notes for visualization and audio
            this.notesSystem.loadNotes(midiData.notes);
            this.audioPlayer.loadNotes(midiData.notes);
            this.restart();

        } catch (error) {
            console.error('Error loading MIDI file:', error);
            alert('Error loading MIDI file. Please try another file.');
        }
    }

    updateCameraPosition() {
        const dist = this.config.cameraDistance;

        switch (this.config.cameraPreset) {
            case 'front':
                this.camera.position.set(0, 3, dist);
                this.camera.lookAt(0, 0, 0);
                break;
            case 'top':
                this.camera.position.set(0, dist * 1.5, 2);
                this.camera.lookAt(0, 0, -2);
                break;
            case 'side':
                this.camera.position.set(dist, 2, 2);
                this.camera.lookAt(0, 0, 0);
                break;
            case 'dynamic':
                // Will be updated in animation loop
                this.camera.position.set(0, 4, dist);
                this.camera.lookAt(0, 0, 0);
                break;
        }
    }

    async togglePlayPause() {
        this.isPlaying = !this.isPlaying;
        const btn = document.getElementById('play-pause');
        btn.textContent = this.isPlaying ? '⏸ Pause' : '▶ Play';

        if (this.isPlaying) {
            this.startTime = Date.now() - this.currentTime;
            // Initialize audio on first play (requires user interaction)
            if (!this.audioPlayer.isInitialized) {
                await this.audioPlayer.init();
            }
        } else {
            // Pause audio
            this.audioPlayer.pause();
        }
    }

    async restart() {
        this.currentTime = 0;
        this.startTime = Date.now();
        this.isPlaying = true;
        document.getElementById('play-pause').textContent = '⏸ Pause';
        this.notesSystem.reset();
        this.piano.reset();
        this.audioPlayer.stop();

        // Initialize audio if not already done
        if (!this.audioPlayer.isInitialized) {
            await this.audioPlayer.init();
        }
    }

    loadNewFile() {
        document.getElementById('drop-zone').classList.remove('hidden');
        document.getElementById('controls').classList.add('hidden');
        document.getElementById('file-info').classList.add('hidden');
        this.isPlaying = false;
        this.currentTime = 0;
        this.notesSystem.clear();
        this.piano.reset();
        this.audioPlayer.clear();
    }

    animate() {
        this.animationId = requestAnimationFrame(() => this.animate());

        if (this.isPlaying) {
            this.currentTime = (Date.now() - this.startTime) * this.config.noteSpeed;
        }

        // Update systems
        this.notesSystem.update(this.currentTime);
        this.piano.update(this.currentTime, this.notesSystem.activeNotes);
        this.effectsSystem.update(this.currentTime, this.notesSystem.activeNotes, this.piano.getKeyPositions());

        // Update audio playback
        if (this.isPlaying && this.audioPlayer.isInitialized) {
            this.audioPlayer.play(this.currentTime);
        }

        // Dynamic camera
        if (this.config.cameraPreset === 'dynamic') {
            const wobble = Math.sin(this.currentTime * 0.0005) * 0.5;
            this.camera.position.y = 4 + wobble;
            this.camera.lookAt(0, 0, wobble * 2);
        }

        this.renderer.render(this.scene, this.camera);
    }

    onWindowResize() {
        this.camera.aspect = window.innerWidth / window.innerHeight;
        this.camera.updateProjectionMatrix();
        this.renderer.setSize(window.innerWidth, window.innerHeight);
    }

    formatTime(seconds) {
        const mins = Math.floor(seconds / 60);
        const secs = Math.floor(seconds % 60);
        return `${mins}:${secs.toString().padStart(2, '0')}`;
    }
}

// Initialize the visualizer when the page loads
new PianoVisualizer();
