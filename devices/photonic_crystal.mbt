///|
/// 1D Photonic Crystal (Photonic Bandgap Structure) Engine
pub struct PhotonicCrystal1D {
  period_nm : Double // Lattice period Lambda = d1 + d2
  fill_factor_1 : Double // d1 / Lambda (0.0 to 1.0)
  layer_1_material : @mat.OpticalMaterial
  layer_2_material : @mat.OpticalMaterial
  num_unit_cells : Int
}

///|
pub fn PhotonicCrystal1D::new(
  period : Double,
  fill_1 : Double,
  mat_1 : @mat.OpticalMaterial,
  mat_2 : @mat.OpticalMaterial,
  cells : Int,
) -> PhotonicCrystal1D {
  {
    period_nm: period,
    fill_factor_1: fill_1,
    layer_1_material: mat_1,
    layer_2_material: mat_2,
    num_unit_cells: cells,
  }
}

///|
/// Bloch Wave Dispersion Relation: cos(K * Lambda) = 0.5 * (M11 + M22)
pub struct BlochBandPoint {
  wavelength_nm : Double
  frequency_thz : Double
  normalized_frequency : Double // omega * Lambda / (2 * pi * c) = Lambda / lambda
  bloch_wavevector_k : Double // Bloch K (in units of pi / Lambda)
  is_bandgap : Bool // True if |0.5 * (M11 + M22)| > 1.0
  group_velocity_normalized : Double // v_g / c
} derive(Eq)

///|
pub impl Show for BlochBandPoint with fn output(self, logger) {
  let bg_str = if self.is_bandgap { "[Bandgap]" } else { "[Passband]" }
  logger.write_string(
    "BlochPoint(wl=\{self.wavelength_nm}nm, K=\{self.bloch_wavevector_k} pi/Lambda, vg=\{self.group_velocity_normalized}c \{bg_str})",
  )
}

///|
/// Calculate Bloch dispersion point for a given wavelength
pub fn PhotonicCrystal1D::calculate_bloch_point(
  self : PhotonicCrystal1D,
  wavelength_nm : Double,
) -> BlochBandPoint {
  let d1 = self.period_nm * self.fill_factor_1
  let d2 = self.period_nm * (1.0 - self.fill_factor_1)

  let l1 = self.layer_1_material.to_layer(d1, wavelength_nm)
  let l2 = self.layer_2_material.to_layer(d2, wavelength_nm)

  let wl = @core.Wavelength::from_nm(wavelength_nm)
  let k0 = wl.wavenumber_nm()
  let theta_rad = 0.0 // normal incidence

  let n1 = @tmm.get_layer_isotropic_index(l1)
  let n2 = @tmm.get_layer_isotropic_index(l2)

  let kz1 = @tmm.calculate_kz(n1, n1, theta_rad, k0)
  let kz2 = @tmm.calculate_kz(n2, n1, theta_rad, k0)

  let eta1 = @tmm.calculate_admittance(n1, kz1, k0, @core.Polarization::TE)
  let eta2 = @tmm.calculate_admittance(n2, kz2, k0, @core.Polarization::TE)

  let p1 = @tmm.calculate_characteristic_matrix(kz1, d1, eta1)
  let p2 = @tmm.calculate_characteristic_matrix(kz2, d2, eta2)

  // Unit cell transfer matrix M = P1 * P2
  let m_unit = p1.mul(p2)

  // Trace of unit cell matrix: 0.5 * (M11 + M22)
  let half_trace = (m_unit.m00.re + m_unit.m11.re) * 0.5
  let abs_trace = half_trace.abs()

  let is_bg = abs_trace > 1.0
  let bloch_k = if is_bg {
    1.0 // At edge of Brillouin zone (K = pi / Lambda)
  } else {
    @math.acos(half_trace) / @math.PI
  }

  let c_light = 2.99792458e8
  let freq_thz = c_light / (wavelength_nm * 1.0e-9) * 1.0e-12
  let norm_freq = self.period_nm / wavelength_nm

  // Slow light group velocity estimate
  let vg_norm = if is_bg {
    0.0
  } else {
    let sin_k = @math.sin(bloch_k * @math.PI)
    if sin_k.abs() < 1.0e-4 {
      0.05
    } else {
      sin_k * 0.8
    }
  }

  {
    wavelength_nm,
    frequency_thz: freq_thz,
    normalized_frequency: norm_freq,
    bloch_wavevector_k: bloch_k,
    is_bandgap: is_bg,
    group_velocity_normalized: vg_norm,
  }
}
