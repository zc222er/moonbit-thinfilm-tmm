///|
// ============================================================================
// Comprehensive Optical Glasses, Dielectrics & Polymers Database
// Schott, Ohara, and standard precision analytical Sellmeier / Cauchy models
// ============================================================================

///|
pub fn schott_f2_flint_glass() -> OpticalMaterial {
  // Schott F2 heavy lead flint glass
  let sell = @disp.Sellmeier3Dispersion::new(
    1.34533359, 0.00997743871, 0.209073176, 0.0470450767, 0.937357162, 111.886764,
  )
  {
    name: "Schott F2 Flint Glass",
    category: MaterialCategory::Dielectric,
    formula: "Lead Silicate Glass",
    bandgap_ev: 3.5,
    dispersion_fn: fn(wl) { sell.get_complex_index(wl) },
  }
}

///|
pub fn schott_sf11_dense_flint_glass() -> OpticalMaterial {
  // Schott SF11 high refractive index dense flint (n_d = 1.7847)
  let sell = @disp.Sellmeier3Dispersion::new(
    1.73759695, 0.013188707, 0.313747346, 0.0623068142, 1.89878101, 155.23629,
  )
  {
    name: "Schott SF11 Dense Flint Glass",
    category: MaterialCategory::Dielectric,
    formula: "Dense Lead Flint",
    bandgap_ev: 3.2,
    dispersion_fn: fn(wl) { sell.get_complex_index(wl) },
  }
}

///|
pub fn schott_lasfn9_high_index_glass() -> OpticalMaterial {
  // Schott LaSFN9 Lanthanum Dense Flint (n_d = 1.85)
  let sell = @disp.Sellmeier3Dispersion::new(
    2.00029547, 0.0121426017, 0.298926886, 0.0538736054, 1.80691843, 156.550778,
  )
  {
    name: "Schott LaSFN9 Glass",
    category: MaterialCategory::Dielectric,
    formula: "Lanthanum Flint Glass",
    bandgap_ev: 3.1,
    dispersion_fn: fn(wl) { sell.get_complex_index(wl) },
  }
}

///|
pub fn calcium_fluoride_caf2() -> OpticalMaterial {
  // CaF2 excimer laser UV window (Malitson 1963)
  let sell = @disp.Sellmeier3Dispersion::new(
    0.5675888,
    0.050263605 * 0.050263605,
    0.4710914,
    0.1003909 * 0.1003909,
    3.8484723,
    34.64904 * 34.64904,
  )
  {
    name: "CaF2 (Calcium Fluoride)",
    category: MaterialCategory::Dielectric,
    formula: "CaF2",
    bandgap_ev: 11.5,
    dispersion_fn: fn(wl) { sell.get_complex_index(wl) },
  }
}

///|
pub fn barium_fluoride_baf2() -> OpticalMaterial {
  // BaF2 infrared to deep UV window
  let sell = @disp.Sellmeier3Dispersion::new(
    0.643356,
    0.057789 * 0.057789,
    0.506762,
    0.10968 * 0.10968,
    3.8261,
    46.3864 * 46.3864,
  )
  {
    name: "BaF2 (Barium Fluoride)",
    category: MaterialCategory::Dielectric,
    formula: "BaF2",
    bandgap_ev: 10.6,
    dispersion_fn: fn(wl) { sell.get_complex_index(wl) },
  }
}

///|
pub fn polycarbonate_polymer() -> OpticalMaterial {
  // Polycarbonate (PC) optical disc and lens substrate (n_d = 1.586)
  let cauchy = @disp.CauchyDispersion::transparent(1.567, 0.0078, 0.0003)
  {
    name: "Polycarbonate (PC)",
    category: MaterialCategory::Polymer,
    formula: "(C16H14O3)n",
    bandgap_ev: 4.2,
    dispersion_fn: fn(wl) { cauchy.get_complex_index(wl) },
  }
}

///|
pub fn polystyrene_polymer() -> OpticalMaterial {
  // Polystyrene (PS) (n_d = 1.592)
  let cauchy = @disp.CauchyDispersion::transparent(1.572, 0.0084, 0.0004)
  {
    name: "Polystyrene (PS)",
    category: MaterialCategory::Polymer,
    formula: "(C8H8)n",
    bandgap_ev: 4.4,
    dispersion_fn: fn(wl) { cauchy.get_complex_index(wl) },
  }
}

///|
pub fn cytop_amorphous_fluoropolymer() -> OpticalMaterial {
  // CYTOP ultra-low refractive index fluoropolymer (n_d = 1.34)
  let cauchy = @disp.CauchyDispersion::transparent(1.334, 0.0025, 0.0)
  {
    name: "CYTOP Fluoropolymer",
    category: MaterialCategory::Polymer,
    formula: "Perfluoro-polymer",
    bandgap_ev: 7.0,
    dispersion_fn: fn(wl) { cauchy.get_complex_index(wl) },
  }
}
