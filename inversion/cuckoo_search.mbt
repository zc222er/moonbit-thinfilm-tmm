///|
/// Cuckoo Search (CS) Global Optimization with Lévy Flights (Yang & Deb 2009)
pub struct CuckooSettings {
  num_nests : Int // Population size n ~ 30
  max_generations : Int
  discovery_rate_pa : Double // Fraction of eggs discovered p_a ~ 0.25
  step_size_alpha : Double // Lévy step scale ~ 0.1
}

///|
pub fn CuckooSettings::default() -> CuckooSettings {
  {
    num_nests: 35,
    max_generations: 150,
    discovery_rate_pa: 0.25,
    step_size_alpha: 0.1,
  }
}

///|
/// Run Cuckoo Search Optimization
pub fn cuckoo_search_optimize(
  fitness_fn : (Array[Double]) -> Double,
  param_bounds : Array[ParameterBound],
  settings : CuckooSettings,
) -> Array[Double] {
  let num_params = param_bounds.length()
  let pop_size = settings.num_nests
  let rng = @linalg.Rng::new(9988776655UL)

  let nests = Array::new(capacity=pop_size)
  let fitness = Array::new(capacity=pop_size)

  let mut best_nest = Array::new(capacity=num_params)
  let mut best_fit = 1.0e30

  // 1. Initialize Nests
  for _i = 0; _i < pop_size; _i = _i + 1 {
    let nest = Array::new(capacity=num_params)
    for j = 0; j < num_params; j = j + 1 {
      let b = param_bounds[j]
      nest.push(rng.next_range(b.min_val, b.max_val))
    }
    let fit = fitness_fn(nest)
    nests.push(nest)
    fitness.push(fit)

    if fit < best_fit {
      best_fit = fit
      best_nest = nest.copy()
    }
  }

  // 2. Cuckoo Flight Iterations
  for _gen = 0; _gen < settings.max_generations; _gen = _gen + 1 {
    for i = 0; i < pop_size; i = i + 1 {
      let candidate = Array::new(capacity=num_params)

      for j = 0; j < num_params; j = j + 1 {
        let b = param_bounds[j]
        let g = rng.next_gaussian(0.0, 1.0)
        let step = settings.step_size_alpha * g * (b.max_val - b.min_val) * 0.1 +
          0.3 * (best_nest[j] - nests[i][j])
        let mut val = nests[i][j] + step
        if val < b.min_val {
          val = b.min_val
        } else if val > b.max_val {
          val = b.max_val
        }
        candidate.push(val)
      }

      let cand_fit = fitness_fn(candidate)
      if cand_fit < fitness[i] {
        nests[i] = candidate
        fitness[i] = cand_fit

        if cand_fit < best_fit {
          best_fit = cand_fit
          best_nest = nests[i].copy()
        }
      }
    }

    // Abandon fraction of nests
    for i = 0; i < pop_size; i = i + 1 {
      if rng.next_double() < settings.discovery_rate_pa {
        let new_nest = Array::new(capacity=num_params)
        for j = 0; j < num_params; j = j + 1 {
          let b = param_bounds[j]
          new_nest.push(rng.next_range(b.min_val, b.max_val))
        }
        let f_new = fitness_fn(new_nest)
        nests[i] = new_nest
        fitness[i] = f_new

        if f_new < best_fit {
          best_fit = f_new
          best_nest = new_nest.copy()
        }
      }
    }
  }

  best_nest
}
