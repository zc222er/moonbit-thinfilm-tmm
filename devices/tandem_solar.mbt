///|
/// Monolithic 2-Terminal Perovskite / Silicon Tandem Solar Cell Engine
pub struct TandemSolarCell {
  top_perovskite_thickness_nm : Double
  bottom_silicon_thickness_um : Double
  front_arc_thickness_nm : Double
  recombination_layer_thickness_nm : Double
}

///|
pub fn TandemSolarCell::new(
  top_pero_nm : Double,
  bot_si_um : Double,
  arc_nm : Double,
  rec_nm : Double,
) -> TandemSolarCell {
  {
    top_perovskite_thickness_nm: top_pero_nm,
    bottom_silicon_thickness_um: bot_si_um,
    front_arc_thickness_nm: arc_nm,
    recombination_layer_thickness_nm: rec_nm,
  }
}

///|
/// Tandem Current Matching Simulation Result
pub struct TandemCurrentResult {
  j_top_ma_cm2 : Double // Current generated in Top Perovskite cell
  j_bottom_ma_cm2 : Double // Current generated in Bottom Silicon cell
  j_matched_2t_ma_cm2 : Double // Limiting 2-terminal current: min(J_top, J_bot)
  current_mismatch_percent : Double // abs(J_top - J_bot) / max(J_top, J_bot) * 100%
  top_absorption_spectrum : @core.SpectrumData
  bottom_absorption_spectrum : @core.SpectrumData
} derive(Eq)

///|
pub impl Show for TandemCurrentResult with fn output(self, logger) {
  logger.write_string(
    "TandemResult(2T Jsc=\{self.j_matched_2t_ma_cm2} mA/cm², J_top=\{self.j_top_ma_cm2}, J_bot=\{self.j_bottom_ma_cm2}, mismatch=\{self.current_mismatch_percent}%)",
  )
}

///|
/// Simulate complete optical absorption & current generation in both subcells under AM1.5G
pub fn TandemSolarCell::simulate_current_matching(
  self : TandemSolarCell,
  grid : @core.SpectrumGrid,
) -> TandemCurrentResult {
  let count = grid.count()
  let q_elem = 1.602176634e-19
  let h_planck = 6.62607015e-34
  let c_light = 2.99792458e8

  let x_wls = Array::new(capacity=count)
  let y_top_integrand = Array::new(capacity=count)
  let y_bot_integrand = Array::new(capacity=count)

  let top_abs_arr = Array::new(capacity=count)
  let bot_abs_arr = Array::new(capacity=count)

  for i = 0; i < count; i = i + 1 {
    let wl = grid.get(i)
    let irr = am15g_solar_irradiance(wl)

    // Build tandem stack at wavelength wl:
    // Air / MgF2 ARC (arc_nm) / ITO (100nm) / NiOx (15nm) / Perovskite (d_pero) / C60 (20nm) / IZO Recombination (rec_nm) / Si (bot_si) / Ag
    let air = @mat.air().to_layer(0.0, wl)
    let arc = @mat.magnesium_fluoride().to_layer(
      self.front_arc_thickness_nm,
      wl,
    )
    let ito = @mat.indium_tin_oxide().to_layer(100.0, wl)
    let pero = @mat.perovskite_mapbi3().to_layer(
      self.top_perovskite_thickness_nm,
      wl,
    )
    let izo = @mat.indium_tin_oxide().to_layer(
      self.recombination_layer_thickness_nm,
      wl,
    )
    let si_sub = @mat.crystalline_silicon().to_layer(0.0, wl)

    let stack = @core.MultiLayerStack::new(air, [arc, ito, pero, izo], si_sub)
    let res = @tmm.solve_tmm2d_single(stack, wl, @core.IncidentAngle::normal())

    // Spectral partitioning:
    // Below perovskite bandgap (~780nm), light is primarily absorbed in top cell
    // Above 780nm, light transmits through top cell (T_top) and is absorbed in bottom silicon cell
    let a_top = if wl <= 780.0 {
      let frac_pero = 0.92 // high internal absorption in active layer
      res.a_power * frac_pero
    } else {
      0.01 // sub-bandgap parasitic absorption
    }

    let a_bottom = if wl > 780.0 && wl <= 1150.0 {
      // Light transmitted into silicon substrate with optical path enhancement
      let si_alpha = 4.0 *
        @math.PI *
        @mat.crystalline_silicon().get_index(wl).im /
        wl
      let single_pass = 1.0 -
        @math.exp(-si_alpha * self.bottom_silicon_thickness_um * 1000.0)
      res.t_power * single_pass
    } else if wl <= 780.0 {
      // Small transmitted residual below 780 nm
      res.t_power * 0.8
    } else {
      0.0
    }

    top_abs_arr.push(a_top)
    bot_abs_arr.push(a_bottom)

    let factor = wl * 1.0e-9 * (q_elem / (h_planck * c_light)) * 0.1
    let j_top_wl = irr * factor * a_top
    let j_bot_wl = irr * factor * a_bottom

    x_wls.push(wl)
    y_top_integrand.push(j_top_wl)
    y_bot_integrand.push(j_bot_wl)
  }

  let j_top = @linalg.simpson_rule(x_wls, y_top_integrand)
  let j_bot = @linalg.simpson_rule(x_wls, y_bot_integrand)

  let j_matched = if j_top < j_bot { j_top } else { j_bot }
  let max_j = if j_top > j_bot { j_top } else { j_bot }
  let mismatch = if max_j > 0.0 {
    (j_top - j_bot).abs() / max_j * 100.0
  } else {
    0.0
  }

  {
    j_top_ma_cm2: j_top,
    j_bottom_ma_cm2: j_bot,
    j_matched_2t_ma_cm2: j_matched,
    current_mismatch_percent: mismatch,
    top_absorption_spectrum: @core.SpectrumData::new(
      "TopPerovskiteAbsorption", grid, top_abs_arr,
    ),
    bottom_absorption_spectrum: @core.SpectrumData::new(
      "BottomSiliconAbsorption", grid, bot_abs_arr,
    ),
  }
}
