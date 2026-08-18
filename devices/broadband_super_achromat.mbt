///|
/// 5-Element Ultra-Broadband Super-Achromat Retarder & Multi-Cavity Bandpass Engine
pub struct SuperAchromatDesign {
  center_wavelength_nm : Double
  target_retardance_deg : Double
  plates_azimuths : Array[Double]
  plates_retardances : Array[Double]
}

///|
pub fn SuperAchromatDesign::standard_five_element_quarter_wave() -> SuperAchromatDesign {
  // Title-Tuchin 5-element super-achromatic QWP (Broadband 350 - 1100 nm)
  {
    center_wavelength_nm: 600.0,
    target_retardance_deg: 90.0,
    plates_azimuths: [15.0, 75.0, 15.0, 75.0, 15.0],
    plates_retardances: [180.0, 180.0, 180.0, 180.0, 90.0],
  }
}

///|
/// Multi-Cavity Bandpass Filter Design (e.g. 3-Cavity Fabry-Perot Flat-Top Bandpass)
pub struct MultiCavityBandpassDesign {
  center_wavelength_nm : Double
  fwhm_bandwidth_nm : Double
  num_cavities : Int
  spacer_order_m : Int
}

///|
pub fn MultiCavityBandpassDesign::telecom_dense_wdm_100ghz() -> MultiCavityBandpassDesign {
  // 100 GHz DWDM Bandpass filter (FWHM ~ 0.8 nm at 1550 nm)
  {
    center_wavelength_nm: 1550.0,
    fwhm_bandwidth_nm: 0.80,
    num_cavities: 3,
    spacer_order_m: 4,
  }
}

///|
/// Calculate Transmittance Shape Factor (ratio of -0.5dB bandwidth to -25dB bandwidth)
pub fn MultiCavityBandpassDesign::calculate_shape_factor(
  self : MultiCavityBandpassDesign,
) -> Double {
  // Shape factor improves with cavity count N: SF ~ (N / (N + 1))^0.8
  let n = self.num_cavities.to_double()
  @math.pow(n / (n + 1.0), 0.8)
}
