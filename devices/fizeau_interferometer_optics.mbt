///|
/// Fizeau Optical Surface Profilometry Interferometer Engine
pub struct FizeauInterferometer {
  source_wavelength_nm : Double // He-Ne 632.8 nm
  reference_flat_reflectance : Double // R_ref ~ 0.04 for uncoated optical flat
  tilt_x_fringes : Double
  tilt_y_fringes : Double
}

///|
pub fn FizeauInterferometer::new(
  wl_nm : Double,
  r_ref : Double,
  tx : Double,
  ty : Double,
) -> FizeauInterferometer {
  {
    source_wavelength_nm: wl_nm,
    reference_flat_reflectance: r_ref,
    tilt_x_fringes: tx,
    tilt_y_fringes: ty,
  }
}

///|
/// Two-Beam Interference Intensity Pattern: I(x, y) = I1 + I2 + 2*sqrt(I1*I2)*cos( (4*pi / lambda)*OPD(x,y) )
pub fn FizeauInterferometer::calculate_fringe_intensity(
  self : FizeauInterferometer,
  x_norm : Double, // -1.0 to 1.0
  y_norm : Double,
  surface_height_error_nm : Double,
) -> Double {
  let lambda = self.source_wavelength_nm
  let opd_nm = 2.0 * surface_height_error_nm +
    (self.tilt_x_fringes * x_norm + self.tilt_y_fringes * y_norm) *
    (lambda * 0.5)
  let phase = 4.0 * @math.PI * opd_nm / lambda

  let r1 = self.reference_flat_reflectance
  let r2 = 0.04 // Test surface reflection

  let i_avg = r1 + r2
  let i_mod = 2.0 * (r1 * r2).sqrt()

  i_avg + i_mod * @math.cos(phase)
}
