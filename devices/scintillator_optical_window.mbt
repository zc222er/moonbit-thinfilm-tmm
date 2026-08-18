///|
/// Scintillation Crystal Optical Coupling & Light Extraction Efficiency (LEE) Engine
pub struct ScintillatorCouplingSystem {
  scintillator_material : @mat.OpticalMaterial // E.g. LYSO or BGO
  optical_grease_material : @mat.OpticalMaterial // E.g. Optical silicone grease n ~ 1.48
  grease_thickness_um : Double
  photodetector_window_index : Double // E.g. Quartz n = 1.46 or Silicon Photomultiplier (SiPM) n ~ 1.55
}

///|
pub fn ScintillatorCouplingSystem::new(
  scint_mat : @mat.OpticalMaterial,
  grease_mat : @mat.OpticalMaterial,
  grease_um : Double,
  window_n : Double,
) -> ScintillatorCouplingSystem {
  {
    scintillator_material: scint_mat,
    optical_grease_material: grease_mat,
    grease_thickness_um: grease_um,
    photodetector_window_index: window_n,
  }
}

///|
/// Light Extraction Efficiency (LEE) into Photodetector Acceptance Cone
pub fn ScintillatorCouplingSystem::calculate_light_extraction_efficiency(
  self : ScintillatorCouplingSystem,
  scintillation_peak_wavelength_nm : Double,
) -> Double {
  let n_scint = self.scintillator_material.get_index(
      scintillation_peak_wavelength_nm,
    ).re
  let n_grease = self.optical_grease_material.get_index(
      scintillation_peak_wavelength_nm,
    ).re
  let n_win = self.photodetector_window_index

  // Critical angle for total internal reflection inside scintillator: sin(theta_c) = min(n_grease, n_win) / n_scint
  let n_exit = if n_grease < n_win { n_grease } else { n_win }
  let sin_theta_c = if n_exit < n_scint { n_exit / n_scint } else { 1.0 }
  let cos_theta_c = (1.0 - sin_theta_c * sin_theta_c).sqrt()

  // Solid angle escape cone fraction: eta_cone = 0.5 * (1 - cos(theta_c))
  let eta_cone = 0.5 * (1.0 - cos_theta_c)

  // Fresnel transmittance at normal incidence
  let r_scint_grease = (n_scint - n_grease) /
    (n_scint + n_grease) *
    ((n_scint - n_grease) / (n_scint + n_grease))
  let r_grease_win = (n_grease - n_win) /
    (n_grease + n_win) *
    ((n_grease - n_win) / (n_grease + n_win))
  let t_interface = (1.0 - r_scint_grease) * (1.0 - r_grease_win)

  eta_cone * t_interface
}
