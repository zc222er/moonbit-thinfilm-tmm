///|
/// Fast Simulated Annealing (FSA) with Cauchy Cooling Schedule for Global Thin Film Optimization
pub struct AnnealingSettings {
  initial_temperature : Double
  final_temperature : Double
  max_evaluations : Int
  cooling_rate : Double
}

///|
pub fn AnnealingSettings::default() -> AnnealingSettings {
  {
    initial_temperature: 10.0,
    final_temperature: 1.0e-5,
    max_evaluations: 2000,
    cooling_rate: 0.95,
  }
}

///|
/// Run Fast Simulated Annealing Global Optimization
pub fn simulated_annealing_optimize(
  fitness_fn : (Array[Double]) -> Double,
  initial_point : Array[Double],
  param_bounds : Array[ParameterBound],
  settings : AnnealingSettings,
) -> Array[Double] {
  let num_params = initial_point.length()
  let rng = @linalg.Rng::new(7788990011UL)

  let mut current_p = initial_point.copy()
  let mut current_energy = fitness_fn(current_p)

  let mut best_p = current_p.copy()
  let mut best_energy = current_energy

  let mut temperature = settings.initial_temperature
  let mut eval_count = 0

  while eval_count < settings.max_evaluations &&
        temperature > settings.final_temperature {
    eval_count = eval_count + 1

    let candidate_p = Array::new(capacity=num_params)
    for j = 0; j < num_params; j = j + 1 {
      let b = param_bounds[j]
      let (g, _) = (rng.next_gaussian(0.0, 1.0), 0.0)
      let step = g *
        (temperature / settings.initial_temperature) *
        0.5 *
        (b.max_val - b.min_val)
      let mut cand_val = current_p[j] + step
      if cand_val < b.min_val {
        cand_val = b.min_val
      } else if cand_val > b.max_val {
        cand_val = b.max_val
      }
      candidate_p.push(cand_val)
    }

    let candidate_energy = fitness_fn(candidate_p)
    let delta_e = candidate_energy - current_energy

    let accept = if delta_e <= 0.0 {
      true
    } else {
      let rand_u = rng.next_double()
      let prob = @math.exp(-delta_e / temperature)
      rand_u < prob
    }

    if accept {
      current_p = candidate_p
      current_energy = candidate_energy

      if current_energy < best_energy {
        best_energy = current_energy
        best_p = current_p.copy()
      }
    }

    temperature = settings.initial_temperature /
      (1.0 + eval_count.to_double() * 0.01)
  }

  best_p
}
