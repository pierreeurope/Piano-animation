#!/usr/bin/env python3
"""
Python-based Piano Visualizer
Creates beautiful piano roll visualizations from MIDI files with customizable colors
"""

import numpy as np
import matplotlib.pyplot as plt
import matplotlib.animation as animation
from matplotlib.patches import Rectangle
from matplotlib.collections import PatchCollection
import pretty_midi
import argparse
import json
from pathlib import Path
import subprocess
import shutil


class PianoVisualizer:
    """Creates beautiful piano visualizations from MIDI files"""

    def __init__(self, midi_file, config_file=None):
        self.midi_file = midi_file
        self.midi_data = pretty_midi.PrettyMIDI(midi_file)

        # Load configuration
        self.config = self.load_config(config_file)

        # Piano settings
        self.num_keys = 88
        self.start_note = 21  # A0
        self.end_note = 108   # C8

        # Extract notes
        self.notes = self.extract_notes()
        self.duration = self.midi_data.get_end_time()

        print(f"Loaded MIDI file: {midi_file}")
        print(f"Duration: {self.duration:.2f} seconds")
        print(f"Total notes: {len(self.notes)}")

    def load_config(self, config_file):
        """Load color configuration from JSON file"""
        default_config = {
            "background_color": "#1a1a2e",
            "piano_color": "#2a2a3e",
            "white_key_color": "#ffffff",
            "black_key_color": "#1a1a1a",
            "note_colors": ["#667eea", "#764ba2", "#f093fb", "#4facfe"],
            "active_key_color": "#00ff88",
            "grid_color": "#ffffff",
            "grid_alpha": 0.1
        }

        if config_file and Path(config_file).exists():
            with open(config_file, 'r') as f:
                user_config = json.load(f)
                default_config.update(user_config)

        return default_config

    def extract_notes(self):
        """Extract all notes from MIDI file"""
        notes = []

        for instrument in self.midi_data.instruments:
            for note in instrument.notes:
                if self.start_note <= note.pitch <= self.end_note:
                    notes.append({
                        'pitch': note.pitch,
                        'start': note.start,
                        'end': note.end,
                        'velocity': note.velocity,
                        'duration': note.end - note.start
                    })

        return sorted(notes, key=lambda x: x['start'])

    def is_black_key(self, midi_note):
        """Check if a MIDI note corresponds to a black key"""
        note_in_octave = midi_note % 12
        return note_in_octave in [1, 3, 6, 8, 10]  # C#, D#, F#, G#, A#

    def create_static_visualization(self, output_file='piano_viz.png', dpi=150):
        """Create a static piano roll visualization"""
        fig, (ax1, ax2) = plt.subplots(2, 1, figsize=(16, 10),
                                        gridspec_kw={'height_ratios': [4, 1]})

        fig.patch.set_facecolor(self.config['background_color'])
        ax1.set_facecolor(self.config['background_color'])
        ax2.set_facecolor(self.config['piano_color'])

        # Main piano roll
        ax1.set_xlim(0, self.duration)
        ax1.set_ylim(self.start_note - 0.5, self.end_note + 0.5)
        ax1.set_xlabel('Time (seconds)', color='white', fontsize=12)
        ax1.set_ylabel('MIDI Note', color='white', fontsize=12)
        ax1.tick_params(colors='white')
        ax1.grid(True, alpha=self.config['grid_alpha'], color=self.config['grid_color'])

        # Draw notes
        colors = self.config['note_colors']
        for note in self.notes:
            color = colors[note['pitch'] % len(colors)]
            alpha = 0.6 + (note['velocity'] / 127) * 0.4

            rect = Rectangle(
                (note['start'], note['pitch'] - 0.4),
                note['duration'],
                0.8,
                facecolor=color,
                edgecolor=color,
                alpha=alpha,
                linewidth=1
            )
            ax1.add_patch(rect)

        # Draw piano keyboard
        ax2.set_xlim(self.start_note - 0.5, self.end_note + 0.5)
        ax2.set_ylim(0, 1)
        ax2.set_aspect('auto')
        ax2.axis('off')

        for note in range(self.start_note, self.end_note + 1):
            is_black = self.is_black_key(note)
            color = self.config['black_key_color'] if is_black else self.config['white_key_color']
            height = 0.6 if is_black else 1.0
            y_pos = 0.4 if is_black else 0

            rect = Rectangle(
                (note - 0.45, y_pos),
                0.9,
                height,
                facecolor=color,
                edgecolor='#333333',
                linewidth=0.5
            )
            ax2.add_patch(rect)

        plt.tight_layout()
        plt.savefig(output_file, dpi=dpi, facecolor=self.config['background_color'])
        print(f"Saved visualization to: {output_file}")
        plt.close()

    def create_animated_visualization(self, output_file='piano_animation.mp4',
                                     fps=30, window_size=10):
        """Create an animated falling-notes style visualization"""
        print("Creating animated visualization...")
        
        # Check if FFmpeg is available
        ffmpeg_available = shutil.which('ffmpeg') is not None
        
        # Check if matplotlib can use FFmpeg writer
        try:
            animation.writers.list()
            ffmpeg_writer_available = 'ffmpeg' in animation.writers.list()
        except:
            ffmpeg_writer_available = False
        
        if not ffmpeg_available or not ffmpeg_writer_available:
            print("\n❌ Error: FFmpeg is required for animated visualizations")
            print("\nTo install FFmpeg:")
            print("  macOS:    brew install ffmpeg")
            print("  Ubuntu:   sudo apt install ffmpeg")
            print("  Windows:  Download from https://ffmpeg.org/download.html")
            print("\nAfter installing FFmpeg, restart Python and try again.")
            raise RuntimeError("FFmpeg not available. Please install FFmpeg to create animated visualizations.")

        fig, (ax1, ax2) = plt.subplots(2, 1, figsize=(16, 9),
                                        gridspec_kw={'height_ratios': [5, 1]})

        fig.patch.set_facecolor(self.config['background_color'])
        ax1.set_facecolor(self.config['background_color'])
        ax2.set_facecolor(self.config['piano_color'])

        # Setup axes
        ax1.set_xlim(self.start_note - 0.5, self.end_note + 0.5)
        ax1.set_ylim(0, 100)
        ax1.set_xlabel('Piano Keys', color='white', fontsize=12)
        ax1.set_ylabel('Time', color='white', fontsize=12)
        ax1.tick_params(colors='white')
        ax1.grid(True, alpha=self.config['grid_alpha'], color=self.config['grid_color'])
        ax1.invert_yaxis()  # Notes fall from top

        # Piano keyboard
        ax2.set_xlim(self.start_note - 0.5, self.end_note + 0.5)
        ax2.set_ylim(0, 1)
        ax2.axis('off')

        # Draw keyboard
        key_patches = {}
        for note in range(self.start_note, self.end_note + 1):
            is_black = self.is_black_key(note)
            color = self.config['black_key_color'] if is_black else self.config['white_key_color']
            height = 0.6 if is_black else 1.0
            y_pos = 0.4 if is_black else 0

            rect = Rectangle(
                (note - 0.45, y_pos),
                0.9,
                height,
                facecolor=color,
                edgecolor='#333333',
                linewidth=0.5
            )
            ax2.add_patch(rect)
            key_patches[note] = rect

        # Animation function
        note_patches = []
        colors = self.config['note_colors']

        def animate(frame):
            current_time = frame / fps

            # Clear previous note patches
            for patch in note_patches:
                patch.remove()
            note_patches.clear()

            # Reset key colors
            for note, patch in key_patches.items():
                is_black = self.is_black_key(note)
                color = self.config['black_key_color'] if is_black else self.config['white_key_color']
                patch.set_facecolor(color)

            # Draw notes in current window
            window_start = current_time
            window_end = current_time + window_size

            active_notes = set()

            for note in self.notes:
                # Check if note is in time window
                if note['start'] >= window_start and note['start'] <= window_end:
                    # Calculate y position (distance from current time)
                    y_pos = (note['start'] - current_time) / window_size * 100
                    height = min((note['duration'] / window_size * 100), 20)

                    color = colors[note['pitch'] % len(colors)]
                    alpha = 0.6 + (note['velocity'] / 127) * 0.4

                    rect = Rectangle(
                        (note['pitch'] - 0.4, y_pos),
                        0.8,
                        height,
                        facecolor=color,
                        edgecolor=color,
                        alpha=alpha,
                        linewidth=1
                    )
                    ax1.add_patch(rect)
                    note_patches.append(rect)

                # Check if note is currently playing
                if note['start'] <= current_time <= note['end']:
                    active_notes.add(note['pitch'])

            # Highlight active keys
            for note in active_notes:
                if note in key_patches:
                    key_patches[note].set_facecolor(self.config['active_key_color'])

            # Update title with current time
            ax1.set_title(f'Time: {current_time:.2f}s / {self.duration:.2f}s',
                         color='white', fontsize=14, pad=20)

            return note_patches

        # Create animation
        num_frames = int(self.duration * fps)
        anim = animation.FuncAnimation(fig, animate, frames=num_frames,
                                      interval=1000/fps, blit=False)

        # Save animation
        try:
            Writer = animation.writers['ffmpeg']
            writer = Writer(fps=fps, bitrate=5000)
        except RuntimeError as e:
            print("\n❌ Error: Could not initialize FFmpeg writer")
            print(f"   Details: {e}")
            print("\nPlease ensure FFmpeg is installed and accessible in your PATH.")
            raise

        print(f"Rendering {num_frames} frames at {fps} FPS...")
        anim.save(output_file, writer=writer, dpi=100)
        print(f"Saved animation to: {output_file}")

        plt.close()


def main():
    parser = argparse.ArgumentParser(
        description='Create beautiful piano visualizations from MIDI files'
    )
    parser.add_argument('midi_file', help='Path to MIDI file')
    parser.add_argument('-o', '--output', default='output',
                       help='Output file name (without extension)')
    parser.add_argument('-t', '--type', choices=['static', 'animated', 'both'],
                       default='both', help='Type of visualization to create')
    parser.add_argument('-c', '--config', help='Path to JSON config file for colors')
    parser.add_argument('--fps', type=int, default=30,
                       help='Frames per second for animation (default: 30)')
    parser.add_argument('--dpi', type=int, default=150,
                       help='DPI for static image (default: 150)')
    parser.add_argument('--window', type=float, default=10,
                       help='Time window for animated view in seconds (default: 10)')

    args = parser.parse_args()

    # Create visualizer
    viz = PianoVisualizer(args.midi_file, args.config)

    # Generate visualizations
    if args.type in ['static', 'both']:
        viz.create_static_visualization(f'{args.output}_static.png', dpi=args.dpi)

    if args.type in ['animated', 'both']:
        viz.create_animated_visualization(
            f'{args.output}_animated.mp4',
            fps=args.fps,
            window_size=args.window
        )

    print("\nDone! ✨")


if __name__ == '__main__':
    main()
