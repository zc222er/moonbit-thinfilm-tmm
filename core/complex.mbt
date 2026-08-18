///|
/// Complex number representation and fundamental operations for optical calculations
pub(all) struct Complex {
  re : Double
  im : Double
} derive(Eq, Default)

///|
pub impl Show for Complex with fn output(self, logger) {
  if self.im >= 0.0 {
    logger.write_string("\{self.re} + \{self.im}i")
  } else {
    let neg_im = -self.im
    logger.write_string("\{self.re} - \{neg_im}i")
  }
}

///|
pub fn Complex::new(re : Double, im : Double) -> Complex {
  { re, im }
}

///|
pub fn Complex::zero() -> Complex {
  { re: 0.0, im: 0.0 }
}

///|
pub fn Complex::one() -> Complex {
  { re: 1.0, im: 0.0 }
}

///|
pub fn Complex::i() -> Complex {
  { re: 0.0, im: 1.0 }
}

///|
pub fn Complex::from_real(re : Double) -> Complex {
  { re, im: 0.0 }
}

///|
pub fn Complex::from_imag(im : Double) -> Complex {
  { re: 0.0, im }
}

///|
pub fn Complex::from_polar(r : Double, theta : Double) -> Complex {
  { re: r * @math.cos(theta), im: r * @math.sin(theta) }
}

///|
pub fn Complex::add(self : Complex, other : Complex) -> Complex {
  { re: self.re + other.re, im: self.im + other.im }
}

///|
pub fn Complex::op_add(self : Complex, other : Complex) -> Complex {
  self.add(other)
}

///|
pub fn Complex::add_real(self : Complex, r : Double) -> Complex {
  { re: self.re + r, im: self.im }
}

///|
pub fn Complex::sub(self : Complex, other : Complex) -> Complex {
  { re: self.re - other.re, im: self.im - other.im }
}

///|
pub fn Complex::op_sub(self : Complex, other : Complex) -> Complex {
  self.sub(other)
}

///|
pub fn Complex::sub_real(self : Complex, r : Double) -> Complex {
  { re: self.re - r, im: self.im }
}

///|
pub fn Complex::neg(self : Complex) -> Complex {
  { re: -self.re, im: -self.im }
}

///|
pub fn Complex::op_neg(self : Complex) -> Complex {
  self.neg()
}

///|
pub fn Complex::mul(self : Complex, other : Complex) -> Complex {
  {
    re: self.re * other.re - self.im * other.im,
    im: self.re * other.im + self.im * other.re,
  }
}

///|
pub fn Complex::op_mul(self : Complex, other : Complex) -> Complex {
  self.mul(other)
}

///|
pub fn Complex::mul_real(self : Complex, r : Double) -> Complex {
  { re: self.re * r, im: self.im * r }
}

///|
pub fn Complex::div(self : Complex, other : Complex) -> Complex {
  let denom = other.re * other.re + other.im * other.im
  if denom == 0.0 {
    { re: 0.0, im: 0.0 }
  } else {
    {
      re: (self.re * other.re + self.im * other.im) / denom,
      im: (self.im * other.re - self.re * other.im) / denom,
    }
  }
}

///|
pub fn Complex::op_div(self : Complex, other : Complex) -> Complex {
  self.div(other)
}

///|
pub fn Complex::div_real(self : Complex, r : Double) -> Complex {
  if r == 0.0 {
    { re: 0.0, im: 0.0 }
  } else {
    { re: self.re / r, im: self.im / r }
  }
}

///|
pub fn Complex::conj(self : Complex) -> Complex {
  { re: self.re, im: -self.im }
}

///|
pub fn Complex::norm_sq(self : Complex) -> Double {
  self.re * self.re + self.im * self.im
}

///|
pub fn Complex::abs(self : Complex) -> Double {
  @math.hypot(self.re, self.im)
}

///|
pub fn Complex::arg(self : Complex) -> Double {
  @math.atan2(self.im, self.re)
}

///|
pub fn Complex::inv(self : Complex) -> Complex {
  let denom = self.re * self.re + self.im * self.im
  if denom == 0.0 {
    { re: 0.0, im: 0.0 }
  } else {
    { re: self.re / denom, im: -self.im / denom }
  }
}

///|
pub fn Complex::sqrt(self : Complex) -> Complex {
  let r = self.abs()
  let theta = self.arg()
  let r_sqrt = r.sqrt()
  let half_theta = theta / 2.0
  { re: r_sqrt * @math.cos(half_theta), im: r_sqrt * @math.sin(half_theta) }
}

///|
pub fn Complex::exp(self : Complex) -> Complex {
  let exp_re = @math.exp(self.re)
  { re: exp_re * @math.cos(self.im), im: exp_re * @math.sin(self.im) }
}

///|
pub fn Complex::ln(self : Complex) -> Complex {
  { re: @math.ln(self.abs()), im: self.arg() }
}

///|
pub fn Complex::pow_real(self : Complex, p : Double) -> Complex {
  let r = self.abs()
  let theta = self.arg()
  let r_p = @math.pow(r, p)
  let p_theta = p * theta
  { re: r_p * @math.cos(p_theta), im: r_p * @math.sin(p_theta) }
}

///|
pub fn Complex::pow(self : Complex, exp : Complex) -> Complex {
  self.ln().mul(exp).exp()
}

///|
pub fn Complex::sin(self : Complex) -> Complex {
  {
    re: @math.sin(self.re) * @math.cosh(self.im),
    im: @math.cos(self.re) * @math.sinh(self.im),
  }
}

///|
pub fn Complex::cos(self : Complex) -> Complex {
  {
    re: @math.cos(self.re) * @math.cosh(self.im),
    im: -@math.sin(self.re) * @math.sinh(self.im),
  }
}

///|
pub fn Complex::tan(self : Complex) -> Complex {
  self.sin().div(self.cos())
}

///|
pub fn Complex::sinh(self : Complex) -> Complex {
  {
    re: @math.sinh(self.re) * @math.cos(self.im),
    im: @math.cosh(self.re) * @math.sin(self.im),
  }
}

///|
pub fn Complex::cosh(self : Complex) -> Complex {
  {
    re: @math.cosh(self.re) * @math.cos(self.im),
    im: @math.sinh(self.re) * @math.sin(self.im),
  }
}

///|
pub fn Complex::tanh(self : Complex) -> Complex {
  self.sinh().div(self.cosh())
}

///|
pub fn Complex::approx_eq(
  self : Complex,
  other : Complex,
  eps : Double,
) -> Bool {
  (self.re - other.re).abs() <= eps && (self.im - other.im).abs() <= eps
}
