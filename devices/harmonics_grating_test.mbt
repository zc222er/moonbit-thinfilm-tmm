///|
test "type 1 shg phase matching angle" {
  // BBO crystal parameters for 1064 nm -> 532 nm SHG
  // no(1064) = 1.6551, ne(1064) = 1.5426
  // no(532) = 1.6749, ne(532) = 1.5555
  let pm = NonLinearPhaseMatching::new(1064.0, 1.6551, 1.5426, 1.6749, 1.5555)
  let angle = pm.calculate_type1_phase_matching_angle_deg()

  // BBO Type-I SHG phase matching angle is ~ 22.8 degrees
  assert_true(angle > 18.0 && angle < 28.0)
}

///|
test "subwavelength grating form birefringence" {
  let tio2 = @mat.titanium_dioxide()
  let air = @mat.air()
  let grating = SubwavelengthGrating::new(200.0, 0.50, tio2, air, 300.0)

  let indices = grating.calculate_effective_indices(632.8)

  // Form birefringence Delta n_form = n_TE - n_TM should be strictly positive
  assert_true(indices.birefringence_form > 0.3)
  assert_true(indices.n_eff_te > indices.n_eff_tm)
}
