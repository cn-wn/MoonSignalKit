# MoonSignalKit Pipeline Example

一个典型的信号处理流程：

```moonbit
let normalized = series.normalize_minmax()
let smoothed = normalized.moving_average(5)
let rate = smoothed.rate_of_change()
let peaks = smoothed.peaks(0.8)
let outliers = series.outliers(2.0)
```

这个流程可以用于传感器读数、请求延迟、CPU 负载、内存曲线和简单实验数据。
