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
// PREMIUM TRANSLUCENT GLASS NOTE RENDERING
// ============================================================

@fragment
fn fs_main(in: VertexOutput) -> @location(0) vec4<f32> {
    // ===== CLIP AT KEYBOARD =====
    if in.world_y >= in.keyboard_y - 2.0 {
        discard;
    }

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
    
    // ===== GLASS BASE COLOR =====
    // Start with the note color, slightly darkened for depth
    var glass_color = in.color * 0.7;
    
    // ===== GLOSSY TOP HIGHLIGHT =====
    // Sharp white reflection at top like light on glass
    let top_highlight = exp(-uv.y * uv.y * 80.0) * 0.9;
    glass_color = glass_color + vec3<f32>(top_highlight);
    
    // ===== SOFT TOP GRADIENT =====
    // Broader highlight gradient
    let top_gradient = (1.0 - uv.y) * 0.25;
    glass_color = glass_color + vec3<f32>(top_gradient * 0.5);
    
    // ===== LEFT EDGE REFLECTION =====
    // Glass catches light on edges
    let left_edge = exp(-uv.x * uv.x * 150.0) * 0.4;
    glass_color = glass_color + vec3<f32>(left_edge);
    
    // ===== RIGHT EDGE SUBTLE HIGHLIGHT =====
    let right_x = 1.0 - uv.x;
    let right_edge = exp(-right_x * right_x * 200.0) * 0.2;
    glass_color = glass_color + vec3<f32>(right_edge);
    
    // ===== INTERNAL LUMINOSITY =====
    // Glass has internal glow - brighter toward center
    let center_x = abs(uv.x - 0.5);
    let center_glow = (1.0 - center_x * 2.0) * 0.2;
    glass_color = glass_color + in.color * max(center_glow, 0.0);
    
    // ===== DEPTH GRADIENT =====
    // Subtle darkening toward bottom for 3D effect
    let depth = uv.y * 0.15;
    glass_color = glass_color - vec3<f32>(depth * 0.3);
    
    // ===== BOTTOM GLOW (approaching keyboard) =====
    // Notes glow brighter as they approach the play line
    let bottom_proximity = smoothstep(0.6, 1.0, uv.y);
    let bottom_glow = bottom_proximity * 0.35;
    glass_color = glass_color + in.color * bottom_glow;
    
    // ===== SUBTLE INNER SHADOW =====
    // Creates depth perception
    let edge_x = min(uv.x, 1.0 - uv.x);
    let edge_y = min(uv.y, 1.0 - uv.y);
    let inner_shadow = smoothstep(0.0, 0.1, min(edge_x, edge_y));
    glass_color = glass_color * (0.85 + inner_shadow * 0.15);
    
    // ===== THIN BRIGHT BORDER =====
    // Glass has a bright edge where light refracts
    let border_dist = min(min(uv.x, 1.0 - uv.x), min(uv.y, 1.0 - uv.y));
    let border = smoothstep(0.03, 0.0, border_dist) * 0.5;
    glass_color = glass_color + vec3<f32>(border * 0.4) + in.color * border * 0.3;
    
    // ===== TRANSLUCENT ALPHA =====
    // Glass is slightly transparent
    let translucency = 0.92;
    
    // Clamp colors
    glass_color = clamp(glass_color, vec3<f32>(0.0), vec3<f32>(1.2));

    return vec4<f32>(glass_color, base_alpha * translucency);
}
