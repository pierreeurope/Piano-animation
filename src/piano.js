import * as THREE from 'three';
import { MIDIParser } from './midi-parser.js';

export class Piano {
    constructor(scene, config) {
        this.scene = scene;
        this.config = config;
        this.keys = [];
        this.activeKeys = new Set();
        this.keyGlowIntensity = new Map();

        this.createPiano();
    }

    createPiano() {
        // Piano dimensions
        const whiteKeyWidth = 0.12;
        const whiteKeyLength = 0.8;
        const whiteKeyHeight = 0.08;
        const blackKeyWidth = 0.08;
        const blackKeyLength = 0.5;
        const blackKeyHeight = 0.12;

        // 88 keys on a standard piano (A0 to C8)
        const numKeys = 88;
        const startNote = 21; // A0

        // Create piano base
        const baseGeometry = new THREE.BoxGeometry(numKeys * whiteKeyWidth * 0.6, 0.2, whiteKeyLength * 1.2);
        const baseMaterial = new THREE.MeshStandardMaterial({
            color: this.config.pianoColor,
            roughness: 0.3,
            metalness: 0.7
        });
        const base = new THREE.Mesh(baseGeometry, baseMaterial);
        base.position.y = -0.15;
        base.receiveShadow = true;
        this.scene.add(base);

        let whiteKeyIndex = 0;
        const whiteKeyPositions = [];

        // Create white keys first to get positions
        for (let i = 0; i < numKeys; i++) {
            const midiNote = startNote + i;
            if (!MIDIParser.isBlackKey(midiNote)) {
                whiteKeyPositions.push(whiteKeyIndex * whiteKeyWidth);
                whiteKeyIndex++;
            }
        }

        // Create all keys
        whiteKeyIndex = 0;
        let blackKeyIndexInGroup = 0;

        for (let i = 0; i < numKeys; i++) {
            const midiNote = startNote + i;
            const isBlack = MIDIParser.isBlackKey(midiNote);

            let keyGeometry, keyMaterial, posX, posY, posZ;

            if (isBlack) {
                // Black key with glossy finish
                keyGeometry = new THREE.BoxGeometry(blackKeyWidth, blackKeyHeight, blackKeyLength);
                keyMaterial = new THREE.MeshStandardMaterial({
                    color: this.config.blackKeyColor,
                    roughness: 0.1,
                    metalness: 0.9,
                    envMapIntensity: 1.0
                });

                // Position black keys between white keys
                posX = whiteKeyPositions[whiteKeyIndex - 1] + whiteKeyWidth * 0.6 - numKeys * whiteKeyWidth * 0.3;
                posY = blackKeyHeight / 2 + 0.02;
                posZ = -whiteKeyLength / 4;

            } else {
                // White key with glossy, reflective finish
                keyGeometry = new THREE.BoxGeometry(whiteKeyWidth, whiteKeyHeight, whiteKeyLength);
                keyMaterial = new THREE.MeshStandardMaterial({
                    color: this.config.whiteKeyColor,
                    roughness: 0.2,
                    metalness: 0.3,
                    envMapIntensity: 1.2
                });

                posX = whiteKeyPositions[whiteKeyIndex] - numKeys * whiteKeyWidth * 0.3;
                posY = whiteKeyHeight / 2;
                posZ = 0;

                whiteKeyIndex++;
            }

            const key = new THREE.Mesh(keyGeometry, keyMaterial);
            key.position.set(posX, posY, posZ);
            key.castShadow = true;
            key.receiveShadow = true;

            this.scene.add(key);

            this.keys.push({
                mesh: key,
                midiNote,
                isBlack,
                originalY: posY,
                originalColor: isBlack ? this.config.blackKeyColor : this.config.whiteKeyColor,
                originalMaterial: keyMaterial.clone()
            });
        }

        // Add dramatic lighting for high contrast
        const ambientLight = new THREE.AmbientLight(0xffffff, 0.3);
        this.scene.add(ambientLight);

        // Main light from above with blue-white tint (like in the image)
        const mainLight = new THREE.DirectionalLight(0xaaccff, 1.2);
        mainLight.position.set(0, 12, 5);
        mainLight.castShadow = true;
        mainLight.shadow.mapSize.width = 2048;
        mainLight.shadow.mapSize.height = 2048;
        mainLight.shadow.camera.near = 0.5;
        mainLight.shadow.camera.far = 50;
        mainLight.shadow.camera.left = -10;
        mainLight.shadow.camera.right = 10;
        mainLight.shadow.camera.top = 10;
        mainLight.shadow.camera.bottom = -10;
        this.scene.add(mainLight);

        // Red fill light for dramatic effect
        const redFillLight = new THREE.DirectionalLight(0xff3300, 0.4);
        redFillLight.position.set(-5, 5, -5);
        this.scene.add(redFillLight);

        // Rim light for edge definition
        const rimLight = new THREE.DirectionalLight(0xffaaaa, 0.3);
        rimLight.position.set(0, 2, -10);
        this.scene.add(rimLight);
    }

    update(currentTime, activeNotes) {
        // Update key states based on active notes
        const currentActiveNotes = new Set(activeNotes.map(n => n.midi));

        // Animate key presses and glows
        this.keys.forEach(keyData => {
            const isActive = currentActiveNotes.has(keyData.midiNote);
            const wasActive = this.activeKeys.has(keyData.midiNote);

            if (isActive && !wasActive) {
                // Key just pressed
                this.activeKeys.add(keyData.midiNote);
                this.keyGlowIntensity.set(keyData.midiNote, 1.0);
            } else if (!isActive && wasActive) {
                // Key just released
                this.activeKeys.delete(keyData.midiNote);
            }

            // Get current glow intensity
            let glowIntensity = this.keyGlowIntensity.get(keyData.midiNote) || 0;

            if (isActive) {
                // Fade in quickly
                glowIntensity = Math.min(1.0, glowIntensity + 0.1);
            } else {
                // Fade out slowly
                glowIntensity = Math.max(0, glowIntensity - 0.05);
            }

            this.keyGlowIntensity.set(keyData.midiNote, glowIntensity);

            // Animate key press (push down)
            const targetY = isActive ? keyData.originalY - 0.01 : keyData.originalY;
            keyData.mesh.position.y += (targetY - keyData.mesh.position.y) * 0.3;

            // Update key color with intense white-to-red glow
            if (glowIntensity > 0) {
                const glowColor = new THREE.Color(this.config.activeKeyColor);
                const originalColor = new THREE.Color(keyData.originalColor);
                
                // Create white-to-red gradient based on intensity
                const whiteGlow = new THREE.Color(0xffffff);
                const redGlow = new THREE.Color(this.config.activeKeyColor);
                
                // Start with white at high intensity, fade to red
                let finalGlowColor;
                if (glowIntensity > 0.7) {
                    // Bright white glow when first pressed
                    finalGlowColor = whiteGlow.clone().lerp(redGlow, (glowIntensity - 0.7) / 0.3);
                } else {
                    // Red glow as it fades
                    finalGlowColor = redGlow;
                }
                
                const mixedColor = originalColor.clone().lerp(finalGlowColor, glowIntensity * 0.9);

                keyData.mesh.material.color = mixedColor;
                keyData.mesh.material.emissive = finalGlowColor;
                keyData.mesh.material.emissiveIntensity = glowIntensity * 2.5; // Much more intense
            } else {
                keyData.mesh.material.color = new THREE.Color(keyData.originalColor);
                keyData.mesh.material.emissive = new THREE.Color(0x000000);
                keyData.mesh.material.emissiveIntensity = 0;
            }
        });
    }

    updateColors(config) {
        this.config = config;
        this.keys.forEach(keyData => {
            if (!this.activeKeys.has(keyData.midiNote)) {
                const newColor = keyData.isBlack ? config.blackKeyColor : config.whiteKeyColor;
                keyData.originalColor = newColor;
                keyData.mesh.material.color = new THREE.Color(newColor);
            }
        });
    }

    reset() {
        this.activeKeys.clear();
        this.keyGlowIntensity.clear();
        this.keys.forEach(keyData => {
            keyData.mesh.position.y = keyData.originalY;
            keyData.mesh.material.color = new THREE.Color(keyData.originalColor);
            keyData.mesh.material.emissive = new THREE.Color(0x000000);
            keyData.mesh.material.emissiveIntensity = 0;
        });
    }

    getKeyPositions() {
        // Return positions of currently active keys for particle effects
        return this.keys
            .filter(k => this.activeKeys.has(k.midiNote))
            .map(k => k.mesh.position.clone());
    }
}
