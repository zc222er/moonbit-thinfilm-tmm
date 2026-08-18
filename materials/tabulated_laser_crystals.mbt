///|
// ============================================================================
// Solid-State Laser Crystals & Nonlinear Optical Crystals Database
// Precision Sellmeier dispersion equations for laser gain and harmonic generation
// ============================================================================

///|
pub fn yag_crystal() -> OpticalMaterial {
  // Y3Al5O12 (Yttrium Aluminum Garnet / YAG) laser crystal host
  let sell = @disp.Sellmeier3Dispersion::new(
    2.282, 0.01185, 3.276, 282.73, 0.0, 0.0,
  )
  {
    name: "Y3Al5O12 (YAG Crystal)",
    category: MaterialCategory::Dielectric,
    formula: "Y3Al5O12",
    bandgap_ev: 6.5,
    dispersion_fn: fn(wl) { sell.get_complex_index(wl) },
  }
}

///|
pub fn bbo_nonlinear_crystal_ordinary() -> OpticalMaterial {
  // Beta-BBO (beta-BaB2O4) ordinary ray for SHG/THG frequency conversion
  let sell = @disp.Sellmeier3Dispersion::new(
    0.90291, 0.00305, 0.00412, 0.0105, 0.01519, 82.44,
  )
  {
    name: "beta-BBO (o-ray)",
    category: MaterialCategory::Dielectric,
    formula: "BaB2O4",
    bandgap_ev: 6.4,
    dispersion_fn: fn(wl) { sell.get_complex_index(wl) },
  }
}

///|
pub fn bbo_nonlinear_crystal_extraordinary() -> OpticalMaterial {
  // Beta-BBO extraordinary ray
  let sell = @disp.Sellmeier3Dispersion::new(
    1.37470, 0.00580, 0.01877, 0.0182, 0.01354, 100.0,
  )
  {
    name: "beta-BBO (e-ray)",
    category: MaterialCategory::Dielectric,
    formula: "BaB2O4",
    bandgap_ev: 6.4,
    dispersion_fn: fn(wl) { sell.get_complex_index(wl) },
  }
}

///|
pub fn ktp_nonlinear_crystal_z() -> OpticalMaterial {
  // Potassium Titanyl Phosphate (KTP / KTiOPO4) z-axis for 1064nm SHG (green laser)
  let sell = @disp.Sellmeier3Dispersion::new(
    1.3138, 0.04641, 0.8524, 0.2248, 0.0, 0.0,
  )
  {
    name: "KTP Crystal (z-axis)",
    category: MaterialCategory::Dielectric,
    formula: "KTiOPO4",
    bandgap_ev: 3.5,
    dispersion_fn: fn(wl) { sell.get_complex_index(wl) },
  }
}

///|
pub fn lbo_nonlinear_crystal_z() -> OpticalMaterial {
  // Lithium Triborate (LBO / LiB3O5) high damage threshold nonlinear crystal
  let sell = @disp.Sellmeier3Dispersion::new(
    1.4428, 0.01961, 0.0, 0.0, 0.0, 0.0,
  )
  {
    name: "LBO Crystal (z-axis)",
    category: MaterialCategory::Dielectric,
    formula: "LiB3O5",
    bandgap_ev: 7.7,
    dispersion_fn: fn(wl) { sell.get_complex_index(wl) },
  }
}
