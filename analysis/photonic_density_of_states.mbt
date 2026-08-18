///|
/// Local Density of Optical States (LDOS) & Purcell Factor Engine
pub struct LocalDensityOfStates {
  purcell_factor_perp : Double // Enhancement for perpendicular dipole orientation
  purcell_factor_parallel : Double // Enhancement for parallel dipole orientation
  orientation_averaged_purcell : Double // F_p = (1/3) * F_perp + (2/3) * F_par
  radiative_quantum_efficiency : Double // eta_rad = F_rad / (F_rad + F_nrad)
} derive(Eq)

///|
pub impl Show for LocalDensityOfStates with fn output(self, logger) {
  logger.write_string(
    "LDOS(Purcell_Avg=\{self.orientation_averaged_purcell}x, F_perp=\{self.purcell_factor_perp}, F_par=\{self.purcell_factor_parallel}, Rad_QE=\{self.radiative_quantum_efficiency * 100.0}%)",
  )
}

///|
/// Calculate LDOS Enhancement from Multilayer Reflection Coefficients at Dipole Position z
pub fn calculate_ldos_at_depth(
  r_te : @core.Complex,
  r_tm : @core.Complex,
  distance_from_interface_nm : Double,
  wavelength_nm : Double,
  intrinsic_quantum_yield : Double,
) -> LocalDensityOfStates {
  let k0 = 2.0 * @math.PI / wavelength_nm
  let phase = 2.0 * k0 * distance_from_interface_nm

  // Perpendicular dipole couples to TM: F_perp = 1 + 1.5 * Im(r_tm * exp(i * phase))
  let exp_phase = @core.Complex::new(@math.cos(phase), @math.sin(phase))
  let term_tm = r_tm.mul(exp_phase)
  let f_perp = 1.0 + 1.5 * term_tm.im

  // Parallel dipole couples to both TE and TM: F_par = 1 + 0.75 * Im((r_te - r_tm) * exp(i * phase))
  let diff_r = r_te.sub(r_tm)
  let term_par = diff_r.mul(exp_phase)
  let f_par = 1.0 + 0.75 * term_par.im

  let f_perp_clamped = if f_perp < 0.05 { 0.05 } else { f_perp }
  let f_par_clamped = if f_par < 0.05 { 0.05 } else { f_par }
  let f_avg = 1.0 / 3.0 * f_perp_clamped + 2.0 / 3.0 * f_par_clamped

  let eta_rad = f_avg *
    intrinsic_quantum_yield /
    (f_avg * intrinsic_quantum_yield + (1.0 - intrinsic_quantum_yield))

  {
    purcell_factor_perp: f_perp_clamped,
    purcell_factor_parallel: f_par_clamped,
    orientation_averaged_purcell: f_avg,
    radiative_quantum_efficiency: eta_rad,
  }
}
