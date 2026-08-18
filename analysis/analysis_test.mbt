///|
test "cie 1931 white point chromaticity" {
  // Perfect 100% white reflector spectrum
  let grid = @core.SpectrumGrid::visible_spectrum(41)
  let ones = Array::new(capacity=41)
  for _i = 0; _i < 41; _i = _i + 1 {
    ones.push(1.0)
  }
  let white_spec = @core.SpectrumData::new("WhiteReflector", grid, ones)

  let color = spectrum_to_color(white_spec)

  // Standard D65 chromaticity is x ~ 0.3127, y ~ 0.3290
  assert_true((color.chroma_x - 0.3127).abs() < 0.02)
  assert_true((color.chroma_y - 0.3290).abs() < 0.02)

  // White RGB should be close to 255, 255, 255
  assert_true(color.srgb_r >= 250)
  assert_true(color.srgb_g >= 250)
  assert_true(color.srgb_b >= 250)
}
