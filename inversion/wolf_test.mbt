///|
test "grey wolf optimizer on sphere function" {
  let sphere = fn(p : Array[Double]) -> Double {
    let x = p[0] - 2.1
    let y = p[1] - 3.7
    x * x + y * y
  }

  let bounds = [
    ParameterBound::new("x", -10.0, 10.0, 0.0),
    ParameterBound::new("y", -10.0, 10.0, 0.0),
  ]

  let best = grey_wolf_optimize(sphere, bounds, GWOSettings::default())
  assert_true((best[0] - 2.1).abs() < 0.2)
  assert_true((best[1] - 3.7).abs() < 0.2)
}
