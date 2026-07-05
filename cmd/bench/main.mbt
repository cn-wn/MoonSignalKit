///|
/// Deterministic operation-count benchmark for streaming telemetry.
fn main {
  let count = 100000
  let stats = @signal.OnlineMoments::new()
  let detector = @signal.CusumDetector::new(100.0, 0.2, 8.0)
  let mut changes = 0
  for i = 0; i < count; i = i + 1 {
    let phase = (i / 25000) % 2
    let baseline = if phase == 0 { 100.0 } else { 101.0 }
    let noise = ((i * 17) % 9 - 4).to_double() / 10.0
    let value = baseline + noise
    stats.push(value)
    match detector.push(@signal.Sample::new(i, value)) {
      Some(_) => changes = changes + 1
      None => ()
    }
  }
  println("scenario,samples,retained_samples,mean,variance,changes")
  println(
    "stream-100k,\{count},0,\{stats.mean},\{stats.variance()},\{changes}",
  )
}
