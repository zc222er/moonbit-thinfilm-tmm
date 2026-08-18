///|
/// Distributed Bragg Reflector (DBR) Mirror Generator
pub struct DBRDesign {
  center_wavelength_nm : Double
  pairs : Int
  high_index_material : @mat.OpticalMaterial
  low_index_material : @mat.OpticalMaterial
  substrate : @core.Layer
}

///|
pub fn DBRDesign::new(
  center_wavelength_nm : Double,
  pairs : Int,
  high_mat : @mat.OpticalMaterial,
  low_mat : @mat.OpticalMaterial,
  substrate : @core.Layer,
) -> DBRDesign {
  {
    center_wavelength_nm,
    pairs,
    high_index_material: high_mat,
    low_index_material: low_mat,
    substrate,
  }
}

///|
/// Build MultiLayerStack for the DBR
pub fn DBRDesign::build_stack(self : DBRDesign) -> @core.MultiLayerStack {
  let air = @mat.air().to_layer(0.0, self.center_wavelength_nm)
  let n_h = self.high_index_material.get_index(self.center_wavelength_nm).re
  let n_l = self.low_index_material.get_index(self.center_wavelength_nm).re

  let d_h = self.center_wavelength_nm / (4.0 * n_h)
  let d_l = self.center_wavelength_nm / (4.0 * n_l)

  let layers = Array::new(capacity=self.pairs * 2)
  for _i = 0; _i < self.pairs; _i = _i + 1 {
    let layer_h = self.high_index_material.to_layer(
      d_h,
      self.center_wavelength_nm,
    )
    let layer_l = self.low_index_material.to_layer(
      d_l,
      self.center_wavelength_nm,
    )
    layers.push(layer_h)
    layers.push(layer_l)
  }

  @core.MultiLayerStack::new(air, layers, self.substrate)
}

///|
/// Analytical Stopband Width Delta_lambda = (4 / pi) * lambda_0 * arcsin((n_h - n_l) / (n_h + n_l))
pub fn DBRDesign::analytical_stopband_width(self : DBRDesign) -> Double {
  let n_h = self.high_index_material.get_index(self.center_wavelength_nm).re
  let n_l = self.low_index_material.get_index(self.center_wavelength_nm).re
  let frac = (n_h - n_l) / (n_h + n_l)
  let asin_val = @math.asin(frac)
  4.0 / @math.PI * self.center_wavelength_nm * asin_val
}

///|
/// Analytical Peak Reflectivity R_max = ((1 - (n_sub / n_amb)*(n_h/n_l)^(2N)) / (1 + (n_sub / n_amb)*(n_h/n_l)^(2N)))^2
pub fn DBRDesign::analytical_peak_reflectance(self : DBRDesign) -> Double {
  let n_h = self.high_index_material.get_index(self.center_wavelength_nm).re
  let n_l = self.low_index_material.get_index(self.center_wavelength_nm).re
  let n_sub = @tmm.get_layer_isotropic_index(self.substrate).re
  let n_amb = 1.0

  let ratio = n_h / n_l
  let ratio_2n = @math.pow(ratio, (2 * self.pairs).to_double())
  let factor = n_sub / n_amb * ratio_2n
  let r_amp = (1.0 - factor) / (1.0 + factor)
  r_amp * r_amp
}
