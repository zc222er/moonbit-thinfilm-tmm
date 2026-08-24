///|
test "levenberg marquardt single layer thickness inversion" {
  let air = @mat.air().to_layer(0.0, 550.0)
  let true_film = @core.Layer::real("TrueFilm", 100.0, 2.0)
  let glass_sub = @core.Layer::real("Glass", 0.0, 1.5)
  let true_stack = @core.MultiLayerStack::new(air, [true_film], glass_sub)

  let grid = @core.SpectrumGrid::linear(400.0, 800.0, 31)
  let sim = @tmm.solve_spectrum(true_stack, grid, @core.IncidentAngle::normal())

  // Invert starting from guess: d_0 = 90.0 nm, n_0 = 1.95
  let inv_res = fit_single_layer_rn(glass_sub, sim.reflectance, 90.0, 1.95)

  assert_true(inv_res.converged)
  let fitted_d = inv_res.optimized_parameters[0]
  let fitted_n = inv_res.optimized_parameters[1]

  // Check residual MSE is small (< 1e-4)
  assert_true(inv_res.final_residual_mse < 1.0e-4)
  assert_true((fitted_d - 100.0).abs() < 2.0)
  assert_true((fitted_n - 2.0).abs() < 0.1)
}

///|
test "differential evolution global search" {
  let sphere = fn(p : Array[Double]) -> Double {
    let x = p[0] - 3.5
    let y = p[1] - 7.2
    x * x + y * y
  }

  let bounds = [
    ParameterBound::new("x", -10.0, 10.0, 0.0),
    ParameterBound::new("y", -10.0, 10.0, 0.0),
  ]

  let best = differential_evolution(sphere, bounds, 20, 50, 0.8, 0.9)
  assert_true((best[0] - 3.5).abs() < 0.1)
  assert_true((best[1] - 7.2).abs() < 0.1)
}

///|
test "differential evolution keeps bounded parameters" {
  let objective = fn(p : Array[Double]) -> Double {
    let x = p[0] - 0.25
    x * x
  }
  let bounds = [ParameterBound::new("x", -0.5, 0.5, 0.0)]
  let best = differential_evolution(objective, bounds, 2, 4, 0.8, 0.9)
  assert_true(best.length() == 1)
  assert_true(best[0] >= -0.5 && best[0] <= 0.5)
  assert_true(!best[0].is_nan() && !best[0].is_inf())
}
