///|
test "photometric luminous transmittance calculation" {
  let grid = @core.SpectrumGrid::visible_spectrum(41)
  let count = grid.count()
  let t_arr = Array::new(capacity=count)
  let r_arr = Array::new(capacity=count)
  let a_arr = Array::new(capacity=count)
  let phr_arr = Array::new(capacity=count)
  let pht_arr = Array::new(capacity=count)

  for _i = 0; _i < count; _i = _i + 1 {
    t_arr.push(0.92)
    r_arr.push(0.08)
    a_arr.push(0.0)
    phr_arr.push(0.0)
    pht_arr.push(0.0)
  }

  let sim : @core.SpectralSimulationResult = {
    grid,
    reflectance: @core.SpectrumData::new("R", grid, r_arr),
    transmittance: @core.SpectrumData::new("T", grid, t_arr),
    absorptance: @core.SpectrumData::new("A", grid, a_arr),
    r_te: @core.SpectrumData::new("R_TE", grid, r_arr),
    t_te: @core.SpectrumData::new("T_TE", grid, t_arr),
    r_tm: @core.SpectrumData::new("R_TM", grid, r_arr),
    t_tm: @core.SpectrumData::new("T_TM", grid, t_arr),
    phase_r: @core.SpectrumData::new("Phase_R", grid, phr_arr),
    phase_t: @core.SpectrumData::new("Phase_T", grid, pht_arr),
  }

  let photo = calculate_photometric_quantities(sim)

  assert_true((photo.luminous_transmittance - 0.92).abs() < 0.01)
  assert_true((photo.luminous_reflectance - 0.08).abs() < 0.01)
  assert_true(photo.correlated_color_temperature_k > 3000.0)
}
