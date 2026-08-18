///|
/// Pancharatnam 3-Element Achromatic Retarder Waveplate Engine
pub struct PancharatnamAchromaticWaveplate {
  design_center_wavelength_nm : Double // 550 nm
  plate_1_retardance_deg : Double // delta_1 (e.g. 180 deg)
  plate_1_azimuth_deg : Double // theta_1 (e.g. 0 deg)
  plate_2_retardance_deg : Double // delta_2 (e.g. 180 deg)
  plate_2_azimuth_deg : Double // theta_2 (e.g. 60 deg)
  plate_3_retardance_deg : Double // delta_3 (e.g. 180 deg)
  plate_3_azimuth_deg : Double // theta_3 (e.g. 0 deg)
}

///|
pub fn PancharatnamAchromaticWaveplate::achromatic_half_wave_plate() -> PancharatnamAchromaticWaveplate {
  // Classic Pancharatnam AHWP: (180°@0°, 180°@60°, 180°@0°) -> achromatic 180° retardance
  {
    design_center_wavelength_nm: 550.0,
    plate_1_retardance_deg: 180.0,
    plate_1_azimuth_deg: 0.0,
    plate_2_retardance_deg: 180.0,
    plate_2_azimuth_deg: 60.0,
    plate_3_retardance_deg: 180.0,
    plate_3_azimuth_deg: 0.0,
  }
}

///|
pub fn PancharatnamAchromaticWaveplate::achromatic_quarter_wave_plate() -> PancharatnamAchromaticWaveplate {
  // Pancharatnam AQWP: (180°@115°, 180°@29°, 180°@115°)
  {
    design_center_wavelength_nm: 550.0,
    plate_1_retardance_deg: 180.0,
    plate_1_azimuth_deg: 115.0,
    plate_2_retardance_deg: 180.0,
    plate_2_azimuth_deg: 29.0,
    plate_3_retardance_deg: 180.0,
    plate_3_azimuth_deg: 115.0,
  }
}

///|
/// Calculate Net Effective Retardance Delta_eff(lambda) in degrees across broad spectrum
pub fn PancharatnamAchromaticWaveplate::calculate_effective_retardance_deg(
  self : PancharatnamAchromaticWaveplate,
  wavelength_nm : Double,
) -> Double {
  let scale = self.design_center_wavelength_nm / wavelength_nm
  let d1_rad = self.plate_1_retardance_deg * scale * @math.PI / 180.0
  let d2_rad = self.plate_2_retardance_deg * scale * @math.PI / 180.0
  let d3_rad = self.plate_3_retardance_deg * scale * @math.PI / 180.0

  let t1_rad = self.plate_1_azimuth_deg * @math.PI / 180.0
  let t2_rad = self.plate_2_azimuth_deg * @math.PI / 180.0
  let t3_rad = self.plate_3_azimuth_deg * @math.PI / 180.0

  // Pancharatnam composition of 3 linear retarders
  let cos_half_r = @math.cos(0.5 * d1_rad) *
    @math.cos(0.5 * d2_rad) *
    @math.cos(0.5 * d3_rad) -
    @math.sin(0.5 * d1_rad) *
    @math.sin(0.5 * d2_rad) *
    @math.cos(0.5 * d3_rad) *
    @math.cos(2.0 * (t1_rad - t2_rad)) -
    @math.cos(0.5 * d1_rad) *
    @math.sin(0.5 * d2_rad) *
    @math.sin(0.5 * d3_rad) *
    @math.cos(2.0 * (t2_rad - t3_rad)) -
    @math.sin(0.5 * d1_rad) *
    @math.cos(0.5 * d2_rad) *
    @math.sin(0.5 * d3_rad) *
    @math.cos(2.0 * (t1_rad - t3_rad))

  let cos_clamped = if cos_half_r < -1.0 {
    -1.0
  } else if cos_half_r > 1.0 {
    1.0
  } else {
    cos_half_r
  }
  let half_r_rad = @math.acos(cos_clamped)
  let r_deg = 2.0 * half_r_rad * (180.0 / @math.PI)
  r_deg
}
