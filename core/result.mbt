///|
/// Complex reflection and transmission coefficients for a single wavelength and angle
pub struct OpticalCoefficients {
  r_te : Complex // Amplitude reflection coefficient for TE (s-pol)
  t_te : Complex // Amplitude transmission coefficient for TE (s-pol)
  r_tm : Complex // Amplitude reflection coefficient for TM (p-pol)
  t_tm : Complex // Amplitude transmission coefficient for TM (p-pol)
  r_cross_sp : Complex // Cross-polarization reflection s -> p (for anisotropic)
  r_cross_ps : Complex // Cross-polarization reflection p -> s (for anisotropic)
  t_cross_sp : Complex // Cross-polarization transmission s -> p (for anisotropic)
  t_cross_ps : Complex // Cross-polarization transmission p -> s (for anisotropic)
} derive(Eq, Default)

///|
pub impl Show for OpticalCoefficients with fn output(self, logger) {
  logger.write_string(
    "OpticalCoefficients(r_te=\{self.r_te}, t_te=\{self.t_te}, r_tm=\{self.r_tm}, t_tm=\{self.t_tm})",
  )
}

///|
pub fn OpticalCoefficients::isotropic(
  r_te : Complex,
  t_te : Complex,
  r_tm : Complex,
  t_tm : Complex,
) -> OpticalCoefficients {
  {
    r_te,
    t_te,
    r_tm,
    t_tm,
    r_cross_sp: Complex::zero(),
    r_cross_ps: Complex::zero(),
    t_cross_sp: Complex::zero(),
    t_cross_ps: Complex::zero(),
  }
}

///|
/// Energy power reflectance R, transmittance T, and absorptance A for a single wavelength
pub struct SingleWavelengthResult {
  wavelength_nm : Double
  r_power : Double // Reflectance R = |r|^2 (0.0 to 1.0)
  t_power : Double // Transmittance T = (n_sub / n_amb) * |t|^2 (0.0 to 1.0)
  a_power : Double // Absorptance A = 1 - R - T (0.0 to 1.0)
  phase_r_deg : Double // Reflection phase shift in degrees
  phase_t_deg : Double // Transmission phase shift in degrees
  r_te_power : Double
  t_te_power : Double
  r_tm_power : Double
  t_tm_power : Double
} derive(Eq, Default)

///|
pub impl Show for SingleWavelengthResult with fn output(self, logger) {
  logger.write_string(
    "Result(@\{self.wavelength_nm}nm: R=\{self.r_power}, T=\{self.t_power}, A=\{self.a_power})",
  )
}

///|
/// Full spectral optical simulation result
pub struct SpectralSimulationResult {
  grid : SpectrumGrid
  reflectance : SpectrumData
  transmittance : SpectrumData
  absorptance : SpectrumData
  r_te : SpectrumData
  t_te : SpectrumData
  r_tm : SpectrumData
  t_tm : SpectrumData
  phase_r : SpectrumData
  phase_t : SpectrumData
} derive(Eq)

///|
pub impl Show for SpectralSimulationResult with fn output(self, logger) {
  logger.write_string(
    "SpectralSimulationResult(\{self.grid.count()} wavelengths)",
  )
}

///|
/// Spatial depth point for electric and magnetic field distribution
pub struct DepthFieldPoint {
  z_nm : Double // Depth position in nanometers from ambient interface
  layer_index : Int // Index of the layer (-1 for ambient, 0..N-1 for films, N for substrate)
  e_intensity : Double // Normalized |E(z)|^2 / |E0|^2
  ex : Complex // Ex component
  ey : Complex // Ey component
  ez : Complex // Ez component
  hx : Complex // Hx component
  hy : Complex // Hy component
  poynting_z : Double // Real part of Poynting vector Sz(z)
  absorption_rate : Double // Local dissipation Q(z) = 0.5 * omega * eps0 * Im(eps) * |E|^2
} derive(Eq, Default)

///|
pub impl Show for DepthFieldPoint with fn output(self, logger) {
  logger.write_string(
    "FieldPoint(z=\{self.z_nm}nm, |E|^2=\{self.e_intensity}, Sz=\{self.poynting_z})",
  )
}

///|
/// Spatial depth field simulation profile
pub struct DepthFieldProfile {
  wavelength_nm : Double
  angle_deg : Double
  polarization : Polarization
  points : Array[DepthFieldPoint]
} derive(Eq)

///|
pub impl Show for DepthFieldProfile with fn output(self, logger) {
  logger.write_string(
    "DepthFieldProfile(wl=\{self.wavelength_nm}nm, angle=\{self.angle_deg}°, pol=\{self.polarization}, points=\{self.points.length()})",
  )
}

///|
/// Spectroscopic Ellipsometry parameters Psi and Delta
/// tan(Psi) * exp(i * Delta) = r_p / r_s
pub struct EllipsometryPoint {
  wavelength_nm : Double
  psi_deg : Double // Psi in degrees (0 to 90 deg)
  delta_deg : Double // Delta in degrees (-180 to 180 deg or 0 to 360 deg)
  tan_psi : Double
  cos_delta : Double
  rho : Complex // Complex ratio r_p / r_s
} derive(Eq, Default)

///|
pub impl Show for EllipsometryPoint with fn output(self, logger) {
  logger.write_string(
    "EllipsometryPoint(@\{self.wavelength_nm}nm: Psi=\{self.psi_deg}°, Delta=\{self.delta_deg}°)",
  )
}

///|
/// Photovoltaic Solar Cell metrics
pub struct SolarCellOpticalResult {
  short_circuit_current_ma_cm2 : Double // Jsc in mA/cm^2 under AM1.5G
  integrated_absorption_fraction : Double // Fraction of AM1.5G photons absorbed (0.0 to 1.0)
  weighted_reflectance : Double // AM1.5G weighted solar reflectance
  active_layer_absorption : SpectrumData // EQE(lambda) / Absorptance in photoactive layer
} derive(Eq)

///|
pub impl Show for SolarCellOpticalResult with fn output(self, logger) {
  logger.write_string(
    "SolarCellResult(Jsc=\{self.short_circuit_current_ma_cm2} mA/cm², absorbed=\{self.integrated_absorption_fraction * 100.0}%)",
  )
}

///|
/// Non-linear parameter inversion & fitting result
pub struct InversionResult {
  converged : Bool
  iterations : Int
  final_residual_mse : Double
  optimized_parameters : Array[Double]
  parameter_names : Array[String]
  uncertainties : Array[Double] // 1-sigma standard errors from covariance matrix
  message : String
} derive(Eq)

///|
pub impl Show for InversionResult with fn output(self, logger) {
  logger.write_string(
    "InversionResult(converged=\{self.converged}, iter=\{self.iterations}, mse=\{self.final_residual_mse})",
  )
}
