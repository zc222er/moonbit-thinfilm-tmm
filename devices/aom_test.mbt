///|
test "acousto optic modulator bragg angle and efficiency" {
  let teo2 = @mat.teo2_paratellurite_acousto_optic()
  let aom = AcoustoOpticModulator::new(teo2, 10.0, 2.0, 80.0) // 80 MHz RF drive

  let theta_b = aom.calculate_bragg_angle_deg(632.8)
  assert_true(theta_b > 0.5 && theta_b < 5.0)

  let eta = aom.calculate_diffraction_efficiency(632.8, 1.0)
  assert_true(eta >= 0.0 && eta <= 1.0)
}
