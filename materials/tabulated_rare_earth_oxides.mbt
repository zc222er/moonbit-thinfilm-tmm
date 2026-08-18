///|
// ============================================================================
// Rare Earth & High-k Optical Oxides Database
// Laser host materials and advanced optical coating dielectrics
// ============================================================================

///|
pub fn yttrium_oxide_y2o3() -> OpticalMaterial {
  // Y2O3 (Yttria) high-power laser dielectric (Nigara 1968)
  let sell = @disp.Sellmeier3Dispersion::new(
    2.578,
    0.137 * 0.137,
    0.0,
    0.0,
    3.86,
    18.7 * 18.7,
  )
  {
    name: "Y2O3 (Yttrium Oxide / Yttria)",
    category: MaterialCategory::Dielectric,
    formula: "Y2O3",
    bandgap_ev: 5.6,
    dispersion_fn: fn(wl) { sell.get_complex_index(wl) },
  }
}

///|
pub fn scandium_oxide_sc2o3() -> OpticalMaterial {
  // Sc2O3 high laser damage threshold coating material
  let cauchy = @disp.CauchyDispersion::transparent(1.964, 0.016, 0.0008)
  {
    name: "Sc2O3 (Scandium Oxide)",
    category: MaterialCategory::Dielectric,
    formula: "Sc2O3",
    bandgap_ev: 6.0,
    dispersion_fn: fn(wl) { cauchy.get_complex_index(wl) },
  }
}

///|
pub fn lanthanum_oxide_la2o3() -> OpticalMaterial {
  // La2O3 high-k gate dielectric (Eg ~ 5.8 eV)
  let cauchy = @disp.CauchyDispersion::transparent(1.928, 0.014, 0.0005)
  {
    name: "La2O3 (Lanthanum Oxide)",
    category: MaterialCategory::Dielectric,
    formula: "La2O3",
    bandgap_ev: 5.8,
    dispersion_fn: fn(wl) { cauchy.get_complex_index(wl) },
  }
}

///|
pub fn hafnium_dioxide_hfo2_precise() -> OpticalMaterial {
  // HfO2 (Hafnia) high-k dielectric (Franta et al. 2011)
  let cauchy = @disp.CauchyDispersion::transparent(2.065, 0.021, 0.0012)
  {
    name: "HfO2 (Hafnium Dioxide)",
    category: MaterialCategory::Dielectric,
    formula: "HfO2",
    bandgap_ev: 5.7,
    dispersion_fn: fn(wl) { cauchy.get_complex_index(wl) },
  }
}

///|
pub fn zirconium_dioxide_zro2() -> OpticalMaterial {
  // ZrO2 (Zirconia) high index optical coating
  let cauchy = @disp.CauchyDispersion::transparent(2.135, 0.024, 0.0018)
  {
    name: "ZrO2 (Zirconium Dioxide)",
    category: MaterialCategory::Dielectric,
    formula: "ZrO2",
    bandgap_ev: 5.5,
    dispersion_fn: fn(wl) { cauchy.get_complex_index(wl) },
  }
}
