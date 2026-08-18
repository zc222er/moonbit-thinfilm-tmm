///|
/// Fiber Bragg Grating (FBG) Coupled-Mode Theory Engine
pub struct FiberBraggGrating {
  grating_period_nm : Double // Lambda (e.g. 535 nm for 1550 nm Bragg wavelength)
  grating_length_mm : Double // L
  core_effective_index : Double // n_eff ~ 1.448
  index_modulation_delta_n : Double // Delta n ~ 1.0e-4 to 1.0e-3
}

///|
pub fn FiberBraggGrating::new(
  period_nm : Double,
  length_mm : Double,
  n_eff : Double,
  delta_n : Double,
) -> FiberBraggGrating {
  {
    grating_period_nm: period_nm,
    grating_length_mm: length_mm,
    core_effective_index: n_eff,
    index_modulation_delta_n: delta_n,
  }
}

///|
/// Bragg Wavelength lambda_B = 2 * n_eff * Lambda
pub fn FiberBraggGrating::calculate_bragg_wavelength_nm(
  self : FiberBraggGrating,
) -> Double {
  2.0 * self.core_effective_index * self.grating_period_nm
}

///|
/// Peak Reflectivity at Bragg Wavelength: R_max = tanh^2(kappa * L)
/// kappa = pi * Delta_n * eta / lambda_B
pub fn FiberBraggGrating::calculate_peak_reflectivity(
  self : FiberBraggGrating,
) -> Double {
  let lambda_b = self.calculate_bragg_wavelength_nm()
  let eta_core = 0.82 // Mode overlap factor with doped core
  let kappa_um1 = @math.PI *
    self.index_modulation_delta_n *
    eta_core /
    (lambda_b * 1.0e-3)
  let l_um = self.grating_length_mm * 1000.0
  let kl = kappa_um1 * l_um

  // tanh(kl) = (exp(2*kl) - 1) / (exp(2*kl) + 1)
  let exp_2kl = @math.exp(if 2.0 * kl > 30.0 { 30.0 } else { 2.0 * kl })
  let tanh_kl = (exp_2kl - 1.0) / (exp_2kl + 1.0)
  tanh_kl * tanh_kl
}
