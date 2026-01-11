struct ViewUniform {
    transform: mat4x4<f32>,
    size: vec2<f32>,
    scale: f32,
}

@group(0) @binding(0)
var<uniform> view_uniform: ViewUniform;

struct Vertex {
    @location(0) position: vec2<f32>,
}

struct QuadInstance {
    @location(1) q_position: vec2<f32>,
    @location(2) size: vec2<f32>,
    @location(3) color: vec4<f32>,
    @location(4) time_data: vec2<f32>,
}

struct VertexOutput {
    @builtin(position) position: vec4<f32>,
    @location(0) uv: vec2<f32>,
    @location(1) quad_color: vec4<f32>,
    @location(2) press_time: f32,
}

@vertex
fn vs_main(vertex: Vertex, quad: QuadInstance) -> VertexOutput {
    var quad_position = quad.q_position * view_uniform.scale;
    var quad_size = quad.size * view_uniform.scale;

    var i_transform: mat4x4<f32> = mat4x4<f32>(
        vec4<f32>(quad_size.x, 0.0, 0.0, 0.0),
        vec4<f32>(0.0, quad_size.y, 0.0, 0.0),
        vec4<f32>(0.0, 0.0, 1.0, 0.0),
        vec4<f32>(quad_position, 0.0, 1.0)
    );

    var out: VertexOutput;
    out.position = view_uniform.transform * i_transform * vec4<f32>(vertex.position, 0.0, 1.0);
    out.uv = vertex.position;
    out.quad_color = quad.color;
    out.press_time = quad.time_data.x;
    return out;
}

// ============================================================
// HASH
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
// SPECTACULAR SHOOTING SPARK
// ============================================================

fn shooting_spark(uv: vec2<f32>, center: vec2<f32>, time: f32, id: f32) -> f32 {
    let h = hash3(vec2<f32>(id * 1.23, id * 0.77));
    
    // Spark shoots outward in all directions
    let base_angle = h.x * 6.28318;
    // Mix of upward and sideways
    let angle = base_angle * 0.7 - 3.14159 * 0.3 + (h.y - 0.5) * 1.5;
    
    // SLOWER animation for more visibility
    let speed = 0.35 + h.z * 0.25;
    let t = time * 1.8;  // Slower time progression
    
    // Physics: fast start, slow down
    let travel = speed * t * exp(-t * 0.3);
    
    // Gentle gravity
    let gravity = t * t * 0.015;
    
    // Calculate spark position
    let dir = vec2<f32>(cos(angle), sin(angle));
    var spark_pos = center + dir * travel;
    spark_pos.y = spark_pos.y + gravity;
    
    // Distance to spark
    let d = distance(uv, spark_pos);
    
    // LARGER spark size
    let size = 0.025 * (1.0 - t * 0.15) * (0.6 + h.x * 0.8);
    
    // Very bright core
    let core = exp(-d * d / (size * size * 0.06)) * 1.5;
    
    // Larger glowing halo
    let halo = exp(-d * d / (size * size * 0.4)) * 0.6;
    
    // Longer motion trail
    var trail = 0.0;
    let vel = dir * speed * exp(-t * 0.3);
    let vel_len = length(vel);
    if vel_len > 0.001 {
        let vel_norm = vel / vel_len;
        let to_uv = uv - spark_pos;
        let along = dot(to_uv, -vel_norm);
        let perp = length(to_uv + vel_norm * along);
        
        let trail_len = 0.12 * (1.0 - t * 0.2);
        if along > 0.0 && along < trail_len {
            let trail_fade = 1.0 - along / trail_len;
            let trail_width = size * 0.6 * trail_fade;
            trail = exp(-perp * perp / (trail_width * trail_width)) * trail_fade * 0.7;
        }
    }
    
    // SLOWER fade out
    let fade = exp(-t * 1.5);
    
    return (core + halo + trail) * fade;
}

// ============================================================
// MAIN - SPECTACULAR IMPACT EFFECT
// ============================================================

@fragment
fn fs_main(in: VertexOutput) -> @location(0) vec4<f32> {
    let center = vec2(0.5, 0.5);
    let dist = distance(in.uv, center);
    let time = in.press_time;
    
    let norm_dist = dist * 2.0;
    
    // ===== COMPACT CENTRAL GLOW =====
    let core_radius = 0.06;
    let core_dist = dist / core_radius;
    
    // Bright white core
    let core = exp(-core_dist * core_dist * 3.0);
    // Inner glow
    let inner = exp(-core_dist * core_dist * 1.0) * 0.6;
    // Outer glow
    let outer = exp(-core_dist * core_dist * 0.4) * 0.3;
    
    var glow = core + inner + outer;
    
    // Initial bright flash
    let flash = exp(-time * 12.0) * 4.0;
    glow = glow + flash * exp(-core_dist * core_dist * 2.0);
    
    // ===== SHOOTING SPARKS - LONGER LASTING =====
    var sparks = 0.0;
    
    if time < 2.0 {  // Extended duration
        // Main burst - 24 sparks shooting outward
        for (var i = 0; i < 24; i++) {
            sparks += shooting_spark(in.uv, center, time, f32(i));
        }
        
        // Second wave - slightly delayed
        if time > 0.03 {
            for (var i = 0; i < 18; i++) {
                sparks += shooting_spark(in.uv, center, time - 0.03, f32(i) + 50.0) * 0.85;
            }
        }
        
        // Third wave
        if time > 0.08 {
            for (var i = 0; i < 12; i++) {
                sparks += shooting_spark(in.uv, center, time - 0.08, f32(i) + 100.0) * 0.7;
            }
        }
        
        // Fourth wave for sustained effect
        if time > 0.15 {
            for (var i = 0; i < 8; i++) {
                sparks += shooting_spark(in.uv, center, time - 0.15, f32(i) + 150.0) * 0.5;
            }
        }
    }
    
    // ===== EXPANDING SHOCKWAVE RING =====
    let ring_speed = 0.8;
    let ring_radius = time * ring_speed;
    let ring_width = 0.02 + time * 0.03;
    let ring_dist = abs(norm_dist - ring_radius);
    let ring = exp(-ring_dist * ring_dist / (ring_width * ring_width)) * exp(-time * 4.0);
    
    // ===== COLOR COMPOSITION =====
    var final_color = in.quad_color.rgb;
    
    // White-hot center
    let white_amount = core * 0.9 + flash * 0.6;
    final_color = mix(final_color, vec3<f32>(1.0, 1.0, 1.0), clamp(white_amount, 0.0, 0.95));
    
    // Bright spark color - white-gold
    let spark_color = vec3<f32>(1.0, 0.95, 0.75);
    final_color = final_color + spark_color * sparks * 2.0;
    
    // Ring
    let ring_color = mix(vec3<f32>(1.0, 0.9, 0.5), in.quad_color.rgb, 0.4);
    final_color = final_color + ring_color * ring;
    
    // Total intensity
    let total = glow + sparks + ring * 0.6;
    
    // Alpha - smooth edge falloff
    var alpha = total * in.quad_color.a;
    let edge_fade = smoothstep(0.5, 0.35, norm_dist);
    alpha = alpha * edge_fade;
    
    if alpha < 0.002 {
        discard;
    }
    
    // Clamp color intensity
    final_color = clamp(final_color * min(total, 2.5), vec3<f32>(0.0), vec3<f32>(3.0));
    
    return vec4<f32>(final_color, clamp(alpha, 0.0, 1.0));
}
