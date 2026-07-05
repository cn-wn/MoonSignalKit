# MoonSignalKit Pipeline Example

批量分析可以将归一化、平滑、变化率和异常检测组合成数据处理流水线：

```moonbit
let normalized = series.normalize_minmax()
let smoothed = normalized.moving_average(5)
let rate = smoothed.rate_of_change()
let peaks = smoothed.peaks(0.8)
let outliers = series.outliers(2.0)
```

持续遥测则使用不保存历史的状态对象：

```moonbit
let stats = OnlineMoments::new()
let detector = CusumDetector::new(50.0, 0.2, 6.0)

for sample in incoming_samples {
  stats.push(sample.value)
  match detector.push(sample) {
    Some(change) => handle_change(change)
    None => ()
  }
}
```

典型场景包括传感器读数、请求延迟、CPU 负载、能耗曲线和设备健康监测。
