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
