///|
/// Second Harmonic Generation (SHG) & Phase Matching Angle Engine
pub struct NonLinearPhaseMatching {
  fundamental_wavelength_nm : Double // E.g. 1064 nm (Nd:YAG)
  harmonic_wavelength_nm : Double // E.g. 532 nm (Green)
  no_fundamental : Double
  ne_fundamental : Double
  no_harmonic : Double
  ne_harmonic : Double
}

///|
pub fn NonLinearPhaseMatching::new(
  wl_fund : Double,
  no_f : Double,
  ne_f : Double,
  no_h : Double,
  ne_h : Double,
) -> NonLinearPhaseMatching {
  {
    fundamental_wavelength_nm: wl_fund,
    harmonic_wavelength_nm: wl_fund / 2.0,
    no_fundamental: no_f,
    ne_fundamental: ne_f,
    no_harmonic: no_h,
    ne_harmonic: ne_h,
  }
}

///|
/// Type-I Negative Uniaxial Phase Matching Angle theta_pm:
/// n_e(2omega, theta_pm) = n_o(omega)
/// 1 / n_o(omega)^2 = cos^2(theta) / n_o(2omega)^2 + sin^2(theta) / n_e(2omega)^2
pub fn NonLinearPhaseMatching::calculate_type1_phase_matching_angle_deg(
  self : NonLinearPhaseMatching,
) -> Double {
  let no_w = self.no_fundamental
  let no_2w = self.no_harmonic
  let ne_2w = self.ne_harmonic

  let inv_no_w_sq = 1.0 / (no_w * no_w)
  let inv_no_2w_sq = 1.0 / (no_2w * no_2w)
  let inv_ne_2w_sq = 1.0 / (ne_2w * ne_2w)

  let num = inv_no_w_sq - inv_no_2w_sq
  let denom = inv_ne_2w_sq - inv_no_2w_sq

  if denom.abs() < 1.0e-8 {
    0.0
  } else {
    let sin2_theta = num / denom
    if sin2_theta < 0.0 {
      0.0
    } else if sin2_theta > 1.0 {
      90.0
    } else {
      let sin_t = sin2_theta.sqrt()
      @math.asin(sin_t) * (180.0 / @math.PI)
    }
  }
}
