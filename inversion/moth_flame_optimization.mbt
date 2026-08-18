///|
/// Moth-Flame Optimization (MFO) Engine (Mirjalili 2015)
pub struct MFOSettings {
  num_moths : Int // Population size n ~ 30
  max_iterations : Int
  spiral_constant_b : Double // Spiral parameter b ~ 1.0
}

///|
pub fn MFOSettings::default() -> MFOSettings {
  { num_moths: 30, max_iterations: 80, spiral_constant_b: 1.0 }
}

///|
/// Run Moth-Flame Optimization
pub fn moth_flame_optimize(
  fitness_fn : (Array[Double]) -> Double,
  param_bounds : Array[ParameterBound],
  settings : MFOSettings,
) -> Array[Double] {
  let num_params = param_bounds.length()
  let pop_size = settings.num_moths
  let rng = @linalg.Rng::new(2468013579UL)

  let moths = Array::new(capacity=pop_size)
  let fitness = Array::new(capacity=pop_size)

  // 1. Initialize Moths
  for _i = 0; _i < pop_size; _i = _i + 1 {
    let m = Array::new(capacity=num_params)
    for j = 0; j < num_params; j = j + 1 {
      let b = param_bounds[j]
      m.push(rng.next_range(b.min_val, b.max_val))
    }
    let fit = fitness_fn(m)
    moths.push(m)
    fitness.push(fit)
  }

  // 2. MFO Spiral Navigation Iterations
  for iter = 0; iter < settings.max_iterations; iter = iter + 1 {
    // Sort moths to identify best flames
    for i = 0; i < pop_size - 1; i = i + 1 {
      for j = i + 1; j < pop_size; j = j + 1 {
        if fitness[j] < fitness[i] {
          let tmp_f = fitness[i]
          fitness[i] = fitness[j]
          fitness[j] = tmp_f

          let tmp_m = moths[i]
          moths[i] = moths[j]
          moths[j] = tmp_m
        }
      }
    }

    let a_decay = -1.0 +
      iter.to_double() / settings.max_iterations.to_double() * -1.0 // -1 to -2

    for i = 0; i < pop_size; i = i + 1 {
      let new_moth = Array::new(capacity=num_params)

      for j = 0; j < num_params; j = j + 1 {
        let b = param_bounds[j]
        let t = (a_decay - 1.0) * rng.next_double() + 1.0 // Random path parameter in [a, 1]

        let flame_idx = if i < 5 { i } else { 0 }
        let d_flame = (moths[flame_idx][j] - moths[i][j]).abs()
        let spiral = d_flame *
          @math.exp(settings.spiral_constant_b * t) *
          @math.cos(2.0 * @math.PI * t)
        let mut val = moths[flame_idx][j] + spiral

        if val < b.min_val {
          val = b.min_val
        } else if val > b.max_val {
          val = b.max_val
        }
        new_moth.push(val)
      }

      moths[i] = new_moth
      fitness[i] = fitness_fn(moths[i])
    }
  }

  // Final sort to return best flame
  for i = 0; i < pop_size - 1; i = i + 1 {
    for j = i + 1; j < pop_size; j = j + 1 {
      if fitness[j] < fitness[i] {
        let tmp_f = fitness[i]
        fitness[i] = fitness[j]
        fitness[j] = tmp_f

        let tmp_m = moths[i]
        moths[i] = moths[j]
        moths[j] = tmp_m
      }
    }
  }

  moths[0].copy()
}
