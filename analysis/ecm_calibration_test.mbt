///|
test "mueller matrix ecm calibration" {
  let m_id = MuellerMatrix::identity()
  let calib = MuellerCalibrationParameters::ideal()
  let m_cal = calibrate_raw_mueller_matrix(m_id, calib)

  assert_true((m_cal.m[0] - 1.0).abs() < 1.0e-5)
  assert_true((m_cal.m[5] - 1.0).abs() < 1.0e-5)
}
