///|
test "whale optimization algorithm on sphere function" {
  let sphere = fn(p : Array[Double]) -> Double {
    let x = p[0] - 1.6
    let y = p[1] - 3.2
    x * x + y * y
  }

  let bounds = [
    ParameterBound::new("x", -10.0, 10.0, 0.0),
    ParameterBound::new("y", -10.0, 10.0, 0.0),
  ]

  let best = whale_optimize(sphere, bounds, WOASettings::default())
  assert_true((best[0] - 1.6).abs() < 0.2)
  assert_true((best[1] - 3.2).abs() < 0.2)
}
