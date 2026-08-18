///|
test "incoherent substrate backside correction" {
  let sub_corr = IncoherentSubstrateCorrection::new(1.0, 0.0, 1.0)
  // Transparent glass (n=1.52) front R=0.04, T=0.96, back interface R=0.04
  let r_tot = sub_corr.calculate_total_reflectance(0.04, 0.96, 0.04)

  // Standard double-sided glass reflection is ~ 7.7%
  assert_true(r_tot > 0.07 && r_tot < 0.09)
}

///|
test "spectrometer slit convolution smoothing" {
  let grid = @core.SpectrumGrid::linear(400.0, 600.0, 21)
  let vals = Array::new(capacity=21)
  for i = 0; i < 21; i = i + 1 {
    // Sharp delta peak in middle
    vals.push(if i == 10 { 1.0 } else { 0.0 })
  }
  let sharp_spec = @core.SpectrumData::new("SharpPeak", grid, vals)
  let smoothed = convolve_spectrometer_slit(sharp_spec, 15.0)

  // Peak should be broadened (height < 1.0, neighbors > 0.0)
  assert_true(smoothed.get(10) < 1.0 && smoothed.get(10) > 0.1)
  assert_true(smoothed.get(9) > 0.0)
  assert_true(smoothed.get(11) > 0.0)
}
