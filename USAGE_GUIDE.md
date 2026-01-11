# 🎹 Piano Animation - Complete Usage Guide

## Overview

This project provides **two beautiful piano visualization systems**:

1. **Web Visualizer** (Three.js) - Interactive 3D browser-based visualizer
2. **Python Visualizer** - High-quality video rendering for YouTube-style videos

Both support **MIDI files directly** and **MP3 files** (via automatic transcription).

---

## 🚀 Quick Start

### Installation

```bash
# Install Node.js dependencies
npm install

# Install Python dependencies (optional, for MP3 support and video rendering)
pip install -r python/requirements.txt
```

### Method 1: Web Visualizer (Easiest & Most Interactive)

```bash
# Start the web server
npm run dev
```

This will open your browser to `http://localhost:5173`

**How to use:**
1. Drag and drop a MIDI file into the browser
2. Watch the beautiful 3D visualization
3. Customize colors, effects, camera angles in real-time
4. Control playback with play/pause/restart buttons

**Features:**
- ✨ Real-time 3D graphics with WebGL
- 🎨 Live color customization
- 🌟 Particle effects
- 💡 Dynamic lighting
- 📷 Multiple camera presets
- 🎮 Interactive controls

### Method 2: Python Visualizer (Best for Video Export)

```bash
# Create a static piano roll image
python python/visualizer.py your-file.mid -o output -t static

# Create an animated video (MP4)
python python/visualizer.py your-file.mid -o output -t animated

# Create both
python python/visualizer.py your-file.mid -o output -t both
```

**Advanced options:**
```bash
# High quality animation
python python/visualizer.py song.mid -o output --fps 60 --dpi 300

# Custom colors
python python/visualizer.py song.mid -c python/config.json

# Adjust time window (how much of the piece shows at once)
python python/visualizer.py song.mid --window 15
```

---

## 🎵 Working with MP3 Files

### Convert MP3 to MIDI

```bash
python python/mp3_to_midi.py your-song.mp3
```

This uses **Spotify's Basic Pitch** AI model to transcribe audio to MIDI.

**With automatic visualization:**
```bash
python python/mp3_to_midi.py your-song.mp3 --visualize
```

**Then use the MIDI file:**
- Web: Drag the generated `*_basic_pitch.mid` file into the browser
- Python: Run the visualizer on the generated MIDI file

**Tips for best results:**
- Use clear piano recordings (less background noise)
- Solo piano works best
- Higher quality audio = better transcription

---

## 🎨 Customizing Colors

### Web Visualizer

Colors can be customized **in real-time** using the control panel on the right side:

- **Background Color** - Scene background
- **Piano Color** - Piano body color
- **White Keys** - White key color
- **Black Keys** - Black key color
- **Active Key Glow** - Color when keys are pressed
- **Note Color** - Falling notes color

### Python Visualizer

Edit `python/config.json`:

```json
{
  "background_color": "#1a1a2e",
  "piano_color": "#2a2a3e",
  "white_key_color": "#ffffff",
  "black_key_color": "#1a1a1a",
  "note_colors": [
    "#667eea",
    "#764ba2",
    "#f093fb",
    "#4facfe"
  ],
  "active_key_color": "#00ff88",
  "grid_color": "#ffffff",
  "grid_alpha": 0.1
}
```

Then use it:
```bash
python python/visualizer.py song.mid -c python/config.json
```

---

## 🎬 Creating YouTube Videos

### Option 1: Screen Recording (Easiest)

1. Start web visualizer: `npm run dev`
2. Load your MIDI file
3. Use screen recording software:
   - **Mac**: QuickTime Player or Cmd+Shift+5
   - **Windows**: Xbox Game Bar (Win+G)
   - **Any OS**: OBS Studio (free)
4. Record the visualization

**Pros:** Real-time, interactive, easy
**Cons:** Limited to screen resolution

### Option 2: Python Video Export (Best Quality)

```bash
# Create high-quality video
python python/visualizer.py song.mid -o output -t animated --fps 60
```

This creates an MP4 file you can upload directly to YouTube.

**Pros:** High quality, consistent, automated
**Cons:** Takes time to render

### Option 3: Frame Export + FFmpeg (Maximum Control)

For the web visualizer, you can add frame export functionality (requires modification) or use a tool like:

```bash
# Record browser with headless Chrome (advanced)
# Coming in future update
```

---

## 📝 Examples

### Example 1: Simple Web Visualization

```bash
npm run dev
# Drag your-song.mid into browser
# Adjust colors and effects
# Hit record on your screen recorder
```

### Example 2: Convert MP3 and Create Video

```bash
# Step 1: Convert MP3 to MIDI
python python/mp3_to_midi.py piano-song.mp3

# Step 2: Create video
python python/visualizer.py piano-song_basic_pitch.mid -o final --fps 60

# Result: final_animated.mp4
```

### Example 3: Batch Process Multiple Files

```bash
# Bash script to process all MIDI files
for file in examples/*.mid; do
    python python/visualizer.py "$file" -o "output/$(basename "$file" .mid)"
done
```

---

## ⚙️ Advanced Configuration

### Web Visualizer Settings

Edit settings in [src/main.js](src/main.js):

```javascript
this.config = {
    bgColor: 0x1a1a2e,
    noteSpeed: 1.0,
    particlesEnabled: true,
    glowIntensity: 1.0,
    // ... more settings
};
```

### Camera Presets

- **Front View** - Classic view from the front
- **Top View** - Bird's eye view
- **Side View** - View from the side
- **Dynamic** - Camera follows the music

### Effects Control

- **Particles**: Toggle on/off, creates sparkles on key presses
- **Glow Intensity**: 0-2, controls brightness of effects
- **Note Speed**: 0.5-2x, speed up or slow down playback

---

## 🐛 Troubleshooting

### Web Visualizer Issues

**Problem:** Black screen
- Check browser console (F12) for errors
- Make sure WebGL is supported in your browser
- Try a different browser (Chrome/Firefox recommended)

**Problem:** Performance issues
- Lower the glow intensity
- Disable particles
- Close other browser tabs

### Python Issues

**Problem:** "No module named 'basic_pitch'"
```bash
pip install basic-pitch
```

**Problem:** "No module named 'pretty_midi'"
```bash
pip install pretty-midi
```

**Problem:** FFmpeg not found
```bash
# Mac
brew install ffmpeg

# Ubuntu/Debian
sudo apt install ffmpeg

# Windows
# Download from https://ffmpeg.org
```

**Problem:** MP3 conversion takes too long
- This is normal for AI transcription
- Try shorter files first
- Use a faster computer or wait patiently

---

## 📊 Comparison: Which Visualizer to Use?

| Feature | Web Visualizer | Python Visualizer |
|---------|---------------|-------------------|
| Ease of use | ⭐⭐⭐⭐⭐ | ⭐⭐⭐ |
| Visual quality | ⭐⭐⭐⭐ | ⭐⭐⭐⭐ |
| Customization | ⭐⭐⭐⭐⭐ | ⭐⭐⭐ |
| Video export | ⭐⭐ (via recording) | ⭐⭐⭐⭐⭐ |
| Real-time | ✅ Yes | ❌ No |
| 3D effects | ✅ Yes | ❌ 2D only |
| Batch processing | ❌ No | ✅ Yes |

**Recommendation:**
- **For fun/experimentation**: Use web visualizer
- **For YouTube videos**: Use Python visualizer
- **For live performances**: Use web visualizer with screen capture

---

## 🎯 Tips for Beautiful Visualizations

1. **Choose complementary colors**: Use a color picker to find colors that work well together
2. **Match the mood**: Dark colors for classical, bright colors for upbeat pieces
3. **Use high-quality MIDI**: Better MIDI files = better visualizations
4. **Adjust camera angle**: Different pieces work better with different angles
5. **Enable particles sparingly**: Too many can be distracting
6. **Export at high resolution**: 1080p minimum for YouTube

---

## 🔮 Future Features

- Direct video export from web visualizer
- PDF sheet music recognition
- Multiple instrument colors
- Advanced particle systems
- Lyrics/text overlay
- Audio waveform visualization
- Preset themes (classical, modern, neon, etc.)

---

## 🤝 Need Help?

If you encounter issues:
1. Check this guide
2. Look at the examples in `examples/`
3. Check the code comments
4. Experiment with different settings

Happy visualizing! 🎹✨
