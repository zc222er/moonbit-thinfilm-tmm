///|
test "pancharatnam achromatic half wave plate retardance" {
  let ahwp = PancharatnamAchromaticWaveplate::achromatic_half_wave_plate()
  let r_550 = ahwp.calculate_effective_retardance_deg(550.0)

  // Retardance at design wavelength should be 180 degrees
  assert_true((r_550 - 180.0).abs() < 1.0)

  // Retardance at broadband 450nm and 700nm should remain close to 180 degrees
  let r_450 = ahwp.calculate_effective_retardance_deg(450.0)
  let r_700 = ahwp.calculate_effective_retardance_deg(700.0)
  assert_true(r_450 > 165.0 && r_450 < 195.0)
  assert_true(r_700 > 165.0 && r_700 < 195.0)
}
