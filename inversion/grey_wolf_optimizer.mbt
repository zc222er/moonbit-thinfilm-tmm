///|
/// Grey Wolf Optimizer (GWO) Engine for Multilayer Film Design (Mirjalili et al. 2014)
pub struct GWOSettings {
  num_wolves : Int // Pack size n ~ 30
  max_iterations : Int
}

///|
pub fn GWOSettings::default() -> GWOSettings {
  { num_wolves: 30, max_iterations: 80 }
}

///|
/// Run Grey Wolf Optimization
pub fn grey_wolf_optimize(
  fitness_fn : (Array[Double]) -> Double,
  param_bounds : Array[ParameterBound],
  settings : GWOSettings,
) -> Array[Double] {
  let num_params = param_bounds.length()
  let pop_size = settings.num_wolves
  let rng = @linalg.Rng::new(12345678901UL)

  let wolves = Array::new(capacity=pop_size)
  let fitness = Array::new(capacity=pop_size)

  let mut alpha_pos = Array::new(capacity=num_params)
  let mut beta_pos = Array::new(capacity=num_params)
  let mut delta_pos = Array::new(capacity=num_params)

  let mut alpha_score = 1.0e30
  let mut beta_score = 1.0e30
  let mut delta_score = 1.0e30

  // 1. Initialize Pack
  for _i = 0; _i < pop_size; _i = _i + 1 {
    let w = Array::new(capacity=num_params)
    for j = 0; j < num_params; j = j + 1 {
      let b = param_bounds[j]
      w.push(rng.next_range(b.min_val, b.max_val))
    }
    let fit = fitness_fn(w)
    wolves.push(w)
    fitness.push(fit)

    if fit < alpha_score {
      delta_score = beta_score
      delta_pos = beta_pos.copy()
      beta_score = alpha_score
      beta_pos = alpha_pos.copy()
      alpha_score = fit
      alpha_pos = w.copy()
    } else if fit < beta_score {
      delta_score = beta_score
      delta_pos = beta_pos.copy()
      beta_score = fit
      beta_pos = w.copy()
    } else if fit < delta_score {
      delta_score = fit
      delta_pos = w.copy()
    }
  }

  // 2. Wolf Pack Hunting Iterations
  for iter = 0; iter < settings.max_iterations; iter = iter + 1 {
    let a_linear = 2.0 -
      2.0 * (iter.to_double() / settings.max_iterations.to_double())

    for i = 0; i < pop_size; i = i + 1 {
      let new_pos = Array::new(capacity=num_params)

      for j = 0; j < num_params; j = j + 1 {
        let b = param_bounds[j]

        // Toward Alpha
        let r1_a = rng.next_double()
        let r2_a = rng.next_double()
        let a1 = 2.0 * a_linear * r1_a - a_linear
        let c1 = 2.0 * r2_a
        let d_alpha = (c1 * alpha_pos[j] - wolves[i][j]).abs()
        let x1 = alpha_pos[j] - a1 * d_alpha

        // Toward Beta
        let r1_b = rng.next_double()
        let r2_b = rng.next_double()
        let a2 = 2.0 * a_linear * r1_b - a_linear
        let c2 = 2.0 * r2_b
        let d_beta = (c2 * beta_pos[j] - wolves[i][j]).abs()
        let x2 = beta_pos[j] - a2 * d_beta

        // Toward Delta
        let r1_d = rng.next_double()
        let r2_d = rng.next_double()
        let a3 = 2.0 * a_linear * r1_d - a_linear
        let c3 = 2.0 * r2_d
        let d_delta = (c3 * delta_pos[j] - wolves[i][j]).abs()
        let x3 = delta_pos[j] - a3 * d_delta

        // Average position
        let mut final_x = (x1 + x2 + x3) / 3.0
        if final_x < b.min_val {
          final_x = b.min_val
        } else if final_x > b.max_val {
          final_x = b.max_val
        }
        new_pos.push(final_x)
      }

      wolves[i] = new_pos
      let fit = fitness_fn(wolves[i])
      fitness[i] = fit

      if fit < alpha_score {
        delta_score = beta_score
        delta_pos = beta_pos.copy()
        beta_score = alpha_score
        beta_pos = alpha_pos.copy()
        alpha_score = fit
        alpha_pos = wolves[i].copy()
      } else if fit < beta_score {
        delta_score = beta_score
        delta_pos = beta_pos.copy()
        beta_score = fit
        beta_pos = wolves[i].copy()
      } else if fit < delta_score {
        delta_score = fit
        delta_pos = wolves[i].copy()
      }
    }
  }

  alpha_pos
}
