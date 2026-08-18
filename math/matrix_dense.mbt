///|
/// Dense Matrix QR Decomposition (A = Q * R) using Modified Gram-Schmidt Orthonormalization
pub struct QRDecomposition {
  q : Matrix
  r : Matrix
}

///|
pub fn Matrix::qr_decompose(self : Matrix) -> QRDecomposition {
  let m = self.rows
  let n = self.cols
  let q_mat = Matrix::zeros(m, n)
  let r_mat = Matrix::zeros(n, n)

  // Copy columns of self into v vectors
  let v = Matrix::zeros(m, n)
  for i = 0; i < m; i = i + 1 {
    for j = 0; j < n; j = j + 1 {
      v.set(i, j, self.get(i, j))
    }
  }

  for j = 0; j < n; j = j + 1 {
    // r_jj = ||v_j||
    let mut norm_sq = 0.0
    for i = 0; i < m; i = i + 1 {
      let val = v.get(i, j)
      norm_sq = norm_sq + val * val
    }
    let norm = norm_sq.sqrt()
    r_mat.set(j, j, norm)

    if norm > 1.0e-14 {
      for i = 0; i < m; i = i + 1 {
        q_mat.set(i, j, v.get(i, j) / norm)
      }
    }

    for k = j + 1; k < n; k = k + 1 {
      // r_jk = q_j^T * v_k
      let mut dot = 0.0
      for i = 0; i < m; i = i + 1 {
        dot = dot + q_mat.get(i, j) * v.get(i, k)
      }
      r_mat.set(j, k, dot)

      // v_k = v_k - r_jk * q_j
      for i = 0; i < m; i = i + 1 {
        let new_v = v.get(i, k) - dot * q_mat.get(i, j)
        v.set(i, k, new_v)
      }
    }
  }

  { q: q_mat, r: r_mat }
}

///|
/// Compute Dominant Eigenvalue and Eigenvector using Power Iteration
pub fn Matrix::dominant_eigenvalue(
  self : Matrix,
  max_iter : Int,
  tol : Double,
) -> (Double, Array[Double]) {
  let n = self.rows
  let mut x = Array::new(capacity=n)
  for _i = 0; _i < n; _i = _i + 1 {
    x.push(1.0)
  }

  let mut lambda = 0.0
  let mut iter = 0

  while iter < max_iter {
    iter = iter + 1
    // y = A * x
    let y = self.mul_vec(x)

    // Compute norm of y
    let mut norm_sq = 0.0
    for v in y {
      norm_sq = norm_sq + v * v
    }
    let norm = norm_sq.sqrt()

    if norm < 1.0e-14 {
      break
    }

    let new_lambda = norm
    let diff = (new_lambda - lambda).abs()

    let new_x = Array::new(capacity=n)
    for v in y {
      new_x.push(v / norm)
    }

    x = new_x
    lambda = new_lambda

    if diff < tol {
      break
    }
  }

  (lambda, x)
}
