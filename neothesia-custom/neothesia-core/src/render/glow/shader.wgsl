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
}

struct VertexOutput {
    @builtin(position) position: vec4<f32>,
    @location(0) uv: vec2<f32>,
    @location(1) quad_color: vec4<f32>,
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
    return out;
}

// ============================================================
// CIRCULAR GLOW - Fades completely to zero at edges
// ============================================================

@fragment
fn fs_main(in: VertexOutput) -> @location(0) vec4<f32> {
    let center = vec2(0.5, 0.5);
    let dist = distance(in.uv, center);
    
    // Hard cutoff at edge of circle
    if dist > 0.5 {
        discard;
    }
    
    // Normalized distance (0 at center, 1 at edge)
    let norm_dist = dist * 2.0;
    
    // Multi-layer bloom that DEFINITELY fades to zero at edge
    // Using (1 - normalized_dist) as base for smooth falloff
    let falloff = 1.0 - norm_dist;
    let falloff2 = falloff * falloff;
    let falloff3 = falloff2 * falloff;
    let falloff4 = falloff3 * falloff;
    
    // Bright core
    let core = falloff4 * falloff4 * 1.5;
    
    // Inner glow
    let inner = falloff4 * 0.8;
    
    // Mid glow  
    let mid = falloff3 * 0.5;
    
    // Outer glow
    let outer = falloff2 * 0.3;
    
    // All these naturally go to 0 at edge (norm_dist = 1)
    let total = core + inner + mid + outer;
    
    // Color mixing - white hot center
    var glow_color = in.quad_color.rgb;
    let white_mix = core * 0.6;
    glow_color = mix(glow_color, vec3<f32>(1.0, 1.0, 1.0), clamp(white_mix, 0.0, 1.0));
    
    let final_alpha = total * in.quad_color.a;
    
    // Ensure alpha goes to 0 at edge
    if final_alpha < 0.01 {
        discard;
    }
    
    return vec4<f32>(glow_color * total, clamp(final_alpha, 0.0, 1.0));
}
