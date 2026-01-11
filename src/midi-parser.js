import { Midi } from '@tonejs/midi';

export class MIDIParser {
    constructor() {
        this.midiData = null;
    }

    async parse(arrayBuffer) {
        // Parse MIDI file using Tone.js MIDI
        this.midiData = new Midi(arrayBuffer);

        // Extract all notes from all tracks
        const notes = [];
        let noteId = 0;

        this.midiData.tracks.forEach((track, trackIndex) => {
            track.notes.forEach(note => {
                notes.push({
                    id: noteId++,
                    midi: note.midi,
                    time: note.time * 1000, // Convert to milliseconds
                    duration: note.duration * 1000,
                    velocity: note.velocity,
                    name: note.name,
                    trackIndex
                });
            });
        });

        // Sort notes by time
        notes.sort((a, b) => a.time - b.time);

        // Calculate duration
        const lastNote = notes[notes.length - 1];
        const duration = lastNote ? (lastNote.time + lastNote.duration) / 1000 : 0;

        return {
            notes,
            duration,
            name: this.midiData.name || 'Untitled',
            tracks: this.midiData.tracks.length,
            tempos: this.midiData.header.tempos
        };
    }

    // Convert MIDI note number to piano key index (0-87 for 88 keys, starting at A0)
    static midiToKeyIndex(midiNote) {
        // Standard piano: A0 (MIDI 21) to C8 (MIDI 108)
        return midiNote - 21;
    }

    // Check if a MIDI note is a black key
    static isBlackKey(midiNote) {
        const noteInOctave = midiNote % 12;
        return [1, 3, 6, 8, 10].includes(noteInOctave); // C#, D#, F#, G#, A#
    }

    // Get note name from MIDI number
    static getNoteName(midiNote) {
        const noteNames = ['C', 'C#', 'D', 'D#', 'E', 'F', 'F#', 'G', 'G#', 'A', 'A#', 'B'];
        const octave = Math.floor(midiNote / 12) - 1;
        const noteName = noteNames[midiNote % 12];
        return `${noteName}${octave}`;
    }
}
