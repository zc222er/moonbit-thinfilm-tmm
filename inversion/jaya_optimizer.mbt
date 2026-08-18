///|
/// Jaya Parameterless Global Optimization Algorithm (Rao 2016)
pub struct JayaSettings {
  population_size : Int // NP ~ 30
  max_iterations : Int
}

///|
pub fn JayaSettings::default() -> JayaSettings {
  { population_size: 30, max_iterations: 80 }
}

///|
/// Run Jaya Optimization: X_new = X + r1 * (X_best - |X|) - r2 * (X_worst - |X|)
pub fn jaya_optimize(
  fitness_fn : (Array[Double]) -> Double,
  param_bounds : Array[ParameterBound],
  settings : JayaSettings,
) -> Array[Double] {
  let num_params = param_bounds.length()
  let np = settings.population_size
  let rng = @linalg.Rng::new(6543210987UL)

  let pop = Array::new(capacity=np)
  let fitness = Array::new(capacity=np)

  let mut best_idx = 0
  let mut worst_idx = 0

  // 1. Initialize Population
  for i = 0; i < np; i = i + 1 {
    let ind = Array::new(capacity=num_params)
    for j = 0; j < num_params; j = j + 1 {
      let b = param_bounds[j]
      ind.push(rng.next_range(b.min_val, b.max_val))
    }
    let fit = fitness_fn(ind)
    pop.push(ind)
    fitness.push(fit)

    if fit < fitness[best_idx] {
      best_idx = i
    }
    if fit > fitness[worst_idx] {
      worst_idx = i
    }
  }

  // 2. Jaya Algorithm Iterations
  for _iter = 0; _iter < settings.max_iterations; _iter = _iter + 1 {
    for i = 0; i < np; i = i + 1 {
      let new_ind = Array::new(capacity=num_params)

      for j = 0; j < num_params; j = j + 1 {
        let b = param_bounds[j]
        let r1 = rng.next_double()
        let r2 = rng.next_double()

        let x = pop[i][j]
        let x_best = pop[best_idx][j]
        let x_worst = pop[worst_idx][j]

        let mut val = x + r1 * (x_best - x.abs()) - r2 * (x_worst - x.abs())
        if val < b.min_val {
          val = b.min_val
        } else if val > b.max_val {
          val = b.max_val
        }
        new_ind.push(val)
      }

      let new_fit = fitness_fn(new_ind)
      if new_fit <= fitness[i] {
        pop[i] = new_ind
        fitness[i] = new_fit
      }
    }

    // Update best and worst indices
    best_idx = 0
    worst_idx = 0
    for i = 1; i < np; i = i + 1 {
      if fitness[i] < fitness[best_idx] {
        best_idx = i
      }
      if fitness[i] > fitness[worst_idx] {
        worst_idx = i
      }
    }
  }

  pop[best_idx].copy()
}
