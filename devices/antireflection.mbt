///|
/// Create a Single Layer Quarter-Wave Anti-Reflection (AR) coating stack
pub fn create_single_layer_ar(
  substrate : @core.Layer,
  center_wl_nm : Double,
  film_mat : @mat.OpticalMaterial,
) -> @core.MultiLayerStack {
  let air = @mat.air().to_layer(0.0, center_wl_nm)
  let n_film = film_mat.get_index(center_wl_nm).re
  let d_nm = center_wl_nm / (4.0 * n_film)
  let ar_layer = film_mat.to_layer(d_nm, center_wl_nm)
  @core.MultiLayerStack::new(air, [ar_layer], substrate)
}

///|
/// Create a Double Layer (V-coat or W-coat) Broadband AR Coating
pub fn create_double_layer_ar(
  substrate : @core.Layer,
  center_wl_nm : Double,
  low_index_mat : @mat.OpticalMaterial,
  high_index_mat : @mat.OpticalMaterial,
) -> @core.MultiLayerStack {
  let air = @mat.air().to_layer(0.0, center_wl_nm)
  let n_low = low_index_mat.get_index(center_wl_nm).re
  let n_high = high_index_mat.get_index(center_wl_nm).re

  // Quarter-quarter design: d_low = lambda / (4*n_low), d_high = lambda / (4*n_high)
  let d_low = center_wl_nm / (4.0 * n_low)
  let d_high = center_wl_nm / (4.0 * n_high)

  let layer_top = low_index_mat.to_layer(d_low, center_wl_nm)
  let layer_bot = high_index_mat.to_layer(d_high, center_wl_nm)

  @core.MultiLayerStack::new(air, [layer_top, layer_bot], substrate)
}

///|
/// Create a 4-Layer Broadband AR Coating (e.g. for Silicon or Glass across 400 - 1000 nm)
pub fn create_broadband_4layer_ar(
  substrate : @core.Layer,
  center_wl_nm : Double,
) -> @core.MultiLayerStack {
  let air = @mat.air().to_layer(0.0, center_wl_nm)
  let mgf2 = @mat.magnesium_fluoride()
  let tio2 = @mat.titanium_dioxide()
  let sio2 = @mat.fused_silica()

  // Standard high-efficiency 4-layer design
  let l1 = mgf2.to_layer(95.0, center_wl_nm)
  let l2 = tio2.to_layer(30.0, center_wl_nm)
  let l3 = sio2.to_layer(25.0, center_wl_nm)
  let l4 = tio2.to_layer(45.0, center_wl_nm)

  @core.MultiLayerStack::new(air, [l1, l2, l3, l4], substrate)
}
