///|
/// Numerically stable online statistics using Welford's algorithm.
///
/// Each sample is processed in O(1) time and O(1) memory, so the accumulator
/// can be used for unbounded telemetry streams without retaining raw samples.
pub(all) struct OnlineMoments {
  mut count : Int
  mut mean : Double
  mut m2 : Double
  mut min : Double
  mut max : Double
} derive(Debug)

///|
pub fn OnlineMoments::new() -> OnlineMoments {
  { count: 0, mean: 0.0, m2: 0.0, min: 0.0, max: 0.0 }
}

///|
/// Adds one observation using a stable one-pass update.
pub fn OnlineMoments::push(self : OnlineMoments, value : Double) -> Unit {
  if self.count == 0 {
    self.count = 1
    self.mean = value
    self.m2 = 0.0
    self.min = value
    self.max = value
    return
  }
  self.count = self.count + 1
  let delta = value - self.mean
  self.mean = self.mean + delta / self.count.to_double()
  let delta_after = value - self.mean
  self.m2 = self.m2 + delta * delta_after
  if value < self.min {
    self.min = value
  }
  if value > self.max {
    self.max = value
  }
}

///|
pub fn OnlineMoments::variance(self : OnlineMoments) -> Double {
  if self.count < 2 { 0.0 } else { self.m2 / self.count.to_double() }
}

///|
pub fn OnlineMoments::std_dev(self : OnlineMoments) -> Double {
  self.variance().sqrt()
}

///|
/// Takes an immutable summary without resetting the accumulator.
pub fn OnlineMoments::summary(self : OnlineMoments) -> Summary {
  let variance = self.variance()
  {
    count: self.count,
    min: if self.count == 0 { 0.0 } else { self.min },
    max: if self.count == 0 { 0.0 } else { self.max },
    mean: self.mean,
    range: if self.count == 0 { 0.0 } else { self.max - self.min },
    variance,
    std_dev: variance.sqrt(),
  }
}

///|
pub(all) enum ChangeDirection {
  Rising
  Falling
} derive(Eq, Debug)

///|
/// A sustained level shift reported by `CusumDetector`.
pub(all) struct ChangePoint {
  sample : Sample
  direction : ChangeDirection
  magnitude : Double
  observation : Int
} derive(Debug)

///|
/// Stateful two-sided CUSUM detector for streaming telemetry.
///
/// `target` is the expected process level, `drift` suppresses ordinary noise,
/// and `threshold` controls how much cumulative evidence triggers an event.
pub(all) struct CusumDetector {
  target : Double
  drift : Double
  threshold : Double
  mut positive_sum : Double
  mut negative_sum : Double
  mut observations : Int
} derive(Debug)

///|
pub fn CusumDetector::new(
  target : Double,
  drift : Double,
  threshold : Double,
) -> CusumDetector {
  {
    target,
    drift: abs_double(drift),
    threshold: max_double(abs_double(threshold), 0.000000001),
    positive_sum: 0.0,
    negative_sum: 0.0,
    observations: 0,
  }
}

///|
/// Processes one sample in O(1) time and returns an event only on a level shift.
pub fn CusumDetector::push(
  self : CusumDetector,
  sample : Sample,
) -> ChangePoint? {
  self.observations = self.observations + 1
  let centered = sample.value - self.target
  self.positive_sum = max_double(
    0.0,
    self.positive_sum + centered - self.drift,
  )
  self.negative_sum = min_double(
    0.0,
    self.negative_sum + centered + self.drift,
  )
  if self.positive_sum >= self.threshold {
    let magnitude = self.positive_sum
    self.reset_evidence()
    Some({
      sample,
      direction: Rising,
      magnitude,
      observation: self.observations,
    })
  } else if -self.negative_sum >= self.threshold {
    let magnitude = -self.negative_sum
    self.reset_evidence()
    Some({
      sample,
      direction: Falling,
      magnitude,
      observation: self.observations,
    })
  } else {
    None
  }
}

///|
/// Clears accumulated evidence while preserving configuration and count.
pub fn CusumDetector::reset_evidence(self : CusumDetector) -> Unit {
  self.positive_sum = 0.0
  self.negative_sum = 0.0
}

///|
pub fn ChangePoint::to_json(self : ChangePoint) -> String {
  let direction = match self.direction {
    Rising => "rising"
    Falling => "falling"
  }
  "{\"time\":\{self.sample.time},\"value\":\{self.sample.value},\"direction\":\"\{direction}\",\"magnitude\":\{self.magnitude},\"observation\":\{self.observation}}"
}

///|
fn abs_double(value : Double) -> Double {
  if value < 0.0 { -value } else { value }
}

///|
fn min_double(a : Double, b : Double) -> Double {
  if a < b { a } else { b }
}

///|
fn max_double(a : Double, b : Double) -> Double {
  if a > b { a } else { b }
}
