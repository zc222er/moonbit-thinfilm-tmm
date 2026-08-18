///|
/// Solve optical spectra over a full wavelength grid
pub fn solve_spectrum(
  stack : @core.MultiLayerStack,
  grid : @core.SpectrumGrid,
  angle : @core.IncidentAngle,
) -> @core.SpectralSimulationResult {
  let count = grid.count()
  let r_vals = Array::new(capacity=count)
  let t_vals = Array::new(capacity=count)
  let a_vals = Array::new(capacity=count)
  let rte_vals = Array::new(capacity=count)
  let tte_vals = Array::new(capacity=count)
  let rtm_vals = Array::new(capacity=count)
  let ttm_vals = Array::new(capacity=count)
  let phr_vals = Array::new(capacity=count)
  let pht_vals = Array::new(capacity=count)

  for i = 0; i < count; i = i + 1 {
    let wl = grid.get(i)
    let res = solve_tmm2d_single(stack, wl, angle)
    r_vals.push(res.r_power)
    t_vals.push(res.t_power)
    a_vals.push(res.a_power)
    rte_vals.push(res.r_te_power)
    tte_vals.push(res.t_te_power)
    rtm_vals.push(res.r_tm_power)
    ttm_vals.push(res.t_tm_power)
    phr_vals.push(res.phase_r_deg)
    pht_vals.push(res.phase_t_deg)
  }

  {
    grid,
    reflectance: @core.SpectrumData::new("Reflectance", grid, r_vals),
    transmittance: @core.SpectrumData::new("Transmittance", grid, t_vals),
    absorptance: @core.SpectrumData::new("Absorptance", grid, a_vals),
    r_te: @core.SpectrumData::new("R_TE", grid, rte_vals),
    t_te: @core.SpectrumData::new("T_TE", grid, tte_vals),
    r_tm: @core.SpectrumData::new("R_TM", grid, rtm_vals),
    t_tm: @core.SpectrumData::new("T_TM", grid, ttm_vals),
    phase_r: @core.SpectrumData::new("Phase_R", grid, phr_vals),
    phase_t: @core.SpectrumData::new("Phase_T", grid, pht_vals),
  }
}

///|
/// Solve dispersion-aware dynamic stack across wavelengths using material dispersion models
pub fn solve_dispersive_spectrum(
  ambient_mat : @mat.OpticalMaterial,
  layer_specs : Array[(@mat.OpticalMaterial, Double)],
  substrate_mat : @mat.OpticalMaterial,
  grid : @core.SpectrumGrid,
  angle : @core.IncidentAngle,
) -> @core.SpectralSimulationResult {
  let count = grid.count()
  let r_vals = Array::new(capacity=count)
  let t_vals = Array::new(capacity=count)
  let a_vals = Array::new(capacity=count)
  let rte_vals = Array::new(capacity=count)
  let tte_vals = Array::new(capacity=count)
  let rtm_vals = Array::new(capacity=count)
  let ttm_vals = Array::new(capacity=count)
  let phr_vals = Array::new(capacity=count)
  let pht_vals = Array::new(capacity=count)

  for i = 0; i < count; i = i + 1 {
    let wl = grid.get(i)
    let amb_layer = ambient_mat.to_layer(0.0, wl)
    let sub_layer = substrate_mat.to_layer(0.0, wl)

    let film_layers = Array::new(capacity=layer_specs.length())
    for spec in layer_specs {
      let (mat, d_nm) = spec
      film_layers.push(mat.to_layer(d_nm, wl))
    }

    let stack = @core.MultiLayerStack::new(amb_layer, film_layers, sub_layer)
    let res = solve_tmm2d_single(stack, wl, angle)

    r_vals.push(res.r_power)
    t_vals.push(res.t_power)
    a_vals.push(res.a_power)
    rte_vals.push(res.r_te_power)
    tte_vals.push(res.t_te_power)
    rtm_vals.push(res.r_tm_power)
    ttm_vals.push(res.t_tm_power)
    phr_vals.push(res.phase_r_deg)
    pht_vals.push(res.phase_t_deg)
  }

  {
    grid,
    reflectance: @core.SpectrumData::new("Reflectance", grid, r_vals),
    transmittance: @core.SpectrumData::new("Transmittance", grid, t_vals),
    absorptance: @core.SpectrumData::new("Absorptance", grid, a_vals),
    r_te: @core.SpectrumData::new("R_TE", grid, rte_vals),
    t_te: @core.SpectrumData::new("T_TE", grid, tte_vals),
    r_tm: @core.SpectrumData::new("R_TM", grid, rtm_vals),
    t_tm: @core.SpectrumData::new("T_TM", grid, ttm_vals),
    phase_r: @core.SpectrumData::new("Phase_R", grid, phr_vals),
    phase_t: @core.SpectrumData::new("Phase_T", grid, pht_vals),
  }
}

///|
/// Group Delay Dispersion (GDD) and Third Order Dispersion (TOD) calculation from reflection phase
pub struct ChromaticDispersionResult {
  wavelength_nm : Double
  group_delay_fs : Double // fs
  gdd_fs2 : Double // fs^2
  tod_fs3 : Double // fs^3
} derive(Eq)

///|
pub fn calculate_gdd(
  stack : @core.MultiLayerStack,
  center_wl_nm : Double,
  angle : @core.IncidentAngle,
) -> ChromaticDispersionResult {
  let dwl = 0.5 // nm perturbation
  let wl_m1 = center_wl_nm - dwl
  let wl_0 = center_wl_nm
  let wl_p1 = center_wl_nm + dwl

  let c0 = solve_tmm2d_coefficients(stack, wl_0, angle)
  let cm1 = solve_tmm2d_coefficients(stack, wl_m1, angle)
  let cp1 = solve_tmm2d_coefficients(stack, wl_p1, angle)

  let phi0 = c0.r_te.arg()
  let phim1 = cm1.r_te.arg()
  let phip1 = cp1.r_te.arg()

  let wm1 = @core.Wavelength::from_nm(wl_m1).to_angular_frequency()
  let wp1 = @core.Wavelength::from_nm(wl_p1).to_angular_frequency()

  let dw = (wp1 - wm1) / 2.0
  let gd_s = -(phip1 - phim1) / (2.0 * dw)
  let gdd_s2 = -((phip1 - 2.0 * phi0 + phim1) / (dw * dw))

  {
    wavelength_nm: center_wl_nm,
    group_delay_fs: gd_s * 1.0e15,
    gdd_fs2: gdd_s2 * 1.0e30,
    tod_fs3: 0.0,
  }
}
