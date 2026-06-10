# 公开开发跟踪

MoonSignalKit 按公开仓库持续开发方式推进，核心证据包括提交记录、Issue、Pull Request、CHANGELOG、ROADMAP 和 CI。

## 当前提交主题

- 基础骨架与仓库元数据
- 方差与标准差统计
- Min-Max 归一化
- 移动平均平滑
- 指数平滑
- 差分与变化率
- 局部峰值检测
- Z-Score 异常点检测
- 统计摘要 JSON 导出
- CLI 演示
- CI 与协作模板
- README、路线图和更新日志

## 后续工单建议

1. 支持中位数和分位数
2. 支持滚动窗口摘要
3. 支持 Hampel 异常检测
4. 增加 CSV 导入导出
5. 增加 WebAssembly 示例

## 合并请求建议

- `feat/rolling-summary`
- `feat/median-percentile`
- `feat/hampel-filter`
- `io/csv-series`
