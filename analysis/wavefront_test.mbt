///|
test "wavefront aberration and strehl ratio" {
  // Test flat wavefront
  let phases = [0.0, 0.0, 0.0, 0.0, 0.0]
  let wf = calculate_angular_wavefront_aberration(phases, 500.0)

  assert_true((wf.strehl_ratio - 1.0).abs() < 1.0e-5)
  assert_true((wf.rms_opd_nm - 0.0).abs() < 1.0e-5)

  // Test slightly deformed wavefront (10 deg phase ripples)
  let phases_distorted = [0.0, 5.0, 10.0, 5.0, 0.0]
  let wf_dist = calculate_angular_wavefront_aberration(phases_distorted, 500.0)
  assert_true(wf_dist.strehl_ratio < 1.0 && wf_dist.strehl_ratio > 0.90)
  assert_true(wf_dist.peak_to_valley_opd_nm > 0.0)
}
