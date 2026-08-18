///|
/// Fast 64-bit XorShift pseudo-random number generator
pub struct Rng {
  mut state : UInt64
} derive(Eq)

///|
pub fn Rng::new(seed : UInt64) -> Rng {
  let s = if seed == 0UL { 0x853c49e6748fea9bUL } else { seed }
  { state: s }
}

///|
pub fn Rng::default() -> Rng {
  Rng::new(123456789UL)
}

///|
pub fn Rng::next_u64(self : Rng) -> UInt64 {
  let mut x = self.state
  x = x ^ (x << 13)
  x = x ^ (x >> 7)
  x = x ^ (x << 17)
  self.state = x
  x
}

///|
/// Uniform random double in [0.0, 1.0)
pub fn Rng::next_double(self : Rng) -> Double {
  let u = self.next_u64()
  let masked = u & 0x1FFFFFFFFFFFFFUL
  masked.to_double() / 9007199254740992.0
}

///|
/// Uniform random double in [min, max)
pub fn Rng::next_range(self : Rng, min : Double, max : Double) -> Double {
  min + (max - min) * self.next_double()
}

///|
/// Standard Normal distribution N(0, 1) using Box-Muller transform
pub fn Rng::next_gaussian(
  self : Rng,
  mean : Double,
  std_dev : Double,
) -> Double {
  let u1 = self.next_double()
  let u2 = self.next_double()
  let safe_u1 = if u1 <= 1.0e-15 { 1.0e-15 } else { u1 }
  let r = (-2.0 * @stdmath.ln(safe_u1)).sqrt()
  let theta = 2.0 * @stdmath.PI * u2
  let z0 = r * @stdmath.cos(theta)
  mean + std_dev * z0
}
