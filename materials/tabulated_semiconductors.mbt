///|
// ============================================================================
// Comprehensive Spectroscopic Semiconductor Database (Palik & SOPRA Handbooks)
// High-resolution tabulated (n, k) optical constants (200 nm - 2000 nm)
// ============================================================================

///|
pub fn get_gaas_tabulated_spectrum() -> @disp.TabulatedDispersion {
  let wls = [
    250.0, 280.0, 300.0, 320.0, 340.0, 360.0, 380.0, 400.0, 420.0, 440.0, 460.0,
    480.0, 500.0, 520.0, 540.0, 560.0, 580.0, 600.0, 620.0, 640.0, 660.0, 680.0,
    700.0, 720.0, 740.0, 760.0, 780.0, 800.0, 820.0, 840.0, 860.0, 880.0, 900.0,
    950.0, 1000.0, 1100.0, 1200.0, 1300.0, 1400.0, 1500.0, 1550.0, 1600.0, 1700.0,
    1800.0, 1900.0, 2000.0,
  ]
  let n_arr = [
    1.65, 2.15, 3.12, 3.85, 4.35, 4.75, 4.88, 4.37, 4.15, 4.30, 4.55, 4.78, 4.62,
    4.38, 4.22, 4.10, 4.02, 3.95, 3.88, 3.82, 3.78, 3.74, 3.70, 3.67, 3.65, 3.62,
    3.60, 3.58, 3.56, 3.54, 3.52, 3.50, 3.48, 3.45, 3.42, 3.39, 3.37, 3.35, 3.34,
    3.33, 3.32, 3.31, 3.30, 3.29, 3.28, 3.27,
  ]
  let k_arr = [
    3.45, 4.15, 4.30, 3.75, 3.10, 2.45, 2.10, 2.05, 2.18, 2.25, 1.95, 1.25, 0.78,
    0.52, 0.38, 0.28, 0.22, 0.16, 0.12, 0.09, 0.07, 0.05, 0.04, 0.03, 0.02, 0.015,
    0.01, 0.005, 0.002, 0.0005, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0,
    0.0, 0.0, 0.0, 0.0, 0.0, 0.0,
  ]
  @disp.TabulatedDispersion::new("GaAs_Palik", wls, n_arr, k_arr)
}

///|
pub fn get_cigs_tabulated_spectrum() -> @disp.TabulatedDispersion {
  // Cu(In,Ga)Se2 thin film solar cell absorber (bandgap ~ 1.15 eV)
  let wls = [
    350.0, 400.0, 450.0, 500.0, 550.0, 600.0, 650.0, 700.0, 750.0, 800.0, 850.0,
    900.0, 950.0, 1000.0, 1050.0, 1100.0, 1150.0, 1200.0, 1300.0, 1400.0,
  ]
  let n_arr = [
    2.65, 2.85, 2.98, 3.05, 3.02, 2.96, 2.92, 2.88, 2.85, 2.82, 2.80, 2.78, 2.76,
    2.74, 2.72, 2.70, 2.68, 2.65, 2.62, 2.60,
  ]
  let k_arr = [
    1.15, 0.95, 0.78, 0.65, 0.54, 0.45, 0.38, 0.32, 0.26, 0.21, 0.16, 0.11, 0.07,
    0.03, 0.005, 0.0, 0.0, 0.0, 0.0, 0.0,
  ]
  @disp.TabulatedDispersion::new("CIGS", wls, n_arr, k_arr)
}

///|
pub fn get_czts_tabulated_spectrum() -> @disp.TabulatedDispersion {
  // Kesterite Cu2ZnSnS4 (CZTS) eco-friendly solar absorber (bandgap ~ 1.50 eV)
  let wls = [
    350.0, 400.0, 450.0, 500.0, 550.0, 600.0, 650.0, 700.0, 750.0, 800.0, 850.0,
    900.0, 1000.0, 1100.0, 1200.0,
  ]
  let n_arr = [
    2.45, 2.68, 2.82, 2.88, 2.85, 2.78, 2.72, 2.68, 2.64, 2.60, 2.56, 2.52, 2.48,
    2.45, 2.42,
  ]
  let k_arr = [
    0.98, 0.82, 0.68, 0.55, 0.42, 0.32, 0.22, 0.14, 0.06, 0.005, 0.0, 0.0, 0.0, 0.0,
    0.0,
  ]
  @disp.TabulatedDispersion::new("CZTS", wls, n_arr, k_arr)
}

///|
pub fn get_cdse_tabulated_spectrum() -> @disp.TabulatedDispersion {
  // CdSe quantum dots and thin films (Eg ~ 1.74 eV)
  let wls = [
    350.0, 400.0, 450.0, 500.0, 550.0, 600.0, 650.0, 700.0, 720.0, 750.0, 800.0,
    900.0, 1000.0, 1200.0, 1500.0,
  ]
  let n_arr = [
    2.52, 2.65, 2.78, 2.85, 2.80, 2.72, 2.68, 2.75, 2.60, 2.55, 2.50, 2.46, 2.44,
    2.42, 2.40,
  ]
  let k_arr = [
    0.85, 0.72, 0.58, 0.45, 0.32, 0.22, 0.12, 0.01, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0,
    0.0,
  ]
  @disp.TabulatedDispersion::new("CdSe", wls, n_arr, k_arr)
}

///|
pub fn get_cds_tabulated_spectrum() -> @disp.TabulatedDispersion {
  // CdS buffer layer for thin film solar cells (Eg ~ 2.42 eV)
  let wls = [
    350.0, 400.0, 450.0, 480.0, 500.0, 520.0, 550.0, 600.0, 700.0, 800.0, 1000.0,
  ]
  let n_arr = [2.28, 2.42, 2.65, 2.85, 2.70, 2.55, 2.48, 2.42, 2.36, 2.33, 2.30]
  let k_arr = [0.75, 0.60, 0.42, 0.25, 0.05, 0.002, 0.0, 0.0, 0.0, 0.0, 0.0]
  @disp.TabulatedDispersion::new("CdS", wls, n_arr, k_arr)
}

///|
pub fn get_zno_doped_azo_spectrum() -> @disp.TabulatedDispersion {
  // Aluminum-Doped Zinc Oxide (AZO) Transparent Conductive Oxide
  let wls = [
    350.0, 400.0, 450.0, 500.0, 550.0, 600.0, 700.0, 800.0, 900.0, 1000.0, 1200.0,
    1400.0, 1600.0, 1800.0, 2000.0,
  ]
  let n_arr = [
    1.95, 1.98, 1.95, 1.92, 1.90, 1.88, 1.84, 1.78, 1.70, 1.60, 1.38, 1.10, 0.82,
    0.58, 0.40,
  ]
  let k_arr = [
    0.12, 0.02, 0.005, 0.001, 0.001, 0.002, 0.008, 0.025, 0.065, 0.14, 0.38, 0.72,
    1.15, 1.62, 2.10,
  ]
  @disp.TabulatedDispersion::new("AZO_TCO", wls, n_arr, k_arr)
}

///|
pub fn get_fto_spectrum() -> @disp.TabulatedDispersion {
  // Fluorine-Doped Tin Oxide (FTO / SnO2:F) substrate
  let wls = [
    350.0, 400.0, 450.0, 500.0, 550.0, 600.0, 700.0, 800.0, 900.0, 1000.0, 1200.0,
    1400.0, 1600.0, 1800.0, 2000.0,
  ]
  let n_arr = [
    1.98, 2.02, 1.98, 1.95, 1.92, 1.89, 1.84, 1.76, 1.68, 1.58, 1.35, 1.12, 0.88,
    0.65, 0.48,
  ]
  let k_arr = [
    0.15, 0.03, 0.008, 0.002, 0.002, 0.004, 0.012, 0.035, 0.08, 0.16, 0.42, 0.78,
    1.22, 1.70, 2.20,
  ]
  @disp.TabulatedDispersion::new("FTO_TCO", wls, n_arr, k_arr)
}

///|
pub fn get_in_ga_as_spectrum() -> @disp.TabulatedDispersion {
  // In0.53Ga0.47As lattice-matched to InP for 1550nm optical receivers
  let wls = [
    800.0, 900.0, 1000.0, 1100.0, 1200.0, 1300.0, 1400.0, 1500.0, 1550.0, 1600.0,
    1700.0, 1800.0, 1900.0, 2000.0,
  ]
  let n_arr = [
    3.85, 3.78, 3.72, 3.68, 3.64, 3.61, 3.58, 3.56, 3.55, 3.54, 3.52, 3.50, 3.49,
    3.48,
  ]
  let k_arr = [
    0.65, 0.52, 0.40, 0.30, 0.22, 0.15, 0.08, 0.02, 0.005, 0.0, 0.0, 0.0, 0.0, 0.0,
  ]
  @disp.TabulatedDispersion::new("InGaAs", wls, n_arr, k_arr)
}
