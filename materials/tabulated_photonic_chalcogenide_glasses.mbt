///|
// ============================================================================
// Extended Chalcogenide Optical Glasses Database (IG2, IG3, As-Se-S)
// Mid-IR & Far-IR transmission and high nonlinear refractive index n2
// ============================================================================

///|
pub fn ig2_ge20sb15se65_glass() -> OpticalMaterial {
  // IG2 (Ge20Sb15Se65) mid-IR chalcogenide glass (transmittance 0.85 - 14 um, n ~ 2.61)
  let sell = @disp.Sellmeier3Dispersion::new(
    5.824,
    0.295 * 0.295,
    0.0,
    0.0,
    1.45,
    32.0 * 32.0,
  )
  {
    name: "IG2 (Ge20Sb15Se65 Glass)",
    category: MaterialCategory::Dielectric,
    formula: "Ge20Sb15Se65",
    bandgap_ev: 1.85,
    dispersion_fn: fn(wl) { sell.get_complex_index(wl) },
  }
}

///|
pub fn ig3_ge22as20se58_glass() -> OpticalMaterial {
  // IG3 (Ge22As20Se58) precision infrared optical glass (n ~ 2.50)
  let sell = @disp.Sellmeier3Dispersion::new(
    5.250,
    0.280 * 0.280,
    0.0,
    0.0,
    1.32,
    30.0 * 30.0,
  )
  {
    name: "IG3 (Ge22As20Se58 Glass)",
    category: MaterialCategory::Dielectric,
    formula: "Ge22As20Se58",
    bandgap_ev: 2.05,
    dispersion_fn: fn(wl) { sell.get_complex_index(wl) },
  }
}

///|
pub fn as40se60_chalcogenide_glass() -> OpticalMaterial {
  // As40Se60 ultra-high nonlinear glass (n2 ~ 1.1e-17 m^2/W, 500x silica)
  let sell = @disp.Sellmeier3Dispersion::new(
    6.125,
    0.345 * 0.345,
    0.0,
    0.0,
    1.85,
    35.0 * 35.0,
  )
  {
    name: "As40Se60 (Nonlinear Glass)",
    category: MaterialCategory::Dielectric,
    formula: "As2Se3",
    bandgap_ev: 1.77,
    dispersion_fn: fn(wl) { sell.get_complex_index(wl) },
  }
}
