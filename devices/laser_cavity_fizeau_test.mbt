///|
test "solid state dpssl laser cavity performance" {
  let nd_yag = @mat.nd_yag_laser_gain()
  let cavity = SolidStateLaserCavity::new(nd_yag, 5.0, 0.95, 0.02, 150.0)

  let metrics = cavity.calculate_laser_performance(0.25)
  assert_true(metrics.threshold_pump_power_mw > 10.0)
  assert_true(metrics.slope_efficiency_percent > 20.0)
}

///|
test "fizeau interferometer fringe intensity" {
  let fizeau = FizeauInterferometer::new(632.8, 0.04, 2.0, 0.0)
  let i_center = fizeau.calculate_fringe_intensity(0.0, 0.0, 0.0)

  assert_true(i_center >= 0.0 && i_center <= 1.0)
}
