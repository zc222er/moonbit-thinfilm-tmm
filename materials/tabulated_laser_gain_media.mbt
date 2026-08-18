///|
// ============================================================================
// Solid-State Laser Gain Media Database (Nd:YAG, Yb:YAG, Ti:Sapphire, Er:YAG)
// Optical cross sections and upper state fluorescence lifetimes
// ============================================================================

///|
pub(all) struct LaserGainProperties {
  emission_cross_section_cm2 : Double // sigma_e
  absorption_cross_section_pump_cm2 : Double // sigma_a at pump wavelength
  fluorescence_lifetime_us : Double // tau_f in microseconds
  laser_wavelength_nm : Double
  pump_wavelength_nm : Double
} derive(Eq)

///|
pub fn nd_yag_laser_gain() -> LaserGainProperties {
  // Nd:YAG 1064 nm transition pumped at 808 nm diode
  {
    emission_cross_section_cm2: 2.8e-19,
    absorption_cross_section_pump_cm2: 4.1e-19,
    fluorescence_lifetime_us: 230.0,
    laser_wavelength_nm: 1064.0,
    pump_wavelength_nm: 808.0,
  }
}

///|
pub fn yb_yag_laser_gain() -> LaserGainProperties {
  // Yb:YAG 1030 nm quasi-three-level laser pumped at 940 nm
  {
    emission_cross_section_cm2: 2.3e-20,
    absorption_cross_section_pump_cm2: 7.7e-21,
    fluorescence_lifetime_us: 950.0,
    laser_wavelength_nm: 1030.0,
    pump_wavelength_nm: 940.0,
  }
}

///|
pub fn ti_sapphire_laser_gain() -> LaserGainProperties {
  // Ti:Sapphire broad tunable ultrafast laser (680 - 1100 nm) pumped at 532 nm
  {
    emission_cross_section_cm2: 4.1e-19,
    absorption_cross_section_pump_cm2: 6.5e-20,
    fluorescence_lifetime_us: 3.2,
    laser_wavelength_nm: 800.0,
    pump_wavelength_nm: 532.0,
  }
}

///|
pub fn er_yag_mid_ir_laser_gain() -> LaserGainProperties {
  // Er:YAG 2940 nm mid-IR medical & dental laser pumped at 976 nm
  {
    emission_cross_section_cm2: 3.0e-20,
    absorption_cross_section_pump_cm2: 5.0e-21,
    fluorescence_lifetime_us: 100.0,
    laser_wavelength_nm: 2940.0,
    pump_wavelength_nm: 976.0,
  }
}
