///|
test "bayesian mcmc metropolis hastings sampling" {
  let target_quadratic = fn(p : Array[Double]) -> Array[Double] {
    let r1 = p[0] - 1.5
    let r2 = p[1] - 3.2
    [r1, r2]
  }

  let bounds = [
    ParameterBound::new("p1", -5.0, 5.0, 1.2),
    ParameterBound::new("p2", -5.0, 5.0, 3.0),
  ]

  let settings : MCMCSettings = {
    num_samples: 400,
    burn_in: 100,
    proposal_step_std: 0.1,
    likelihood_noise_sigma: 0.1,
  }

  let mcmc_res = run_mcmc_bayesian_inversion(
    target_quadratic,
    [1.2, 3.0],
    bounds,
    settings,
  )

  assert_true(mcmc_res.sample_chain.length() > 0)
  assert_true((mcmc_res.mean_parameters[0] - 1.5).abs() < 0.3)
  assert_true((mcmc_res.mean_parameters[1] - 3.2).abs() < 0.3)
}
