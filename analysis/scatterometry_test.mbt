///|
test "ocd scatterometry sidewall angle" {
  // Grating with Bottom CD = 50 nm, Top CD = 40 nm, Depth = 100 nm, Pitch = 100 nm
  let trap = GratingTrapezoidProfile::new(50.0, 40.0, 100.0, 100.0)
  let swa = trap.calculate_sidewall_angle_deg()

  // SWA should be steep (~ 87.1 degrees)
  assert_true(swa > 80.0 && swa < 89.9)

  let slices = trap.slice_trapezoid(5)
  assert_eq(slices.length(), 5)
}
