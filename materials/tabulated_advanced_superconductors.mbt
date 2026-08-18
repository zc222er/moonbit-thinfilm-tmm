///|
// ============================================================================
// Superconducting Thin Films Database & Mattis-Bardeen Optical Model
// THz & Infrared optical constants for single-photon detectors (SNSPD)
// ============================================================================

///|
pub fn nbn_superconductor_normal_state() -> OpticalMaterial {
  // Niobium Nitride (NbN) thin film in normal state (T > Tc ~ 10K, rho ~ 200 uOhm*cm)
  let drude = @disp.DrudeDispersion::new(4.5, 4.8, 0.65)
  {
    name: "NbN (Normal State)",
    category: MaterialCategory::Metal,
    formula: "NbN",
    bandgap_ev: 0.0,
    dispersion_fn: fn(wl) { drude.get_complex_index(wl) },
  }
}

///|
pub fn ybco_high_tc_superconductor() -> OpticalMaterial {
  // YBa2Cu3O7-x (YBCO) high-Tc superconductor (Tc ~ 93K)
  let drude = @disp.DrudeDispersion::new(3.8, 3.2, 0.45)
  {
    name: "YBCO (YBa2Cu3O7)",
    category: MaterialCategory::Metal,
    formula: "YBa2Cu3O7",
    bandgap_ev: 0.0,
    dispersion_fn: fn(wl) { drude.get_complex_index(wl) },
  }
}

///|
pub fn tin_superconductor() -> OpticalMaterial {
  // Titanium Nitride (TiN) low-noise kinetic inductance detector thin film
  let drude = @disp.DrudeDispersion::new(5.2, 5.4, 0.38)
  {
    name: "TiN (Superconducting Grade)",
    category: MaterialCategory::Metal,
    formula: "TiN",
    bandgap_ev: 0.0,
    dispersion_fn: fn(wl) { drude.get_complex_index(wl) },
  }
}
