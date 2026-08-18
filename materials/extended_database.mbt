///|
// ============================================================================
// Extended Optical Materials Database
// High-precision physical dispersion models and reference spectroscopic data
// ============================================================================

// ----------------------------------------------------------------------------
// 1. Advanced Halide Perovskites & Double Perovskites
// ----------------------------------------------------------------------------

///|
pub fn perovskite_fapbi3() -> OpticalMaterial {
  // Formamidinium Lead Triiodide (FAPbI3) bandgap ~ 1.48 eV (alpha-phase black perovskite)
  let wls = [
    350.0, 400.0, 450.0, 500.0, 550.0, 600.0, 650.0, 700.0, 750.0, 800.0, 840.0,
    900.0,
  ]
  let n_arr = [
    2.42, 2.58, 2.65, 2.61, 2.55, 2.50, 2.52, 2.63, 2.68, 2.58, 2.32, 2.22,
  ]
  let k_arr = [
    0.98, 0.88, 0.76, 0.61, 0.48, 0.35, 0.27, 0.22, 0.18, 0.08, 0.005, 0.0,
  ]
  let tab = @disp.TabulatedDispersion::new("FAPbI3", wls, n_arr, k_arr)
  {
    name: "FAPbI3 Perovskite",
    category: MaterialCategory::Semiconductor,
    formula: "HC(NH2)2PbI3",
    bandgap_ev: 1.48,
    dispersion_fn: fn(wl) { tab.get_complex_index(wl) },
  }
}

///|
pub fn perovskite_cspbi3() -> OpticalMaterial {
  // All-inorganic Cesium Lead Iodide (CsPbI3) gamma-phase
  let wls = [
    350.0, 400.0, 450.0, 500.0, 550.0, 600.0, 650.0, 700.0, 720.0, 760.0, 800.0,
    900.0,
  ]
  let n_arr = [
    2.35, 2.50, 2.58, 2.53, 2.47, 2.44, 2.48, 2.59, 2.52, 2.28, 2.20, 2.15,
  ]
  let k_arr = [
    0.92, 0.82, 0.70, 0.55, 0.42, 0.30, 0.21, 0.14, 0.02, 0.0, 0.0, 0.0,
  ]
  let tab = @disp.TabulatedDispersion::new("CsPbI3", wls, n_arr, k_arr)
  {
    name: "CsPbI3 Inorganic Perovskite",
    category: MaterialCategory::Semiconductor,
    formula: "CsPbI3",
    bandgap_ev: 1.73,
    dispersion_fn: fn(wl) { tab.get_complex_index(wl) },
  }
}

///|
pub fn perovskite_cspbbr3() -> OpticalMaterial {
  // Cesium Lead Bromide green-emitting perovskite (bandgap ~ 2.3 eV)
  let wls = [
    350.0, 400.0, 450.0, 500.0, 520.0, 540.0, 560.0, 600.0, 650.0, 700.0, 800.0,
  ]
  let n_arr = [2.25, 2.38, 2.45, 2.55, 2.62, 2.40, 2.25, 2.15, 2.10, 2.08, 2.05]
  let k_arr = [0.85, 0.75, 0.60, 0.40, 0.15, 0.005, 0.0, 0.0, 0.0, 0.0, 0.0]
  let tab = @disp.TabulatedDispersion::new("CsPbBr3", wls, n_arr, k_arr)
  {
    name: "CsPbBr3 Green Perovskite",
    category: MaterialCategory::Semiconductor,
    formula: "CsPbBr3",
    bandgap_ev: 2.30,
    dispersion_fn: fn(wl) { tab.get_complex_index(wl) },
  }
}

///|
pub fn double_perovskite_cs2agbibbr6() -> OpticalMaterial {
  // Lead-free Double Perovskite Cs2AgBiBr6 (bandgap ~ 2.05 eV)
  let cauchy = @disp.CauchyDispersion::new(2.18, 0.022, 0.0, 0.15, 0.01)
  {
    name: "Cs2AgBiBr6 Double Perovskite",
    category: MaterialCategory::Semiconductor,
    formula: "Cs2AgBiBr6",
    bandgap_ev: 2.05,
    dispersion_fn: fn(wl) { cauchy.get_complex_index(wl) },
  }
}

// ----------------------------------------------------------------------------
// 2. Wide Bandgap & Power Semiconductors
// ----------------------------------------------------------------------------

///|
pub fn silicon_carbide_4h() -> OpticalMaterial {
  // 4H-SiC (Silicon Carbide) power semiconductor
  let sell = @disp.Sellmeier3Dispersion::new(
    5.5515,
    0.1625 * 0.1625,
    0.0,
    0.0,
    0.0,
    0.0,
  )
  {
    name: "4H-SiC (Silicon Carbide)",
    category: MaterialCategory::Semiconductor,
    formula: "SiC",
    bandgap_ev: 3.26,
    dispersion_fn: fn(wl) { sell.get_complex_index(wl) },
  }
}

///|
pub fn gallium_nitride() -> OpticalMaterial {
  // Wurtzite GaN (Barker and Ilegems 1973)
  let cauchy = @disp.CauchyDispersion::transparent(2.32, 0.028, 0.002)
  {
    name: "GaN (Gallium Nitride)",
    category: MaterialCategory::Semiconductor,
    formula: "GaN",
    bandgap_ev: 3.44,
    dispersion_fn: fn(wl) { cauchy.get_complex_index(wl) },
  }
}

///|
pub fn aluminum_nitride() -> OpticalMaterial {
  // AlN deep-ultraviolet semiconductor (Eg ~ 6.2 eV)
  let sell = @disp.Sellmeier3Dispersion::new(
    3.1399,
    0.1415 * 0.1415,
    3.2989,
    13.78 * 13.78,
    0.0,
    0.0,
  )
  {
    name: "AlN (Aluminum Nitride)",
    category: MaterialCategory::Semiconductor,
    formula: "AlN",
    bandgap_ev: 6.20,
    dispersion_fn: fn(wl) { sell.get_complex_index(wl) },
  }
}

///|
pub fn zinc_oxide() -> OpticalMaterial {
  // ZnO (Bond 1965)
  let cauchy = @disp.CauchyDispersion::transparent(1.98, 0.019, 0.001)
  {
    name: "ZnO (Zinc Oxide)",
    category: MaterialCategory::Semiconductor,
    formula: "ZnO",
    bandgap_ev: 3.37,
    dispersion_fn: fn(wl) { cauchy.get_complex_index(wl) },
  }
}

///|
pub fn gallium_oxide() -> OpticalMaterial {
  // Beta-Ga2O3 ultra-wide bandgap oxide (Eg ~ 4.9 eV)
  let cauchy = @disp.CauchyDispersion::transparent(1.89, 0.011, 0.0)
  {
    name: "beta-Ga2O3 (Gallium Oxide)",
    category: MaterialCategory::Semiconductor,
    formula: "Ga2O3",
    bandgap_ev: 4.85,
    dispersion_fn: fn(wl) { cauchy.get_complex_index(wl) },
  }
}

// ----------------------------------------------------------------------------
// 3. Narrow Bandgap & Infrared Semiconductors
// ----------------------------------------------------------------------------

///|
pub fn germanium() -> OpticalMaterial {
  // Crystalline Germanium (c-Ge) (Palik 1985)
  let wls = [
    500.0, 600.0, 700.0, 800.0, 900.0, 1000.0, 1200.0, 1400.0, 1600.0, 2000.0,
  ]
  let n_arr = [4.14, 5.26, 5.08, 4.78, 4.54, 4.38, 4.22, 4.14, 4.09, 4.04]
  let k_arr = [2.22, 1.25, 0.72, 0.44, 0.28, 0.15, 0.02, 0.0, 0.0, 0.0]
  let tab = @disp.TabulatedDispersion::new("Germanium", wls, n_arr, k_arr)
  {
    name: "c-Ge (Germanium)",
    category: MaterialCategory::Semiconductor,
    formula: "Ge",
    bandgap_ev: 0.66,
    dispersion_fn: fn(wl) { tab.get_complex_index(wl) },
  }
}

///|
pub fn indium_phosphide() -> OpticalMaterial {
  // InP (Pettit and Turner 1965)
  let wls = [500.0, 600.0, 700.0, 800.0, 900.0, 1000.0, 1200.0, 1550.0]
  let n_arr = [3.82, 3.58, 3.48, 3.42, 3.38, 3.25, 3.17, 3.10]
  let k_arr = [0.45, 0.26, 0.18, 0.08, 0.01, 0.0, 0.0, 0.0]
  let tab = @disp.TabulatedDispersion::new("InP", wls, n_arr, k_arr)
  {
    name: "InP (Indium Phosphide)",
    category: MaterialCategory::Semiconductor,
    formula: "InP",
    bandgap_ev: 1.344,
    dispersion_fn: fn(wl) { tab.get_complex_index(wl) },
  }
}

///|
pub fn cadmium_telluride() -> OpticalMaterial {
  // CdTe thin-film photovoltaic semiconductor
  let wls = [400.0, 500.0, 600.0, 700.0, 800.0, 850.0, 900.0, 1000.0, 1200.0]
  let n_arr = [3.75, 3.32, 3.08, 2.98, 2.92, 2.88, 2.76, 2.72, 2.68]
  let k_arr = [1.20, 0.58, 0.32, 0.18, 0.06, 0.005, 0.0, 0.0, 0.0]
  let tab = @disp.TabulatedDispersion::new("CdTe", wls, n_arr, k_arr)
  {
    name: "CdTe (Cadmium Telluride)",
    category: MaterialCategory::Semiconductor,
    formula: "CdTe",
    bandgap_ev: 1.44,
    dispersion_fn: fn(wl) { tab.get_complex_index(wl) },
  }
}

///|
pub fn lead_sulfide_quantum_dots() -> OpticalMaterial {
  // PbS colloidal quantum dots for infrared photodetectors
  let cauchy = @disp.CauchyDispersion::new(2.45, 0.035, 0.0, 0.30, 0.02)
  {
    name: "PbS Colloidal Quantum Dots",
    category: MaterialCategory::Semiconductor,
    formula: "PbS",
    bandgap_ev: 0.95,
    dispersion_fn: fn(wl) { cauchy.get_complex_index(wl) },
  }
}

// ----------------------------------------------------------------------------
// 4. Refractory & Plasmonic Transition Metals
// ----------------------------------------------------------------------------

///|
pub fn titanium() -> OpticalMaterial {
  // Johnson and Christy 1974 Ti
  let wls = [300.0, 400.0, 500.0, 600.0, 700.0, 800.0, 900.0, 1000.0, 1550.0]
  let n_arr = [1.45, 1.95, 2.35, 2.75, 3.10, 3.42, 3.65, 3.85, 4.35]
  let k_arr = [2.25, 2.60, 2.95, 3.30, 3.60, 3.88, 4.10, 4.30, 5.20]
  let tab = @disp.TabulatedDispersion::new("Titanium", wls, n_arr, k_arr)
  {
    name: "Ti (Titanium)",
    category: MaterialCategory::Metal,
    formula: "Ti",
    bandgap_ev: 0.0,
    dispersion_fn: fn(wl) { tab.get_complex_index(wl) },
  }
}

///|
pub fn chromium() -> OpticalMaterial {
  // Johnson and Christy 1974 Cr (adhesion layer)
  let wls = [300.0, 400.0, 500.0, 600.0, 700.0, 800.0, 900.0, 1000.0, 1550.0]
  let n_arr = [1.32, 2.10, 2.95, 3.45, 3.80, 4.10, 4.35, 4.55, 5.10]
  let k_arr = [2.65, 3.25, 3.90, 4.25, 4.40, 4.50, 4.60, 4.70, 5.30]
  let tab = @disp.TabulatedDispersion::new("Chromium", wls, n_arr, k_arr)
  {
    name: "Cr (Chromium)",
    category: MaterialCategory::Metal,
    formula: "Cr",
    bandgap_ev: 0.0,
    dispersion_fn: fn(wl) { tab.get_complex_index(wl) },
  }
}

///|
pub fn platinum() -> OpticalMaterial {
  // Werner et al. 2009 Pt
  let wls = [300.0, 400.0, 500.0, 600.0, 700.0, 800.0, 900.0, 1000.0, 1550.0]
  let n_arr = [1.45, 1.85, 2.30, 2.75, 3.20, 3.65, 4.05, 4.45, 5.80]
  let k_arr = [2.50, 3.20, 3.85, 4.40, 4.90, 5.35, 5.75, 6.15, 7.90]
  let tab = @disp.TabulatedDispersion::new("Platinum", wls, n_arr, k_arr)
  {
    name: "Pt (Platinum)",
    category: MaterialCategory::Metal,
    formula: "Pt",
    bandgap_ev: 0.0,
    dispersion_fn: fn(wl) { tab.get_complex_index(wl) },
  }
}

///|
pub fn nickel() -> OpticalMaterial {
  let wls = [300.0, 400.0, 500.0, 600.0, 700.0, 800.0, 1000.0, 1550.0]
  let n_arr = [1.38, 1.62, 1.78, 1.95, 2.15, 2.38, 2.80, 3.65]
  let k_arr = [1.95, 2.45, 2.95, 3.45, 3.90, 4.30, 4.95, 6.40]
  let tab = @disp.TabulatedDispersion::new("Nickel", wls, n_arr, k_arr)
  {
    name: "Ni (Nickel)",
    category: MaterialCategory::Metal,
    formula: "Ni",
    bandgap_ev: 0.0,
    dispersion_fn: fn(wl) { tab.get_complex_index(wl) },
  }
}

///|
pub fn tungsten() -> OpticalMaterial {
  // High melting point thermal radiation emitter
  let wls = [400.0, 500.0, 600.0, 700.0, 800.0, 1000.0, 1550.0]
  let n_arr = [3.25, 3.48, 3.65, 3.75, 3.80, 3.60, 3.20]
  let k_arr = [2.65, 2.85, 2.95, 3.05, 3.15, 3.35, 4.10]
  let tab = @disp.TabulatedDispersion::new("Tungsten", wls, n_arr, k_arr)
  {
    name: "W (Tungsten)",
    category: MaterialCategory::Metal,
    formula: "W",
    bandgap_ev: 0.0,
    dispersion_fn: fn(wl) { tab.get_complex_index(wl) },
  }
}

// ----------------------------------------------------------------------------
// 5. 2D Transition Metal Dichalcogenides (TMDCs)
// ----------------------------------------------------------------------------

///|
pub fn mos2_monolayer() -> OpticalMaterial {
  // Monolayer MoS2 with A and B exciton resonance peaks (Li et al. 2014)
  let wls = [
    400.0, 450.0, 500.0, 550.0, 600.0, 615.0, 640.0, 660.0, 680.0, 720.0, 800.0,
  ]
  let n_arr = [4.20, 4.65, 4.85, 4.90, 5.40, 5.95, 4.80, 6.20, 4.50, 3.85, 3.60]
  let k_arr = [2.40, 2.10, 1.85, 1.65, 2.20, 2.85, 1.50, 3.10, 0.80, 0.15, 0.02]
  let tab = @disp.TabulatedDispersion::new("MoS2_Monolayer", wls, n_arr, k_arr)
  {
    name: "MoS2 Monolayer (2D)",
    category: MaterialCategory::TwoDimensional,
    formula: "MoS2 (1L)",
    bandgap_ev: 1.88,
    dispersion_fn: fn(wl) { tab.get_complex_index(wl) },
  }
}

///|
pub fn ws2_monolayer() -> OpticalMaterial {
  // Monolayer WS2 direct bandgap 2D crystal (Eg ~ 2.01 eV)
  let wls = [
    400.0, 450.0, 500.0, 550.0, 580.0, 615.0, 630.0, 660.0, 700.0, 800.0,
  ]
  let n_arr = [3.90, 4.40, 4.70, 4.80, 5.50, 6.10, 4.60, 4.10, 3.70, 3.45]
  let k_arr = [2.20, 1.95, 1.65, 1.45, 2.10, 3.25, 0.95, 0.30, 0.05, 0.01]
  let tab = @disp.TabulatedDispersion::new("WS2_Monolayer", wls, n_arr, k_arr)
  {
    name: "WS2 Monolayer (2D)",
    category: MaterialCategory::TwoDimensional,
    formula: "WS2 (1L)",
    bandgap_ev: 2.01,
    dispersion_fn: fn(wl) { tab.get_complex_index(wl) },
  }
}

// ----------------------------------------------------------------------------
// 6. Ferroelectric & Electro-Optic Crystals
// ----------------------------------------------------------------------------

///|
pub fn lithium_niobate() -> OpticalMaterial {
  // LiNbO3 ordinary ray (Zelmon et al. 1997)
  let sell = @disp.Sellmeier3Dispersion::new(
    2.9804, 0.02047, 0.5981, 0.0666, 8.9543, 416.08,
  )
  {
    name: "LiNbO3 (Lithium Niobate, o-ray)",
    category: MaterialCategory::Dielectric,
    formula: "LiNbO3",
    bandgap_ev: 3.80,
    dispersion_fn: fn(wl) { sell.get_complex_index(wl) },
  }
}

///|
pub fn barium_titanate() -> OpticalMaterial {
  // BaTiO3 high dielectric constant ferroelectric
  let cauchy = @disp.CauchyDispersion::transparent(2.38, 0.038, 0.002)
  {
    name: "BaTiO3 (Barium Titanate)",
    category: MaterialCategory::Dielectric,
    formula: "BaTiO3",
    bandgap_ev: 3.20,
    dispersion_fn: fn(wl) { cauchy.get_complex_index(wl) },
  }
}

///|
pub fn zinc_selenide() -> OpticalMaterial {
  // ZnSe infrared window (Marple 1964)
  let sell = @disp.Sellmeier3Dispersion::new(
    4.298,
    0.192 * 0.192,
    0.6277,
    0.378 * 0.378,
    2.8955,
    46.7 * 46.7,
  )
  {
    name: "ZnSe (Zinc Selenide)",
    category: MaterialCategory::Dielectric,
    formula: "ZnSe",
    bandgap_ev: 2.70,
    dispersion_fn: fn(wl) { sell.get_complex_index(wl) },
  }
}

// ----------------------------------------------------------------------------
// 7. Optical Polymers, Adhesives & Photoresists
// ----------------------------------------------------------------------------

///|
pub fn su8_photoresist() -> OpticalMaterial {
  // SU-8 epoxy-based negative photoresist for microfluidics and waveguides
  let cauchy = @disp.CauchyDispersion::transparent(1.585, 0.0075, 0.0005)
  {
    name: "SU-8 Photoresist",
    category: MaterialCategory::Polymer,
    formula: "Epoxy Resin",
    bandgap_ev: 3.90,
    dispersion_fn: fn(wl) { cauchy.get_complex_index(wl) },
  }
}

///|
pub fn pdms_silicone() -> OpticalMaterial {
  // Polydimethylsiloxane (PDMS) elastomer (n ~ 1.41)
  let cauchy = @disp.CauchyDispersion::transparent(1.405, 0.0038, 0.0)
  {
    name: "PDMS (Silicone Elastomer)",
    category: MaterialCategory::Polymer,
    formula: "(C2H6OSi)n",
    bandgap_ev: 6.0,
    dispersion_fn: fn(wl) { cauchy.get_complex_index(wl) },
  }
}

///|
pub fn norland_optical_adhesive_68() -> OpticalMaterial {
  // NOA 68 UV-curable optical adhesive (n = 1.54)
  let cauchy = @disp.CauchyDispersion::transparent(1.535, 0.0055, 0.0)
  {
    name: "NOA 68 Optical Adhesive",
    category: MaterialCategory::Polymer,
    formula: "Thiol-Ene UV Adhesive",
    bandgap_ev: 3.80,
    dispersion_fn: fn(wl) { cauchy.get_complex_index(wl) },
  }
}
