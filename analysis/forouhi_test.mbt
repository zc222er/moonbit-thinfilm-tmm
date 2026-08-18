///|
test "forouhi bloomer optical constants calculation" {
  let fb = ForouhiBloomerDispersion::new(1.85, 0.12, 4.2, 5.5, 2.0)
  let n_c = fb.get_complex_index(500.0)

  // 500 nm is 2.48 eV > 2.0 eV (in absorption band)
  assert_true(n_c.re > 1.5)
  assert_true(n_c.im > 0.0)
}
