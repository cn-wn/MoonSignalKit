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
pub fn Series::difference(self : Series, name? : String = "") -> Series {
  let diff : Array[Sample] = []
  if self.samples.length() < 2 {
    return Series::new(
      if name == "" {
        self.name + ".diff"
      } else {
        name
      },
      diff,
    )
  }
  for i = 1; i < self.samples.length(); i = i + 1 {
    diff.push(
      Sample::new(
        self.samples[i].time,
        self.samples[i].value - self.samples[i - 1].value,
      ),
    )
  }
  Series::new(if name == "" { self.name + ".diff" } else { name }, diff)
}

///|
pub fn Series::rate_of_change(self : Series, name? : String = "") -> Series {
  let rates : Array[Sample] = []
  if self.samples.length() < 2 {
    return Series::new(
      if name == "" {
        self.name + ".rate"
      } else {
        name
      },
      rates,
    )
  }
  for i = 1; i < self.samples.length(); i = i + 1 {
    let dt = self.samples[i].time - self.samples[i - 1].time
    let rate = if dt == 0 {
      0.0
    } else {
      (self.samples[i].value - self.samples[i - 1].value) / dt.to_double()
    }
    rates.push(Sample::new(self.samples[i].time, rate))
  }
  Series::new(if name == "" { self.name + ".rate" } else { name }, rates)
}

///|
pub fn Series::peaks(self : Series, threshold : Double) -> Array[Sample] {
  let peaks : Array[Sample] = []
  if self.samples.length() < 3 {
    return peaks
  }
  for i = 1; i < self.samples.length() - 1; i = i + 1 {
    let value = self.samples[i].value
    if value >= threshold &&
      value > self.samples[i - 1].value &&
      value > self.samples[i + 1].value {
      peaks.push(self.samples[i])
    }
  }
  peaks
}

///|
pub fn Series::peak_count(self : Series, threshold : Double) -> Int {
  self.peaks(threshold).length()
}

///|
pub fn Series::outliers(self : Series, z_threshold : Double) -> Array[Sample] {
  let result : Array[Sample] = []
  let summary = self.summary()
  if summary.std_dev == 0.0 {
    return result
  }
  let threshold = if z_threshold < 0.0 { -z_threshold } else { z_threshold }
  for i = 0; i < self.samples.length(); i = i + 1 {
    let delta = self.samples[i].value - summary.mean
    let abs_delta = if delta < 0.0 { -delta } else { delta }
    let z = abs_delta / summary.std_dev
    if z >= threshold {
      result.push(self.samples[i])
    }
  }
  result
}

///|
pub fn Summary::to_json(self : Summary) -> String {
  "{\"count\":\{self.count},\"min\":\{self.min},\"max\":\{self.max},\"mean\":\{self.mean},\"range\":\{self.range},\"variance\":\{self.variance},\"std_dev\":\{self.std_dev}}"
}

///|
pub fn Series::summary_json(self : Series) -> String {
  self.summary().to_json()
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
