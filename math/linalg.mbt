///|
/// Real Matrix struct with arbitrary dimensions (M x N)
pub struct Matrix {
  rows : Int
  cols : Int
  data : Array[Double]
} derive(Eq)

///|
pub impl Show for Matrix with fn output(self, logger) {
  logger.write_string("Matrix(\{self.rows}x\{self.cols})[\n")
  for r = 0; r < self.rows; r = r + 1 {
    logger.write_string("  [")
    for c = 0; c < self.cols; c = c + 1 {
      logger.write_string("\{self.get(r, c)}")
      if c < self.cols - 1 {
        logger.write_string(", ")
      }
    }
    logger.write_string("]\n")
  }
  logger.write_string("]")
}

///|
pub fn Matrix::zeros(rows : Int, cols : Int) -> Matrix {
  let size = rows * cols
  let data = Array::new(capacity=size)
  for i = 0; i < size; i = i + 1 {
    data.push(0.0)
  }
  { rows, cols, data }
}

///|
pub fn Matrix::identity(n : Int) -> Matrix {
  let m = Matrix::zeros(n, n)
  for i = 0; i < n; i = i + 1 {
    m.set(i, i, 1.0)
  }
  m
}

///|
pub fn Matrix::from_array2d(arr : Array[Array[Double]]) -> Matrix {
  let rows = arr.length()
  if rows == 0 {
    return Matrix::zeros(0, 0)
  }
  let cols = arr[0].length()
  let m = Matrix::zeros(rows, cols)
  for r = 0; r < rows; r = r + 1 {
    for c = 0; c < cols; c = c + 1 {
      m.set(r, c, arr[r][c])
    }
  }
  m
}

///|
pub fn Matrix::get(self : Matrix, r : Int, c : Int) -> Double {
  self.data[r * self.cols + c]
}

///|
pub fn Matrix::set(self : Matrix, r : Int, c : Int, val : Double) -> Unit {
  self.data[r * self.cols + c] = val
}

///|
pub fn Matrix::clone(self : Matrix) -> Matrix {
  { rows: self.rows, cols: self.cols, data: self.data.copy() }
}

///|
pub fn Matrix::add(self : Matrix, other : Matrix) -> Matrix {
  let res = Matrix::zeros(self.rows, self.cols)
  for i = 0; i < self.data.length(); i = i + 1 {
    res.data[i] = self.data[i] + other.data[i]
  }
  res
}

///|
pub fn Matrix::sub(self : Matrix, other : Matrix) -> Matrix {
  let res = Matrix::zeros(self.rows, self.cols)
  for i = 0; i < self.data.length(); i = i + 1 {
    res.data[i] = self.data[i] - other.data[i]
  }
  res
}

///|
pub fn Matrix::scale(self : Matrix, s : Double) -> Matrix {
  let res = Matrix::zeros(self.rows, self.cols)
  for i = 0; i < self.data.length(); i = i + 1 {
    res.data[i] = self.data[i] * s
  }
  res
}

///|
pub fn Matrix::mul(self : Matrix, other : Matrix) -> Matrix {
  let res = Matrix::zeros(self.rows, other.cols)
  for r = 0; r < self.rows; r = r + 1 {
    for c = 0; c < other.cols; c = c + 1 {
      let mut sum = 0.0
      for k = 0; k < self.cols; k = k + 1 {
        sum = sum + self.get(r, k) * other.get(k, c)
      }
      res.set(r, c, sum)
    }
  }
  res
}

///|
pub fn Matrix::transpose(self : Matrix) -> Matrix {
  let res = Matrix::zeros(self.cols, self.rows)
  for r = 0; r < self.rows; r = r + 1 {
    for c = 0; c < self.cols; c = c + 1 {
      res.set(c, r, self.get(r, c))
    }
  }
  res
}

///|
pub fn Matrix::mul_vec(self : Matrix, v : Array[Double]) -> Array[Double] {
  let res = Array::new(capacity=self.rows)
  for r = 0; r < self.rows; r = r + 1 {
    let mut sum = 0.0
    for c = 0; c < self.cols; c = c + 1 {
      sum = sum + self.get(r, c) * v[c]
    }
    res.push(sum)
  }
  res
}

///|
/// LU Decomposition with partial pivoting
pub struct LUDecomposition {
  lu : Matrix
  pivots : Array[Int]
  num_swaps : Int
} derive(Eq)

///|
pub fn Matrix::lu_decompose(self : Matrix) -> LUDecomposition {
  let n = self.rows
  let lu = self.clone()
  let pivots = Array::new(capacity=n)
  for i = 0; i < n; i = i + 1 {
    pivots.push(i)
  }
  let mut swaps = 0

  for i = 0; i < n; i = i + 1 {
    let mut max_row = i
    let mut max_val = lu.get(i, i).abs()
    for k = i + 1; k < n; k = k + 1 {
      let val = lu.get(k, i).abs()
      if val > max_val {
        max_val = val
        max_row = k
      }
    }

    if max_row != i {
      // Swap rows in LU
      for c = 0; c < n; c = c + 1 {
        let tmp = lu.get(i, c)
        lu.set(i, c, lu.get(max_row, c))
        lu.set(max_row, c, tmp)
      }
      // Swap pivots
      let tmp_p = pivots[i]
      pivots[i] = pivots[max_row]
      pivots[max_row] = tmp_p
      swaps = swaps + 1
    }

    let diag = lu.get(i, i)
    if diag.abs() > 1.0e-14 {
      for j = i + 1; j < n; j = j + 1 {
        let factor = lu.get(j, i) / diag
        lu.set(j, i, factor)
        for k = i + 1; k < n; k = k + 1 {
          let updated = lu.get(j, k) - factor * lu.get(i, k)
          lu.set(j, k, updated)
        }
      }
    }
  }

  { lu, pivots, num_swaps: swaps }
}

///|
pub fn LUDecomposition::solve(
  self : LUDecomposition,
  b : Array[Double],
) -> Array[Double] {
  let n = self.lu.rows
  let x = Array::new(capacity=n)
  for i = 0; i < n; i = i + 1 {
    x.push(b[self.pivots[i]])
  }

  // Forward substitution L * y = P * b
  for i = 0; i < n; i = i + 1 {
    for j = 0; j < i; j = j + 1 {
      x[i] = x[i] - self.lu.get(i, j) * x[j]
    }
  }

  // Backward substitution U * x = y
  for i = n - 1; i >= 0; i = i - 1 {
    for j = i + 1; j < n; j = j + 1 {
      x[i] = x[i] - self.lu.get(i, j) * x[j]
    }
    let diag = self.lu.get(i, i)
    if diag.abs() > 1.0e-14 {
      x[i] = x[i] / diag
    } else {
      x[i] = 0.0
    }
  }

  x
}

///|
pub fn LUDecomposition::det(self : LUDecomposition) -> Double {
  let n = self.lu.rows
  let mut d = if self.num_swaps % 2 == 0 { 1.0 } else { -1.0 }
  for i = 0; i < n; i = i + 1 {
    d = d * self.lu.get(i, i)
  }
  d
}

///|
pub fn Matrix::inv(self : Matrix) -> Matrix {
  let n = self.rows
  let lu = self.lu_decompose()
  let res = Matrix::zeros(n, n)
  let unit_col = Array::new(capacity=n)
  for i = 0; i < n; i = i + 1 {
    unit_col.push(0.0)
  }

  for col = 0; col < n; col = col + 1 {
    for i = 0; i < n; i = i + 1 {
      unit_col[i] = if i == col { 1.0 } else { 0.0 }
    }
    let sol = lu.solve(unit_col)
    for row = 0; row < n; row = row + 1 {
      res.set(row, col, sol[row])
    }
  }
  res
}

///|
/// Complex Matrix struct (M x N)
pub struct MatrixC {
  rows : Int
  cols : Int
  data : Array[@core.Complex]
} derive(Eq)

///|
pub fn MatrixC::zeros(rows : Int, cols : Int) -> MatrixC {
  let size = rows * cols
  let data = Array::new(capacity=size)
  for i = 0; i < size; i = i + 1 {
    data.push(@core.Complex::zero())
  }
  { rows, cols, data }
}

///|
pub fn MatrixC::identity(n : Int) -> MatrixC {
  let m = MatrixC::zeros(n, n)
  for i = 0; i < n; i = i + 1 {
    m.set(i, i, @core.Complex::one())
  }
  m
}

///|
pub fn MatrixC::get(self : MatrixC, r : Int, c : Int) -> @core.Complex {
  self.data[r * self.cols + c]
}

///|
pub fn MatrixC::set(
  self : MatrixC,
  r : Int,
  c : Int,
  val : @core.Complex,
) -> Unit {
  self.data[r * self.cols + c] = val
}

///|
pub fn MatrixC::clone(self : MatrixC) -> MatrixC {
  { rows: self.rows, cols: self.cols, data: self.data.copy() }
}

///|
pub fn MatrixC::mul(self : MatrixC, other : MatrixC) -> MatrixC {
  let res = MatrixC::zeros(self.rows, other.cols)
  for r = 0; r < self.rows; r = r + 1 {
    for c = 0; c < other.cols; c = c + 1 {
      let mut sum = @core.Complex::zero()
      for k = 0; k < self.cols; k = k + 1 {
        sum = sum.add(self.get(r, k).mul(other.get(k, c)))
      }
      res.set(r, c, sum)
    }
  }
  res
}

///|
pub fn MatrixC::mul_vec(
  self : MatrixC,
  v : Array[@core.Complex],
) -> Array[@core.Complex] {
  let res = Array::new(capacity=self.rows)
  for r = 0; r < self.rows; r = r + 1 {
    let mut sum = @core.Complex::zero()
    for c = 0; c < self.cols; c = c + 1 {
      sum = sum.add(self.get(r, c).mul(v[c]))
    }
    res.push(sum)
  }
  res
}

///|
/// Complex LU Decomposition with partial pivoting
pub struct LUDecompositionC {
  lu : MatrixC
  pivots : Array[Int]
} derive(Eq)

///|
pub fn MatrixC::lu_decompose(self : MatrixC) -> LUDecompositionC {
  let n = self.rows
  let lu = self.clone()
  let pivots = Array::new(capacity=n)
  for i = 0; i < n; i = i + 1 {
    pivots.push(i)
  }

  for i = 0; i < n; i = i + 1 {
    let mut max_row = i
    let mut max_val = lu.get(i, i).abs()
    for k = i + 1; k < n; k = k + 1 {
      let val = lu.get(k, i).abs()
      if val > max_val {
        max_val = val
        max_row = k
      }
    }

    if max_row != i {
      for c = 0; c < n; c = c + 1 {
        let tmp = lu.get(i, c)
        lu.set(i, c, lu.get(max_row, c))
        lu.set(max_row, c, tmp)
      }
      let tmp_p = pivots[i]
      pivots[i] = pivots[max_row]
      pivots[max_row] = tmp_p
    }

    let diag = lu.get(i, i)
    if diag.abs() > 1.0e-14 {
      for j = i + 1; j < n; j = j + 1 {
        let factor = lu.get(j, i).div(diag)
        lu.set(j, i, factor)
        for k = i + 1; k < n; k = k + 1 {
          let updated = lu.get(j, k).sub(factor.mul(lu.get(i, k)))
          lu.set(j, k, updated)
        }
      }
    }
  }

  { lu, pivots }
}

///|
pub fn LUDecompositionC::solve(
  self : LUDecompositionC,
  b : Array[@core.Complex],
) -> Array[@core.Complex] {
  let n = self.lu.rows
  let x = Array::new(capacity=n)
  for i = 0; i < n; i = i + 1 {
    x.push(b[self.pivots[i]])
  }

  for i = 0; i < n; i = i + 1 {
    for j = 0; j < i; j = j + 1 {
      x[i] = x[i].sub(self.lu.get(i, j).mul(x[j]))
    }
  }

  for i = n - 1; i >= 0; i = i - 1 {
    for j = i + 1; j < n; j = j + 1 {
      x[i] = x[i].sub(self.lu.get(i, j).mul(x[j]))
    }
    let diag = self.lu.get(i, i)
    if diag.abs() > 1.0e-14 {
      x[i] = x[i].div(diag)
    } else {
      x[i] = @core.Complex::zero()
    }
  }

  x
}

///|
pub fn MatrixC::inv(self : MatrixC) -> MatrixC {
  let n = self.rows
  let lu = self.lu_decompose()
  let res = MatrixC::zeros(n, n)
  let unit_col = Array::new(capacity=n)
  for i = 0; i < n; i = i + 1 {
    unit_col.push(@core.Complex::zero())
  }

  for col = 0; col < n; col = col + 1 {
    for i = 0; i < n; i = i + 1 {
      unit_col[i] = if i == col {
        @core.Complex::one()
      } else {
        @core.Complex::zero()
      }
    }
    let sol = lu.solve(unit_col)
    for row = 0; row < n; row = row + 1 {
      res.set(row, col, sol[row])
    }
  }
  res
}

///|
/// 4x4 Complex Matrix Exponential via Padé approximation with scaling and squaring
pub fn matrix_exp_4x4(m : @core.Mat4x4C) -> @core.Mat4x4C {
  // Compute norm estimate
  let mut norm = 0.0
  for r = 0; r < 4; r = r + 1 {
    let mut row_sum = 0.0
    for c = 0; c < 4; c = c + 1 {
      row_sum = row_sum + m.get(r, c).abs()
    }
    if row_sum > norm {
      norm = row_sum
    }
  }

  // Scaling factor: find power of 2 such that ||m / 2^s|| <= 0.5
  let mut s = 0
  let mut scale_factor = 1.0
  let mut norm_scaled = norm
  while norm_scaled > 0.5 && s < 20 {
    s = s + 1
    scale_factor = scale_factor * 2.0
    norm_scaled = norm / scale_factor
  }

  // Scale matrix A = m / 2^s
  let a = @core.Mat4x4C::new()
  let inv_scale = 1.0 / scale_factor
  for r = 0; r < 4; r = r + 1 {
    for c = 0; c < 4; c = c + 1 {
      a.set(r, c, m.get(r, c).mul_real(inv_scale))
    }
  }

  // [6/6] Padé approximation: exp(A) ≈ N(A) * D(A)^(-1)
  // N(A) = sum_{k=0}^6 c_k A^k
  // D(A) = sum_{k=0}^6 (-1)^k c_k A^k
  // c_k = (2p - k)! p! / ((2p)! k! (p - k)!) with p=6
  let c = [
    1.0, 0.5, 0.11363636363636363, 0.015151515151515152, 0.0013774104683195593, 7.996582425040924e-5,
    2.4232067954669466e-6,
  ]

  let id = @core.Mat4x4C::identity()
  let a2 = a.mul(a)
  let a3 = a2.mul(a)
  let a4 = a3.mul(a)
  let a5 = a4.mul(a)
  let a6 = a5.mul(a)

  // N(A) = c0*I + c1*A + c2*A2 + c3*A3 + c4*A4 + c5*A5 + c6*A6
  let mut n_mat = id.scale(@core.Complex::from_real(c[0]))
  n_mat = n_mat.add(a.scale(@core.Complex::from_real(c[1])))
  n_mat = n_mat.add(a2.scale(@core.Complex::from_real(c[2])))
  n_mat = n_mat.add(a3.scale(@core.Complex::from_real(c[3])))
  n_mat = n_mat.add(a4.scale(@core.Complex::from_real(c[4])))
  n_mat = n_mat.add(a5.scale(@core.Complex::from_real(c[5])))
  n_mat = n_mat.add(a6.scale(@core.Complex::from_real(c[6])))

  // D(A) = c0*I - c1*A + c2*A2 - c3*A3 + c4*A4 - c5*A5 + c6*A6
  let mut d_mat = id.scale(@core.Complex::from_real(c[0]))
  d_mat = d_mat.sub(a.scale(@core.Complex::from_real(c[1])))
  d_mat = d_mat.add(a2.scale(@core.Complex::from_real(c[2])))
  d_mat = d_mat.sub(a3.scale(@core.Complex::from_real(c[3])))
  d_mat = d_mat.add(a4.scale(@core.Complex::from_real(c[4])))
  d_mat = d_mat.sub(a5.scale(@core.Complex::from_real(c[5])))
  d_mat = d_mat.add(a6.scale(@core.Complex::from_real(c[6])))

  // Convert D to MatrixC to invert
  let d_mc = MatrixC::zeros(4, 4)
  for r = 0; r < 4; r = r + 1 {
    for col = 0; col < 4; col = col + 1 {
      d_mc.set(r, col, d_mat.get(r, col))
    }
  }
  let d_inv_mc = d_mc.inv()
  let d_inv = @core.Mat4x4C::new()
  for r = 0; r < 4; r = r + 1 {
    for col = 0; col < 4; col = col + 1 {
      d_inv.set(r, col, d_inv_mc.get(r, col))
    }
  }

  // Result before squaring: R = N * D^(-1)
  let mut r_mat = n_mat.mul(d_inv)

  // Squaring step: R = R^(2^s)
  for _i = 0; _i < s; _i = _i + 1 {
    r_mat = r_mat.mul(r_mat)
  }

  r_mat
}
