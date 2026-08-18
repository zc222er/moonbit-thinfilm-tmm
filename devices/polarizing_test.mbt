///|
test "macneille pbs brewster angle calculation" {
  let bk7 = @mat.bk7()
  let tio2 = @mat.titanium_dioxide()
  let sio2 = @mat.fused_silica()

  let pbs = MacNeillePBSDesign::new(632.8, bk7, tio2, sio2, 10)
  let angle = pbs.calculate_brewster_angle_in_prism()

  // Brewster angle inside BK7 for TiO2/SiO2 pair is typically ~ 55 - 58 degrees
  assert_true(angle > 45.0 && angle < 65.0)
}

///|
test "daytime radiative cooling net power" {
  let rad_cooling = RadiativeCoolingStructure::new(0.95, 0.96)
  let p_net = rad_cooling.calculate_net_cooling_power(300.0, 300.0, 0.0)
  assert_true(p_net > 0.0)
}
