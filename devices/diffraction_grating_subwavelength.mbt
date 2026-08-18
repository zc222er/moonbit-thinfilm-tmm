///|
/// Subwavelength 1D Diffraction Grating & Metasurface Effective Index Engine
pub struct SubwavelengthGrating {
  grating_period_nm : Double // Period Lambda < lambda / (n_sub + n_inc) (zero order regime)
  fill_factor : Double // Ridge width w / Lambda (0.0 to 1.0)
  ridge_material : @mat.OpticalMaterial
  groove_material : @mat.OpticalMaterial // E.g. Air
  grating_depth_nm : Double
}

///|
pub fn SubwavelengthGrating::new(
  period : Double,
  fill : Double,
  ridge : @mat.OpticalMaterial,
  groove : @mat.OpticalMaterial,
  depth : Double,
) -> SubwavelengthGrating {
  {
    grating_period_nm: period,
    fill_factor: fill,
    ridge_material: ridge,
    groove_material: groove,
    grating_depth_nm: depth,
  }
}

///|
/// Zero-th Order Effective Medium Approximation (EMA) for TE and TM Polarizations:
/// eps_eff_TE = f * eps_ridge + (1 - f) * eps_groove
/// 1 / eps_eff_TM = f / eps_ridge + (1 - f) / eps_groove
pub struct GratingEffectiveIndices {
  n_eff_te : Double
  n_eff_tm : Double
  birefringence_form : Double // Delta n_form = n_eff_TE - n_eff_TM (form birefringence)
} derive(Eq)

///|
pub impl Show for GratingEffectiveIndices with fn output(self, logger) {
  logger.write_string(
    "GratingEMA(n_TE=\{self.n_eff_te}, n_TM=\{self.n_eff_tm}, Delta_n=\{self.birefringence_form})",
  )
}

///|
/// Calculate Form Birefringence of Subwavelength Grating
pub fn SubwavelengthGrating::calculate_effective_indices(
  self : SubwavelengthGrating,
  wavelength_nm : Double,
) -> GratingEffectiveIndices {
  let n_r = self.ridge_material.get_index(wavelength_nm).re
  let n_g = self.groove_material.get_index(wavelength_nm).re

  let eps_r = n_r * n_r
  let eps_g = n_g * n_g
  let f = self.fill_factor

  // TE (E parallel to grating grooves)
  let eps_te = f * eps_r + (1.0 - f) * eps_g
  let n_te = eps_te.sqrt()

  // TM (E perpendicular to grating grooves)
  let inv_eps_tm = f / eps_r + (1.0 - f) / eps_g
  let eps_tm = if inv_eps_tm > 0.0 { 1.0 / inv_eps_tm } else { 1.0 }
  let n_tm = eps_tm.sqrt()

  { n_eff_te: n_te, n_eff_tm: n_tm, birefringence_form: n_te - n_tm }
}
