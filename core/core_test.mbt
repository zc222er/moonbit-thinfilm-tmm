///|
test "complex arithmetic operations" {
  let c1 = Complex::new(3.0, 4.0)
  let c2 = Complex::new(1.0, -2.0)

  // Addition
  let c_add = c1.add(c2)
  assert_eq(c_add.re, 4.0)
  assert_eq(c_add.im, 2.0)

  // Subtraction
  let c_sub = c1.sub(c2)
  assert_eq(c_sub.re, 2.0)
  assert_eq(c_sub.im, 6.0)

  // Multiplication (3+4i)(1-2i) = 3 - 6i + 4i - 8i^2 = 11 - 2i
  let c_mul = c1.mul(c2)
  assert_eq(c_mul.re, 11.0)
  assert_eq(c_mul.im, -2.0)

  // Norm and abs
  assert_eq(c1.norm_sq(), 25.0)
  assert_eq(c1.abs(), 5.0)

  // Division (11-2i) / (1-2i) = 3 + 4i
  let c_div = c_mul.div(c2)
  assert_true(c_div.approx_eq(c1, 1.0e-10))

  // Inversion
  let c1_inv = c1.inv()
  let prod = c1.mul(c1_inv)
  assert_true(prod.approx_eq(Complex::one(), 1.0e-10))
}

///|
test "complex elementary functions" {
  // Euler formula e^(i*pi) = -1
  let i_pi = Complex::new(0.0, @math.PI)
  let exp_i_pi = i_pi.exp()
  assert_true(exp_i_pi.approx_eq(Complex::new(-1.0, 0.0), 1.0e-10))

  // sin^2(z) + cos^2(z) = 1
  let z = Complex::new(0.7, 1.2)
  let sin_z = z.sin()
  let cos_z = z.cos()
  let id = sin_z.mul(sin_z).add(cos_z.mul(cos_z))
  assert_true(id.approx_eq(Complex::one(), 1.0e-10))

  // sqrt(4) = 2, sqrt(-1) = i
  let sqrt_4 = Complex::from_real(4.0).sqrt()
  assert_true(sqrt_4.approx_eq(Complex::from_real(2.0), 1.0e-10))
  let sqrt_neg1 = Complex::from_real(-1.0).sqrt()
  assert_true(sqrt_neg1.approx_eq(Complex::i(), 1.0e-10))
}

///|
test "matrix 2x2 complex operations" {
  let m1 = Mat2x2C::new(
    Complex::new(1.0, 0.0),
    Complex::new(2.0, 1.0),
    Complex::new(0.0, -1.0),
    Complex::new(3.0, 0.0),
  )

  // Identity multiplication
  let id = Mat2x2C::identity()
  let m1_id = m1.mul(id)
  assert_true(m1_id.m00.approx_eq(m1.m00, 1.0e-10))
  assert_true(m1_id.m01.approx_eq(m1.m01, 1.0e-10))
  assert_true(m1_id.m10.approx_eq(m1.m10, 1.0e-10))
  assert_true(m1_id.m11.approx_eq(m1.m11, 1.0e-10))

  // Inversion M * M^(-1) = I
  let inv = m1.inv()
  let res = m1.mul(inv)
  assert_true(res.m00.approx_eq(Complex::one(), 1.0e-10))
  assert_true(res.m01.approx_eq(Complex::zero(), 1.0e-10))
  assert_true(res.m10.approx_eq(Complex::zero(), 1.0e-10))
  assert_true(res.m11.approx_eq(Complex::one(), 1.0e-10))
}

///|
test "matrix 4x4 complex operations" {
  let id = Mat4x4C::identity()
  let v = Vec4C::new(
    Complex::new(1.0, 2.0),
    Complex::new(3.0, 4.0),
    Complex::new(5.0, 6.0),
    Complex::new(7.0, 8.0),
  )
  let v_res = id.mul_vec(v)
  assert_true(v_res.v0.approx_eq(v.v0, 1.0e-10))
  assert_true(v_res.v1.approx_eq(v.v1, 1.0e-10))
  assert_true(v_res.v2.approx_eq(v.v2, 1.0e-10))
  assert_true(v_res.v3.approx_eq(v.v3, 1.0e-10))
}

///|
test "layer and multilayer stack construction" {
  let air = Layer::real("Air", 0.0, 1.0)
  let tio2 = Layer::absorbing("TiO2", 55.0, 2.3, 0.001)
  let sio2 = Layer::real("SiO2", 90.0, 1.46)
  let glass = Layer::real("Glass", 0.0, 1.52)

  let stack = MultiLayerStack::new(air, [tio2, sio2], glass)
  assert_eq(stack.layer_count(), 2)
  assert_eq(stack.total_thickness(), 145.0)
}

///|
test "spectrum grid and linear interpolation" {
  let grid = SpectrumGrid::linear(400.0, 800.0, 5) // 400, 500, 600, 700, 800
  assert_eq(grid.count(), 5)
  assert_eq(grid.get(0), 400.0)
  assert_eq(grid.get(4), 800.0)

  let data = SpectrumData::new("Test", grid, [0.0, 10.0, 20.0, 30.0, 40.0])
  assert_eq(data.interpolate_linear(450.0), 5.0)
  assert_eq(data.interpolate_linear(550.0), 15.0)
  assert_eq(data.interpolate_linear(700.0), 30.0)
}

///|
test "zero-step spectrum grid is empty" {
  let grid = SpectrumGrid::linear(400.0, 800.0, 0)
  assert_eq(grid.count(), 0)

  let data = SpectrumData::zeros("empty", grid)
  assert_eq(data.grid.count(), 0)
  assert_eq(data.interpolate_linear(550.0), 0.0)
}

///|
test "negative-step spectrum grid is empty" {
  let grid = SpectrumGrid::linear(400.0, 800.0, -3)
  assert_eq(grid.count(), 0)
}
