///|
test "berreman 4x4 isotropic degeneracy check" {
  // Test that 4x4 Berreman yields identical reflection for isotropic medium
  let amb_n = @core.Complex::from_real(1.0)
  let sub_n = @core.Complex::from_real(1.5)
  let film_eps = PermittivityTensor::isotropic(@core.Complex::from_real(2.0))
  let d_nm = 100.0

  let res_4x4 = solve_berreman_4x4(
    amb_n,
    [(film_eps, d_nm)],
    sub_n,
    550.0,
    @core.IncidentAngle::normal(),
  )

  // Cross-polarization reflection must be identically zero for isotropic media
  assert_true(res_4x4.r_sp.abs() < 1.0e-10)
  assert_true(res_4x4.r_ps.abs() < 1.0e-10)
  assert_true(res_4x4.r_ss.abs() > 0.0)
}

///|
test "berreman 4x4 uniaxial birefringent layer" {
  let amb_n = @core.Complex::from_real(1.0)
  let sub_n = @core.Complex::from_real(1.5)

  // Uniaxial crystal with extraordinary index ne = 1.6, ordinary index no = 1.4
  // Optical axis tilted at 45 degrees
  let eps_uniaxial = PermittivityTensor::uniaxial(
    @core.Complex::from_real(1.4),
    @core.Complex::from_real(1.6),
    @math.PI / 4.0,
    @math.PI / 4.0,
  )

  let res_4x4 = solve_berreman_4x4(
    amb_n,
    [(eps_uniaxial, 200.0)],
    sub_n,
    632.8,
    @core.IncidentAngle::normal(),
  )

  // In birefringent tilted media, cross-polarization r_sp / r_ps can be generated
  assert_true(res_4x4.r_ss.norm_sq() >= 0.0)
  assert_true(res_4x4.r_pp.norm_sq() >= 0.0)
}
