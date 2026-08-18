///|
/// Integrated Photonics Optical Modulator & Micro-Ring Resonator Engine
pub struct OpticalRingResonator {
  ring_radius_um : Double
  waveguide_effective_index : Double
  power_coupling_coefficient_k2 : Double // Ring-to-bus power coupling kappa^2 (e.g. 0.05)
  round_trip_loss_alpha_db_cm : Double // Waveguide propagation loss
}

///|
pub fn OpticalRingResonator::new(
  radius_um : Double,
  n_eff : Double,
  kappa2 : Double,
  loss_db : Double,
) -> OpticalRingResonator {
  {
    ring_radius_um: radius_um,
    waveguide_effective_index: n_eff,
    power_coupling_coefficient_k2: kappa2,
    round_trip_loss_alpha_db_cm: loss_db,
  }
}

///|
/// Ring Resonator Spectral Transmission Point: T = (a^2 - 2 r a cos(phi) + r^2) / (1 - 2 r a cos(phi) + (r a)^2)
pub fn OpticalRingResonator::calculate_transmission(
  self : OpticalRingResonator,
  wavelength_nm : Double,
) -> Double {
  let perimeter_um = 2.0 * @math.PI * self.ring_radius_um
  let phi = 2.0 *
    @math.PI *
    self.waveguide_effective_index *
    (perimeter_um * 1000.0) /
    wavelength_nm

  // Amplitude transmission factor r = sqrt(1 - kappa^2)
  let r = (1.0 - self.power_coupling_coefficient_k2).sqrt()

  // Round trip amplitude attenuation: a = exp(-alpha * L / 2)
  let alpha_np_um = self.round_trip_loss_alpha_db_cm / 4.343 * 1.0e-4
  let a = @math.exp(-0.5 * alpha_np_um * perimeter_um)

  let num = a * a - 2.0 * r * a * @math.cos(phi) + r * r
  let denom = 1.0 - 2.0 * r * a * @math.cos(phi) + r * a * (r * a)

  if denom <= 0.0 {
    0.0
  } else {
    num / denom
  }
}

///|
/// Free Spectral Range (FSR) in nm: FSR = lambda^2 / (n_g * L)
pub fn OpticalRingResonator::calculate_fsr_nm(
  self : OpticalRingResonator,
  wavelength_nm : Double,
) -> Double {
  let perimeter_um = 2.0 * @math.PI * self.ring_radius_um
  let l_nm = perimeter_um * 1000.0
  wavelength_nm * wavelength_nm / (self.waveguide_effective_index * l_nm)
}
