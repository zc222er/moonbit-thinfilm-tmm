///|
test "artmann goos hanchen spatial shift" {
  // Glass (n1=1.50) / Air (n2=1.00) interface at 60 deg (> critical angle 41.8 deg)
  let gh = calculate_goos_hanchen_shift(1.50, 1.00, 60.0, 632.8)

  assert_true(gh.shift_te_nm > 50.0)
  assert_true(gh.shift_tm_nm > gh.shift_te_nm) // S_TM > S_TE
  assert_true(gh.ratio_tm_te > 1.0)
}
