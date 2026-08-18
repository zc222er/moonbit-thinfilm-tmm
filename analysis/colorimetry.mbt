///|
/// CIE 1931 2-degree Standard Color Matching Functions and D65 Illuminant
pub struct CIEColorMatchPoint {
  wl_nm : Double
  x_bar : Double
  y_bar : Double
  z_bar : Double
  d65 : Double
} derive(Eq)

///|
/// CIE 1931 Tabulated Standard Observer at 20nm steps (380 - 780 nm)
pub fn get_cie_table() -> Array[CIEColorMatchPoint] {
  [
    { wl_nm: 380.0, x_bar: 0.0014, y_bar: 0.0000, z_bar: 0.0065, d65: 50.0 },
    { wl_nm: 400.0, x_bar: 0.0143, y_bar: 0.0004, z_bar: 0.0679, d65: 82.8 },
    { wl_nm: 420.0, x_bar: 0.1344, y_bar: 0.0040, z_bar: 0.6456, d65: 93.4 },
    { wl_nm: 440.0, x_bar: 0.3483, y_bar: 0.0230, z_bar: 1.7471, d65: 104.9 },
    { wl_nm: 460.0, x_bar: 0.2908, y_bar: 0.0600, z_bar: 1.6692, d65: 117.8 },
    { wl_nm: 480.0, x_bar: 0.0956, y_bar: 0.1390, z_bar: 0.8130, d65: 115.9 },
    { wl_nm: 500.0, x_bar: 0.0049, y_bar: 0.3230, z_bar: 0.2720, d65: 109.4 },
    { wl_nm: 520.0, x_bar: 0.0633, y_bar: 0.7100, z_bar: 0.0782, d65: 104.8 },
    { wl_nm: 540.0, x_bar: 0.2904, y_bar: 0.9540, z_bar: 0.0203, d65: 104.4 },
    { wl_nm: 560.0, x_bar: 0.5945, y_bar: 0.9950, z_bar: 0.0039, d65: 100.0 },
    { wl_nm: 580.0, x_bar: 0.9163, y_bar: 0.8700, z_bar: 0.0017, d65: 95.8 },
    { wl_nm: 600.0, x_bar: 1.0622, y_bar: 0.6310, z_bar: 0.0008, d65: 90.0 },
    { wl_nm: 620.0, x_bar: 0.8544, y_bar: 0.3810, z_bar: 0.0002, d65: 87.7 },
    { wl_nm: 640.0, x_bar: 0.4479, y_bar: 0.1750, z_bar: 0.0000, d65: 83.7 },
    { wl_nm: 660.0, x_bar: 0.1649, y_bar: 0.0610, z_bar: 0.0000, d65: 80.2 },
    { wl_nm: 680.0, x_bar: 0.0468, y_bar: 0.0170, z_bar: 0.0000, d65: 78.3 },
    { wl_nm: 700.0, x_bar: 0.0114, y_bar: 0.0041, z_bar: 0.0000, d65: 71.6 },
    { wl_nm: 720.0, x_bar: 0.0029, y_bar: 0.0010, z_bar: 0.0000, d65: 61.6 },
    { wl_nm: 740.0, x_bar: 0.0007, y_bar: 0.0002, z_bar: 0.0000, d65: 70.3 },
    { wl_nm: 760.0, x_bar: 0.0002, y_bar: 0.0001, z_bar: 0.0000, d65: 63.6 },
    { wl_nm: 780.0, x_bar: 0.0000, y_bar: 0.0000, z_bar: 0.0000, d65: 61.0 },
  ]
}

///|
/// CIE Tristimulus Values (X, Y, Z) and Chromaticity (x, y)
pub struct CIEXYZColor {
  x_val : Double
  y_val : Double
  z_val : Double
  chroma_x : Double
  chroma_y : Double
  srgb_r : Int // 0 - 255
  srgb_g : Int // 0 - 255
  srgb_b : Int // 0 - 255
  hex_code : String
} derive(Eq)

///|
pub impl Show for CIEXYZColor with fn output(self, logger) {
  logger.write_string(
    "Color(xy=[\{self.chroma_x}, \{self.chroma_y}], RGB=[\{self.srgb_r}, \{self.srgb_g}, \{self.srgb_b}], hex=\{self.hex_code})",
  )
}

///|
fn hex_byte(val : Int) -> String {
  let clamped = if val < 0 { 0 } else if val > 255 { 255 } else { val }
  let hex_chars = [
    "0", "1", "2", "3", "4", "5", "6", "7", "8", "9", "A", "B", "C", "D", "E", "F",
  ]
  let hi = clamped / 16
  let lo = clamped % 16
  hex_chars[hi] + hex_chars[lo]
}

///|
/// Convert Reflectance / Transmittance Spectrum to CIE 1931 XYZ and sRGB Color
pub fn spectrum_to_color(spectrum : @core.SpectrumData) -> CIEXYZColor {
  let table = get_cie_table()
  let n = table.length()

  let wls = Array::new(capacity=n)
  let f_x = Array::new(capacity=n)
  let f_y = Array::new(capacity=n)
  let f_z = Array::new(capacity=n)
  let f_k = Array::new(capacity=n)

  for pt in table {
    let r_val = spectrum.interpolate_linear(pt.wl_nm)
    wls.push(pt.wl_nm)
    f_x.push(r_val * pt.d65 * pt.x_bar)
    f_y.push(r_val * pt.d65 * pt.y_bar)
    f_z.push(r_val * pt.d65 * pt.z_bar)
    f_k.push(pt.d65 * pt.y_bar)
  }

  let k_norm = @linalg.simpson_rule(wls, f_k)
  let norm_factor = if k_norm > 0.0 { 100.0 / k_norm } else { 1.0 }

  let x_val = @linalg.simpson_rule(wls, f_x) * norm_factor
  let y_val = @linalg.simpson_rule(wls, f_y) * norm_factor
  let z_val = @linalg.simpson_rule(wls, f_z) * norm_factor

  let sum_xyz = x_val + y_val + z_val
  let chroma_x = if sum_xyz > 0.0 { x_val / sum_xyz } else { 0.3127 }
  let chroma_y = if sum_xyz > 0.0 { y_val / sum_xyz } else { 0.3290 }

  // CIE XYZ to Linear RGB (D65 illuminant, 2 deg observer)
  let x_n = x_val / 100.0
  let y_n = y_val / 100.0
  let z_n = z_val / 100.0

  let r_lin = 3.2404542 * x_n - 1.5371385 * y_n - 0.4985314 * z_n
  let g_lin = -0.9692660 * x_n + 1.8760108 * y_n + 0.0415560 * z_n
  let b_lin = 0.0556434 * x_n - 0.2040259 * y_n + 1.0572252 * z_n

  // sRGB gamma correction
  let gamma_correct = fn(c : Double) -> Double {
    let c_clamp = if c < 0.0 { 0.0 } else if c > 1.0 { 1.0 } else { c }
    if c_clamp <= 0.0031308 {
      12.92 * c_clamp
    } else {
      1.055 * @math.pow(c_clamp, 1.0 / 2.4) - 0.055
    }
  }

  let r_srgb = (gamma_correct(r_lin) * 255.0 + 0.5).to_int()
  let g_srgb = (gamma_correct(g_lin) * 255.0 + 0.5).to_int()
  let b_srgb = (gamma_correct(b_lin) * 255.0 + 0.5).to_int()

  let hex_code = "#" + hex_byte(r_srgb) + hex_byte(g_srgb) + hex_byte(b_srgb)

  {
    x_val,
    y_val,
    z_val,
    chroma_x,
    chroma_y,
    srgb_r: r_srgb,
    srgb_g: g_srgb,
    srgb_b: b_srgb,
    hex_code,
  }
}
