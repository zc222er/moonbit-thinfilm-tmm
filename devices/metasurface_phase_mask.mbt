///|
/// Dielectric Geometric Phase (Pancharatnam-Berry) Metasurface Engine
pub struct PBMetasurfaceMetalens {
  focal_length_um : Double // Focal length f
  design_wavelength_nm : Double // Target wavelength lambda_0
  nanofin_height_nm : Double // Height h (typically lambda / (2 * (n - 1)) for half-wave plate condition)
  nanofin_material : @mat.OpticalMaterial // E.g. TiO2 or GaN
}

///|
pub fn PBMetasurfaceMetalens::new(
  f_um : Double,
  lambda_nm : Double,
  h_nm : Double,
  mat : @mat.OpticalMaterial,
) -> PBMetasurfaceMetalens {
  {
    focal_length_um: f_um,
    design_wavelength_nm: lambda_nm,
    nanofin_height_nm: h_nm,
    nanofin_material: mat,
  }
}

///|
/// Metalens Hyperbolic Focusing Phase Profile: Phi(r) = - (2 * pi / lambda) * ( sqrt(r^2 + f^2) - f )
pub fn PBMetasurfaceMetalens::calculate_focusing_phase_rad(
  self : PBMetasurfaceMetalens,
  radial_position_um : Double,
) -> Double {
  let r = radial_position_um
  let f = self.focal_length_um
  let lambda_um = self.design_wavelength_nm * 1.0e-3

  let path_diff_um = (r * r + f * f).sqrt() - f
  let k0_um = 2.0 * @math.PI / lambda_um
  let phase_raw = -k0_um * path_diff_um

  // Modulo 2*pi phase wrapping into [0, 2*pi)
  let two_pi = 2.0 * @math.PI
  let phase_wrapped = phase_raw - @math.floor(phase_raw / two_pi) * two_pi
  phase_wrapped
}

///|
/// Required Nanofin In-Plane Rotation Angle theta(r) = 0.5 * Phi(r) (Geometric Phase)
pub fn PBMetasurfaceMetalens::calculate_nanofin_orientation_deg(
  self : PBMetasurfaceMetalens,
  radial_position_um : Double,
) -> Double {
  let phi_rad = self.calculate_focusing_phase_rad(radial_position_um)
  let theta_rad = 0.5 * phi_rad
  theta_rad * (180.0 / @math.PI)
}
