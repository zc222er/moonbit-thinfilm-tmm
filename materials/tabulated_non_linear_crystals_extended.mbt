///|
// ============================================================================
// Extended Nonlinear Optical Crystals & Phase-Matching Database
// Sellmeier equations for mid-IR & deep-UV harmonic generation
// ============================================================================

///|
pub fn zgp_zinc_germanium_phosphide() -> OpticalMaterial {
  // ZnGeP2 (ZGP) premier mid-IR nonlinear crystal (transmittance 0.74 - 12 um)
  let sell = @disp.Sellmeier3Dispersion::new(
    8.040,
    0.386 * 0.386,
    1.120,
    2.50 * 2.50,
    2.15,
    30.0 * 30.0,
  )
  {
    name: "ZnGeP2 (ZGP Crystal)",
    category: MaterialCategory::Dielectric,
    formula: "ZnGeP2",
    bandgap_ev: 2.0,
    dispersion_fn: fn(wl) { sell.get_complex_index(wl) },
  }
}

///|
pub fn ag_ga_se2_silver_gallium_selenide() -> OpticalMaterial {
  // AgGaSe2 far-IR nonlinear crystal (transmittance 0.7 - 18 um)
  let sell = @disp.Sellmeier3Dispersion::new(
    5.2912,
    0.3843 * 0.3843,
    0.6264,
    1.442 * 1.442,
    1.897,
    40.0 * 40.0,
  )
  {
    name: "AgGaSe2 Crystal",
    category: MaterialCategory::Dielectric,
    formula: "AgGaSe2",
    bandgap_ev: 1.83,
    dispersion_fn: fn(wl) { sell.get_complex_index(wl) },
  }
}

///|
pub fn clbo_cesium_lithium_borate() -> OpticalMaterial {
  // CsLiB6O10 (CLBO) deep-UV 4th & 5th harmonic generation crystal (266 nm & 213 nm)
  let sell = @disp.Sellmeier3Dispersion::new(
    1.143, 0.0058, 0.013, 0.019, 0.0, 0.0,
  )
  {
    name: "CLBO (Deep-UV Crystal)",
    category: MaterialCategory::Dielectric,
    formula: "CsLiB6O10",
    bandgap_ev: 6.9,
    dispersion_fn: fn(wl) { sell.get_complex_index(wl) },
  }
}

///|
pub fn bibo_bismuth_triborate() -> OpticalMaterial {
  // BiB3O6 (BIBO) high nonlinear coefficient d_eff crystal (d22 = 3.5 pm/V)
  let sell = @disp.Sellmeier3Dispersion::new(
    2.154, 0.0142, 0.452, 0.052, 0.0, 0.0,
  )
  {
    name: "BiB3O6 (BIBO Crystal)",
    category: MaterialCategory::Dielectric,
    formula: "BiB3O6",
    bandgap_ev: 4.3,
    dispersion_fn: fn(wl) { sell.get_complex_index(wl) },
  }
}
