///|
test "rolling window retains chronological bounded samples" {
  let window = @moonsignalkit.RollingWindow::new(3)
  window.push(@moonsignalkit.Sample::new(0, 1.0))
  window.push(@moonsignalkit.Sample::new(1, 3.0))
  window.push(@moonsignalkit.Sample::new(2, 5.0))
  window.push(@moonsignalkit.Sample::new(3, 7.0))
  let samples = window.samples()
  assert_true(window.is_ready())
  assert_eq(samples.length(), 3)
  assert_eq(samples[0].time, 1)
  assert_eq(samples[2].value, 7.0)
}

///|
test "rolling window reports exact quantiles and stable summary" {
  let window = @moonsignalkit.RollingWindow::new(5)
  for i = 0; i < 5; i = i + 1 {
    window.push(@moonsignalkit.Sample::new(i, (i * 2 + 1).to_double()))
  }
  assert_eq(window.quantile(0), 1.0)
  assert_eq(window.median(), 5.0)
  assert_eq(window.quantile(1000), 9.0)
  let summary = window.summary()
  assert_eq(summary.mean, 5.0)
  assert_eq(summary.variance, 8.0)
}

///|
test "ewma and median filters suppress telemetry noise" {
  let ewma = @moonsignalkit.EwmaFilter::new(500)
  assert_eq(ewma.push(@moonsignalkit.Sample::new(0, 10.0)).value, 10.0)
  assert_eq(ewma.push(@moonsignalkit.Sample::new(1, 14.0)).value, 12.0)
  let median = @moonsignalkit.MedianFilter::new(3)
  assert_eq(median.push(@moonsignalkit.Sample::new(0, 10.0)).value, 10.0)
  assert_eq(median.push(@moonsignalkit.Sample::new(1, 100.0)).value, 10.0)
  assert_eq(median.push(@moonsignalkit.Sample::new(2, 11.0)).value, 11.0)
}
