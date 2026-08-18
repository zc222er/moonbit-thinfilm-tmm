///|
/// Stokes Vector (S0, S1, S2, S3)
pub struct StokesVector {
  s0 : Double // Total intensity I
  s1 : Double // Linear horizontal vs vertical preference (Q)
  s2 : Double // Linear +45 deg vs -45 deg preference (U)
  s3 : Double // Circular right vs left handed preference (V)
} derive(Eq, Default)

///|
pub impl Show for StokesVector with fn output(self, logger) {
  logger.write_string(
    "Stokes([S0=\{self.s0}, S1=\{self.s1}, S2=\{self.s2}, S3=\{self.s3}])",
  )
}

///|
pub fn StokesVector::unpolarized(intensity : Double) -> StokesVector {
  { s0: intensity, s1: 0.0, s2: 0.0, s3: 0.0 }
}

///|
pub fn StokesVector::linear_horizontal(intensity : Double) -> StokesVector {
  { s0: intensity, s1: intensity, s2: 0.0, s3: 0.0 }
}

///|
pub fn StokesVector::linear_vertical(intensity : Double) -> StokesVector {
  { s0: intensity, s1: -intensity, s2: 0.0, s3: 0.0 }
}

///|
pub fn StokesVector::circular_right(intensity : Double) -> StokesVector {
  { s0: intensity, s1: 0.0, s2: 0.0, s3: intensity }
}

///|
/// Degree of Total Polarization (DOP): sqrt(S1^2 + S2^2 + S3^2) / S0
pub fn StokesVector::degree_of_polarization(self : StokesVector) -> Double {
  if self.s0 <= 0.0 {
    0.0
  } else {
    let p_sq = self.s1 * self.s1 + self.s2 * self.s2 + self.s3 * self.s3
    p_sq.sqrt() / self.s0
  }
}

///|
/// Degree of Linear Polarization (DoLP): sqrt(S1^2 + S2^2) / S0
pub fn StokesVector::degree_of_linear_polarization(
  self : StokesVector,
) -> Double {
  if self.s0 <= 0.0 {
    0.0
  } else {
    let p_sq = self.s1 * self.s1 + self.s2 * self.s2
    p_sq.sqrt() / self.s0
  }
}

///|
/// Degree of Circular Polarization (DoCP): |S3| / S0
pub fn StokesVector::degree_of_circular_polarization(
  self : StokesVector,
) -> Double {
  if self.s0 <= 0.0 {
    0.0
  } else {
    self.s3.abs() / self.s0
  }
}

///|
/// 4x4 Mueller Matrix representation
pub struct MuellerMatrix {
  m : Array[Double] // 16 elements (4x4 flattened row-major)
} derive(Eq)

///|
pub fn MuellerMatrix::identity() -> MuellerMatrix {
  let arr = [
    1.0, 0.0, 0.0, 0.0, 0.0, 1.0, 0.0, 0.0, 0.0, 0.0, 1.0, 0.0, 0.0, 0.0, 0.0, 1.0,
  ]
  { m: arr }
}

///|
/// Transform Stokes vector through Mueller matrix: S_out = M * S_in
pub fn MuellerMatrix::transform(
  self : MuellerMatrix,
  s : StokesVector,
) -> StokesVector {
  let s0_out = self.m[0] * s.s0 +
    self.m[1] * s.s1 +
    self.m[2] * s.s2 +
    self.m[3] * s.s3
  let s1_out = self.m[4] * s.s0 +
    self.m[5] * s.s1 +
    self.m[6] * s.s2 +
    self.m[7] * s.s3
  let s2_out = self.m[8] * s.s0 +
    self.m[9] * s.s1 +
    self.m[10] * s.s2 +
    self.m[11] * s.s3
  let s3_out = self.m[12] * s.s0 +
    self.m[13] * s.s1 +
    self.m[14] * s.s2 +
    self.m[15] * s.s3
  { s0: s0_out, s1: s1_out, s2: s2_out, s3: s3_out }
}
