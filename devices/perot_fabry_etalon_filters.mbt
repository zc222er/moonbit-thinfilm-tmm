///|
/// Fabry-Pérot Etalon & High-Finesse Optical Resonator Engine
pub struct FabryPerotEtalon {
  cavity_length_um : Double // Etalon gap d in um
  cavity_refractive_index : Double // n = 1.0 for air, 1.45 for fused silica
  mirror_reflectance : Double // Mirror intensity reflectivity R (e.g. 0.95 - 0.99)
}

///|
pub fn FabryPerotEtalon::new(
  gap_um : Double,
  n_cavity : Double,
  r_mirror : Double,
) -> FabryPerotEtalon {
  {
    cavity_length_um: gap_um,
    cavity_refractive_index: n_cavity,
    mirror_reflectance: r_mirror,
  }
}

///|
/// Etalon Optical Performance Metrics
pub struct EtalonMetrics {
  finesse : Double // Finesse F = pi * sqrt(R) / (1 - R)
  free_spectral_range_nm : Double // FSR = lambda^2 / (2 * n * d)
  bandwidth_fwhm_nm : Double // Delta_lambda = FSR / F
  peak_transmission : Double
} derive(Eq)

///|
pub impl Show for EtalonMetrics with fn output(self, logger) {
  logger.write_string(
    "EtalonMetrics(Finesse=\{self.finesse}, FSR=\{self.free_spectral_range_nm} nm, FWHM=\{self.bandwidth_fwhm_nm} nm, T_peak=\{self.peak_transmission * 100.0}%)",
  )
}

///|
/// Calculate Fabry-Pérot Etalon Performance Metrics
pub fn FabryPerotEtalon::evaluate_etalon(
  self : FabryPerotEtalon,
  center_wavelength_nm : Double,
) -> EtalonMetrics {
  let r = self.mirror_reflectance
  let sqrt_r = r.sqrt()
  let finesse_val = @math.PI * sqrt_r / (1.0 - r)

  let d_nm = self.cavity_length_um * 1000.0
  let opt_length_nm = 2.0 * self.cavity_refractive_index * d_nm
  let fsr_nm = center_wavelength_nm * center_wavelength_nm / opt_length_nm
  let fwhm_nm = fsr_nm / finesse_val

  {
    finesse: finesse_val,
    free_spectral_range_nm: fsr_nm,
    bandwidth_fwhm_nm: fwhm_nm,
    peak_transmission: 1.0,
  }
}

///|
/// Calculate Airy Transmission Spectrum at Wavelength lambda
pub fn FabryPerotEtalon::calculate_transmission(
  self : FabryPerotEtalon,
  wavelength_nm : Double,
) -> Double {
  let d_nm = self.cavity_length_um * 1000.0
  let delta = 4.0 *
    @math.PI *
    self.cavity_refractive_index *
    d_nm /
    wavelength_nm
  let sin_half_delta = @math.sin(0.5 * delta)

  let r = self.mirror_reflectance
  let f_coeff = 4.0 * r / ((1.0 - r) * (1.0 - r))

  let denom = 1.0 + f_coeff * sin_half_delta * sin_half_delta
  if denom <= 0.0 {
    0.0
  } else {
    1.0 / denom
  }
}
