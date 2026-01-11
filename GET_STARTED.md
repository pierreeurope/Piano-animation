# 🚀 Get Started in 2 Minutes

## Super Quick Start

### 1. Install Dependencies

```bash
npm install
```

### 2. Start the Visualizer

```bash
npm run dev
```

Your browser will open to `http://localhost:5173`

### 3. Get a MIDI File

Don't have a MIDI file? Download one here:
- [BitMidi](https://bitmidi.com/) - Huge free collection
- Try this popular one: [Für Elise](https://bitmidi.com/beethoven-fur-elise-mid)

### 4. Drag and Drop

Drag the MIDI file into your browser window and watch the magic happen! ✨

---

## What You'll See

- 🎹 A beautiful 3D piano keyboard
- 🎵 Notes falling from the sky (like Guitar Hero)
- ✨ Particle effects when keys are pressed
- 💡 Dynamic lighting that responds to the music
- 🎨 Real-time color controls

---

## Try These Things

1. **Change Colors**: Use the color pickers on the right
2. **Camera Angles**: Try "Dynamic" for a moving camera
3. **Effects**: Toggle particles on/off
4. **Speed**: Adjust playback speed

---

## Want to Convert MP3 Files?

First install Python dependencies:

```bash
pip install basic-pitch pretty-midi matplotlib numpy
```

Then convert any MP3:

```bash
python python/mp3_to_midi.py your-song.mp3
```

This creates a MIDI file you can visualize!

---

## Need More Help?

Read the full [USAGE_GUIDE.md](USAGE_GUIDE.md) for:
- Python visualizer (for video export)
- Advanced customization
- Troubleshooting
- Tips for YouTube videos

---

## Quick Examples

### Example 1: Simple Visualization
```bash
npm run dev
# Drag MIDI file
# Done!
```

### Example 2: Convert MP3 and Visualize
```bash
python python/mp3_to_midi.py song.mp3
npm run dev
# Drag the generated MIDI file
```

### Example 3: Create Video for YouTube
```bash
python python/visualizer.py song.mid -o output -t animated --fps 60
# Creates output_animated.mp4
```

---

## That's It!

You're ready to create beautiful piano visualizations. Have fun! 🎹🎵✨

For questions or issues, check:
- [USAGE_GUIDE.md](USAGE_GUIDE.md) - Comprehensive guide
- [README.md](README.md) - Project overview
