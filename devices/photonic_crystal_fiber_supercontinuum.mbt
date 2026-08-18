///|
/// Photonic Crystal Fiber (PCF) Supercontinuum Generation Engine
pub struct PCFSupercontinuumSource {
  fiber_length_m : Double
  nonlinear_refractive_index_n2 : Double // n2 ~ 2.6e-20 m^2 / W for fused silica
  effective_mode_area_um2 : Double // A_eff ~ 3 - 5 um^2
  pump_peak_power_w : Double // P_peak ~ 1 - 10 kW (femtosecond laser)
}

///|
pub fn PCFSupercontinuumSource::new(
  length_m : Double,
  n2_m2_w : Double,
  a_eff_um2 : Double,
  p_peak_w : Double,
) -> PCFSupercontinuumSource {
  {
    fiber_length_m: length_m,
    nonlinear_refractive_index_n2: n2_m2_w,
    effective_mode_area_um2: a_eff_um2,
    pump_peak_power_w: p_peak_w,
  }
}

///|
/// Calculate Fiber Nonlinear Parameter gamma in (W * m)^(-1): gamma = 2 * pi * n_2 / (lambda * A_eff)
pub fn PCFSupercontinuumSource::calculate_nonlinear_parameter_gamma(
  self : PCFSupercontinuumSource,
  pump_wavelength_nm : Double,
) -> Double {
  let lambda_m = pump_wavelength_nm * 1.0e-9
  let a_eff_m2 = self.effective_mode_area_um2 * 1.0e-12
  2.0 * @math.PI * self.nonlinear_refractive_index_n2 / (lambda_m * a_eff_m2)
}

///|
/// Self-Phase Modulation (SPM) Maximum Nonlinear Phase Shift: Phi_NL = gamma * P_peak * L_eff
pub fn PCFSupercontinuumSource::calculate_spm_phase_shift_rad(
  self : PCFSupercontinuumSource,
  pump_wavelength_nm : Double,
) -> Double {
  let gamma = self.calculate_nonlinear_parameter_gamma(pump_wavelength_nm)
  gamma * self.pump_peak_power_w * self.fiber_length_m
}
