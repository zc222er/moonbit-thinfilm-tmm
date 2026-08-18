///|
// ============================================================================
// Optical Solvents, Liquids & Index-Matching Fluids Database
// Precision spectroscopic refractive index data (200 nm - 2500 nm)
// ============================================================================

///|
pub fn heavy_water_d2o() -> OpticalMaterial {
  // Deuterium oxide (Heavy Water) low near-IR absorption solvent
  let cauchy = @disp.CauchyDispersion::transparent(1.324, 0.0031, 0.0)
  {
    name: "D2O (Heavy Water)",
    category: MaterialCategory::Liquid,
    formula: "D2O",
    bandgap_ev: 8.5,
    dispersion_fn: fn(wl) { cauchy.get_complex_index(wl) },
  }
}

///|
pub fn ethanol_solvent() -> OpticalMaterial {
  // Ethanol C2H5OH optical solvent
  let cauchy = @disp.CauchyDispersion::transparent(1.355, 0.0034, 0.0001)
  {
    name: "Ethanol",
    category: MaterialCategory::Liquid,
    formula: "C2H5OH",
    bandgap_ev: 6.2,
    dispersion_fn: fn(wl) { cauchy.get_complex_index(wl) },
  }
}

///|
pub fn isopropanol_ipa() -> OpticalMaterial {
  // Isopropanol (IPA) semiconductor cleaning solvent
  let cauchy = @disp.CauchyDispersion::transparent(1.372, 0.0036, 0.0001)
  {
    name: "Isopropanol (IPA)",
    category: MaterialCategory::Liquid,
    formula: "C3H8O",
    bandgap_ev: 6.0,
    dispersion_fn: fn(wl) { cauchy.get_complex_index(wl) },
  }
}

///|
pub fn toluene_solvent() -> OpticalMaterial {
  // Toluene high-index organic solvent (n_d = 1.496)
  let cauchy = @disp.CauchyDispersion::transparent(1.482, 0.0062, 0.0003)
  {
    name: "Toluene",
    category: MaterialCategory::Liquid,
    formula: "C7H8",
    bandgap_ev: 4.5,
    dispersion_fn: fn(wl) { cauchy.get_complex_index(wl) },
  }
}

///|
pub fn chlorobenzene_solvent() -> OpticalMaterial {
  // Chlorobenzene perovskite and organic solar cell solvent (n_d = 1.524)
  let cauchy = @disp.CauchyDispersion::transparent(1.510, 0.0071, 0.0004)
  {
    name: "Chlorobenzene",
    category: MaterialCategory::Liquid,
    formula: "C6H5Cl",
    bandgap_ev: 4.3,
    dispersion_fn: fn(wl) { cauchy.get_complex_index(wl) },
  }
}

///|
pub fn glycerol_liquid() -> OpticalMaterial {
  // Glycerol high-viscosity index matching liquid (n_d = 1.473)
  let cauchy = @disp.CauchyDispersion::transparent(1.463, 0.0048, 0.0001)
  {
    name: "Glycerol",
    category: MaterialCategory::Liquid,
    formula: "C3H8O3",
    bandgap_ev: 5.5,
    dispersion_fn: fn(wl) { cauchy.get_complex_index(wl) },
  }
}

///|
pub fn cargille_index_matching_oil_152() -> OpticalMaterial {
  // Standard Cargille immersion oil for microscope optics (n_d = 1.518, Abbe vd = 41.5)
  let cauchy = @disp.CauchyDispersion::transparent(1.505, 0.0065, 0.0002)
  {
    name: "Cargille Immersion Oil (n=1.518)",
    category: MaterialCategory::Liquid,
    formula: "Hydrocarbon Immersion Fluid",
    bandgap_ev: 4.0,
    dispersion_fn: fn(wl) { cauchy.get_complex_index(wl) },
  }
}
