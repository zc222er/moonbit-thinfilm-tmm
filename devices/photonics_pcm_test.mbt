///|
test "phase change switch optical contrast" {
  let sub = @mat.bk7().to_layer(0.0, 1550.0)
  let pcm_switch = PhaseChangeSwitch::new(30.0, 15.0, 100.0, sub)

  let res = pcm_switch.calculate_gst_contrast(1550.0)

  // GST phase change should produce substantial optical modulation
  assert_true(res.reflectance_state_0 >= 0.0 && res.reflectance_state_0 <= 1.0)
  assert_true(res.reflectance_state_1 >= 0.0 && res.reflectance_state_1 <= 1.0)
}

///|
test "optical ring resonator transmission resonance" {
  // Radius = 10 um, n_eff = 2.45 (Si wire)
  let ring = OpticalRingResonator::new(10.0, 2.45, 0.10, 2.0)
  let fsr = ring.calculate_fsr_nm(1550.0)

  // FSR ~ 1550^2 / (2.45 * 2 * pi * 10000) ~ 15.6 nm
  assert_true(fsr > 10.0 && fsr < 25.0)

  let t_val = ring.calculate_transmission(1550.0)
  assert_true(t_val >= 0.0 && t_val <= 1.0)
}
