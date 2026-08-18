///|
// ============================================================================
// Scintillator Crystals & Radiation Detection Optics Database
// Precision Sellmeier dispersion for medical imaging (PET/CT) & calorimetry
// ============================================================================

///|
pub fn bgo_bismuth_germanate() -> OpticalMaterial {
  // Bi4Ge3O12 (BGO) high density gamma ray scintillator (n_d = 2.15)
  let sell = @disp.Sellmeier3Dispersion::new(3.562, 0.0195, 0.0, 0.0, 0.0, 0.0)
  {
    name: "Bi4Ge3O12 (BGO Scintillator)",
    category: MaterialCategory::Dielectric,
    formula: "Bi4Ge3O12",
    bandgap_ev: 4.8,
    dispersion_fn: fn(wl) { sell.get_complex_index(wl) },
  }
}

///|
pub fn lyso_lutetium_yttrium_oxyorthosilicate() -> OpticalMaterial {
  // LYSO:Ce (Lu1.8Y0.2SiO5:Ce) premier TOF-PET medical imaging crystal (n = 1.82)
  let sell = @disp.Sellmeier3Dispersion::new(2.285, 0.0142, 0.0, 0.0, 0.0, 0.0)
  {
    name: "LYSO:Ce Scintillator",
    category: MaterialCategory::Dielectric,
    formula: "Lu1.8Y0.2SiO5:Ce",
    bandgap_ev: 6.0,
    dispersion_fn: fn(wl) { sell.get_complex_index(wl) },
  }
}

///|
pub fn lead_tungstate_pbwo4() -> OpticalMaterial {
  // PbWO4 (PWO) high-energy physics crystal (CERN CMS calorimeter)
  let sell = @disp.Sellmeier3Dispersion::new(3.685, 0.0265, 0.0, 0.0, 0.0, 0.0)
  {
    name: "PbWO4 (Lead Tungstate)",
    category: MaterialCategory::Dielectric,
    formula: "PbWO4",
    bandgap_ev: 4.2,
    dispersion_fn: fn(wl) { sell.get_complex_index(wl) },
  }
}

///|
pub fn sodium_iodide_nai() -> OpticalMaterial {
  // NaI:Tl standard radiation detector (n_d = 1.77)
  let sell = @disp.Sellmeier3Dispersion::new(2.124, 0.0162, 0.0, 0.0, 0.0, 0.0)
  {
    name: "NaI:Tl Scintillator",
    category: MaterialCategory::Dielectric,
    formula: "NaI:Tl",
    bandgap_ev: 5.9,
    dispersion_fn: fn(wl) { sell.get_complex_index(wl) },
  }
}
