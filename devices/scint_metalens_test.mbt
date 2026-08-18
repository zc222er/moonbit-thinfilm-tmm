///|
test "scintillator optical coupling lee" {
  let lyso = @mat.lyso_lutetium_yttrium_oxyorthosilicate()
  let grease = @mat.pmma() // Optical silicone grease equivalent
  let coupling = ScintillatorCouplingSystem::new(lyso, grease, 50.0, 1.55)

  let lee = coupling.calculate_light_extraction_efficiency(420.0)
  // Scintillator extraction into SiPM is typically ~ 10 - 25%
  assert_true(lee > 0.05 && lee < 0.50)
}

///|
test "pancharatnam berry metalens phase profile" {
  let tio2 = @mat.titanium_dioxide()
  let metalens = PBMetasurfaceMetalens::new(100.0, 532.0, 600.0, tio2)

  let phase_center = metalens.calculate_focusing_phase_rad(0.0)
  let rot_center = metalens.calculate_nanofin_orientation_deg(0.0)

  assert_true(phase_center >= 0.0 && phase_center <= 2.0 * @math.PI)
  assert_true(rot_center >= 0.0 && rot_center <= 180.0)
}
