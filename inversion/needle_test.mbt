///|
test "needle thin film synthesis" {
  let grid = @core.SpectrumGrid::visible_spectrum(31)
  let zeros = Array::new(capacity=31)
  for _i = 0; _i < 31; _i = _i + 1 {
    zeros.push(0.0) // Ideal anti-reflection target
  }
  let target = @core.SpectrumData::new("IdealAR", grid, zeros)

  let tio2 = @mat.titanium_dioxide()
  let sio2 = @mat.fused_silica()
  let glass = @mat.bk7().to_layer(0.0, 550.0)

  let engine = NeedleSynthesisEngine::new(target, tio2, sio2, glass, 4)
  let res = engine.synthesize(200.0)

  assert_true(res.layer_count >= 1)
  assert_true(res.total_thickness_nm > 0.0)
  assert_true(res.merit_function_value >= 0.0)
}
