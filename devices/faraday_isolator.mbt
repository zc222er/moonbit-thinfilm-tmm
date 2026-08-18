///|
/// Optical Faraday Isolator & Non-Reciprocal Polarizer Engine
pub struct FaradayIsolator {
  operating_wavelength_nm : Double
  crystal_length_mm : Double // L
  applied_magnetic_field_tesla : Double // B
  rotator_material : @mat.OpticalMaterial
}

///|
pub fn FaradayIsolator::new(
  wavelength_nm : Double,
  length_mm : Double,
  field_tesla : Double,
  mat : @mat.OpticalMaterial,
) -> FaradayIsolator {
  {
    operating_wavelength_nm: wavelength_nm,
    crystal_length_mm: length_mm,
    applied_magnetic_field_tesla: field_tesla,
    rotator_material: mat,
  }
}

///|
/// Faraday Rotation Angle: theta_F = V(lambda) * B * L
pub fn FaradayIsolator::calculate_rotation_angle_deg(
  self : FaradayIsolator,
) -> Double {
  let v_rad = @mat.tgg_verdet_constant(self.operating_wavelength_nm)
  let l_m = self.crystal_length_mm * 1.0e-3
  let theta_rad = v_rad * self.applied_magnetic_field_tesla * l_m
  theta_rad * (180.0 / @math.PI)
}

///|
/// Optical Isolation Ratio in dB: Isolation = -10 * log10( sin^2(theta - 45 deg) + 10^(-ER/10) )
pub fn FaradayIsolator::calculate_isolation_db(
  self : FaradayIsolator,
  polarizer_extinction_ratio_db : Double,
) -> Double {
  let theta_deg = self.calculate_rotation_angle_deg().abs()
  let d_theta_rad = (theta_deg - 45.0) * @math.PI / 180.0
  let sin2_err = @math.sin(d_theta_rad) * @math.sin(d_theta_rad)

  let pol_leak = @math.pow(10.0, -polarizer_extinction_ratio_db / 10.0)
  let total_leak = sin2_err + pol_leak

  if total_leak <= 0.0 {
    60.0
  } else {
    -10.0 * @math.ln(total_leak) / @math.ln(10.0)
  }
}
