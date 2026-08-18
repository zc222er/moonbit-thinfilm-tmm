///|
test "fiber bragg grating resonance and reflectivity" {
  let fbg = FiberBraggGrating::new(535.0, 10.0, 1.448, 5.0e-4)
  let lambda_b = fbg.calculate_bragg_wavelength_nm()

  // Bragg wavelength ~ 2 * 1.448 * 535 = 1549.36 nm
  assert_true(lambda_b > 1545.0 && lambda_b < 1555.0)

  let r_peak = fbg.calculate_peak_reflectivity()
  assert_true(r_peak > 0.90 && r_peak <= 1.0)
}
