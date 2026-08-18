///|
/// Parameter bounds for constrained non-linear optimization
pub struct ParameterBound {
  name : String
  min_val : Double
  max_val : Double
  initial_guess : Double
} derive(Eq)

///|
pub fn ParameterBound::new(
  name : String,
  min_val : Double,
  max_val : Double,
  initial_guess : Double,
) -> ParameterBound {
  { name, min_val, max_val, initial_guess }
}

///|
/// Calculate Numerical Jacobian Matrix (M residuals x N parameters) using central difference
pub fn compute_jacobian(
  residual_fn : (Array[Double]) -> Array[Double],
  params : Array[Double],
  step_size : Double,
) -> @linalg.Matrix {
  let r0 = residual_fn(params)
  let m = r0.length()
  let n = params.length()
  let jac = @linalg.Matrix::zeros(m, n)

  for j = 0; j < n; j = j + 1 {
    let p_plus = params.copy()
    let p_minus = params.copy()
    let dp = if params[j].abs() > 1.0e-5 {
      params[j] * step_size
    } else {
      step_size
    }

    p_plus[j] = p_plus[j] + dp
    p_minus[j] = p_minus[j] - dp

    let r_plus = residual_fn(p_plus)
    let r_minus = residual_fn(p_minus)

    let two_dp = 2.0 * dp
    for i = 0; i < m; i = i + 1 {
      jac.set(i, j, (r_plus[i] - r_minus[i]) / two_dp)
    }
  }

  jac
}

///|
/// Compute Mean Squared Error of residual vector
pub fn compute_mse(residuals : Array[Double]) -> Double {
  let n = residuals.length()
  if n == 0 {
    return 0.0
  }
  let mut sum_sq = 0.0
  for r in residuals {
    sum_sq = sum_sq + r * r
  }
  sum_sq / n.to_double()
}

///|
/// Levenberg-Marquardt Non-Linear Least Squares Optimization Algorithm
pub fn levenberg_marquardt(
  residual_fn : (Array[Double]) -> Array[Double],
  initial_params : Array[Double],
  param_bounds : Array[ParameterBound],
  max_iterations : Int,
  tolerance : Double,
) -> @core.InversionResult {
  let num_params = initial_params.length()
  let mut current_params = initial_params.copy()
  let mut current_residuals = residual_fn(current_params)
  let mut current_mse = compute_mse(current_residuals)

  let mut lambda_damp = 0.001
  let mut iter = 0
  let mut converged = false

  while iter < max_iterations && !converged {
    iter = iter + 1

    if current_mse < tolerance {
      converged = true
      break
    }

    // 1. Calculate Jacobian J (M x N)
    let jac = compute_jacobian(residual_fn, current_params, 1.0e-5)
    let jac_t = jac.transpose()

    // 2. Normal equations: (J^T * J + lambda * diag(J^T * J)) * dp = -J^T * r
    let jtj = jac_t.mul(jac)
    let jtr = jac_t.mul_vec(current_residuals)

    // Add damping to diagonal
    let jtj_damped = jtj.clone()
    for j = 0; j < num_params; j = j + 1 {
      let diag_val = jtj.get(j, j)
      let diag_add = if diag_val > 1.0e-8 {
        diag_val * lambda_damp
      } else {
        lambda_damp
      }
      jtj_damped.set(j, j, diag_val + diag_add)
    }

    // Solve for step dp: jtj_damped * dp = -jtr
    let neg_jtr = Array::new(capacity=num_params)
    for v in jtr {
      neg_jtr.push(-v)
    }

    let lu = jtj_damped.lu_decompose()
    let dp = lu.solve(neg_jtr)

    // Check step norm
    let mut step_norm = 0.0
    for delta in dp {
      step_norm = step_norm + delta * delta
    }
    step_norm = step_norm.sqrt()

    if step_norm < 1.0e-9 {
      converged = true
      break
    }

    // Trial update: p_trial = p + dp, clamped to bounds
    let trial_params = current_params.copy()
    for j = 0; j < num_params; j = j + 1 {
      let mut val = current_params[j] + dp[j]
      if j < param_bounds.length() {
        if val < param_bounds[j].min_val {
          val = param_bounds[j].min_val
        }
        if val > param_bounds[j].max_val {
          val = param_bounds[j].max_val
        }
      }
      trial_params[j] = val
    }

    let trial_residuals = residual_fn(trial_params)
    let trial_mse = compute_mse(trial_residuals)

    if trial_mse < current_mse {
      let diff_mse = current_mse - trial_mse
      current_params = trial_params
      current_residuals = trial_residuals
      current_mse = trial_mse
      lambda_damp = lambda_damp * 0.2

      if diff_mse < 1.0e-12 || current_mse < tolerance {
        converged = true
      }
    } else {
      lambda_damp = lambda_damp * 8.0
      if lambda_damp > 1.0e14 {
        break
      }
    }
  }

  // Calculate parameter standard uncertainties from covariance matrix C = s^2 * (J^T J)^(-1)
  let final_jac = compute_jacobian(residual_fn, current_params, 1.0e-5)
  let final_jtj = final_jac.transpose().mul(final_jac)
  let jtj_inv = final_jtj.inv()

  let uncertainties = Array::new(capacity=num_params)
  let names = Array::new(capacity=num_params)
  for j = 0; j < num_params; j = j + 1 {
    let name = if j < param_bounds.length() {
      param_bounds[j].name
    } else {
      "Param\{j}"
    }
    names.push(name)
    let var_val = (current_mse * jtj_inv.get(j, j)).abs()
    uncertainties.push(var_val.sqrt())
  }

  let msg = if converged || current_mse < 1.0e-4 {
    "Converged successfully"
  } else {
    "Reached maximum iterations"
  }
  let is_conv = converged || current_mse < 1.0e-4

  {
    converged: is_conv,
    iterations: iter,
    final_residual_mse: current_mse,
    optimized_parameters: current_params,
    parameter_names: names,
    uncertainties,
    message: msg,
  }
}

///|
/// Differential Evolution (DE) Global Optimizer for multi-parameter thin film fitting
pub fn differential_evolution(
  fitness_fn : (Array[Double]) -> Double,
  param_bounds : Array[ParameterBound],
  population_size : Int,
  generations : Int,
  f_weight : Double,
  crossover_prob : Double,
) -> Array[Double] {
  let num_params = param_bounds.length()
  let pop_size = if population_size < 10 { 15 } else { population_size }
  let rng = @linalg.Rng::new(987654321UL)

  // 1. Initialize population randomly within bounds
  let population = Array::new(capacity=pop_size)
  let fitness = Array::new(capacity=pop_size)

  for _i = 0; _i < pop_size; _i = _i + 1 {
    let individual = Array::new(capacity=num_params)
    for j = 0; j < num_params; j = j + 1 {
      let b = param_bounds[j]
      individual.push(rng.next_range(b.min_val, b.max_val))
    }
    let fit = fitness_fn(individual)
    population.push(individual)
    fitness.push(fit)
  }

  // 2. Evolution loop (Mutation + Crossover + Selection)
  for _gen = 0; _gen < generations; _gen = _gen + 1 {
    for i = 0; i < pop_size; i = i + 1 {
      let mut a = (rng.next_double() * pop_size.to_double()).to_int()
      while a == i {
        a = (rng.next_double() * pop_size.to_double()).to_int()
      }
      let mut b = (rng.next_double() * pop_size.to_double()).to_int()
      while b == i || b == a {
        b = (rng.next_double() * pop_size.to_double()).to_int()
      }
      let mut c = (rng.next_double() * pop_size.to_double()).to_int()
      while c == i || c == a || c == b {
        c = (rng.next_double() * pop_size.to_double()).to_int()
      }

      let trial = Array::new(capacity=num_params)
      let r_param = (rng.next_double() * num_params.to_double()).to_int()

      for j = 0; j < num_params; j = j + 1 {
        let rand_j = rng.next_double()
        let b_j = param_bounds[j]
        let mut val = population[i][j]

        if rand_j < crossover_prob || j == r_param {
          let mutated = population[a][j] +
            f_weight * (population[b][j] - population[c][j])
          if mutated < b_j.min_val {
            val = b_j.min_val
          } else if mutated > b_j.max_val {
            val = b_j.max_val
          } else {
            val = mutated
          }
        }
        trial.push(val)
      }

      let trial_fit = fitness_fn(trial)
      if trial_fit < fitness[i] {
        population[i] = trial
        fitness[i] = trial_fit
      }
    }
  }

  let mut best_idx = 0
  let mut best_fit = fitness[0]
  for i = 1; i < pop_size; i = i + 1 {
    if fitness[i] < best_fit {
      best_fit = fitness[i]
      best_idx = i
    }
  }

  population[best_idx].copy()
}
