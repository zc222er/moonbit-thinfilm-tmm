///|
test "jones calculus quarter wave plate transformation" {
  let vin = JonesVector::linear_horizontal()
  let qwp = JonesMatrix::quarter_wave_plate_fast_axis_x()
  let vout = qwp.apply(vin)

  // Magnitude of components should be preserved
  let mag2 = vout.ex.norm_sq() + vout.ey.norm_sq()
  assert_true((mag2 - 1.0).abs() < 1.0e-5)
}
