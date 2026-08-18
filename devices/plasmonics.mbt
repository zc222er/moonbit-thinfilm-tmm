///|
/// Kretschmann Surface Plasmon Resonance (SPR) Biosensor Simulation Engine
pub struct SPRSensorDesign {
  prism_material : @mat.OpticalMaterial
  metal_material : @mat.OpticalMaterial
  metal_thickness_nm : Double
  adhesion_layer : (@mat.OpticalMaterial, Double)?
  operating_wavelength_nm : Double
}

///|
pub fn SPRSensorDesign::new(
  prism_mat : @mat.OpticalMaterial,
  metal_mat : @mat.OpticalMaterial,
  metal_nm : Double,
  adhesion : (@mat.OpticalMaterial, Double)?,
  operating_wl : Double,
) -> SPRSensorDesign {
  {
    prism_material: prism_mat,
    metal_material: metal_mat,
    metal_thickness_nm: metal_nm,
    adhesion_layer: adhesion,
    operating_wavelength_nm: operating_wl,
  }
}

///|
/// SPR Angular Scan Result
pub struct SPRAngularScanResult {
  angles_deg : Array[Double]
  reflectance_tm : Array[Double]
  resonance_angle_deg : Double
  minimum_reflectance : Double
  fwhm_deg : Double
} derive(Eq)

///|
pub impl Show for SPRAngularScanResult with fn output(self, logger) {
  logger.write_string(
    "SPRAngularScan(theta_SPR=\{self.resonance_angle_deg}°, R_min=\{self.minimum_reflectance}, FWHM=\{self.fwhm_deg}°)",
  )
}

///|
/// Perform Angular Reflectance Scan for given analyte refractive index (e.g. Water n=1.333 or Buffer n=1.340)
pub fn SPRSensorDesign::scan_angle(
  self : SPRSensorDesign,
  analyte_index : Double,
  start_angle_deg : Double,
  stop_angle_deg : Double,
  steps : Int,
) -> SPRAngularScanResult {
  let wl = self.operating_wavelength_nm
  let prism_layer = self.prism_material.to_layer(0.0, wl)
  let analyte_layer = @core.Layer::real("Analyte", 0.0, analyte_index)

  let films = Array::new(capacity=3)
  match self.adhesion_layer {
    Some((adh_mat, adh_d)) => films.push(adh_mat.to_layer(adh_d, wl))
    None => ()
  }
  films.push(self.metal_material.to_layer(self.metal_thickness_nm, wl))

  let stack = @core.MultiLayerStack::new(prism_layer, films, analyte_layer)

  let d_theta = (stop_angle_deg - start_angle_deg) / (steps.to_double() - 1.0)
  let angles = Array::new(capacity=steps)
  let r_tm_arr = Array::new(capacity=steps)

  let mut min_r = 1.0
  let mut min_theta = start_angle_deg

  for i = 0; i < steps; i = i + 1 {
    let theta = start_angle_deg + d_theta * i.to_double()
    let ang = @core.IncidentAngle::from_deg(theta)
    let res = @tmm.solve_tmm2d_single(stack, wl, ang)

    angles.push(theta)
    r_tm_arr.push(res.r_tm_power)

    if res.r_tm_power < min_r {
      min_r = res.r_tm_power
      min_theta = theta
    }
  }

  let half_depth = 0.5 * (1.0 + min_r)
  let mut left_angle = min_theta
  let mut right_angle = min_theta

  for i = 0; i < steps; i = i + 1 {
    if angles[i] < min_theta && r_tm_arr[i] <= half_depth {
      left_angle = angles[i]
      break
    }
  }
  for i = steps - 1; i >= 0; i = i - 1 {
    if angles[i] > min_theta && r_tm_arr[i] <= half_depth {
      right_angle = angles[i]
      break
    }
  }

  let fwhm = if right_angle > left_angle {
    right_angle - left_angle
  } else {
    1.5
  }

  {
    angles_deg: angles,
    reflectance_tm: r_tm_arr,
    resonance_angle_deg: min_theta,
    minimum_reflectance: min_r,
    fwhm_deg: fwhm,
  }
}

///|
/// Calculate Refractive Index Sensitivity S_theta = Delta_theta / Delta_n (deg / RIU)
pub fn SPRSensorDesign::calculate_sensitivity(
  self : SPRSensorDesign,
  base_analyte_n : Double,
  dn : Double,
) -> Double {
  let scan1 = self.scan_angle(base_analyte_n, 40.0, 80.0, 400)
  let scan2 = self.scan_angle(base_analyte_n + dn, 40.0, 80.0, 400)
  let d_theta = scan2.resonance_angle_deg - scan1.resonance_angle_deg
  if dn != 0.0 {
    d_theta / dn
  } else {
    0.0
  }
}
