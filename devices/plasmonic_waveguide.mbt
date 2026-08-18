///|
/// Metal-Insulator-Metal (MIM) Nanoplasmonic Waveguide Engine
pub struct MIMWaveguide {
  insulator_gap_nm : Double // Dielectric core thickness w (10 nm - 100 nm)
  insulator_material : @mat.OpticalMaterial // E.g. SiO2, Air, or polymer
  metal_cladding_material : @mat.OpticalMaterial // E.g. Silver Ag or Gold Au
}

///|
pub fn MIMWaveguide::new(
  gap_nm : Double,
  insulator : @mat.OpticalMaterial,
  metal : @mat.OpticalMaterial,
) -> MIMWaveguide {
  {
    insulator_gap_nm: gap_nm,
    insulator_material: insulator,
    metal_cladding_material: metal,
  }
}

///|
/// MIM Mode Dispersion Result
pub struct MIMModeResult {
  wavelength_nm : Double
  effective_index_re : Double // n_eff = Re(beta / k0)
  effective_index_im : Double // k_eff = Im(beta / k0)
  propagation_length_um : Double // L_spp = 1 / (2 * Im(beta))
  skin_depth_metal_nm : Double // 1 / Re(k_z,metal)
  confinement_factor : Double
} derive(Eq)

///|
pub impl Show for MIMModeResult with fn output(self, logger) {
  logger.write_string(
    "MIMMode(n_eff=\{self.effective_index_re} + \{self.effective_index_im}i, L_spp=\{self.propagation_length_um} um, skin_depth=\{self.skin_depth_metal_nm} nm)",
  )
}

///|
/// Solve fundamental even TM plasmonic mode in MIM waveguide
pub fn MIMWaveguide::solve_fundamental_mode(
  self : MIMWaveguide,
  wavelength_nm : Double,
) -> MIMModeResult {
  let n_d = self.insulator_material.get_index(wavelength_nm).re
  let eps_d = n_d * n_d
  let eps_m = self.metal_cladding_material.get_index(wavelength_nm)
  let eps_m_c = eps_m.mul(eps_m)

  // Analytical approximation for subwavelength MIM gap:
  // tanh(k_d * w / 2) = - eps_d * k_m / (eps_m * k_d)
  // For small w: n_eff ~ sqrt(eps_d) * sqrt(1 + 2 * delta_p / w)
  let k0 = 2.0 * @math.PI / wavelength_nm
  let abs_eps_m_re = if eps_m_c.re < 0.0 { -eps_m_c.re } else { 1.0 }
  let delta_p = 1.0 / (k0 * (abs_eps_m_re - eps_d).sqrt())

  let neff_re = (eps_d * (1.0 + 2.0 * delta_p / self.insulator_gap_nm)).sqrt()
  let loss_factor = eps_m_c.im / (2.0 * abs_eps_m_re * abs_eps_m_re)
  let neff_im = neff_re * loss_factor * 0.5

  let beta_im = k0 * neff_im
  let l_spp_um = if beta_im > 0.0 {
    1.0 / (2.0 * beta_im) * 0.001
  } else {
    100.0
  }
  let skin_d_nm = wavelength_nm / (2.0 * @math.PI) / abs_eps_m_re.sqrt()

  {
    wavelength_nm,
    effective_index_re: neff_re,
    effective_index_im: neff_im,
    propagation_length_um: l_spp_um,
    skin_depth_metal_nm: skin_d_nm,
    confinement_factor: 0.95,
  }
}
