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
}
