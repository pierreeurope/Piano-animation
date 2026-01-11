#!/usr/bin/env python3
"""
Generate a simple test MIDI file for testing the visualizer
Creates a simple C major scale and chord progression
"""

import pretty_midi
import numpy as np


def create_test_midi(output_file='test_song.mid'):
    """Create a simple test MIDI file with scales and chords"""

    # Create a PrettyMIDI object
    midi = pretty_midi.PrettyMIDI()

    # Create an instrument (Acoustic Grand Piano)
    piano = pretty_midi.Instrument(program=0)

    # C major scale - ascending
    scale_notes = [60, 62, 64, 65, 67, 69, 71, 72]  # C4 to C5
    time = 0
    duration = 0.5

    print("Creating test MIDI file...")

    # Play scale ascending
    for note in scale_notes:
        note_obj = pretty_midi.Note(
            velocity=80,
            pitch=note,
            start=time,
            end=time + duration
        )
        piano.notes.append(note_obj)
        time += duration

    time += 0.5  # Pause

    # Play scale descending
    for note in reversed(scale_notes):
        note_obj = pretty_midi.Note(
            velocity=80,
            pitch=note,
            start=time,
            end=time + duration
        )
        piano.notes.append(note_obj)
        time += duration

    time += 1  # Longer pause

    # Play some chords
    chord_progressions = [
        [60, 64, 67],  # C major
        [65, 69, 72],  # F major
        [67, 71, 74],  # G major
        [60, 64, 67],  # C major
    ]

    chord_duration = 2.0

    for chord in chord_progressions:
        # Play all notes in chord simultaneously
        for pitch in chord:
            note_obj = pretty_midi.Note(
                velocity=90,
                pitch=pitch,
                start=time,
                end=time + chord_duration
            )
            piano.notes.append(note_obj)

        time += chord_duration

    time += 1

    # Play a simple melody
    melody = [
        (64, 0.5, 80),  # E
        (64, 0.5, 80),  # E
        (65, 0.5, 80),  # F
        (67, 0.5, 80),  # G
        (67, 0.5, 80),  # G
        (65, 0.5, 80),  # F
        (64, 0.5, 80),  # E
        (62, 0.5, 80),  # D
        (60, 0.5, 80),  # C
        (60, 0.5, 80),  # C
        (62, 0.5, 80),  # D
        (64, 0.5, 80),  # E
        (64, 1.0, 80),  # E (longer)
        (62, 0.5, 80),  # D
        (62, 1.0, 80),  # D (longer)
    ]

    for pitch, dur, velocity in melody:
        note_obj = pretty_midi.Note(
            velocity=velocity,
            pitch=pitch,
            start=time,
            end=time + dur
        )
        piano.notes.append(note_obj)
        time += dur

    # Add the instrument to the MIDI object
    midi.instruments.append(piano)

    # Save to file
    midi.write(output_file)
    print(f"✅ Test MIDI file created: {output_file}")
    print(f"   Duration: {time:.2f} seconds")
    print(f"   Total notes: {len(piano.notes)}")
    print()
    print("Try it with:")
    print(f"  Web:    npm run dev (then drag {output_file})")
    print(f"  Python: python python/visualizer.py {output_file}")


if __name__ == '__main__':
    create_test_midi()
