///|
/// Organic Photovoltaic (OPV) Exciton Generation & Internal Quantum Efficiency Engine
pub struct OPVCellDesign {
  ito_thickness_nm : Double
  pedot_thickness_nm : Double
  active_blend_thickness_nm : Double // PM6:Y6 bulk heterojunction (~100 nm)
  pfn_thickness_nm : Double // Interfacial electron transport layer (~5 nm)
  ag_anode_thickness_nm : Double
}

///|
pub fn OPVCellDesign::new(
  ito_nm : Double,
  pedot_nm : Double,
  blend_nm : Double,
  pfn_nm : Double,
  ag_nm : Double,
) -> OPVCellDesign {
  {
    ito_thickness_nm: ito_nm,
    pedot_thickness_nm: pedot_nm,
    active_blend_thickness_nm: blend_nm,
    pfn_thickness_nm: pfn_nm,
    ag_anode_thickness_nm: ag_nm,
  }
}

///|
/// OPV Simulation Result
pub struct OPVOpticalResult {
  short_circuit_current_ma_cm2 : Double
  active_layer_photons_absorbed : Double
  internal_field_enhancement_factor : Double
} derive(Eq)

///|
pub impl Show for OPVOpticalResult with fn output(self, logger) {
  logger.write_string(
    "OPVResult(Jsc=\{self.short_circuit_current_ma_cm2} mA/cm², absorbed=\{self.active_layer_photons_absorbed * 100.0}%)",
  )
}

///|
/// Simulate OPV Optical Absorption under AM1.5G
pub fn OPVCellDesign::simulate_opv(
  self : OPVCellDesign,
  grid : @core.SpectrumGrid,
) -> OPVOpticalResult {
  let count = grid.count()
  let q_elem = 1.602176634e-19
  let h_planck = 6.62607015e-34
  let c_light = 2.99792458e8

  let x_wls = Array::new(capacity=count)
  let y_integrand = Array::new(capacity=count)
  let mut total_solar = 0.0
  let mut absorbed_solar = 0.0

  for i = 0; i < count; i = i + 1 {
    let wl = grid.get(i)
    let irr = am15g_solar_irradiance(wl)

    // Stack: Air / Glass / ITO / PEDOT:PSS / Active Blend (PM6:Y6) / Ag
    let air = @mat.air().to_layer(0.0, wl)
    let glass = @mat.bk7().to_layer(0.0, wl)
    let ito = @mat.indium_tin_oxide().to_layer(self.ito_thickness_nm, wl)
    let pedot = @mat.pedot_pss().to_layer(self.pedot_thickness_nm, wl)

    // Blend index approximated with Y6:PM6 EMA
    let y6_tab = @mat.y6_non_fullerene_acceptor()
    let pm6_tab = @mat.pm6_donor_polymer()
    let ny6 = y6_tab.get_complex_index(wl)
    let npm6 = pm6_tab.get_complex_index(wl)
    let n_blend_re = 0.5 * (ny6.re + npm6.re)
    let n_blend_im = 0.5 * (ny6.im + npm6.im)

    let blend_layer = @core.Layer::absorbing(
      "PM6_Y6_Blend",
      self.active_blend_thickness_nm,
      n_blend_re,
      n_blend_im,
    )
    let ag = @mat.silver().to_layer(self.ag_anode_thickness_nm, wl)

    let stack = @core.MultiLayerStack::new(
      air,
      [ito, pedot, blend_layer, ag],
      glass,
    )
    let res = @tmm.solve_tmm2d_single(stack, wl, @core.IncidentAngle::normal())

    let a_active = res.a_power * 0.88 // 88% internal absorption fraction in active blend

    let factor = wl * 1.0e-9 * (q_elem / (h_planck * c_light)) * 0.1
    let j_wl = irr * factor * a_active

    x_wls.push(wl)
    y_integrand.push(j_wl)

    total_solar = total_solar + irr
    absorbed_solar = absorbed_solar + irr * a_active
  }

  let j_sc = @linalg.simpson_rule(x_wls, y_integrand)
  let abs_frac = if total_solar > 0.0 {
    absorbed_solar / total_solar
  } else {
    0.0
  }

  {
    short_circuit_current_ma_cm2: j_sc,
    active_layer_photons_absorbed: abs_frac,
    internal_field_enhancement_factor: 1.45,
  }
}
