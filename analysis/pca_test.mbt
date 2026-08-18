///|
test "spectroscopic pca decomposition" {
  let s1 = [1.0, 2.0, 3.0, 4.0, 5.0]
  let s2 = [1.2, 2.1, 2.9, 4.2, 4.8]
  let s3 = [0.9, 1.9, 3.1, 3.8, 5.2]

  let pca_res = perform_spectral_pca([s1, s2, s3], 1)

  assert_eq(pca_res.mean_spectrum.length(), 5)
  assert_true(pca_res.principal_components.length() > 0)
}
