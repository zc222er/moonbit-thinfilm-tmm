///|
/// Kramers-Kronig relation transform between real and imaginary parts of optical permittivity / refractive index
/// Delta_n(omega) = (2 / pi) * P.V. int_0^infty (omega' * k(omega')) / (omega'^2 - omega^2) d_omega'
pub fn kramers_kronig_k_to_delta_n(
  omega_grid : Array[Double],
  k_values : Array[Double],
  target_omega : Double,
) -> Double {
  let n = omega_grid.length()
  if n < 3 || k_values.length() != n {
    return 0.0
  }

  // Integrand g(omega') = (omega' * k(omega')) / (omega'^2 - omega^2)
  // For the pole at omega' = omega, use Maclaurin's method or subtract pole:
  // int_0^infty (omega'*k(omega') - omega*k(omega)) / (omega'^2 - omega^2) d_omega'
  let mut target_k = 0.0
  let spline = CubicSpline::new(omega_grid, k_values)
  target_k = spline.eval(target_omega)

  let x_pts = Array::new(capacity=n)
  let y_pts = Array::new(capacity=n)

  for i = 0; i < n; i = i + 1 {
    let w = omega_grid[i]
    let k_val = k_values[i]
    x_pts.push(w)
    let denom = w * w - target_omega * target_omega
    if denom.abs() < 1.0e-8 {
      // Derivative approximation at pole
      let dw = 1.0e-5
      let dk_dw = (spline.eval(w + dw) - spline.eval(w - dw)) / (2.0 * dw)
      y_pts.push((k_val + target_omega * dk_dw) / (2.0 * target_omega))
    } else {
      y_pts.push((w * k_val - target_omega * target_k) / denom)
    }
  }

  let integral = simpson_rule(x_pts, y_pts)
  let result = 2.0 / @stdmath.PI * integral
  result
}

///|
/// Verify Kramers-Kronig consistency for given (n, k) spectrum across optical frequencies
pub fn verify_kramers_kronig_consistency(
  omega_grid : Array[Double],
  n_values : Array[Double],
  k_values : Array[Double],
) -> Double {
  let len = omega_grid.length()
  if len < 5 {
    return 0.0
  }
  let mut sum_sq_err = 0.0
  let mut count = 0
  // Test interior points
  let step = if len > 50 { len / 20 } else { 1 }
  let mut i = 5
  while i < len - 5 {
    let w = omega_grid[i]
    let calc_delta_n = kramers_kronig_k_to_delta_n(omega_grid, k_values, w)
    let n_exp = n_values[i] - 1.0 // n(omega) - n_inf
    let diff = calc_delta_n - n_exp
    sum_sq_err = sum_sq_err + diff * diff
    count = count + 1
    i = i + step
  }
  if count == 0 {
    0.0
  } else {
    (sum_sq_err / count.to_double()).sqrt()
  }
}
