///|
// ============================================================================
// Acousto-Optic Modulator Crystals (TeO2, PbMoO4) & Acousto-Optic Figure of Merit
// Precision photoelastic coefficients & acoustic velocity
// ============================================================================

///|
pub struct AcoustoOpticProperties {
  material_name : String
  acoustic_velocity_m_s : Double // v_a (e.g. 616 m/s for slow shear TeO2)
  figure_of_merit_m2_10_15_s3_kg : Double // M_2 figure of merit (e.g. 793 for TeO2, 36 for PbMoO4)
  center_index : Double
} derive(Eq)

///|
pub fn teo2_paratellurite_acousto_optic() -> AcoustoOpticProperties {
  // TeO2 (Paratellurite) slow shear wave high-efficiency AOM crystal (M2 ~ 793 x 10^-15 s^3/kg)
  {
    material_name: "TeO2 (Paratellurite)",
    acoustic_velocity_m_s: 616.0,
    figure_of_merit_m2_10_15_s3_kg: 793.0,
    center_index: 2.26,
  }
}

///|
pub fn pbmso4_lead_molybdate_acousto_optic() -> AcoustoOpticProperties {
  // PbMoO4 (Lead Molybdate) standard laser Q-switch AOM crystal (M2 ~ 36 x 10^-15 s^3/kg)
  {
    material_name: "PbMoO4 (Lead Molybdate)",
    acoustic_velocity_m_s: 3630.0,
    figure_of_merit_m2_10_15_s3_kg: 36.0,
    center_index: 2.39,
  }
}
