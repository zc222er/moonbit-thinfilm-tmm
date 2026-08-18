///|
/// Particle Swarm Optimization (PSO) Algorithm for Multilayer Thin-Film Synthesis
pub struct PSOSettings {
  num_particles : Int
  max_iterations : Int
  inertia_weight_start : Double // w_start ~ 0.9
  inertia_weight_end : Double // w_end ~ 0.4
  c1_cognitive : Double // c1 ~ 1.5
  c2_social : Double // c2 ~ 1.5
}

///|
pub fn PSOSettings::default() -> PSOSettings {
  {
    num_particles: 30,
    max_iterations: 80,
    inertia_weight_start: 0.9,
    inertia_weight_end: 0.4,
    c1_cognitive: 1.5,
    c2_social: 1.5,
  }
}

///|
/// Run Particle Swarm Optimization
pub fn particle_swarm_optimize(
  fitness_fn : (Array[Double]) -> Double,
  param_bounds : Array[ParameterBound],
  settings : PSOSettings,
) -> Array[Double] {
  let num_params = param_bounds.length()
  let pop_size = settings.num_particles
  let rng = @linalg.Rng::new(135792468UL)

  let positions = Array::new(capacity=pop_size)
  let velocities = Array::new(capacity=pop_size)
  let pbest_pos = Array::new(capacity=pop_size)
  let pbest_fit = Array::new(capacity=pop_size)

  let mut gbest_pos = Array::new(capacity=num_params)
  let mut gbest_fit = 1.0e30

  // 1. Initialize Swarm
  for _i = 0; _i < pop_size; _i = _i + 1 {
    let pos = Array::new(capacity=num_params)
    let vel = Array::new(capacity=num_params)

    for j = 0; j < num_params; j = j + 1 {
      let b = param_bounds[j]
      let p_val = rng.next_range(b.min_val, b.max_val)
      let v_span = (b.max_val - b.min_val) * 0.1
      let v_val = rng.next_range(-v_span, v_span)
      pos.push(p_val)
      vel.push(v_val)
    }

    let fit = fitness_fn(pos)
    positions.push(pos)
    velocities.push(vel)
    pbest_pos.push(pos.copy())
    pbest_fit.push(fit)

    if fit < gbest_fit {
      gbest_fit = fit
      gbest_pos = pos.copy()
    }
  }

  // 2. Swarm Movement Iterations
  for iter = 0; iter < settings.max_iterations; iter = iter + 1 {
    let iter_frac = iter.to_double() / settings.max_iterations.to_double()
    let w = settings.inertia_weight_start -
      (settings.inertia_weight_start - settings.inertia_weight_end) * iter_frac

    for i = 0; i < pop_size; i = i + 1 {
      for j = 0; j < num_params; j = j + 1 {
        let r1 = rng.next_double()
        let r2 = rng.next_double()
        let b = param_bounds[j]

        // v = w * v + c1 * r1 * (pbest - x) + c2 * r2 * (gbest - x)
        let cog = settings.c1_cognitive *
          r1 *
          (pbest_pos[i][j] - positions[i][j])
        let soc = settings.c2_social * r2 * (gbest_pos[j] - positions[i][j])
        let mut new_v = w * velocities[i][j] + cog + soc

        // Velocity clamping
        let max_v = (b.max_val - b.min_val) * 0.2
        if new_v > max_v {
          new_v = max_v
        } else if new_v < -max_v {
          new_v = -max_v
        }
        velocities[i][j] = new_v

        // Position update: x = x + v
        let mut new_p = positions[i][j] + new_v
        if new_p < b.min_val {
          new_p = b.min_val
          velocities[i][j] = -0.5 * velocities[i][j]
        } else if new_p > b.max_val {
          new_p = b.max_val
          velocities[i][j] = -0.5 * velocities[i][j]
        }
        positions[i][j] = new_p
      }

      let current_fit = fitness_fn(positions[i])
      if current_fit < pbest_fit[i] {
        pbest_fit[i] = current_fit
        pbest_pos[i] = positions[i].copy()

        if current_fit < gbest_fit {
          gbest_fit = current_fit
          gbest_pos = positions[i].copy()
        }
      }
    }
  }

  gbest_pos
}
