///|
/// Fabry-Perot Narrowband Cavity Filter Generator: (LH)^m (2S) (HL)^m
pub struct FabryPerotFilter {
  center_wavelength_nm : Double
  mirror_pairs : Int
  cavity_order : Int // 1 for lambda/2 cavity, 2 for lambda cavity
  high_mat : @mat.OpticalMaterial
  low_mat : @mat.OpticalMaterial
  cavity_mat : @mat.OpticalMaterial
  substrate : @core.Layer
}

///|
pub fn FabryPerotFilter::new(
  center_wavelength_nm : Double,
  mirror_pairs : Int,
  cavity_order : Int,
  high_mat : @mat.OpticalMaterial,
  low_mat : @mat.OpticalMaterial,
  cavity_mat : @mat.OpticalMaterial,
  substrate : @core.Layer,
) -> FabryPerotFilter {
  {
    center_wavelength_nm,
    mirror_pairs,
    cavity_order,
    high_mat,
    low_mat,
    cavity_mat,
    substrate,
  }
}

///|
pub fn FabryPerotFilter::build_stack(
  self : FabryPerotFilter,
) -> @core.MultiLayerStack {
  let air = @mat.air().to_layer(0.0, self.center_wavelength_nm)
  let n_h = self.high_mat.get_index(self.center_wavelength_nm).re
  let n_l = self.low_mat.get_index(self.center_wavelength_nm).re
  let n_c = self.cavity_mat.get_index(self.center_wavelength_nm).re

  let d_h = self.center_wavelength_nm / (4.0 * n_h)
  let d_l = self.center_wavelength_nm / (4.0 * n_l)
  let d_cavity = self.cavity_order.to_double() *
    self.center_wavelength_nm /
    (2.0 * n_c)

  let layers = Array::new(capacity=self.mirror_pairs * 4 + 1)

  // 1. Top DBR mirror (HL)^m
  for _i = 0; _i < self.mirror_pairs; _i = _i + 1 {
    layers.push(self.high_mat.to_layer(d_h, self.center_wavelength_nm))
    layers.push(self.low_mat.to_layer(d_l, self.center_wavelength_nm))
  }

  // 2. Central Spacer Cavity (2S)
  layers.push(self.cavity_mat.to_layer(d_cavity, self.center_wavelength_nm))

  // 3. Bottom DBR mirror (LH)^m
  for _i = 0; _i < self.mirror_pairs; _i = _i + 1 {
    layers.push(self.low_mat.to_layer(d_l, self.center_wavelength_nm))
    layers.push(self.high_mat.to_layer(d_h, self.center_wavelength_nm))
  }

  @core.MultiLayerStack::new(air, layers, self.substrate)
}
