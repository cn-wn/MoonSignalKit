# 相关工作与项目边界

检索日期：2026-07-06。

- [`dowdiness/moondsp`](https://mooncakes.io/docs/dowdiness/moondsp) 是 MoonBit
  音频 DSP 引擎，重点在音频信号处理。MoonSignalKit 面向传感器和系统遥测，重点是
  在线统计、过程漂移和结构化变化事件。
- [`mizchi/signals`](https://mooncakes.io/docs/mizchi/signals) 是响应式状态信号库，
  “signal”表示 UI/状态依赖传播，不处理数值时间序列。
- MoonBit 标准库提供数组和数学运算，但不提供遥测语义、在线统计状态机或 CUSUM
  事件模型。

MoonSignalKit 的核心边界是：以 O(1) 内存处理持续数值流，输出可供告警、日志和
可视化系统消费的统计摘要与变化事件。项目不承担音频合成、FFT 全家桶、UI 响应式
状态或平台 IO。
