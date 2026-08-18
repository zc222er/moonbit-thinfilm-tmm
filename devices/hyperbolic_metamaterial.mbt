///|
/// Hyperbolic Metamaterial (HMM) Multilayer Superlattice Engine
pub struct HyperbolicMetamaterial {
  metal_material : @mat.OpticalMaterial // E.g. Au or Ag
  dielectric_material : @mat.OpticalMaterial // E.g. TiO2 or Al2O3
  metal_fill_fraction : Double // f_m = d_m / (d_m + d_d)
  unit_period_nm : Double // d_total = d_m + d_d (e.g. 10 - 20 nm subwavelength)
}

///|
pub fn HyperbolicMetamaterial::new(
  metal : @mat.OpticalMaterial,
  dielectric : @mat.OpticalMaterial,
  fill_metal : Double,
  period_nm : Double,
) -> HyperbolicMetamaterial {
  {
    metal_material: metal,
    dielectric_material: dielectric,
    metal_fill_fraction: fill_metal,
    unit_period_nm: period_nm,
  }
}

///|
/// Effective Anisotropic Permittivity Tensor Components via Effective Medium Theory (EMT):
/// eps_parallel = f_m * eps_m + (1 - f_m) * eps_d
/// eps_perp = (f_m / eps_m + (1 - f_m) / eps_d)^(-1)
pub struct HMMAnisotropicPermittivity {
  eps_parallel : @core.Complex // in-plane (x, y)
  eps_perpendicular : @core.Complex // out-of-plane (z)
  is_type_1_hyperbolic : Bool // Re(eps_parallel) > 0 and Re(eps_perp) < 0
  is_type_2_hyperbolic : Bool // Re(eps_parallel) < 0 and Re(eps_perp) > 0
  is_elliptic_dielectric : Bool
} derive(Eq)

///|
pub impl Show for HMMAnisotropicPermittivity with fn output(self, logger) {
  let type_str = if self.is_type_1_hyperbolic {
    "Type-I Hyperbolic (Isofrequency: 2-sheet hyperboloid)"
  } else if self.is_type_2_hyperbolic {
    "Type-II Hyperbolic (Isofrequency: 1-sheet hyperboloid)"
  } else {
    "Elliptic Dielectric"
  }
  logger.write_string(
    "HMM_Permittivity(eps_par=\{self.eps_parallel}, eps_perp=\{self.eps_perpendicular}, regime=\{type_str})",
  )
}

///|
/// Calculate Effective Hyperbolic Permittivities at Wavelength
pub fn HyperbolicMetamaterial::calculate_effective_permittivities(
  self : HyperbolicMetamaterial,
  wavelength_nm : Double,
) -> HMMAnisotropicPermittivity {
  let n_m = self.metal_material.get_index(wavelength_nm)
  let eps_m = n_m.mul(n_m)

  let n_d = self.dielectric_material.get_index(wavelength_nm)
  let eps_d = n_d.mul(n_d)

  let fm = self.metal_fill_fraction
  let fd = 1.0 - fm

  // eps_parallel = fm * eps_m + fd * eps_d
  let eps_par = eps_m.mul_real(fm).add(eps_d.mul_real(fd))

  // eps_perp = 1 / (fm / eps_m + fd / eps_d)
  let inv_eps_m = if eps_m.abs() == 0.0 {
    @core.Complex::zero()
  } else {
    @core.Complex::one().div(eps_m)
  }
  let inv_eps_d = if eps_d.abs() == 0.0 {
    @core.Complex::zero()
  } else {
    @core.Complex::one().div(eps_d)
  }
  let sum_inv = inv_eps_m.mul_real(fm).add(inv_eps_d.mul_real(fd))
  let eps_perp = if sum_inv.abs() == 0.0 {
    @core.Complex::zero()
  } else {
    @core.Complex::one().div(sum_inv)
  }

  let t1 = eps_par.re > 0.0 && eps_perp.re < 0.0
  let t2 = eps_par.re < 0.0 && eps_perp.re > 0.0
  let ell = eps_par.re > 0.0 && eps_perp.re > 0.0

  {
    eps_parallel: eps_par,
    eps_perpendicular: eps_perp,
    is_type_1_hyperbolic: t1,
    is_type_2_hyperbolic: t2,
    is_elliptic_dielectric: ell,
  }
}
