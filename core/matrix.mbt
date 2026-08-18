///|
/// Real 2x2 Matrix
pub struct Mat2x2 {
  m00 : Double
  m01 : Double
  m10 : Double
  m11 : Double
} derive(Eq, Default)

///|
pub impl Show for Mat2x2 with fn output(self, logger) {
  logger.write_string(
    "[[\{self.m00}, \{self.m01}], [\{self.m10}, \{self.m11}]]",
  )
}

///|
pub fn Mat2x2::new(
  m00 : Double,
  m01 : Double,
  m10 : Double,
  m11 : Double,
) -> Mat2x2 {
  { m00, m01, m10, m11 }
}

///|
pub fn Mat2x2::identity() -> Mat2x2 {
  { m00: 1.0, m01: 0.0, m10: 0.0, m11: 1.0 }
}

///|
pub fn Mat2x2::zero() -> Mat2x2 {
  { m00: 0.0, m01: 0.0, m10: 0.0, m11: 0.0 }
}

///|
pub fn Mat2x2::add(self : Mat2x2, other : Mat2x2) -> Mat2x2 {
  {
    m00: self.m00 + other.m00,
    m01: self.m01 + other.m01,
    m10: self.m10 + other.m10,
    m11: self.m11 + other.m11,
  }
}

///|
pub fn Mat2x2::sub(self : Mat2x2, other : Mat2x2) -> Mat2x2 {
  {
    m00: self.m00 - other.m00,
    m01: self.m01 - other.m01,
    m10: self.m10 - other.m10,
    m11: self.m11 - other.m11,
  }
}

///|
pub fn Mat2x2::mul(self : Mat2x2, other : Mat2x2) -> Mat2x2 {
  {
    m00: self.m00 * other.m00 + self.m01 * other.m10,
    m01: self.m00 * other.m01 + self.m01 * other.m11,
    m10: self.m10 * other.m00 + self.m11 * other.m10,
    m11: self.m10 * other.m01 + self.m11 * other.m11,
  }
}

///|
pub fn Mat2x2::scale(self : Mat2x2, s : Double) -> Mat2x2 {
  { m00: self.m00 * s, m01: self.m01 * s, m10: self.m10 * s, m11: self.m11 * s }
}

///|
pub fn Mat2x2::det(self : Mat2x2) -> Double {
  self.m00 * self.m11 - self.m01 * self.m10
}

///|
pub fn Mat2x2::trace(self : Mat2x2) -> Double {
  self.m00 + self.m11
}

///|
pub fn Mat2x2::transpose(self : Mat2x2) -> Mat2x2 {
  { m00: self.m00, m01: self.m10, m10: self.m01, m11: self.m11 }
}

///|
pub fn Mat2x2::inv(self : Mat2x2) -> Mat2x2 {
  let d = self.det()
  if d == 0.0 {
    Mat2x2::zero()
  } else {
    {
      m00: self.m11 / d,
      m01: -self.m01 / d,
      m10: -self.m10 / d,
      m11: self.m00 / d,
    }
  }
}

///|
/// Complex 2x2 Matrix for standard isotropic TMM
pub struct Mat2x2C {
  m00 : Complex
  m01 : Complex
  m10 : Complex
  m11 : Complex
} derive(Eq, Default)

///|
pub impl Show for Mat2x2C with fn output(self, logger) {
  logger.write_string(
    "[[\{self.m00}, \{self.m01}], [\{self.m10}, \{self.m11}]]",
  )
}

///|
pub fn Mat2x2C::new(
  m00 : Complex,
  m01 : Complex,
  m10 : Complex,
  m11 : Complex,
) -> Mat2x2C {
  { m00, m01, m10, m11 }
}

///|
pub fn Mat2x2C::identity() -> Mat2x2C {
  {
    m00: Complex::one(),
    m01: Complex::zero(),
    m10: Complex::zero(),
    m11: Complex::one(),
  }
}

///|
pub fn Mat2x2C::zero() -> Mat2x2C {
  {
    m00: Complex::zero(),
    m01: Complex::zero(),
    m10: Complex::zero(),
    m11: Complex::zero(),
  }
}

///|
pub fn Mat2x2C::add(self : Mat2x2C, other : Mat2x2C) -> Mat2x2C {
  {
    m00: self.m00.add(other.m00),
    m01: self.m01.add(other.m01),
    m10: self.m10.add(other.m10),
    m11: self.m11.add(other.m11),
  }
}

///|
pub fn Mat2x2C::sub(self : Mat2x2C, other : Mat2x2C) -> Mat2x2C {
  {
    m00: self.m00.sub(other.m00),
    m01: self.m01.sub(other.m01),
    m10: self.m10.sub(other.m10),
    m11: self.m11.sub(other.m11),
  }
}

///|
pub fn Mat2x2C::mul(self : Mat2x2C, other : Mat2x2C) -> Mat2x2C {
  {
    m00: self.m00.mul(other.m00).add(self.m01.mul(other.m10)),
    m01: self.m00.mul(other.m01).add(self.m01.mul(other.m11)),
    m10: self.m10.mul(other.m00).add(self.m11.mul(other.m10)),
    m11: self.m10.mul(other.m01).add(self.m11.mul(other.m11)),
  }
}

///|
pub fn Mat2x2C::scale(self : Mat2x2C, s : Complex) -> Mat2x2C {
  {
    m00: self.m00.mul(s),
    m01: self.m01.mul(s),
    m10: self.m10.mul(s),
    m11: self.m11.mul(s),
  }
}

///|
pub fn Mat2x2C::scale_real(self : Mat2x2C, s : Double) -> Mat2x2C {
  {
    m00: self.m00.mul_real(s),
    m01: self.m01.mul_real(s),
    m10: self.m10.mul_real(s),
    m11: self.m11.mul_real(s),
  }
}

///|
pub fn Mat2x2C::det(self : Mat2x2C) -> Complex {
  self.m00.mul(self.m11).sub(self.m01.mul(self.m10))
}

///|
pub fn Mat2x2C::trace(self : Mat2x2C) -> Complex {
  self.m00.add(self.m11)
}

///|
pub fn Mat2x2C::transpose(self : Mat2x2C) -> Mat2x2C {
  { m00: self.m00, m01: self.m10, m10: self.m01, m11: self.m11 }
}

///|
pub fn Mat2x2C::dagger(self : Mat2x2C) -> Mat2x2C {
  {
    m00: self.m00.conj(),
    m01: self.m10.conj(),
    m10: self.m01.conj(),
    m11: self.m11.conj(),
  }
}

///|
pub fn Mat2x2C::inv(self : Mat2x2C) -> Mat2x2C {
  let d = self.det()
  if d.abs() == 0.0 {
    Mat2x2C::zero()
  } else {
    {
      m00: self.m11.div(d),
      m01: self.m01.neg().div(d),
      m10: self.m10.neg().div(d),
      m11: self.m00.div(d),
    }
  }
}

///|
/// Complex 4x4 Matrix for Berreman 4x4 Anisotropic TMM
pub struct Mat4x4C {
  data : FixedArray[Complex]
} derive(Eq)

///|
pub fn Mat4x4C::new() -> Mat4x4C {
  { data: FixedArray::make(16, Complex::zero()) }
}

///|
pub impl Show for Mat4x4C with fn output(self, logger) {
  logger.write_string("[\n")
  for row = 0; row < 4; row = row + 1 {
    logger.write_string("  [")
    for col = 0; col < 4; col = col + 1 {
      logger.write_string("\{self.get(row, col)}")
      if col < 3 {
        logger.write_string(", ")
      }
    }
    logger.write_string("]\n")
  }
  logger.write_string("]")
}

///|
pub fn Mat4x4C::get(self : Mat4x4C, row : Int, col : Int) -> Complex {
  self.data[row * 4 + col]
}

///|
pub fn Mat4x4C::set(
  self : Mat4x4C,
  row : Int,
  col : Int,
  val : Complex,
) -> Unit {
  self.data[row * 4 + col] = val
}

///|
pub fn Mat4x4C::identity() -> Mat4x4C {
  let m = Mat4x4C::new()
  m.set(0, 0, Complex::one())
  m.set(1, 1, Complex::one())
  m.set(2, 2, Complex::one())
  m.set(3, 3, Complex::one())
  m
}

///|
pub fn Mat4x4C::zero() -> Mat4x4C {
  Mat4x4C::new()
}

///|
pub fn Mat4x4C::clone(self : Mat4x4C) -> Mat4x4C {
  let m = Mat4x4C::new()
  for i = 0; i < 16; i = i + 1 {
    m.data[i] = self.data[i]
  }
  m
}

///|
pub fn Mat4x4C::add(self : Mat4x4C, other : Mat4x4C) -> Mat4x4C {
  let res = Mat4x4C::new()
  for i = 0; i < 16; i = i + 1 {
    res.data[i] = self.data[i].add(other.data[i])
  }
  res
}

///|
pub fn Mat4x4C::sub(self : Mat4x4C, other : Mat4x4C) -> Mat4x4C {
  let res = Mat4x4C::new()
  for i = 0; i < 16; i = i + 1 {
    res.data[i] = self.data[i].sub(other.data[i])
  }
  res
}

///|
pub fn Mat4x4C::mul(self : Mat4x4C, other : Mat4x4C) -> Mat4x4C {
  let res = Mat4x4C::new()
  for r = 0; r < 4; r = r + 1 {
    for c = 0; c < 4; c = c + 1 {
      let mut sum = Complex::zero()
      for k = 0; k < 4; k = k + 1 {
        sum = sum.add(self.get(r, k).mul(other.get(k, c)))
      }
      res.set(r, c, sum)
    }
  }
  res
}

///|
pub fn Mat4x4C::scale(self : Mat4x4C, s : Complex) -> Mat4x4C {
  let res = Mat4x4C::new()
  for i = 0; i < 16; i = i + 1 {
    res.data[i] = self.data[i].mul(s)
  }
  res
}

///|
pub fn Mat4x4C::transpose(self : Mat4x4C) -> Mat4x4C {
  let res = Mat4x4C::new()
  for r = 0; r < 4; r = r + 1 {
    for c = 0; c < 4; c = c + 1 {
      res.set(r, c, self.get(c, r))
    }
  }
  res
}

///|
pub fn Mat4x4C::dagger(self : Mat4x4C) -> Mat4x4C {
  let res = Mat4x4C::new()
  for r = 0; r < 4; r = r + 1 {
    for c = 0; c < 4; c = c + 1 {
      res.set(r, c, self.get(c, r).conj())
    }
  }
  res
}

///|
pub fn Mat4x4C::trace(self : Mat4x4C) -> Complex {
  self.get(0, 0).add(self.get(1, 1)).add(self.get(2, 2)).add(self.get(3, 3))
}

///|
/// 2D Vector
pub struct Vec2 {
  x : Double
  y : Double
} derive(Eq, Default)

///|
pub impl Show for Vec2 with fn output(self, logger) {
  logger.write_string("(\{self.x}, \{self.y})")
}

///|
pub fn Vec2::new(x : Double, y : Double) -> Vec2 {
  { x, y }
}

///|
pub fn Vec2::add(self : Vec2, other : Vec2) -> Vec2 {
  { x: self.x + other.x, y: self.y + other.y }
}

///|
pub fn Vec2::sub(self : Vec2, other : Vec2) -> Vec2 {
  { x: self.x - other.x, y: self.y - other.y }
}

///|
pub fn Vec2::scale(self : Vec2, s : Double) -> Vec2 {
  { x: self.x * s, y: self.y * s }
}

///|
pub fn Vec2::dot(self : Vec2, other : Vec2) -> Double {
  self.x * other.x + self.y * other.y
}

///|
pub fn Vec2::norm(self : Vec2) -> Double {
  @math.hypot(self.x, self.y)
}

///|
/// 3D Vector
pub struct Vec3 {
  x : Double
  y : Double
  z : Double
} derive(Eq, Default)

///|
pub impl Show for Vec3 with fn output(self, logger) {
  logger.write_string("(\{self.x}, \{self.y}, \{self.z})")
}

///|
pub fn Vec3::new(x : Double, y : Double, z : Double) -> Vec3 {
  { x, y, z }
}

///|
pub fn Vec3::add(self : Vec3, other : Vec3) -> Vec3 {
  { x: self.x + other.x, y: self.y + other.y, z: self.z + other.z }
}

///|
pub fn Vec3::sub(self : Vec3, other : Vec3) -> Vec3 {
  { x: self.x - other.x, y: self.y - other.y, z: self.z - other.z }
}

///|
pub fn Vec3::scale(self : Vec3, s : Double) -> Vec3 {
  { x: self.x * s, y: self.y * s, z: self.z * s }
}

///|
pub fn Vec3::dot(self : Vec3, other : Vec3) -> Double {
  self.x * other.x + self.y * other.y + self.z * other.z
}

///|
pub fn Vec3::cross(self : Vec3, other : Vec3) -> Vec3 {
  {
    x: self.y * other.z - self.z * other.y,
    y: self.z * other.x - self.x * other.z,
    z: self.x * other.y - self.y * other.x,
  }
}

///|
pub fn Vec3::norm(self : Vec3) -> Double {
  (self.x * self.x + self.y * self.y + self.z * self.z).sqrt()
}

///|
/// Complex 2-vector (Jones vector representation)
pub struct Vec2C {
  x : Complex
  y : Complex
} derive(Eq, Default)

///|
pub impl Show for Vec2C with fn output(self, logger) {
  logger.write_string("(\{self.x}, \{self.y})")
}

///|
pub fn Vec2C::new(x : Complex, y : Complex) -> Vec2C {
  { x, y }
}

///|
pub fn Vec2C::add(self : Vec2C, other : Vec2C) -> Vec2C {
  { x: self.x.add(other.x), y: self.y.add(other.y) }
}

///|
pub fn Vec2C::sub(self : Vec2C, other : Vec2C) -> Vec2C {
  { x: self.x.sub(other.x), y: self.y.sub(other.y) }
}

///|
pub fn Vec2C::scale(self : Vec2C, s : Complex) -> Vec2C {
  { x: self.x.mul(s), y: self.y.mul(s) }
}

///|
pub fn Vec2C::scale_real(self : Vec2C, s : Double) -> Vec2C {
  { x: self.x.mul_real(s), y: self.y.mul_real(s) }
}

///|
pub fn Vec2C::norm_sq(self : Vec2C) -> Double {
  self.x.norm_sq() + self.y.norm_sq()
}

///|
pub fn Vec2C::norm(self : Vec2C) -> Double {
  self.norm_sq().sqrt()
}

///|
/// Complex 4-vector (Berreman state vector [Ex, Hy, Ey, -Hx])
pub struct Vec4C {
  v0 : Complex
  v1 : Complex
  v2 : Complex
  v3 : Complex
} derive(Eq, Default)

///|
pub impl Show for Vec4C with fn output(self, logger) {
  logger.write_string("(\{self.v0}, \{self.v1}, \{self.v2}, \{self.v3})")
}

///|
pub fn Vec4C::new(
  v0 : Complex,
  v1 : Complex,
  v2 : Complex,
  v3 : Complex,
) -> Vec4C {
  { v0, v1, v2, v3 }
}

///|
pub fn Vec4C::zero() -> Vec4C {
  {
    v0: Complex::zero(),
    v1: Complex::zero(),
    v2: Complex::zero(),
    v3: Complex::zero(),
  }
}

///|
pub fn Vec4C::add(self : Vec4C, other : Vec4C) -> Vec4C {
  {
    v0: self.v0.add(other.v0),
    v1: self.v1.add(other.v1),
    v2: self.v2.add(other.v2),
    v3: self.v3.add(other.v3),
  }
}

///|
pub fn Vec4C::sub(self : Vec4C, other : Vec4C) -> Vec4C {
  {
    v0: self.v0.sub(other.v0),
    v1: self.v1.sub(other.v1),
    v2: self.v2.sub(other.v2),
    v3: self.v3.sub(other.v3),
  }
}

///|
pub fn Vec4C::scale(self : Vec4C, s : Complex) -> Vec4C {
  {
    v0: self.v0.mul(s),
    v1: self.v1.mul(s),
    v2: self.v2.mul(s),
    v3: self.v3.mul(s),
  }
}

///|
pub fn Vec4C::norm_sq(self : Vec4C) -> Double {
  self.v0.norm_sq() + self.v1.norm_sq() + self.v2.norm_sq() + self.v3.norm_sq()
}

///|
pub fn Mat4x4C::mul_vec(self : Mat4x4C, v : Vec4C) -> Vec4C {
  let v0 = self
    .get(0, 0)
    .mul(v.v0)
    .add(self.get(0, 1).mul(v.v1))
    .add(self.get(0, 2).mul(v.v2))
    .add(self.get(0, 3).mul(v.v3))
  let v1 = self
    .get(1, 0)
    .mul(v.v0)
    .add(self.get(1, 1).mul(v.v1))
    .add(self.get(1, 2).mul(v.v2))
    .add(self.get(1, 3).mul(v.v3))
  let v2 = self
    .get(2, 0)
    .mul(v.v0)
    .add(self.get(2, 1).mul(v.v1))
    .add(self.get(2, 2).mul(v.v2))
    .add(self.get(2, 3).mul(v.v3))
  let v3 = self
    .get(3, 0)
    .mul(v.v0)
    .add(self.get(3, 1).mul(v.v1))
    .add(self.get(3, 2).mul(v.v2))
    .add(self.get(3, 3).mul(v.v3))
  Vec4C::new(v0, v1, v2, v3)
}

///|
pub fn Mat2x2C::mul_vec(self : Mat2x2C, v : Vec2C) -> Vec2C {
  let x = self.m00.mul(v.x).add(self.m01.mul(v.y))
  let y = self.m10.mul(v.x).add(self.m11.mul(v.y))
  Vec2C::new(x, y)
}
