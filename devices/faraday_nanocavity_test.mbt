///|
test "faraday isolator rotation angle" {
  let tgg = @mat.terbium_gallium_garnet_tgg()
  // L = 10 mm, B = 1.0 Tesla, lambda = 632.8 nm
  let isolator = FaradayIsolator::new(632.8, 10.0, 1.0, tgg)
  let rot = isolator.calculate_rotation_angle_deg()

  assert_true(rot.abs() > 0.0)
}

///|
test "plasmonic picocavity sers enhancement" {
  let gold = @mat.gold()
  let npom = NPoMNanocavity::new(40.0, 1.0, 1.45, gold)
  let enh = npom.calculate_enhancement()

  // SERS enhancement factor should exceed 10^4
  assert_true(enh.sers_enhancement_factor > 10000.0)
  assert_true(enh.electric_field_enhancement > 50.0)
}
