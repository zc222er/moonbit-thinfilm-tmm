///|
/// Render ASCII Graph of SpectrumData in Terminal
pub fn render_ascii_spectrum(
  spectrum : @core.SpectrumData,
  width : Int,
  height : Int,
) -> String {
  let w = if width < 20 { 60 } else { width }
  let h = if height < 5 { 15 } else { height }

  let grid = spectrum.grid
  let count = grid.count()
  if count == 0 {
    return "(Empty Spectrum)"
  }

  let wl_start = grid.get(0)
  let wl_end = grid.get(count - 1)

  // Find min and max value
  let mut min_val = spectrum.get(0)
  let mut max_val = spectrum.get(0)
  for i = 1; i < count; i = i + 1 {
    let v = spectrum.get(i)
    if v < min_val {
      min_val = v
    }
    if v > max_val {
      max_val = v
    }
  }

  if max_val - min_val < 1.0e-5 {
    max_val = min_val + 1.0
  }

  let sb = StringBuilder()
  sb.write_string("==== Spectrum Plot: \{spectrum.name} ====\n")

  // Create canvas (h rows x w cols)
  let canvas = Array::new(capacity=h)
  for _r = 0; _r < h; _r = _r + 1 {
    let row_chars = Array::new(capacity=w)
    for _c = 0; _c < w; _c = _c + 1 {
      row_chars.push(" ")
    }
    canvas.push(row_chars)
  }

  // Plot data points
  for c = 0; c < w; c = c + 1 {
    let target_wl = wl_start +
      (wl_end - wl_start) * (c.to_double() / (w.to_double() - 1.0))
    let val = spectrum.interpolate_linear(target_wl)
    let norm_val = (val - min_val) / (max_val - min_val)
    let mut row_idx = (norm_val * (h.to_double() - 1.0) + 0.5).to_int()
    if row_idx < 0 {
      row_idx = 0
    }
    if row_idx >= h {
      row_idx = h - 1
    }
    let flipped_r = h - 1 - row_idx
    canvas[flipped_r][c] = "*"
  }

  // Render canvas with Y-axis
  for r = 0; r < h; r = r + 1 {
    let y_val = max_val -
      (max_val - min_val) * (r.to_double() / (h.to_double() - 1.0))
    let y_str = if y_val >= 0.0 && y_val < 10.0 { " " } else { "" }
    sb.write_string("\{y_str}\{y_val} | ")
    for c = 0; c < w; c = c + 1 {
      sb.write_string(canvas[r][c])
    }
    sb.write_string("\n")
  }

  // X-axis
  sb.write_string("        +")
  for _c = 0; _c < w; _c = _c + 1 {
    sb.write_string("-")
  }
  sb.write_string("\n")
  sb.write_string("        \{wl_start} nm")
  let mid_spaces = w - 24
  for _s = 0; _s < mid_spaces; _s = _s + 1 {
    sb.write_string(" ")
  }
  sb.write_string("\{wl_end} nm\n")

  sb.to_string()
}
