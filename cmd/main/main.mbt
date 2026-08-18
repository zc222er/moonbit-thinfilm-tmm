///|
fn main {
  println(
    "================================================================================",
  )
  println("  MOONBIT THIN-FILM TMM OPTICAL SIMULATION & INVERSION ENGINE")
  println("  Pure MoonBit High-Performance Optical Engineering Library")
  println(
    "================================================================================\n",
  )

  println(@cli.cmd_simulate())
  println("")
  println(@cli.cmd_dbr(12, 600.0))
  println("")
  println(@cli.cmd_solar())
  println("")
  println(@cli.cmd_benchmark())
}
