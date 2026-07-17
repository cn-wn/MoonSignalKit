# MoonSignalKit

MoonSignalKit supplies portable time-series and streaming telemetry primitives
for MoonBit: batch summaries, bounded rolling quantiles, filters, CSV
interchange, online moments, timestamp monitoring, and two-sided CUSUM.

## Add to a project

```bash
moon add cn-wn/moonsignalkit
```

```mbt check
///|
test {
  let monitor = TimestampMonitor::new(10)
  let _first = monitor.observe(Sample::new(100, 1.0))
  let observation = monitor.observe(Sample::new(115, 1.0))
  assert_true(observation.is_gap)
}
```

The package has no filesystem, network, browser, or FFI dependency, so its API
is shared by Native, JavaScript, Wasm, and Wasm-GC targets. For full examples,
quality gates, scope, and related work, see the repository README.
