///|
/// OLED Microcavity Optical Parameters
pub struct OLEDMicrocavity {
  bottom_mirror_stack : @core.MultiLayerStack // E.g. Ag anode or DBR
  htl_thickness_nm : Double
  eml_thickness_nm : Double
  etl_thickness_nm : Double
  top_cathode_transmittance : Double
  emission_wavelength_nm : Double
}

///|
pub fn OLEDMicrocavity::new(
  bottom_mirror : @core.MultiLayerStack,
  htl_nm : Double,
  eml_nm : Double,
  etl_nm : Double,
  top_cathode_t : Double,
  emission_wl : Double,
) -> OLEDMicrocavity {
  {
    bottom_mirror_stack: bottom_mirror,
    htl_thickness_nm: htl_nm,
    eml_thickness_nm: eml_nm,
    etl_thickness_nm: etl_nm,
    top_cathode_transmittance: top_cathode_t,
    emission_wavelength_nm: emission_wl,
  }
}

///|
/// Calculate Cavity Purcell factor enhancement: F_p = 1 + 1.5 * Im(r_bottom * r_top * exp(2 i phi)) / (1 - |r_b r_t|^2)
pub fn OLEDMicrocavity::estimate_purcell_factor(
  self : OLEDMicrocavity,
  r_bottom : Double,
  r_top : Double,
  cavity_length_nm : Double,
) -> Double {
  let n_org = 1.75
  let phi = 2.0 *
    @math.PI *
    n_org *
    cavity_length_nm /
    self.emission_wavelength_nm
  let r_eff = (r_bottom * r_top).sqrt()
  let denom = 1.0 + r_eff * r_eff - 2.0 * r_eff * @math.cos(2.0 * phi)
  if denom <= 0.0 {
    1.0
  } else {
    (1.0 - r_eff * r_eff) / denom
  }
}
