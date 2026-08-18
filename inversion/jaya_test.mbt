///|
test "jaya parameterless optimization on sphere function" {
  let sphere = fn(p : Array[Double]) -> Double {
    let x = p[0] - 1.4
    let y = p[1] - 2.6
    x * x + y * y
  }

  let bounds = [
    ParameterBound::new("x", -10.0, 10.0, 0.0),
    ParameterBound::new("y", -10.0, 10.0, 0.0),
  ]

  let best = jaya_optimize(sphere, bounds, JayaSettings::default())
  assert_true((best[0] - 1.4).abs() < 0.2)
  assert_true((best[1] - 2.6).abs() < 0.2)
}
