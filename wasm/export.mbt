///|
/// WASM Export: Compute reflectance R of a single thin film on a substrate
pub fn wasm_solve_single_layer(
  n_film : Double,
  k_film : Double,
  d_nm : Double,
  n_sub : Double,
  wl_nm : Double,
  angle_deg : Double,
) -> Double {
  let air = @mat.air().to_layer(0.0, wl_nm)
  let film = @core.Layer::absorbing("FilmLn", d_nm, n_film, k_film)
  let sub = @core.Layer::real("Substrate", 0.0, n_sub)
  let stack = @core.MultiLayerStack::new(air, [film], sub)
  let angle = @core.IncidentAngle::from_deg(angle_deg)
  let res = @tmm.solve_tmm2d_single(stack, wl_nm, angle)
  res.r_power
}

///|
/// WASM Export: Compute structural color of a thin film as packed 0x00RRGGBB integer
pub fn wasm_estimate_film_color(
  n_film : Double,
  d_nm : Double,
  n_sub : Double,
) -> Int {
  let air = @mat.air().to_layer(0.0, 550.0)
  let film = @core.Layer::real("ColorFilm", d_nm, n_film)
  let sub = @core.Layer::real("Substrate", 0.0, n_sub)
  let stack = @core.MultiLayerStack::new(air, [film], sub)

  let grid = @core.SpectrumGrid::visible_spectrum(41)
  let sim = @tmm.solve_spectrum(stack, grid, @core.IncidentAngle::normal())
  let color = @ana.spectrum_to_color(sim.reflectance)

  (color.srgb_r << 16) | (color.srgb_g << 8) | color.srgb_b
}

///|
/// WASM Export: Invert thin film thickness from measured reflectance array
pub fn wasm_fit_single_layer_thickness(
  measured_r : Array[Double],
  start_wl : Double,
  stop_wl : Double,
  n_film : Double,
  n_sub : Double,
) -> Double {
  let steps = measured_r.length()
  let grid = @core.SpectrumGrid::linear(start_wl, stop_wl, steps)
  let spec_data = @core.SpectrumData::new("Measured", grid, measured_r)
  let sub = @core.Layer::real("Substrate", 0.0, n_sub)

  let fit_res = @inv.fit_single_layer_rn(sub, spec_data, 100.0, n_film)
  fit_res.optimized_parameters[0]
}
