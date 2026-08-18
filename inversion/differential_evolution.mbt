///|
/// Classical Differential Evolution (DE/rand/1/bin) Global Optimizer (Storn & Price 1997)
pub struct DESettings {
  population_size : Int // NP ~ 30
  max_generations : Int
  mutation_factor_f : Double // F ~ 0.5 - 0.8
  crossover_prob_cr : Double // CR ~ 0.7 - 0.9
}

///|
pub fn DESettings::default() -> DESettings {
  {
    population_size: 30,
    max_generations: 80,
    mutation_factor_f: 0.7,
    crossover_prob_cr: 0.8,
  }
}

///|
/// Run Differential Evolution Optimization
pub fn differential_evolution_optimize(
  fitness_fn : (Array[Double]) -> Double,
  param_bounds : Array[ParameterBound],
  settings : DESettings,
) -> Array[Double] {
  let num_params = param_bounds.length()
  let np = settings.population_size
  let rng = @linalg.Rng::new(87654321098UL)

  let pop = Array::new(capacity=np)
  let fitness = Array::new(capacity=np)

  let mut best_sol = Array::new(capacity=num_params)
  let mut best_fit = 1.0e30

  // 1. Initialize Population
  for _i = 0; _i < np; _i = _i + 1 {
    let ind = Array::new(capacity=num_params)
    for j = 0; j < num_params; j = j + 1 {
      let b = param_bounds[j]
      ind.push(rng.next_range(b.min_val, b.max_val))
    }
    let fit = fitness_fn(ind)
    pop.push(ind)
    fitness.push(fit)

    if fit < best_fit {
      best_fit = fit
      best_sol = ind.copy()
    }
  }

  // 2. DE Evolution Loop
  for _gen = 0; _gen < settings.max_generations; _gen = _gen + 1 {
    for i = 0; i < np; i = i + 1 {
      // Pick 3 distinct random individuals r1, r2, r3 != i
      let mut r1 = (rng.next_double() * np.to_double()).to_int()
      while r1 == i {
        r1 = (rng.next_double() * np.to_double()).to_int()
      }
      let mut r2 = (rng.next_double() * np.to_double()).to_int()
      while r2 == i || r2 == r1 {
        r2 = (rng.next_double() * np.to_double()).to_int()
      }
      let mut r3 = (rng.next_double() * np.to_double()).to_int()
      while r3 == i || r3 == r1 || r3 == r2 {
        r3 = (rng.next_double() * np.to_double()).to_int()
      }

      let j_rand = (rng.next_double() * num_params.to_double()).to_int()
      let trial = Array::new(capacity=num_params)

      for j = 0; j < num_params; j = j + 1 {
        let b = param_bounds[j]
        let mut val = pop[i][j]

        if rng.next_double() < settings.crossover_prob_cr || j == j_rand {
          // Mutation: v_j = x_r1 + F * (x_r2 - x_r3)
          val = pop[r1][j] +
            settings.mutation_factor_f * (pop[r2][j] - pop[r3][j])
        }

        if val < b.min_val {
          val = b.min_val
        } else if val > b.max_val {
          val = b.max_val
        }
        trial.push(val)
      }

      // Selection
      let trial_fit = fitness_fn(trial)
      if trial_fit <= fitness[i] {
        pop[i] = trial
        fitness[i] = trial_fit

        if trial_fit < best_fit {
          best_fit = trial_fit
          best_sol = pop[i].copy()
        }
      }
    }
  }

  best_sol
}
