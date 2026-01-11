struct ViewUniform {
    transform: mat4x4<f32>,
    size: vec2<f32>,
    scale: f32,
}

struct TimeUniform {
    time: f32,
    speed: f32,
}

@group(0) @binding(0)
var<uniform> view_uniform: ViewUniform;

@group(1) @binding(0)
var<uniform> time_uniform: TimeUniform;

struct Vertex {
    @location(0) position: vec2<f32>,
}

struct NoteInstance {
    @location(1) n_position: vec2<f32>,
    @location(2) size: vec2<f32>,
    @location(3) color: vec3<f32>,
    @location(4) radius: f32,
}

struct VertexOutput {
    @builtin(position) position: vec4<f32>,
    @location(0) src_position: vec2<f32>,
    @location(1) size: vec2<f32>,
    @location(2) color: vec3<f32>,
    @location(3) radius: f32,
    @location(4) note_pos: vec2<f32>,
    @location(5) world_y: f32,
    @location(6) keyboard_y: f32,
}

@vertex
fn vs_main(vertex: Vertex, note: NoteInstance) -> VertexOutput {
    let speed = time_uniform.speed;
    let size = vec2<f32>(note.size.x, note.size.y * abs(speed)) * view_uniform.scale;

    let keyboard_h = view_uniform.size.y / 5.0;
    let keyboard_y = view_uniform.size.y - keyboard_h;

    var pos = vec2<f32>(note.n_position.x * view_uniform.scale, keyboard_y);

    if speed > 0.0 {
        pos.y -= size.y;
    }

    pos.y -= (note.n_position.y - time_uniform.time) * speed;

    let transform = mat4x4<f32>(
        vec4<f32>(size.x, 0.0,    0.0, 0.0),
        vec4<f32>(0.0,    size.y, 0.0, 0.0),
        vec4<f32>(0.0,    0.0,    1.0, 0.0),
        vec4<f32>(pos.x,  pos.y,  0.0, 1.0)
    );

    var out: VertexOutput;
    out.position = view_uniform.transform * transform * vec4<f32>(vertex.position, 0.0, 1.0);
    out.note_pos = pos;
    out.src_position = vertex.position;
    out.size = size;
    out.color = note.color;
    out.radius = note.radius * view_uniform.scale;
    out.world_y = pos.y + vertex.position.y * size.y;
    out.keyboard_y = keyboard_y;

    return out;
}

fn dist(
    frag_coord: vec2<f32>,
    position: vec2<f32>,
    size: vec2<f32>,
    radius: f32,
) -> f32 {
    let inner_size: vec2<f32> = size - vec2<f32>(radius, radius) * 2.0;
    let top_left: vec2<f32> = position + vec2<f32>(radius, radius);
    let bottom_right: vec2<f32> = top_left + inner_size;

    let top_left_distance: vec2<f32> = top_left - frag_coord;
    let bottom_right_distance: vec2<f32> = frag_coord - bottom_right;

    let d: vec2<f32> = vec2<f32>(
        max(max(top_left_distance.x, bottom_right_distance.x), 0.0),
        max(max(top_left_distance.y, bottom_right_distance.y), 0.0),
    );

    return sqrt(d.x * d.x + d.y * d.y);
}

// ============================================================
// PREMIUM NOTE RENDERING - CLIPPED AT PLAY LINE
// ============================================================

@fragment
fn fs_main(in: VertexOutput) -> @location(0) vec4<f32> {
    // ===== HARD CLIP NOTES AT KEYBOARD (play line) =====
    // Anything at or below keyboard line gets discarded
    if in.world_y >= in.keyboard_y - 2.0 {
        discard;
    }
    
    // No fade - hard clip
    let keyboard_fade = 1.0;

    let dist_val: f32 = dist(
        in.position.xy,
        in.note_pos,
        in.size,
        in.radius,
    );

    let base_alpha: f32 = 1.0 - smoothstep(
        max(in.radius - 0.5, 0.0),
        in.radius + 0.5,
        dist_val,
    );
    
    let uv = in.src_position;
    
    // ===== HORIZONTAL SCANLINE TEXTURE =====
    let stripe_freq = 35.0;
    let stripe_y = uv.y * stripe_freq;
    let stripe_raw = fract(stripe_y);
    let stripe = smoothstep(0.25, 0.45, stripe_raw) * smoothstep(0.75, 0.55, stripe_raw);
    let stripe_intensity = 0.35 + stripe * 0.65;
    
    // ===== BASE COLOR with stripe modulation =====
    var note_color = in.color * stripe_intensity;
    
    // ===== TOP BRIGHT EDGE =====
    let top_edge = smoothstep(0.1, 0.0, uv.y) * 0.8;
    note_color = note_color + vec3<f32>(top_edge);
    
    // ===== LEFT/RIGHT EDGE HIGHLIGHTS =====
    let left_edge = smoothstep(0.05, 0.0, uv.x) * 0.3;
    let right_edge = smoothstep(0.95, 1.0, uv.x) * 0.15;
    note_color = note_color + vec3<f32>(left_edge + right_edge);
    
    // ===== INTERNAL GLOW - brighter center =====
    let center_dist = abs(uv.x - 0.5);
    let center_glow = (1.0 - center_dist * 1.5) * 0.2;
    note_color = note_color + in.color * max(center_glow, 0.0);
    
    // ===== BOTTOM GLOW (approaching play line) =====
    let bottom_proximity = smoothstep(0.7, 1.0, uv.y);
    let bottom_glow = bottom_proximity * 0.4;
    note_color = note_color + in.color * bottom_glow;
    
    // ===== OUTER GLOW/BLOOM EFFECT =====
    let edge_x = min(uv.x, 1.0 - uv.x);
    let edge_y = min(uv.y, 1.0 - uv.y);
    let edge_dist = min(edge_x, edge_y);
    let outer_glow = smoothstep(0.15, 0.0, edge_dist) * 0.5;
    note_color = note_color + in.color * outer_glow;
    
    // Clamp colors
    note_color = clamp(note_color, vec3<f32>(0.0), vec3<f32>(1.3));

    // Apply keyboard fade
    return vec4<f32>(note_color, base_alpha * keyboard_fade);
}
