# Piano Animation - Beautiful Piano Visualizations

Create stunning piano visualization videos from MIDI or MP3 files with customizable colors and effects.

## Features

- **Multiple Visualization Engines**:
  - Three.js WebGL 3D visualizer (high quality, web-based)
  - Python-based visualizer (for video rendering)

- **Input Support**:
  - MIDI files (direct input)
  - MP3 files (automatic transcription to MIDI)

- **Customization**:
  - Color schemes
  - Particle effects
  - Lighting effects
  - Camera angles
  - Volume control

- **Audio Playback**:
  - Real-time piano sound synthesis
  - Synchronized with visualization
  - Adjustable volume

## Quick Start

### 1. Install Dependencies

**Web Visualizer (Required):**
```bash
npm install
```

**Python Features (Optional - for MP3 conversion and video rendering):**
```bash
# Install all Python dependencies at once
pip install -r python/requirements.txt

# Or install individually:
pip install pretty-midi matplotlib numpy basic-pitch
```

**Note:** Python features are optional. The web visualizer works perfectly with just `npm install`.

### 2. Run the Web Visualizer

```bash
npm run dev
```

Open your browser to `http://localhost:5173`

### 3. Use It

1. Drag and drop a MIDI file into the browser
2. Press Play to start (audio will begin after first user interaction)
3. Enjoy the beautiful visualization with synchronized audio
4. Customize colors, effects, and volume in the control panel
5. Record with screen capture for videos

## Project Structure

```
piano-animation/
├── index.html              # Main web interface
├── src/
│   ├── main.js            # Application entry point
│   ├── piano.js           # 3D piano keyboard
│   ├── notes.js           # Falling notes system
│   ├── effects.js         # Particle effects & lighting
│   └── midi-parser.js     # MIDI file handling
├── python/
│   ├── visualizer.py      # Python-based visualizer
│   └── mp3_to_midi.py     # MP3 to MIDI converter
└── public/
    └── fonts/             # Web fonts for UI
```

## Technologies Used

- **Three.js** - 3D graphics rendering
- **Tone.js** - MIDI parsing and audio playback
- **Spotify Basic Pitch** - MP3 to MIDI transcription
- **Vite** - Fast development server
- **Python + Matplotlib** - Alternative rendering engine

## What's Included

✅ **Fully Functional Features**:
- Web-based 3D visualizer with real-time controls
- **Real-time audio playback** with piano sound synthesis
- Python video renderer for YouTube-quality exports
- MP3 to MIDI conversion using AI (Spotify Basic Pitch)
- Customizable colors, effects, camera angles, and volume
- Particle effects and dynamic lighting
- Multiple visualization styles
- Comprehensive documentation

## Documentation

- **[GET_STARTED.md](GET_STARTED.md)** - Start here! 2-minute quick start
- **[USAGE_GUIDE.md](USAGE_GUIDE.md)** - Complete usage guide with examples
- **[PROJECT_SUMMARY.md](PROJECT_SUMMARY.md)** - Technical details and architecture

## Examples

### Convert MP3 to visualization:
```bash
python python/mp3_to_midi.py your-song.mp3
npm run dev  # Then drag the generated MIDI file
```

### Create a YouTube video:
```bash
python python/visualizer.py song.mid -o output -t animated --fps 60
```

### Generate test MIDI file:
```bash
python python/generate_test_midi.py
```

## Tips

- Get free MIDI files from [BitMidi](https://bitmidi.com/)
- Best MP3 conversion results with piano-only recordings
- Use the web visualizer for experimentation
- Use the Python visualizer for final video exports
- Customize colors in `python/config.json` for consistent branding

## Screenshots & Demo

The web visualizer features:
- 88-key 3D piano with realistic lighting
- **Real-time audio playback** synchronized with visuals
- Falling notes (Guitar Hero style)
- Particle effects on key presses
- Dynamic spotlights that follow the music
- Real-time color customization
- Volume control
- Multiple camera presets

## License

MIT
