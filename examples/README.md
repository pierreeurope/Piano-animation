# Example MIDI Files

This directory is for example MIDI files to test the visualizer.

You can find free MIDI files at:
- [BitMidi](https://bitmidi.com/) - Large collection of free MIDI files
- [Classical Archives](https://www.classicalarchives.com/)
- [MuseScore](https://musescore.com/) - Download and export as MIDI

## Quick Test

1. Download any MIDI file
2. Place it in this directory
3. Run the web visualizer: `npm run dev`
4. Drag and drop the MIDI file

Or use the Python visualizer:
```bash
python python/visualizer.py examples/your-file.mid
```

## Converting Your Own Music

If you have an MP3 or audio file:

```bash
# Convert MP3 to MIDI
python python/mp3_to_midi.py your-song.mp3

# Then visualize it
python python/visualizer.py your-song_basic_pitch.mid
```
