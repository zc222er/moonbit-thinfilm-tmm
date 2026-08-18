///|
/// Chirped Dielectric Mirror for Ultrafast Laser Dispersion Compensation
pub struct ChirpedMirrorDesign {
  center_wavelength_nm : Double
  target_gdd_fs2 : Double // Target negative GDD (e.g. -50 fs^2 to -250 fs^2)
  num_layer_pairs : Int
  high_mat : @mat.OpticalMaterial
  low_mat : @mat.OpticalMaterial
  substrate : @core.Layer
}

///|
pub fn ChirpedMirrorDesign::new(
  center_wl : Double,
  target_gdd : Double,
  pairs : Int,
  high_mat : @mat.OpticalMaterial,
  low_mat : @mat.OpticalMaterial,
  substrate : @core.Layer,
) -> ChirpedMirrorDesign {
  {
    center_wavelength_nm: center_wl,
    target_gdd_fs2: target_gdd,
    num_layer_pairs: pairs,
    high_mat,
    low_mat,
    substrate,
  }
}

///|
/// Build Chirped MultiLayerStack with linearly graded physical thickness (Bragg frequency chirp)
pub fn ChirpedMirrorDesign::build_stack(
  self : ChirpedMirrorDesign,
) -> @core.MultiLayerStack {
  let air = @mat.air().to_layer(0.0, self.center_wavelength_nm)
  let n_h = self.high_mat.get_index(self.center_wavelength_nm).re
  let n_l = self.low_mat.get_index(self.center_wavelength_nm).re

  let n_total_layers = self.num_layer_pairs * 2
  let layers = Array::new(capacity=n_total_layers)

  // Linear chirp: shorter wavelengths reflect near front surface, longer wavelengths penetrate deeper
  let lambda_start = self.center_wavelength_nm - 120.0
  let lambda_end = self.center_wavelength_nm + 120.0
  let d_lambda = (lambda_end - lambda_start) /
    (self.num_layer_pairs.to_double() - 1.0)

  for p = 0; p < self.num_layer_pairs; p = p + 1 {
    let local_lambda = lambda_start + d_lambda * p.to_double()
    let d_h = local_lambda / (4.0 * n_h)
    let d_l = local_lambda / (4.0 * n_l)

    layers.push(self.high_mat.to_layer(d_h, local_lambda))
    layers.push(self.low_mat.to_layer(d_l, local_lambda))
  }

  @core.MultiLayerStack::new(air, layers, self.substrate)
}

///|
/// Calculate GDD spectrum across laser bandwidth (e.g. 700 - 900 nm for Ti:Sapphire)
pub fn ChirpedMirrorDesign::simulate_gdd_spectrum(
  self : ChirpedMirrorDesign,
  grid : @core.SpectrumGrid,
) -> Array[@tmm.ChromaticDispersionResult] {
  let stack = self.build_stack()
  let count = grid.count()
  let results = Array::new(capacity=count)

  for i = 0; i < count; i = i + 1 {
    let wl = grid.get(i)
    let gdd_res = @tmm.calculate_gdd(stack, wl, @core.IncidentAngle::normal())
    results.push(gdd_res)
  }

  results
}
