///|
/// Helper to extract isotropic complex refractive index from OpticalMedium
pub fn get_layer_isotropic_index(layer : @core.Layer) -> @core.Complex {
  match layer.medium {
    Isotropic(n) => n
    Anisotropic(nx, _, _) => nx
    Biaxial(nx, _, _, _, _, _) => nx
  }
}

///|
/// Calculate complex wavevector z-component k_z = k_0 * sqrt(n_j^2 - n_0^2 * sin^2(theta_0))
/// Choosing the branch with Im(k_z) >= 0 for physical damping
pub fn calculate_kz(
  n_layer : @core.Complex,
  n_amb : @core.Complex,
  theta_amb_rad : Double,
  k0_nm : Double,
) -> @core.Complex {
  let sin_theta = @math.sin(theta_amb_rad)
  let n0_sin = n_amb.mul_real(sin_theta)
  let n0_sin_sq = n0_sin.mul(n0_sin)
  let n_sq = n_layer.mul(n_layer)
  let arg = n_sq.sub(n0_sin_sq)
  let sqrt_arg = arg.sqrt()

  // Ensure Im(kz) >= 0 (decaying wave in absorbing medium)
  let correct_branch = if sqrt_arg.im < 0.0 { sqrt_arg.neg() } else { sqrt_arg }

  correct_branch.mul_real(k0_nm)
}

///|
/// Calculate optical admittance eta for TE and TM polarizations
/// eta_TE = kz / k0 = sqrt(n^2 - n0^2 sin^2(theta))
/// eta_TM = n^2 / eta_TE
pub fn calculate_admittance(
  n_layer : @core.Complex,
  kz : @core.Complex,
  k0_nm : Double,
  pol : @core.Polarization,
) -> @core.Complex {
  if k0_nm <= 0.0 {
    return @core.Complex::one()
  }
  let eta_te = kz.div_real(k0_nm)
  match pol {
    TE => eta_te
    TM => {
      let n_sq = n_layer.mul(n_layer)
      if eta_te.abs() == 0.0 {
        @core.Complex::zero()
      } else {
        n_sq.div(eta_te)
      }
    }
    _ => eta_te
  }
}

///|
/// Single thin film characteristic propagation matrix P_j
/// P = [[cos(delta), -i/eta * sin(delta)], [-i*eta * sin(delta), cos(delta)]]
/// delta = kz * d
pub fn calculate_characteristic_matrix(
  kz : @core.Complex,
  d_nm : Double,
  eta : @core.Complex,
) -> @core.Mat2x2C {
  let delta = kz.mul_real(d_nm) // phase thickness
  let cos_d = delta.cos()
  let sin_d = delta.sin()

  let minus_i = @core.Complex::new(0.0, -1.0)
  let m00 = cos_d
  let m01 = if eta.abs() == 0.0 {
    @core.Complex::zero()
  } else {
    minus_i.mul(sin_d).div(eta)
  }
  let m10 = minus_i.mul(eta).mul(sin_d)
  let m11 = cos_d

  @core.Mat2x2C::new(m00, m01, m10, m11)
}

///|
/// Solve 2x2 Transfer Matrix Method for a multilayer stack at a single wavelength and angle
pub fn solve_tmm2d_single(
  stack : @core.MultiLayerStack,
  wavelength_nm : Double,
  angle : @core.IncidentAngle,
) -> @core.SingleWavelengthResult {
  let wl = @core.Wavelength::from_nm(wavelength_nm)
  let k0 = wl.wavenumber_nm()
  let theta_rad = angle.to_rad()

  let n_amb = get_layer_isotropic_index(stack.ambient)
  let n_sub = get_layer_isotropic_index(stack.substrate)

  let kz_amb = calculate_kz(n_amb, n_amb, theta_rad, k0)
  let kz_sub = calculate_kz(n_sub, n_amb, theta_rad, k0)

  // 1. TE Polarization (s-pol)
  let eta_amb_te = calculate_admittance(
    n_amb,
    kz_amb,
    k0,
    @core.Polarization::TE,
  )
  let eta_sub_te = calculate_admittance(
    n_sub,
    kz_sub,
    k0,
    @core.Polarization::TE,
  )

  let mut m_total_te = @core.Mat2x2C::identity()
  for layer in stack.layers {
    if layer.thickness_nm > 0.0 {
      let n_j = get_layer_isotropic_index(layer)
      let kz_j = calculate_kz(n_j, n_amb, theta_rad, k0)
      let eta_j_te = calculate_admittance(n_j, kz_j, k0, @core.Polarization::TE)
      let p_j = calculate_characteristic_matrix(
        kz_j,
        layer.thickness_nm,
        eta_j_te,
      )
      m_total_te = m_total_te.mul(p_j)
    }
  }

  // Calculate r_te and t_te
  // Numerator r = eta_0 (M00 + M01 eta_s) - (M10 + M11 eta_s)
  // Denominator = eta_0 (M00 + M01 eta_s) + (M10 + M11 eta_s)
  let b_te = m_total_te.m00.add(m_total_te.m01.mul(eta_sub_te))
  let c_te = m_total_te.m10.add(m_total_te.m11.mul(eta_sub_te))

  let num_r_te = eta_amb_te.mul(b_te).sub(c_te)
  let den_te = eta_amb_te.mul(b_te).add(c_te)

  let r_te = num_r_te.div(den_te)
  let t_te = @core.Complex::from_real(2.0).mul(eta_amb_te).div(den_te)

  let r_te_power = r_te.norm_sq()
  let t_te_power = if eta_amb_te.re.abs() > 0.0 {
    eta_sub_te.re / eta_amb_te.re * t_te.norm_sq()
  } else {
    0.0
  }

  // 2. TM Polarization (p-pol)
  let eta_amb_tm = calculate_admittance(
    n_amb,
    kz_amb,
    k0,
    @core.Polarization::TM,
  )
  let eta_sub_tm = calculate_admittance(
    n_sub,
    kz_sub,
    k0,
    @core.Polarization::TM,
  )

  let mut m_total_tm = @core.Mat2x2C::identity()
  for layer in stack.layers {
    if layer.thickness_nm > 0.0 {
      let n_j = get_layer_isotropic_index(layer)
      let kz_j = calculate_kz(n_j, n_amb, theta_rad, k0)
      let eta_j_tm = calculate_admittance(n_j, kz_j, k0, @core.Polarization::TM)
      let p_j = calculate_characteristic_matrix(
        kz_j,
        layer.thickness_nm,
        eta_j_tm,
      )
      m_total_tm = m_total_tm.mul(p_j)
    }
  }

  let b_tm = m_total_tm.m00.add(m_total_tm.m01.mul(eta_sub_tm))
  let c_tm = m_total_tm.m10.add(m_total_tm.m11.mul(eta_sub_tm))

  let num_r_tm = eta_amb_tm.mul(b_tm).sub(c_tm)
  let den_tm = eta_amb_tm.mul(b_tm).add(c_tm)

  let r_tm = num_r_tm.div(den_tm)
  let t_tm = @core.Complex::from_real(2.0).mul(eta_amb_tm).div(den_tm)

  let r_tm_power = r_tm.norm_sq()
  let t_tm_power = if eta_amb_tm.re.abs() > 0.0 {
    eta_sub_tm.re / eta_amb_tm.re * t_tm.norm_sq()
  } else {
    0.0
  }

  // Unpolarized averages (50% TE + 50% TM)
  let r_unpol = 0.5 * (r_te_power + r_tm_power)
  let t_unpol = 0.5 * (t_te_power + t_tm_power)
  let a_unpol = if 1.0 - r_unpol - t_unpol < 0.0 {
    0.0
  } else {
    1.0 - r_unpol - t_unpol
  }

  let phase_r = r_te.arg() * 180.0 / @math.PI
  let phase_t = t_te.arg() * 180.0 / @math.PI

  {
    wavelength_nm,
    r_power: r_unpol,
    t_power: t_unpol,
    a_power: a_unpol,
    phase_r_deg: phase_r,
    phase_t_deg: phase_t,
    r_te_power,
    t_te_power,
    r_tm_power,
    t_tm_power,
  }
}

///|
/// Solve 2x2 TMM returning full amplitude coefficients for TE and TM
pub fn solve_tmm2d_coefficients(
  stack : @core.MultiLayerStack,
  wavelength_nm : Double,
  angle : @core.IncidentAngle,
) -> @core.OpticalCoefficients {
  let wl = @core.Wavelength::from_nm(wavelength_nm)
  let k0 = wl.wavenumber_nm()
  let theta_rad = angle.to_rad()

  let n_amb = get_layer_isotropic_index(stack.ambient)
  let n_sub = get_layer_isotropic_index(stack.substrate)

  let kz_amb = calculate_kz(n_amb, n_amb, theta_rad, k0)
  let kz_sub = calculate_kz(n_sub, n_amb, theta_rad, k0)

  // TE
  let eta_amb_te = calculate_admittance(
    n_amb,
    kz_amb,
    k0,
    @core.Polarization::TE,
  )
  let eta_sub_te = calculate_admittance(
    n_sub,
    kz_sub,
    k0,
    @core.Polarization::TE,
  )

  let mut m_total_te = @core.Mat2x2C::identity()
  for layer in stack.layers {
    if layer.thickness_nm > 0.0 {
      let n_j = get_layer_isotropic_index(layer)
      let kz_j = calculate_kz(n_j, n_amb, theta_rad, k0)
      let eta_j_te = calculate_admittance(n_j, kz_j, k0, @core.Polarization::TE)
      let p_j = calculate_characteristic_matrix(
        kz_j,
        layer.thickness_nm,
        eta_j_te,
      )
      m_total_te = m_total_te.mul(p_j)
    }
  }
  let b_te = m_total_te.m00.add(m_total_te.m01.mul(eta_sub_te))
  let c_te = m_total_te.m10.add(m_total_te.m11.mul(eta_sub_te))
  let r_te = eta_amb_te.mul(b_te).sub(c_te).div(eta_amb_te.mul(b_te).add(c_te))
  let t_te = @core.Complex::from_real(2.0)
    .mul(eta_amb_te)
    .div(eta_amb_te.mul(b_te).add(c_te))

  // TM
  let eta_amb_tm = calculate_admittance(
    n_amb,
    kz_amb,
    k0,
    @core.Polarization::TM,
  )
  let eta_sub_tm = calculate_admittance(
    n_sub,
    kz_sub,
    k0,
    @core.Polarization::TM,
  )

  let mut m_total_tm = @core.Mat2x2C::identity()
  for layer in stack.layers {
    if layer.thickness_nm > 0.0 {
      let n_j = get_layer_isotropic_index(layer)
      let kz_j = calculate_kz(n_j, n_amb, theta_rad, k0)
      let eta_j_tm = calculate_admittance(n_j, kz_j, k0, @core.Polarization::TM)
      let p_j = calculate_characteristic_matrix(
        kz_j,
        layer.thickness_nm,
        eta_j_tm,
      )
      m_total_tm = m_total_tm.mul(p_j)
    }
  }
  let b_tm = m_total_tm.m00.add(m_total_tm.m01.mul(eta_sub_tm))
  let c_tm = m_total_tm.m10.add(m_total_tm.m11.mul(eta_sub_tm))
  let r_tm = eta_amb_tm.mul(b_tm).sub(c_tm).div(eta_amb_tm.mul(b_tm).add(c_tm))
  let t_tm = @core.Complex::from_real(2.0)
    .mul(eta_amb_tm)
    .div(eta_amb_tm.mul(b_tm).add(c_tm))

  @core.OpticalCoefficients::isotropic(r_te, t_te, r_tm, t_tm)
}

///|
/// Calculate Spectroscopic Ellipsometry parameters Psi and Delta
/// rho = r_p / r_s = tan(Psi) * exp(i * Delta)
pub fn solve_ellipsometry(
  stack : @core.MultiLayerStack,
  wavelength_nm : Double,
  angle : @core.IncidentAngle,
) -> @core.EllipsometryPoint {
  let coeff = solve_tmm2d_coefficients(stack, wavelength_nm, angle)
  let rs = coeff.r_te
  let rp = coeff.r_tm

  let rho = if rs.abs() == 0.0 { @core.Complex::zero() } else { rp.div(rs) }

  let tan_psi = rho.abs()
  let psi_rad = @math.atan(tan_psi)
  let psi_deg = psi_rad * 180.0 / @math.PI

  let delta_rad = rho.arg()
  let mut delta_deg = delta_rad * 180.0 / @math.PI
  if delta_deg < 0.0 {
    delta_deg = delta_deg + 360.0
  }

  let cos_delta = @math.cos(delta_rad)

  { wavelength_nm, psi_deg, delta_deg, tan_psi, cos_delta, rho }
}
