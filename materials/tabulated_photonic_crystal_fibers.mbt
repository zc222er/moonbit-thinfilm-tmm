///|
// ============================================================================
// Photonic Crystal Fibers (PCF) & Nonlinear Silica Database
// Effective index and anomalous dispersion zero-dispersion wavelengths
// ============================================================================

///|
pub struct PCFCladdingGeometry {
  pitch_period_um : Double // Hole-to-hole pitch Lambda (e.g. 2.0 - 5.0 um)
  hole_diameter_over_pitch : Double // d / Lambda (0.2 to 0.8)
  core_material : OpticalMaterial
}

///|
pub fn PCFCladdingGeometry::new(
  pitch : Double,
  d_over_lambda : Double,
  core : OpticalMaterial,
) -> PCFCladdingGeometry {
  {
    pitch_period_um: pitch,
    hole_diameter_over_pitch: d_over_lambda,
    core_material: core,
  }
}

///|
/// Effective V-parameter for Endlessly Single-Mode Guidance: V_eff = (2*pi*Lambda/lambda) * sqrt(n_core^2 - n_fsm^2) <= pi
pub fn PCFCladdingGeometry::is_endlessly_single_mode(
  self : PCFCladdingGeometry,
) -> Bool {
  // Saitoh & Koshiba criterion: d / Lambda <= 0.44 ensures endlessly single mode for all wavelengths
  self.hole_diameter_over_pitch <= 0.44
}
