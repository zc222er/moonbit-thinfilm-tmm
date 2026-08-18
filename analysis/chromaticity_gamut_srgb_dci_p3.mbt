///|
/// Display Color Gamut Coverage Engine (sRGB, DCI-P3, BT.2020)
pub struct DisplayGamutCoverage {
  srgb_coverage_percent : Double
  dci_p3_coverage_percent : Double
  bt2020_coverage_percent : Double
  correlated_color_temp_k : Double
} derive(Eq)

///|
pub fn DisplayGamutCoverage::new(
  srgb : Double,
  p3 : Double,
  bt : Double,
  cct : Double,
) -> DisplayGamutCoverage {
  {
    srgb_coverage_percent: srgb,
    dci_p3_coverage_percent: p3,
    bt2020_coverage_percent: bt,
    correlated_color_temp_k: cct,
  }
}

///|
pub impl Show for DisplayGamutCoverage with fn output(self, logger) {
  logger.write_string(
    "GamutCoverage(sRGB=\{self.srgb_coverage_percent}%, DCI-P3=\{self.dci_p3_coverage_percent}%, BT.2020=\{self.bt2020_coverage_percent}%, CCT=\{self.correlated_color_temp_k} K)",
  )
}

///|
/// McCamy Correlated Color Temperature (CCT) Formula from (x, y) chromaticity
pub fn calculate_cct_mccamy(x : Double, y : Double) -> Double {
  let xe = 0.3320
  let ye = 0.1858
  let denom = y - ye
  if denom.abs() < 1.0e-5 {
    6500.0
  } else {
    let n = (x - xe) / denom
    let n3 = n * n * n
    let n2 = n * n
    449.0 * n3 + 3525.0 * n2 + 6823.3 * n + 5520.33
  }
}

///|
/// Triangle Area in CIE (x,y) Chromaticity Space
pub fn calculate_gamut_triangle_area(
  rx : Double,
  ry : Double,
  gx : Double,
  gy : Double,
  bx : Double,
  by : Double,
) -> Double {
  0.5 * (rx * (gy - by) + gx * (by - ry) + bx * (ry - gy)).abs()
}
