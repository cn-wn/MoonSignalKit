///|
/// Deterministic operation-count benchmark for streaming telemetry.
fn main {
  let count = 100000
  let stats = @signal.OnlineMoments::new()
  let detector = @signal.CusumDetector::new(100.0, 0.2, 8.0)
  let rolling = @signal.RollingWindow::new(256)
  let filter = @signal.EwmaFilter::new(250)
  let mut changes = 0
  for i = 0; i < count; i = i + 1 {
    let phase = i / 25000 % 2
    let baseline = if phase == 0 { 100.0 } else { 101.0 }
    let noise = (i * 17 % 9 - 4).to_double() / 10.0
    let value = baseline + noise
    let cleaned = filter.push(@signal.Sample::new(i, value))
    rolling.push(cleaned)
    stats.push(cleaned.value)
    match detector.push(cleaned) {
      Some(_) => changes = changes + 1
      None => ()
    }
  }
  println("scenario,samples,retained_samples,mean,variance,p95,changes")
  println(
    "stream-100k,\{count},\{rolling.length()},\{stats.mean},\{stats.variance()},\{rolling.quantile(950)},\{changes}",
  )
}
