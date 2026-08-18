///|
// ============================================================================
// Photonic Liquid Crystals (5CB, E7) Birefringence Database
// Temperature and wavelength dependent ordinary (no) and extraordinary (ne) indices
// ============================================================================

///|
pub struct LiquidCrystalBirefringence {
  name : String
  no_cauchy_a : Double
  no_cauchy_b : Double
  ne_cauchy_a : Double
  ne_cauchy_b : Double
} derive(Eq)

///|
pub fn e7_liquid_crystal() -> LiquidCrystalBirefringence {
  // E7 nematic liquid crystal mixture (Delta n ~ 0.22 at 589nm, 20 °C)
  {
    name: "E7 (Nematic Mixture)",
    no_cauchy_a: 1.503,
    no_cauchy_b: 0.0075,
    ne_cauchy_a: 1.705,
    ne_cauchy_b: 0.0155,
  }
}

///|
pub fn five_cb_liquid_crystal() -> LiquidCrystalBirefringence {
  // 5CB (4-cyano-4'-pentylbiphenyl) single component LC (Delta n ~ 0.18 at 25 °C)
  {
    name: "5CB (Pentylcyanobiphenyl)",
    no_cauchy_a: 1.512,
    no_cauchy_b: 0.0080,
    ne_cauchy_a: 1.685,
    ne_cauchy_b: 0.0162,
  }
}

///|
/// Get Ordinary Refractive Index n_o(lambda)
pub fn LiquidCrystalBirefringence::get_no(
  self : LiquidCrystalBirefringence,
  wavelength_nm : Double,
) -> Double {
  let wl_um = wavelength_nm / 1000.0
  self.no_cauchy_a + self.no_cauchy_b / (wl_um * wl_um)
}

///|
/// Get Extraordinary Refractive Index n_e(lambda)
pub fn LiquidCrystalBirefringence::get_ne(
  self : LiquidCrystalBirefringence,
  wavelength_nm : Double,
) -> Double {
  let wl_um = wavelength_nm / 1000.0
  self.ne_cauchy_a + self.ne_cauchy_b / (wl_um * wl_um)
}
