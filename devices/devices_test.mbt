///|
test "dbr mirror stopband and peak reflectance" {
  let tio2 = @mat.titanium_dioxide()
  let sio2 = @mat.fused_silica()
  let glass = @mat.bk7().to_layer(0.0, 600.0)

  // 10 pairs DBR at 600 nm
  let dbr = DBRDesign::new(600.0, 10, tio2, sio2, glass)
  let stack = dbr.build_stack()

  // 1. Analytical stopband width should be > 100 nm (due to high index contrast 2.48 vs 1.46)
  let stopband_w = dbr.analytical_stopband_width()
  assert_true(stopband_w > 120.0 && stopband_w < 250.0)

  // 2. Center wavelength reflectance should be > 99%
  let res_center = @tmm.solve_tmm2d_single(
    stack,
    600.0,
    @core.IncidentAngle::normal(),
  )
  assert_true(res_center.r_power > 0.99)
}

///|
test "fabry perot filter narrow transmission resonance" {
  let tio2 = @mat.titanium_dioxide()
  let sio2 = @mat.fused_silica()
  let glass = @mat.bk7().to_layer(0.0, 500.0)

  // 4 pairs top/bottom with SiO2 cavity (half-wave spacer)
  let fp = FabryPerotFilter::new(500.0, 4, 1, tio2, sio2, sio2, glass)
  let stack = fp.build_stack()

  let res_peak = @tmm.solve_tmm2d_single(
    stack,
    500.0,
    @core.IncidentAngle::normal(),
  )
  let res_off = @tmm.solve_tmm2d_single(
    stack,
    480.0,
    @core.IncidentAngle::normal(),
  )

  // Transmission at resonance must be significantly higher than off-resonance
  assert_true(res_peak.t_power > res_off.t_power)
  assert_true(res_off.r_power > 0.80)
}

///|
test "solar cell jsc integration under am15g" {
  let grid = @core.SpectrumGrid::solar_spectrum(50)
  let solar_stack = create_perovskite_solar_cell(350.0, 550.0)

  let solar_res = calculate_solar_cell_jsc(solar_stack, 2, grid)

  // Typical perovskite solar cell Jsc is ~ 15 - 25 mA/cm^2
  assert_true(solar_res.short_circuit_current_ma_cm2 > 10.0)
  assert_true(solar_res.integrated_absorption_fraction > 0.5)
}
