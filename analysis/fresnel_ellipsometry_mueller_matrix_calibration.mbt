///|
/// Dual-Rotating Compensator Mueller Matrix Ellipsometer Eigenvalue Calibration Method (ECM)
pub struct MuellerCalibrationParameters {
  polarizer_azimuth_error_deg : Double
  analyzer_azimuth_error_deg : Double
  compensator_1_retardance_deg : Double
  compensator_2_retardance_deg : Double
} derive(Eq)

///|
pub fn MuellerCalibrationParameters::ideal() -> MuellerCalibrationParameters {
  {
    polarizer_azimuth_error_deg: 0.0,
    analyzer_azimuth_error_deg: 0.0,
    compensator_1_retardance_deg: 127.0, // Optimum achromatic retardance
    compensator_2_retardance_deg: 127.0,
  }
}

///|
/// Calibrate Normalized Experimental 4x4 Mueller Matrix
pub fn calibrate_raw_mueller_matrix(
  raw_matrix : MuellerMatrix,
  calib : MuellerCalibrationParameters,
) -> MuellerMatrix {
  let m00 = raw_matrix.m[0]
  if m00 <= 0.0 {
    return raw_matrix
  }

  // Normalize by m00
  let norm_m = Array::new(capacity=16)
  for i = 0; i < 16; i = i + 1 {
    norm_m.push(raw_matrix.m[i] / m00)
  }

  // Apply small angular corrections (first-order Taylor expansion)
  let p_err_rad = calib.polarizer_azimuth_error_deg * @math.PI / 180.0
  norm_m[1] = norm_m[1] - 2.0 * p_err_rad * norm_m[2]
  norm_m[2] = norm_m[2] + 2.0 * p_err_rad * norm_m[1]

  { m: norm_m }
}
