///|
test "wasm export single layer calculation" {
  let r = wasm_solve_single_layer(1.38, 0.0, 100.0, 1.52, 550.0, 0.0)
  assert_true(r >= 0.0 && r <= 1.0)
}

///|
test "wasm export color packing" {
  let color_int = wasm_estimate_film_color(2.0, 80.0, 1.5)
  assert_true(color_int >= 0 && color_int <= 0xFFFFFF)
}
