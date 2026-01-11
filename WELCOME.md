# 🎉 Welcome to Piano Animation!

Your piano visualization system is **ready to use right now**!

---

## 🚀 Quick Start (60 seconds)

### Step 1: Start the visualizer
```bash
npm run dev
```

Your browser will open automatically to `http://localhost:5173`

### Step 2: Get a MIDI file

**Don't have one?** Download a free one:
- Go to [BitMidi.com](https://bitmidi.com/)
- Search for "Beethoven Fur Elise" or any song you like
- Download the .mid file

**Or generate a test file:**
```bash
python python/generate_test_midi.py
```

### Step 3: Drag and drop

Drag the MIDI file into your browser window.

### Step 4: Enjoy!

Watch the beautiful 3D visualization with:
- Falling notes
- Glowing keys
- Particle effects
- Dynamic lighting

---

## 🎨 What You Can Do

### In the Browser:
✨ **Change colors** - Use the color pickers on the right
🎥 **Camera angles** - Try different views (Dynamic is cool!)
⚡ **Effects** - Toggle particles and adjust glow
🎵 **Playback** - Play, pause, restart, change speed

### With Python:
📹 **Create videos** - Perfect for YouTube
```bash
python python/visualizer.py your-song.mid -o output -t animated --fps 60
```

🎵 **Convert MP3** - Turn any audio into MIDI
```bash
python python/mp3_to_midi.py your-song.mp3
```

🖼️ **Static images** - Create piano roll pictures
```bash
python python/visualizer.py your-song.mid -o output -t static
```

---

## 📚 Documentation

- **[GET_STARTED.md](GET_STARTED.md)** - 2-minute quick start guide
- **[USAGE_GUIDE.md](USAGE_GUIDE.md)** - Complete guide with examples
- **[PROJECT_SUMMARY.md](PROJECT_SUMMARY.md)** - Technical details
- **[README.md](README.md)** - Project overview

---

## 💡 Tips

1. **First time?** Try the web visualizer first - it's the easiest
2. **Want videos?** Use the Python visualizer after experimenting
3. **Have MP3s?** Convert them to MIDI first
4. **Customize colors** to match your style or brand
5. **Try different camera angles** for variety

---

## 🎯 Common Use Cases

### For YouTube Creators
```bash
# Convert your MP3
python python/mp3_to_midi.py song.mp3

# Create high-quality video
python python/visualizer.py song_basic_pitch.mid -o final --fps 60

# Upload final_animated.mp4 to YouTube
```

### For Live Performance
```bash
# Start visualizer
npm run dev

# Load your MIDI file
# Project on screen
# Perform!
```

### For Practice/Study
```bash
# Start visualizer
npm run dev

# Load your practice piece
# Follow the falling notes
# Learn the timing
```

---

## 🔧 Need to Install Python Packages?

For **MP3 support**:
```bash
pip install basic-pitch
```

For **Python visualizer**:
```bash
pip install -r python/requirements.txt
```

For **video export**:
- Mac: `brew install ffmpeg`
- Ubuntu: `sudo apt install ffmpeg`
- Windows: Download from [ffmpeg.org](https://ffmpeg.org)

---

## ✨ What Makes This Special

This isn't just another MIDI visualizer. You get:

- **Two full visualization engines** (web + Python)
- **Professional quality** (YouTube-ready)
- **Real-time customization** (colors, effects, camera)
- **AI-powered** MP3 to MIDI conversion
- **Easy to use** - drag and drop
- **Well documented** - guides for everything
- **Fully functional** - everything works right now

---

## 🎹 Ready to Create?

```bash
npm run dev
```

Then drag in a MIDI file and watch the magic happen!

---

## 🙋 Questions?

- Read the [USAGE_GUIDE.md](USAGE_GUIDE.md) for detailed instructions
- Check [PROJECT_SUMMARY.md](PROJECT_SUMMARY.md) for technical details
- Experiment with the controls - everything is real-time!

---

**Have fun creating beautiful piano visualizations!** 🎵✨

Made with passion for music and code 💙
