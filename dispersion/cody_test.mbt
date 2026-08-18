///|
test "cody lorentz dispersion evaluation" {
  // a-Si:H Cody-Lorentz parameters (Eg = 1.65 eV, E0 = 3.65 eV)
  let cody = CodyLorentzDispersion::new(2.1, 120.0, 3.65, 2.4, 1.65, 0.05, 1.85)
  let n_550 = cody.get_complex_index(550.0)

  // 550 nm is 2.25 eV > 1.65 eV (in absorbing band)
  assert_true(n_550.re > 3.0 && n_550.re < 5.0)
  assert_true(n_550.im > 0.05)
}
