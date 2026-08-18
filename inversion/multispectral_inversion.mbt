///|
/// Multi-Angle Spectroscopic Ellipsometry (VASE) Joint Inversion Target
pub struct MultiAngleEllipsometryData {
  angles_deg : Array[Double] // E.g. [65.0, 70.0, 75.0]
  grid : @core.SpectrumGrid
  measured_psi : Array[Array[Double]] // [angle_idx][wl_idx]
  measured_delta : Array[Array[Double]] // [angle_idx][wl_idx]
}

///|
pub fn MultiAngleEllipsometryData::new(
  angles : Array[Double],
  grid : @core.SpectrumGrid,
  psi_data : Array[Array[Double]],
  delta_data : Array[Array[Double]],
) -> MultiAngleEllipsometryData {
  {
    angles_deg: angles,
    grid,
    measured_psi: psi_data,
    measured_delta: delta_data,
  }
}

///|
/// Joint Inversion of Film Thickness d and Cauchy optical parameters (A, B) using VASE data
pub fn fit_multi_angle_ellipsometry(
  substrate : @core.Layer,
  vase_data : MultiAngleEllipsometryData,
  initial_d_nm : Double,
  initial_a : Double,
  initial_b : Double,
) -> @core.InversionResult {
  let num_angles = vase_data.angles_deg.length()
  let num_wls = vase_data.grid.count()
  let total_residuals = num_angles * num_wls * 2
  let air = @mat.air().to_layer(0.0, 550.0)

  let residual_fn = fn(params : Array[Double]) -> Array[Double] {
    let d = params[0]
    let a = params[1]
    let b = params[2]

    let residuals = Array::new(capacity=total_residuals)

    for ang_idx = 0; ang_idx < num_angles; ang_idx = ang_idx + 1 {
      let angle = @core.IncidentAngle::from_deg(vase_data.angles_deg[ang_idx])

      for wl_idx = 0; wl_idx < num_wls; wl_idx = wl_idx + 1 {
        let wl = vase_data.grid.get(wl_idx)
        let wl_um = wl / 1000.0
        let n = a + b / (wl_um * wl_um)
        let film = @core.Layer::real("FittedFilm", d, n)
        let stack = @core.MultiLayerStack::new(air, [film], substrate)

        let ellip = @tmm.solve_ellipsometry(stack, wl, angle)
        let target_psi = vase_data.measured_psi[ang_idx][wl_idx]
        let target_delta = vase_data.measured_delta[ang_idx][wl_idx]

        // Weighted residual: normalized Psi and Delta differences
        residuals.push((ellip.psi_deg - target_psi) / 45.0)
        residuals.push((ellip.delta_deg - target_delta) / 180.0)
      }
    }

    residuals
  }

  let bounds = [
    ParameterBound::new("Thickness_d", 5.0, 2000.0, initial_d_nm),
    ParameterBound::new("Cauchy_A", 1.1, 3.5, initial_a),
    ParameterBound::new("Cauchy_B", 0.0, 0.08, initial_b),
  ]

  levenberg_marquardt(
    residual_fn,
    [initial_d_nm, initial_a, initial_b],
    bounds,
    100,
    1.0e-7,
  )
}
