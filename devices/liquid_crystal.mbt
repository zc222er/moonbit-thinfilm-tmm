///|
/// Liquid Crystal Cell Director Distribution & Electro-Optic Modulator
pub struct LiquidCrystalCell {
  cell_gap_um : Double // Cell thickness d (typically 3 - 5 um)
  ordinary_index : Double // n_o
  extraordinary_index : Double // n_e
  twist_angle_deg : Double // 90 deg for TN, 0 deg for ECB / VA
  pretilt_angle_deg : Double // Surface pretilt (typically 1 - 3 deg)
}

///|
pub fn LiquidCrystalCell::new(
  cell_gap : Double,
  no : Double,
  ne : Double,
  twist : Double,
  pretilt : Double,
) -> LiquidCrystalCell {
  {
    cell_gap_um: cell_gap,
    ordinary_index: no,
    extraordinary_index: ne,
    twist_angle_deg: twist,
    pretilt_angle_deg: pretilt,
  }
}

///|
/// Calculate Optical Phase Retardation Gamma = 2 * pi * Delta_n * d / lambda
pub fn LiquidCrystalCell::optical_retardation_rad(
  self : LiquidCrystalCell,
  wavelength_nm : Double,
) -> Double {
  let delta_n = (self.extraordinary_index - self.ordinary_index).abs()
  let d_nm = self.cell_gap_um * 1000.0
  2.0 * @math.PI * delta_n * d_nm / wavelength_nm
}

///|
/// Discretize continuous Twisted Nematic LC profile into N sliced uniaxial sublayers
pub fn LiquidCrystalCell::discretize_slices(
  self : LiquidCrystalCell,
  voltage_v : Double,
  num_slices : Int,
) -> Array[(@core.Complex, @core.Complex, Double, Double, Double)] {
  let n = if num_slices < 5 { 10 } else { num_slices }
  let d_sub_nm = self.cell_gap_um * 1000.0 / n.to_double()
  let no_c = @core.Complex::from_real(self.ordinary_index)
  let ne_c = @core.Complex::from_real(self.extraordinary_index)

  let slices = Array::new(capacity=n)
  let v_norm = if voltage_v > 1.0 { (voltage_v - 1.0) / 4.0 } else { 0.0 }
  let max_tilt = if v_norm > 1.0 {
    85.0
  } else {
    self.pretilt_angle_deg + (85.0 - self.pretilt_angle_deg) * v_norm
  }

  for i = 0; i < n; i = i + 1 {
    let z_norm = (i.to_double() + 0.5) / n.to_double()
    let twist_rad = self.twist_angle_deg * @math.PI / 180.0 * z_norm
    let tilt_rad = (
        max_tilt * @math.sin(@math.PI * z_norm) + self.pretilt_angle_deg
      ) *
      @math.PI /
      180.0

    slices.push((no_c, ne_c, tilt_rad, twist_rad, d_sub_nm))
  }

  slices
}
