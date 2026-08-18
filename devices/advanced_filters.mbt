///|
/// Non-Polarizing 50/50 Beam Splitter (NPBS) MultiLayer Coating
pub struct NonPolarizingBeamSplitter {
  center_wavelength_nm : Double
  target_angle_deg : Double
  stack : @core.MultiLayerStack
}

///|
pub fn NonPolarizingBeamSplitter::new(
  center_wl_nm : Double,
  prism_glass : @mat.OpticalMaterial,
) -> NonPolarizingBeamSplitter {
  let prism = prism_glass.to_layer(0.0, center_wl_nm)
  let tio2 = @mat.titanium_dioxide()
  let sio2 = @mat.fused_silica()

  // Symmetrical 5-layer non-polarizing design: Glass / H L H L H / Glass
  let d_h = center_wl_nm / (4.0 * tio2.get_index(center_wl_nm).re)
  let d_l = center_wl_nm / (4.0 * sio2.get_index(center_wl_nm).re)

  let l1 = tio2.to_layer(d_h * 0.85, center_wl_nm)
  let l2 = sio2.to_layer(d_l * 1.15, center_wl_nm)
  let l3 = tio2.to_layer(d_h * 1.30, center_wl_nm)
  let l4 = sio2.to_layer(d_l * 1.15, center_wl_nm)
  let l5 = tio2.to_layer(d_h * 0.85, center_wl_nm)

  let stack = @core.MultiLayerStack::new(prism, [l1, l2, l3, l4, l5], prism)
  { center_wavelength_nm: center_wl_nm, target_angle_deg: 45.0, stack }
}

///|
/// Dichroic Mirror (e.g. Reflect 532nm Green Laser, Transmit 1064nm Nd:YAG Laser at 45 deg)
pub fn create_dichroic_mirror_532_1064(
  glass_substrate : @mat.OpticalMaterial,
) -> @core.MultiLayerStack {
  let air = @mat.air().to_layer(0.0, 532.0)
  let sub = glass_substrate.to_layer(0.0, 532.0)
  let tio2 = @mat.titanium_dioxide()
  let sio2 = @mat.fused_silica()

  let dbr_design = DBRDesign::new(532.0, 14, tio2, sio2, sub)
  let base_stack = dbr_design.build_stack()

  // Top matching layer for 1064nm anti-reflection
  let d_ar = 1064.0 / (4.0 * sio2.get_index(1064.0).re)
  let ar_layer = sio2.to_layer(d_ar, 1064.0)

  let modified_layers = Array::new(capacity=base_stack.layers.length() + 1)
  modified_layers.push(ar_layer)
  for l in base_stack.layers {
    modified_layers.push(l)
  }

  @core.MultiLayerStack::new(air, modified_layers, sub)
}
