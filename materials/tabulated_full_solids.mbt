///|
// ============================================================================
// Phase-Change Optical Materials (VO2, GST-225) & Photonic Compounds
// Dynamic reconfigurable optical constants across thermal & optical transitions
// ============================================================================

///|
pub fn vanadium_dioxide_insulating_phase() -> @disp.TabulatedDispersion {
  // VO2 Monoclinic Semiconductor / Insulating Phase (T < 68 °C / 341 K)
  let wls = [
    400.0, 500.0, 600.0, 700.0, 800.0, 900.0, 1000.0, 1200.0, 1500.0, 2000.0, 2500.0,
  ]
  let n_arr = [2.85, 3.10, 3.25, 3.18, 3.05, 2.95, 2.88, 2.80, 2.75, 2.70, 2.68]
  let k_arr = [0.85, 0.58, 0.42, 0.32, 0.28, 0.26, 0.25, 0.25, 0.28, 0.35, 0.42]
  @disp.TabulatedDispersion::new("VO2_Insulating", wls, n_arr, k_arr)
}

///|
pub fn vanadium_dioxide_metallic_phase() -> @disp.TabulatedDispersion {
  // VO2 Rutile Metallic Phase (T > 68 °C / 341 K) - high IR reflectance
  let wls = [
    400.0, 500.0, 600.0, 700.0, 800.0, 900.0, 1000.0, 1200.0, 1500.0, 2000.0, 2500.0,
  ]
  let n_arr = [2.40, 2.25, 2.10, 1.95, 1.82, 1.70, 1.58, 1.35, 1.10, 0.85, 0.65]
  let k_arr = [0.95, 1.15, 1.45, 1.78, 2.10, 2.45, 2.80, 3.45, 4.35, 5.75, 7.10]
  @disp.TabulatedDispersion::new("VO2_Metallic", wls, n_arr, k_arr)
}

///|
pub fn gst225_amorphous_phase() -> @disp.TabulatedDispersion {
  // Ge2Sb2Te5 (GST) Amorphous Phase for non-volatile optical memory & switches
  let wls = [400.0, 500.0, 600.0, 700.0, 800.0, 1000.0, 1310.0, 1550.0, 2000.0]
  let n_arr = [3.25, 3.85, 4.25, 4.35, 4.30, 4.15, 3.98, 3.92, 3.85]
  let k_arr = [2.15, 1.65, 1.05, 0.62, 0.35, 0.12, 0.02, 0.005, 0.0]
  @disp.TabulatedDispersion::new("GST225_Amorphous", wls, n_arr, k_arr)
}

///|
pub fn gst225_crystalline_phase() -> @disp.TabulatedDispersion {
  // Ge2Sb2Te5 (GST) Crystalline Phase (Large index contrast Delta n > 2.5)
  let wls = [400.0, 500.0, 600.0, 700.0, 800.0, 1000.0, 1310.0, 1550.0, 2000.0]
  let n_arr = [2.85, 3.65, 4.55, 5.45, 6.10, 6.65, 6.75, 6.70, 6.55]
  let k_arr = [3.45, 3.10, 2.75, 2.35, 1.95, 1.35, 0.85, 0.62, 0.35]
  @disp.TabulatedDispersion::new("GST225_Crystalline", wls, n_arr, k_arr)
}

///|
pub fn gallium_phosphide_gap() -> OpticalMaterial {
  // GaP high refractive index visible photonic crystal semiconductor (Eg ~ 2.26 eV)
  let sell = @disp.Sellmeier3Dispersion::new(
    6.435,
    0.2858 * 0.2858,
    0.0,
    0.0,
    1.90,
    25.0 * 25.0,
  )
  {
    name: "GaP (Gallium Phosphide)",
    category: MaterialCategory::Semiconductor,
    formula: "GaP",
    bandgap_ev: 2.26,
    dispersion_fn: fn(wl) { sell.get_complex_index(wl) },
  }
}
