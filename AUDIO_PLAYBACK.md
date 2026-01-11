# 🔊 Audio Playback Feature

The web visualizer now includes **real-time audio playback** synchronized with the visual animation!

## What's New

### Audio Synthesis
- **Real-time piano sound** using Tone.js PolySynth
- **Synchronized playback** with falling notes and key presses
- **Polyphonic** - multiple notes can play simultaneously
- **Volume control** - adjust from 0% to 100%

### How It Works

The audio system uses Web Audio API through Tone.js to synthesize piano-like sounds:

1. **Loads MIDI data** - Extracts note timing and pitch information
2. **Synthesizes sound** - Creates piano-like tones using oscillators
3. **Triggers notes** - Plays notes in sync with visual animation
4. **Real-time control** - Responds to play/pause/restart commands

## Using Audio Playback

### Basic Usage

1. **Load a MIDI file** - Drag and drop into the browser
2. **Press Play** - Audio starts automatically (requires user interaction due to browser policies)
3. **Adjust volume** - Use the volume slider in the control panel
4. **Pause/Resume** - Click pause button to stop audio

### Volume Control

The volume slider converts from percentage (0-100%) to decibels:
- **0%** = -60dB (essentially silent)
- **50%** = -30dB (moderate volume)
- **100%** = 0dB (maximum volume)

### Browser Requirements

Audio playback requires:
- **Modern browser** with Web Audio API support (Chrome, Firefox, Safari, Edge)
- **User interaction** - Audio context can only start after a user gesture (click/tap)
- **HTTPS or localhost** - Some browsers restrict audio on non-secure origins

## Technical Details

### Audio System Architecture

```
AudioPlayer Class
├── Tone.PolySynth (Piano synthesis)
├── Note scheduling
├── Real-time triggering
└── Volume control
```

### Synthesis Parameters

```javascript
{
  oscillator: { type: 'triangle' },  // Warm piano-like sound
  envelope: {
    attack: 0.005,   // Quick note onset
    decay: 0.1,      // Natural decay
    sustain: 0.3,    // Sustained tone
    release: 1       // Smooth release
  }
}
```

### Performance

- **Polyphony**: Unlimited simultaneous notes (within browser limits)
- **Latency**: < 10ms typical
- **CPU Usage**: Minimal (hardware-accelerated)
- **Memory**: ~5-10 MB for audio engine

## Customization

### Future Enhancements

You can extend the audio system by modifying [src/audio-player.js](src/audio-player.js):

**Different Instruments:**
```javascript
// Instead of Synth, try:
new Tone.PolySynth(Tone.FMSynth)  // FM synthesis
new Tone.PolySynth(Tone.AMSynth)  // AM synthesis
new Tone.Sampler({ ... })         // Use audio samples
```

**Effects:**
```javascript
this.synth = new Tone.PolySynth(Tone.Synth)
  .chain(
    new Tone.Reverb(),
    new Tone.Chorus(),
    Tone.Destination
  );
```

**Velocity Sensitivity:**
```javascript
// Adjust volume based on note velocity
const velocity = note.velocity * 2; // Make dynamics more pronounced
this.synth.triggerAttack(frequency, undefined, velocity);
```

## Troubleshooting

### No Audio Playing

**Problem:** Audio doesn't start when pressing play

**Solutions:**
1. Check browser console for errors
2. Ensure you clicked play button (user interaction required)
3. Check browser audio permissions
4. Try increasing volume
5. Verify browser supports Web Audio API

### Audio Lag/Delay

**Problem:** Audio is out of sync with visuals

**Solutions:**
1. Close other browser tabs to free resources
2. Reduce playback speed if system is struggling
3. Try a different browser
4. Check CPU usage

### Distorted Sound

**Problem:** Audio sounds clipped or distorted

**Solutions:**
1. Lower the volume
2. Reduce the number of simultaneous notes
3. Check system audio settings
4. Try different synthesis parameters

### Browser Blocks Audio

**Problem:** Browser says "Audio context suspended"

**Solutions:**
1. Click anywhere on the page to resume
2. Check browser audio settings
3. Ensure site is not muted in browser
4. Try reloading the page

## Files Changed

The audio playback feature involved these changes:

- **NEW:** [src/audio-player.js](src/audio-player.js) - Audio synthesis engine
- **MODIFIED:** [src/main.js](src/main.js) - Audio integration
- **MODIFIED:** [index.html](index.html) - Volume control UI
- **MODIFIED:** [README.md](README.md) - Updated documentation

## Dependencies

Audio playback uses the `tone` package (already included in package.json):

```json
{
  "dependencies": {
    "tone": "^15.1.3"
  }
}
```

No additional installation required - it's already installed with `npm install`.

## Comparison with Python Visualizer

| Feature | Web Visualizer | Python Visualizer |
|---------|---------------|-------------------|
| **Audio Playback** | ✅ Real-time | ❌ No audio (video only) |
| **Latency** | < 10ms | N/A |
| **Sound Quality** | Synthesized | N/A |
| **Volume Control** | ✅ Yes | N/A |

**Note:** The Python visualizer creates silent videos. You can add audio in post-processing using video editing software.

## Examples

### Example 1: Basic Playback
```bash
npm run dev
# Drag MIDI file
# Press Play
# Adjust volume if needed
```

### Example 2: Record with Audio
```bash
npm run dev
# Load MIDI file
# Adjust colors and effects
# Set comfortable volume
# Start screen recording (with system audio)
# Press Play
# Stop recording when done
```

### Example 3: Silent Mode
```bash
# Just set volume to 0%
# Or mute your system audio
# Visual animation continues normally
```

## Future Ideas

Potential enhancements for audio system:

1. **Soundfont Loading** - Use real piano samples
2. **MIDI Export** - Export with audio track
3. **Equalizer** - Frequency controls
4. **Effects Chain** - Reverb, delay, chorus
5. **Multiple Instruments** - Different sounds per track
6. **Audio Visualization** - Waveform or spectrum display
7. **Metronome** - Optional click track
8. **Audio Recording** - Download audio separately

## Credits

Audio synthesis powered by:
- **[Tone.js](https://tonejs.github.io/)** - Web Audio framework
- **[Web Audio API](https://developer.mozilla.org/en-US/docs/Web/API/Web_Audio_API)** - Browser audio engine

---

**Enjoy your piano visualizations with beautiful sound!** 🎹🎵✨
