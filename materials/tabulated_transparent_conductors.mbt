///|
// ============================================================================
// Transparent Conductive Oxides & Electrodes Database
// High-resolution spectroscopic optical data (250 nm - 2500 nm)
// ============================================================================

///|
pub fn get_izo_spectrum() -> @disp.TabulatedDispersion {
  // Indium Zinc Oxide (IZO) amorphous transparent conductor
  let wls = [
    300.0, 350.0, 400.0, 450.0, 500.0, 550.0, 600.0, 700.0, 800.0, 900.0, 1000.0,
    1200.0, 1400.0, 1600.0, 1800.0, 2000.0, 2200.0, 2400.0,
  ]
  let n_arr = [
    2.15, 2.08, 2.02, 1.98, 1.95, 1.92, 1.88, 1.80, 1.70, 1.58, 1.42, 1.08, 0.78,
    0.52, 0.38, 0.28, 0.22, 0.18,
  ]
  let k_arr = [
    0.45, 0.12, 0.015, 0.003, 0.001, 0.002, 0.006, 0.022, 0.055, 0.12, 0.24, 0.62,
    1.15, 1.75, 2.38, 3.02, 3.65, 4.25,
  ]
  @disp.TabulatedDispersion::new("IZO_TCO", wls, n_arr, k_arr)
}

///|
pub fn get_igzo_spectrum() -> @disp.TabulatedDispersion {
  // Indium Gallium Zinc Oxide (a-IGZO) TFT semiconductor channel
  let wls = [
    300.0, 350.0, 380.0, 400.0, 450.0, 500.0, 550.0, 600.0, 700.0, 800.0, 1000.0,
  ]
  let n_arr = [2.25, 2.18, 2.12, 2.04, 1.96, 1.92, 1.89, 1.87, 1.85, 1.84, 1.83]
  let k_arr = [0.55, 0.22, 0.06, 0.005, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0]
  @disp.TabulatedDispersion::new("a-IGZO", wls, n_arr, k_arr)
}

///|
pub fn get_pedot_pss_clevios_ph1000() -> @disp.TabulatedDispersion {
  // High conductivity PEDOT:PSS (PH1000) with DMSO additive
  let wls = [
    350.0, 400.0, 450.0, 500.0, 550.0, 600.0, 700.0, 800.0, 900.0, 1000.0, 1200.0,
    1400.0, 1600.0, 1800.0, 2000.0,
  ]
  let n_arr = [
    1.52, 1.50, 1.48, 1.46, 1.44, 1.42, 1.38, 1.32, 1.25, 1.18, 1.02, 0.88, 0.75,
    0.65, 0.58,
  ]
  let k_arr = [
    0.02, 0.03, 0.05, 0.08, 0.12, 0.18, 0.32, 0.48, 0.65, 0.82, 1.18, 1.55, 1.90,
    2.25, 2.58,
  ]
  @disp.TabulatedDispersion::new("PEDOT_PSS_PH1000", wls, n_arr, k_arr)
}

///|
pub fn get_single_walled_cnt_film() -> @disp.TabulatedDispersion {
  // Single-Walled Carbon Nanotube transparent conducting network
  let wls = [
    400.0, 500.0, 600.0, 700.0, 800.0, 900.0, 1000.0, 1200.0, 1500.0, 1800.0, 2000.0,
  ]
  let n_arr = [1.65, 1.62, 1.58, 1.55, 1.52, 1.50, 1.48, 1.44, 1.38, 1.32, 1.28]
  let k_arr = [0.28, 0.32, 0.35, 0.38, 0.42, 0.45, 0.48, 0.55, 0.68, 0.82, 0.95]
  @disp.TabulatedDispersion::new("SWCNT_Film", wls, n_arr, k_arr)
}
