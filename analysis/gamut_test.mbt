///|
test "mccamy cct calculation for chromaticity point" {
  let cct = calculate_cct_mccamy(0.3127, 0.3290)
  assert_true(cct > 4000.0 && cct < 7000.0)

  let cov = DisplayGamutCoverage::new(100.0, 95.0, 78.0, cct)
  assert_true(cov.srgb_coverage_percent > 90.0)
}

///|
test "gamut triangle area calculation" {
  // sRGB primaries: R(0.64, 0.33), G(0.30, 0.60), B(0.15, 0.06)
  let area_srgb = calculate_gamut_triangle_area(
    0.64, 0.33, 0.30, 0.60, 0.15, 0.06,
  )

  // sRGB area is ~ 0.098
  assert_true(area_srgb > 0.08 && area_srgb < 0.12)
}
