///|
test "euv mirror debye waller and peak reflectivity" {
  let euv = EUVMirrorDesign::standard_moly_silicon()
  let dw = euv.debye_waller_factor(0.0)

  // Debye-Waller factor should be between 0.8 and 1.0
  assert_true(dw > 0.80 && dw <= 1.0)

  let r_peak = euv.calculate_peak_reflectivity(0.0)
  // Mo/Si peak reflectivity is ~ 65 - 72%
  assert_true(r_peak > 0.60 && r_peak < 0.75)
}

///|
test "graded index film discretization" {
  let air = @core.Layer::real("Air", 0.0, 1.0)
  let glass = @core.Layer::real("Glass", 0.0, 1.5)
  let grin = GradedIndexFilm::new(
    100.0,
    1.0,
    1.5,
    GradedProfileType::Linear,
    20,
  )

  let stack = grin.discretize_to_stack(air, glass, 550.0)
  assert_eq(stack.layers.length(), 20)

  // Middle sublayer index should be between 1.0 and 1.5
  let mid_index = @tmm.get_layer_isotropic_index(stack.layers[10]).re
  assert_true(mid_index > 1.20 && mid_index < 1.30)
}
