///|
test "particle swarm optimization convergence" {
  let rastrigin = fn(p : Array[Double]) -> Double {
    let x = p[0] - 2.0
    let y = p[1] - 4.0
    x * x + y * y
  }

  let bounds = [
    ParameterBound::new("x", -10.0, 10.0, 0.0),
    ParameterBound::new("y", -10.0, 10.0, 0.0),
  ]

  let best = particle_swarm_optimize(rastrigin, bounds, PSOSettings::default())
  assert_true((best[0] - 2.0).abs() < 0.1)
  assert_true((best[1] - 4.0).abs() < 0.1)
}
