///|
/// A bounded chronological telemetry window.
///
/// Appending a sample is O(1). Summaries and quantiles deliberately inspect the
/// bounded window, so their cost is O(window_size) and does not grow with the
/// lifetime of a stream.
pub(all) struct RollingWindow {
  capacity : Int
  values : Array[Sample]
  mut size : Int
  mut next : Int
} derive(Debug)

///|
pub fn RollingWindow::new(capacity : Int) -> RollingWindow {
  let normalized = if capacity < 1 { 1 } else { capacity }
  {
    capacity: normalized,
    values: Array::make(normalized, Sample::new(0, 0.0)),
    size: 0,
    next: 0,
  }
}

///|
pub fn RollingWindow::capacity(self : RollingWindow) -> Int {
  self.capacity
}

///|
pub fn RollingWindow::length(self : RollingWindow) -> Int {
  self.size
}

///|
pub fn RollingWindow::is_ready(self : RollingWindow) -> Bool {
  self.size == self.capacity
}

///|
/// Adds one sample, evicting the oldest sample after the capacity is reached.
pub fn RollingWindow::push(self : RollingWindow, sample : Sample) -> Unit {
  self.values[self.next] = sample
  self.next = (self.next + 1) % self.capacity
  if self.size < self.capacity {
    self.size = self.size + 1
  }
}

///|
/// Returns retained samples from oldest to newest.
pub fn RollingWindow::samples(self : RollingWindow) -> Array[Sample] {
  let result : Array[Sample] = []
  let start = if self.size == self.capacity { self.next } else { 0 }
  for i = 0; i < self.size; i = i + 1 {
    result.push(self.values[(start + i) % self.capacity])
  }
  result
}

///|
/// Computes a numerically stable summary over the current bounded window.
pub fn RollingWindow::summary(self : RollingWindow) -> Summary {
  let moments = OnlineMoments::new()
  let retained = self.samples()
  for i = 0; i < retained.length(); i = i + 1 {
    moments.push(retained[i].value)
  }
  moments.summary()
}

///|
/// Returns an exact nearest-rank quantile over the retained values.
///
/// `permille` is clamped to the inclusive range 0..1000, making 500 the median.
pub fn RollingWindow::quantile(self : RollingWindow, permille : Int) -> Double {
  if self.size == 0 {
    return 0.0
  }
  let values : Array[Double] = []
  let retained = self.samples()
  for i = 0; i < retained.length(); i = i + 1 {
    values.push(retained[i].value)
  }
  insertion_sort(values)
  let normalized = clamp_int(permille, 0, 1000)
  let index = normalized * (values.length() - 1) / 1000
  values[index]
}

///|
pub fn RollingWindow::median(self : RollingWindow) -> Double {
  self.quantile(500)
}

///|
pub fn RollingWindow::reset(self : RollingWindow) -> Unit {
  self.size = 0
  self.next = 0
}

///|
/// O(1)-memory exponentially weighted moving-average filter.
pub(all) struct EwmaFilter {
  alpha : Double
  mut has_value : Bool
  mut value : Double
} derive(Debug)

///|
pub fn EwmaFilter::new(alpha_per_mille : Int) -> EwmaFilter {
  {
    alpha: clamp_int(alpha_per_mille, 0, 1000).to_double() / 1000.0,
    has_value: false,
    value: 0.0,
  }
}

///|
pub fn EwmaFilter::push(self : EwmaFilter, sample : Sample) -> Sample {
  if !self.has_value {
    self.value = sample.value
    self.has_value = true
  } else {
    self.value = self.alpha * sample.value + (1.0 - self.alpha) * self.value
  }
  Sample::new(sample.time, self.value)
}

///|
pub fn EwmaFilter::value(self : EwmaFilter) -> Double? {
  if self.has_value {
    Some(self.value)
  } else {
    None
  }
}

///|
pub fn EwmaFilter::reset(self : EwmaFilter) -> Unit {
  self.has_value = false
  self.value = 0.0
}

///|
/// A bounded median filter for suppressing isolated telemetry spikes.
pub(all) struct MedianFilter {
  window : RollingWindow
} derive(Debug)

///|
pub fn MedianFilter::new(window : Int) -> MedianFilter {
  { window: RollingWindow::new(window) }
}

///|
pub fn MedianFilter::push(self : MedianFilter, sample : Sample) -> Sample {
  self.window.push(sample)
  Sample::new(sample.time, self.window.median())
}

///|
pub fn MedianFilter::reset(self : MedianFilter) -> Unit {
  self.window.reset()
}

///|
fn insertion_sort(values : Array[Double]) -> Unit {
  for i = 1; i < values.length(); i = i + 1 {
    let current = values[i]
    let mut cursor = i - 1
    while cursor >= 0 && values[cursor] > current {
      values[cursor + 1] = values[cursor]
      cursor = cursor - 1
    }
    values[cursor + 1] = current
  }
}
