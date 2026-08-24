///|
/// Cody-Lorentz Optical Dispersion Model (Cody et al. 1982, Ferlauto et al. 2004)
/// Handles band-to-band transitions and exponential Urbach absorption tail
pub struct CodyLorentzDispersion {
  eps_infinity : Double
  amplitude_a : Double // Amplitude in eV
  resonance_e0 : Double // Peak transition energy in eV
  broadening_c : Double // Broadening gamma in eV
  optical_bandgap_eg : Double // Cody optical bandgap in eV
  urbach_energy_eu : Double // Urbach tail characteristic energy in eV
  transition_energy_et : Double // Demarcation energy between Urbach tail and band absorption
} derive(Eq)

///|
pub fn CodyLorentzDispersion::new(
  eps_inf : Double,
  amp : Double,
  e0 : Double,
  c_broad : Double,
  eg : Double,
  eu : Double,
  et : Double,
) -> CodyLorentzDispersion {
  {
    eps_infinity: eps_inf,
    amplitude_a: amp,
    resonance_e0: e0,
    broadening_c: c_broad,
    optical_bandgap_eg: eg,
    urbach_energy_eu: eu,
    transition_energy_et: et,
  }
}

///|
pub impl OpticalDispersion for CodyLorentzDispersion with fn get_complex_index(
  self,
  wavelength_nm,
) {
  let e_ev = 1239.84193 / wavelength_nm

  // Cody-Lorentz imaginary dielectric function eps_2(E):
  // For E > Et: eps_2(E) = [ (E - Eg)^2 / ((E - Eg)^2 + Ep^2) ] * [ A * E0 * C * E / ((E^2 - E0^2)^2 + C^2 * E^2) ]
  // For E <= Et: eps_2(E) = (E_t / E) * exp((E - E_t) / E_u) * eps_2(E_t)
  let eps2 = if e_ev <= self.optical_bandgap_eg {
    let ep = 1.0
    let eg_diff = self.transition_energy_et - self.optical_bandgap_eg
    let num_t = eg_diff * eg_diff
    let denom_t = num_t + ep * ep
    let lorentz_t = self.amplitude_a *
      self.resonance_e0 *
      self.broadening_c *
      self.transition_energy_et /
      (
        @math.pow(
          self.transition_energy_et * self.transition_energy_et -
          self.resonance_e0 * self.resonance_e0,
          2.0,
        ) +
        self.broadening_c *
        self.broadening_c *
        self.transition_energy_et *
        self.transition_energy_et
      )
    let eps2_et = num_t / denom_t * lorentz_t
    let exp_tail = @math.exp(
      (e_ev - self.transition_energy_et) / self.urbach_energy_eu,
    )
    eps2_et * exp_tail
  } else {
    let ep = 1.0
    let eg_diff = e_ev - self.optical_bandgap_eg
    let num = eg_diff * eg_diff
    let denom = num + ep * ep
    let lorentz = self.amplitude_a *
      self.resonance_e0 *
      self.broadening_c *
      e_ev /
      (
        @math.pow(e_ev * e_ev - self.resonance_e0 * self.resonance_e0, 2.0) +
        self.broadening_c * self.broadening_c * e_ev * e_ev
      )
    num / denom * lorentz
  }

  // eps_1(E) via Kramers-Kronig approximation
  let e0_sq = self.resonance_e0 * self.resonance_e0
  let diff_sq = e0_sq - e_ev * e_ev
  let eps1 = self.eps_infinity +
    self.amplitude_a *
    diff_sq /
    (diff_sq * diff_sq + self.broadening_c * self.broadening_c * e_ev * e_ev)

  let eps_c = @core.Complex::new(eps1, eps2)
  eps_c.sqrt()
}

///|
pub impl OpticalDispersion for CodyLorentzDispersion with fn get_permittivity(
  self,
  wavelength_nm,
) {
  let n_c = OpticalDispersion::get_complex_index(self, wavelength_nm)
  n_c.mul(n_c)
}
