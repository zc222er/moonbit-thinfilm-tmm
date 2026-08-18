///|
// ============================================================================
// High-Temperature Refractory Ceramics & Transparent Armor Database
// High-energy laser windows and thermal barrier coatings
// ============================================================================

///|
pub fn ysz_8mol_yttria_stabilized_zirconia() -> OpticalMaterial {
  // 8YSZ (8 mol% Y2O3 stabilized ZrO2) thermal barrier and solid oxide electrolyte
  let cauchy = @disp.CauchyDispersion::transparent(2.152, 0.026, 0.0019)
  {
    name: "8YSZ (Yttria-Stabilized Zirconia)",
    category: MaterialCategory::Dielectric,
    formula: "(ZrO2)0.92(Y2O3)0.08",
    bandgap_ev: 5.2,
    dispersion_fn: fn(wl) { cauchy.get_complex_index(wl) },
  }
}

///|
pub fn spinel_mgal2o4_ceramic() -> OpticalMaterial {
  // MgAl2O4 (Magnesium Aluminate Spinel) rugged transparent armor window (0.2 - 5.5 um)
  let sell = @disp.Sellmeier3Dispersion::new(
    1.89937,
    0.01026,
    2.5694,
    37.38 * 37.38,
    0.0,
    0.0,
  )
  {
    name: "MgAl2O4 (Spinel Ceramic)",
    category: MaterialCategory::Dielectric,
    formula: "MgAl2O4",
    bandgap_ev: 7.8,
    dispersion_fn: fn(wl) { sell.get_complex_index(wl) },
  }
}

///|
pub fn alon_aluminum_oxynitride() -> OpticalMaterial {
  // AlON (Aluminum Oxynitride / ALON) transparent bulletproof ceramic (n_d = 1.79)
  let sell = @disp.Sellmeier3Dispersion::new(
    2.1587,
    0.0125,
    3.412,
    42.0 * 42.0,
    0.0,
    0.0,
  )
  {
    name: "AlON (Aluminum Oxynitride)",
    category: MaterialCategory::Dielectric,
    formula: "Al23O27N5",
    bandgap_ev: 6.2,
    dispersion_fn: fn(wl) { sell.get_complex_index(wl) },
  }
}

///|
pub fn lanthanum_zirconate_la2zr2o7() -> OpticalMaterial {
  // La2Zr2O7 pyrochlore thermal barrier coating
  let cauchy = @disp.CauchyDispersion::transparent(2.085, 0.022, 0.0011)
  {
    name: "La2Zr2O7 (Lanthanum Zirconate)",
    category: MaterialCategory::Dielectric,
    formula: "La2Zr2O7",
    bandgap_ev: 4.8,
    dispersion_fn: fn(wl) { cauchy.get_complex_index(wl) },
  }
}
