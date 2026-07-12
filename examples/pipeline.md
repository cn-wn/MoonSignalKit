# Telemetry pipeline

This runnable-style pipeline shows the intended production composition: import
portable telemetry, suppress isolated spikes, inspect a bounded recent window,
and detect sustained baseline shifts. It works unchanged on Native, JS, Wasm,
and Wasm-GC because the library has no platform I/O dependency.

```mbt nocheck
///|
test {
  let csv = "time,value\n0,20.0\n1,20.2\n2,80.0\n3,20.4"
  let series = @cn_wn/moonsignalkit.Series::from_csv("temperature", csv)
  match series {
    Ok(readings) => {
      let median = @cn_wn/moonsignalkit.MedianFilter::new(3)
      let window = @cn_wn/moonsignalkit.RollingWindow::new(60)
      let changes = @cn_wn/moonsignalkit.CusumDetector::new(20.0, 0.2, 4.0)
      for i = 0; i < readings.length(); i = i + 1 {
        let cleaned = median.push(readings.samples[i])
        window.push(cleaned)
        match changes.push(cleaned) {
          Some(event) => println(event.to_json())
          None => ()
        }
      }
      println("p95=\{window.quantile(950)}")
    }
    Err(error) => println(error)
  }
}
```

The CSV reader intentionally accepts the portable two-column `time,value`
format. It reports malformed rows instead of silently treating bad telemetry as
zero. Quoted CSV dialects and file/network I/O remain an integration-layer
responsibility so the MoonBit core stays portable.
