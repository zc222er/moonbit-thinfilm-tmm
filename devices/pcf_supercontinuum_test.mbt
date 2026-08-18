///|
test "pcf endlessly single mode criterion" {
  let silica = @mat.fused_silica()
  let pcf_esm = @mat.PCFCladdingGeometry::new(2.5, 0.40, silica)
  let pcf_multimode = @mat.PCFCladdingGeometry::new(2.5, 0.65, silica)

  assert_true(pcf_esm.is_endlessly_single_mode())
  assert_true(!pcf_multimode.is_endlessly_single_mode())
}

///|
test "pcf nonlinear parameter and spm phase shift" {
  let source = PCFSupercontinuumSource::new(1.0, 2.6e-20, 4.0, 5000.0) // 5 kW pump
  let gamma = source.calculate_nonlinear_parameter_gamma(800.0)

  // gamma for 4 um^2 PCF at 800nm is ~ 0.05 (W * m)^-1
  assert_true(gamma > 0.01)

  let phi_nl = source.calculate_spm_phase_shift_rad(800.0)
  assert_true(phi_nl > 10.0)
}
