///|
/// Nanoparticle-on-Mirror (NPoM) Plasmonic Picocavity Engine
pub struct NPoMNanocavity {
  nanoparticle_radius_nm : Double // R ~ 40 nm Au NP
  molecular_gap_nm : Double // d ~ 1 - 2 nm self-assembled monolayer
  gap_refractive_index : Double // n_gap ~ 1.45
  metal_substrate : @mat.OpticalMaterial // E.g. Single-crystal Au film
}

///|
pub fn NPoMNanocavity::new(
  radius_nm : Double,
  gap_nm : Double,
  n_gap : Double,
  metal : @mat.OpticalMaterial,
) -> NPoMNanocavity {
  {
    nanoparticle_radius_nm: radius_nm,
    molecular_gap_nm: gap_nm,
    gap_refractive_index: n_gap,
    metal_substrate: metal,
  }
}

///|
/// Local Field Enhancement & SERS Enhancement Factor Result
pub struct NanocavityEnhancementResult {
  coupled_plasmon_resonance_nm : Double
  electric_field_enhancement : Double // |E / E0| in the junction (> 100)
  sers_enhancement_factor : Double // EF ~ |E / E0|^4 (> 10^8)
  mode_volume_nm3 : Double // V_eff << 100 nm^3
} derive(Eq)

///|
pub impl Show for NanocavityEnhancementResult with fn output(self, logger) {
  logger.write_string(
    "NPoM(Resonance=\{self.coupled_plasmon_resonance_nm} nm, Field_Enhancement=\{self.electric_field_enhancement}x, SERS_EF=\{self.sers_enhancement_factor}, V_mode=\{self.mode_volume_nm3} nm³)",
  )
}

///|
/// Calculate Plasmonic Cavity Resonance & SERS Enhancement
pub fn NPoMNanocavity::calculate_enhancement(
  self : NPoMNanocavity,
) -> NanocavityEnhancementResult {
  // Analytical transformation optics formula for NPoM:
  // lambda_res ~ lambda_sp * sqrt( 1 + 2 * (R / d) * (n_gap^2 / eps_infinity) )
  let r_over_d = self.nanoparticle_radius_nm / self.molecular_gap_nm
  let lambda_res = 520.0 * (1.0 + 0.18 * r_over_d.sqrt())

  // Field enhancement in sub-nanometer gap: |E / E0| ~ sqrt(R / d) * (eps_m / eps_gap)
  let e_enh = 12.0 * r_over_d.sqrt()
  let sers_ef = e_enh * e_enh * e_enh * e_enh

  // Effective mode volume V_eff ~ pi * (R * d) * d
  let v_eff = @math.PI *
    self.nanoparticle_radius_nm *
    self.molecular_gap_nm *
    self.molecular_gap_nm

  {
    coupled_plasmon_resonance_nm: lambda_res,
    electric_field_enhancement: e_enh,
    sers_enhancement_factor: sers_ef,
    mode_volume_nm3: v_eff,
  }
}
