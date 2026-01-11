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
// HASH FUNCTIONS
// ============================================================

fn hash(p: vec2<f32>) -> f32 {
    var p3 = fract(vec3<f32>(p.x, p.y, p.x) * 0.1031);
    p3 = p3 + dot(p3, p3.yzx + 33.33);
    return fract((p3.x + p3.y) * p3.z);
}

fn hash3(p: vec2<f32>) -> vec3<f32> {
    return vec3<f32>(
        hash(p),
        hash(p + vec2<f32>(127.1, 311.7)),
        hash(p + vec2<f32>(269.5, 183.3))
    );
}

// ============================================================
// STAR/SPARKLE SHAPE
// ============================================================

fn star_shape(uv: vec2<f32>, center: vec2<f32>, size: f32, rotation: f32) -> f32 {
    let d = uv - center;
    let angle = atan2(d.y, d.x) + rotation;
    let dist = length(d);
    
    let star = abs(cos(angle * 2.0)) * 0.5 + 0.5;
    let star_dist = dist / (size * (0.3 + star * 0.7));
    
    return exp(-star_dist * star_dist * 8.0);
}

// ============================================================
// MAIN - CLEAN DARK BACKGROUND WITH ELEGANT PARTICLES
// ============================================================

@fragment
fn fs_main(in: VertexOutput) -> @location(0) vec4<f32> {
    let uv = in.uv_position;
    let time = time_uniform.time;
    
    // ===== PURE BLACK BACKGROUND =====
    var color = vec3<f32>(0.0, 0.0, 0.0);
    
    // ===== BRIGHT GOLDEN PLAY LINE =====
    let play_line_y = 0.205;
    let dist_from_line = abs(uv.y - play_line_y);
    
    let line_core = exp(-dist_from_line * dist_from_line * 120000.0) * 2.5;
    let line_glow1 = exp(-dist_from_line * dist_from_line * 15000.0) * 1.2;
    let line_glow2 = exp(-dist_from_line * dist_from_line * 2000.0) * 0.5;
    let line_glow3 = exp(-dist_from_line * dist_from_line * 500.0) * 0.2;
    
    let line_total = line_core + line_glow1 + line_glow2 + line_glow3;
    let golden = vec3<f32>(1.0, 0.8, 0.3);
    let white_hot = vec3<f32>(1.0, 0.98, 0.92);
    let line_color = mix(golden, white_hot, clamp(line_core * 0.4, 0.0, 1.0));
    color = color + line_color * line_total;
    
    // ===== RISING EMBER SPARKS WITH TRAILS =====
    for (var i = 0; i < 45; i++) {
        let id = f32(i);
        let h = hash3(vec2<f32>(id * 1.23, id * 0.77));
        
        let speed = 0.025 + h.x * 0.035;
        let lifecycle = fract(time * speed + h.y);
        let x = h.z + sin(lifecycle * 6.28 + id) * 0.025;
        let y = lifecycle;
        let pos = vec2<f32>(fract(x), y);
        
        if pos.y > 0.23 && pos.y < 0.93 {
            let size = 0.0025 + h.x * 0.003;
            
            // Fade in/out smoothly
            let fade = sin((pos.y - 0.23) / 0.70 * 3.14159);
            
            // Twinkle effect
            let twinkle = 0.4 + 0.6 * pow(0.5 + 0.5 * sin(time * (4.0 + h.x * 8.0) + id * 5.0), 2.0);
            
            // Particle glow
            let d = distance(uv, pos);
            let glow = exp(-d * d / (size * size * 0.15));
            
            // Small trail
            let trail_dir = vec2<f32>(0.0, -1.0);
            let to_uv = uv - pos;
            let along = dot(to_uv, trail_dir);
            if along > 0.0 && along < 0.015 {
                let perp = length(to_uv - trail_dir * along);
                let trail_fade = 1.0 - along / 0.015;
                let trail_width = size * 0.3 * trail_fade;
                let trail = exp(-perp * perp / (trail_width * trail_width)) * trail_fade * 0.4;
                color = color + vec3<f32>(1.0, 0.85, 0.5) * trail * fade * 0.4;
            }
            
            color = color + vec3<f32>(1.0, 0.85, 0.5) * glow * fade * twinkle * 0.7;
        }
    }
    
    // ===== TWINKLING STAR SPARKLES =====
    for (var i = 0; i < 30; i++) {
        let id = f32(i) + 100.0;
        let h = hash3(vec2<f32>(id * 2.17, id * 1.31));
        
        let x = h.x + sin(time * 0.08 + id * 0.5) * 0.01;
        let y = 0.28 + h.y * 0.60;
        let pos = vec2<f32>(fract(x), y);
        
        let size = 0.002 + h.z * 0.003;
        let rotation = time * (0.3 + h.x * 0.5);
        
        // Sharp twinkle - fully on/off
        let twinkle_speed = 2.5 + h.y * 4.0;
        let twinkle = pow(0.5 + 0.5 * sin(time * twinkle_speed + id * 11.0), 4.0);
        
        let star = star_shape(uv, pos, size, rotation) * twinkle;
        
        color = color + vec3<f32>(1.0, 0.92, 0.75) * star * 0.5;
    }
    
    // ===== TINY FLOATING DUST =====
    for (var i = 0; i < 50; i++) {
        let id = f32(i) + 200.0;
        let h = hash3(vec2<f32>(id, id * 0.5));
        
        let x = h.x + sin(time * 0.15 + id * 0.2) * 0.015;
        let y = fract(h.y + time * 0.008 * (0.5 + h.z));
        let pos = vec2<f32>(fract(x), y);
        
        if pos.y > 0.26 && pos.y < 0.88 {
            let d = distance(uv, pos);
            let size = 0.001 + h.z * 0.001;
            let dust = exp(-d * d / (size * size * 0.2));
            let fade = sin((pos.y - 0.26) / 0.62 * 3.14159) * 0.25;
            
            color = color + vec3<f32>(0.85, 0.8, 0.65) * dust * fade;
        }
    }
    
    // ===== VERY SUBTLE AMBIENT HAZE =====
    let haze = smoothstep(0.12, 0.22, uv.y) * smoothstep(0.35, 0.22, uv.y);
    color = color + golden * haze * 0.02;
    
    return vec4<f32>(color, 1.0);
}
