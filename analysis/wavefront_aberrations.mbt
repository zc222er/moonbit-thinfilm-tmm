///|
/// Multilayer Reflection Wavefront Deformation & Aberration Analyzer
pub struct WavefrontMetrics {
  peak_to_valley_opd_nm : Double // Peak-to-Valley (PV) OPD in nm
  rms_opd_nm : Double // Root Mean Square (RMS) OPD in nm
  strehl_ratio : Double // Strehl ratio S ~ exp(-(2 * pi * RMS / lambda)^2)
  phase_variance_rad2 : Double
} derive(Eq)

///|
pub impl Show for WavefrontMetrics with fn output(self, logger) {
  logger.write_string(
    "Wavefront(PV=\{self.peak_to_valley_opd_nm} nm, RMS=\{self.rms_opd_nm} nm, Strehl=\{self.strehl_ratio})",
  )
}

///|
/// Calculate Wavefront Aberration Metrics across Incident Angles
pub fn calculate_angular_wavefront_aberration(
  phase_shift_deg_arr : Array[Double],
  wavelength_nm : Double,
) -> WavefrontMetrics {
  let count = phase_shift_deg_arr.length()
  if count == 0 {
    return {
      peak_to_valley_opd_nm: 0.0,
      rms_opd_nm: 0.0,
      strehl_ratio: 1.0,
      phase_variance_rad2: 0.0,
    }
  }

  // Convert phase in degrees to OPD in nm: OPD = (phi / 360) * lambda
  let opd_arr = Array::new(capacity=count)
  let mut min_opd = phase_shift_deg_arr[0] / 360.0 * wavelength_nm
  let mut max_opd = min_opd
  let mut sum_opd = 0.0

  for phi in phase_shift_deg_arr {
    let opd = phi / 360.0 * wavelength_nm
    opd_arr.push(opd)
    sum_opd = sum_opd + opd
    if opd < min_opd {
      min_opd = opd
    }
    if opd > max_opd {
      max_opd = opd
    }
  }

  let mean_opd = sum_opd / count.to_double()
  let mut sum_sq_diff = 0.0
  for opd in opd_arr {
    let diff = opd - mean_opd
    sum_sq_diff = sum_sq_diff + diff * diff
  }

  let rms_opd = (sum_sq_diff / count.to_double()).sqrt()
  let pv_opd = max_opd - min_opd

  // Strehl Ratio: S = exp( - (2 * pi * RMS / lambda)^2 )
  let phi_rms_rad = 2.0 * @math.PI * rms_opd / wavelength_nm
  let var_rad2 = phi_rms_rad * phi_rms_rad
  let strehl = @math.exp(-var_rad2)

  {
    peak_to_valley_opd_nm: pv_opd,
    rms_opd_nm: rms_opd,
    strehl_ratio: strehl,
    phase_variance_rad2: var_rad2,
  }
}
