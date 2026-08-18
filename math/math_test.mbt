///|
test "matrix 3x3 LU solver and inversion" {
  let a = Matrix::from_array2d([
    [2.0, 1.0, -1.0],
    [-3.0, -1.0, 2.0],
    [-2.0, 1.0, 2.0],
  ])
  let b = [8.0, -11.0, -3.0]

  let lu = a.lu_decompose()
  let x = lu.solve(b)

  // Solution should be x = [2.0, 3.0, -1.0]
  assert_true((x[0] - 2.0).abs() < 1.0e-8)
  assert_true((x[1] - 3.0).abs() < 1.0e-8)
  assert_true((x[2] - -1.0).abs() < 1.0e-8)

  // Inversion A * A^(-1) = I
  let inv = a.inv()
  let id = a.mul(inv)
  assert_true((id.get(0, 0) - 1.0).abs() < 1.0e-8)
  assert_true((id.get(1, 1) - 1.0).abs() < 1.0e-8)
  assert_true((id.get(2, 2) - 1.0).abs() < 1.0e-8)
  assert_true(id.get(0, 1).abs() < 1.0e-8)
}

///|
test "complex matrix LU inversion" {
  let mc = MatrixC::zeros(2, 2)
  mc.set(0, 0, @core.Complex::new(1.0, 2.0))
  mc.set(0, 1, @core.Complex::new(3.0, 4.0))
  mc.set(1, 0, @core.Complex::new(5.0, 6.0))
  mc.set(1, 1, @core.Complex::new(7.0, 8.0))

  let inv = mc.inv()
  let prod = mc.mul(inv)
  assert_true(prod.get(0, 0).approx_eq(@core.Complex::one(), 1.0e-8))
  assert_true(prod.get(1, 1).approx_eq(@core.Complex::one(), 1.0e-8))
  assert_true(prod.get(0, 1).approx_eq(@core.Complex::zero(), 1.0e-8))
  assert_true(prod.get(1, 0).approx_eq(@core.Complex::zero(), 1.0e-8))
}

///|
test "cubic spline interpolation accuracy" {
  // Interpolate y = sin(x)
  let x = [0.0, 0.5, 1.0, 1.5, 2.0, 2.5, 3.0]
  let y = Array::new(capacity=x.length())
  for v in x {
    y.push(@stdmath.sin(v))
  }
  let spline = CubicSpline::new(x, y)

  let test_x = 1.25
  let expected = @stdmath.sin(test_x)
  let actual = spline.eval(test_x)
  assert_true((actual - expected).abs() < 0.01)
}

///|
test "numerical integration accuracy" {
  // Integrate sin(x) from 0 to pi = 2.0
  let n = 101
  let x = Array::new(capacity=n)
  let y = Array::new(capacity=n)
  let h = @stdmath.PI / (n.to_double() - 1.0)
  for i = 0; i < n; i = i + 1 {
    let xi = h * i.to_double()
    x.push(xi)
    y.push(@stdmath.sin(xi))
  }

  let trap_res = trapezoid_rule(x, y)
  let simp_res = simpson_rule(x, y)

  assert_true((trap_res - 2.0).abs() < 0.001)
  assert_true((simp_res - 2.0).abs() < 1.0e-6)

  // Gauss-Legendre quadrature
  let gl_res = composite_gauss_legendre(
    fn(t) { @stdmath.sin(t) },
    0.0,
    @stdmath.PI,
    4,
  )
  assert_true((gl_res - 2.0).abs() < 1.0e-10)
}

///|
test "rng generation" {
  let rng = Rng::new(42UL)
  let v1 = rng.next_double()
  let v2 = rng.next_double()
  assert_true(v1 >= 0.0 && v1 < 1.0)
  assert_true(v2 >= 0.0 && v2 < 1.0)
  assert_true(v1 != v2)
}
