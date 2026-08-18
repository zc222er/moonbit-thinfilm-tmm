///|
/// Goos-Hänchen & Imbert-Fedorov Spatial Beam Shift Engine upon Total Internal Reflection (TIR)
pub struct GoosHanchenShiftResult {
  shift_te_nm : Double // Longitudinal spatial shift for TE polarization
  shift_tm_nm : Double // Longitudinal spatial shift for TM polarization
  ratio_tm_te : Double // S_TM / S_TE ~ (n1 / n2)^2
} derive(Eq)

///|
pub impl Show for GoosHanchenShiftResult with fn output(self, logger) {
  logger.write_string(
    "GoosHanchen(S_TE=\{self.shift_te_nm} nm, S_TM=\{self.shift_tm_nm} nm, TM/TE=\{self.ratio_tm_te})",
  )
}

///|
/// Calculate Artmann Analytical Goos-Hänchen Shift at Total Internal Reflection Interface
/// S_TE = (lambda / pi) * tan(theta) / sqrt( n1^2 * sin^2(theta) - n2^2 )
/// S_TM = S_TE * ( (n1 / n2)^2 / ( (n1/n2)^2 * sin^2(theta) - cos^2(theta) ) )
pub fn calculate_goos_hanchen_shift(
  n_dense : Double, // n1
  n_rare : Double, // n2 < n1
  incident_angle_deg : Double,
  wavelength_nm : Double,
) -> GoosHanchenShiftResult {
  let theta_rad = incident_angle_deg * @math.PI / 180.0
  let sin_theta = @math.sin(theta_rad)
  let cos_theta = @math.cos(theta_rad)
  let tan_theta = @math.tan(theta_rad)

  let arg_sq = n_dense * n_dense * sin_theta * sin_theta - n_rare * n_rare
  if arg_sq <= 0.0 {
    // Below critical angle (no total internal reflection)
    return { shift_te_nm: 0.0, shift_tm_nm: 0.0, ratio_tm_te: 1.0 }
  }

  let denom_sq = arg_sq.sqrt()
  let s_te = wavelength_nm / @math.PI * (tan_theta / denom_sq)

  let n_ratio = n_dense / n_rare
  let n_ratio_sq = n_ratio * n_ratio
  let tm_factor = n_ratio_sq /
    (n_ratio_sq * sin_theta * sin_theta - cos_theta * cos_theta)
  let s_tm = s_te * tm_factor.abs()

  {
    shift_te_nm: s_te,
    shift_tm_nm: s_tm,
    ratio_tm_te: if s_te > 0.0 {
      s_tm / s_te
    } else {
      1.0
    },
  }
}
