///|
// ============================================================================
// Optical Polymers, Waveguide Resists & Fluoropolymers Database
// ============================================================================

///|
pub fn topas_coc_polymer() -> OpticalMaterial {
  // Topas Cyclic Olefin Copolymer (COC) for UV-Vis microfluidic lenses (n_d = 1.533)
  let cauchy = @disp.CauchyDispersion::transparent(1.528, 0.0045, 0.0002)
  {
    name: "Topas (COC Polymer)",
    category: MaterialCategory::Polymer,
    formula: "(C9H14)n",
    bandgap_ev: 5.1,
    dispersion_fn: fn(wl) { cauchy.get_complex_index(wl) },
  }
}

///|
pub fn cytop_fluoropolymer() -> OpticalMaterial {
  // Cytop amorphous fluoropolymer with ultra-low refractive index (n = 1.34)
  let cauchy = @disp.CauchyDispersion::transparent(1.335, 0.0035, 0.0)
  {
    name: "Cytop (Perfluoro Polymer)",
    category: MaterialCategory::Polymer,
    formula: "C3F6O",
    bandgap_ev: 7.2,
    dispersion_fn: fn(wl) { cauchy.get_complex_index(wl) },
  }
}

///|
pub fn zeonex_cop_polymer() -> OpticalMaterial {
  // Zeonex Cyclo-Olefin Polymer (COP) for precision injection-molded lenses (n_d = 1.53)
  let cauchy = @disp.CauchyDispersion::transparent(1.525, 0.0048, 0.0003)
  {
    name: "Zeonex (Cyclo-Olefin Polymer)",
    category: MaterialCategory::Polymer,
    formula: "C10H16",
    bandgap_ev: 4.8,
    dispersion_fn: fn(wl) { cauchy.get_complex_index(wl) },
  }
}

///|
pub fn my133_optical_adhesive() -> OpticalMaterial {
  // MY-133 ultra-low index optical adhesive (n_d = 1.333 matching water)
  let cauchy = @disp.CauchyDispersion::transparent(1.328, 0.0032, 0.0)
  {
    name: "MY-133 (Low Index Adhesive)",
    category: MaterialCategory::Polymer,
    formula: "Fluorinated Acrylate",
    bandgap_ev: 6.8,
    dispersion_fn: fn(wl) { cauchy.get_complex_index(wl) },
  }
}
