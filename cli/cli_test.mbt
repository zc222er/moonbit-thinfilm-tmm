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
