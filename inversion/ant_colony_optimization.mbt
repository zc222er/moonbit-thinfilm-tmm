///|
/// Continuous Ant Colony Optimization (ACOR) for Multilayer Optical Synthesis (Socha & Dorigo 2008)
pub struct ACORSettings {
  num_ants : Int // Number of ants generated per iteration ~ 30
  archive_size : Int // Solution archive size k ~ 50
  max_iterations : Int
  q_locality : Double // Locality parameter q ~ 0.5
  xi_convergence : Double // Pheromone evaporation / convergence speed xi ~ 0.85
}

///|
pub fn ACORSettings::default() -> ACORSettings {
  {
    num_ants: 30,
    archive_size: 50,
    max_iterations: 80,
    q_locality: 0.5,
    xi_convergence: 0.85,
  }
}

///|
/// Run Continuous Ant Colony Optimization
pub fn ant_colony_optimize(
  fitness_fn : (Array[Double]) -> Double,
  param_bounds : Array[ParameterBound],
  settings : ACORSettings,
) -> Array[Double] {
  let num_params = param_bounds.length()
  let k_arch = settings.archive_size
  let rng = @linalg.Rng::new(246813579UL)

  let archive_pos = Array::new(capacity=k_arch)
  let archive_fit = Array::new(capacity=k_arch)

  // 1. Initialize Archive randomly
  for _i = 0; _i < k_arch; _i = _i + 1 {
    let p = Array::new(capacity=num_params)
    for j = 0; j < num_params; j = j + 1 {
      let b = param_bounds[j]
      p.push(rng.next_range(b.min_val, b.max_val))
    }
    let fit = fitness_fn(p)
    archive_pos.push(p)
    archive_fit.push(fit)
  }

  // 2. Ant Generation Iterations
  for _iter = 0; _iter < settings.max_iterations; _iter = _iter + 1 {
    // Sort archive in ascending order of fitness
    for i = 0; i < k_arch - 1; i = i + 1 {
      for j = i + 1; j < k_arch; j = j + 1 {
        if archive_fit[j] < archive_fit[i] {
          let tmp_f = archive_fit[i]
          archive_fit[i] = archive_fit[j]
          archive_fit[j] = tmp_f

          let tmp_p = archive_pos[i]
          archive_pos[i] = archive_pos[j]
          archive_pos[j] = tmp_p
        }
      }
    }

    // Sample new solutions using Gaussian kernel mixtures
    for _a = 0; _a < settings.num_ants; _a = _a + 1 {
      // Pick guide solution l from archive with higher weight for better ranks
      let guide_idx = (rng.next_double() * 5.0).to_int() // bias towards top 5
      let guide_p = archive_pos[guide_idx]

      let new_ant_p = Array::new(capacity=num_params)
      for j = 0; j < num_params; j = j + 1 {
        let b = param_bounds[j]
        let g = rng.next_gaussian(0.0, 1.0)
        let sigma = settings.xi_convergence * (b.max_val - b.min_val) * 0.05
        let mut val = guide_p[j] + g * sigma
        if val < b.min_val {
          val = b.min_val
        } else if val > b.max_val {
          val = b.max_val
        }
        new_ant_p.push(val)
      }

      let fit = fitness_fn(new_ant_p)
      // If better than worst in archive, replace
      if fit < archive_fit[k_arch - 1] {
        archive_pos[k_arch - 1] = new_ant_p
        archive_fit[k_arch - 1] = fit
      }
    }
  }

  // Return best solution
  archive_pos[0].copy()
}
