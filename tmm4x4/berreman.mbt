///|
/// 3x3 Complex Permittivity Tensor
pub struct PermittivityTensor {
  exx : @core.Complex
  exy : @core.Complex
  exz : @core.Complex
  eyx : @core.Complex
  eyy : @core.Complex
  eyz : @core.Complex
  ezx : @core.Complex
  ezy : @core.Complex
  ezz : @core.Complex
} derive(Eq)

///|
pub fn PermittivityTensor::isotropic(n : @core.Complex) -> PermittivityTensor {
  let eps = n.mul(n)
  let zero = @core.Complex::zero()
  {
    exx: eps,
    exy: zero,
    exz: zero,
    eyx: zero,
    eyy: eps,
    eyz: zero,
    ezx: zero,
    ezy: zero,
    ezz: eps,
  }
}

///|
pub fn PermittivityTensor::uniaxial(
  no : @core.Complex,
  ne : @core.Complex,
  theta_rad : Double,
  phi_rad : Double,
) -> PermittivityTensor {
  let epso = no.mul(no)
  let epse = ne.mul(ne)
  let deps = epse.sub(epso)

  let sin_t = @math.sin(theta_rad)
  let cos_t = @math.cos(theta_rad)
  let sin_p = @math.sin(phi_rad)
  let cos_p = @math.cos(phi_rad)

  // Director vector c = (sin_t cos_p, sin_t sin_p, cos_t)
  let cx = sin_t * cos_p
  let cy = sin_t * sin_p
  let cz = cos_t

  let exx = epso.add(deps.mul_real(cx * cx))
  let exy = deps.mul_real(cx * cy)
  let exz = deps.mul_real(cx * cz)
  let eyx = exy
  let eyy = epso.add(deps.mul_real(cy * cy))
  let eyz = deps.mul_real(cy * cz)
  let ezx = exz
  let ezy = eyz
  let ezz = epso.add(deps.mul_real(cz * cz))

  { exx, exy, exz, eyx, eyy, eyz, ezx, ezy, ezz }
}

///|
/// Construct 4x4 Berreman Differential Matrix Delta for given permittivity tensor and in-plane wavevector Kx
pub fn construct_berreman_delta(
  eps : PermittivityTensor,
  kx : Double,
) -> @core.Mat4x4C {
  let ezz = eps.ezz
  let kx_c = @core.Complex::from_real(kx)
  let kx2_c = @core.Complex::from_real(kx * kx)

  let delta = @core.Mat4x4C::new()

  // Row 0
  // D00 = -Kx * ezx / ezz
  let d00 = kx_c.neg().mul(eps.ezx).div(ezz)
  // D01 = 1 - Kx^2 / ezz
  let d01 = @core.Complex::one().sub(kx2_c.div(ezz))
  // D02 = -Kx * ezy / ezz
  let d02 = kx_c.neg().mul(eps.ezy).div(ezz)
  let d03 = @core.Complex::zero()

  // Row 1
  // D10 = exx - exz * ezx / ezz
  let d10 = eps.exx.sub(eps.exz.mul(eps.ezx).div(ezz))
  // D11 = -Kx * exz / ezz
  let d11 = kx_c.neg().mul(eps.exz).div(ezz)
  // D12 = exy - exz * ezy / ezz
  let d12 = eps.exy.sub(eps.exz.mul(eps.ezy).div(ezz))
  let d13 = @core.Complex::zero()

  // Row 2
  let d20 = @core.Complex::zero()
  let d21 = @core.Complex::zero()
  let d22 = @core.Complex::zero()
  let d23 = @core.Complex::one()

  // Row 3
  // D30 = eyx - eyz * ezx / ezz
  let d30 = eps.eyx.sub(eps.eyz.mul(eps.ezx).div(ezz))
  // D31 = -Kx * eyz / ezz
  let d31 = kx_c.neg().mul(eps.eyz).div(ezz)
  // D32 = eyy - eyz * ezy / ezz - Kx^2
  let d32 = eps.eyy.sub(eps.eyz.mul(eps.ezy).div(ezz)).sub(kx2_c)
  let d33 = @core.Complex::zero()

  delta.set(0, 0, d00)
  delta.set(0, 1, d01)
  delta.set(0, 2, d02)
  delta.set(0, 3, d03)

  delta.set(1, 0, d10)
  delta.set(1, 1, d11)
  delta.set(1, 2, d12)
  delta.set(1, 3, d13)

  delta.set(2, 0, d20)
  delta.set(2, 1, d21)
  delta.set(2, 2, d22)
  delta.set(2, 3, d23)

  delta.set(3, 0, d30)
  delta.set(3, 1, d31)
  delta.set(3, 2, d32)
  delta.set(3, 3, d33)

  delta
}

///|
/// Anisotropic Layer 4x4 Propagation Matrix P = exp(i * k0 * d * Delta)
pub fn calculate_anisotropic_layer_matrix(
  eps : PermittivityTensor,
  d_nm : Double,
  kx : Double,
  k0_nm : Double,
) -> @core.Mat4x4C {
  let delta = construct_berreman_delta(eps, kx)
  let i_k0_d = @core.Complex::new(0.0, k0_nm * d_nm)
  let m_scaled = delta.scale(i_k0_d)
  @linalg.matrix_exp_4x4(m_scaled)
}

///|
/// Full 4x4 2x2 Jones Reflection and Transmission Matrix result
pub struct JonesMatrixResult {
  r_ss : @core.Complex
  r_sp : @core.Complex // cross-polarization
  r_ps : @core.Complex // cross-polarization
  r_pp : @core.Complex
  t_ss : @core.Complex
  t_sp : @core.Complex
  t_ps : @core.Complex
  t_pp : @core.Complex
} derive(Eq)

///|
pub impl Show for JonesMatrixResult with fn output(self, logger) {
  logger.write_string(
    "JonesMatrix(rss=\{self.r_ss}, rpp=\{self.r_pp}, rsp=\{self.r_sp}, rps=\{self.r_ps})",
  )
}

///|
/// Solve 4x4 Berreman Transfer Matrix for Anisotropic / Birefringent Multilayer Stack
pub fn solve_berreman_4x4(
  ambient_n : @core.Complex,
  layer_tensors : Array[(PermittivityTensor, Double)],
  substrate_n : @core.Complex,
  wavelength_nm : Double,
  angle : @core.IncidentAngle,
) -> JonesMatrixResult {
  let wl = @core.Wavelength::from_nm(wavelength_nm)
  let k0 = wl.wavenumber_nm()
  let theta_rad = angle.to_rad()

  let n_amb = ambient_n.re
  let kx = n_amb * @math.sin(theta_rad)

  // 1. Calculate overall transfer matrix M = prod_j P_j
  let mut m_total = @core.Mat4x4C::identity()
  for item in layer_tensors {
    let (eps, d_nm) = item
    if d_nm > 0.0 {
      let p_j = calculate_anisotropic_layer_matrix(eps, d_nm, kx, k0)
      m_total = m_total.mul(p_j)
    }
  }

  // 2. Ambient and Substrate partial wave matrices
  // Ambient: kz_amb = sqrt(n_amb^2 - kx^2)
  let kz_amb = ambient_n
    .mul(ambient_n)
    .sub(@core.Complex::from_real(kx * kx))
    .sqrt()
  let q_amb = kz_amb.div(ambient_n) // cos(theta_amb)
  let kz_sub = substrate_n
    .mul(substrate_n)
    .sub(@core.Complex::from_real(kx * kx))
    .sqrt()
  let q_sub = kz_sub.div(substrate_n)

  // Semi-analytical matching for Jones coefficients:
  // For normal / oblique incidence, solve linear system:
  // [E_inc + r_s, r_p / q_0, ...] = M * [t_s, t_p / q_sub, ...]
  let m00 = m_total.get(0, 0)
  let m01 = m_total.get(0, 1)
  let m02 = m_total.get(0, 2)
  let m03 = m_total.get(0, 3)

  let m10 = m_total.get(1, 0)
  let m11 = m_total.get(1, 1)
  let m12 = m_total.get(1, 2)
  let m13 = m_total.get(1, 3)

  let m20 = m_total.get(2, 0)
  let m21 = m_total.get(2, 1)
  let m22 = m_total.get(2, 2)
  let m23 = m_total.get(2, 3)

  let m30 = m_total.get(3, 0)
  let m31 = m_total.get(3, 1)
  let m32 = m_total.get(3, 2)
  let m33 = m_total.get(3, 3)

  // Form 4x4 matrix equation A * [r_s, r_p, t_s, t_p]^T = B
  let a_mat = @linalg.MatrixC::zeros(4, 4)

  // Row 0: Ex matching: -r_p * q_amb - M00 * q_sub * t_p - M01 * substrate_n * t_p - M02 * t_s - M03 * kz_sub * t_s
  a_mat.set(0, 0, @core.Complex::zero())
  a_mat.set(0, 1, q_amb.neg())
  a_mat.set(0, 2, m02.add(m03.mul(kz_sub)).neg())
  a_mat.set(0, 3, m00.mul(q_sub).add(m01.mul(substrate_n)).neg())

  // Row 1: Hy matching: -ambient_n * r_p - M10 * q_sub * t_p - M11 * substrate_n * t_p - M12 * t_s - M13 * kz_sub * t_s
  a_mat.set(1, 0, @core.Complex::zero())
  a_mat.set(1, 1, ambient_n.neg())
  a_mat.set(1, 2, m12.add(m13.mul(kz_sub)).neg())
  a_mat.set(1, 3, m10.mul(q_sub).add(m11.mul(substrate_n)).neg())

  // Row 2: Ey matching: -r_s - M20 * q_sub * t_p - M21 * substrate_n * t_p - M22 * t_s - M23 * kz_sub * t_s
  a_mat.set(2, 0, @core.Complex::from_real(-1.0))
  a_mat.set(2, 1, @core.Complex::zero())
  a_mat.set(2, 2, m22.add(m23.mul(kz_sub)).neg())
  a_mat.set(2, 3, m20.mul(q_sub).add(m21.mul(substrate_n)).neg())

  // Row 3: -Hx matching: kz_amb * r_s - M30 * q_sub * t_p - M31 * substrate_n * t_p - M32 * t_s - M33 * kz_sub * t_s
  a_mat.set(3, 0, kz_amb)
  a_mat.set(3, 1, @core.Complex::zero())
  a_mat.set(3, 2, m32.add(m33.mul(kz_sub)).neg())
  a_mat.set(3, 3, m30.mul(q_sub).add(m31.mul(substrate_n)).neg())

  let lu_a = a_mat.lu_decompose()

  // Incident s-polarization: B_s = [0, 0, -1, -kz_amb]^T
  let b_s = [
    @core.Complex::zero(),
    @core.Complex::zero(),
    @core.Complex::from_real(-1.0),
    kz_amb.neg(),
  ]
  let sol_s = lu_a.solve(b_s)
  let r_ss = sol_s[0]
  let r_sp = sol_s[1]
  let t_ss = sol_s[2]
  let t_sp = sol_s[3]

  // Incident p-polarization: B_p = [-q_amb, ambient_n, 0, 0]^T
  let b_p = [
    q_amb.neg(),
    ambient_n,
    @core.Complex::zero(),
    @core.Complex::zero(),
  ]
  let sol_p = lu_a.solve(b_p)
  let r_ps = sol_p[0]
  let r_pp = sol_p[1]
  let t_ps = sol_p[2]
  let t_pp = sol_p[3]

  { r_ss, r_sp, r_ps, r_pp, t_ss, t_sp, t_ps, t_pp }
}
