///|
/// Lu-Chipman Polar Decomposition for Experimental Mueller Matrices
pub struct LuChipmanDecompositionResult {
  diattenuation : Double // D in [0, 1]
  retardance_rad : Double // Total optical retardance R in radians
  depolarization_index : Double // P_Delta in [0, 1] (1 = completely non-depolarizing)
  polarimetric_entropy : Double // Entropy E in [0, 1] (0 = pure state, 1 = unpolarized noise)
} derive(Eq)

///|
pub impl Show for LuChipmanDecompositionResult with fn output(self, logger) {
  logger.write_string(
    "LuChipman(Diattenuation=\{self.diattenuation}, Retardance=\{self.retardance_rad * 180.0 / 3.14159}°, Depol_Index=\{self.depolarization_index})",
  )
}

///|
/// Perform Lu-Chipman Polar Decomposition on Experimental Mueller Matrix
pub fn decompose_mueller_matrix(
  m : MuellerMatrix,
) -> LuChipmanDecompositionResult {
  let m00 = m.m[0]
  if m00 <= 0.0 {
    return {
      diattenuation: 0.0,
      retardance_rad: 0.0,
      depolarization_index: 0.0,
      polarimetric_entropy: 1.0,
    }
  }

  // Diattenuation vector D = [m01, m02, m03] / m00
  let d1 = m.m[1] / m00
  let d2 = m.m[2] / m00
  let d3 = m.m[3] / m00
  let d_mag = (d1 * d1 + d2 * d2 + d3 * d3).sqrt()

  // Depolarization index P_Delta = sqrt( sum_{i,j} m_ij^2 - m_00^2 ) / (sqrt(3) * m_00)
  let mut sum_sq = 0.0
  for v in m.m {
    sum_sq = sum_sq + v * v
  }
  let diff_sq = sum_sq - m00 * m00
  let num_p = if diff_sq > 0.0 { diff_sq.sqrt() } else { 0.0 }
  let p_delta = num_p / (1.7320508 * m00)

  // Retardance estimate from trace of normalized 3x3 submatrix
  let tr = (m.m[5] + m.m[10] + m.m[15]) / m00
  let cos_r = 0.5 * (tr - 1.0)
  let cos_r_clamped = if cos_r < -1.0 {
    -1.0
  } else if cos_r > 1.0 {
    1.0
  } else {
    cos_r
  }
  let r_rad = @math.acos(cos_r_clamped)

  {
    diattenuation: if d_mag > 1.0 {
      1.0
    } else {
      d_mag
    },
    retardance_rad: r_rad,
    depolarization_index: if p_delta > 1.0 {
      1.0
    } else {
      p_delta
    },
    polarimetric_entropy: 1.0 - p_delta,
  }
}
