///|
test "lu chipman mueller decomposition" {
  let m_id = MuellerMatrix::identity()
  let decomp = decompose_mueller_matrix(m_id)

  assert_true((decomp.diattenuation - 0.0).abs() < 1.0e-5)
  assert_true((decomp.depolarization_index - 1.0).abs() < 1.0e-5)
  assert_true((decomp.polarimetric_entropy - 0.0).abs() < 1.0e-5)
}
