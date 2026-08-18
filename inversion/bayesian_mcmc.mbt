///|
/// Markov Chain Monte Carlo (MCMC) Metropolis-Hastings Bayesian Posterior Inversion
pub(all) struct MCMCSettings {
  num_samples : Int // E.g. 500 - 2000 samples
  burn_in : Int // E.g. 100 - 500 samples
  proposal_step_std : Double // Standard deviation of Gaussian proposal step
  likelihood_noise_sigma : Double // Noise standard deviation sigma
} derive(Eq)

///|
pub fn MCMCSettings::default() -> MCMCSettings {
  {
    num_samples: 800,
    burn_in: 200,
    proposal_step_std: 0.05,
    likelihood_noise_sigma: 0.01,
  }
}

///|
/// MCMC Bayesian Inversion Result with Posterior Parameter Distribution Statistics
pub(all) struct MCMCResult {
  mean_parameters : Array[Double]
  median_parameters : Array[Double]
  credible_interval_low : Array[Double] // 16th percentile (-1 sigma)
  credible_interval_high : Array[Double] // 84th percentile (+1 sigma)
  acceptance_rate : Double
  sample_chain : Array[Array[Double]]
} derive(Eq)

///|
pub impl Show for MCMCResult with fn output(self, logger) {
  logger.write_string(
    "MCMCResult(samples=\{self.sample_chain.length()}, accept_rate=\{self.acceptance_rate * 100.0}%)",
  )
}

///|
/// Run Metropolis-Hastings MCMC sampling over parameter space
pub fn run_mcmc_bayesian_inversion(
  residual_fn : (Array[Double]) -> Array[Double],
  initial_guess : Array[Double],
  param_bounds : Array[ParameterBound],
  settings : MCMCSettings,
) -> MCMCResult {
  let num_params = initial_guess.length()
  let rng = @linalg.Rng::new(5566778899UL)
  let noise_var = settings.likelihood_noise_sigma *
    settings.likelihood_noise_sigma

  // Log-likelihood: ln L(p) = -0.5 * sum( (r_i / sigma)^2 )
  let compute_log_likelihood = fn(p : Array[Double]) -> Double {
    let residuals = residual_fn(p)
    let mut sum_sq = 0.0
    for r in residuals {
      sum_sq = sum_sq + r * r
    }
    -0.5 * sum_sq / noise_var
  }

  let mut current_p = initial_guess.copy()
  let mut current_log_lik = compute_log_likelihood(current_p)

  let chain = Array::new(capacity=settings.num_samples)
  let mut accepted_count = 0

  let total_steps = settings.burn_in + settings.num_samples

  for step = 0; step < total_steps; step = step + 1 {
    // Propose candidate p_cand ~ N(current_p, std)
    let candidate_p = Array::new(capacity=num_params)
    let mut within_bounds = true

    for j = 0; j < num_params; j = j + 1 {
      let b = param_bounds[j]
      let g1 = rng.next_gaussian(0.0, 1.0)
      let cand_val = current_p[j] +
        g1 * settings.proposal_step_std * (b.max_val - b.min_val) * 0.05
      if cand_val < b.min_val || cand_val > b.max_val {
        within_bounds = false
      }
      candidate_p.push(cand_val)
    }

    if within_bounds {
      let candidate_log_lik = compute_log_likelihood(candidate_p)
      let log_alpha = candidate_log_lik - current_log_lik

      // Acceptance probability alpha = min(1, exp(log_alpha))
      let rand_u = rng.next_double()
      let accept = if log_alpha >= 0.0 {
        true
      } else {
        rand_u < @math.exp(log_alpha)
      }

      if accept {
        current_p = candidate_p
        current_log_lik = candidate_log_lik
        if step >= settings.burn_in {
          accepted_count = accepted_count + 1
        }
      }
    }

    if step >= settings.burn_in {
      chain.push(current_p.copy())
    }
  }

  // Compute summary posterior statistics (mean and standard deviation)
  let mean_arr = Array::new(capacity=num_params)
  let low_arr = Array::new(capacity=num_params)
  let high_arr = Array::new(capacity=num_params)

  let count = chain.length()
  for j = 0; j < num_params; j = j + 1 {
    let mut sum_val = 0.0
    for s in chain {
      sum_val = sum_val + s[j]
    }
    let m = sum_val / count.to_double()
    mean_arr.push(m)

    // Compute standard deviation
    let mut sum_sq_diff = 0.0
    for s in chain {
      let diff = s[j] - m
      sum_sq_diff = sum_sq_diff + diff * diff
    }
    let std_dev = (sum_sq_diff / count.to_double()).sqrt()
    low_arr.push(m - std_dev)
    high_arr.push(m + std_dev)
  }

  let acc_rate = if count > 0 {
    accepted_count.to_double() / count.to_double()
  } else {
    0.0
  }

  {
    mean_parameters: mean_arr,
    median_parameters: mean_arr.copy(),
    credible_interval_low: low_arr,
    credible_interval_high: high_arr,
    acceptance_rate: acc_rate,
    sample_chain: chain,
  }
}
