///|
// ============================================================================
// Magneto-Optical Materials & Faraday Rotators Database
// Gyrotropic permittivity tensors & Verdet constants
// ============================================================================

///|
pub fn terbium_gallium_garnet_tgg() -> OpticalMaterial {
  // TGG (Tb3Ga5O12) premier Faraday rotator crystal for 400 - 1100 nm (Verdet V ~ -134 rad/T/m at 633nm)
  let sell = @disp.Sellmeier3Dispersion::new(
    2.656, 0.0135, 0.412, 0.052, 0.0, 0.0,
  )
  {
    name: "TGG (Terbium Gallium Garnet)",
    category: MaterialCategory::Dielectric,
    formula: "Tb3Ga5O12",
    bandgap_ev: 3.8,
    dispersion_fn: fn(wl) { sell.get_complex_index(wl) },
  }
}

///|
/// Verdet Constant V(lambda) in rad / (T * m) for TGG crystal
pub fn tgg_verdet_constant(wavelength_nm : Double) -> Double {
  // Analytical fit: V(lambda) = - (1.85e7) / (lambda^2 - lambda_0^2)
  let wl_um = wavelength_nm / 1000.0
  let wl0_um = 0.258
  let denom = wl_um * wl_um - wl0_um * wl0_um
  if denom <= 0.0 {
    -134.0
  } else {
    -42.0 / denom
  }
}

///|
pub fn yttrium_iron_garnet_yig() -> OpticalMaterial {
  // YIG (Y3Fe5O12) telecom infrared Faraday rotator crystal (1310 nm & 1550 nm)
  let sell = @disp.Sellmeier3Dispersion::new(3.592, 0.0245, 0.0, 0.0, 0.0, 0.0)
  {
    name: "YIG (Yttrium Iron Garnet)",
    category: MaterialCategory::Dielectric,
    formula: "Y3Fe5O12",
    bandgap_ev: 2.8,
    dispersion_fn: fn(wl) { sell.get_complex_index(wl) },
  }
}

///|
pub fn bismuth_yig_biyig() -> OpticalMaterial {
  // Bi:YIG (Bi-doped YIG) huge Faraday rotation for compact thin-film isolators
  let sell = @disp.Sellmeier3Dispersion::new(4.250, 0.032, 0.0, 0.0, 0.0, 0.0)
  {
    name: "Bi:YIG (Bismuth-Substituted YIG)",
    category: MaterialCategory::Dielectric,
    formula: "Bi1.2Y1.8Fe5O12",
    bandgap_ev: 2.5,
    dispersion_fn: fn(wl) { sell.get_complex_index(wl) },
  }
}
