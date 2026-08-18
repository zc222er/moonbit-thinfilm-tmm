///|
/// Zernike Circular Polynomials for Wavefront Aberration Expansion (Noll Indexing)
pub(all) struct ZernikeAberrationCoefficients {
  mut piston_c0 : Double // Z_0 = 1
  mut tilt_x_c1 : Double // Z_1 = 2 * r * cos(theta)
  mut tilt_y_c2 : Double // Z_2 = 2 * r * sin(theta)
  mut defocus_c3 : Double // Z_3 = sqrt(3) * (2*r^2 - 1)
  mut astigmatism_0_c4 : Double // Z_4 = sqrt(6) * r^2 * sin(2*theta)
  mut astigmatism_45_c5 : Double // Z_5 = sqrt(6) * r^2 * cos(2*theta)
  mut coma_x_c6 : Double // Z_6 = sqrt(8) * (3*r^3 - 2*r) * sin(theta)
  mut coma_y_c7 : Double // Z_7 = sqrt(8) * (3*r^3 - 2*r) * cos(theta)
  mut spherical_c8 : Double // Z_8 = sqrt(5) * (6*r^4 - 6*r^2 + 1)
} derive(Eq)

///|
pub fn ZernikeAberrationCoefficients::zeros() -> ZernikeAberrationCoefficients {
  {
    piston_c0: 0.0,
    tilt_x_c1: 0.0,
    tilt_y_c2: 0.0,
    defocus_c3: 0.0,
    astigmatism_0_c4: 0.0,
    astigmatism_45_c5: 0.0,
    coma_x_c6: 0.0,
    coma_y_c7: 0.0,
    spherical_c8: 0.0,
  }
}

///|
/// Evaluate Wavefront Optical Path Difference OPD(r, theta) in nm
pub fn ZernikeAberrationCoefficients::evaluate_opd(
  self : ZernikeAberrationCoefficients,
  r_norm : Double, // Normalized radius 0.0 to 1.0
  theta_rad : Double,
) -> Double {
  let r = if r_norm > 1.0 { 1.0 } else { r_norm }
  let r2 = r * r
  let r3 = r2 * r
  let r4 = r2 * r2

  let z0 = 1.0
  let z1 = 2.0 * r * @math.cos(theta_rad)
  let z2 = 2.0 * r * @math.sin(theta_rad)
  let z3 = 1.7320508 * (2.0 * r2 - 1.0)
  let z4 = 2.4494897 * r2 * @math.sin(2.0 * theta_rad)
  let z5 = 2.4494897 * r2 * @math.cos(2.0 * theta_rad)
  let z6 = 2.8284271 * (3.0 * r3 - 2.0 * r) * @math.sin(theta_rad)
  let z7 = 2.8284271 * (3.0 * r3 - 2.0 * r) * @math.cos(theta_rad)
  let z8 = 2.2360679 * (6.0 * r4 - 6.0 * r2 + 1.0)

  self.piston_c0 * z0 +
  self.tilt_x_c1 * z1 +
  self.tilt_y_c2 * z2 +
  self.defocus_c3 * z3 +
  self.astigmatism_0_c4 * z4 +
  self.astigmatism_45_c5 * z5 +
  self.coma_x_c6 * z6 +
  self.coma_y_c7 * z7 +
  self.spherical_c8 * z8
}

///|
/// Total Root-Mean-Square (RMS) Wavefront Error: sigma_w = sqrt( sum_{i=1..8} c_i^2 )
pub fn ZernikeAberrationCoefficients::calculate_rms_error_nm(
  self : ZernikeAberrationCoefficients,
) -> Double {
  let sum_sq = self.tilt_x_c1 * self.tilt_x_c1 +
    self.tilt_y_c2 * self.tilt_y_c2 +
    self.defocus_c3 * self.defocus_c3 +
    self.astigmatism_0_c4 * self.astigmatism_0_c4 +
    self.astigmatism_45_c5 * self.astigmatism_45_c5 +
    self.coma_x_c6 * self.coma_x_c6 +
    self.coma_y_c7 * self.coma_y_c7 +
    self.spherical_c8 * self.spherical_c8
  sum_sq.sqrt()
}
