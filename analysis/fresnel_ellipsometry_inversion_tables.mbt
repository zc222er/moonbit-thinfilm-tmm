///|
/// Pseudo-Dielectric Function <eps> Analytical Inversion from Measured Ellipsometric (Psi, Delta)
pub struct PseudoDielectricFunction {
  wavelength_nm : Double
  incident_angle_deg : Double
  eps_1_real : Double
  eps_2_imag : Double
  pseudo_n : Double
  pseudo_k : Double
} derive(Eq)

///|
pub impl Show for PseudoDielectricFunction with fn output(self, logger) {
  logger.write_string(
    "PseudoEps(@\{self.wavelength_nm}nm: <eps>=\{self.eps_1_real} + \{self.eps_2_imag}i, <n>=\{self.pseudo_n}, <k>=\{self.pseudo_k})",
  )
}

///|
/// Compute Pseudo-Dielectric Function <eps> = sin^2(phi) * [ 1 + tan^2(phi) * ((1 - rho) / (1 + rho))^2 ]
pub fn calculate_pseudo_dielectric_function(
  psi_deg : Double,
  delta_deg : Double,
  incident_angle_deg : Double,
  wavelength_nm : Double,
) -> PseudoDielectricFunction {
  let phi_rad = incident_angle_deg * @math.PI / 180.0
  let psi_rad = psi_deg * @math.PI / 180.0
  let delta_rad = delta_deg * @math.PI / 180.0

  let sin_phi = @math.sin(phi_rad)
  let tan_phi = @math.tan(phi_rad)

  // Complex reflectance ratio rho = tan(Psi) * exp(i * Delta)
  let tan_psi = @math.tan(psi_rad)
  let rho = @core.Complex::new(
    tan_psi * @math.cos(delta_rad),
    tan_psi * @math.sin(delta_rad),
  )

  // (1 - rho) / (1 + rho)
  let one = @core.Complex::one()
  let num = one.sub(rho)
  let denom = one.add(rho)
  let frac = num.div(denom)
  let frac_sq = frac.mul(frac)

  // <eps> = sin^2(phi) * (1 + tan^2(phi) * frac_sq)
  let bracket = one.add(frac_sq.mul_real(tan_phi * tan_phi))
  let eps_pseudo = bracket.mul_real(sin_phi * sin_phi)

  let n_pseudo_c = eps_pseudo.sqrt()

  {
    wavelength_nm,
    incident_angle_deg,
    eps_1_real: eps_pseudo.re,
    eps_2_imag: eps_pseudo.im,
    pseudo_n: n_pseudo_c.re,
    pseudo_k: n_pseudo_c.im,
  }
}
