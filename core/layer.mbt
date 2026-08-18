///|
/// Light polarization state
pub(all) enum Polarization {
  TE // s-polarized: Electric field perpendicular to plane of incidence
  TM // p-polarized: Magnetic field perpendicular to plane of incidence
  Unpolarized // Equal 50/50 incoherent mixture of TE and TM
  CircularLeft // Left circular polarization
  CircularRight // Right circular polarization
  Arbitrary(Double) // Linear polarization with angle psi relative to TE (0 = TE, pi/2 = TM)
} derive(Eq)

///|
pub impl Show for Polarization with fn output(self, logger) {
  match self {
    TE => logger.write_string("TE")
    TM => logger.write_string("TM")
    Unpolarized => logger.write_string("Unpolarized")
    CircularLeft => logger.write_string("CircularLeft")
    CircularRight => logger.write_string("CircularRight")
    Arbitrary(ang) => logger.write_string("Arbitrary(\{ang})")
  }
}

///|
/// Optical medium representation
pub(all) enum OpticalMedium {
  Isotropic(Complex) // Complex refractive index n + i*k
  Anisotropic(Complex, Complex, Complex) // Principal complex indices (nx, ny, nz)
  Biaxial(Complex, Complex, Complex, Double, Double, Double) // (nx, ny, nz, Euler alpha, beta, gamma)
} derive(Eq)

///|
pub impl Show for OpticalMedium with fn output(self, logger) {
  match self {
    Isotropic(n) => logger.write_string("Isotropic(\{n})")
    Anisotropic(nx, ny, nz) =>
      logger.write_string("Anisotropic(\{nx}, \{ny}, \{nz})")
    Biaxial(nx, ny, nz, a, b, g) =>
      logger.write_string(
        "Biaxial(\{nx}, \{ny}, \{nz}, euler=[\{a}, \{b}, \{g}])",
      )
  }
}

///|
/// Layer in a multilayer optical stack
pub(all) struct Layer {
  name : String
  thickness_nm : Double // Thickness in nanometers (0 for semi-infinite substrate/ambient)
  medium : OpticalMedium
  is_coherent : Bool // True for thin coherent layers, False for thick incoherent substrates
} derive(Eq)

///|
pub impl Show for Layer with fn output(self, logger) {
  logger.write_string(
    "Layer('\{self.name}', d=\{self.thickness_nm}nm, medium=\{self.medium})",
  )
}

///|
pub fn Layer::new(name : String, thickness_nm : Double, n : Complex) -> Layer {
  { name, thickness_nm, medium: OpticalMedium::Isotropic(n), is_coherent: true }
}

///|
pub fn Layer::real(name : String, thickness_nm : Double, n : Double) -> Layer {
  {
    name,
    thickness_nm,
    medium: OpticalMedium::Isotropic(Complex::from_real(n)),
    is_coherent: true,
  }
}

///|
pub fn Layer::absorbing(
  name : String,
  thickness_nm : Double,
  n : Double,
  k : Double,
) -> Layer {
  {
    name,
    thickness_nm,
    medium: OpticalMedium::Isotropic(Complex::new(n, k)),
    is_coherent: true,
  }
}

///|
pub fn Layer::anisotropic(
  name : String,
  thickness_nm : Double,
  nx : Complex,
  ny : Complex,
  nz : Complex,
) -> Layer {
  {
    name,
    thickness_nm,
    medium: OpticalMedium::Anisotropic(nx, ny, nz),
    is_coherent: true,
  }
}

///|
pub fn Layer::biaxial(
  name : String,
  thickness_nm : Double,
  nx : Complex,
  ny : Complex,
  nz : Complex,
  alpha : Double,
  beta : Double,
  gamma : Double,
) -> Layer {
  {
    name,
    thickness_nm,
    medium: OpticalMedium::Biaxial(nx, ny, nz, alpha, beta, gamma),
    is_coherent: true,
  }
}

///|
pub fn Layer::incoherent(
  name : String,
  thickness_nm : Double,
  n : Complex,
) -> Layer {
  {
    name,
    thickness_nm,
    medium: OpticalMedium::Isotropic(n),
    is_coherent: false,
  }
}

///|
/// Multilayer optical stack containing ambient, sequence of thin films, and substrate
pub(all) struct MultiLayerStack {
  ambient : Layer // Semi-infinite incident medium (e.g. Air n=1.0)
  layers : Array[Layer] // Intermediate thin film layers
  substrate : Layer // Semi-infinite or thick exit medium (e.g. Glass n=1.52 or Si)
} derive(Eq)

///|
pub impl Show for MultiLayerStack with fn output(self, logger) {
  logger.write_string(
    "MultiLayerStack(ambient=\{self.ambient.name}, count=\{self.layers.length()}, substrate=\{self.substrate.name})",
  )
}

///|
pub fn MultiLayerStack::new(
  ambient : Layer,
  layers : Array[Layer],
  substrate : Layer,
) -> MultiLayerStack {
  { ambient, layers, substrate }
}

///|
pub fn MultiLayerStack::air_substrate(substrate : Layer) -> MultiLayerStack {
  { ambient: Layer::real("Air", 0.0, 1.0), layers: [], substrate }
}

///|
pub fn MultiLayerStack::add_layer(
  self : MultiLayerStack,
  layer : Layer,
) -> MultiLayerStack {
  let new_layers = self.layers.copy()
  new_layers.push(layer)
  { ambient: self.ambient, layers: new_layers, substrate: self.substrate }
}

///|
pub fn MultiLayerStack::total_thickness(self : MultiLayerStack) -> Double {
  let mut sum = 0.0
  for layer in self.layers {
    sum = sum + layer.thickness_nm
  }
  sum
}

///|
pub fn MultiLayerStack::layer_count(self : MultiLayerStack) -> Int {
  self.layers.length()
}

///|
/// Angle of incidence wrapper in radians and degrees
pub(all) struct IncidentAngle {
  radians : Double
} derive(Eq, Default)

///|
pub impl Show for IncidentAngle with fn output(self, logger) {
  logger.write_string("\{self.to_deg()}°")
}

///|
pub fn IncidentAngle::from_deg(deg : Double) -> IncidentAngle {
  { radians: deg * @math.PI / 180.0 }
}

///|
pub fn IncidentAngle::from_rad(rad : Double) -> IncidentAngle {
  { radians: rad }
}

///|
pub fn IncidentAngle::to_deg(self : IncidentAngle) -> Double {
  self.radians * 180.0 / @math.PI
}

///|
pub fn IncidentAngle::to_rad(self : IncidentAngle) -> Double {
  self.radians
}

///|
pub fn IncidentAngle::normal() -> IncidentAngle {
  { radians: 0.0 }
}
