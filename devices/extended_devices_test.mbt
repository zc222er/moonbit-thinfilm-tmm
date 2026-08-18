///|
test "tandem solar cell current matching simulation" {
  let grid = @core.SpectrumGrid::solar_spectrum(41)
  let tandem = TandemSolarCell::new(450.0, 200.0, 100.0, 20.0)
  let res = tandem.simulate_current_matching(grid)

  // Tandem current should be positive (> 5 mA/cm^2)
  assert_true(res.j_matched_2t_ma_cm2 > 5.0)
  assert_true(res.j_top_ma_cm2 > 0.0)
  assert_true(res.j_bottom_ma_cm2 > 0.0)
}

///|
test "surface plasmon resonance angular dip and sensitivity" {
  let bk7 = @mat.bk7()
  let gold = @mat.gold()
  let spr = SPRSensorDesign::new(bk7, gold, 48.0, None, 632.8)

  // Scan in water (n = 1.333)
  let scan = spr.scan_angle(1.333, 40.0, 75.0, 300)

  // Gold SPR dip angle in BK7/Water at 633nm is typically ~ 43 - 60 degrees
  assert_true(
    scan.resonance_angle_deg > 41.0 && scan.resonance_angle_deg < 75.0,
  )
  assert_true(scan.minimum_reflectance < 0.60)

  // Sensitivity d_theta / dn should be positive
  let s_theta = spr.calculate_sensitivity(1.333, 0.01)
  assert_true(s_theta > 10.0)
}

///|
test "liquid crystal cell phase retardation" {
  // 4 um cell gap, 5CB liquid crystal (no=1.53, ne=1.71, Delta_n=0.18)
  let lc = LiquidCrystalCell::new(4.0, 1.53, 1.71, 90.0, 2.0)
  let retard = lc.optical_retardation_rad(550.0)

  // Retardation = 2 * pi * 0.18 * 4000 / 550 ~ 8.2 rad
  assert_true(retard > 7.0 && retard < 10.0)
}
