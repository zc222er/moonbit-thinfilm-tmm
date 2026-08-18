///|
/// Natural Cubic Spline Interpolator
pub struct CubicSpline {
  x : Array[Double]
  y : Array[Double]
  a : Array[Double]
  b : Array[Double]
  c : Array[Double]
  d : Array[Double]
} derive(Eq)

///|
pub fn CubicSpline::new(
  x_in : Array[Double],
  y_in : Array[Double],
) -> CubicSpline {
  let n = x_in.length()
  if n < 2 {
    let a_arr = y_in.copy()
    let zeros = Array::new(capacity=n)
    for i = 0; i < n; i = i + 1 {
      zeros.push(0.0)
    }
    return {
      x: x_in.copy(),
      y: y_in.copy(),
      a: a_arr,
      b: zeros.copy(),
      c: zeros.copy(),
      d: zeros.copy(),
    }
  }

  let x = x_in.copy()
  let a = y_in.copy()
  let h = Array::new(capacity=n - 1)
  for i = 0; i < n - 1; i = i + 1 {
    h.push(x[i + 1] - x[i])
  }

  let alpha = Array::new(capacity=n)
  alpha.push(0.0)
  for i = 1; i < n - 1; i = i + 1 {
    let val = 3.0 / h[i] * (a[i + 1] - a[i]) -
      3.0 / h[i - 1] * (a[i] - a[i - 1])
    alpha.push(val)
  }
  alpha.push(0.0)

  let l = Array::new(capacity=n)
  let mu = Array::new(capacity=n)
  let z = Array::new(capacity=n)
  for i = 0; i < n; i = i + 1 {
    l.push(0.0)
    mu.push(0.0)
    z.push(0.0)
  }
  l[0] = 1.0
  mu[0] = 0.0
  z[0] = 0.0

  for i = 1; i < n - 1; i = i + 1 {
    l[i] = 2.0 * (x[i + 1] - x[i - 1]) - h[i - 1] * mu[i - 1]
    if l[i] != 0.0 {
      mu[i] = h[i] / l[i]
      z[i] = (alpha[i] - h[i - 1] * z[i - 1]) / l[i]
    }
  }

  l[n - 1] = 1.0
  z[n - 1] = 0.0

  let c = Array::new(capacity=n)
  let b = Array::new(capacity=n)
  let d = Array::new(capacity=n)
  for i = 0; i < n; i = i + 1 {
    c.push(0.0)
    b.push(0.0)
    d.push(0.0)
  }

  c[n - 1] = 0.0
  for j = n - 2; j >= 0; j = j - 1 {
    c[j] = z[j] - mu[j] * c[j + 1]
    if h[j] != 0.0 {
      b[j] = (a[j + 1] - a[j]) / h[j] - h[j] * (c[j + 1] + 2.0 * c[j]) / 3.0
      d[j] = (c[j + 1] - c[j]) / (3.0 * h[j])
    }
  }

  { x, y: a, a, b, c, d }
}

///|
pub fn CubicSpline::eval(self : CubicSpline, target_x : Double) -> Double {
  let n = self.x.length()
  if n == 0 {
    return 0.0
  }
  if n == 1 {
    return self.a[0]
  }

  if target_x <= self.x[0] {
    let dx = target_x - self.x[0]
    return self.a[0] + self.b[0] * dx
  }
  if target_x >= self.x[n - 1] {
    let dx = target_x - self.x[n - 2]
    return self.a[n - 2] +
      self.b[n - 2] * dx +
      self.c[n - 2] * dx * dx +
      self.d[n - 2] * dx * dx * dx
  }

  let mut left = 0
  let mut right = n - 1
  while right - left > 1 {
    let mid = (left + right) / 2
    if self.x[mid] <= target_x {
      left = mid
    } else {
      right = mid
    }
  }

  let dx = target_x - self.x[left]
  self.a[left] +
  self.b[left] * dx +
  self.c[left] * dx * dx +
  self.d[left] * dx * dx * dx
}

///|
/// Bilinear 2D Grid Interpolator
pub struct Bilinear2D {
  x_grid : Array[Double] // Angle / param 1
  y_grid : Array[Double] // Wavelength / param 2
  z_data : Matrix // Values [x_idx, y_idx]
} derive(Eq)

///|
pub fn Bilinear2D::new(
  x_grid : Array[Double],
  y_grid : Array[Double],
  z_data : Matrix,
) -> Bilinear2D {
  { x_grid, y_grid, z_data }
}

///|
pub fn Bilinear2D::eval(self : Bilinear2D, x : Double, y : Double) -> Double {
  let nx = self.x_grid.length()
  let ny = self.y_grid.length()
  if nx == 0 || ny == 0 {
    return 0.0
  }

  // Find x interval
  let mut i = 0
  while i < nx - 2 && x > self.x_grid[i + 1] {
    i = i + 1
  }
  // Find y interval
  let mut j = 0
  while j < ny - 2 && y > self.y_grid[j + 1] {
    j = j + 1
  }

  let x1 = self.x_grid[i]
  let x2 = self.x_grid[i + 1]
  let y1 = self.y_grid[j]
  let y2 = self.y_grid[j + 1]

  let q11 = self.z_data.get(i, j)
  let q12 = self.z_data.get(i, j + 1)
  let q21 = self.z_data.get(i + 1, j)
  let q22 = self.z_data.get(i + 1, j + 1)

  let denom = (x2 - x1) * (y2 - y1)
  if denom == 0.0 {
    return q11
  }

  let f_xy = (
      q11 * (x2 - x) * (y2 - y) +
      q21 * (x - x1) * (y2 - y) +
      q12 * (x2 - x) * (y - y1) +
      q22 * (x - x1) * (y - y1)
    ) /
    denom
  f_xy
}
