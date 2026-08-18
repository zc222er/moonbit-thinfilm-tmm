///|
/// MacNeille Polarizing Beam Splitter (PBS) Prism Coating Engine
pub struct MacNeillePBSDesign {
  center_wavelength_nm : Double
  prism_glass : @mat.OpticalMaterial
  high_index_mat : @mat.OpticalMaterial
  low_index_mat : @mat.OpticalMaterial
  num_pairs : Int
}

///|
pub fn MacNeillePBSDesign::new(
  center_wl : Double,
  prism : @mat.OpticalMaterial,
  high_mat : @mat.OpticalMaterial,
  low_mat : @mat.OpticalMaterial,
  pairs : Int,
) -> MacNeillePBSDesign {
  {
    center_wavelength_nm: center_wl,
    prism_glass: prism,
    high_index_mat: high_mat,
    low_index_mat: low_mat,
    num_pairs: pairs,
  }
}

///|
/// Brewster condition matching: sin^2(theta_p) = (n_H * n_L)^2 / (n_prism^2 * (n_H^2 + n_L^2))
pub fn MacNeillePBSDesign::calculate_brewster_angle_in_prism(
  self : MacNeillePBSDesign,
) -> Double {
  let n_p = self.prism_glass.get_index(self.center_wavelength_nm).re
  let n_h = self.high_index_mat.get_index(self.center_wavelength_nm).re
  let n_l = self.low_index_mat.get_index(self.center_wavelength_nm).re

  let num = n_h * n_l * (n_h * n_l)
  let denom = n_p * n_p * (n_h * n_h + n_l * n_l)
  let sin2_theta = num / denom
  let sin_theta = if sin2_theta > 1.0 { 1.0 } else { sin2_theta.sqrt() }
  @math.asin(sin_theta) * (180.0 / @math.PI)
}

///|
/// Build MacNeille PBS MultiLayerStack
pub fn MacNeillePBSDesign::build_stack(
  self : MacNeillePBSDesign,
) -> @core.MultiLayerStack {
  let prism = self.prism_glass.to_layer(0.0, self.center_wavelength_nm)
  let wl = self.center_wavelength_nm
  let n_h = self.high_index_mat.get_index(wl).re
  let n_l = self.low_index_mat.get_index(wl).re
  let theta_prism_rad = 45.0 * @math.PI / 180.0

  // Effective optical thickness for 45 deg incidence inside prism
  let n_p = self.prism_glass.get_index(wl).re
  let cos_h = (1.0 -
  n_p *
  @math.sin(theta_prism_rad) /
  n_h *
  (n_p * @math.sin(theta_prism_rad) / n_h)).sqrt()
  let cos_l = (1.0 -
  n_p *
  @math.sin(theta_prism_rad) /
  n_l *
  (n_p * @math.sin(theta_prism_rad) / n_l)).sqrt()

  let d_h = wl / (4.0 * n_h * cos_h)
  let d_l = wl / (4.0 * n_l * cos_l)

  let layers = Array::new(capacity=self.num_pairs * 2)
  for _i = 0; _i < self.num_pairs; _i = _i + 1 {
    layers.push(self.high_index_mat.to_layer(d_h, wl))
    layers.push(self.low_index_mat.to_layer(d_l, wl))
  }

  @core.MultiLayerStack::new(prism, layers, prism)
}
