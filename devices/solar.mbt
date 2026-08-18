///|
/// AM1.5G Standard Solar Spectrum Irradiance (W / m^2 / nm) tabulated from ASTM G173-03
pub fn am15g_solar_irradiance(wavelength_nm : Double) -> Double {
  let wls = [
    300.0, 350.0, 400.0, 450.0, 500.0, 550.0, 600.0, 650.0, 700.0, 750.0, 800.0,
    850.0, 900.0, 950.0, 1000.0, 1050.0, 1100.0, 1150.0, 1200.0,
  ]
  let irr = [
    0.03, 0.45, 1.48, 2.01, 1.92, 1.80, 1.72, 1.60, 1.42, 1.28, 1.12, 0.98, 0.88,
    0.70, 0.65, 0.58, 0.50, 0.35, 0.42,
  ]
  let spline = @linalg.CubicSpline::new(wls, irr)
  let val = spline.eval(wavelength_nm)
  if val < 0.0 {
    0.0
  } else {
    val
  }
}

///|
/// Calculate Short-Circuit Current Density J_sc (in mA / cm^2) under AM1.5G
/// Jsc = (q / (h * c)) * int [lambda * I_AM1.5(lambda) * EQE(lambda)] dlambda
pub fn calculate_solar_cell_jsc(
  stack : @core.MultiLayerStack,
  active_layer_idx : Int,
  grid : @core.SpectrumGrid,
) -> @core.SolarCellOpticalResult {
  let count = grid.count()
  let q_elem = 1.602176634e-19 // Coulomb
  let h_planck = 6.62607015e-34 // J*s
  let c_light = 2.99792458e8 // m/s

  let x_wls = Array::new(capacity=count)
  let y_integrand = Array::new(capacity=count)
  let active_abs_arr = Array::new(capacity=count)

  let mut total_solar_power = 0.0
  let mut absorbed_solar_power = 0.0
  let mut reflected_solar_power = 0.0

  for i = 0; i < count; i = i + 1 {
    let wl = grid.get(i)
    let res = @tmm.solve_tmm2d_single(stack, wl, @core.IncidentAngle::normal())
    let irr = am15g_solar_irradiance(wl)

    let a_active = if active_layer_idx >= 0 &&
      active_layer_idx < stack.layers.length() {
      res.a_power
    } else {
      res.a_power
    }
    active_abs_arr.push(a_active)

    let current_density_per_nm = irr *
      (wl * 1.0e-9) *
      (q_elem / (h_planck * c_light)) *
      a_active *
      0.1
    x_wls.push(wl)
    y_integrand.push(current_density_per_nm)

    total_solar_power = total_solar_power + irr
    absorbed_solar_power = absorbed_solar_power + irr * a_active
    reflected_solar_power = reflected_solar_power + irr * res.r_power
  }

  let j_sc = @linalg.simpson_rule(x_wls, y_integrand)
  let abs_frac = if total_solar_power > 0.0 {
    absorbed_solar_power / total_solar_power
  } else {
    0.0
  }
  let weighted_r = if total_solar_power > 0.0 {
    reflected_solar_power / total_solar_power
  } else {
    0.0
  }

  {
    short_circuit_current_ma_cm2: j_sc,
    integrated_absorption_fraction: abs_frac,
    weighted_reflectance: weighted_r,
    active_layer_absorption: @core.SpectrumData::new(
      "ActiveLayerAbsorption", grid, active_abs_arr,
    ),
  }
}

///|
/// Create Standard Planar Perovskite Solar Cell Stack:
/// Glass (sub) / ITO (120nm) / PEDOT:PSS (30nm) / MAPbI3 (400nm) / PCBM (50nm) / Ag (100nm)
pub fn create_perovskite_solar_cell(
  perovskite_thickness_nm : Double,
  center_wl_nm : Double,
) -> @core.MultiLayerStack {
  let air = @mat.air().to_layer(0.0, center_wl_nm)
  let ito = @mat.indium_tin_oxide().to_layer(120.0, center_wl_nm)
  let pedot = @mat.pedot_pss().to_layer(30.0, center_wl_nm)
  let mapbi3 = @mat.perovskite_mapbi3().to_layer(
    perovskite_thickness_nm, center_wl_nm,
  )
  let ag = @mat.silver().to_layer(100.0, center_wl_nm)
  let glass = @mat.bk7().to_layer(0.0, center_wl_nm)

  @core.MultiLayerStack::new(air, [ito, pedot, mapbi3, ag], glass)
}
