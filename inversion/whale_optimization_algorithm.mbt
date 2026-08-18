///|
/// Whale Optimization Algorithm (WOA) Engine (Mirjalili & Lewis 2016)
pub struct WOASettings {
  num_whales : Int // Population size n ~ 30
  max_iterations : Int
  spiral_constant_b : Double // Logarithmic spiral shape constant b ~ 1.0
}

///|
pub fn WOASettings::default() -> WOASettings {
  { num_whales: 30, max_iterations: 80, spiral_constant_b: 1.0 }
}

///|
/// Run Whale Optimization Algorithm
pub fn whale_optimize(
  fitness_fn : (Array[Double]) -> Double,
  param_bounds : Array[ParameterBound],
  settings : WOASettings,
) -> Array[Double] {
  let num_params = param_bounds.length()
  let pop_size = settings.num_whales
  let rng = @linalg.Rng::new(5432198760UL)

  let whales = Array::new(capacity=pop_size)
  let fitness = Array::new(capacity=pop_size)

  let mut best_whale = Array::new(capacity=num_params)
  let mut best_fit = 1.0e30

  // 1. Initialize Whale Population
  for _i = 0; _i < pop_size; _i = _i + 1 {
    let w = Array::new(capacity=num_params)
    for j = 0; j < num_params; j = j + 1 {
      let b = param_bounds[j]
      w.push(rng.next_range(b.min_val, b.max_val))
    }
    let fit = fitness_fn(w)
    whales.push(w)
    fitness.push(fit)

    if fit < best_fit {
      best_fit = fit
      best_whale = w.copy()
    }
  }

  // 2. Hunting & Bubble-Net Iterations
  for iter = 0; iter < settings.max_iterations; iter = iter + 1 {
    let a_decay = 2.0 -
      2.0 * (iter.to_double() / settings.max_iterations.to_double())

    for i = 0; i < pop_size; i = i + 1 {
      let r1 = rng.next_double()
      let r2 = rng.next_double()

      let a_vec = 2.0 * a_decay * r1 - a_decay
      let c_vec = 2.0 * r2
      let p = rng.next_double()
      let l = rng.next_range(-1.0, 1.0)

      let new_w = Array::new(capacity=num_params)

      for j = 0; j < num_params; j = j + 1 {
        let b = param_bounds[j]
        let mut val = whales[i][j]

        if p < 0.5 {
          if a_vec.abs() < 1.0 {
            // Shrinking encircling mechanism toward leader
            let d_leader = (c_vec * best_whale[j] - whales[i][j]).abs()
            val = best_whale[j] - a_vec * d_leader
          } else {
            // Search for prey (exploration)
            let rand_idx = (rng.next_double() * pop_size.to_double()).to_int()
            let d_rand = (c_vec * whales[rand_idx][j] - whales[i][j]).abs()
            val = whales[rand_idx][j] - a_vec * d_rand
          }
        } else {
          // Spiral bubble-net updating position: D' * exp(b*l) * cos(2*pi*l) + X*
          let d_prime = (best_whale[j] - whales[i][j]).abs()
          let spiral = d_prime *
            @math.exp(settings.spiral_constant_b * l) *
            @math.cos(2.0 * @math.PI * l)
          val = best_whale[j] + spiral
        }

        if val < b.min_val {
          val = b.min_val
        } else if val > b.max_val {
          val = b.max_val
        }
        new_w.push(val)
      }

      whales[i] = new_w
      let fit = fitness_fn(whales[i])
      fitness[i] = fit

      if fit < best_fit {
        best_fit = fit
        best_whale = whales[i].copy()
      }
    }
  }

  best_whale
}
