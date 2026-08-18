///|
/// Thermophotovoltaic (TPV) Selective Emitter and Low-Bandgap Cell Optical System
pub struct TPVSimulationEngine {
  emitter_temperature_k : Double // E.g. 1300K - 1800K
  cell_bandgap_ev : Double // E.g. 0.72 eV for GaSb or 0.60 eV for InGaAs
  selective_filter_stack : @core.MultiLayerStack
}

///|
pub fn TPVSimulationEngine::new(
  emitter_t_k : Double,
  bandgap_ev : Double,
  filter : @core.MultiLayerStack,
) -> TPVSimulationEngine {
  {
    emitter_temperature_k: emitter_t_k,
    cell_bandgap_ev: bandgap_ev,
    selective_filter_stack: filter,
  }
}

///|
/// TPV Efficiency Metrics Result
pub struct TPVOpticalMetrics {
  in_band_efficiency : Double // In-band photon power above bandgap / total emitted radiation
  sub_bandgap_reflectance : Double // Sub-bandgap back-reflectance to heat source
  spectral_efficiency_percent : Double // Ultimate optical spectral efficiency
  potential_power_density_w_cm2 : Double // Electrical power density potential
} derive(Eq)

///|
pub impl Show for TPVOpticalMetrics with fn output(self, logger) {
  logger.write_string(
    "TPVResult(spectral_eff=\{self.spectral_efficiency_percent}%, power_density=\{self.potential_power_density_w_cm2} W/cm², sub_bg_R=\{self.sub_bandgap_reflectance * 100.0}%)",
  )
}

///|
/// Calculate TPV Spectral Efficiency
pub fn TPVSimulationEngine::calculate_spectral_efficiency(
  self : TPVSimulationEngine,
  grid : @core.SpectrumGrid,
) -> TPVOpticalMetrics {
  let cutoff_wavelength_nm = 1239.84193 / self.cell_bandgap_ev
  let count = grid.count()

  let wls = Array::new(capacity=count)
  let f_total_emission = Array::new(capacity=count)
  let f_in_band_transmitted = Array::new(capacity=count)
  let f_sub_band_reflected = Array::new(capacity=count)
  let f_sub_band_total = Array::new(capacity=count)

  for i = 0; i < count; i = i + 1 {
    let wl = grid.get(i)
    let b_rad = planck_blackbody_radiance(wl, self.emitter_temperature_k)
    let res = @tmm.solve_tmm2d_single(
      self.selective_filter_stack,
      wl,
      @core.IncidentAngle::normal(),
    )

    wls.push(wl)
    f_total_emission.push(b_rad)

    if wl <= cutoff_wavelength_nm {
      // In-band usable photon flux
      f_in_band_transmitted.push(b_rad * res.t_power)
      f_sub_band_reflected.push(0.0)
      f_sub_band_total.push(0.0)
    } else {
      // Sub-bandgap parasitic photons
      f_in_band_transmitted.push(0.0)
      f_sub_band_reflected.push(b_rad * res.r_power)
      f_sub_band_total.push(b_rad)
    }
  }

  let total_p = @linalg.simpson_rule(wls, f_total_emission)
  let in_band_p = @linalg.simpson_rule(wls, f_in_band_transmitted)
  let sub_bg_r = @linalg.simpson_rule(wls, f_sub_band_reflected)
  let sub_bg_tot = @linalg.simpson_rule(wls, f_sub_band_total)

  let r_sub_frac = if sub_bg_tot > 0.0 { sub_bg_r / sub_bg_tot } else { 0.95 }
  let net_heat_absorbed = total_p - sub_bg_r
  let spec_eff = if net_heat_absorbed > 0.0 {
    in_band_p / net_heat_absorbed * 100.0
  } else {
    0.0
  }

  let power_density = in_band_p * @math.PI * 1.0e-4 * 0.35 // W / cm^2 at 35% PV efficiency

  {
    in_band_efficiency: if total_p > 0.0 {
      in_band_p / total_p
    } else {
      0.0
    },
    sub_bandgap_reflectance: r_sub_frac,
    spectral_efficiency_percent: spec_eff,
    potential_power_density_w_cm2: power_density,
  }
}
