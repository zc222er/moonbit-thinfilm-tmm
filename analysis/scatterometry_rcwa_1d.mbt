///|
/// Semiconductor Optical Critical Dimension (OCD) Scatterometry Model
pub struct GratingTrapezoidProfile {
  bottom_cd_nm : Double // Bottom Critical Dimension (line width at base)
  top_cd_nm : Double // Top Critical Dimension
  trench_depth_nm : Double // Etch depth H
  pitch_period_nm : Double // Grating pitch Lambda
}

///|
pub fn GratingTrapezoidProfile::new(
  bottom_cd : Double,
  top_cd : Double,
  depth : Double,
  pitch : Double,
) -> GratingTrapezoidProfile {
  {
    bottom_cd_nm: bottom_cd,
    top_cd_nm: top_cd,
    trench_depth_nm: depth,
    pitch_period_nm: pitch,
  }
}

///|
/// Sidewall Angle (SWA) in degrees: SWA = atan( H / (0.5 * (Bottom_CD - Top_CD)) )
pub fn GratingTrapezoidProfile::calculate_sidewall_angle_deg(
  self : GratingTrapezoidProfile,
) -> Double {
  let delta_w = (self.bottom_cd_nm - self.top_cd_nm) * 0.5
  if delta_w.abs() < 1.0e-5 {
    90.0
  } else {
    let tan_swa = self.trench_depth_nm / delta_w
    let swa_rad = @math.atan(tan_swa)
    swa_rad * (180.0 / @math.PI)
  }
}

///|
/// Discretize Trapezoid into Multi-Slice Binary Gratings for Slicing RCWA
pub fn GratingTrapezoidProfile::slice_trapezoid(
  self : GratingTrapezoidProfile,
  num_slices : Int,
) -> Array[(Double, Double)] {
  let n = if num_slices < 3 { 5 } else { num_slices }
  let d_slice = self.trench_depth_nm / n.to_double()
  let slices = Array::new(capacity=n)

  for i = 0; i < n; i = i + 1 {
    let z_norm = (i.to_double() + 0.5) / n.to_double() // 0 = top, 1 = bottom
    let local_width = self.top_cd_nm +
      (self.bottom_cd_nm - self.top_cd_nm) * z_norm
    let fill = local_width / self.pitch_period_nm
    slices.push((fill, d_slice))
  }

  slices
}
