///|
test "hyperbolic metamaterial effective medium" {
  let gold = @mat.gold()
  let tio2 = @mat.titanium_dioxide()
  let hmm = HyperbolicMetamaterial::new(gold, tio2, 0.40, 20.0)

  let eps_res = hmm.calculate_effective_permittivities(700.0)
  // At 700nm, gold is metallic (eps_m < 0) and TiO2 is dielectric (eps_d > 0)
  assert_true(
    eps_res.is_type_1_hyperbolic ||
    eps_res.is_type_2_hyperbolic ||
    eps_res.is_elliptic_dielectric,
  )
}

///|
test "tpv spectral selectivity simulation" {
  let sub = @mat.bk7().to_layer(0.0, 1500.0)
  let tio2 = @mat.titanium_dioxide()
  let sio2 = @mat.fused_silica()

  let filter = DBRDesign::new(2000.0, 8, tio2, sio2, sub).build_stack()
  let tpv = TPVSimulationEngine::new(1500.0, 0.72, filter)

  let grid = @core.SpectrumGrid::linear(500.0, 4000.0, 50)
  let metrics = tpv.calculate_spectral_efficiency(grid)

  assert_true(metrics.potential_power_density_w_cm2 > 0.0)
}
