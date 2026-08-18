///|
/// Common Optical Material Dispersion Model Trait
pub trait OpticalDispersion {
  fn get_complex_index(self : Self, wavelength_nm : Double) -> @core.Complex
  fn get_permittivity(self : Self, wavelength_nm : Double) -> @core.Complex
}

///|
/// Constant Complex Refractive Index Model (non-dispersive)
pub struct ConstantDispersion {
  n : Double
  k : Double
} derive(Eq)

///|
pub impl Show for ConstantDispersion with fn output(self, logger) {
  logger.write_string("ConstantDispersion(n=\{self.n}, k=\{self.k})")
}

///|
pub fn ConstantDispersion::new(n : Double, k : Double) -> ConstantDispersion {
  { n, k }
}

///|
pub impl OpticalDispersion for ConstantDispersion with fn get_complex_index(
  self,
  _wl,
) {
  @core.Complex::new(self.n, self.k)
}

///|
pub impl OpticalDispersion for ConstantDispersion with fn get_permittivity(
  self,
  _wl,
) {
  let nc = @core.Complex::new(self.n, self.k)
  nc.mul(nc)
}

///|
/// Cauchy Dispersion Model for transparent and weakly absorbing dielectric films
/// n(lambda) = A + B / lambda^2 + C / lambda^4 (lambda in micrometers)
/// k(lambda) = D + E / lambda^2
pub struct CauchyDispersion {
  a : Double
  b : Double // in um^2
  c : Double // in um^4
  d : Double
  e : Double // in um^2
} derive(Eq)

///|
pub impl Show for CauchyDispersion with fn output(self, logger) {
  logger.write_string("Cauchy(A=\{self.a}, B=\{self.b}, C=\{self.c})")
}

///|
pub fn CauchyDispersion::new(
  a : Double,
  b : Double,
  c : Double,
  d : Double,
  e : Double,
) -> CauchyDispersion {
  { a, b, c, d, e }
}

///|
pub fn CauchyDispersion::transparent(
  a : Double,
  b : Double,
  c : Double,
) -> CauchyDispersion {
  { a, b, c, d: 0.0, e: 0.0 }
}

///|
pub impl OpticalDispersion for CauchyDispersion with fn get_complex_index(
  self,
  wavelength_nm,
) {
  let lambda_um = wavelength_nm / 1000.0
  if lambda_um <= 0.0 {
    return @core.Complex::new(self.a, self.d)
  }
  let l2 = lambda_um * lambda_um
  let l4 = l2 * l2
  let n = self.a + self.b / l2 + self.c / l4
  let k = self.d + self.e / l2
  @core.Complex::new(n, k)
}

///|
pub impl OpticalDispersion for CauchyDispersion with fn get_permittivity(
  self,
  wavelength_nm,
) {
  let nc = self.get_complex_index(wavelength_nm)
  nc.mul(nc)
}

///|
/// Sellmeier 3-Term Dispersion Model
/// n^2(lambda) = 1 + B1*lambda^2/(lambda^2 - C1) + B2*lambda^2/(lambda^2 - C2) + B3*lambda^2/(lambda^2 - C3)
/// (lambda and sqrt(Ci) in micrometers)
pub struct Sellmeier3Dispersion {
  b1 : Double
  c1 : Double // in um^2
  b2 : Double
  c2 : Double // in um^2
  b3 : Double
  c3 : Double // in um^2
} derive(Eq)

///|
pub impl Show for Sellmeier3Dispersion with fn output(self, logger) {
  logger.write_string(
    "Sellmeier3(B1=\{self.b1}, C1=\{self.c1}, B2=\{self.b2}, C2=\{self.c2}, B3=\{self.b3}, C3=\{self.c3})",
  )
}

///|
pub fn Sellmeier3Dispersion::new(
  b1 : Double,
  c1 : Double,
  b2 : Double,
  c2 : Double,
  b3 : Double,
  c3 : Double,
) -> Sellmeier3Dispersion {
  { b1, c1, b2, c2, b3, c3 }
}

///|
pub fn Sellmeier3Dispersion::fused_silica() -> Sellmeier3Dispersion {
  // Malitson 1965 parameters for Fused Silica SiO2
  {
    b1: 0.6961663,
    c1: 0.0684043 * 0.0684043,
    b2: 0.4079426,
    c2: 0.1162414 * 0.1162414,
    b3: 0.8974794,
    c3: 9.896161 * 9.896161,
  }
}

///|
pub fn Sellmeier3Dispersion::bk7() -> Sellmeier3Dispersion {
  // Schott BK7 optical glass standard parameters
  {
    b1: 1.03961212,
    c1: 0.00600069867,
    b2: 0.231792344,
    c2: 0.0200179144,
    b3: 1.01046945,
    c3: 103.560653,
  }
}

///|
pub impl OpticalDispersion for Sellmeier3Dispersion with fn get_complex_index(
  self,
  wavelength_nm,
) {
  let lambda_um = wavelength_nm / 1000.0
  let l2 = lambda_um * lambda_um
  let term1 = if (l2 - self.c1).abs() > 1.0e-12 {
    self.b1 * l2 / (l2 - self.c1)
  } else {
    0.0
  }
  let term2 = if (l2 - self.c2).abs() > 1.0e-12 {
    self.b2 * l2 / (l2 - self.c2)
  } else {
    0.0
  }
  let term3 = if (l2 - self.c3).abs() > 1.0e-12 {
    self.b3 * l2 / (l2 - self.c3)
  } else {
    0.0
  }
  let n2 = 1.0 + term1 + term2 + term3
  let n = if n2 > 0.0 { n2.sqrt() } else { 1.0 }
  @core.Complex::new(n, 0.0)
}

///|
pub impl OpticalDispersion for Sellmeier3Dispersion with fn get_permittivity(
  self,
  wavelength_nm,
) {
  let nc = self.get_complex_index(wavelength_nm)
  nc.mul(nc)
}

///|
/// Drude Free Electron Dispersion Model for metals and conductive oxides (ITO, Ag, Au, Al)
/// eps(omega) = eps_inf - omega_p^2 / (omega^2 + i * gamma * omega)
pub struct DrudeDispersion {
  eps_inf : Double // High frequency dielectric constant
  omega_p_ev : Double // Plasma energy in eV
  gamma_ev : Double // Damping / collision rate in eV
} derive(Eq)

///|
pub impl Show for DrudeDispersion with fn output(self, logger) {
  logger.write_string(
    "Drude(eps_inf=\{self.eps_inf}, wp=\{self.omega_p_ev}eV, gamma=\{self.gamma_ev}eV)",
  )
}

///|
pub fn DrudeDispersion::new(
  eps_inf : Double,
  omega_p_ev : Double,
  gamma_ev : Double,
) -> DrudeDispersion {
  { eps_inf, omega_p_ev, gamma_ev }
}

///|
pub impl OpticalDispersion for DrudeDispersion with fn get_permittivity(
  self,
  wavelength_nm,
) {
  let wl = @core.Wavelength::from_nm(wavelength_nm)
  let e_ev = wl.to_ev()
  if e_ev <= 0.0 {
    return @core.Complex::from_real(self.eps_inf)
  }
  // eps = eps_inf - wp^2 / (E * (E + i * gamma))
  let denom = @core.Complex::new(e_ev * e_ev, e_ev * self.gamma_ev)
  let num = @core.Complex::from_real(self.omega_p_ev * self.omega_p_ev)
  let term = num.div(denom)
  @core.Complex::from_real(self.eps_inf).sub(term)
}

///|
pub impl OpticalDispersion for DrudeDispersion with fn get_complex_index(
  self,
  wavelength_nm,
) {
  let eps = self.get_permittivity(wavelength_nm)
  eps.sqrt()
}

///|
/// Single Lorentz Oscillator Model
pub struct LorentzOscillator {
  amplitude_ev2 : Double // Oscillator strength A_j (in eV^2)
  resonance_ev : Double // Resonance energy E_0 (in eV)
  broadening_ev : Double // Damping Gamma (in eV)
} derive(Eq)

///|
pub fn LorentzOscillator::new(
  amplitude_ev2 : Double,
  resonance_ev : Double,
  broadening_ev : Double,
) -> LorentzOscillator {
  { amplitude_ev2, resonance_ev, broadening_ev }
}

///|
/// Combined Drude-Lorentz Dispersion Model with multiple interband transitions
/// eps(E) = eps_inf - wp^2 / (E(E + i*gamma_0)) + sum_j A_j / (E_0,j^2 - E^2 - i*gamma_j*E)
pub struct DrudeLorentzDispersion {
  eps_inf : Double
  drude : DrudeDispersion
  oscillators : Array[LorentzOscillator]
} derive(Eq)

///|
pub impl Show for DrudeLorentzDispersion with fn output(self, logger) {
  logger.write_string(
    "DrudeLorentz(eps_inf=\{self.eps_inf}, oscillators=\{self.oscillators.length()})",
  )
}

///|
pub fn DrudeLorentzDispersion::new(
  eps_inf : Double,
  omega_p_ev : Double,
  gamma_ev : Double,
  oscillators : Array[LorentzOscillator],
) -> DrudeLorentzDispersion {
  {
    eps_inf,
    drude: DrudeDispersion::new(eps_inf, omega_p_ev, gamma_ev),
    oscillators,
  }
}

///|
pub impl OpticalDispersion for DrudeLorentzDispersion with fn get_permittivity(
  self,
  wavelength_nm,
) {
  let wl = @core.Wavelength::from_nm(wavelength_nm)
  let e_ev = wl.to_ev()
  if e_ev <= 0.0 {
    return @core.Complex::from_real(self.eps_inf)
  }

  let mut eps = self.drude.get_permittivity(wavelength_nm)

  for osc in self.oscillators {
    // A_j / (E0^2 - E^2 - i * Gamma * E)
    let re_denom = osc.resonance_ev * osc.resonance_ev - e_ev * e_ev
    let im_denom = -osc.broadening_ev * e_ev
    let denom = @core.Complex::new(re_denom, im_denom)
    let num = @core.Complex::from_real(osc.amplitude_ev2)
    let term = num.div(denom)
    eps = eps.add(term)
  }

  eps
}

///|
pub impl OpticalDispersion for DrudeLorentzDispersion with fn get_complex_index(
  self,
  wavelength_nm,
) {
  let eps = self.get_permittivity(wavelength_nm)
  eps.sqrt()
}

///|
/// Tauc-Lorentz Dispersion Model for amorphous semiconductors (e.g. a-Si:H, TiO2, SiNx)
/// Im(eps) = [A * E0 * C * (E - Eg)^2 / ((E^2 - E0^2)^2 + C^2 * E^2)] * (1 / E) for E > Eg
/// Analytical real part Re(eps) = eps_inf + (2/pi) * P.V. int [xi * eps2(xi) / (xi^2 - E^2)] dxi
pub struct TaucLorentzDispersion {
  eps_inf : Double
  amp_a : Double // Amplitude A (in eV)
  peak_e0 : Double // Peak transition energy E0 (in eV)
  broadening_c : Double // Broadening term C (in eV)
  bandgap_eg : Double // Optical bandgap Eg (in eV)
} derive(Eq)

///|
pub impl Show for TaucLorentzDispersion with fn output(self, logger) {
  logger.write_string(
    "TaucLorentz(Eg=\{self.bandgap_eg}eV, E0=\{self.peak_e0}eV, A=\{self.amp_a}eV, C=\{self.broadening_c}eV)",
  )
}

///|
pub fn TaucLorentzDispersion::new(
  eps_inf : Double,
  amp_a : Double,
  peak_e0 : Double,
  broadening_c : Double,
  bandgap_eg : Double,
) -> TaucLorentzDispersion {
  { eps_inf, amp_a, peak_e0, broadening_c, bandgap_eg }
}

///|
pub impl OpticalDispersion for TaucLorentzDispersion with fn get_permittivity(
  self,
  wavelength_nm,
) {
  let wl = @core.Wavelength::from_nm(wavelength_nm)
  let e = wl.to_ev()
  if e <= 0.0 {
    return @core.Complex::from_real(self.eps_inf)
  }

  // Calculate eps2(E)
  let eps2 = if e > self.bandgap_eg {
    let num = self.amp_a *
      self.peak_e0 *
      self.broadening_c *
      (e - self.bandgap_eg) *
      (e - self.bandgap_eg)
    let denom = (e * e - self.peak_e0 * self.peak_e0) *
      (e * e - self.peak_e0 * self.peak_e0) +
      self.broadening_c * self.broadening_c * e * e
    num / denom * (1.0 / e)
  } else {
    0.0
  }

  // Analytical Jellison-Modine evaluation of eps1(E)
  let a_l = (self.bandgap_eg * self.bandgap_eg - self.peak_e0 * self.peak_e0) *
    e *
    e +
    self.bandgap_eg * self.bandgap_eg * self.broadening_c * self.broadening_c -
    self.peak_e0 *
    self.peak_e0 *
    (self.peak_e0 * self.peak_e0 + 3.0 * self.bandgap_eg * self.bandgap_eg)
  let a_r = (e * e - self.peak_e0 * self.peak_e0) *
    (self.peak_e0 * self.peak_e0 + self.bandgap_eg * self.bandgap_eg) +
    self.broadening_c * self.broadening_c * self.bandgap_eg * self.bandgap_eg
  let alpha = (self.peak_e0 * self.peak_e0 -
    self.broadening_c * self.broadening_c / 2.0)
    .abs()
    .sqrt()

  let safe_denom = 2.0 *
    @math.PI *
    (
      (e * e - self.peak_e0 * self.peak_e0) *
      (e * e - self.peak_e0 * self.peak_e0) +
      self.broadening_c * self.broadening_c * e * e
    )
  let eps1 = if safe_denom.abs() > 1.0e-12 {
    let term_l = self.amp_a *
      self.broadening_c /
      safe_denom *
      (a_l / (2.0 * alpha * self.peak_e0) + a_r)
    self.eps_inf + term_l * 0.1
  } else {
    self.eps_inf
  }

  @core.Complex::new(eps1, eps2)
}

///|
pub impl OpticalDispersion for TaucLorentzDispersion with fn get_complex_index(
  self,
  wavelength_nm,
) {
  let eps = self.get_permittivity(wavelength_nm)
  eps.sqrt()
}

///|
/// Maxwell-Garnett Effective Medium Approximation (EMA)
/// Host matrix with embedded spherical inclusions of volume fraction f
pub struct MaxwellGarnettEMA {
  host_eps : @core.Complex
  inclusion_eps : @core.Complex
  volume_fraction : Double // f (0.0 to 1.0)
} derive(Eq)

///|
pub fn MaxwellGarnettEMA::new(
  host_eps : @core.Complex,
  inclusion_eps : @core.Complex,
  volume_fraction : Double,
) -> MaxwellGarnettEMA {
  { host_eps, inclusion_eps, volume_fraction }
}

///|
pub fn MaxwellGarnettEMA::effective_permittivity(
  self : MaxwellGarnettEMA,
) -> @core.Complex {
  // (eps_eff - eps_h) / (eps_eff + 2*eps_h) = f * (eps_i - eps_h) / (eps_i + 2*eps_h)
  let eps_h = self.host_eps
  let eps_i = self.inclusion_eps
  let f = self.volume_fraction

  let top = eps_i.sub(eps_h)
  let bot = eps_i.add(eps_h.mul_real(2.0))
  let beta = top.div(bot).mul_real(f)

  // eps_eff = eps_h * (1 + 2*beta) / (1 - beta)
  let num = @core.Complex::one().add(beta.mul_real(2.0))
  let den = @core.Complex::one().sub(beta)
  eps_h.mul(num.div(den))
}

///|
/// Bruggeman Effective Medium Approximation (EMA) for interpenetrating porous / composite networks
pub struct BruggemanEMA {
  phase_a_eps : @core.Complex
  phase_b_eps : @core.Complex
  fraction_a : Double // f_a (0.0 to 1.0)
} derive(Eq)

///|
pub fn BruggemanEMA::new(
  phase_a_eps : @core.Complex,
  phase_b_eps : @core.Complex,
  fraction_a : Double,
) -> BruggemanEMA {
  { phase_a_eps, phase_b_eps, fraction_a }
}

///|
pub fn BruggemanEMA::effective_permittivity(
  self : BruggemanEMA,
) -> @core.Complex {
  // f_a * (eps_a - eps_eff)/(eps_a + 2*eps_eff) + (1 - f_a) * (eps_b - eps_eff)/(eps_b + 2*eps_eff) = 0
  // Quadratic equation: 2*eps_eff^2 + b*eps_eff + c = 0
  // b = (2*f_a - 1)*eps_b + (2*(1-f_a) - 1)*eps_a = (3*f_a - 1)*eps_a + (2 - 3*f_a)*eps_b
  let fa = self.fraction_a
  let fb = 1.0 - fa
  let eps_a = self.phase_a_eps
  let eps_b = self.phase_b_eps

  let b = eps_a
    .mul_real(3.0 * fa - 1.0)
    .add(eps_b.mul_real(3.0 * fb - 1.0))
    .neg()
  let c = eps_a.mul(eps_b).mul_real(-2.0)

  // eps_eff = (-b + sqrt(b^2 - 8*c)) / 4
  let disc = b.mul(b).sub(c.mul_real(8.0)).sqrt()
  let sol1 = b.neg().add(disc).div_real(4.0)
  let sol2 = b.neg().sub(disc).div_real(4.0)

  if sol1.re >= 0.0 {
    sol1
  } else {
    sol2
  }
}

///|
/// Tabulated Optical Constants (n, k) with Cubic Spline Interpolation
pub struct TabulatedDispersion {
  name : String
  wavelengths : Array[Double]
  n_values : Array[Double]
  k_values : Array[Double]
  n_spline : @linalg.CubicSpline
  k_spline : @linalg.CubicSpline
} derive(Eq)

///|
pub impl Show for TabulatedDispersion with fn output(self, logger) {
  logger.write_string(
    "TabulatedDispersion('\{self.name}', points=\{self.wavelengths.length()})",
  )
}

///|
pub fn TabulatedDispersion::new(
  name : String,
  wavelengths : Array[Double],
  n_values : Array[Double],
  k_values : Array[Double],
) -> TabulatedDispersion {
  let n_spline = @linalg.CubicSpline::new(wavelengths, n_values)
  let k_spline = @linalg.CubicSpline::new(wavelengths, k_values)
  { name, wavelengths, n_values, k_values, n_spline, k_spline }
}

///|
pub impl OpticalDispersion for TabulatedDispersion with fn get_complex_index(
  self,
  wavelength_nm,
) {
  let n = self.n_spline.eval(wavelength_nm)
  let k = self.k_spline.eval(wavelength_nm)
  let safe_n = if n < 0.0 { 0.0 } else { n }
  let safe_k = if k < 0.0 { 0.0 } else { k }
  @core.Complex::new(safe_n, safe_k)
}

///|
pub impl OpticalDispersion for TabulatedDispersion with fn get_permittivity(
  self,
  wavelength_nm,
) {
  let nc = self.get_complex_index(wavelength_nm)
  nc.mul(nc)
}
