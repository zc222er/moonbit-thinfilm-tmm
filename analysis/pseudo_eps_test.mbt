///|
test "pseudo dielectric function calculation" {
  // Bare silicon substrate at 70 deg incidence: Psi ~ 20 deg, Delta ~ 170 deg
  let pseudo = calculate_pseudo_dielectric_function(20.0, 170.0, 70.0, 550.0)

  // Pseudo index for silicon should be close to ~ 3.5 - 4.5
  assert_true(pseudo.pseudo_n > 2.5 && pseudo.pseudo_n < 5.5)
  assert_true(pseudo.eps_1_real > 5.0)
}
