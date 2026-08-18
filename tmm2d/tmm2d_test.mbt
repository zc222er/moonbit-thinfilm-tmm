///|
test "fresnel normal incidence single interface reflection" {
  // Air (n=1) to Glass (n=1.5)
  // Analytical R = ((1.5 - 1)/(1.5 + 1))^2 = (0.5 / 2.5)^2 = 0.2^2 = 0.04 (4%)
  let air = @core.Layer::real("Air", 0.0, 1.0)
  let glass = @core.Layer::real("Glass", 0.0, 1.5)
  let stack = @core.MultiLayerStack::new(air, [], glass)

  let res = solve_tmm2d_single(stack, 600.0, @core.IncidentAngle::normal())
  assert_true((res.r_power - 0.04).abs() < 1.0e-8)
  assert_true((res.t_power - 0.96).abs() < 1.0e-8)
  assert_true((res.a_power - 0.0).abs() < 1.0e-8)
}

///|
test "brewster angle zero reflection for TM polarization" {
  // Air (n=1) to Glass (n=1.52)
  // Brewster angle theta_B = atan(1.52 / 1.0) = 56.6593 deg
  let air = @core.Layer::real("Air", 0.0, 1.0)
  let glass = @core.Layer::real("Glass", 0.0, 1.52)
  let stack = @core.MultiLayerStack::new(air, [], glass)

  let theta_b = @core.IncidentAngle::from_rad(@math.atan(1.52))
  let res = solve_tmm2d_single(stack, 632.8, theta_b)

  // TM reflection must be zero at Brewster's angle
  assert_true(res.r_tm_power < 1.0e-10)
  // TE reflection is non-zero
  assert_true(res.r_te_power > 0.10)
}

///|
test "quarter wave single layer antireflection coating" {
  // Substrate: Glass n=1.523. AR layer: MgF2 n=1.38
  // At center wavelength lambda_0 = 550nm: d = 550 / (4 * 1.38) = 99.6377 nm
  // Ideally, if n_film = sqrt(n_sub) = sqrt(1.523) ~ 1.234, R = 0.
  // With n_film = 1.23414, d = 550 / (4 * 1.23414) = 111.4136 nm:
  let n_sub = 1.523
  let n_opt_ar = n_sub.sqrt() // exact sqrt(n_sub)
  let d_ar = 550.0 / (4.0 * n_opt_ar)

  let air = @core.Layer::real("Air", 0.0, 1.0)
  let ar_layer = @core.Layer::real("IdealAR", d_ar, n_opt_ar)
  let substrate = @core.Layer::real("Glass", 0.0, n_sub)
  let stack = @core.MultiLayerStack::new(air, [ar_layer], substrate)

  let res_550 = solve_tmm2d_single(stack, 550.0, @core.IncidentAngle::normal())
  // At center wavelength, reflectance must be strictly zero
  assert_true(res_550.r_power < 1.0e-10)
  assert_true((res_550.t_power - 1.0).abs() < 1.0e-10)
}

///|
test "ellipsometry psi and delta at 70 degrees" {
  // Bare silicon substrate at 70 deg incident angle
  let air = @core.Layer::real("Air", 0.0, 1.0)
  let si = @core.Layer::absorbing("Silicon", 0.0, 3.88, 0.02)
  let stack = @core.MultiLayerStack::new(air, [], si)

  let angle_70 = @core.IncidentAngle::from_deg(70.0)
  let ellip = solve_ellipsometry(stack, 632.8, angle_70)

  // Psi is typically ~ 10-30 deg for silicon at 70 deg
  assert_true(ellip.psi_deg > 5.0 && ellip.psi_deg < 45.0)
  assert_true(ellip.delta_deg >= 0.0 && ellip.delta_deg <= 360.0)
}
