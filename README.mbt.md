# MoonSignalKit

MoonSignalKit 是面向 MoonBit 的流式遥测分析与变化检测基础库。它服务于传感器、
设备指标、性能监控和边缘计算等持续数据场景，在保留批量序列分析 API 的同时，
提供 O(1) 内存在线统计和双向 CUSUM 变化点检测。

## 核心价值

- **流式优先**：不保存完整历史即可持续更新均值、方差、极值和标准差。
- **变化检测**：识别被普通阈值和单点异常检测忽略的持续水平漂移。
- **数值稳定**：在线统计采用 Welford 单遍算法，避免平方和相减造成的精度损失。
- **后端中立**：核心库不依赖文件系统、浏览器、网络或平台 FFI。
- **可复现**：确定性测试和基准覆盖 Native、JavaScript、Wasm、Wasm-GC。

## 功能

- `Sample`、`Series`、`Summary` 批量数据模型
- 均值、方差、标准差、范围和 JSON 摘要
- O(n) 移动平均、指数平滑、Min-Max 归一化
- 差分、变化率、局部峰值和 Z-Score 异常点
- `OnlineMoments` 在线均值与方差
- `CusumDetector` 双向流式变化点检测
- `ChangePoint` 结构化事件与 JSON 导出

## 在线统计

```mbt nocheck
///|
test {
  let stats = OnlineMoments::new()
  stats.push(10.0)
  stats.push(12.0)
  stats.push(14.0)

  let summary = stats.summary()
  assert_eq(summary.count, 3)
  assert_eq(summary.mean, 12.0)
}
```

在线更新每个样本只需 O(1) 时间和 O(1) 内存，适合无法保留全部历史数据的长期任务。

## CUSUM 变化点检测

```mbt nocheck
///|
test {
  let detector = CusumDetector::new(
    10.0, // 正常目标水平
     0.25, // 可忽略的小幅漂移
     4.0, // 累积触发阈值
  )
  let mut detected = false
  for i = 0; i < 6; i = i + 1 {
    match detector.push(Sample::new(i, 12.0)) {
      Some(change) => {
        assert_true(change.direction == Rising)
        detected = true
      }
      None => ()
    }
  }
  assert_true(detected)
}
```

CUSUM 累积微小偏差，适合发现设备温度缓慢偏移、接口延迟基线抬升、传感器校准
漂移等“单个样本不异常，但过程已经改变”的问题。

## 运行

```bash
moon check --target all
moon test --target wasm
moon run cmd/main
moon run cmd/bench
```

## 项目边界

MoonSignalKit 不是音频合成器或完整频域 DSP 引擎。项目重点是可嵌入、跨后端、
低内存的遥测统计和在线过程监测。参见
[相关工作](docs/RELATED_WORK.md) 和 [验收证据](docs/ACCEPTANCE.md)。
