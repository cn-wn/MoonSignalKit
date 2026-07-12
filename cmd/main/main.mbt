///|
fn main {
  let series = @signal.Series::new("demo", [
    @signal.Sample::new(0, 10.0),
    @signal.Sample::new(1, 12.0),
    @signal.Sample::new(2, 9.0),
    @signal.Sample::new(3, 30.0),
    @signal.Sample::new(4, 11.0),
  ])
  println(series.summary_json())
  println("peaks=\{series.peak_count(20.0)}")
  println("outliers=\{series.outliers(1.5).length()}")
  let window = @signal.RollingWindow::new(3)
  let median = @signal.MedianFilter::new(3)
  let stats = @signal.OnlineMoments::new()
  let detector = @signal.CusumDetector::new(10.0, 0.25, 4.0)
  for i = 0; i < series.samples.length(); i = i + 1 {
    let sample = series.samples[i]
    stats.push(sample.value)
    let cleaned = median.push(sample)
    window.push(cleaned)
    match detector.push(cleaned) {
      Some(change) => println(change.to_json())
      None => ()
    }
  }
  println("stream_mean=\{stats.mean}")
  println("recent_median=\{window.median()} recent_p95=\{window.quantile(950)}")
  println(series.to_csv())
}
