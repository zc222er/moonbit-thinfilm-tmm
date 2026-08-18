///|
/// Continuous Graded-Index (GRIN) and Rugate Thin-Film Engine
pub struct GradedIndexFilm {
  total_thickness_nm : Double
  start_index : Double // Index at front interface z = 0
  end_index : Double // Index at substrate interface z = d
  profile_type : GradedProfileType
  num_slices : Int
}

///|
pub(all) enum GradedProfileType {
  Linear
  Exponential
  Parabolic
  SinusoidalRugate(Double, Double) // (period_nm, modulation_depth_delta_n)
  ChebyshevOptimum
} derive(Eq)

///|
pub fn GradedIndexFilm::new(
  thickness_nm : Double,
  n_start : Double,
  n_end : Double,
  profile : GradedProfileType,
  slices : Int,
) -> GradedIndexFilm {
  {
    total_thickness_nm: thickness_nm,
    start_index: n_start,
    end_index: n_end,
    profile_type: profile,
    num_slices: if slices < 10 {
      30
    } else {
      slices
    },
  }
}

///|
/// Discretize continuous index profile into multilayer stack for TMM solver
pub fn GradedIndexFilm::discretize_to_stack(
  self : GradedIndexFilm,
  ambient : @core.Layer,
  substrate : @core.Layer,
  _wavelength_nm : Double,
) -> @core.MultiLayerStack {
  let n = self.num_slices
  let d_sub_nm = self.total_thickness_nm / n.to_double()
  let layers = Array::new(capacity=n)

  for i = 0; i < n; i = i + 1 {
    let z_norm = (i.to_double() + 0.5) / n.to_double() // 0.0 to 1.0

    let local_n = match self.profile_type {
      Linear => self.start_index + (self.end_index - self.start_index) * z_norm
      Exponential =>
        self.start_index * @math.pow(self.end_index / self.start_index, z_norm)
      Parabolic =>
        self.start_index +
        (self.end_index - self.start_index) * (z_norm * z_norm)
      SinusoidalRugate(period, delta_n) => {
        let z_actual = z_norm * self.total_thickness_nm
        let base_n = self.start_index +
          (self.end_index - self.start_index) * z_norm
        base_n + delta_n * @math.sin(2.0 * @math.PI * z_actual / period)
      }
      ChebyshevOptimum => {
        let arg = 0.5 * @math.PI * (1.0 - z_norm)
        self.start_index +
        (self.end_index - self.start_index) * (1.0 - @math.sin(arg))
      }
    }

    let sublayer = @core.Layer::real("GRIN_Sublayer_\{i}", d_sub_nm, local_n)
    layers.push(sublayer)
  }

  @core.MultiLayerStack::new(ambient, layers, substrate)
}
