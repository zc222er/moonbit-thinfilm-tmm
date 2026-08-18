///|
test "super achromat design initialization" {
  let sa = SuperAchromatDesign::standard_five_element_quarter_wave()
  assert_eq(sa.plates_azimuths.length(), 5)
  assert_true((sa.target_retardance_deg - 90.0).abs() < 1.0e-5)
}

///|
test "multi cavity dwdm bandpass shape factor" {
  let dwdm = MultiCavityBandpassDesign::telecom_dense_wdm_100ghz()
  let sf = dwdm.calculate_shape_factor()

  // 3-cavity shape factor should be ~ 0.79
  assert_true(sf > 0.70 && sf < 0.90)
}
