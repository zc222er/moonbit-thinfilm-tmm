///|
/// Forouhi-Bloomer (FB) Interband Optical Dispersion Model (Forouhi & Bloomer 1986)
pub struct ForouhiBloomerDispersion {
  n_infinity : Double
  amplitude_a : Double
  broadening_b : Double
  position_c : Double
  bandgap_eg : Double
} derive(Eq)

///|
pub fn ForouhiBloomerDispersion::new(
  n_inf : Double,
  amp : Double,
  b_val : Double,
  c_val : Double,
  eg : Double,
) -> ForouhiBloomerDispersion {
  {
    n_infinity: n_inf,
    amplitude_a: amp,
    broadening_b: b_val,
    position_c: c_val,
    bandgap_eg: eg,
  }
}

///|
/// Calculate (n, k) index from Forouhi-Bloomer formulas
pub fn ForouhiBloomerDispersion::get_complex_index(
  self : ForouhiBloomerDispersion,
  wavelength_nm : Double,
) -> @core.Complex {
  let e_ev = 1239.84193 / wavelength_nm

  // k(E) = A * (E - Eg)^2 / (E^2 - B * E + C) for E > Eg
  let k_val = if e_ev <= self.bandgap_eg {
    0.0
  } else {
    let diff = e_ev - self.bandgap_eg
    let denom = e_ev * e_ev - self.broadening_b * e_ev + self.position_c
    if denom.abs() < 1.0e-6 {
      0.0
    } else {
      self.amplitude_a * diff * diff / denom
    }
  }

  // Analytical Kramers-Kronig for n(E)
  let q = 0.5 *
    (4.0 * self.position_c - self.broadening_b * self.broadening_b).sqrt()
  let b0 = self.amplitude_a /
    q *
    (
      -0.5 * self.broadening_b * self.broadening_b +
      self.broadening_b * self.bandgap_eg -
      self.position_c +
      self.bandgap_eg * self.bandgap_eg
    )
  let c0 = self.amplitude_a /
    q *
    (
      0.5 *
      (self.broadening_b * self.broadening_b - 4.0 * self.position_c) *
      self.bandgap_eg +
      self.broadening_b * self.position_c -
      self.bandgap_eg * self.position_c
    )

  let denom_e = e_ev * e_ev - self.broadening_b * e_ev + self.position_c
  let n_val = self.n_infinity +
    (b0 * e_ev + c0) / (if denom_e.abs() < 1.0e-6 { 1.0 } else { denom_e })

  @core.Complex::new(n_val, k_val)
}
