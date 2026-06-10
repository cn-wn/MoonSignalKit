# MoonSignalKit

MoonSignalKit 是一个面向 MoonBit 的时间序列与信号处理基础库。

项目方向和前面的 MoonNavKit、MoonSketchKit、MoonLexKit、MoonChartKit 都不同。它聚焦序列统计、平滑、归一化、差分、峰值检测和轻量数据报告，适合传感器数据、日志指标、性能采样、教学算法和数据分析工具复用。

GitHub 仓库地址：[cn-wn/-MoonSignalKit](https://github.com/cn-wn/-MoonSignalKit)。

## 当前能力

- 时间序列数据模型：`Sample`、`Series`
- 统计摘要：count、min、max、mean、range、variance、std_dev
- 预处理：Min-Max 归一化、移动平均、指数平滑
- 变化分析：差分、变化率
- 检测能力：局部峰值检测、Z-Score 异常点检测
- 报告输出：统计摘要 JSON
- CLI 演示：`moon run cmd/main`

## 快速开始

```bash
moon test
moon run cmd/main
```

```moonbit
let series = @moonsignalkit.Series::new("sensor", [
  @moonsignalkit.Sample::new(0, 10.0),
  @moonsignalkit.Sample::new(1, 12.0),
  @moonsignalkit.Sample::new(2, 30.0),
])

let smoothed = series.moving_average(3)
let peaks = series.peaks(20.0)
let report = series.summary_json()
```

## 设计原则

- 后端中立：核心库不依赖文件系统、浏览器或平台 IO
- 数值透明：阈值、窗口和归一化规则明确可测
- 组合使用：统计、平滑、差分、峰值和异常检测可以自由组合
- 可追踪开发：提交记录、Issue、PR、CHANGELOG 和 CI 围绕公开仓库维护
