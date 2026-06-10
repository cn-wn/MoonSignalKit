///|
pub(all) struct Sample {
  time : Int
  value : Double
} derive(Debug)

///|
pub(all) struct Series {
  name : String
  samples : Array[Sample]
} derive(Debug)

///|
pub(all) struct Summary {
  count : Int
  min : Double
  max : Double
  mean : Double
  range : Double
  variance : Double
  std_dev : Double
} derive(Debug)

///|
pub fn Sample::new(time : Int, value : Double) -> Sample {
  { time, value }
}

///|
pub fn Series::new(name : String, samples : Array[Sample]) -> Series {
  { name, samples }
}

///|
pub fn Series::length(self : Series) -> Int {
  self.samples.length()
}

///|
pub fn Series::is_empty(self : Series) -> Bool {
  self.samples.length() == 0
}

///|
pub fn Series::sum(self : Series) -> Double {
  let mut total = 0.0
  for i = 0; i < self.samples.length(); i = i + 1 {
    total = total + self.samples[i].value
  }
  total
}

///|
pub fn Series::min_value(self : Series) -> Double {
  if self.samples.length() == 0 {
    return 0.0
  }
  let mut best = self.samples[0].value
  for i = 1; i < self.samples.length(); i = i + 1 {
    if self.samples[i].value < best {
      best = self.samples[i].value
    }
  }
  best
}

///|
pub fn Series::max_value(self : Series) -> Double {
  if self.samples.length() == 0 {
    return 0.0
  }
  let mut best = self.samples[0].value
  for i = 1; i < self.samples.length(); i = i + 1 {
    if self.samples[i].value > best {
      best = self.samples[i].value
    }
  }
  best
}

///|
pub fn Series::mean(self : Series) -> Double {
  if self.samples.length() == 0 {
    0.0
  } else {
    self.sum() / self.samples.length().to_double()
  }
}

///|
pub fn Series::summary(self : Series) -> Summary {
  let variance = self.variance()
  {
    count: self.samples.length(),
    min: self.min_value(),
    max: self.max_value(),
    mean: self.mean(),
    range: self.range(),
    variance,
    std_dev: variance.sqrt(),
  }
}

///|
pub fn Series::range(self : Series) -> Double {
  self.max_value() - self.min_value()
}

///|
pub fn Series::variance(self : Series) -> Double {
  if self.samples.length() < 2 {
    return 0.0
  }
  let mean = self.mean()
  let mut total = 0.0
  for i = 0; i < self.samples.length(); i = i + 1 {
    let delta = self.samples[i].value - mean
    total = total + delta * delta
  }
  total / self.samples.length().to_double()
}

///|
pub fn Series::normalize_minmax(self : Series, name? : String = "") -> Series {
  let min = self.min_value()
  let range = self.range()
  let normalized : Array[Sample] = []
  for i = 0; i < self.samples.length(); i = i + 1 {
    let value = if range == 0.0 {
      0.0
    } else {
      (self.samples[i].value - min) / range
    }
    normalized.push(Sample::new(self.samples[i].time, value))
  }
  Series::new(
    if name == "" {
      self.name + ".normalized"
    } else {
      name
    },
    normalized,
  )
}

///|
pub fn Series::moving_average(
  self : Series,
  window : Int,
  name? : String = "",
) -> Series {
  let normalized_window = if window <= 1 { 1 } else { window }
  let smoothed : Array[Sample] = []
  for i = 0; i < self.samples.length(); i = i + 1 {
    let start = if i + 1 < normalized_window {
      0
    } else {
      i + 1 - normalized_window
    }
    let mut total = 0.0
    let mut count = 0
    for j = start; j <= i; j = j + 1 {
      total = total + self.samples[j].value
      count = count + 1
    }
    smoothed.push(Sample::new(self.samples[i].time, total / count.to_double()))
  }
  Series::new(if name == "" { self.name + ".ma" } else { name }, smoothed)
}

///|
pub fn Series::exponential_smoothing(
  self : Series,
  alpha_per_mille : Int,
  name? : String = "",
) -> Series {
  if self.samples.length() == 0 {
    return Series::new(if name == "" { self.name + ".ema" } else { name }, [])
  }
  let alpha = clamp_int(alpha_per_mille, 0, 1000).to_double() / 1000.0
  let smoothed : Array[Sample] = []
  let mut last = self.samples[0].value
  smoothed.push(Sample::new(self.samples[0].time, last))
  for i = 1; i < self.samples.length(); i = i + 1 {
    last = alpha * self.samples[i].value + (1.0 - alpha) * last
    smoothed.push(Sample::new(self.samples[i].time, last))
  }
  Series::new(if name == "" { self.name + ".ema" } else { name }, smoothed)
}

///|
fn clamp_int(value : Int, min : Int, max : Int) -> Int {
  if value < min {
    min
  } else if value > max {
    max
  } else {
    value
  }
}
