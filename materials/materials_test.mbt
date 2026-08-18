///|
test "materials database registry lookup" {
  let db = MaterialDatabase::standard()
  assert_true(db.count() >= 20)

  let sio2_opt = db.find("SiO2 (Fused Silica)")
  assert_true(sio2_opt is Some(_))

  let ag_opt = db.find("Ag (Silver)")
  assert_true(ag_opt is Some(_))
}

///|
test "silicon refractive index at visible and near-infrared" {
  let si = crystalline_silicon()
  let n_633 = si.get_index(633.0)
  // At 633 nm, Silicon n ~ 3.88, k ~ 0.02
  assert_true((n_633.re - 3.88).abs() < 0.2)
  assert_true(n_633.im > 0.0 && n_633.im < 0.05)

  // In NIR at 1550 nm, Silicon is transparent (k ~ 0) and n ~ 3.48
  let n_1550 = si.get_index(1550.0)
  assert_true((n_1550.re - 3.48).abs() < 0.1)
  assert_true(n_1550.im < 1.0e-4)
}

///|
test "gold and silver optical constants" {
  let au = gold()
  let ag = silver()

  let n_au_600 = au.get_index(600.0)
  // Gold at 600nm: n ~ 0.20, k ~ 2.90
  assert_true((n_au_600.re - 0.20).abs() < 0.15)
  assert_true((n_au_600.im - 2.90).abs() < 0.2)

  let n_ag_600 = ag.get_index(600.0)
  // Silver at 600nm: n ~ 0.06, k ~ 4.00
  assert_true((n_ag_600.re - 0.06).abs() < 0.15)
  assert_true((n_ag_600.im - 4.00).abs() < 0.2)
}
