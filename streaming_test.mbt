///|
test "online moments agree with batch summary" {
  let values = [2.0, 4.0, 6.0, 8.0]
  let online = @moonsignalkit.OnlineMoments::new()
  let samples : Array[@moonsignalkit.Sample] = []
  for i = 0; i < values.length(); i = i + 1 {
    online.push(values[i])
    samples.push(@moonsignalkit.Sample::new(i, values[i]))
  }
  let batch = @moonsignalkit.Series::new("batch", samples).summary()
  let streamed = online.summary()
  assert_eq(streamed.count, batch.count)
  assert_eq(streamed.mean, batch.mean)
  assert_eq(streamed.variance, batch.variance)
  assert_eq(streamed.min, batch.min)
  assert_eq(streamed.max, batch.max)
}

///|
test "online moments handle empty and single streams" {
  let online = @moonsignalkit.OnlineMoments::new()
  assert_eq(online.summary().count, 0)
  assert_eq(online.variance(), 0.0)
  online.push(42.0)
  assert_eq(online.summary().mean, 42.0)
  assert_eq(online.std_dev(), 0.0)
}

///|
test "cusum ignores bounded noise" {
  let detector = @moonsignalkit.CusumDetector::new(10.0, 0.5, 5.0)
  let values = [10.2, 9.8, 10.1, 9.9, 10.3, 9.7]
  for i = 0; i < values.length(); i = i + 1 {
    assert_true(
      detector.push(@moonsignalkit.Sample::new(i, values[i])) is None,
    )
  }
}

///|
test "cusum detects sustained upward change" {
  let detector = @moonsignalkit.CusumDetector::new(10.0, 0.25, 4.0)
  let mut detected = false
  for i = 0; i < 6; i = i + 1 {
    match detector.push(@moonsignalkit.Sample::new(i, 12.0)) {
      Some(change) => {
        assert_true(change.direction == @moonsignalkit.Rising)
        assert_true(change.magnitude >= 4.0)
        detected = true
      }
      None => ()
    }
  }
  assert_true(detected)
}

///|
test "cusum detects sustained downward change" {
  let detector = @moonsignalkit.CusumDetector::new(20.0, 0.5, 5.0)
  let mut change : @moonsignalkit.ChangePoint? = None
  for i = 0; i < 5; i = i + 1 {
    match detector.push(@moonsignalkit.Sample::new(i, 18.0)) {
      Some(event) => change = Some(event)
      None => ()
    }
  }
  match change {
    Some(event) => {
      assert_true(event.direction == @moonsignalkit.Falling)
      assert_true(event.to_json().contains("\"direction\":\"falling\""))
    }
    None => fail("expected a falling change point")
  }
}

///|
test "moving average keeps exact rolling window semantics" {
  let series = @moonsignalkit.Series::new("window", [
    @moonsignalkit.Sample::new(0, 1.0),
    @moonsignalkit.Sample::new(1, 2.0),
    @moonsignalkit.Sample::new(2, 3.0),
    @moonsignalkit.Sample::new(3, 4.0),
    @moonsignalkit.Sample::new(4, 5.0),
  ])
  let result = series.moving_average(2)
  assert_eq(result.samples[0].value, 1.0)
  assert_eq(result.samples[1].value, 1.5)
  assert_eq(result.samples[2].value, 2.5)
  assert_eq(result.samples[3].value, 3.5)
  assert_eq(result.samples[4].value, 4.5)
}
