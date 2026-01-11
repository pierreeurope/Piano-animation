#!/usr/bin/env python3
"""
MP3 to MIDI Converter
Uses Spotify's Basic Pitch for automatic music transcription
"""

import argparse
from pathlib import Path
import sys

try:
    from basic_pitch.inference import predict_and_save
    from basic_pitch import ICASSP_2022_MODEL_PATH
except ImportError:
    print("Error: basic-pitch not installed.")
    print("Install with: pip install basic-pitch")
    sys.exit(1)


def convert_audio_to_midi(audio_file, output_dir=None, model_path=ICASSP_2022_MODEL_PATH):
    """
    Convert audio file (MP3, WAV, etc.) to MIDI using Basic Pitch

    Args:
        audio_file: Path to input audio file
        output_dir: Directory to save output files (default: same as input)
        model_path: Path to Basic Pitch model
    """
    audio_path = Path(audio_file)

    if not audio_path.exists():
        print(f"Error: Audio file not found: {audio_file}")
        sys.exit(1)

    if output_dir is None:
        output_dir = audio_path.parent
    else:
        output_dir = Path(output_dir)
        output_dir.mkdir(parents=True, exist_ok=True)

    print(f"Converting {audio_path.name} to MIDI...")
    print("This may take a few minutes depending on file length...")

    try:
        # Run Basic Pitch prediction
        predict_and_save(
            [str(audio_path)],
            str(output_dir),
            save_midi=True,
            sonify_midi=False,
            save_model_outputs=False,
            save_notes=False,
            model_or_model_path=model_path
        )

        # Find the generated MIDI file
        midi_file = output_dir / f"{audio_path.stem}_basic_pitch.mid"

        if midi_file.exists():
            print(f"\n✅ Success! MIDI file created: {midi_file}")
            print(f"\nYou can now use this MIDI file with the visualizer:")
            print(f"  Web: Open http://localhost:5173 and drag the MIDI file")
            print(f"  Python: python python/visualizer.py {midi_file}")
            return str(midi_file)
        else:
            print(f"\n⚠️  Expected MIDI file not found: {midi_file}")
            print("Conversion may have failed. Check the output directory.")
            return None

    except Exception as e:
        print(f"\n❌ Error during conversion: {e}")
        sys.exit(1)


def main():
    parser = argparse.ArgumentParser(
        description='Convert audio files to MIDI using AI transcription'
    )
    parser.add_argument('audio_file', help='Path to audio file (MP3, WAV, etc.)')
    parser.add_argument('-o', '--output-dir',
                       help='Output directory for MIDI file (default: same as input)')
    parser.add_argument('--visualize', action='store_true',
                       help='Automatically create visualization after conversion')

    args = parser.parse_args()

    # Convert audio to MIDI
    midi_file = convert_audio_to_midi(args.audio_file, args.output_dir)

    # Optionally create visualization
    if args.visualize and midi_file:
        print("\nCreating visualization...")
        try:
            from visualizer import PianoVisualizer

            viz = PianoVisualizer(midi_file)
            output_name = Path(midi_file).stem

            viz.create_static_visualization(f'{output_name}_viz.png')
            print(f"\n✅ Visualization created: {output_name}_viz.png")

        except ImportError as e:
            print(f"\n⚠️  Could not create visualization: {e}")
            print("Make sure required packages are installed:")
            print("  pip install pretty-midi matplotlib numpy")


if __name__ == '__main__':
    main()
