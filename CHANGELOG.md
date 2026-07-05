# Changelog

## 0.2.0 - 2026-07-06

### Added

- 新增基于 Welford 算法的 `OnlineMoments` 流式统计。
- 新增双向 `CusumDetector` 持续水平变化检测。
- 新增 `ChangePoint` 结构化事件及 JSON 导出。
- 新增确定性流式基准、相关工作和验收证据。
- 新增 Native、JavaScript、Wasm、Wasm-GC CI 矩阵。

### Changed

- 移动平均由 O(n × window) 优化为 O(n) 滚动窗口实现。
- 仓库地址统一为 `cn-wn/MoonSignalKit`。
- 修复 README、路线图和跟踪文档的中文乱码。

## 0.1.0 - 2026-06-11

- 初始化 `Sample`、`Series`、`Summary` 数据模型。
- 实现基础统计、归一化、平滑、差分、峰值和 Z-Score 异常检测。
- 增加 CLI、测试、CI 和公开协作模板。
