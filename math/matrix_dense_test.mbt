///|
test "matrix qr decomposition orthogonality" {
  let a = Matrix::zeros(3, 3)
  a.set(0, 0, 12.0)
  a.set(0, 1, -51.0)
  a.set(0, 2, 4.0)
  a.set(1, 0, 6.0)
  a.set(1, 1, 167.0)
  a.set(1, 2, -68.0)
  a.set(2, 0, -4.0)
  a.set(2, 1, 24.0)
  a.set(2, 2, -41.0)

  let qr = a.qr_decompose()
  // Q^T * Q should be Identity
  let qt = qr.q.transpose()
  let qt_q = qt.mul(qr.q)

  assert_true((qt_q.get(0, 0) - 1.0).abs() < 1.0e-5)
  assert_true((qt_q.get(1, 1) - 1.0).abs() < 1.0e-5)
  assert_true((qt_q.get(2, 2) - 1.0).abs() < 1.0e-5)
  assert_true(qt_q.get(0, 1).abs() < 1.0e-5)
}

///|
test "power iteration dominant eigenvalue" {
  let a = Matrix::zeros(2, 2)
  a.set(0, 0, 2.0)
  a.set(0, 1, 1.0)
  a.set(1, 0, 1.0)
  a.set(1, 1, 2.0)

  let (lambda, _) = a.dominant_eigenvalue(50, 1.0e-7)
  // Eigenvalues of [[2,1],[1,2]] are 3.0 and 1.0
  assert_true((lambda - 3.0).abs() < 0.01)
}
