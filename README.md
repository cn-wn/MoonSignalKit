# MoonSignalKit

MoonSignalKit is a MoonBit-native library for streaming telemetry and compact
time-series analysis. It is intended for device metrics, sensor pipelines,
service health signals, edge processing, and WebAssembly monitoring views.
The same dependency-free API runs on Native, JavaScript, Wasm, and Wasm-GC.

## Why this library exists

MoonBit provides portable numeric and collection primitives, but application
authors still need bounded windows, online statistics, robust smoothing,
timestamp-quality checks, and sustained-change detection. MoonSignalKit turns
those recurring pieces into a typed, tested library rather than requiring every
application to reimplement them.

## Install

Add the published package to a MoonBit project:

```bash
moon add cn-wn/moonsignalkit
```

Then import it from the package that consumes it:

```mbt check
import {
  "cn-wn/moonsignalkit" @signal,
}
```

## Minimal call

This example keeps the newest three samples and asks for the median. It is a
complete black-box test body that can be copied into a consuming package.

```mbt check
///|
test {
  let window = @signal.RollingWindow::new(3)
  window.push(@signal.Sample::new(100, 41.0))
  window.push(@signal.Sample::new(101, 43.0))
  window.push(@signal.Sample::new(102, 42.0))
  assert_eq(window.median(), 42.0)
}
```

## Production-oriented capabilities

- Batch series analysis: summaries, normalization, moving average, EMA,
  difference, rate of change, peaks, and Z-score outliers.
- Bounded rolling windows with chronological eviction, exact nearest-rank
  quantiles, median, and stable summaries.
- Constant-memory Welford online moments and two-sided CUSUM level-shift
  detection for unbounded streams.
- EWMA smoothing and bounded median filtering for noisy measurements.
- `TimestampMonitor` for deterministic late-sample and sampling-gap detection;
  late arrivals never move the accepted timing baseline backwards.
- Portable `time,value` CSV import/export with explicit malformed-input errors.

## Runnable examples

The repository contains a deterministic telemetry walkthrough and a
100,000-sample operation-count benchmark:

```bash
moon run cmd/main
moon run cmd/bench
```

The benchmark intentionally retains a bounded 256-sample rolling window. Its
`retained_samples` column is therefore `256`, while online statistics and CUSUM
remain constant-memory. See [examples/pipeline.md](examples/pipeline.md) and
[benchmark notes](docs/BENCHMARK.md) for the reproducible scenario.

## Verification

```bash
moon fmt --check
moon check --deny-warn --target all
moon info && git diff --exit-code -- '*.mbti'
moon test --deny-warn --target all
```

MoonBit 0.10.4 no longer accepts `moon fmt --deny-warn` or
`moon info --deny-warn`. The non-mutating equivalents above are used locally;
CI detects and uses those flags on toolchains that still provide them.

## Scope

MoonSignalKit is not an audio DSP engine, FFT suite, reactive UI framework, or
platform I/O layer. It focuses on portable numerical telemetry primitives that
applications can compose with their own transports and storage. Related work,
license, and acceptance evidence are documented in
[README.mbt.md](README.mbt.md), [docs/RELATED_WORK.md](docs/RELATED_WORK.md),
and [docs/ACCEPTANCE.md](docs/ACCEPTANCE.md).

Licensed under [Apache-2.0](LICENSE).
