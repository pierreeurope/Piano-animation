use std::time::Duration;

use wgpu_jumpstart::{Color, Gpu, TransformUniform, Uniform};

use super::{GlowInstance, GlowPipeline};

struct GlowState {
    time: f32,
    was_active: bool,
}

impl GlowState {
    fn new() -> Self {
        Self {
            time: 0.0,
            was_active: false,
        }
    }

    fn size(&self) -> f32 {
        // MUCH LARGER glow area so particles have room to fly
        // Burst starts big, settles to steady state
        let burst = (-self.time * 2.0).exp() * 150.0;
        350.0 + burst  // Very large to give particles travel distance
    }

    fn update(&mut self, delta: Duration, is_active: bool) {
        if is_active {
            if !self.was_active {
                self.time = 0.0;  // Reset on new press
            }
            self.time += delta.as_secs_f32() * 3.0;
        } else {
            self.time = 0.0;
        }
        self.was_active = is_active;
    }

    fn calc_color(&self, color: Color) -> [f32; 4] {
        let mut color = color.into_linear_rgba();
        
        // Bright flash on press
        let flash = (-self.time * 5.0).exp() * 0.5;
        
        color[0] = (color[0] * 1.3 + flash).min(1.5);
        color[1] = (color[1] * 1.2 + flash * 0.8).min(1.3);
        color[2] = (color[2] * 1.1 + flash * 0.5).min(1.2);
        color[3] = 0.8;
        
        color
    }
    
    fn get_time(&self) -> f32 {
        self.time
    }
}

pub struct GlowRenderer {
    pipeline: GlowPipeline,
    states: Vec<GlowState>,
}

impl GlowRenderer {
    pub fn new(
        gpu: &Gpu,
        transform: &Uniform<TransformUniform>,
        layout: &piano_layout::KeyboardLayout,
    ) -> Self {
        let pipeline = GlowPipeline::new(gpu, transform);

        let states: Vec<GlowState> = layout
            .range
            .iter()
            .map(|_| GlowState::new())
            .collect();

        Self { pipeline, states }
    }

    pub fn prepare(&mut self) {
        self.pipeline.prepare();
    }

    pub fn render<'a>(&'a self, render_pass: &mut wgpu::RenderPass<'a>) {
        self.pipeline.render(render_pass);
    }

    pub fn clear(&mut self) {
        self.pipeline.clear();
    }

    pub fn push(
        &mut self,
        id: usize,
        color: Color,
        key_x: f32,
        key_y: f32,
        key_w: f32,
        delta: Duration,
    ) {
        let state = &mut self.states[id];
        state.update(delta, true);

        let color = state.calc_color(color);
        let glow_w = state.size();
        let glow_h = glow_w;
        let time = state.get_time();

        self.pipeline.instances().push(GlowInstance {
            position: [key_x - glow_w / 2.0 + key_w / 2.0, key_y - glow_w / 2.0],
            size: [glow_w, glow_h],
            color,
            time,
            _padding: 0.0,
        });
    }
    
    pub fn update_inactive(&mut self, delta: Duration) {
        for state in self.states.iter_mut() {
            if state.was_active {
                state.update(delta, false);
            }
        }
    }
}
