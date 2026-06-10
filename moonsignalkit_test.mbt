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
