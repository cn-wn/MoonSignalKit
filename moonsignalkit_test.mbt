///|
test "series stores samples and length" {
  let series = @moonsignalkit.Series::new("cpu", [
    @moonsignalkit.Sample::new(0, 1.0),
    @moonsignalkit.Sample::new(1, 3.0),
  ])
  assert_eq(series.name, "cpu")
  assert_eq(series.length(), 2)
  assert_false(series.is_empty())
}

///|
test "series summary computes basic statistics" {
  let series = @moonsignalkit.Series::new("load", [
    @moonsignalkit.Sample::new(0, 2.0),
    @moonsignalkit.Sample::new(1, 6.0),
    @moonsignalkit.Sample::new(2, 4.0),
  ])
  let summary = series.summary()
  assert_eq(summary.count, 3)
  assert_eq(summary.min, 2.0)
  assert_eq(summary.max, 6.0)
  assert_eq(summary.mean, 4.0)
  assert_eq(summary.range, 4.0)
}

///|
test "series variance and standard deviation are deterministic" {
  let series = @moonsignalkit.Series::new("stable", [
    @moonsignalkit.Sample::new(0, 2.0),
    @moonsignalkit.Sample::new(1, 4.0),
    @moonsignalkit.Sample::new(2, 6.0),
  ])
  assert_eq(series.variance(), 2.6666666666666665)
  assert_eq(series.summary().std_dev, series.variance().sqrt())
}

///|
test "minmax normalization maps values to zero one range" {
  let series = @moonsignalkit.Series::new("sensor", [
    @moonsignalkit.Sample::new(0, 10.0),
    @moonsignalkit.Sample::new(1, 20.0),
    @moonsignalkit.Sample::new(2, 30.0),
  ])
  let normalized = series.normalize_minmax()
  assert_eq(normalized.name, "sensor.normalized")
  assert_eq(normalized.samples[0].value, 0.0)
  assert_eq(normalized.samples[1].value, 0.5)
  assert_eq(normalized.samples[2].value, 1.0)
}

///|
test "moving average smooths with prefix windows" {
  let series = @moonsignalkit.Series::new("noise", [
    @moonsignalkit.Sample::new(0, 2.0),
    @moonsignalkit.Sample::new(1, 4.0),
    @moonsignalkit.Sample::new(2, 8.0),
    @moonsignalkit.Sample::new(3, 10.0),
  ])
  let smoothed = series.moving_average(3)
  assert_eq(smoothed.samples[0].value, 2.0)
  assert_eq(smoothed.samples[1].value, 3.0)
  assert_eq(smoothed.samples[2].value, 4.666666666666667)
  assert_eq(smoothed.samples[3].value, 7.333333333333333)
}

///|
test "exponential smoothing follows alpha per mille" {
  let series = @moonsignalkit.Series::new("signal", [
    @moonsignalkit.Sample::new(0, 10.0),
    @moonsignalkit.Sample::new(1, 20.0),
    @moonsignalkit.Sample::new(2, 30.0),
  ])
  let smoothed = series.exponential_smoothing(500)
  assert_eq(smoothed.samples[0].value, 10.0)
  assert_eq(smoothed.samples[1].value, 15.0)
  assert_eq(smoothed.samples[2].value, 22.5)
}

///|
test "difference returns adjacent value deltas" {
  let series = @moonsignalkit.Series::new("counter", [
    @moonsignalkit.Sample::new(0, 4.0),
    @moonsignalkit.Sample::new(1, 9.0),
    @moonsignalkit.Sample::new(2, 12.0),
  ])
  let diff = series.difference()
  assert_eq(diff.length(), 2)
  assert_eq(diff.samples[0].value, 5.0)
  assert_eq(diff.samples[1].value, 3.0)
}

///|
test "rate of change divides by time delta" {
  let series = @moonsignalkit.Series::new("distance", [
    @moonsignalkit.Sample::new(0, 0.0),
    @moonsignalkit.Sample::new(2, 10.0),
    @moonsignalkit.Sample::new(4, 18.0),
  ])
  let rate = series.rate_of_change()
  assert_eq(rate.samples[0].value, 5.0)
  assert_eq(rate.samples[1].value, 4.0)
}

///|
test "peak detection finds local maxima above threshold" {
  let series = @moonsignalkit.Series::new("pulse", [
    @moonsignalkit.Sample::new(0, 1.0),
    @moonsignalkit.Sample::new(1, 5.0),
    @moonsignalkit.Sample::new(2, 2.0),
    @moonsignalkit.Sample::new(3, 7.0),
    @moonsignalkit.Sample::new(4, 3.0),
  ])
  let peaks = series.peaks(4.0)
  assert_eq(peaks.length(), 2)
  assert_eq(peaks[0].time, 1)
  assert_eq(peaks[1].value, 7.0)
  assert_eq(series.peak_count(6.0), 1)
}

///|
test "outlier detection uses z score threshold" {
  let series = @moonsignalkit.Series::new("metric", [
    @moonsignalkit.Sample::new(0, 10.0),
    @moonsignalkit.Sample::new(1, 11.0),
    @moonsignalkit.Sample::new(2, 9.0),
    @moonsignalkit.Sample::new(3, 100.0),
  ])
  let outliers = series.outliers(1.5)
  assert_eq(outliers.length(), 1)
  assert_eq(outliers[0].time, 3)
}
