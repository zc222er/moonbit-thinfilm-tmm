///|
test "ldos and purcell factor calculation" {
  let r_te = @core.Complex::new(0.9, 0.0)
  let r_tm = @core.Complex::new(0.9, 0.0)

  let ldos = calculate_ldos_at_depth(r_te, r_tm, 10.0, 550.0, 0.8)

  assert_true(ldos.orientation_averaged_purcell > 0.0)
  assert_true(
    ldos.radiative_quantum_efficiency > 0.0 &&
    ldos.radiative_quantum_efficiency <= 1.0,
  )
}
