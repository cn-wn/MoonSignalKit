# MoonSignalKit

MoonSignalKit is a MoonBit-native, dependency-light time-series and streaming
telemetry analysis library. It is designed for sensor telemetry, device health,
application metrics, edge computing, and WebAssembly dashboards: one API works
on Native, JavaScript, Wasm, and Wasm-GC.

## Why it matters to MoonBit

MoonBit has portable collection and numeric primitives, but it does not provide
a domain library for bounded telemetry windows, online moments, robust filtering,
change detection, and portable telemetry interchange. MoonSignalKit fills that
gap without filesystem, network, browser, or FFI dependencies, so the same core
can run beside an edge device, in a server-side simulation, or in a WebAssembly
monitoring view.

## Production-oriented capabilities

- Batch series operations: summaries, normalization, moving average, EMA,
  difference, rate of change, peaks, and Z-score outliers.
- Constant-memory streaming: numerically stable Welford online moments and
  two-sided CUSUM change-point events.
- Bounded rolling windows: chronological eviction, stable summaries, exact
  nearest-rank quantiles, and median.
- Streaming filters: O(1)-memory EWMA and bounded median spike suppression.
- Portable `time,value` CSV import/export with explicit malformed-input errors.
- Deterministic CLI scenario and 100k-sample operation-count benchmark.

## Quick start

```mbt check
///|
test {
  let window = @cn_wn/moonsignalkit.RollingWindow::new(5)
  window.push(@cn_wn/moonsignalkit.Sample::new(0, 42.0))
  window.push(@cn_wn/moonsignalkit.Sample::new(1, 43.0))
  assert_eq(window.median(), 42.0)
}
```

## Runnable examples and benchmark

```bash
moon run cmd/main       # sensor/metric analysis walkthrough
moon run cmd/bench      # deterministic 100,000-sample streaming scenario
moon test --target js   # JavaScript backend verification (requires Node)
```

See [examples/pipeline.md](examples/pipeline.md) for a telemetry pipeline that
combines CSV, filters, rolling quantiles, and CUSUM.

## Quality gates

```bash
moon check --target all
moon fmt --check
moon info && git diff --exit-code -- '*.mbti'
moon test --target wasm
```

Older contest feedback mentions `moon fmt --deny-warn` and
`moon info --deny-warn`. The current MoonBit CLI (`moon 0.1.20260522`) no
longer accepts those flags: `moon fmt --check` is the non-mutating format gate,
while `moon info` followed by a clean generated-interface diff is the supported
public-API gate. CI uses exactly these current commands.

## Scope and related work

This is a numeric telemetry library, not a full audio DSP engine, FFT suite,
reactive UI signal library, or platform I/O framework. See
[README.mbt.md](README.mbt.md), [related work](docs/RELATED_WORK.md), and the
[acceptance evidence](docs/ACCEPTANCE.md) for details.

Licensed under [Apache-2.0](LICENSE).
