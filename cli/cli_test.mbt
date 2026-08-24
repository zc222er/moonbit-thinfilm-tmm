///|
test "cli simulate command execution" {
  let output = cmd_simulate()
  assert_true(output.length() > 50)
}

///|
test "cli dbr command execution" {
  let output = cmd_dbr(5, 650.0)
  assert_true(output.length() > 50)
}

///|
test "cli materials database listing" {
  let output = cmd_materials()
  assert_true(output.length() > 100)
}

///|
test "cli benchmark exposes reproducible case summaries" {
  let output = cmd_benchmark()
  assert_true(output.contains("benchmark_version=1"))
  assert_true(output.contains("case=2x2_dbr"))
  assert_true(output.contains("case=4x4_uniaxial"))
  assert_true(output.contains("case=device_spectrum"))
}
