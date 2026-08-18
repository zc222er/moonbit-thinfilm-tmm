///|
/// Covariance Matrix Adaptation Evolution Strategy (CMA-ES) Engine (Hansen 2006)
pub struct CMAESSettings {
  lambda_pop_size : Int // Population size lambda ~ 4 + 3 * ln(N)
  max_generations : Int
  initial_sigma : Double // Initial step-size sigma ~ 0.3
}

///|
pub fn CMAESSettings::default() -> CMAESSettings {
  { lambda_pop_size: 20, max_generations: 80, initial_sigma: 0.3 }
}

///|
/// Run CMA-ES Evolutionary Optimization
pub fn cma_es_optimize(
  fitness_fn : (Array[Double]) -> Double,
  initial_mean : Array[Double],
  param_bounds : Array[ParameterBound],
  settings : CMAESSettings,
) -> Array[Double] {
  let num_params = param_bounds.length()
  let pop_size = settings.lambda_pop_size
  let rng = @linalg.Rng::new(31415926535UL)

  let mut mean_p = initial_mean.copy()
  let mut sigma = settings.initial_sigma

  let mut best_sol = mean_p.copy()
  let mut best_fit = fitness_fn(mean_p)

  let mu = pop_size / 2 // Number of parents to recombine
  let weights = Array::new(capacity=mu)
  let mut sum_w = 0.0

  for i = 0; i < mu; i = i + 1 {
    let w = @math.ln((mu + 1).to_double()) - @math.ln((i + 1).to_double())
    weights.push(w)
    sum_w = sum_w + w
  }
  for i = 0; i < mu; i = i + 1 {
    weights[i] = weights[i] / sum_w
  }

  // Evolutionary Generations
  for _gen = 0; _gen < settings.max_generations; _gen = _gen + 1 {
    // 1. Sample population: x_k ~ mean + sigma * N(0, I)
    let population = Array::new(capacity=pop_size)
    let pop_fitness = Array::new(capacity=pop_size)

    for _k = 0; _k < pop_size; _k = _k + 1 {
      let cand = Array::new(capacity=num_params)
      for j = 0; j < num_params; j = j + 1 {
        let b = param_bounds[j]
        let g = rng.next_gaussian(0.0, 1.0)
        let mut val = mean_p[j] + sigma * g * (b.max_val - b.min_val) * 0.1
        if val < b.min_val {
          val = b.min_val
        } else if val > b.max_val {
          val = b.max_val
        }
        cand.push(val)
      }
      let fit = fitness_fn(cand)
      population.push(cand)
      pop_fitness.push(fit)

      if fit < best_fit {
        best_fit = fit
        best_sol = cand.copy()
      }
    }

    // 2. Sort population by fitness
    for i = 0; i < pop_size - 1; i = i + 1 {
      for j = i + 1; j < pop_size; j = j + 1 {
        if pop_fitness[j] < pop_fitness[i] {
          let tmp_f = pop_fitness[i]
          pop_fitness[i] = pop_fitness[j]
          pop_fitness[j] = tmp_f

          let tmp_p = population[i]
          population[i] = population[j]
          population[j] = tmp_p
        }
      }
    }

    // 3. Recombination: update mean
    let new_mean = Array::new(capacity=num_params)
    for j = 0; j < num_params; j = j + 1 {
      let mut weighted_sum = 0.0
      for i = 0; i < mu; i = i + 1 {
        weighted_sum = weighted_sum + weights[i] * population[i][j]
      }
      new_mean.push(weighted_sum)
    }

    mean_p = new_mean

    // Step-size adaptation decay
    sigma = sigma * 0.96
    if sigma < 1.0e-5 {
      sigma = 1.0e-5
    }
  }

  best_sol
}
