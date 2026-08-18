///|
/// Diode-Pumped Solid-State Laser (DPSSL) Resonator & Output Coupler Engine
pub struct SolidStateLaserCavity {
  gain_crystal : @mat.LaserGainProperties
  crystal_length_mm : Double
  output_coupler_reflectance : Double // R_oc (e.g. 0.85 - 0.98)
  passive_round_trip_loss : Double // T_loss (e.g. 0.02)
  pump_beam_radius_um : Double // w_p
}

///|
pub fn SolidStateLaserCavity::new(
  gain : @mat.LaserGainProperties,
  length_mm : Double,
  r_oc : Double,
  loss : Double,
  w_pump_um : Double,
) -> SolidStateLaserCavity {
  {
    gain_crystal: gain,
    crystal_length_mm: length_mm,
    output_coupler_reflectance: r_oc,
    passive_round_trip_loss: loss,
    pump_beam_radius_um: w_pump_um,
  }
}

///|
/// Laser Cavity Operating Performance Metrics
pub struct LaserOperatingMetrics {
  threshold_pump_power_mw : Double
  slope_efficiency_percent : Double
  optimum_oc_reflectance : Double
} derive(Eq)

///|
pub impl Show for LaserOperatingMetrics with fn output(self, logger) {
  logger.write_string(
    "DPSSL(P_th=\{self.threshold_pump_power_mw} mW, Slope_Eff=\{self.slope_efficiency_percent}%, R_opt=\{self.optimum_oc_reflectance * 100.0}%)",
  )
}

///|
/// Calculate Laser Threshold Power & Slope Efficiency
pub fn SolidStateLaserCavity::calculate_laser_performance(
  self : SolidStateLaserCavity,
  small_signal_gain_g0_cm1 : Double,
) -> LaserOperatingMetrics {
  let h_planck = 6.62607015e-34
  let c_light = 2.99792458e8

  let e_pump_j = h_planck *
    c_light /
    (self.gain_crystal.pump_wavelength_nm * 1.0e-9)
  let e_laser_j = h_planck *
    c_light /
    (self.gain_crystal.laser_wavelength_nm * 1.0e-9)
  let quantum_defect = e_laser_j / e_pump_j

  let t_oc = 1.0 - self.output_coupler_reflectance
  let total_loss = t_oc + self.passive_round_trip_loss

  let area_cm2 = @math.PI *
    (self.pump_beam_radius_um * 1.0e-4) *
    (self.pump_beam_radius_um * 1.0e-4)
  let tau_s = self.gain_crystal.fluorescence_lifetime_us * 1.0e-6
  let sigma_e = self.gain_crystal.emission_cross_section_cm2

  // P_th = (E_pump * Area * Total_loss) / (2 * sigma_e * tau_f)
  let p_th_w = e_pump_j * area_cm2 * total_loss / (2.0 * sigma_e * tau_s)
  let p_th_mw = p_th_w * 1000.0

  // Slope efficiency: eta_slope = eta_quantum_defect * (T_oc / (T_oc + T_loss))
  let slope_eff = quantum_defect * (t_oc / total_loss) * 100.0

  // Optimum output coupling: T_opt = sqrt(2 * g0 * L * T_loss) - T_loss
  let l_cm = self.crystal_length_mm * 0.1
  let g0_2l = 2.0 * small_signal_gain_g0_cm1 * l_cm
  let t_opt = (g0_2l * self.passive_round_trip_loss).sqrt() -
    self.passive_round_trip_loss
  let r_opt = if t_opt < 0.01 {
    0.99
  } else if t_opt > 0.3 {
    0.70
  } else {
    1.0 - t_opt
  }

  {
    threshold_pump_power_mw: p_th_mw,
    slope_efficiency_percent: slope_eff,
    optimum_oc_reflectance: r_opt,
  }
}
