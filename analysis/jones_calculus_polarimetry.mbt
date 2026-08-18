///|
/// Jones Calculus Polarimetry & Optical Retarder Engine
pub struct JonesVector {
  ex : @core.Complex
  ey : @core.Complex
} derive(Eq)

///|
pub fn JonesVector::linear_horizontal() -> JonesVector {
  { ex: @core.Complex::one(), ey: @core.Complex::zero() }
}

///|
pub fn JonesVector::linear_vertical() -> JonesVector {
  { ex: @core.Complex::zero(), ey: @core.Complex::one() }
}

///|
pub fn JonesVector::circular_right() -> JonesVector {
  let inv_sqrt2 = 0.70710678
  {
    ex: @core.Complex::from_real(inv_sqrt2),
    ey: @core.Complex::new(0.0, -inv_sqrt2),
  }
}

///|
/// 2x2 Complex Jones Optical Element Matrix
pub struct JonesMatrix {
  j00 : @core.Complex
  j01 : @core.Complex
  j10 : @core.Complex
  j11 : @core.Complex
} derive(Eq)

///|
pub fn JonesMatrix::quarter_wave_plate_fast_axis_x() -> JonesMatrix {
  // QWP: [ exp(i * pi / 4), 0 ; 0, exp(-i * pi / 4) ]
  let inv = 0.70710678
  {
    j00: @core.Complex::new(inv, inv),
    j01: @core.Complex::zero(),
    j10: @core.Complex::zero(),
    j11: @core.Complex::new(inv, -inv),
  }
}

///|
pub fn JonesMatrix::half_wave_plate_fast_axis_x() -> JonesMatrix {
  // HWP: [ -i, 0 ; 0, i ]
  {
    j00: @core.Complex::new(0.0, -1.0),
    j01: @core.Complex::zero(),
    j10: @core.Complex::zero(),
    j11: @core.Complex::new(0.0, 1.0),
  }
}

///|
/// Apply Jones Matrix to Input Jones Vector: E_out = J * E_in
pub fn JonesMatrix::apply(self : JonesMatrix, vin : JonesVector) -> JonesVector {
  let e_out_x = self.j00.mul(vin.ex).add(self.j01.mul(vin.ey))
  let e_out_y = self.j10.mul(vin.ex).add(self.j11.mul(vin.ey))
  { ex: e_out_x, ey: e_out_y }
}
