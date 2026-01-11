struct TimeUniform {
    time: f32,
}

@group(0) @binding(0)
var<uniform> time_uniform: TimeUniform;

struct Vertex {
    @location(0) position: vec2<f32>,
}

struct VertexOutput {
    @builtin(position) position: vec4<f32>,
    @location(0) uv_position: vec2<f32>,
}

@vertex
fn vs_main(vertex: Vertex) -> VertexOutput {
    var out: VertexOutput;
    out.position = vec4<f32>(vertex.position, 0.0, 1.0);
    out.uv_position = (vertex.position + vec2<f32>(1.0, 1.0)) / 2.0;
    return out;
}

// ============================================================
// NOISE FUNCTIONS
// ============================================================

fn hash(p: vec2<f32>) -> f32 {
    return fract(sin(dot(p, vec2<f32>(127.1, 311.7))) * 43758.5453);
}

fn noise(p: vec2<f32>) -> f32 {
    let i = floor(p);
    let f = fract(p);
    let u = f * f * (3.0 - 2.0 * f);
    return mix(
        mix(hash(i), hash(i + vec2<f32>(1.0, 0.0)), u.x),
        mix(hash(i + vec2<f32>(0.0, 1.0)), hash(i + vec2<f32>(1.0, 1.0)), u.x),
        u.y
    );
}

fn fbm(p: vec2<f32>) -> f32 {
    var value = 0.0;
    var amplitude = 0.5;
    var pos = p;
    for (var i = 0; i < 4; i++) {
        value += amplitude * noise(pos);
        amplitude *= 0.5;
        pos *= 2.0;
    }
    return value;
}

// ============================================================
// PARTICLE SPARKS - Rising ember effect (sparse)
// ============================================================

fn spark(uv: vec2<f32>, time: f32, id: f32) -> f32 {
    let h1 = hash(vec2<f32>(id, id * 1.3));
    let h2 = hash(vec2<f32>(id * 2.1, id));
    
    // Lifecycle
    let lifecycle = fract(time * (0.06 + h1 * 0.04) + h2);
    
    // Start from play line (y=0.20) and rise UP (y increases)
    let x = h1;
    let y = 0.22 + lifecycle * 0.5;
    
    // Only show particles below top
    if y > 0.85 {
        return 0.0;
    }
    
    // Wandering motion
    let wander = sin(lifecycle * 6.0 + id * 4.0) * 0.015;
    let pos = vec2<f32>(x + wander, y);
    
    let d = distance(uv, pos);
    let size = 0.001 + h2 * 0.0015;
    
    // Fade in/out
    let fade = sin(lifecycle * 3.14159);
    
    let core = smoothstep(size, 0.0, d);
    let glow = smoothstep(size * 2.5, 0.0, d) * 0.2;
    
    return (core + glow) * fade;
}

// ============================================================
// SMOKE WISPS - Very subtle rising smoke
// ============================================================

fn smoke(uv: vec2<f32>, time: f32) -> f32 {
    // Only near play line (which is at y ≈ 0.20)
    if uv.y < 0.15 || uv.y > 0.35 {
        return 0.0;
    }
    
    var p = uv * vec2<f32>(4.0, 2.0);
    p.y += time * 0.06; // Rising smoke
    p.x += sin(p.y * 2.5 + time * 0.4) * 0.15;
    
    let n = fbm(p);
    
    // Tight fade around play line
    let dist = abs(uv.y - 0.22);
    let fade = 1.0 - smoothstep(0.0, 0.1, dist);
    
    return n * fade * 0.06;
}

// ============================================================
// MAIN - PURE BLACK WITH GOLDEN PLAY LINE
// ============================================================

@fragment
fn fs_main(in: VertexOutput) -> @location(0) vec4<f32> {
    let uv = in.uv_position;
    let time = time_uniform.time;
    
    // ===== PURE BLACK BACKGROUND =====
    var color = vec3<f32>(0.0, 0.0, 0.0);
    
    // ===== SINGLE GOLDEN PLAY LINE (at keyboard top) =====
    // In this coordinate system: y=0 is BOTTOM, y=1 is TOP
    // Keyboard occupies bottom 20%, so play line is at y ≈ 0.20
    let play_line_y = 0.205;
    let dist_from_line = abs(uv.y - play_line_y);
    
    // Only render near the line
    if dist_from_line < 0.15 {
        // Intense bright core
        let line_core = smoothstep(0.0015, 0.0, dist_from_line) * 1.8;
        
        // Glow layers
        let glow1 = smoothstep(0.012, 0.0, dist_from_line) * 0.9;
        let glow2 = smoothstep(0.035, 0.0, dist_from_line) * 0.45;
        let glow3 = smoothstep(0.08, 0.0, dist_from_line) * 0.2;
        let glow4 = smoothstep(0.15, 0.0, dist_from_line) * 0.08;
        
        let line_total = line_core + glow1 + glow2 + glow3 + glow4;
        
        // Golden to white-hot gradient
        let golden = vec3<f32>(1.0, 0.78, 0.2);
        let white = vec3<f32>(1.0, 1.0, 0.92);
        let line_color = mix(golden, white, clamp(line_core * 0.4, 0.0, 1.0));
        
        color = color + line_color * line_total;
    }
    
    // ===== GOLDEN FLOATING SPARKS (dense) =====
    var sparks = 0.0;
    for (var i = 0; i < 120; i++) {
        sparks += spark(uv, time, f32(i));
    }
    
    let spark_color = vec3<f32>(1.0, 0.75, 0.25);
    color = color + spark_color * sparks * 0.7;
    
    // ===== GOLDEN MIST/HAZE NEAR KEYBOARD =====
    let smoke_val = smoke(uv, time);
    let smoke_color = vec3<f32>(0.7, 0.55, 0.2);
    color = color + smoke_color * smoke_val;
    
    // ===== AMBIENT GOLDEN HAZE AT KEYBOARD =====
    let haze_dist = abs(uv.y - 0.18);
    let haze = exp(-haze_dist * haze_dist * 80.0) * 0.08;
    color = color + vec3<f32>(0.8, 0.6, 0.2) * haze;
    
    return vec4<f32>(color, 1.0);
}
