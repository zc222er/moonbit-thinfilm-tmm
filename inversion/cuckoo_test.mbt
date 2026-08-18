///|
test "cuckoo search optimization convergence" {
  let sphere = fn(p : Array[Double]) -> Double {
    let x = p[0] - 2.5
    let y = p[1] - 4.5
    x * x + y * y
  }

  let bounds = [
    ParameterBound::new("x", -10.0, 10.0, 0.0),
    ParameterBound::new("y", -10.0, 10.0, 0.0),
  ]

  let best = cuckoo_search_optimize(sphere, bounds, CuckooSettings::default())
  assert_true((best[0] - 2.5).abs() < 0.2)
  assert_true((best[1] - 4.5).abs() < 0.2)
}
