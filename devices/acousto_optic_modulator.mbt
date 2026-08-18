///|
/// Acousto-Optic Modulator (AOM) & Tunable Filter (AOTF) Bragg Diffraction Engine
pub struct AcoustoOpticModulator {
  crystal_properties : @mat.AcoustoOpticProperties
  acoustic_transducer_length_mm : Double // L
  acoustic_transducer_height_mm : Double // H
  rf_frequency_mhz : Double // Frequency f_a
}

///|
pub fn AcoustoOpticModulator::new(
  props : @mat.AcoustoOpticProperties,
  length_mm : Double,
  height_mm : Double,
  f_mhz : Double,
) -> AcoustoOpticModulator {
  {
    crystal_properties: props,
    acoustic_transducer_length_mm: length_mm,
    acoustic_transducer_height_mm: height_mm,
    rf_frequency_mhz: f_mhz,
  }
}

///|
/// Bragg Diffraction Angle in degrees: theta_B = asin( lambda * f_a / (2 * v_a * n) )
pub fn AcoustoOpticModulator::calculate_bragg_angle_deg(
  self : AcoustoOpticModulator,
  optical_wavelength_nm : Double,
) -> Double {
  let lambda_m = optical_wavelength_nm * 1.0e-9
  let f_hz = self.rf_frequency_mhz * 1.0e6
  let v_a = self.crystal_properties.acoustic_velocity_m_s
  let n = self.crystal_properties.center_index

  let sin_theta = lambda_m * f_hz / (2.0 * v_a * n)
  let sin_clamped = if sin_theta < -1.0 {
    -1.0
  } else if sin_theta > 1.0 {
    1.0
  } else {
    sin_theta
  }
  let theta_rad = @math.asin(sin_clamped)
  theta_rad * (180.0 / @math.PI)
}

///|
/// First-Order Bragg Diffraction Efficiency: eta = sin^2( (pi / (lambda * cos(theta_B))) * sqrt( (M2 * P_a * L) / (2 * H) ) )
pub fn AcoustoOpticModulator::calculate_diffraction_efficiency(
  self : AcoustoOpticModulator,
  optical_wavelength_nm : Double,
  acoustic_rf_power_w : Double,
) -> Double {
  let lambda_m = optical_wavelength_nm * 1.0e-9
  let m2_si = self.crystal_properties.figure_of_merit_m2_10_15_s3_kg * 1.0e-15
  let l_m = self.acoustic_transducer_length_mm * 1.0e-3
  let h_m = self.acoustic_transducer_height_mm * 1.0e-3

  let inside_sqrt = m2_si * acoustic_rf_power_w * l_m / (2.0 * h_m)
  let sqrt_val = if inside_sqrt > 0.0 { inside_sqrt.sqrt() } else { 0.0 }

  let theta_rad = self.calculate_bragg_angle_deg(optical_wavelength_nm) *
    @math.PI /
    180.0
  let cos_theta = @math.cos(theta_rad)

  let arg = @math.PI / (lambda_m * cos_theta) * sqrt_val
  let sin_val = @math.sin(arg)
  sin_val * sin_val
}
