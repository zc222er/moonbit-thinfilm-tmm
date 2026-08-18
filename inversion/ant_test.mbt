///|
test "ant colony continuous optimization" {
  let sphere = fn(p : Array[Double]) -> Double {
    let x = p[0] - 1.2
    let y = p[1] - 2.8
    x * x + y * y
  }

  let bounds = [
    ParameterBound::new("x", -10.0, 10.0, 0.0),
    ParameterBound::new("y", -10.0, 10.0, 0.0),
  ]

  let best = ant_colony_optimize(sphere, bounds, ACORSettings::default())
  assert_true((best[0] - 1.2).abs() < 0.2)
  assert_true((best[1] - 2.8).abs() < 0.2)
}
