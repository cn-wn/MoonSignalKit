///|
test "csv export and import preserve telemetry samples" {
  let original = @moonsignalkit.Series::new("cpu", [
    @moonsignalkit.Sample::new(10, 1.5),
    @moonsignalkit.Sample::new(20, 2.25),
  ])
  let csv = original.to_csv()
  assert_true(csv.contains("time,value"))
  match @moonsignalkit.Series::from_csv("cpu-copy", csv) {
    Ok(imported) => {
      assert_eq(imported.length(), 2)
      assert_eq(imported.samples[1].time, 20)
      assert_eq(imported.samples[1].value, 2.25)
    }
    Err(_) => fail("expected portable CSV to import")
  }
}

///|
test "csv import reports useful malformed input errors" {
  match @moonsignalkit.Series::from_csv("bad", "time,value\n1,nope") {
    Err(@moonsignalkit.InvalidValue(2)) => ()
    _ => fail("expected invalid value on line 2")
  }
  match @moonsignalkit.Series::from_csv("bad", "time,value\n1") {
    Err(@moonsignalkit.MissingColumns(2)) => ()
    _ => fail("expected missing columns on line 2")
  }
}
