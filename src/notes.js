import * as THREE from 'three';
import { MIDIParser } from './midi-parser.js';

export class NotesSystem {
    constructor(scene, config) {
        this.scene = scene;
        this.config = config;
        this.notes = [];
        this.noteMeshes = [];
        this.activeNotes = [];
        this.notesGroup = new THREE.Group();
        this.scene.add(this.notesGroup);

        this.fallDistance = 15; // How far ahead notes appear
        this.fallSpeed = 0.01; // Base speed of falling notes
        
        // Create glowing red play line
        this.createPlayLine();
    }

    createPlayLine() {
        // Create a bright glowing red horizontal line above the piano
        const lineWidth = 20; // Span the entire width
        const lineHeight = 0.05;
        const lineDepth = 0.1;
        
        const geometry = new THREE.BoxGeometry(lineWidth, lineHeight, lineDepth);
        
        // Create a glowing material with high emissive intensity
        const material = new THREE.MeshStandardMaterial({
            color: this.config.playLineColor || 0xff0000,
            emissive: this.config.playLineColor || 0xff0000,
            emissiveIntensity: 2.0,
            roughness: 0.1,
            metalness: 0.9,
            transparent: true,
            opacity: 0.95
        });
        
        this.playLine = new THREE.Mesh(geometry, material);
        this.playLine.position.set(0, 0.4, 0); // Position above the keys
        this.playLine.rotation.x = Math.PI / 2; // Rotate to be horizontal
        
        // Add glow effect using a larger, more transparent mesh
        const glowGeometry = new THREE.BoxGeometry(lineWidth * 1.1, lineHeight * 2, lineDepth * 1.5);
        const glowMaterial = new THREE.MeshBasicMaterial({
            color: this.config.playLineColor || 0xff0000,
            transparent: true,
            opacity: 0.3
        });
        this.playLineGlow = new THREE.Mesh(glowGeometry, glowMaterial);
        this.playLineGlow.position.copy(this.playLine.position);
        this.playLineGlow.rotation.copy(this.playLine.rotation);
        
        this.scene.add(this.playLineGlow);
        this.scene.add(this.playLine);
    }

    updatePlayLineColor(color) {
        if (this.playLine) {
            this.playLine.material.color = new THREE.Color(color);
            this.playLine.material.emissive = new THREE.Color(color);
            this.playLineGlow.material.color = new THREE.Color(color);
        }
    }

    loadNotes(notes) {
        this.clear();
        this.notes = notes;
        this.createNoteMeshes();
    }

    createNoteMeshes() {
        const whiteKeyWidth = 0.12;
        const numWhiteKeys = 52; // Approximate for 88 keys
        const startNote = 21; // A0

        this.notes.forEach((note, index) => {
            const keyIndex = note.midi - startNote;
            const isBlack = MIDIParser.isBlackKey(note.midi);

            // Calculate position based on key index
            let posX = this.calculateKeyPosition(note.midi);

            // Note dimensions
            const noteWidth = isBlack ? 0.08 : 0.11;
            const noteHeight = 0.05;
            const noteLength = Math.max(0.2, (note.duration / 1000) * 2); // Scale by duration

            // Create note geometry with rounded edges
            const geometry = new THREE.BoxGeometry(noteWidth, noteHeight, noteLength);

            // Create vibrant red-orange material with strong glow
            const baseColor = new THREE.Color(this.config.noteColor);
            const velocity = note.velocity || 0.7;

            // Create a gradient from red-orange to bright red based on velocity
            const hue = 0.05; // Red-orange hue
            const saturation = 0.9 + velocity * 0.1;
            const lightness = 0.4 + velocity * 0.3;
            const adjustedColor = new THREE.Color().setHSL(hue, saturation, lightness);

            const material = new THREE.MeshStandardMaterial({
                color: adjustedColor,
                emissive: adjustedColor,
                emissiveIntensity: 1.2, // Much stronger glow
                roughness: 0.2,
                metalness: 0.3,
                transparent: true,
                opacity: 0.95
            });

            const mesh = new THREE.Mesh(geometry, material);

            // Initial position (far away, will fall down)
            mesh.position.x = posX;
            mesh.position.y = 0.5;
            mesh.position.z = -this.fallDistance;

            mesh.castShadow = true;
            mesh.receiveShadow = true;

            // Store note data with mesh
            mesh.userData = {
                note,
                noteLength,
                initialZ: -this.fallDistance,
                isActive: false,
                hasBeenPlayed: false
            };

            this.notesGroup.add(mesh);
            this.noteMeshes.push(mesh);
        });
    }

    calculateKeyPosition(midiNote) {
        // Calculate X position based on piano key layout
        const whiteKeyWidth = 0.12;
        const startNote = 21; // A0
        const numKeys = 88;

        // Count white keys before this note
        let whiteKeysBefore = 0;
        for (let i = startNote; i < midiNote; i++) {
            if (!MIDIParser.isBlackKey(i)) {
                whiteKeysBefore++;
            }
        }

        const isBlack = MIDIParser.isBlackKey(midiNote);
        let posX = whiteKeysBefore * whiteKeyWidth - numKeys * whiteKeyWidth * 0.3;

        if (isBlack) {
            posX += whiteKeyWidth * 0.6;
        }

        return posX;
    }

    updateColors(config) {
        this.config = config;
        this.noteMeshes.forEach(mesh => {
            const velocity = mesh.userData.note.velocity || 0.7;
            const hue = 0.05; // Red-orange hue
            const saturation = 0.9 + velocity * 0.1;
            const lightness = 0.4 + velocity * 0.3;
            const adjustedColor = new THREE.Color().setHSL(hue, saturation, lightness);

            mesh.material.color = adjustedColor;
            if (!mesh.userData.isActive) {
                mesh.material.emissive = adjustedColor;
            }
        });
    }

    reset() {
        this.activeNotes = [];
        this.noteMeshes.forEach(mesh => {
            mesh.userData.isActive = false;
            mesh.userData.hasBeenPlayed = false;
            mesh.visible = true;
            mesh.material.opacity = 0.95;
            mesh.scale.set(1, 1, 1);
            mesh.rotation.y = 0;
        });
    }

    clear() {
        this.notes = [];
        this.activeNotes = [];
        this.noteMeshes.forEach(mesh => {
            this.notesGroup.remove(mesh);
            mesh.geometry.dispose();
            mesh.material.dispose();
        });
        this.noteMeshes = [];
    }

    update(currentTime) {
        // Animate play line with pulsing glow
        if (this.playLine && this.playLineGlow) {
            const pulse = 1.0 + Math.sin(currentTime * 0.005) * 0.2;
            this.playLine.material.emissiveIntensity = 2.0 * pulse;
            this.playLineGlow.material.opacity = 0.3 * pulse;
        }
        
        this.activeNotes = [];

        this.noteMeshes.forEach(mesh => {
            const noteData = mesh.userData.note;
            const noteStartTime = noteData.time;
            const noteEndTime = noteData.time + noteData.duration;

            // Calculate where the note should be
            // Notes appear ahead and fall towards the piano
            const timeDiff = noteStartTime - currentTime;
            const fallProgress = 1 - (timeDiff / (this.fallDistance * 100));

            // Position the note based on time
            const targetZ = -this.fallDistance + (fallProgress * this.fallDistance);
            mesh.position.z = targetZ;

            // Check if note is currently being played
            const isActive = currentTime >= noteStartTime && currentTime <= noteEndTime;

            if (isActive) {
                this.activeNotes.push(noteData);
                mesh.userData.isActive = true;
                mesh.userData.hasBeenPlayed = true;

                // Make active notes glow intensely with pulsing effect
                const pulse = 1.0 + Math.sin(currentTime * 0.01) * 0.3;
                mesh.material.emissiveIntensity = 2.5 * pulse;
                mesh.scale.set(1.15, 1.15, 1.15);
                
                // Make active notes brighter and more saturated
                const activeColor = new THREE.Color().setHSL(0.0, 1.0, 0.6); // Pure bright red
                mesh.material.emissive = activeColor;

            } else {
                mesh.userData.isActive = false;
                mesh.material.emissiveIntensity = 1.2;
                mesh.scale.set(1, 1, 1);
            }

            // Fade out notes that have passed
            if (currentTime > noteEndTime) {
                const fadeTime = 500; // ms
                const timeSinceEnd = currentTime - noteEndTime;
                const fadeProgress = Math.min(1, timeSinceEnd / fadeTime);
                mesh.material.opacity = 0.95 * (1 - fadeProgress);

                // Hide completely faded notes
                mesh.visible = fadeProgress < 1;
            } else {
                mesh.visible = true;

                // Fade in upcoming notes
                if (timeDiff > 0) {
                    const fadeInTime = 1000;
                    const fadeInProgress = Math.max(0, 1 - (timeDiff / fadeInTime));
                    mesh.material.opacity = 0.95 * fadeInProgress;
                } else {
                    mesh.material.opacity = 0.95;
                }
            }

            // Add subtle rotation animation for active notes
            if (isActive) {
                mesh.rotation.y = Math.sin(currentTime * 0.005) * 0.05;
            } else {
                mesh.rotation.y = 0;
            }
        });
    }
}
