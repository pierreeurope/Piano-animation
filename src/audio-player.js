import * as Tone from 'tone';

export class AudioPlayer {
    constructor() {
        this.synth = null;
        this.isInitialized = false;
        this.scheduledNotes = [];
        this.activeSynths = new Map();
        this.volume = -8; // dB
    }

    async init() {
        if (this.isInitialized) return;

        // Initialize Tone.js audio context
        await Tone.start();
        console.log('Audio context started');

        // Create a polyphonic synth for piano sounds
        this.synth = new Tone.PolySynth(Tone.Synth, {
            oscillator: {
                type: 'triangle'
            },
            envelope: {
                attack: 0.005,
                decay: 0.1,
                sustain: 0.3,
                release: 1
            },
            volume: this.volume
        }).toDestination();

        this.isInitialized = true;
    }

    loadNotes(notes) {
        // Clear any previously scheduled notes
        this.clear();

        // Store notes for playback
        this.scheduledNotes = notes.map(note => ({
            ...note,
            frequency: Tone.Frequency(note.midi, "midi").toFrequency()
        }));
    }

    async play(currentTime) {
        if (!this.isInitialized) {
            await this.init();
        }

        // Find notes that should be playing at current time
        this.scheduledNotes.forEach(note => {
            const noteId = `${note.id}`;
            const shouldBePlaying = currentTime >= note.time && currentTime < note.time + note.duration;

            if (shouldBePlaying && !this.activeSynths.has(noteId)) {
                // Start this note
                const frequency = note.frequency;
                const velocity = note.velocity || 0.7;

                try {
                    this.synth.triggerAttack(frequency, undefined, velocity);
                    this.activeSynths.set(noteId, {
                        frequency,
                        startTime: currentTime
                    });
                } catch (error) {
                    console.warn('Error triggering note:', error);
                }
            } else if (!shouldBePlaying && this.activeSynths.has(noteId)) {
                // Stop this note
                const activeNote = this.activeSynths.get(noteId);
                try {
                    this.synth.triggerRelease(activeNote.frequency);
                    this.activeSynths.delete(noteId);
                } catch (error) {
                    console.warn('Error releasing note:', error);
                }
            }
        });
    }

    pause() {
        // Release all currently playing notes
        this.activeSynths.forEach((note, id) => {
            try {
                this.synth.triggerRelease(note.frequency);
            } catch (error) {
                console.warn('Error releasing note on pause:', error);
            }
        });
        this.activeSynths.clear();
    }

    stop() {
        this.pause();
        Tone.Transport.stop();
    }

    clear() {
        this.stop();
        this.scheduledNotes = [];
    }

    setVolume(volumeDb) {
        this.volume = volumeDb;
        if (this.synth) {
            this.synth.volume.value = volumeDb;
        }
    }

    dispose() {
        if (this.synth) {
            this.synth.dispose();
        }
        this.isInitialized = false;
    }
}
