///|
/// Thick Incoherent Substrate Back-Surface Optical Correction (Harbecke 1986 formulation)
pub struct IncoherentSubstrateCorrection {
  substrate_thickness_mm : Double
  substrate_absorption_coeff_cm1 : Double
  back_surface_roughness_factor : Double // 1.0 for specular polished, 0.0 for completely unpolished/diffuse
}

///|
pub fn IncoherentSubstrateCorrection::new(
  thickness_mm : Double,
  alpha_cm1 : Double,
  roughness : Double,
) -> IncoherentSubstrateCorrection {
  {
    substrate_thickness_mm: thickness_mm,
    substrate_absorption_coeff_cm1: alpha_cm1,
    back_surface_roughness_factor: roughness,
  }
}

///|
/// Correct Coherent Film-on-Substrate Reflectance R_film and Transmittance T_film for Incoherent Backside
/// R_total = R_f + (T_f^2 * R_b * tau^2) / (1 - R_b * R'_f * tau^2)
pub fn IncoherentSubstrateCorrection::calculate_total_reflectance(
  self : IncoherentSubstrateCorrection,
  r_front_coherent : Double,
  t_front_coherent : Double,
  r_back_interface : Double,
) -> Double {
  // Internal transmittance per pass: tau = exp(-alpha * d)
  let d_cm = self.substrate_thickness_mm * 0.1
  let tau = @math.exp(-self.substrate_absorption_coeff_cm1 * d_cm)
  let tau2 = tau * tau

  let r_b = r_back_interface * self.back_surface_roughness_factor
  let denom = 1.0 - r_b * r_front_coherent * tau2

  if denom <= 0.0 {
    r_front_coherent
  } else {
    r_front_coherent + t_front_coherent * t_front_coherent * r_b * tau2 / denom
  }
}

///|
/// Convolve High-Resolution Spectrum with Gaussian Spectrometer Instrument Response Function (IRF)
pub fn convolve_spectrometer_slit(
  spectrum : @core.SpectrumData,
  fwhm_nm : Double,
) -> @core.SpectrumData {
  let grid = spectrum.grid
  let count = grid.count()
  let sigma = fwhm_nm / 2.35482 // FWHM = 2 * sqrt(2 * ln 2) * sigma
  let two_sigma_sq = 2.0 * sigma * sigma

  let smoothed = Array::new(capacity=count)

  for i = 0; i < count; i = i + 1 {
    let wl_center = grid.get(i)
    let mut weighted_sum = 0.0
    let mut total_weight = 0.0

    for j = 0; j < count; j = j + 1 {
      let wl_j = grid.get(j)
      let d_wl = wl_j - wl_center
      if d_wl.abs() <= 3.5 * sigma {
        let weight = @math.exp(-(d_wl * d_wl) / two_sigma_sq)
        weighted_sum = weighted_sum + spectrum.get(j) * weight
        total_weight = total_weight + weight
      }
    }

    let val = if total_weight > 0.0 {
      weighted_sum / total_weight
    } else {
      spectrum.get(i)
    }
    smoothed.push(val)
  }

  @core.SpectrumData::new("Convolved_\{spectrum.name}", grid, smoothed)
}
