import * as THREE from 'three';

export class EffectsSystem {
    constructor(scene, config) {
        this.scene = scene;
        this.config = config;
        this.particles = [];
        this.particlesGroup = new THREE.Group();
        this.scene.add(this.particlesGroup);

        this.maxParticles = 1000;
        this.particlePool = [];

        this.createParticlePool();
        this.addSpotlights();
    }

    createParticlePool() {
        // Create a pool of reusable particles with fiery red appearance
        for (let i = 0; i < this.maxParticles; i++) {
            // Use slightly larger particles for better visibility
            const geometry = new THREE.SphereGeometry(0.03, 8, 8);
            const material = new THREE.MeshBasicMaterial({
                color: this.config.particleColor || 0xff4400,
                transparent: true,
                opacity: 0,
                emissive: this.config.particleColor || 0xff4400
            });

            const particle = new THREE.Mesh(geometry, material);
            particle.userData = {
                active: false,
                velocity: new THREE.Vector3(),
                life: 0,
                maxLife: 800 + Math.random() * 400, // Vary lifetime for more natural effect
                size: 0.03 + Math.random() * 0.02 // Vary size
            };

            this.particlesGroup.add(particle);
            this.particlePool.push(particle);
        }
    }

    addSpotlights() {
        // Add dynamic spotlights with red theme
        this.spotlights = [];

        for (let i = 0; i < 3; i++) {
            const spotlight = new THREE.SpotLight(0xff3300, 0, 25, Math.PI / 5, 0.4, 2);
            spotlight.position.set(
                (i - 1) * 3,
                6,
                -3
            );
            spotlight.target.position.set((i - 1) * 3, 0, 0);
            spotlight.castShadow = false;

            this.scene.add(spotlight);
            this.scene.add(spotlight.target);
            this.spotlights.push({
                light: spotlight,
                baseIntensity: 0,
                targetIntensity: 0,
                color: new THREE.Color(0xff3300)
            });
        }
    }

    emitParticles(position, color, count = 15) {
        if (!this.config.particlesEnabled) return;

        const particleColor = this.config.particleColor || color || 0xff4400;

        for (let i = 0; i < count; i++) {
            // Find an inactive particle
            const particle = this.particlePool.find(p => !p.userData.active);
            if (!particle) break;

            // Activate and position particle
            particle.userData.active = true;
            particle.userData.life = 0;
            particle.userData.maxLife = 600 + Math.random() * 400;

            particle.position.copy(position);
            particle.position.y += 0.15 + Math.random() * 0.1;
            particle.position.x += (Math.random() - 0.5) * 0.1;
            particle.position.z += (Math.random() - 0.5) * 0.1;

            // More dynamic velocity for fiery effect
            const speed = 0.02 + Math.random() * 0.03;
            particle.userData.velocity.set(
                (Math.random() - 0.5) * 0.03,
                Math.random() * 0.04 + 0.02,
                (Math.random() - 0.5) * 0.03
            );

            // Vary particle color slightly for more natural fiery look
            const hueVariation = (Math.random() - 0.5) * 0.05; // Slight orange-red variation
            const particleHue = 0.05 + hueVariation; // Red-orange range
            const particleColorHSL = new THREE.Color().setHSL(
                particleHue,
                0.9 + Math.random() * 0.1,
                0.5 + Math.random() * 0.3
            );

            particle.material.color = particleColorHSL;
            particle.material.emissive = particleColorHSL;
            particle.material.opacity = 0.9 + Math.random() * 0.1;
            
            // Set initial scale
            const scale = particle.userData.size || 0.03;
            particle.scale.set(scale, scale, scale);

            this.particles.push(particle);
        }
    }

    update(currentTime, activeNotes, keyPositions) {
        // Update particles
        for (let i = this.particles.length - 1; i >= 0; i--) {
            const particle = this.particles[i];
            const data = particle.userData;

            if (!data.active) {
                this.particles.splice(i, 1);
                continue;
            }

            // Update lifetime
            data.life += 16; // Assuming ~60fps

            if (data.life >= data.maxLife) {
                data.active = false;
                particle.material.opacity = 0;
                this.particles.splice(i, 1);
                continue;
            }

            // Update position
            particle.position.add(data.velocity);

            // Apply gravity (lighter for more floaty, fiery effect)
            data.velocity.y -= 0.0005;
            
            // Add some turbulence for smoky effect
            data.velocity.x += (Math.random() - 0.5) * 0.001;
            data.velocity.z += (Math.random() - 0.5) * 0.001;

            // Fade out with more dramatic effect
            const lifeProgress = data.life / data.maxLife;
            particle.material.opacity = (1 - lifeProgress) * this.config.glowIntensity * 0.8;
            
            // Gradually shift color from bright red to darker red as it fades
            const fadeHue = 0.05 - lifeProgress * 0.02; // Shift towards darker red
            const fadeColor = new THREE.Color().setHSL(
                fadeHue,
                0.7 + lifeProgress * 0.2,
                0.3 + (1 - lifeProgress) * 0.3
            );
            particle.material.color = fadeColor;
            particle.material.emissive = fadeColor;

            // Shrink and grow slightly for more dynamic effect
            const baseScale = particle.userData.size || 0.03;
            const scaleVariation = Math.sin(data.life * 0.01) * 0.1;
            const scale = baseScale * (1 - lifeProgress * 0.6 + scaleVariation);
            particle.scale.set(scale, scale, scale);
        }

        // Emit particles from active keys with more intensity
        if (activeNotes.length > 0 && this.config.particlesEnabled) {
            keyPositions.forEach((pos, index) => {
                // Higher chance and more particles for dramatic effect
                if (Math.random() < 0.5) { // 50% chance per frame
                    const particleCount = 8 + Math.floor(Math.random() * 7); // 8-15 particles
                    this.emitParticles(pos, this.config.particleColor || this.config.activeKeyColor, particleCount);
                }
            });
        }

        // Update spotlights based on active notes
        this.spotlights.forEach((spotlight, index) => {
            // Calculate target intensity based on nearby active notes
            let targetIntensity = 0;

            activeNotes.forEach(note => {
                const notePos = this.calculateNotePosition(note.midi);
                const spotlightX = spotlight.light.position.x;
                const distance = Math.abs(notePos - spotlightX);

                if (distance < 2) {
                    targetIntensity += (1 - distance / 2) * 2;
                }
            });

            spotlight.targetIntensity = Math.min(targetIntensity, 3) * this.config.glowIntensity;

            // Smooth transition
            spotlight.baseIntensity += (spotlight.targetIntensity - spotlight.baseIntensity) * 0.1;
            spotlight.light.intensity = spotlight.baseIntensity;

            // Keep red-orange color theme, vary intensity
            if (spotlight.baseIntensity > 0.1) {
                // Slight hue variation in red-orange range
                const hue = 0.05 + Math.sin(currentTime * 0.0005 + index) * 0.02;
                spotlight.light.color.setHSL(hue, 0.9, 0.5);
            }

            // Subtle movement
            spotlight.light.position.y = 5 + Math.sin(currentTime * 0.001 + index) * 0.3;
        });
    }

    calculateNotePosition(midiNote) {
        const whiteKeyWidth = 0.12;
        const startNote = 21;
        const numKeys = 88;

        let whiteKeysBefore = 0;
        for (let i = startNote; i < midiNote; i++) {
            const noteInOctave = i % 12;
            const isBlack = [1, 3, 6, 8, 10].includes(noteInOctave);
            if (!isBlack) {
                whiteKeysBefore++;
            }
        }

        return whiteKeysBefore * whiteKeyWidth - numKeys * whiteKeyWidth * 0.3;
    }

    setParticlesEnabled(enabled) {
        this.config.particlesEnabled = enabled;

        if (!enabled) {
            // Clear all active particles
            this.particles.forEach(particle => {
                particle.userData.active = false;
                particle.material.opacity = 0;
            });
            this.particles = [];
        }
    }

    setGlowIntensity(intensity) {
        this.config.glowIntensity = intensity;
    }
}
