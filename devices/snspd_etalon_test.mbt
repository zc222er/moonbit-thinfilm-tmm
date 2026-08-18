///|
test "snspd optical cavity absorption" {
  let snspd = SNSPDCavityDesign::standard_telecom_1550nm()
  let res = snspd.calculate_optical_performance()

  assert_true(
    res.nanowire_optical_absorption >= 0.0 &&
    res.nanowire_optical_absorption <= 1.0,
  )
  assert_true(
    res.system_detection_efficiency_estimate >= 0.0 &&
    res.system_detection_efficiency_estimate <= 1.0,
  )
}

///|
test "fabry perot etalon finesse and fsr" {
  // Gap = 100 um, R = 0.95
  let etalon = FabryPerotEtalon::new(100.0, 1.0, 0.95)
  let metrics = etalon.evaluate_etalon(1550.0)

  // Finesse F = pi * sqrt(0.95) / 0.05 ~ 61.2
  assert_true(metrics.finesse > 50.0 && metrics.finesse < 70.0)
  assert_true(
    metrics.free_spectral_range_nm > 5.0 &&
    metrics.free_spectral_range_nm < 20.0,
  )
}
