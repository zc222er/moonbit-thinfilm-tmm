///|
/// Ultrafast Femtosecond Laser Pulse Broadening & Dispersion Propagation
pub struct UltrafastPulseProfile {
  initial_duration_fwhm_fs : Double // tau_0 (e.g. 20 fs transform-limited)
  center_wavelength_nm : Double
}

///|
pub fn UltrafastPulseProfile::new(
  tau0_fs : Double,
  center_wl : Double,
) -> UltrafastPulseProfile {
  { initial_duration_fwhm_fs: tau0_fs, center_wavelength_nm: center_wl }
}

///|
/// Pulse Propagation Result after reflection from dispersive multilayer stack
pub struct PulseBroadeningResult {
  output_duration_fwhm_fs : Double // tau_out
  broadening_ratio : Double // tau_out / tau_0
  accumulated_chirp_parameter : Double // Linear chirp parameter C
  peak_intensity_ratio : Double // I_out / I_in ~ tau_0 / tau_out
} derive(Eq)

///|
pub impl Show for PulseBroadeningResult with fn output(self, logger) {
  logger.write_string(
    "PulseBroadening(tau_in=\{self.output_duration_fwhm_fs / self.broadening_ratio} fs -> tau_out=\{self.output_duration_fwhm_fs} fs, Peak_Drop=\{self.peak_intensity_ratio * 100.0}%)",
  )
}

///|
/// Calculate Pulse Broadening from Group Delay Dispersion (GDD in fs^2):
/// tau_out = tau_0 * sqrt( 1 + (4 * ln(2) * GDD / tau_0^2)^2 )
pub fn UltrafastPulseProfile::calculate_broadening(
  self : UltrafastPulseProfile,
  gdd_fs2 : Double,
) -> PulseBroadeningResult {
  let tau0 = self.initial_duration_fwhm_fs
  let four_ln2 = 4.0 * @math.ln(2.0)
  let factor = four_ln2 * gdd_fs2 / (tau0 * tau0)
  let broadening = (1.0 + factor * factor).sqrt()
  let tau_out = tau0 * broadening
  let peak_ratio = if broadening > 0.0 { 1.0 / broadening } else { 1.0 }

  {
    output_duration_fwhm_fs: tau_out,
    broadening_ratio: broadening,
    accumulated_chirp_parameter: factor,
    peak_intensity_ratio: peak_ratio,
  }
}
