///|
/// Material category
pub enum MaterialCategory {
  Dielectric
  Semiconductor
  Metal
  TCO
  Polymer
  TwoDimensional
  Liquid
} derive(Eq)

///|
pub impl Show for MaterialCategory with fn output(self, logger) {
  match self {
    Dielectric => logger.write_string("Dielectric")
    Semiconductor => logger.write_string("Semiconductor")
    Metal => logger.write_string("Metal")
    TCO => logger.write_string("TransparentConductiveOxide")
    Polymer => logger.write_string("Polymer")
    TwoDimensional => logger.write_string("2DMaterial")
    Liquid => logger.write_string("Liquid")
  }
}

///|
/// Optical Material Definition with physical parameters and dispersion model
pub struct OpticalMaterial {
  name : String
  category : MaterialCategory
  formula : String
  bandgap_ev : Double
  dispersion_fn : (Double) -> @core.Complex
}

///|
pub impl Show for OpticalMaterial with fn output(self, logger) {
  logger.write_string(
    "OpticalMaterial('\{self.name}', formula='\{self.formula}', category=\{self.category})",
  )
}

///|
pub impl Eq for OpticalMaterial with fn equal(self, other) {
  self.name == other.name && self.formula == other.formula
}

///|
pub fn OpticalMaterial::get_index(
  self : OpticalMaterial,
  wavelength_nm : Double,
) -> @core.Complex {
  (self.dispersion_fn)(wavelength_nm)
}

///|
pub fn OpticalMaterial::to_layer(
  self : OpticalMaterial,
  thickness_nm : Double,
  wavelength_nm : Double,
) -> @core.Layer {
  let n = self.get_index(wavelength_nm)
  @core.Layer::new(self.name, thickness_nm, n)
}

// -------------------------------------------------------------
// 1. Dielectrics & Optical Glasses
// -------------------------------------------------------------

///|
pub fn air() -> OpticalMaterial {
  {
    name: "Air",
    category: MaterialCategory::Dielectric,
    formula: "Air",
    bandgap_ev: 0.0,
    dispersion_fn: fn(_wl) { @core.Complex::from_real(1.0) },
  }
}

///|
pub fn vacuum() -> OpticalMaterial {
  {
    name: "Vacuum",
    category: MaterialCategory::Dielectric,
    formula: "Vacuum",
    bandgap_ev: 0.0,
    dispersion_fn: fn(_wl) { @core.Complex::from_real(1.0) },
  }
}

///|
pub fn bk7() -> OpticalMaterial {
  let sell = @disp.Sellmeier3Dispersion::bk7()
  {
    name: "BK7",
    category: MaterialCategory::Dielectric,
    formula: "Schott N-BK7",
    bandgap_ev: 4.1,
    dispersion_fn: fn(wl) { sell.get_complex_index(wl) },
  }
}

///|
pub fn fused_silica() -> OpticalMaterial {
  let sell = @disp.Sellmeier3Dispersion::fused_silica()
  {
    name: "SiO2 (Fused Silica)",
    category: MaterialCategory::Dielectric,
    formula: "SiO2",
    bandgap_ev: 8.9,
    dispersion_fn: fn(wl) { sell.get_complex_index(wl) },
  }
}

///|
pub fn silicon_nitride() -> OpticalMaterial {
  // Philipp 1973 Cauchy model for Si3N4
  let cauchy = @disp.CauchyDispersion::transparent(1.996, 0.0125, 0.0)
  {
    name: "Si3N4 (Silicon Nitride)",
    category: MaterialCategory::Dielectric,
    formula: "Si3N4",
    bandgap_ev: 5.0,
    dispersion_fn: fn(wl) { cauchy.get_complex_index(wl) },
  }
}

///|
pub fn titanium_dioxide() -> OpticalMaterial {
  // Devore 1951 Sellmeier for Rutile TiO2 (ordinary ray)
  let cauchy = @disp.CauchyDispersion::transparent(2.48, 0.045, 0.003)
  {
    name: "TiO2 (Titanium Dioxide)",
    category: MaterialCategory::Dielectric,
    formula: "TiO2",
    bandgap_ev: 3.2,
    dispersion_fn: fn(wl) { cauchy.get_complex_index(wl) },
  }
}

///|
pub fn aluminum_oxide() -> OpticalMaterial {
  // Malitson 1962 Sellmeier for Al2O3 Sapphire
  let cauchy = @disp.CauchyDispersion::transparent(1.745, 0.0055, 0.0)
  {
    name: "Al2O3 (Alumina/Sapphire)",
    category: MaterialCategory::Dielectric,
    formula: "Al2O3",
    bandgap_ev: 7.5,
    dispersion_fn: fn(wl) { cauchy.get_complex_index(wl) },
  }
}

///|
pub fn hafnium_oxide() -> OpticalMaterial {
  let cauchy = @disp.CauchyDispersion::transparent(1.98, 0.011, 0.0)
  {
    name: "HfO2 (Hafnium Oxide)",
    category: MaterialCategory::Dielectric,
    formula: "HfO2",
    bandgap_ev: 5.7,
    dispersion_fn: fn(wl) { cauchy.get_complex_index(wl) },
  }
}

///|
pub fn tantalum_pentoxide() -> OpticalMaterial {
  let cauchy = @disp.CauchyDispersion::transparent(2.08, 0.018, 0.0)
  {
    name: "Ta2O5 (Tantalum Oxide)",
    category: MaterialCategory::Dielectric,
    formula: "Ta2O5",
    bandgap_ev: 4.2,
    dispersion_fn: fn(wl) { cauchy.get_complex_index(wl) },
  }
}

///|
pub fn magnesium_fluoride() -> OpticalMaterial {
  // Dodge 1984 Sellmeier for MgF2
  let cauchy = @disp.CauchyDispersion::transparent(1.375, 0.003, 0.0)
  {
    name: "MgF2 (Magnesium Fluoride)",
    category: MaterialCategory::Dielectric,
    formula: "MgF2",
    bandgap_ev: 11.8,
    dispersion_fn: fn(wl) { cauchy.get_complex_index(wl) },
  }
}

///|
pub fn diamond() -> OpticalMaterial {
  let cauchy = @disp.CauchyDispersion::transparent(2.38, 0.012, 0.0)
  {
    name: "Diamond",
    category: MaterialCategory::Dielectric,
    formula: "C",
    bandgap_ev: 5.47,
    dispersion_fn: fn(wl) { cauchy.get_complex_index(wl) },
  }
}

// -------------------------------------------------------------
// 2. Semiconductors
// -------------------------------------------------------------

///|
pub fn crystalline_silicon() -> OpticalMaterial {
  // Green 2008 high precision tabulated data for C-Si at 300K
  let wls = [
    250.0, 300.0, 350.0, 400.0, 450.0, 500.0, 550.0, 600.0, 650.0, 700.0, 750.0,
    800.0, 850.0, 900.0, 950.0, 1000.0, 1050.0, 1100.0, 1200.0, 1550.0,
  ]
  let n_arr = [
    1.62, 5.02, 5.48, 5.57, 4.67, 4.30, 4.09, 3.94, 3.84, 3.77, 3.71, 3.67, 3.64,
    3.61, 3.59, 3.57, 3.56, 3.54, 3.52, 3.48,
  ]
  let k_arr = [
    3.64, 3.32, 3.01, 0.38, 0.13, 0.072, 0.044, 0.028, 0.018, 0.012, 0.0078, 0.0052,
    0.0034, 0.0021, 0.0012, 0.0006, 0.0002, 0.00005, 0.0, 0.0,
  ]
  let tab = @disp.TabulatedDispersion::new(
    "Crystalline Silicon", wls, n_arr, k_arr,
  )
  {
    name: "c-Si (Crystalline Silicon)",
    category: MaterialCategory::Semiconductor,
    formula: "Si",
    bandgap_ev: 1.12,
    dispersion_fn: fn(wl) { tab.get_complex_index(wl) },
  }
}

///|
pub fn amorphous_silicon() -> OpticalMaterial {
  let tl = @disp.TaucLorentzDispersion::new(1.8, 140.0, 3.65, 2.2, 1.6)
  {
    name: "a-Si:H (Hydrogenated Amorphous Silicon)",
    category: MaterialCategory::Semiconductor,
    formula: "a-Si:H",
    bandgap_ev: 1.6,
    dispersion_fn: fn(wl) { tl.get_complex_index(wl) },
  }
}

///|
pub fn gallium_arsenide() -> OpticalMaterial {
  let wls = [
    400.0, 500.0, 600.0, 700.0, 800.0, 850.0, 900.0, 1000.0, 1200.0, 1550.0,
  ]
  let n_arr = [4.38, 4.31, 3.91, 3.79, 3.68, 3.65, 3.59, 3.51, 3.42, 3.37]
  let k_arr = [2.08, 0.61, 0.28, 0.15, 0.08, 0.03, 0.0, 0.0, 0.0, 0.0]
  let tab = @disp.TabulatedDispersion::new("GaAs", wls, n_arr, k_arr)
  {
    name: "GaAs (Gallium Arsenide)",
    category: MaterialCategory::Semiconductor,
    formula: "GaAs",
    bandgap_ev: 1.424,
    dispersion_fn: fn(wl) { tab.get_complex_index(wl) },
  }
}

///|
pub fn perovskite_mapbi3() -> OpticalMaterial {
  // MAPbI3 Methylammonium Lead Iodide Perovskite (Loper et al. 2015)
  let wls = [
    350.0, 400.0, 450.0, 500.0, 550.0, 600.0, 650.0, 700.0, 750.0, 800.0, 850.0,
    900.0,
  ]
  let n_arr = [
    2.40, 2.55, 2.62, 2.58, 2.52, 2.48, 2.50, 2.61, 2.65, 2.45, 2.30, 2.25,
  ]
  let k_arr = [
    0.95, 0.85, 0.72, 0.58, 0.44, 0.32, 0.24, 0.20, 0.15, 0.01, 0.0, 0.0,
  ]
  let tab = @disp.TabulatedDispersion::new("MAPbI3", wls, n_arr, k_arr)
  {
    name: "MAPbI3 Perovskite",
    category: MaterialCategory::Semiconductor,
    formula: "CH3NH3PbI3",
    bandgap_ev: 1.55,
    dispersion_fn: fn(wl) { tab.get_complex_index(wl) },
  }
}

// -------------------------------------------------------------
// 3. Metals (Johnson and Christy 1972)
// -------------------------------------------------------------

///|
pub fn gold() -> OpticalMaterial {
  let wls = [
    300.0, 350.0, 400.0, 450.0, 500.0, 550.0, 600.0, 650.0, 700.0, 750.0, 800.0,
    900.0, 1000.0, 1550.0,
  ]
  let n_arr = [
    1.66, 1.75, 1.66, 1.40, 0.84, 0.33, 0.20, 0.14, 0.13, 0.14, 0.16, 0.21, 0.27,
    0.55,
  ]
  let k_arr = [
    1.96, 1.95, 1.96, 1.88, 1.85, 2.32, 2.90, 3.65, 4.10, 4.54, 4.95, 5.75, 6.55,
    10.8,
  ]
  let tab = @disp.TabulatedDispersion::new("Gold", wls, n_arr, k_arr)
  {
    name: "Au (Gold)",
    category: MaterialCategory::Metal,
    formula: "Au",
    bandgap_ev: 0.0,
    dispersion_fn: fn(wl) { tab.get_complex_index(wl) },
  }
}

///|
pub fn silver() -> OpticalMaterial {
  let wls = [
    300.0, 350.0, 400.0, 450.0, 500.0, 550.0, 600.0, 650.0, 700.0, 750.0, 800.0,
    900.0, 1000.0, 1550.0,
  ]
  let n_arr = [
    1.25, 0.28, 0.08, 0.05, 0.05, 0.06, 0.06, 0.06, 0.07, 0.08, 0.09, 0.11, 0.14,
    0.47,
  ]
  let k_arr = [
    1.00, 1.25, 2.05, 2.65, 3.10, 3.55, 4.00, 4.40, 4.80, 5.20, 5.60, 6.40, 7.15,
    11.2,
  ]
  let tab = @disp.TabulatedDispersion::new("Silver", wls, n_arr, k_arr)
  {
    name: "Ag (Silver)",
    category: MaterialCategory::Metal,
    formula: "Ag",
    bandgap_ev: 0.0,
    dispersion_fn: fn(wl) { tab.get_complex_index(wl) },
  }
}

///|
pub fn aluminum() -> OpticalMaterial {
  // Rakic 1998 Drude-Lorentz parameters for Aluminum
  let drude = @disp.DrudeLorentzDispersion::new(0.7, 14.98, 0.047, [
    @disp.LorentzOscillator::new(0.523, 0.16, 0.351),
    @disp.LorentzOscillator::new(1.309, 1.54, 0.312),
    @disp.LorentzOscillator::new(0.014, 1.80, 0.316),
  ])
  {
    name: "Al (Aluminum)",
    category: MaterialCategory::Metal,
    formula: "Al",
    bandgap_ev: 0.0,
    dispersion_fn: fn(wl) { drude.get_complex_index(wl) },
  }
}

///|
pub fn copper() -> OpticalMaterial {
  let wls = [
    300.0, 350.0, 400.0, 450.0, 500.0, 550.0, 600.0, 650.0, 700.0, 800.0, 1000.0,
  ]
  let n_arr = [1.40, 1.34, 1.28, 1.20, 1.05, 0.72, 0.27, 0.22, 0.20, 0.23, 0.32]
  let k_arr = [1.78, 1.95, 2.18, 2.45, 2.60, 2.58, 3.25, 3.75, 4.25, 5.15, 6.75]
  let tab = @disp.TabulatedDispersion::new("Copper", wls, n_arr, k_arr)
  {
    name: "Cu (Copper)",
    category: MaterialCategory::Metal,
    formula: "Cu",
    bandgap_ev: 0.0,
    dispersion_fn: fn(wl) { tab.get_complex_index(wl) },
  }
}

// -------------------------------------------------------------
// 4. Transparent Conductive Oxides (TCO), 2D & Polymers
// -------------------------------------------------------------

///|
pub fn indium_tin_oxide() -> OpticalMaterial {
  // Drude model for conductive ITO thin films (wp = 1.95 eV, eps_inf = 3.9)
  let drude = @disp.DrudeDispersion::new(3.9, 1.95, 0.12)
  {
    name: "ITO (Indium Tin Oxide)",
    category: MaterialCategory::TCO,
    formula: "In2O3:Sn",
    bandgap_ev: 3.8,
    dispersion_fn: fn(wl) { drude.get_complex_index(wl) },
  }
}

///|
pub fn graphene_monolayer() -> OpticalMaterial {
  // Monolayer Graphene: n = 3.0, k = 5.446 * (lambda_um / 3.0) or approx (2.6, 1.3) in visible
  let cauchy = @disp.CauchyDispersion::new(2.6, 0.015, 0.0, 1.3, 0.005)
  {
    name: "Graphene Monolayer",
    category: MaterialCategory::TwoDimensional,
    formula: "C (2D Monolayer)",
    bandgap_ev: 0.0,
    dispersion_fn: fn(wl) { cauchy.get_complex_index(wl) },
  }
}

///|
pub fn pedot_pss() -> OpticalMaterial {
  let cauchy = @disp.CauchyDispersion::new(1.52, 0.007, 0.0, 0.015, 0.002)
  {
    name: "PEDOT:PSS",
    category: MaterialCategory::Polymer,
    formula: "Polymer Hole Transport",
    bandgap_ev: 2.2,
    dispersion_fn: fn(wl) { cauchy.get_complex_index(wl) },
  }
}

///|
pub fn pmma() -> OpticalMaterial {
  let cauchy = @disp.CauchyDispersion::transparent(1.488, 0.004, 0.0)
  {
    name: "PMMA (Acrylic)",
    category: MaterialCategory::Polymer,
    formula: "C5O2H8",
    bandgap_ev: 4.8,
    dispersion_fn: fn(wl) { cauchy.get_complex_index(wl) },
  }
}

///|
pub fn water() -> OpticalMaterial {
  let cauchy = @disp.CauchyDispersion::transparent(1.333, 0.0031, 0.0)
  {
    name: "Water",
    category: MaterialCategory::Liquid,
    formula: "H2O",
    bandgap_ev: 6.9,
    dispersion_fn: fn(wl) { cauchy.get_complex_index(wl) },
  }
}

///|
/// Material Database Registry with lookup by name
pub struct MaterialDatabase {
  materials : Array[OpticalMaterial]
}

///|
pub fn MaterialDatabase::standard() -> MaterialDatabase {
  {
    materials: [
      air(),
      vacuum(),
      bk7(),
      fused_silica(),
      silicon_nitride(),
      titanium_dioxide(),
      aluminum_oxide(),
      hafnium_oxide(),
      tantalum_pentoxide(),
      magnesium_fluoride(),
      diamond(),
      crystalline_silicon(),
      amorphous_silicon(),
      gallium_arsenide(),
      perovskite_mapbi3(),
      gold(),
      silver(),
      aluminum(),
      copper(),
      indium_tin_oxide(),
      graphene_monolayer(),
      pedot_pss(),
      pmma(),
      water(),
    ],
  }
}

///|
pub fn MaterialDatabase::find(
  self : MaterialDatabase,
  name_query : String,
) -> OpticalMaterial? {
  for mat in self.materials {
    if mat.name == name_query || mat.formula == name_query {
      return Some(mat)
    }
  }
  None
}

///|
pub fn MaterialDatabase::count(self : MaterialDatabase) -> Int {
  self.materials.length()
}

///|
pub fn MaterialDatabase::all(self : MaterialDatabase) -> Array[OpticalMaterial] {
  self.materials.copy()
}
