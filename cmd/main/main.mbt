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
}
