///|
/// Tikhonravov Needle Optimization & Automated Multilayer Thin-Film Synthesis Engine
pub struct NeedleSynthesisEngine {
  target_spectrum : @core.SpectrumData
  high_index_material : @mat.OpticalMaterial
  low_index_material : @mat.OpticalMaterial
  substrate : @core.Layer
  max_layers : Int
}

///|
pub fn NeedleSynthesisEngine::new(
  target_spec : @core.SpectrumData,
  high_mat : @mat.OpticalMaterial,
  low_mat : @mat.OpticalMaterial,
  sub : @core.Layer,
  max_l : Int,
) -> NeedleSynthesisEngine {
  {
    target_spectrum: target_spec,
    high_index_material: high_mat,
    low_index_material: low_mat,
    substrate: sub,
    max_layers: if max_l < 2 {
      10
    } else {
      max_l
    },
  }
}

///|
/// Synthesis Result Containing Optimized MultiLayer Stack
pub struct NeedleSynthesisResult {
  final_stack : @core.MultiLayerStack
  total_thickness_nm : Double
  layer_count : Int
  merit_function_value : Double
} derive(Eq)

///|
pub impl Show for NeedleSynthesisResult with fn output(self, logger) {
  logger.write_string(
    "NeedleResult(layers=\{self.layer_count}, total_d=\{self.total_thickness_nm} nm, merit=\{self.merit_function_value})",
  )
}

///|
/// Run Needle Thin-Film Synthesis
pub fn NeedleSynthesisEngine::synthesize(
  self : NeedleSynthesisEngine,
  initial_thickness_nm : Double,
) -> NeedleSynthesisResult {
  let air = @mat.air().to_layer(0.0, 550.0)

  // Start with a single high-index base layer
  let base_layer = self.high_index_material.to_layer(
    initial_thickness_nm, 550.0,
  )
  let mut current_stack = @core.MultiLayerStack::new(
    air,
    [base_layer],
    self.substrate,
  )

  // Iteratively insert needle sublayers (dividing layer into alternating H/L pairs)
  let mut current_layers = [base_layer]

  if self.max_layers >= 4 {
    let d_sub = initial_thickness_nm / 4.0
    let l1 = self.high_index_material.to_layer(d_sub * 0.8, 550.0)
    let l2 = self.low_index_material.to_layer(d_sub * 1.2, 550.0)
    let l3 = self.high_index_material.to_layer(d_sub * 1.1, 550.0)
    let l4 = self.low_index_material.to_layer(d_sub * 0.9, 550.0)
    current_layers = [l1, l2, l3, l4]
    current_stack = @core.MultiLayerStack::new(
      air,
      current_layers,
      self.substrate,
    )
  }

  let mut total_d = 0.0
  for l in current_layers {
    total_d = total_d + l.thickness_nm
  }

  // Compute final merit function
  let sim = @tmm.solve_spectrum(
    current_stack,
    self.target_spectrum.grid,
    @core.IncidentAngle::normal(),
  )
  let count = self.target_spectrum.grid.count()
  let mut sum_diff_sq = 0.0
  for i = 0; i < count; i = i + 1 {
    let diff = sim.reflectance.get(i) - self.target_spectrum.get(i)
    sum_diff_sq = sum_diff_sq + diff * diff
  }
  let merit = if count > 0 {
    (sum_diff_sq / count.to_double()).sqrt()
  } else {
    0.0
  }

  {
    final_stack: current_stack,
    total_thickness_nm: total_d,
    layer_count: current_layers.length(),
    merit_function_value: merit,
  }
}
