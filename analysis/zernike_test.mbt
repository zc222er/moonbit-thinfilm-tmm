///|
test "zernike polynomials opd evaluation" {
  let z = ZernikeAberrationCoefficients::zeros()
  z.defocus_c3 = 50.0 // 50 nm defocus aberration
  z.spherical_c8 = 20.0 // 20 nm spherical aberration

  let opd_center = z.evaluate_opd(0.0, 0.0)
  let rms = z.calculate_rms_error_nm()

  assert_true(rms > 50.0)
  assert_true(opd_center.abs() > 0.0)
}
