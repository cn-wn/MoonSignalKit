# Acceptance evidence

## Reproducible quality gates

The repository CI explicitly runs formatting, generated-interface, warning-free
checks, and tests. With MoonBit 0.10.4, run:

```bash
moon fmt --check
moon check --deny-warn --target all
moon info && git diff --exit-code -- '*.mbti'
moon test --deny-warn --target all
moon run cmd/main
moon run cmd/bench
```

Older acceptance wording names `moon fmt --deny-warn` and
`moon info --deny-warn`. The current CLI no longer exposes these flags. CI uses
them when they are available and otherwise uses the current non-mutating,
equivalent checks above.

## Functional boundary

MoonSignalKit is a portable telemetry-analysis library, not a full audio DSP,
FFT, visualization, storage, or network stack. Its production-facing boundary
is intentionally focused on reusable numerical components:

- batch series summaries, transformations, rates, peaks, and Z-score outliers;
- bounded rolling windows with chronological eviction and exact quantiles;
- EWMA and median filtering;
- resilient `time,value` CSV import/export;
- O(1)-memory online statistics and two-sided CUSUM change events; and
- timestamp gap and out-of-order sample detection without moving a timing
  baseline backwards.

Tests cover empty inputs, bounded eviction, quantiles, CSV errors, online versus
batch agreement, CUSUM noise/change paths, and timestamp gaps/late arrivals.

## Complexity and benchmark contract

| Operation | Time | Extra memory |
| --- | --- | --- |
| Online moments update | O(1) | O(1) |
| CUSUM update | O(1) | O(1) |
| Timestamp observation | O(1) | O(1) |
| EWMA update | O(1) | O(1) |
| Rolling push | O(1) | O(window) |
| Exact rolling quantile | O(window log window) | O(window) |

`moon run cmd/bench` processes 100,000 deterministic samples. The benchmark
retains a configured 256-sample rolling window, so the published output must
report `retained_samples=256` after warm-up. Online moments and CUSUM themselves
do not retain historical raw samples. See [BENCHMARK.md](BENCHMARK.md).

## Portability

The GitHub Actions matrix exercises Native, JavaScript, Wasm, and Wasm-GC. The
core package deliberately has no platform I/O or FFI dependency, allowing one
API to run in servers, command-line tools, embedded-style simulations, and Web
assembly views.
