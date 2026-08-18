///|
/// Invert Single Layer Thickness and Refractive Index (d, n) from measured Reflectance Spectrum
pub fn fit_single_layer_rn(
  substrate : @core.Layer,
  target_spectrum : @core.SpectrumData,
  initial_d_nm : Double,
  initial_n : Double,
) -> @core.InversionResult {
  let grid = target_spectrum.grid
  let count = grid.count()
  let air = @mat.air().to_layer(0.0, 550.0)

  // Residual function r_i = R_calc(lambda_i; d, n) - R_target(lambda_i)
  let residual_fn = fn(params : Array[Double]) -> Array[Double] {
    let d = params[0]
    let n = params[1]
    let film = @core.Layer::real("FittedFilm", d, n)
    let stack = @core.MultiLayerStack::new(air, [film], substrate)

    let res_arr = Array::new(capacity=count)
    for i = 0; i < count; i = i + 1 {
      let wl = grid.get(i)
      let calc_res = @tmm.solve_tmm2d_single(
        stack,
        wl,
        @core.IncidentAngle::normal(),
      )
      let r_target = target_spectrum.get(i)
      res_arr.push(calc_res.r_power - r_target)
    }
    res_arr
  }

  let bounds = [
    ParameterBound::new("Thickness_d", 5.0, 2000.0, initial_d_nm),
    ParameterBound::new("RefractiveIndex_n", 1.1, 4.5, initial_n),
  ]

  levenberg_marquardt(
    residual_fn,
    [initial_d_nm, initial_n],
    bounds,
    60,
    1.0e-7,
  )
}

///|
/// Invert Cauchy dispersion parameters (A, B, d) from measured Reflectance Spectrum
pub fn fit_cauchy_film(
  substrate : @core.Layer,
  target_spectrum : @core.SpectrumData,
  initial_d : Double,
  initial_a : Double,
  initial_b : Double,
) -> @core.InversionResult {
  let grid = target_spectrum.grid
  let count = grid.count()
  let air = @mat.air().to_layer(0.0, 550.0)

  let residual_fn = fn(params : Array[Double]) -> Array[Double] {
    let d = params[0]
    let a = params[1]
    let b = params[2]

    let res_arr = Array::new(capacity=count)
    for i = 0; i < count; i = i + 1 {
      let wl = grid.get(i)
      let wl_um = wl / 1000.0
      let n = a + b / (wl_um * wl_um)
      let film = @core.Layer::real("CauchyFilm", d, n)
      let stack = @core.MultiLayerStack::new(air, [film], substrate)
      let calc_res = @tmm.solve_tmm2d_single(
        stack,
        wl,
        @core.IncidentAngle::normal(),
      )
      let r_target = target_spectrum.get(i)
      res_arr.push(calc_res.r_power - r_target)
    }
    res_arr
  }

  let bounds = [
    ParameterBound::new("Thickness_d", 10.0, 1500.0, initial_d),
    ParameterBound::new("Cauchy_A", 1.2, 3.0, initial_a),
    ParameterBound::new("Cauchy_B", 0.0, 0.05, initial_b),
  ]

  levenberg_marquardt(
    residual_fn,
    [initial_d, initial_a, initial_b],
    bounds,
    80,
    1.0e-7,
  )
}
