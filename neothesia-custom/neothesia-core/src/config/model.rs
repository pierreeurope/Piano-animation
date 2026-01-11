use std::path::PathBuf;

use serde::{Deserialize, Serialize};

#[derive(Serialize, Deserialize, Default)]
#[serde(deny_unknown_fields)]
pub struct Model {
    #[serde(default)]
    pub waterfall: WaterfallConfig,
    #[serde(default)]
    pub playback: PlaybackConfig,
    #[serde(default)]
    pub history: History,
    #[serde(default)]
    pub synth: SynthConfig,
    #[serde(default)]
    pub keyboard_layout: LayoutConfig,
    #[serde(default)]
    pub devices: DevicesConfig,
    #[serde(default)]
    pub appearance: AppearanceConfig,
}

#[derive(Serialize, Deserialize, Clone)]
pub struct WaterfallConfigV1 {
    #[serde(default = "default_animation_speed")]
    pub animation_speed: f32,

    #[serde(default = "default_animation_offset")]
    pub animation_offset: f32,

    #[serde(default = "default_note_labels")]
    pub note_labels: bool,
}

#[derive(Serialize, Deserialize)]
pub enum WaterfallConfig {
    V1(WaterfallConfigV1),
}

impl Default for WaterfallConfig {
    fn default() -> Self {
        Self::V1(WaterfallConfigV1 {
            animation_speed: default_animation_speed(),
            animation_offset: default_animation_offset(),
            note_labels: default_note_labels(),
        })
    }
}

#[derive(Serialize, Deserialize, Clone)]
pub struct PlaybackConfigV1 {
    #[serde(default = "default_speed_multiplier")]
    pub speed_multiplier: f32,
}

#[derive(Serialize, Deserialize)]
pub enum PlaybackConfig {
    V1(PlaybackConfigV1),
}

impl Default for PlaybackConfig {
    fn default() -> Self {
        Self::V1(PlaybackConfigV1 {
            speed_multiplier: default_speed_multiplier(),
        })
    }
}

#[derive(Serialize, Deserialize, Clone)]
pub struct HistoryV1 {
    pub last_opened_song: Option<PathBuf>,
}

#[derive(Serialize, Deserialize)]
pub enum History {
    V1(HistoryV1),
}

impl Default for History {
    fn default() -> Self {
        Self::V1(HistoryV1 {
            last_opened_song: None,
        })
    }
}

#[derive(Serialize, Deserialize, Clone)]
pub struct SynthConfigV1 {
    pub soundfont_path: Option<PathBuf>,
    #[serde(default = "default_audio_gain")]
    pub audio_gain: f32,
}

#[derive(Serialize, Deserialize)]
pub enum SynthConfig {
    V1(SynthConfigV1),
}

impl Default for SynthConfig {
    fn default() -> Self {
        Self::V1(SynthConfigV1 {
            soundfont_path: None,
            audio_gain: default_audio_gain(),
        })
    }
}

#[derive(Serialize, Deserialize, Clone)]
pub struct LayoutConfigV1 {
    #[serde(default = "default_piano_range")]
    pub range: (u8, u8),
}

#[derive(Serialize, Deserialize)]
pub enum LayoutConfig {
    V1(LayoutConfigV1),
}

impl Default for LayoutConfig {
    fn default() -> Self {
        Self::V1(LayoutConfigV1 {
            range: default_piano_range(),
        })
    }
}

#[derive(Serialize, Deserialize, Clone)]
pub struct DevicesConfigV1 {
    #[serde(default = "default_output")]
    pub output: Option<String>,
    pub input: Option<String>,

    #[serde(default = "default_separate_channels")]
    pub separate_channels: bool,
}

#[derive(Serialize, Deserialize)]
pub enum DevicesConfig {
    V1(DevicesConfigV1),
}

impl Default for DevicesConfig {
    fn default() -> Self {
        Self::V1(DevicesConfigV1 {
            output: default_output(),
            input: None,
            separate_channels: default_separate_channels(),
        })
    }
}

#[derive(Serialize, Deserialize, Default, Clone)]
pub struct ColorSchemaV1 {
    pub base: (u8, u8, u8),
    pub dark: (u8, u8, u8),
}

#[derive(Serialize, Deserialize, Clone)]
pub struct AppearanceConfigV1 {
    #[serde(default = "default_color_schema")]
    pub color_schema: Vec<ColorSchemaV1>,

    #[serde(default)]
    pub background_color: (u8, u8, u8),

    #[serde(default = "default_vertical_guidelines")]
    pub vertical_guidelines: bool,

    #[serde(default = "default_horizontal_guidelines")]
    pub horizontal_guidelines: bool,

    #[serde(default = "default_glow")]
    pub glow: bool,
}

#[derive(Serialize, Deserialize)]
pub enum AppearanceConfig {
    V1(AppearanceConfigV1),
}

impl Default for AppearanceConfig {
    fn default() -> Self {
        Self::V1(AppearanceConfigV1 {
            color_schema: default_color_schema(),
            background_color: Default::default(),
            vertical_guidelines: default_vertical_guidelines(),
            horizontal_guidelines: default_horizontal_guidelines(),
            glow: default_glow(),
        })
    }
}

fn default_piano_range() -> (u8, u8) {
    (21, 108)
}

fn default_speed_multiplier() -> f32 {
    1.0
}

fn default_animation_speed() -> f32 {
    400.0
}

fn default_animation_offset() -> f32 {
    0.0
}

fn default_note_labels() -> bool {
    false
}

fn default_audio_gain() -> f32 {
    0.2
}

fn default_vertical_guidelines() -> bool {
    false  // Disabled for clean look
}

fn default_horizontal_guidelines() -> bool {
    false  // Disabled for clean look
}

fn default_glow() -> bool {
    true
}

fn default_separate_channels() -> bool {
    false
}

// Theme presets - can be selected via environment variable NEOTHESIA_THEME
// Options: "default", "inferno", "neon", "golden"
fn default_color_schema() -> Vec<ColorSchemaV1> {
    let theme = std::env::var("NEOTHESIA_THEME").unwrap_or_else(|_| "default".to_string());
    
    match theme.as_str() {
        "inferno" => inferno_color_schema(),
        "neon" => neon_color_schema(),
        "golden" => golden_color_schema(),
        _ => original_color_schema(),
    }
}

// Original default colors
fn original_color_schema() -> Vec<ColorSchemaV1> {
    vec![
        ColorSchemaV1 {
            base: (210, 89, 222),
            dark: (125, 69, 134),
        },
        ColorSchemaV1 {
            base: (93, 188, 255),
            dark: (48, 124, 255),
        },
        ColorSchemaV1 {
            base: (255, 126, 51),
            dark: (192, 73, 0),
        },
        ColorSchemaV1 {
            base: (51, 255, 102),
            dark: (0, 168, 2),
        },
        ColorSchemaV1 {
            base: (255, 51, 129),
            dark: (48, 124, 255),
        },
        ColorSchemaV1 {
            base: (210, 89, 222),
            dark: (125, 69, 134),
        },
    ]
}

// 🔥 INFERNO THEME - Premium golden/amber fire colors (like SeeMusic/Piano VFX)
fn inferno_color_schema() -> Vec<ColorSchemaV1> {
    vec![
        ColorSchemaV1 {
            base: (255, 170, 50),  // Golden amber
            dark: (200, 120, 20),  // Dark gold
        },
        ColorSchemaV1 {
            base: (255, 140, 30),  // Warm orange
            dark: (200, 100, 10),  // Dark orange
        },
        ColorSchemaV1 {
            base: (255, 200, 80),  // Bright gold
            dark: (200, 150, 40),  // Muted gold
        },
        ColorSchemaV1 {
            base: (255, 120, 20),  // Deep orange
            dark: (180, 80, 10),   // Brown orange
        },
        ColorSchemaV1 {
            base: (255, 180, 60),  // Amber
            dark: (200, 130, 30),  // Dark amber
        },
        ColorSchemaV1 {
            base: (255, 220, 100), // Pale gold
            dark: (200, 160, 50),  // Antique gold
        },
    ]
}

// 💜 NEON CYBER THEME - Cyberpunk cyan/magenta
fn neon_color_schema() -> Vec<ColorSchemaV1> {
    vec![
        ColorSchemaV1 {
            base: (0, 255, 255),   // Cyan
            dark: (0, 150, 180),   // Dark cyan
        },
        ColorSchemaV1 {
            base: (255, 0, 255),   // Magenta
            dark: (180, 0, 150),   // Dark magenta
        },
        ColorSchemaV1 {
            base: (0, 255, 150),   // Mint/Teal
            dark: (0, 180, 100),   // Dark teal
        },
        ColorSchemaV1 {
            base: (255, 100, 255), // Pink
            dark: (180, 50, 180),  // Dark pink
        },
        ColorSchemaV1 {
            base: (100, 200, 255), // Light blue
            dark: (50, 120, 200),  // Blue
        },
        ColorSchemaV1 {
            base: (200, 0, 255),   // Purple
            dark: (120, 0, 180),   // Dark purple
        },
    ]
}

// ✨ GOLDEN ELEGANCE THEME - Classic gold/white
fn golden_color_schema() -> Vec<ColorSchemaV1> {
    vec![
        ColorSchemaV1 {
            base: (255, 215, 0),   // Gold
            dark: (180, 150, 0),   // Dark gold
        },
        ColorSchemaV1 {
            base: (255, 255, 220), // Cream white
            dark: (200, 180, 140), // Beige
        },
        ColorSchemaV1 {
            base: (255, 200, 100), // Light gold
            dark: (200, 140, 50),  // Bronze
        },
        ColorSchemaV1 {
            base: (255, 240, 180), // Champagne
            dark: (200, 170, 100), // Antique gold
        },
        ColorSchemaV1 {
            base: (255, 180, 50),  // Amber gold
            dark: (180, 120, 20),  // Dark amber
        },
        ColorSchemaV1 {
            base: (255, 230, 150), // Pale gold
            dark: (200, 160, 80),  // Old gold
        },
    ]
}

fn default_output() -> Option<String> {
    Some("Buildin Synth".into())
}
