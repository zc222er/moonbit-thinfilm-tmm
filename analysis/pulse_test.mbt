///|
test "ultrafast pulse dispersion broadening" {
  let pulse = UltrafastPulseProfile::new(20.0, 800.0) // 20 fs pulse
  // Reflect from mirror with GDD = 500 fs^2
  let res = pulse.calculate_broadening(500.0)

  // Pulse should broaden (tau_out > 20 fs)
  assert_true(res.output_duration_fwhm_fs > 20.0)
  assert_true(res.broadening_ratio > 1.0)
  assert_true(res.peak_intensity_ratio < 1.0)
}
