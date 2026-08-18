///|
test "simulated annealing quadratic function" {
  let sphere = fn(p : Array[Double]) -> Double {
    let x = p[0] - 1.8
    let y = p[1] - 3.4
    x * x + y * y
  }

  let bounds = [
    ParameterBound::new("x", -10.0, 10.0, 0.0),
    ParameterBound::new("y", -10.0, 10.0, 0.0),
  ]

  let best = simulated_annealing_optimize(
    sphere,
    [0.0, 0.0],
    bounds,
    AnnealingSettings::default(),
  )
  assert_true((best[0] - 1.8).abs() < 0.2)
  assert_true((best[1] - 3.4).abs() < 0.2)
}
