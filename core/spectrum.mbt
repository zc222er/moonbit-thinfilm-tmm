///|
/// Wavelength representation in nanometers
pub struct Wavelength {
  nm : Double
} derive(Eq, Default)

///|
pub impl Show for Wavelength with fn output(self, logger) {
  logger.write_string("\{self.nm} nm")
}

///|
pub fn Wavelength::from_nm(nm : Double) -> Wavelength {
  { nm, }
}

///|
pub fn Wavelength::from_um(um : Double) -> Wavelength {
  { nm: um * 1000.0 }
}

///|
pub fn Wavelength::from_m(m : Double) -> Wavelength {
  { nm: m * 1.0e9 }
}

///|
pub fn Wavelength::to_um(self : Wavelength) -> Double {
  self.nm / 1000.0
}

///|
pub fn Wavelength::to_m(self : Wavelength) -> Double {
  self.nm * 1.0e-9
}

///|
/// Photon energy in electron-volts (eV)
/// E (eV) = 1239.84193 / lambda (nm)
pub fn Wavelength::to_ev(self : Wavelength) -> Double {
  if self.nm <= 0.0 {
    0.0
  } else {
    1239.84193 / self.nm
  }
}

///|
pub fn Wavelength::from_ev(ev : Double) -> Wavelength {
  if ev <= 0.0 {
    { nm: 0.0 }
  } else {
    { nm: 1239.84193 / ev }
  }
}

///|
/// Angular frequency omega = 2 * pi * c / lambda
pub fn Wavelength::to_angular_frequency(self : Wavelength) -> Double {
  let c = 2.99792458e8 // speed of light in m/s
  let lambda_m = self.to_m()
  if lambda_m <= 0.0 {
    0.0
  } else {
    2.0 * @math.PI * c / lambda_m
  }
}

///|
/// Wavenumber k_0 = 2 * pi / lambda (in 1/nm or 1/m)
pub fn Wavelength::wavenumber_nm(self : Wavelength) -> Double {
  if self.nm <= 0.0 {
    0.0
  } else {
    2.0 * @math.PI / self.nm
  }
}

///|
/// Spectrum Grid defining a linear or custom range of wavelengths
pub struct SpectrumGrid {
  wavelengths : Array[Double] // Wavelengths in nm
} derive(Eq)

///|
pub impl Show for SpectrumGrid with fn output(self, logger) {
  let len = self.wavelengths.length()
  if len == 0 {
    logger.write_string("SpectrumGrid(empty)")
  } else {
    let start = self.wavelengths[0]
    let end = self.wavelengths[len - 1]
    logger.write_string("SpectrumGrid(\{len} points: \{start}nm -> \{end}nm)")
  }
}

///|
pub fn SpectrumGrid::linear(
  start_nm : Double,
  stop_nm : Double,
  steps : Int,
) -> SpectrumGrid {
  let wavelengths = Array::new(capacity=steps)
  if steps <= 1 {
    wavelengths.push(start_nm)
  } else {
    let step = (stop_nm - start_nm) / (steps.to_double() - 1.0)
    for i = 0; i < steps; i = i + 1 {
      wavelengths.push(start_nm + step * i.to_double())
    }
  }
  { wavelengths, }
}

///|
pub fn SpectrumGrid::visible_spectrum(steps : Int) -> SpectrumGrid {
  SpectrumGrid::linear(380.0, 780.0, steps)
}

///|
pub fn SpectrumGrid::solar_spectrum(steps : Int) -> SpectrumGrid {
  SpectrumGrid::linear(300.0, 1200.0, steps)
}

///|
pub fn SpectrumGrid::telecom_c_band(steps : Int) -> SpectrumGrid {
  SpectrumGrid::linear(1530.0, 1565.0, steps)
}

///|
pub fn SpectrumGrid::from_array(arr : Array[Double]) -> SpectrumGrid {
  { wavelengths: arr.copy() }
}

///|
pub fn SpectrumGrid::count(self : SpectrumGrid) -> Int {
  self.wavelengths.length()
}

///|
pub fn SpectrumGrid::get(self : SpectrumGrid, idx : Int) -> Double {
  self.wavelengths[idx]
}

///|
/// Spectrum Data consisting of wavelength-dependent values (e.g. R, T, A, n, k)
pub struct SpectrumData {
  name : String
  grid : SpectrumGrid
  values : Array[Double]
} derive(Eq)

///|
pub impl Show for SpectrumData with fn output(self, logger) {
  logger.write_string(
    "SpectrumData('\{self.name}', points=\{self.values.length()})",
  )
}

///|
pub fn SpectrumData::new(
  name : String,
  grid : SpectrumGrid,
  values : Array[Double],
) -> SpectrumData {
  { name, grid, values }
}

///|
pub fn SpectrumData::zeros(name : String, grid : SpectrumGrid) -> SpectrumData {
  let count = grid.count()
  let values = Array::new(capacity=count)
  for i = 0; i < count; i = i + 1 {
    values.push(0.0)
  }
  { name, grid, values }
}

///|
pub fn SpectrumData::get(self : SpectrumData, idx : Int) -> Double {
  self.values[idx]
}

///|
pub fn SpectrumData::interpolate_linear(
  self : SpectrumData,
  wl_nm : Double,
) -> Double {
  let count = self.grid.count()
  if count == 0 {
    return 0.0
  }
  if count == 1 || wl_nm <= self.grid.wavelengths[0] {
    return self.values[0]
  }
  if wl_nm >= self.grid.wavelengths[count - 1] {
    return self.values[count - 1]
  }
  let mut left = 0
  let mut right = count - 1
  while right - left > 1 {
    let mid = (left + right) / 2
    if self.grid.wavelengths[mid] <= wl_nm {
      left = mid
    } else {
      right = mid
    }
  }
  let x0 = self.grid.wavelengths[left]
  let x1 = self.grid.wavelengths[right]
  let y0 = self.values[left]
  let y1 = self.values[right]
  if x1 == x0 {
    y0
  } else {
    let t = (wl_nm - x0) / (x1 - x0)
    y0 + t * (y1 - y0)
  }
}
