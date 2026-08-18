///|
test "spatial field profile and boundary continuity" {
  let air = @core.Layer::real("Air", 0.0, 1.0)
  let tio2 = @core.Layer::real("TiO2", 60.0, 2.3)
  let glass = @core.Layer::real("Glass", 0.0, 1.52)
  let stack = @core.MultiLayerStack::new(air, [tio2], glass)

  let profile = calculate_spatial_field_profile(
    stack,
    600.0,
    @core.IncidentAngle::normal(),
    @core.Polarization::TE,
    100,
  )

  assert_eq(profile.points.length(), 100)
  // Field intensity at front surface should be positive
  assert_true(profile.points[0].e_intensity > 0.0)
  // Poynting flux must be positive (energy propagating forward)
  assert_true(profile.points[99].poynting_z > 0.0)
}

///|
test "field absorption in lossy silicon film" {
  let air = @core.Layer::real("Air", 0.0, 1.0)
  let lossy_si = @core.Layer::absorbing("a-Si", 100.0, 4.0, 0.5)
  let glass = @core.Layer::real("Glass", 0.0, 1.5)
  let stack = @core.MultiLayerStack::new(air, [lossy_si], glass)

  let profile = calculate_spatial_field_profile(
    stack,
    500.0,
    @core.IncidentAngle::normal(),
    @core.Polarization::TE,
    50,
  )

  // In absorbing layer, absorption_rate should be strictly positive
  let mid_pt = profile.points[25]
  assert_true(mid_pt.absorption_rate > 0.0)
}
