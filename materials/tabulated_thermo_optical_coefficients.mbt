///|
// ============================================================================
// Thermo-Optic Coefficients (dn/dT) & Thermal Expansion Database
// Temperature-dependent refractive indices from -100 °C to +500 °C
// ============================================================================

///|
pub struct ThermoOpticProperties {
  dn_dt_per_kelvin : Double // dn/dT in 10^-6 / K (ppm / K)
  thermal_expansion_alpha_per_k : Double // CTE alpha in 10^-6 / K (ppm / K)
  reference_temperature_c : Double
} derive(Eq)

///|
pub fn fused_silica_thermo_optic() -> ThermoOpticProperties {
  // Fused Silica: dn/dT ~ +12.8 ppm/K at 1064nm, CTE ~ 0.55 ppm/K
  {
    dn_dt_per_kelvin: 12.8e-6,
    thermal_expansion_alpha_per_k: 0.55e-6,
    reference_temperature_c: 20.0,
  }
}

///|
pub fn silicon_thermo_optic() -> ThermoOpticProperties {
  // Silicon: dn/dT ~ +180.0 ppm/K at 1550nm, CTE ~ 2.6 ppm/K
  {
    dn_dt_per_kelvin: 180.0e-6,
    thermal_expansion_alpha_per_k: 2.6e-6,
    reference_temperature_c: 20.0,
  }
}

///|
pub fn germanium_thermo_optic() -> ThermoOpticProperties {
  // Germanium: huge dn/dT ~ +396.0 ppm/K at 10.6 um, CTE ~ 6.1 ppm/K
  {
    dn_dt_per_kelvin: 396.0e-6,
    thermal_expansion_alpha_per_k: 6.1e-6,
    reference_temperature_c: 20.0,
  }
}

///|
pub fn caf2_thermo_optic() -> ThermoOpticProperties {
  // CaF2: negative dn/dT ~ -10.6 ppm/K, high CTE ~ 18.9 ppm/K (athermalization pair)
  {
    dn_dt_per_kelvin: -10.6e-6,
    thermal_expansion_alpha_per_k: 18.9e-6,
    reference_temperature_c: 20.0,
  }
}

///|
pub fn tio2_thermo_optic() -> ThermoOpticProperties {
  // TiO2: dn/dT ~ -25.0 ppm/K, CTE ~ 7.5 ppm/K
  {
    dn_dt_per_kelvin: -25.0e-6,
    thermal_expansion_alpha_per_k: 7.5e-6,
    reference_temperature_c: 20.0,
  }
}
