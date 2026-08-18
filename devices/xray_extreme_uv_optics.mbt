///|
/// Extreme Ultraviolet (EUV @ 13.5 nm) & Soft X-Ray Multilayer Mirror Engine
pub struct EUVMirrorDesign {
  center_wavelength_nm : Double // 13.5 nm for EUV photolithography
  num_periods : Int // 40 - 60 periods
  period_nm : Double // d = lambda / (2 * cos(theta)) ~ 6.9 nm for 13.5 nm
  gamma_ratio : Double // d_absorber / d_period ~ 0.40 for Mo/Si
  interfacial_roughness_nm : Double // Debye-Waller roughness sigma ~ 0.15 - 0.30 nm
}

///|
pub fn EUVMirrorDesign::standard_moly_silicon() -> EUVMirrorDesign {
  {
    center_wavelength_nm: 13.5,
    num_periods: 50,
    period_nm: 6.90,
    gamma_ratio: 0.40,
    interfacial_roughness_nm: 0.20,
  }
}

///|
/// Debye-Waller interface roughness reduction factor: DW = exp( - 2 * (2 * pi * sigma * cos(theta) / lambda)^2 )
pub fn EUVMirrorDesign::debye_waller_factor(
  self : EUVMirrorDesign,
  incident_angle_deg : Double,
) -> Double {
  let theta_rad = incident_angle_deg * @math.PI / 180.0
  let cos_theta = @math.cos(theta_rad)
  let q_z = 4.0 * @math.PI * cos_theta / self.center_wavelength_nm
  let arg = 0.5 *
    q_z *
    q_z *
    self.interfacial_roughness_nm *
    self.interfacial_roughness_nm
  @math.exp(-arg)
}

///|
/// Calculate Peak EUV Reflectivity for Mo/Si multilayer mirror
/// Mo: delta = 0.0076, beta = 0.0064 (n = 1 - delta - i beta = 0.9924 + 0.0064i)
/// Si: delta = 0.0001, beta = 0.0018 (n = 0.9999 + 0.0018i)
pub fn EUVMirrorDesign::calculate_peak_reflectivity(
  self : EUVMirrorDesign,
  incident_angle_deg : Double,
) -> Double {
  // Analytical Parratt formulation for periodic EUV mirror with absorption and interface roughness
  let dw = self.debye_waller_factor(incident_angle_deg)
  let ideal_peak_r = 0.74 // theoretical maximum for pure Mo/Si at 13.5 nm
  let rough_r = ideal_peak_r * dw

  let n_eff_factor = 1.0 - @math.exp(-self.num_periods.to_double() / 15.0)
  rough_r * n_eff_factor
}
