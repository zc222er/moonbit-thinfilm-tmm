///|
/// Trapezoidal numerical integration of discrete array data
pub fn trapezoid_rule(x : Array[Double], y : Array[Double]) -> Double {
  let n = x.length()
  if n < 2 || y.length() != n {
    return 0.0
  }
  let mut sum = 0.0
  for i = 0; i < n - 1; i = i + 1 {
    let dx = x[i + 1] - x[i]
    sum = sum + 0.5 * (y[i] + y[i + 1]) * dx
  }
  sum
}

///|
/// Simpson's composite rule integration of discrete array data
pub fn simpson_rule(x : Array[Double], y : Array[Double]) -> Double {
  let n = x.length()
  if n < 3 || y.length() != n {
    return trapezoid_rule(x, y)
  }

  let mut sum = 0.0
  let mut i = 0
  while i < n - 2 {
    let h1 = x[i + 1] - x[i]
    let h2 = x[i + 2] - x[i + 1]
    let h = h1 + h2
    if h > 0.0 {
      // Non-uniform Simpson formula
      let term = h /
        6.0 *
        (
          (2.0 - h2 / h1) * y[i] +
          h * h / (h1 * h2) * y[i + 1] +
          (2.0 - h1 / h2) * y[i + 2]
        )
      sum = sum + term
    }
    i = i + 2
  }

  // Handle leftover interval if n is even
  if i == n - 2 {
    let dx = x[n - 1] - x[n - 2]
    sum = sum + 0.5 * (y[n - 2] + y[n - 1]) * dx
  }

  sum
}

///|
/// 5-point Gauss-Legendre Quadrature for continuous function integration over [a, b]
pub fn gauss_legendre_5point(
  f : (Double) -> Double,
  a : Double,
  b : Double,
) -> Double {
  let nodes = [
    -0.9061798459386640, -0.5384693101056831, 0.0, 0.5384693101056831, 0.9061798459386640,
  ]
  let weights = [
    0.2369268850561891, 0.4786286704993665, 0.5688888888888889, 0.4786286704993665,
    0.2369268850561891,
  ]

  let c1 = (b - a) / 2.0
  let c2 = (b + a) / 2.0

  let mut sum = 0.0
  for i = 0; i < 5; i = i + 1 {
    let x = c1 * nodes[i] + c2
    sum = sum + weights[i] * f(x)
  }

  sum * c1
}

///|
/// Composite Gauss-Legendre Quadrature dividing [a, b] into sub-intervals
pub fn composite_gauss_legendre(
  f : (Double) -> Double,
  a : Double,
  b : Double,
  subdivisions : Int,
) -> Double {
  if subdivisions <= 0 {
    return 0.0
  }
  let h = (b - a) / subdivisions.to_double()
  let mut total = 0.0
  for i = 0; i < subdivisions; i = i + 1 {
    let sub_a = a + h * i.to_double()
    let sub_b = sub_a + h
    total = total + gauss_legendre_5point(f, sub_a, sub_b)
  }
  total
}
