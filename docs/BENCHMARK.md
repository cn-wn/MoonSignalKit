# Reproducible benchmark

Run the deterministic scenario from the repository root:

```bash
moon run cmd/bench
```

It processes 100,000 generated telemetry samples through EWMA, a bounded
256-sample rolling window, Welford online moments, and CUSUM. It reports the
following CSV columns:

| Column | Meaning |
| --- | --- |
| `samples` | Number of generated input records (100,000). |
| `retained_samples` | Current bounded window size (256 after warm-up). |
| `mean`, `variance` | One-pass Welford statistics over every cleaned sample. |
| `p95` | Exact nearest-rank p95 over the bounded retained window. |
| `changes` | Sustained-level changes reported by CUSUM. |

This is an operation-count and correctness-reproducibility scenario, not a
cross-machine latency claim. It deliberately avoids fabricated milliseconds or
backend comparisons. Execute the same command under `moon run --target js`,
`moon run --target wasm`, or `moon run --target wasm-gc` when collecting
environment-specific measurements.
