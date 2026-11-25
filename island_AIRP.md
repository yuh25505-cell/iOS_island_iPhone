# AIRP 模块与 iOS 原生开发资料对照

| AIRP 要做的部分 | 苹果参考 | iOS 原生实现 |
|---|---|---|
| AIRP 内部主屏幕 | App icons、Layout、Widgets HIG | SwiftUI LazyVGrid / ScrollView 分页、拖拽与状态管理 |
| 真正显示在手机桌面的组件 | Widgets HIG | WidgetKit（需额外的 Widget Extension，免费签名下有限制） |
| Liquid Glass 导航栏 | Materials、Navigation bars、Toolbars | 直接用 `glassEffect` / `GlassEffectContainer`（低版本降级 Material） |
| 软件页面 | Apple 各软件 HIG 模式 | SwiftUI 页面 + NavigationStack |
| 弹窗和底部面板 | Alerts、Sheets、Menus | 专属弹窗 UI（自己的 overlay）、sheet、Menu |
| 灵动岛风格区域 | Live Activities HIG | AIRP 内部自绘 SwiftUI 动态区域；真实灵动岛用 ActivityKit（另行评估） |
| 状态栏、刘海屏 | iOS Layout | 安全区（safe area）、沉浸式布局 |
| 日夜间与手动主题 | Dark Mode、Color | `AppearanceStore` + `preferredColorScheme`，UserDefaults 保存用户选择 |
| 动画 | Motion、WWDC | SwiftUI 弹簧动画、matchedGeometryEffect、`glassEffectID` |
| 安装包（只自己安装，不上架） | — | Xcode 编译 → 未签名 ipa → 自签工具签名安装 |

## 必须遵守的实现边界
- AIRP 内部仿 iPhone 桌面与真实 iOS 主屏幕（SpringBoard）是两种不同的东西：第三方 App 无法替换系统主屏幕。
- 需要真实桌面小组件时用 WidgetKit；仅在 AIRP 页面内显示时，SwiftUI 自绘即可。
- 玻璃效果用公开接口，需要考虑系统版本和“降低透明度”设置，提供降级方案。
- 每次开发应先完整检查项目结构和已有实现，再局部修改，避免覆盖无关代码。
