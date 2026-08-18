///|
/// Vertical-Cavity Surface-Emitting Laser (VCSEL) Microcavity Engine
pub struct VCSELDesign {
  emission_wavelength_nm : Double // E.g. 850 nm or 940 nm
  top_dbr_pairs : Int // E.g. 22 pairs (R_top ~ 99.5%)
  bottom_dbr_pairs : Int // E.g. 35 pairs (R_bottom ~ 99.9%)
  high_index_mat : @mat.OpticalMaterial // Al0.12Ga0.88As
  low_index_mat : @mat.OpticalMaterial // Al0.90Ga0.10As
  mqw_active_mat : @mat.OpticalMaterial // InGaAs / GaAs quantum wells
  mqw_thickness_nm : Double
  substrate : @core.Layer
}

///|
pub fn VCSELDesign::new(
  emission_wl : Double,
  top_pairs : Int,
  bot_pairs : Int,
  high_mat : @mat.OpticalMaterial,
  low_mat : @mat.OpticalMaterial,
  active_mat : @mat.OpticalMaterial,
  mqw_nm : Double,
  substrate : @core.Layer,
) -> VCSELDesign {
  {
    emission_wavelength_nm: emission_wl,
    top_dbr_pairs: top_pairs,
    bottom_dbr_pairs: bot_pairs,
    high_index_mat: high_mat,
    low_index_mat: low_mat,
    mqw_active_mat: active_mat,
    mqw_thickness_nm: mqw_nm,
    substrate,
  }
}

///|
/// Build complete VCSEL MultiLayerStack: Air / Top DBR / 1-lambda Cavity + MQW / Bottom DBR / GaAs substrate
pub fn VCSELDesign::build_stack(self : VCSELDesign) -> @core.MultiLayerStack {
  let air = @mat.air().to_layer(0.0, self.emission_wavelength_nm)
  let wl = self.emission_wavelength_nm
  let n_h = self.high_index_mat.get_index(wl).re
  let n_l = self.low_index_mat.get_index(wl).re

  let d_h = wl / (4.0 * n_h)
  let d_l = wl / (4.0 * n_l)

  let total_layers = (self.top_dbr_pairs + self.bottom_dbr_pairs) * 2 + 3
  let layers = Array::new(capacity=total_layers)

  // 1. Top outcoupling DBR
  for _i = 0; _i < self.top_dbr_pairs; _i = _i + 1 {
    layers.push(self.high_index_mat.to_layer(d_h, wl))
    layers.push(self.low_index_mat.to_layer(d_l, wl))
  }

  // 2. 1-lambda Optical Cavity with MQW active region positioned at standing wave antinode
  let d_spacer = (wl / n_h - self.mqw_thickness_nm) / 2.0
  layers.push(self.high_index_mat.to_layer(d_spacer, wl))
  layers.push(self.mqw_active_mat.to_layer(self.mqw_thickness_nm, wl))
  layers.push(self.high_index_mat.to_layer(d_spacer, wl))

  // 3. Bottom high-reflectivity DBR
  for _i = 0; _i < self.bottom_dbr_pairs; _i = _i + 1 {
    layers.push(self.low_index_mat.to_layer(d_l, wl))
    layers.push(self.high_index_mat.to_layer(d_h, wl))
  }

  @core.MultiLayerStack::new(air, layers, self.substrate)
}

///|
/// Calculate Cavity Quality Factor Q = lambda_0 / Delta_lambda_FWHM
pub fn VCSELDesign::calculate_cavity_q(
  self : VCSELDesign,
  grid : @core.SpectrumGrid,
) -> Double {
  let stack = self.build_stack()
  let sim = @tmm.solve_spectrum(stack, grid, @core.IncidentAngle::normal())
  let count = grid.count()

  // Find transmission peak near emission wavelength
  let mut max_t = 0.0
  let mut peak_wl = self.emission_wavelength_nm

  for i = 0; i < count; i = i + 1 {
    let t_val = sim.transmittance.get(i)
    if t_val > max_t {
      max_t = t_val
      peak_wl = grid.get(i)
    }
  }

  let half_t = max_t / 2.0
  let mut wl_left = peak_wl
  let mut wl_right = peak_wl

  for i = 0; i < count; i = i + 1 {
    if grid.get(i) < peak_wl && sim.transmittance.get(i) >= half_t {
      wl_left = grid.get(i)
      break
    }
  }
  for i = count - 1; i >= 0; i = i - 1 {
    if grid.get(i) > peak_wl && sim.transmittance.get(i) >= half_t {
      wl_right = grid.get(i)
      break
    }
  }

  let fwhm = if wl_right > wl_left { wl_right - wl_left } else { 0.5 }
  if fwhm > 0.0 {
    peak_wl / fwhm
  } else {
    2000.0
  }
}
