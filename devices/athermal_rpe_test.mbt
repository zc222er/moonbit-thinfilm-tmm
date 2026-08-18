///|
test "athermal filter thermal drift" {
  let tio2 = @mat.titanium_dioxide()
  let sio2 = @mat.fused_silica()
  let athermal = AthermalFilterDesign::new(1550.0, 50.0, tio2, sio2, 0.55)

  let drift = athermal.calculate_thermal_wavelength_drift_pm_k(-25.0, 2.1)
  assert_true(drift.abs() < 100.0)
}

///|
test "rotating polarizer ellipsometer harmonic simulation" {
  let rpe = RotatingPolarizerEllipsometer::new(45.0, 50.0)
  let harmonics = rpe.simulate_harmonics(30.0, 90.0)

  // Reconstructed angles should match input sample
  assert_true((harmonics.psi_reconstructed_deg - 30.0).abs() < 0.1)
  assert_true((harmonics.delta_reconstructed_deg - 90.0).abs() < 0.1)
}
