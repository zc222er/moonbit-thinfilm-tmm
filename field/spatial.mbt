///|
/// Internal forward and backward wave amplitudes (E+, E-) for each layer interface
pub struct LayerWaveAmplitudes {
  e_plus : @core.Complex
  e_minus : @core.Complex
  kz : @core.Complex
  n : @core.Complex
  z_start_nm : Double
  z_end_nm : Double
  layer_idx : Int
} derive(Eq)

///|
/// Solve layer-by-layer forward/backward wave amplitudes throughout the multilayer stack
pub fn solve_layer_amplitudes(
  stack : @core.MultiLayerStack,
  wavelength_nm : Double,
  angle : @core.IncidentAngle,
  pol : @core.Polarization,
) -> Array[LayerWaveAmplitudes] {
  let coeff = @tmm.solve_tmm2d_coefficients(stack, wavelength_nm, angle)
  let r_amp = match pol {
    TM => coeff.r_tm
    _ => coeff.r_te
  }
  let t_amp = match pol {
    TM => coeff.t_tm
    _ => coeff.t_te
  }

  let wl = @core.Wavelength::from_nm(wavelength_nm)
  let k0 = wl.wavenumber_nm()
  let theta_rad = angle.to_rad()
  let n_amb = @tmm.get_layer_isotropic_index(stack.ambient)
  let n_sub = @tmm.get_layer_isotropic_index(stack.substrate)

  let num_films = stack.layers.length()
  let amplitudes = Array::new(capacity=num_films + 2)

  // 1. Ambient: E+ = 1.0, E- = r_amp
  let kz_amb = @tmm.calculate_kz(n_amb, n_amb, theta_rad, k0)
  amplitudes.push({
    e_plus: @core.Complex::one(),
    e_minus: r_amp,
    kz: kz_amb,
    n: n_amb,
    z_start_nm: -100.0,
    z_end_nm: 0.0,
    layer_idx: -1,
  })

  // 2. Compute interface transfer matrices to obtain (E_j^+, E_j^-)
  let mut current_z = 0.0
  let mut m_accum = @core.Mat2x2C::identity()

  for j = 0; j < num_films; j = j + 1 {
    let layer = stack.layers[j]
    let n_j = @tmm.get_layer_isotropic_index(layer)
    let kz_j = @tmm.calculate_kz(n_j, n_amb, theta_rad, k0)
    let eta_j = @tmm.calculate_admittance(n_j, kz_j, k0, pol)

    let eta_amb = @tmm.calculate_admittance(n_amb, kz_amb, k0, pol)
    let e_front = @core.Complex::one().add(r_amp)
    let h_front = eta_amb.mul(@core.Complex::one().sub(r_amp))

    let m_inv = m_accum.inv()
    let e_j0 = m_inv.m00.mul(e_front).add(m_inv.m01.mul(h_front))
    let h_j0 = m_inv.m10.mul(e_front).add(m_inv.m11.mul(h_front))

    let h_div_eta = if eta_j.abs() == 0.0 {
      @core.Complex::zero()
    } else {
      h_j0.div(eta_j)
    }
    let ej_plus = e_j0.add(h_div_eta).mul_real(0.5)
    let ej_minus = e_j0.sub(h_div_eta).mul_real(0.5)

    let next_z = current_z + layer.thickness_nm
    amplitudes.push({
      e_plus: ej_plus,
      e_minus: ej_minus,
      kz: kz_j,
      n: n_j,
      z_start_nm: current_z,
      z_end_nm: next_z,
      layer_idx: j,
    })

    let p_j = @tmm.calculate_characteristic_matrix(
      kz_j,
      layer.thickness_nm,
      eta_j,
    )
    m_accum = m_accum.mul(p_j)
    current_z = next_z
  }

  // 3. Substrate: E+ = t_amp, E- = 0
  let kz_sub = @tmm.calculate_kz(n_sub, n_amb, theta_rad, k0)
  amplitudes.push({
    e_plus: t_amp,
    e_minus: @core.Complex::zero(),
    kz: kz_sub,
    n: n_sub,
    z_start_nm: current_z,
    z_end_nm: current_z + 100.0,
    layer_idx: num_films,
  })

  amplitudes
}

///|
/// Calculate complete spatial field profile across the multilayer depth
pub fn calculate_spatial_field_profile(
  stack : @core.MultiLayerStack,
  wavelength_nm : Double,
  angle : @core.IncidentAngle,
  pol : @core.Polarization,
  num_points : Int,
) -> @core.DepthFieldProfile {
  let amps = solve_layer_amplitudes(stack, wavelength_nm, angle, pol)
  let total_d = stack.total_thickness()
  let z_min = -50.0 // 50 nm in ambient
  let z_max = total_d + 50.0 // 50 nm in substrate
  let dz = (z_max - z_min) / (num_points.to_double() - 1.0)

  let wl = @core.Wavelength::from_nm(wavelength_nm)
  let k0 = wl.wavenumber_nm()

  let points = Array::new(capacity=num_points)

  for i = 0; i < num_points; i = i + 1 {
    let z = z_min + dz * i.to_double()

    // Find corresponding layer
    let mut chosen_amp = amps[0]
    for amp in amps {
      if z >= amp.z_start_nm && z <= amp.z_end_nm {
        chosen_amp = amp
        break
      }
      if z > amp.z_end_nm {
        chosen_amp = amp
      }
    }

    let rel_z = z - chosen_amp.z_start_nm
    let i_kz_z = @core.Complex::i().mul(chosen_amp.kz).mul_real(rel_z)
    let neg_i_kz_z = i_kz_z.neg()

    let exp_plus = i_kz_z.exp()
    let exp_minus = neg_i_kz_z.exp()

    // Local electric field E(z) = E+ * e^(i kz z) + E- * e^(-i kz z)
    let e_z = chosen_amp.e_plus
      .mul(exp_plus)
      .add(chosen_amp.e_minus.mul(exp_minus))
    let eta = @tmm.calculate_admittance(chosen_amp.n, chosen_amp.kz, k0, pol)
    // Local magnetic field H(z) = eta * (E+ * e^(i kz z) - E- * e^(-i kz z))
    let h_z = eta.mul(
      chosen_amp.e_plus.mul(exp_plus).sub(chosen_amp.e_minus.mul(exp_minus)),
    )

    let e_intensity = e_z.norm_sq()

    // Poynting flux Sz = 0.5 * Re(E * H^*)
    let poynting_z = 0.5 * e_z.mul(h_z.conj()).re

    // Local optical absorption rate Q(z) = alpha * n * |E|^2
    let n_val = chosen_amp.n.re
    let k_val = chosen_amp.n.im
    let alpha_nm = 4.0 * @math.PI * k_val / wavelength_nm
    let absorption_rate = alpha_nm * n_val * e_intensity

    points.push(
      @core.DepthFieldPoint::new(
        z,
        chosen_amp.layer_idx,
        e_intensity,
        e_z,
        @core.Complex::zero(),
        @core.Complex::zero(),
        @core.Complex::zero(),
        h_z,
        poynting_z,
        absorption_rate,
      ),
    )
  }

  { wavelength_nm, angle_deg: angle.to_deg(), polarization: pol, points }
}
