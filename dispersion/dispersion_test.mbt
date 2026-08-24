///|
test "cauchy dispersion evaluation" {
  let cauchy = CauchyDispersion::transparent(1.45, 0.0035, 0.0)
  let n_500 = cauchy.get_complex_index(500.0)
  // lambda = 0.5 um, n = 1.45 + 0.0035 / (0.25) = 1.45 + 0.014 = 1.464
  assert_true((n_500.re - 1.464).abs() < 1.0e-6)
  assert_eq(n_500.im, 0.0)
}

///|
test "sellmeier fused silica dispersion" {
  let silica = Sellmeier3Dispersion::fused_silica()
  // At 589.3 nm (sodium D-line), Fused Silica index is approx 1.4584
  let n_d = silica.get_complex_index(589.3)
  assert_true((n_d.re - 1.4584).abs() < 0.002)

  // At 1550 nm (telecom C-band), Fused Silica index is approx 1.444
  let n_1550 = silica.get_complex_index(1550.0)
  assert_true((n_1550.re - 1.444).abs() < 0.002)
}

///|
test "drude silver plasma model" {
  // Silver Drude parameters: eps_inf = 4.0, wp = 9.0 eV, gamma = 0.05 eV
  let ag_drude = DrudeDispersion::new(4.0, 9.0, 0.05)
  let eps_600 = ag_drude.get_permittivity(600.0)

  // Silver at 600 nm should have large negative Re(eps)
  assert_true(eps_600.re < -10.0)
  assert_true(eps_600.im > 0.0)
}

///|
test "maxwell garnett effective medium" {
  let host = @core.Complex::from_real(1.5 * 1.5) // Glass eps = 2.25
  let incl = @core.Complex::from_real(1.0) // Air pore eps = 1.0
  let mg = MaxwellGarnettEMA::new(host, incl, 0.2) // 20% porosity
  let eff_eps = mg.effective_permittivity()
  let eff_n = eff_eps.sqrt()

  // Porous glass should have 1.0 < n < 1.5
  assert_true(eff_n.re < 1.5 && eff_n.re > 1.0)
}

///|
test "tabulated dispersion interpolation" {
  let wls = [400.0, 500.0, 600.0, 700.0]
  let n_arr = [3.8, 3.5, 3.3, 3.2]
  let k_arr = [0.2, 0.05, 0.01, 0.001]
  let tab = TabulatedDispersion::new("TestSemi", wls, n_arr, k_arr)

  let n_550 = tab.get_complex_index(550.0)
  assert_true(n_550.re < 3.5 && n_550.re > 3.3)
  assert_true(n_550.im < 0.05 && n_550.im > 0.01)
}

///|
test "dispersion models stay finite at nonpositive wavelength" {
  let cauchy = CauchyDispersion::transparent(1.45, 0.0035, 0.0)
  let cauchy_zero = cauchy.get_complex_index(0.0)
  let cauchy_negative = cauchy.get_complex_index(-10.0)
  assert_true(!cauchy_zero.re.is_nan() && !cauchy_zero.re.is_inf())
  assert_true(!cauchy_negative.re.is_nan() && !cauchy_negative.re.is_inf())

  let drude = DrudeDispersion::new(4.0, 9.0, 0.05)
  let eps_zero = drude.get_permittivity(0.0)
  assert_true(!eps_zero.re.is_nan() && !eps_zero.re.is_inf())
  assert_true(!eps_zero.im.is_nan() && !eps_zero.im.is_inf())
}
