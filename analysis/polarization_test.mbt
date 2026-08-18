///|
test "stokes vector degree of polarization" {
  let s_lin = StokesVector::linear_horizontal(2.0)
  assert_true((s_lin.degree_of_polarization() - 1.0).abs() < 1.0e-6)
  assert_true((s_lin.degree_of_linear_polarization() - 1.0).abs() < 1.0e-6)
  assert_true((s_lin.degree_of_circular_polarization() - 0.0).abs() < 1.0e-6)

  let s_unpol = StokesVector::unpolarized(5.0)
  assert_true((s_unpol.degree_of_polarization() - 0.0).abs() < 1.0e-6)
}

///|
test "mueller matrix identity transform" {
  let m_id = MuellerMatrix::identity()
  let s_in = StokesVector::circular_right(1.5)
  let s_out = m_id.transform(s_in)

  assert_true((s_out.s0 - s_in.s0).abs() < 1.0e-6)
  assert_true((s_out.s3 - s_in.s3).abs() < 1.0e-6)
}
