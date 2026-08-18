///|
/// Superconducting Nanowire Single-Photon Detector (SNSPD) Optical Cavity Engine
pub struct SNSPDCavityDesign {
  nanowire_thickness_nm : Double // ~ 5 - 8 nm NbN or WSi
  nanowire_fill_factor : Double // Nanowire meander pitch fill factor f ~ 0.50
  dielectric_spacer_thickness_nm : Double // Quarter-wave SiO2 spacer (~ 250 nm for 1550 nm)
  gold_mirror_thickness_nm : Double // ~ 100 nm Au back reflector
  target_wavelength_nm : Double // 1550 nm telecom C-band
}

///|
pub fn SNSPDCavityDesign::standard_telecom_1550nm() -> SNSPDCavityDesign {
  {
    nanowire_thickness_nm: 6.0,
    nanowire_fill_factor: 0.50,
    dielectric_spacer_thickness_nm: 250.0,
    gold_mirror_thickness_nm: 100.0,
    target_wavelength_nm: 1550.0,
  }
}

///|
/// SNSPD System Absorption & System Detection Efficiency (SDE)
pub struct SNSPDPerformanceResult {
  nanowire_optical_absorption : Double // Target A > 90%
  stack_reflectance : Double
  system_detection_efficiency_estimate : Double // SDE = A * P_internal (~ 95% * 98% ~ 93%)
} derive(Eq)

///|
pub impl Show for SNSPDPerformanceResult with fn output(self, logger) {
  logger.write_string(
    "SNSPDResult(Absorption=\{self.nanowire_optical_absorption * 100.0}%, Reflectance=\{self.stack_reflectance * 100.0}%, SDE=\{self.system_detection_efficiency_estimate * 100.0}%)",
  )
}

///|
/// Calculate Cavity Optical Absorption for SNSPD
pub fn SNSPDCavityDesign::calculate_optical_performance(
  self : SNSPDCavityDesign,
) -> SNSPDPerformanceResult {
  let wl = self.target_wavelength_nm
  let air = @mat.air().to_layer(0.0, wl)
  let sub = @mat.crystalline_silicon().to_layer(0.0, wl)

  // Nanowire effective index via Maxwell Garnett EMT
  let nbn_mat = @mat.nbn_superconductor_normal_state()
  let n_nbn = nbn_mat.get_index(wl)
  let f = self.nanowire_fill_factor

  // Effective layer index
  let n_eff_re = 1.0 + f * (n_nbn.re - 1.0)
  let n_eff_im = f * n_nbn.im
  let nanowire_layer = @core.Layer::absorbing(
    "NbN_Nanowire_Meander",
    self.nanowire_thickness_nm,
    n_eff_re,
    n_eff_im,
  )

  let sio2 = @mat.fused_silica().to_layer(
    self.dielectric_spacer_thickness_nm,
    wl,
  )
  let au = @mat.gold().to_layer(self.gold_mirror_thickness_nm, wl)

  // Stack: Air / Nanowire / SiO2 / Au / Si
  let stack = @core.MultiLayerStack::new(air, [nanowire_layer, sio2, au], sub)
  let res = @tmm.solve_tmm2d_single(stack, wl, @core.IncidentAngle::normal())

  // Absorption in thin nanowire meander
  let a_nano = res.a_power * 0.95

  {
    nanowire_optical_absorption: a_nano,
    stack_reflectance: res.r_power,
    system_detection_efficiency_estimate: a_nano * 0.98,
  }
}
