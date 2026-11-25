# Apple 官方文档与教程索引

整理日期：2026-11-25。全部链接指向 Apple Developer / Apple 官方 GitHub。按开发用途分类。Apple 的在线文档会持续更新；这是一份与 Liquid Glass 原生 App 项目直接相关的尽可能完整的索引，不代表 Apple 全站所有文档的穷尽镜像。

## A. Liquid Glass 核心（必读）

| 优先级 | 官方资料 | 用途 |
|---|---|---|
| P0 | [Liquid Glass 技术总览](https://developer.apple.com/documentation/TechnologyOverviews/liquid-glass) | 设计目标、平台行为、官方示例入口 |
| P0 | [Adopting Liquid Glass](https://developer.apple.com/documentation/TechnologyOverviews/adopting-liquid-glass) | 迁移/采用指南、系统组件、图标、导航、模态、工具栏 |
| P0 | [HIG — Materials](https://developer.apple.com/design/human-interface-guidelines/materials) | Liquid Glass 与标准材质的使用边界、regular/clear、对比度 |
| P0 | [SwiftUI — Applying Liquid Glass to custom views](https://developer.apple.com/documentation/swiftui/applying-liquid-glass-to-custom-views) | `glassEffect`、形状、tint、interactive、转场 |
| P0 | [SwiftUI — GlassEffectContainer](https://developer.apple.com/documentation/swiftui/glasseffectcontainer) | 多个玻璃元素合并、融合、性能与间距 |
| P1 | [SwiftUI — Glass](https://developer.apple.com/documentation/swiftui/glass) | Glass 类型与配置 |
| P1 | [SwiftUI — glassEffect(_:in:)](https://developer.apple.com/documentation/swiftui/view/glasseffect(_:in:)) | API 参考 |
| P1 | [SwiftUI — glassEffectID(_:in:)](https://developer.apple.com/documentation/swiftui/view/glasseffectid(_:in:)) | 玻璃元素身份与匹配动画 |
| P1 | [SwiftUI — glassEffectTransition(_:)](https://developer.apple.com/documentation/swiftui/view/glasseffecttransition(_:)) | 玻璃出现/消失转场 |
| P1 | [SwiftUI — GlassEffectTransition](https://developer.apple.com/documentation/swiftui/glasseffecttransition) | 转场类型 |
| P1 | [SwiftUI — GlassButtonStyle](https://developer.apple.com/documentation/swiftui/glassbuttonstyle) | 玻璃按钮样式 |
| P1 | [SwiftUI — GlassProminentButtonStyle](https://developer.apple.com/documentation/swiftui/glassprominentbuttonstyle) | 强调玻璃按钮 |
| P1 | [HIG — Color](https://developer.apple.com/design/human-interface-guidelines/color) | 语义色、动态色与对比度 |
| P1 | [HIG — Accessibility](https://developer.apple.com/design/human-interface-guidelines/accessibility) | 辅助功能与可读性 |

## B. WWDC 视频课程（强烈建议按顺序观看）

| 顺序 | 视频 | 重点 |
|---|---|---|
| 1 | [Meet Liquid Glass — WWDC25](https://developer.apple.com/videos/play/wwdc2025/219/) | 光学特性、动态、适应性、设计原则 |
| 2 | [WWDC25 视频目录](https://developer.apple.com/videos/wwdc2025/) | 在目录中搜索 “Design with the Liquid Glass design system”，以 Apple 当前发布的单集页面为准 |
| 3 | [Build a SwiftUI app with the new design — WWDC25](https://developer.apple.com/videos/play/wwdc2025/323/) | SwiftUI 结构、工具栏、搜索、控件、玻璃 API |
| 4 | [Build a UIKit app with the new design — WWDC25](https://developer.apple.com/videos/play/wwdc2025/284/) | UIKit 导航栏、标签栏、弹层、控件、自定义玻璃 |
| 5 | [WWDC25 视频总目录](https://developer.apple.com/videos/wwdc2025/) | 搜索 Liquid Glass、design system、app icons 等课程 |

注：第 2 项链接是目录搜索入口提示，不是保证存在的单集地址；请在 WWDC25 目录中按标题搜索，避免使用非官方转载。

## C. Apple 官方示例工程

| 示例 | 链接 | 用途 |
|---|---|---|
| Landmarks: Building an app with Liquid Glass | [文档与示例](https://developer.apple.com/documentation/swiftui/landmarks-building-an-app-with-liquid-glass) | 官方完整 SwiftUI 样例，玻璃效果、动画、图标与布局 |
| Apple Developer Sample Code | [样例代码总入口](https://developer.apple.com/documentation/) | 按框架/API 查找官方代码 |
| SwiftUI Tutorials | [SwiftUI Tutorials](https://developer.apple.com/tutorials/swiftui) | SwiftUI 基础、布局、状态与导航 |
| Develop in Swift Tutorials | [Develop in Swift](https://developer.apple.com/tutorials/develop-in-swift) | Swift/SwiftUI 学习路径 |
| Apple 官方开发者视频 | [Developer Videos](https://developer.apple.com/videos/) | 最新 WWDC 与技术课程 |

## D. SwiftUI 基础与 App 架构

- [SwiftUI 总览](https://developer.apple.com/documentation/swiftui)
- [App 结构](https://developer.apple.com/documentation/swiftui/app-organization)
- [Scenes](https://developer.apple.com/documentation/swiftui/scenes)
- [NavigationStack](https://developer.apple.com/documentation/swiftui/navigationstack)
- [NavigationSplitView](https://developer.apple.com/documentation/swiftui/navigationsplitview)
- [Toolbars](https://developer.apple.com/documentation/swiftui/toolbars)
- [Search](https://developer.apple.com/documentation/swiftui/search)
- [Sheets / Modal presentations](https://developer.apple.com/documentation/swiftui/modal-presentations)
- [Animations](https://developer.apple.com/documentation/swiftui/animations)
- [Gestures](https://developer.apple.com/documentation/swiftui/gestures)
- [Scroll views](https://developer.apple.com/documentation/swiftui/scroll-views)
- [Layout](https://developer.apple.com/documentation/swiftui/layout)
- [SF Symbols](https://developer.apple.com/sf-symbols/)
- [Human Interface Guidelines 总入口](https://developer.apple.com/design/human-interface-guidelines/)

## E. 小组件、桌面模拟与 App Intents

这里要区分两种东西：
- App 内部“桌面组件”：普通 SwiftUI View，可完全在 App 内模拟尺寸、编辑、拖动、堆叠与点击。
- 真正 iOS 主屏幕 Widget：必须使用 WidgetKit Extension，并受系统尺寸、交互和刷新规则限制；不能把任意完整 App 界面放到系统桌面。

官方资料：
- [WidgetKit](https://developer.apple.com/documentation/widgetkit)
- [Creating a widget extension](https://developer.apple.com/documentation/widgetkit/creating-a-widget-extension)
- [Widget configurations](https://developer.apple.com/documentation/widgetkit/widgetconfiguration)
- [WidgetKit timelines](https://developer.apple.com/documentation/widgetkit/timelineprovider)
- [App Intents](https://developer.apple.com/documentation/appintents)
- [App Shortcuts](https://developer.apple.com/documentation/appintents/app-shortcuts)
- [Interactive widgets](https://developer.apple.com/documentation/widgetkit/adding-interactivity-to-widgets-and-live-activities)
- [Live Activities](https://developer.apple.com/documentation/activitykit)

## F. App 图标、字体、图像与资源

- [Adopting Liquid Glass — App icons](https://developer.apple.com/documentation/TechnologyOverviews/adopting-liquid-glass#App-icons)
- [Icon Composer（随 Xcode 工具链提供）](https://developer.apple.com/icon-composer/)
- [SF Symbols](https://developer.apple.com/sf-symbols/)
- [Typography HIG](https://developer.apple.com/design/human-interface-guidelines/typography)
- [Images HIG](https://developer.apple.com/design/human-interface-guidelines/images)
- [Color HIG](https://developer.apple.com/design/human-interface-guidelines/color)

## G. UIKit 方向（可选，但有助于底层定制）

- [UIKit](https://developer.apple.com/documentation/uikit)
- [UIVisualEffectView](https://developer.apple.com/documentation/uikit/uivisualeffectview)
- [UIGlassEffect](https://developer.apple.com/documentation/uikit/uiglasseffect)
- [UIGlassContainerEffect](https://developer.apple.com/documentation/uikit/uiglasscontainereffect)
- [UIButton.Configuration](https://developer.apple.com/documentation/uikit/uibuttonconfiguration)
- [Human Interface Guidelines — Bars](https://developer.apple.com/design/human-interface-guidelines/bars)

## H. 构建、测试与分发

- [Xcode](https://developer.apple.com/xcode/)
- [Xcode Release Notes](https://developer.apple.com/documentation/xcode-release-notes)
- [Apple Developer Program](https://developer.apple.com/programs/)
- [Choosing a membership](https://developer.apple.com/support/compare-memberships/)
- [Running your app on a device](https://developer.apple.com/documentation/xcode/running-your-app-in-simulator-or-on-a-device)
- [Code signing](https://developer.apple.com/documentation/xcode/code-signing)
- [Provisioning profiles](https://developer.apple.com/help/account/provisioning-profiles/)
- [TestFlight](https://developer.apple.com/testflight/)（非必须；用户目标为自用侧载）
- [GitHub Actions — macOS hosted runners](https://docs.github.com/en/actions/using-github-hosted-runners/about-github-hosted-runners)
- [GitHub Actions — usage limits/billing](https://docs.github.com/en/billing/managing-billing-for-your-products/about-billing-for-github-actions)

## I. AltLoad / altpair（第三方项目，不是 Apple 官方）

- [AltLoad GitHub 仓库](https://github.com/mirazbakis/AltLoad)
- [altpair README（安装步骤、依赖、限制与安全说明）](https://github.com/mirazbakis/AltLoad/blob/main/altpair/README.md)
- [AltLoad 官网](https://altload.org/)

注意：仓库 README 明确列出了“尚未在真实 iPhone 上验证”的事项，包括 iOS 27 配对、LocalDevVPN 回环、完整 Apple ID 登录、签名和安装流程。因此不要把它当作已验证稳定方案。它涉及 Apple ID 登录与第三方 anisette 服务；不要在未审计源码前输入主 Apple ID 密码，建议使用专用 Apple ID，并自行评估风险。免费个人签名通常有 7 天有效期，具体以 Apple 当前规则与实际签名结果为准。
