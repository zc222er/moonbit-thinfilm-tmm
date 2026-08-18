///|
/// Sine Cosine Algorithm (SCA) Engine for Multilayer Optimization (Mirjalili 2016)
pub struct SCASettings {
  num_agents : Int // Population size n ~ 30
  max_iterations : Int
  a_constant : Double // Constant a ~ 2.0
}

///|
pub fn SCASettings::default() -> SCASettings {
  { num_agents: 30, max_iterations: 80, a_constant: 2.0 }
}

///|
/// Run Sine Cosine Optimization
pub fn sine_cosine_optimize(
  fitness_fn : (Array[Double]) -> Double,
  param_bounds : Array[ParameterBound],
  settings : SCASettings,
) -> Array[Double] {
  let num_params = param_bounds.length()
  let pop_size = settings.num_agents
  let rng = @linalg.Rng::new(1357924680UL)

  let agents = Array::new(capacity=pop_size)
  let fitness = Array::new(capacity=pop_size)

  let mut best_agent = Array::new(capacity=num_params)
  let mut best_fit = 1.0e30

  // 1. Initialize Agents
  for _i = 0; _i < pop_size; _i = _i + 1 {
    let ag = Array::new(capacity=num_params)
    for j = 0; j < num_params; j = j + 1 {
      let b = param_bounds[j]
      ag.push(rng.next_range(b.min_val, b.max_val))
    }
    let fit = fitness_fn(ag)
    agents.push(ag)
    fitness.push(fit)

    if fit < best_fit {
      best_fit = fit
      best_agent = ag.copy()
    }
  }

  // 2. SCA Iterations
  for iter = 0; iter < settings.max_iterations; iter = iter + 1 {
    let r1 = settings.a_constant -
      settings.a_constant *
      (iter.to_double() / settings.max_iterations.to_double())

    for i = 0; i < pop_size; i = i + 1 {
      let new_pos = Array::new(capacity=num_params)

      for j = 0; j < num_params; j = j + 1 {
        let b = param_bounds[j]
        let r2 = 2.0 * @math.PI * rng.next_double()
        let r3 = 2.0 * rng.next_double()
        let r4 = rng.next_double()

        let mut val = if r4 < 0.5 {
          // Sine phase
          agents[i][j] +
          r1 * @math.sin(r2) * (r3 * best_agent[j] - agents[i][j]).abs()
        } else {
          // Cosine phase
          agents[i][j] +
          r1 * @math.cos(r2) * (r3 * best_agent[j] - agents[i][j]).abs()
        }

        if val < b.min_val {
          val = b.min_val
        } else if val > b.max_val {
          val = b.max_val
        }
        new_pos.push(val)
      }

      agents[i] = new_pos
      let fit = fitness_fn(agents[i])
      fitness[i] = fit

      if fit < best_fit {
        best_fit = fit
        best_agent = agents[i].copy()
      }
    }
  }

  best_agent
}
