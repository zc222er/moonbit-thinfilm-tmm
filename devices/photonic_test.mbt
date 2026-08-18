///|
test "1d photonic crystal bandgap detection" {
  let tio2 = @mat.titanium_dioxide()
  let sio2 = @mat.fused_silica()
  let pc = PhotonicCrystal1D::new(300.0, 0.5, tio2, sio2, 10)

  // Near Bragg condition (lambda ~ 2 * (n1*d1 + n2*d2) = 2 * (2.4*150 + 1.46*150) = 1158 nm)
  let pt_bg = pc.calculate_bloch_point(1150.0)
  assert_true(pt_bg.is_bandgap)
}

///|
test "mim nanoplasmonic waveguide effective index" {
  let sio2 = @mat.fused_silica()
  let silver = @mat.silver()
  let mim = MIMWaveguide::new(50.0, sio2, silver)

  let mode = mim.solve_fundamental_mode(632.8)
  assert_true(mode.effective_index_re > 1.46)
  assert_true(mode.propagation_length_um > 0.0)
}
