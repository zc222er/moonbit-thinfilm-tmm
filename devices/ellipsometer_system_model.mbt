///|
/// Spectroscopic Ellipsometer Instrument Hardware Simulation (Rotating Polarizer & Compensator)
pub struct RotatingPolarizerEllipsometer {
  analyzer_azimuth_deg : Double // Fixed analyzer angle A (typically 45 deg)
  polarizer_frequency_hz : Double // Motor rotation frequency omega_0 (e.g. 50 Hz)
}

///|
pub fn RotatingPolarizerEllipsometer::new(
  analyzer_deg : Double,
  freq_hz : Double,
) -> RotatingPolarizerEllipsometer {
  { analyzer_azimuth_deg: analyzer_deg, polarizer_frequency_hz: freq_hz }
}

///|
/// Fourier Harmonic Coefficients (alpha, beta) from Detected Intensity: I(t) = I_0 * [ 1 + alpha * cos(2 omega t) + beta * sin(2 omega t) ]
pub struct EllipsometerHarmonics {
  alpha_2omega : Double // alpha = (tan^2(Psi) - tan^2(A)) / (tan^2(Psi) + tan^2(A))
  beta_2omega : Double // beta = (2 tan(Psi) cos(Delta) tan(A)) / (tan^2(Psi) + tan^2(A))
  psi_reconstructed_deg : Double
  delta_reconstructed_deg : Double
} derive(Eq)

///|
pub impl Show for EllipsometerHarmonics with fn output(self, logger) {
  logger.write_string(
    "EllipsometerHarmonics(alpha=\{self.alpha_2omega}, beta=\{self.beta_2omega}, Psi=\{self.psi_reconstructed_deg}°, Delta=\{self.delta_reconstructed_deg}°)",
  )
}

///|
/// Simulate Fourier Harmonics for Given Sample (Psi, Delta)
pub fn RotatingPolarizerEllipsometer::simulate_harmonics(
  self : RotatingPolarizerEllipsometer,
  sample_psi_deg : Double,
  sample_delta_deg : Double,
) -> EllipsometerHarmonics {
  let a_rad = self.analyzer_azimuth_deg * @math.PI / 180.0
  let psi_rad = sample_psi_deg * @math.PI / 180.0
  let delta_rad = sample_delta_deg * @math.PI / 180.0

  let tan_a = @math.tan(a_rad)
  let tan_psi = @math.tan(psi_rad)

  let tan2_a = tan_a * tan_a
  let tan2_psi = tan_psi * tan_psi

  let denom = tan2_psi + tan2_a
  let alpha = (tan2_psi - tan2_a) / denom
  let beta = 2.0 * tan_psi * @math.cos(delta_rad) * tan_a / denom

  // Reconstruct Psi and Delta from (alpha, beta)
  let tan_psi_recon = ((1.0 + alpha) / (1.0 - alpha)).sqrt() * tan_a
  let psi_recon_rad = @math.atan(tan_psi_recon)

  let cos_delta_recon = beta / (1.0 - alpha * alpha).sqrt()
  let cos_delta_clamped = if cos_delta_recon < -1.0 {
    -1.0
  } else if cos_delta_recon > 1.0 {
    1.0
  } else {
    cos_delta_recon
  }
  let delta_recon_rad = @math.acos(cos_delta_clamped)

  {
    alpha_2omega: alpha,
    beta_2omega: beta,
    psi_reconstructed_deg: psi_recon_rad * (180.0 / @math.PI),
    delta_reconstructed_deg: delta_recon_rad * (180.0 / @math.PI),
  }
}
