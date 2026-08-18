///|
test "opv organic solar cell simulation" {
  let grid = @core.SpectrumGrid::solar_spectrum(31)
  let opv = OPVCellDesign::new(120.0, 30.0, 100.0, 5.0, 100.0)
  let res = opv.simulate_opv(grid)

  assert_true(res.short_circuit_current_ma_cm2 > 5.0)
  assert_true(res.active_layer_photons_absorbed > 0.30)
}

///|
test "low e glazing performance evaluation" {
  let grid = @core.SpectrumGrid::linear(400.0, 1000.0, 31)
  let low_e = LowEGlazingDesign::new(12.0, 30.0, 35.0, 16.0)
  let metrics = low_e.evaluate_glazing(grid)

  assert_true(metrics.visible_transmittance_tv > 0.50)
  assert_true(metrics.thermal_emissivity_ir < 0.10)
  assert_true(metrics.u_value_w_m2k < 2.0)
}
