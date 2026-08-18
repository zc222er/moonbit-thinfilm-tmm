///|
/// Athermal Optical Filter & Thermal Shift Compensation Engine
pub struct AthermalFilterDesign {
  center_wavelength_nm : Double
  temperature_shift_c : Double // Delta T in °C
  high_index_mat : @mat.OpticalMaterial
  low_index_mat : @mat.OpticalMaterial
  substrate_cte_ppm_k : Double
}

///|
pub fn AthermalFilterDesign::new(
  center_wl : Double,
  dt_c : Double,
  high_mat : @mat.OpticalMaterial,
  low_mat : @mat.OpticalMaterial,
  sub_cte : Double,
) -> AthermalFilterDesign {
  {
    center_wavelength_nm: center_wl,
    temperature_shift_c: dt_c,
    high_index_mat: high_mat,
    low_index_mat: low_mat,
    substrate_cte_ppm_k: sub_cte,
  }
}

///|
/// Thermal Wavelength Shift d_lambda / dT = lambda_0 * [ (1/n) * dn/dT + CTE_sub * (1 + nu)/(1 - nu) ]
pub fn AthermalFilterDesign::calculate_thermal_wavelength_drift_pm_k(
  self : AthermalFilterDesign,
  effective_dn_dt_ppm : Double,
  effective_n : Double,
) -> Double {
  // Drift in pm / K = (lambda_0 [nm] * 1000) * [ (dn/dT / n) + CTE ] * 10^-6
  let frac_optic = effective_dn_dt_ppm * 1.0e-6 / effective_n
  let frac_thermal = self.substrate_cte_ppm_k * 1.0e-6
  let total_drift_per_k = frac_optic + frac_thermal

  self.center_wavelength_nm * 1000.0 * total_drift_per_k
}
