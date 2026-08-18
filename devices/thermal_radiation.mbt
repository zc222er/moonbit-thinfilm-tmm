///|
/// Planck Blackbody Spectral Radiance B_lambda(T) in W / (m^2 * sr * nm)
pub fn planck_blackbody_radiance(
  wavelength_nm : Double,
  temperature_k : Double,
) -> Double {
  let h = 6.62607015e-34 // J*s
  let c = 2.99792458e8 // m/s
  let k_b = 1.380649e-23 // J/K

  let lambda_m = wavelength_nm * 1.0e-9
  if lambda_m <= 0.0 || temperature_k <= 0.0 {
    return 0.0
  }

  // 2 * h * c^2 / lambda^5
  let c1 = 2.0 * h * c * c / @math.pow(lambda_m, 5.0)
  // exp(h * c / (lambda * k_B * T)) - 1
  let exp_arg = h * c / (lambda_m * k_b * temperature_k)
  if exp_arg > 100.0 {
    0.0
  } else {
    let denom = @math.exp(exp_arg) - 1.0
    if denom <= 0.0 {
      0.0
    } else {
      c1 / denom * 1.0e-9
    }
  } // convert from W/(m^2*sr*m) to W/(m^2*sr*nm)
}

///|
/// Passive Daytime Radiative Cooling Multilayer Coating Engine
pub struct RadiativeCoolingStructure {
  atmospheric_window_emissivity : Double // 8 - 13 um window emissivity
  solar_weighted_reflectance : Double // 0.3 - 2.5 um solar reflectance
}

///|
pub fn RadiativeCoolingStructure::new(
  emissivity_ir : Double,
  reflectance_solar : Double,
) -> RadiativeCoolingStructure {
  {
    atmospheric_window_emissivity: emissivity_ir,
    solar_weighted_reflectance: reflectance_solar,
  }
}

///|
/// Net Radiative Cooling Power P_net(T) in W / m^2 under direct sun (1000 W/m^2)
/// P_net = P_rad(T) - P_atm(T_amb) - P_solar - P_nonrad
pub fn RadiativeCoolingStructure::calculate_net_cooling_power(
  self : RadiativeCoolingStructure,
  surface_temp_k : Double,
  ambient_temp_k : Double,
  convective_hc : Double, // Convective heat transfer coefficient (h_c ~ 6 - 8 W/m^2/K)
) -> Double {
  let sigma_sb = 5.670374419e-8 // Stefan-Boltzmann constant W/(m^2*K^4)

  // Emitted thermal radiation from surface through atmospheric window (effective transmission ~ 0.85)
  let p_rad = self.atmospheric_window_emissivity *
    sigma_sb *
    @math.pow(surface_temp_k, 4.0) *
    0.45
  // Downwelling atmospheric radiation absorbed by surface
  let p_atm = self.atmospheric_window_emissivity *
    sigma_sb *
    @math.pow(ambient_temp_k, 4.0) *
    0.35
  // Absorbed solar heat flux under 1000 W/m^2 direct sunlight
  let p_solar = 1000.0 * (1.0 - self.solar_weighted_reflectance)
  // Convective and conductive parasitic heat gain
  let p_nonrad = convective_hc * (ambient_temp_k - surface_temp_k)

  p_rad - p_atm - p_solar - p_nonrad
}
