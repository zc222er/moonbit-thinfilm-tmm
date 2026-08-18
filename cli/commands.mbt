///|
/// Execute 'simulate' CLI command: simulate AR coating or general multilayer stack
pub fn cmd_simulate() -> String {
  let air = @mat.air().to_layer(0.0, 550.0)
  let tio2 = @mat.titanium_dioxide().to_layer(55.0, 550.0)
  let sio2 = @mat.fused_silica().to_layer(90.0, 550.0)
  let glass = @mat.bk7().to_layer(0.0, 550.0)

  let stack = @core.MultiLayerStack::new(air, [tio2, sio2], glass)
  let grid = @core.SpectrumGrid::visible_spectrum(61)
  let sim = @tmm.solve_spectrum(stack, grid, @core.IncidentAngle::normal())

  let sb = StringBuilder::new()
  sb.write_string(
    "=== MultiLayer Optical Simulation (Glass / TiO2 55nm / SiO2 90nm / Air) ===\n\n",
  )
  sb.write_string(render_ascii_spectrum(sim.reflectance, 60, 12))
  sb.write_string("\n")

  // Colorimetry
  let color = @ana.spectrum_to_color(sim.reflectance)
  sb.write_string(
    "Structural Reflectance Color: \{color.hex_code} (RGB: \{color.srgb_r}, \{color.srgb_g}, \{color.srgb_b})\n",
  )
  sb.write_string(
    "CIE 1931 xy Chromaticity: (x = \{color.chroma_x}, y = \{color.chroma_y})\n",
  )

  sb.to_string()
}

///|
/// Execute 'dbr' CLI command: design Distributed Bragg Reflector
pub fn cmd_dbr(pairs : Int, center_wl : Double) -> String {
  let tio2 = @mat.titanium_dioxide()
  let sio2 = @mat.fused_silica()
  let glass = @mat.bk7().to_layer(0.0, center_wl)

  let dbr = @dev.DBRDesign::new(center_wl, pairs, tio2, sio2, glass)
  let stack = dbr.build_stack()

  let start_wl = center_wl - 250.0
  let stop_wl = center_wl + 250.0
  let grid = @core.SpectrumGrid::linear(start_wl, stop_wl, 81)
  let sim = @tmm.solve_spectrum(stack, grid, @core.IncidentAngle::normal())

  let stopband_w = dbr.analytical_stopband_width()
  let peak_r = dbr.analytical_peak_reflectance()

  let sb = StringBuilder::new()
  sb.write_string("=== Distributed Bragg Reflector (DBR) Simulation ===\n")
  sb.write_string("Center Wavelength: \{center_wl} nm, Pairs: \{pairs}\n")
  sb.write_string("Materials: TiO2 (n=2.48) / SiO2 (n=1.46)\n")
  sb.write_string("Analytical Stopband Width: \{stopband_w} nm\n")
  sb.write_string("Analytical Peak Reflectivity: \{peak_r * 100.0}%\n\n")
  sb.write_string(render_ascii_spectrum(sim.reflectance, 60, 12))

  sb.to_string()
}

///|
/// Execute 'solar' CLI command: simulate solar cell optical efficiency
pub fn cmd_solar() -> String {
  let grid = @core.SpectrumGrid::solar_spectrum(61)
  let solar_stack = @dev.create_perovskite_solar_cell(380.0, 550.0)
  let res = @dev.calculate_solar_cell_jsc(solar_stack, 2, grid)

  let sb = StringBuilder::new()
  sb.write_string("=== Perovskite Solar Cell Optical Simulation (AM1.5G) ===\n")
  sb.write_string(
    "Stack: Glass / ITO 120nm / PEDOT:PSS 30nm / MAPbI3 380nm / Ag 100nm\n",
  )
  sb.write_string(
    "Short-Circuit Current Density (J_sc): \{res.short_circuit_current_ma_cm2} mA/cm^2\n",
  )
  sb.write_string(
    "Integrated Solar Absorption: \{res.integrated_absorption_fraction * 100.0}%\n",
  )
  sb.write_string(
    "Weighted Solar Loss (Reflectance): \{res.weighted_reflectance * 100.0}%\n\n",
  )
  sb.write_string(render_ascii_spectrum(res.active_layer_absorption, 60, 10))

  sb.to_string()
}

///|
/// Execute 'materials' CLI command: list all physical optical constants
pub fn cmd_materials() -> String {
  let db = @mat.MaterialDatabase::standard()
  let all_mats = db.all()

  let sb = StringBuilder::new()
  sb.write_string(
    "=== Optical Materials Database (\{all_mats.length()} materials) ===\n",
  )
  sb.write_string(
    "Name                           | Category        | Bandgap  | n @ 550nm   | n @ 1550nm\n",
  )
  sb.write_string(
    "-------------------------------+-----------------+----------+-------------+------------\n",
  )

  for m in all_mats {
    let n_550 = m.get_index(550.0)
    let n_1550 = m.get_index(1550.0)

    let mut name_pad = m.name
    while name_pad.length() < 30 {
      name_pad = name_pad + " "
    }

    let mut cat_pad = "\{m.category}"
    while cat_pad.length() < 15 {
      cat_pad = cat_pad + " "
    }

    sb.write_string(
      "\{name_pad} | \{cat_pad} | \{m.bandgap_ev} eV | \{n_550.re} + \{n_550.im}i | \{n_1550.re} + \{n_1550.im}i\n",
    )
  }

  sb.to_string()
}

///|
/// Execute 'benchmark' CLI command: test computational throughput
pub fn cmd_benchmark() -> String {
  let tio2 = @mat.titanium_dioxide()
  let sio2 = @mat.fused_silica()
  let glass = @mat.bk7().to_layer(0.0, 600.0)

  // 50 pairs = 100 thin film layers
  let dbr = @dev.DBRDesign::new(600.0, 50, tio2, sio2, glass)
  let stack = dbr.build_stack()

  // 1000 wavelength points
  let grid = @core.SpectrumGrid::linear(400.0, 800.0, 1000)
  let sim = @tmm.solve_spectrum(stack, grid, @core.IncidentAngle::normal())

  let sb = StringBuilder::new()
  sb.write_string("=== Pure MoonBit Optical Simulation Benchmark ===\n")
  sb.write_string(
    "1. 100-Layer DBR Transfer Matrix Multiplications: 1,000 Wavelength Points\n",
  )
  sb.write_string(
    "   Total 2x2 Matrix Products Computed: \{100 * 1000} matrix operations\n",
  )
  sb.write_string(
    "   Status: Completed successfully in Pure MoonBit (WASM/Native compatible)\n",
  )
  sb.write_string(
    "   Reflectance @ 600nm: \{sim.reflectance.interpolate_linear(600.0) * 100.0}%\n",
  )

  sb.to_string()
}
