///|
/// Architectural Low-Emissivity (Low-E) Double/Triple Glazing Coating Engine
pub struct LowEGlazingDesign {
  silver_layer_thickness_nm : Double // 10 - 15 nm Ag thin film
  dielectric_bottom_thickness_nm : Double // 30 nm TiO2 or Si3N4
  dielectric_top_thickness_nm : Double // 35 nm TiO2 or Si3N4
  gas_gap_thickness_mm : Double // 12 - 16 mm Argon gas gap
}

///|
pub fn LowEGlazingDesign::new(
  ag_nm : Double,
  d_bot_nm : Double,
  d_top_nm : Double,
  gap_mm : Double,
) -> LowEGlazingDesign {
  {
    silver_layer_thickness_nm: ag_nm,
    dielectric_bottom_thickness_nm: d_bot_nm,
    dielectric_top_thickness_nm: d_top_nm,
    gas_gap_thickness_mm: gap_mm,
  }
}

///|
/// Thermal & Optical Window Glazing Metrics
pub struct GlazingPerformanceMetrics {
  visible_transmittance_tv : Double // Visible light transmittance (T_v ~ 70 - 80%)
  solar_heat_gain_coefficient_shgc : Double // SHGC / g-value (0.35 - 0.50)
  thermal_emissivity_ir : Double // Long-wave thermal emissivity (epsilon < 0.04 for Low-E)
  u_value_w_m2k : Double // Center-of-glass thermal conductance (U ~ 1.1 - 1.4 W/m^2/K)
} derive(Eq)

///|
pub impl Show for GlazingPerformanceMetrics with fn output(self, logger) {
  logger.write_string(
    "LowEMetrics(Tv=\{self.visible_transmittance_tv * 100.0}%, SHGC=\{self.solar_heat_gain_coefficient_shgc}, emissivity=\{self.thermal_emissivity_ir}, U=\{self.u_value_w_m2k} W/m²K)",
  )
}

///|
/// Calculate Glazing Performance Metrics
pub fn LowEGlazingDesign::evaluate_glazing(
  self : LowEGlazingDesign,
  grid : @core.SpectrumGrid,
) -> GlazingPerformanceMetrics {
  let air = @mat.air().to_layer(0.0, 550.0)
  let glass = @mat.bk7().to_layer(0.0, 550.0)
  let tio2 = @mat.titanium_dioxide()
  let ag = @mat.silver()

  // Symmetrical D/M/D Low-E stack: Glass / TiO2 (30nm) / Ag (12nm) / TiO2 (35nm) / Air
  let l1 = tio2.to_layer(self.dielectric_bottom_thickness_nm, 550.0)
  let l2 = ag.to_layer(self.silver_layer_thickness_nm, 550.0)
  let l3 = tio2.to_layer(self.dielectric_top_thickness_nm, 550.0)

  let stack = @core.MultiLayerStack::new(air, [l3, l2, l1], glass)
  let sim = @tmm.solve_spectrum(stack, grid, @core.IncidentAngle::normal())

  let tv = sim.transmittance.interpolate_linear(550.0)
  let r_sol = sim.reflectance.interpolate_linear(900.0)
  let shgc = (1.0 - r_sol) * 0.78

  // Emissivity of continuous 12nm silver layer: epsilon ~ 0.035
  let eps_ir = 0.035
  let u_val = 1.25 // W / (m^2 * K) with Argon gas gap

  {
    visible_transmittance_tv: tv,
    solar_heat_gain_coefficient_shgc: shgc,
    thermal_emissivity_ir: eps_ir,
    u_value_w_m2k: u_val,
  }
}
