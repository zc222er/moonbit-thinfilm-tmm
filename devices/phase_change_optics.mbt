///|
/// Phase-Change Optical Switch & Thermochromic Smart Window Engine
pub struct PhaseChangeSwitch {
  pcm_film_thickness_nm : Double
  top_capping_thickness_nm : Double
  bottom_reflector_thickness_nm : Double
  substrate : @core.Layer
}

///|
pub fn PhaseChangeSwitch::new(
  pcm_nm : Double,
  capping_nm : Double,
  reflector_nm : Double,
  sub : @core.Layer,
) -> PhaseChangeSwitch {
  {
    pcm_film_thickness_nm: pcm_nm,
    top_capping_thickness_nm: capping_nm,
    bottom_reflector_thickness_nm: reflector_nm,
    substrate: sub,
  }
}

///|
/// Dynamic Optical Contrast Result
pub struct PhaseChangeContrastResult {
  wavelength_nm : Double
  reflectance_state_0 : Double // E.g. Amorphous / Insulating
  reflectance_state_1 : Double // E.g. Crystalline / Metallic
  contrast_ratio_db : Double // 10 * log10(R1 / R0)
  absolute_modulation_depth : Double // abs(R1 - R0)
} derive(Eq)

///|
pub impl Show for PhaseChangeContrastResult with fn output(self, logger) {
  logger.write_string(
    "PCMContrast(@\{self.wavelength_nm}nm: R0=\{self.reflectance_state_0}, R1=\{self.reflectance_state_1}, Delta_R=\{self.absolute_modulation_depth}, CR=\{self.contrast_ratio_db} dB)",
  )
}

///|
/// Calculate Dynamic Optical Contrast between Amorphous and Crystalline GST States
pub fn PhaseChangeSwitch::calculate_gst_contrast(
  self : PhaseChangeSwitch,
  wavelength_nm : Double,
) -> PhaseChangeContrastResult {
  let air = @mat.air().to_layer(0.0, wavelength_nm)
  let al2o3 = @mat.aluminum_oxide().to_layer(
    self.top_capping_thickness_nm,
    wavelength_nm,
  )
  let ag = @mat.silver().to_layer(
    self.bottom_reflector_thickness_nm,
    wavelength_nm,
  )

  let gst_amor_tab = @mat.gst225_amorphous_phase()
  let gst_crys_tab = @mat.gst225_crystalline_phase()

  let n_amor = gst_amor_tab.get_complex_index(wavelength_nm)
  let n_crys = gst_crys_tab.get_complex_index(wavelength_nm)

  let layer_amor = @core.Layer::absorbing(
    "GST_Amorphous",
    self.pcm_film_thickness_nm,
    n_amor.re,
    n_amor.im,
  )
  let layer_crys = @core.Layer::absorbing(
    "GST_Crystalline",
    self.pcm_film_thickness_nm,
    n_crys.re,
    n_crys.im,
  )

  let stack_0 = @core.MultiLayerStack::new(
    air,
    [al2o3, layer_amor, ag],
    self.substrate,
  )
  let stack_1 = @core.MultiLayerStack::new(
    air,
    [al2o3, layer_crys, ag],
    self.substrate,
  )

  let res_0 = @tmm.solve_tmm2d_single(
    stack_0,
    wavelength_nm,
    @core.IncidentAngle::normal(),
  )
  let res_1 = @tmm.solve_tmm2d_single(
    stack_1,
    wavelength_nm,
    @core.IncidentAngle::normal(),
  )

  let r0 = res_0.r_power
  let r1 = res_1.r_power
  let delta_r = (r1 - r0).abs()
  let cr_db = if r0 > 1.0e-5 && r1 > 1.0e-5 {
    10.0 * (@math.ln(r1) - @math.ln(r0)) / @math.ln(10.0)
  } else {
    20.0
  }

  {
    wavelength_nm,
    reflectance_state_0: r0,
    reflectance_state_1: r1,
    contrast_ratio_db: cr_db,
    absolute_modulation_depth: delta_r,
  }
}
