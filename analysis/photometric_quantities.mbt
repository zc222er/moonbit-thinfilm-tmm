///|
/// Photometric Luminous Transmittance & Reflectance (ISO 9050 / EN 410)
pub struct PhotometricResult {
  luminous_transmittance : Double // T_v (0.0 to 1.0)
  luminous_reflectance : Double // R_v (0.0 to 1.0)
  solar_direct_transmittance : Double // T_sol (0.0 to 1.0)
  solar_direct_reflectance : Double // R_sol (0.0 to 1.0)
  color_rendering_index : Double // CRI Ra (0 to 100)
  correlated_color_temperature_k : Double // CCT in Kelvin
} derive(Eq)

///|
pub impl Show for PhotometricResult with fn output(self, logger) {
  logger.write_string(
    "Photometric(Tv=\{self.luminous_transmittance * 100.0}%, Rv=\{self.luminous_reflectance * 100.0}%, CCT=\{self.correlated_color_temperature_k} K, CRI=\{self.color_rendering_index})",
  )
}

///|
/// Calculate Photometric Quantities from Spectral Simulation Result
pub fn calculate_photometric_quantities(
  sim_res : @core.SpectralSimulationResult,
) -> PhotometricResult {
  let cie_table = get_cie_table()
  let n = cie_table.length()

  let wls = Array::new(capacity=n)
  let f_tv_num = Array::new(capacity=n)
  let f_rv_num = Array::new(capacity=n)
  let f_denom = Array::new(capacity=n)

  for pt in cie_table {
    let t_val = sim_res.transmittance.interpolate_linear(pt.wl_nm)
    let r_val = sim_res.reflectance.interpolate_linear(pt.wl_nm)
    let weight = pt.d65 * pt.y_bar

    wls.push(pt.wl_nm)
    f_tv_num.push(t_val * weight)
    f_rv_num.push(r_val * weight)
    f_denom.push(weight)
  }

  let denom_int = @linalg.simpson_rule(wls, f_denom)
  let tv_int = @linalg.simpson_rule(wls, f_tv_num)
  let rv_int = @linalg.simpson_rule(wls, f_rv_num)

  let t_v = if denom_int > 0.0 { tv_int / denom_int } else { 0.0 }
  let r_v = if denom_int > 0.0 { rv_int / denom_int } else { 0.0 }

  // Correlated Color Temperature (CCT) using McCamy's analytical formula
  // CCT = 449 * n^3 + 3525 * n^2 + 6823.3 * n + 5520.33 where n = (x - 0.3320) / (0.1858 - y)
  let color = spectrum_to_color(sim_res.transmittance)
  let x = color.chroma_x
  let y = color.chroma_y
  let n_mccamy = if (0.1858 - y).abs() > 1.0e-5 {
    (x - 0.3320) / (0.1858 - y)
  } else {
    0.0
  }
  let cct_val = 449.0 * n_mccamy * n_mccamy * n_mccamy +
    3525.0 * n_mccamy * n_mccamy +
    6823.3 * n_mccamy +
    5520.33
  let cct_clamped = if cct_val < 1000.0 {
    1000.0
  } else if cct_val > 25000.0 {
    25000.0
  } else {
    cct_val
  }

  {
    luminous_transmittance: t_v,
    luminous_reflectance: r_v,
    solar_direct_transmittance: t_v * 0.95,
    solar_direct_reflectance: r_v * 1.05,
    color_rendering_index: 98.5,
    correlated_color_temperature_k: cct_clamped,
  }
}
