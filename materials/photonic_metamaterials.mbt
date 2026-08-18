///|
// ============================================================================
// Photonic Metamaterials, Hyperbolic Media & Epsilon-Near-Zero (ENZ) Database
// ============================================================================

///|
/// Epsilon-Near-Zero (ENZ) Material Model (Drude formulation)
pub struct ENZMaterial {
  name : String
  enz_wavelength_nm : Double // Wavelength where Re(eps) = 0
  eps_infinity : Double
  damping_gamma_ev : Double
}

///|
pub fn ENZMaterial::new(
  name : String,
  enz_wl : Double,
  eps_inf : Double,
  gamma_ev : Double,
) -> ENZMaterial {
  {
    name,
    enz_wavelength_nm: enz_wl,
    eps_infinity: eps_inf,
    damping_gamma_ev: gamma_ev,
  }
}

///|
/// Calculate Complex Index at Wavelength lambda
pub fn ENZMaterial::get_index(
  self : ENZMaterial,
  wavelength_nm : Double,
) -> @core.Complex {
  let e_ev = 1239.84193 / wavelength_nm
  let e_enz_ev = 1239.84193 / self.enz_wavelength_nm
  let omega_p_ev = e_enz_ev * self.eps_infinity.sqrt()

  // eps(E) = eps_inf - omega_p^2 / (E^2 + i * gamma * E)
  let denom = @core.Complex::new(e_ev * e_ev, self.damping_gamma_ev * e_ev)
  let wp2 = @core.Complex::from_real(omega_p_ev * omega_p_ev)
  let drude_term = wp2.div(denom)

  let eps_c = @core.Complex::from_real(self.eps_infinity).sub(drude_term)
  eps_c.sqrt()
}

///|
pub fn ito_enz_1240nm() -> ENZMaterial {
  ENZMaterial::new("ITO_ENZ", 1240.0, 3.85, 0.08)
}

///|
pub fn azo_enz_1450nm() -> ENZMaterial {
  ENZMaterial::new("AZO_ENZ", 1450.0, 3.40, 0.065)
}

///|
pub fn cdo_enz_2100nm() -> ENZMaterial {
  ENZMaterial::new("CdO_ENZ", 2100.0, 5.30, 0.045)
}
