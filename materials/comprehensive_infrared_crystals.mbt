///|
// ============================================================================
// Infrared Crystals, Chalcogenide Glasses & Topological Insulators Database
// Precision optical constants for Mid-IR (3 - 5 um) and Long-IR (8 - 14 um)
// ============================================================================

///|
pub fn amtir1_chalcogenide_glass() -> OpticalMaterial {
  // Ge33As12Se55 (AMTIR-1) infrared optical glass (transmittance 0.7 - 14 um)
  let sell = @disp.Sellmeier3Dispersion::new(
    5.7483,
    0.2858 * 0.2858,
    0.3541,
    0.8038 * 0.8038,
    1.1273,
    30.0 * 30.0,
  )
  {
    name: "AMTIR-1 (Ge33As12Se55 Glass)",
    category: MaterialCategory::Dielectric,
    formula: "Ge33As12Se55",
    bandgap_ev: 2.1,
    dispersion_fn: fn(wl) { sell.get_complex_index(wl) },
  }
}

///|
pub fn as2s3_chalcogenide_glass() -> OpticalMaterial {
  // Arsenic Trisulfide (As2S3) mid-IR glass (n_d ~ 2.41)
  let sell = @disp.Sellmeier3Dispersion::new(
    3.8967,
    0.1983 * 0.1983,
    0.8524,
    0.4124 * 0.4124,
    1.6245,
    25.5 * 25.5,
  )
  {
    name: "As2S3 (Arsenic Trisulfide Glass)",
    category: MaterialCategory::Dielectric,
    formula: "As2S3",
    bandgap_ev: 2.35,
    dispersion_fn: fn(wl) { sell.get_complex_index(wl) },
  }
}

///|
pub fn indium_antimonide_insb() -> OpticalMaterial {
  // InSb narrow bandgap semiconductor for 3-5 um MWIR photodetectors (Eg ~ 0.17 eV)
  let wls = [
    1000.0, 2000.0, 3000.0, 4000.0, 5000.0, 6000.0, 7000.0, 8000.0, 10000.0,
  ]
  let n_arr = [4.35, 4.22, 4.15, 4.08, 4.02, 3.98, 3.96, 3.95, 3.94]
  let k_arr = [1.85, 0.72, 0.35, 0.12, 0.02, 0.001, 0.0, 0.0, 0.0]
  let tab = @disp.TabulatedDispersion::new("InSb", wls, n_arr, k_arr)
  {
    name: "InSb (Indium Antimonide)",
    category: MaterialCategory::Semiconductor,
    formula: "InSb",
    bandgap_ev: 0.17,
    dispersion_fn: fn(wl) { tab.get_complex_index(wl) },
  }
}

///|
pub fn krs5_thallium_bromoiodide() -> OpticalMaterial {
  // KRS-5 (TlBr-TlI) Far-IR window (transmittance up to 40 um, n ~ 2.37)
  let sell = @disp.Sellmeier3Dispersion::new(
    4.6186,
    0.245 * 0.245,
    0.0,
    0.0,
    9.254,
    120.0 * 120.0,
  )
  {
    name: "KRS-5 (Thallium Bromoiodide)",
    category: MaterialCategory::Dielectric,
    formula: "TlBr0.42I0.58",
    bandgap_ev: 2.8,
    dispersion_fn: fn(wl) { sell.get_complex_index(wl) },
  }
}

///|
pub fn bismuth_telluride_bi2te3() -> OpticalMaterial {
  // Bi2Te3 topological insulator and thermoelectric thin film
  let cauchy = @disp.CauchyDispersion::new(5.25, 0.085, 0.0, 1.25, 0.08)
  {
    name: "Bi2Te3 (Bismuth Telluride)",
    category: MaterialCategory::Semiconductor,
    formula: "Bi2Te3",
    bandgap_ev: 0.15,
    dispersion_fn: fn(wl) { cauchy.get_complex_index(wl) },
  }
}
