# AIRP · Apple 视觉参考 + iOS 原生 App 开发资料包

整理日期：2026-11-25（由安卓版资料包改写）

## 这份资料包是做什么的
**用 iOS 原生技术（Swift + SwiftUI）制作 AIRP 小手机 App，并直接调用苹果公开的 Liquid Glass 接口。**
它不是网页开发资料，也不是 WebView 套壳教程。

岛屿机的整体默认基础 UI（配色、颜色、字体、间距、圆角、材质、动效、交互），一律以 Apple 官方文档为准，做到最大程度一样。App 只在自己手机上安装使用，不上架。

## 资料在哪里
- `官方资料/iOS液态玻璃/`：苹果官方资料链接索引、给 Claude 的项目任务书、构建与签名说明、验收清单。
- `island_AIRP.md`：岛屿机各模块和 iOS 实现方式的对照。

## 推荐技术路线
- 语言：Swift
- 原生界面：SwiftUI（必要时少量 UIKit）
- 系统能力：iOS SDK
- 桌面组件：WidgetKit
- 动画：SwiftUI Animation
- 主题：AIRP 自己的主题系统，支持日间、夜间、跟随系统和手动切换
- 构建：XcodeGen + GitHub Actions（macOS runner），输出未签名 ipa（只自己安装，不上架）

## 真实桌面组件 vs AIRP 内部模拟桌面
- 要放在手机真实桌面的组件：WidgetKit。
- 只显示在 AIRP 自己主屏幕页面内的组件：SwiftUI 自己绘制和管理。
- 第三方 App 无法取代系统主屏幕。

## Liquid Glass 在 iOS 上的实现提醒
- 直接用公开接口 `glassEffect()`、`GlassEffectContainer`、`.buttonStyle(.glass)`，不再自己重建。
- 不要给所有卡片都套玻璃；玻璃主要用于导航、工具栏、浮层和交互控件，普通内容区域保持清晰可读。
- 苹果没有公开系统主屏幕、锁屏等的私有实现，无法承诺和系统逐像素一致。

## 注意
本包是官方资料链接索引，不是 Apple 官方文档全文镜像。官方页面和 SDK 会更新，以 Apple Developer 当前页面为准。
