///|
test "differential evolution on sphere function" {
  let sphere = fn(p : Array[Double]) -> Double {
    let x = p[0] - 1.7
    let y = p[1] - 3.1
    x * x + y * y
  }

  let bounds = [
    ParameterBound::new("x", -10.0, 10.0, 0.0),
    ParameterBound::new("y", -10.0, 10.0, 0.0),
  ]

  let best = differential_evolution_optimize(
    sphere,
    bounds,
    DESettings::default(),
  )
  assert_true((best[0] - 1.7).abs() < 0.2)
  assert_true((best[1] - 3.1).abs() < 0.2)
}
