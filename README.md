# 🎹 Piano Visualizer

A premium MIDI piano visualizer that creates stunning videos with professional-quality effects, similar to popular YouTube piano channels.

![Inferno Theme](video_outputs/screenshot_inferno_v2.png)

## ✨ Features

- **Premium Visual Effects**: Horizontal scanline texture on notes, golden play line, circular glow effects
- **Golden Particle System**: 120+ floating sparks with organic movement
- **Clean Design**: Pure black background, no grid lines
- **Multiple Themes**: Inferno (golden/amber), Neon, and more
- **High Quality Output**: 1080p/4K video rendering with audio

## 🚀 Quick Start

### Prerequisites

1. **Rust** (install via [rustup](https://rustup.rs/))
   ```bash
   curl --proto '=https' --tlsv1.2 -sSf https://sh.rustup.rs | sh
   ```

2. **FFmpeg** (for video encoding)
   ```bash
   # macOS
   brew install ffmpeg
   
   # Ubuntu/Debian
   sudo apt install ffmpeg
   ```

### Build

```bash
cd neothesia-custom
cargo build --release -p neothesia-cli
```

### Render a Video

```bash
cd neothesia-custom

# Basic usage (with inferno theme)
NEOTHESIA_THEME=inferno ./target/release/neothesia-cli your_midi.mid output.mp4 --soundfont default.sf2

# Full HD with custom resolution
NEOTHESIA_THEME=inferno ./target/release/neothesia-cli your_midi.mid output.mp4 --soundfont default.sf2 --width 1920 --height 1080

# 4K rendering
NEOTHESIA_THEME=inferno ./target/release/neothesia-cli your_midi.mid output.mp4 --soundfont default.sf2 --width 3840 --height 2160
```

### Available Themes

| Theme | Description |
|-------|-------------|
| `inferno` | Golden/amber fire colors (recommended) |
| `neon` | Cyan/magenta cyberpunk style |
| `golden` | Elegant gold tones |

Set theme via environment variable: `NEOTHESIA_THEME=inferno`

## 🎨 Customization

### Adding New Themes

Edit `neothesia-custom/neothesia-core/src/config/model.rs` and add a new color schema function:

```rust
fn my_theme_color_schema() -> Vec<ColorSchemaV1> {
    vec![
        ColorSchemaV1 {
            base: (R, G, B),   // Base color for white keys
            dark: (R, G, B),   // Color for black keys
        },
        // Add more color variations...
    ]
}
```

### Shader Files

- **Notes**: `neothesia-core/src/render/waterfall/pipeline/shader.wgsl`
- **Background**: `neothesia-core/src/render/background_animation/shader.wgsl`
- **Glow**: `neothesia-core/src/render/glow/shader.wgsl`

## 📁 Project Structure

```
Piano-animation/
├── neothesia-custom/       # Main visualizer (Rust/wgpu)
│   ├── neothesia-cli/      # Command-line renderer
│   ├── neothesia-core/     # Core rendering engine
│   └── default.sf2         # Default SoundFont
├── python/                 # MIDI utilities (deprecated)
├── src/                    # Three.js version (deprecated)
└── video_outputs/          # Generated videos (gitignored)
```

## 🔧 Troubleshooting

### No sound in output
Make sure to include `--soundfont default.sf2` in your command.

### Build errors
Ensure Rust is installed: `rustc --version`

### Performance issues
- Use `--width 1920 --height 1080` for balanced quality/speed
- 4K rendering is slower but produces sharper output

---

## 📜 Deprecated: Legacy Versions

### Python Visualizer (Deprecated)

```bash
cd python
python3 -m venv venv
source venv/bin/activate
pip install -r requirements.txt
python visualizer.py your_midi.mid
```

### Three.js Web Version (Deprecated)

```bash
npm install
npm run dev
# Open http://localhost:5173
```

---

## 📄 License

Based on [Neothesia](https://github.com/PolyMeilex/Neothesia) (GPL-3.0).
