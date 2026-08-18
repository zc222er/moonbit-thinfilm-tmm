///|
test "sine cosine algorithm on sphere function" {
  let sphere = fn(p : Array[Double]) -> Double {
    let x = p[0] - 1.3
    let y = p[1] - 2.7
    x * x + y * y
  }

  let bounds = [
    ParameterBound::new("x", -10.0, 10.0, 0.0),
    ParameterBound::new("y", -10.0, 10.0, 0.0),
  ]

  let best = sine_cosine_optimize(sphere, bounds, SCASettings::default())
  assert_true((best[0] - 1.3).abs() < 0.2)
  assert_true((best[1] - 2.7).abs() < 0.2)
}
