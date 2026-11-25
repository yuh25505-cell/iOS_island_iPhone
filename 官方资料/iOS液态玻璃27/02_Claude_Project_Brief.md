# 给 Claude 的项目任务书：原生 iOS「小手机」桌面体验

你是本项目的 iOS 原生工程师。请直接在当前 GitHub 仓库中工作，并使用 GitHub Actions 的 macOS runner 构建 IPA。用户没有 Mac，只有 Android 电脑、Android 手机，以及一台 iPhone 15（用户报告系统为 iOS 27）。用户预算为零，不购买 Apple Developer Program，不使用网页套壳，不做上架准备。

## 0. 先读资料，不要立即盲目写代码

先阅读仓库中的 `01_Apple_Official_Document_Index.md`，优先读完以下 Apple 官方资料：
1. Liquid Glass 技术总览
2. Adopting Liquid Glass
3. HIG Materials
4. Applying Liquid Glass to custom views
5. GlassEffectContainer
6. WWDC25 Meet Liquid Glass
7. WWDC25 Build a SwiftUI app with the new design
8. Landmarks 官方示例

每个 API 都必须核对当前 SDK 文档和 iOS deployment target。不要杜撰 API，不要把旧版 `.ultraThinMaterial` 冒充 Liquid Glass。

## 1. 项目定义

制作一个完全原生的 iOS App（Swift + SwiftUI 为主，必要时少量 UIKit），App 内部呈现一个可交互的“iPhone 小手机/主屏幕模拟器”。

这不是系统 Launcher，不是 SpringBoard 替代品，不是网页，不是 WebView 套壳，不修改真实 iOS 主屏幕，也不尝试越狱或私有 API。

目标是让用户打开 App 后看到一个尽可能贴近 Apple 公开 iOS 设计语言的模拟主屏幕，并可进入一组内置模拟 App。视觉目标以用户提供的真实 iPhone 15/iOS 版本截图为最终校准依据；没有截图时先做高保真、可持续迭代的原生实现，不宣称像素级一致。

## 2. 技术与约束

- 原生：Swift、SwiftUI、必要时 UIKit。
- 不用 HTML、CSS、JavaScript、React Native、Flutter、WebView。
- 不用私有 API、越狱、系统注入、SpringBoard 替换。
- 不复制 Apple 未授权的专有图标/壁纸/系统资源；使用 SF Symbols、自己绘制的通用图标、用户自有壁纸或合法素材。
- 不冒用 Apple 官方 App 品牌进行误导；模拟应用可用通用名称/图标，或明确标记为演示。
- 支持 iPhone 15 屏幕、安全区、动态字体、深色/浅色外观、Reduce Transparency、Reduce Motion、增加对比度。
- 代码模块化、可编译、可测试；每个阶段提交清晰 commit。
- 所有密钥不得写入源码、日志或 artifact；绝不把 Apple ID 密码放入 GitHub Actions Secrets 或第三方脚本中。

## 3. 主屏幕（App 内模拟）

实现以下能力：
- 全屏沉浸式主屏幕画布，尊重状态栏/安全区，不伪造真实系统状态栏权限。
- 壁纸层：用户可选内置原创渐变/抽象壁纸，支持裁切、模糊、深浅色适配。
- App 图标网格：可配置列数、图标尺寸、圆角、标签、页面分页。
- Dock：底部固定区域，图标点击打开对应模拟 App。
- 页面指示器、左右滑动切换页面。
- 长按进入编辑模式；图标抖动、拖动排序、跨页移动、删除/添加演示图标。
- 文件夹：创建、重命名、打开/关闭、内部图标网格。
- 搜索/应用库式列表：本地过滤内置模拟 App。
- 小组件：小/中/大等 App 内尺寸卡片，支持拖放摆放、编辑配置、堆叠/切换、点击进入功能页。
- 保存用户布局（SwiftData 或 Codable + AppStorage，按复杂度选择）。
- 动画要流畅，遵循 Reduce Motion。

## 4. 内置模拟 App 清单

先做统一的 App Registry / Router，避免每个图标硬编码跳转。以下为建议的第一批功能模块，每个都必须有可操作的页面，而不是只有静态截图：

1. 电话：拨号键盘、最近通话、联系人（仅本地演示数据；不擅自拨打电话）
2. 信息：会话列表、聊天详情、输入框（本地模拟，不发送真实短信）
3. Safari 风格浏览器：地址栏、标签页、收藏夹；默认只做安全的演示页面，不伪装成真正系统 Safari
4. 照片：相册网格、照片详情、收藏、选择模式（使用用户导入/原创占位素材）
5. 相机：仅做界面演示；若调用真实相机，必须明确请求权限并正确处理
6. 设置：分组列表、搜索、详情页、开关与选择项；仅修改本 App 的偏好，不声称修改 iOS 系统设置
7. 日历：月/周/日视图、本地演示事件
8. 时钟：世界时钟、计时器、秒表、闹钟 UI；不宣称后台闹钟完全等同系统时钟
9. 天气：使用明确标记的演示数据；若未来接入天气 API，先征求用户并处理密钥/隐私
10. 备忘录：列表、编辑、搜索、文件夹、本地持久化
11. 提醒事项：清单、完成状态、日期 UI、本地持久化
12. 音乐：本地演示播放器 UI；未提供合法音源时不播放受版权保护歌曲
13. 地图：静态演示地图/路线界面；若使用 MapKit，遵守 Apple API 和隐私要求
14. App Store 风格商店：仅做本地目录 UI，不提供真实购买/下载
15. 文件：本地 App 沙盒文件列表、预览、导入/导出
16. 计算器：可用计算逻辑
17. 健康：只做演示 UI，不采集/推断健康数据
18. 钱包：仅演示卡片 UI，不存储真实银行卡/支付凭据
19. 控制中心风格面板：仅控制 App 内亮度/主题/音量模拟状态，不能控制 iOS 系统
20. 通知中心风格面板：只展示 App 内通知，不读取系统通知

每个模块要有：列表/详情状态、空状态、加载/错误状态、可访问性标签、持久化（适用时）、返回路径、深色模式。

## 5. Liquid Glass 实施原则

- 优先使用系统 SwiftUI/UIKit 标准控件，让系统自动应用当前 iOS 外观。
- 自定义浮层控件、导航控件、工具栏、底部操作栏等少数关键位置使用官方 `glassEffect` API。
- 用 `GlassEffectContainer` 管理需要融合/形变的一组玻璃元素；不要把所有卡片都玻璃化。
- `regular` 用于文字多、需要更稳健可读性的控件；`clear` 只用于背景丰富且对比度可控的浮动控件。
- 玻璃是功能/导航层，不是内容底板；内容区使用适当的系统标准材质或普通背景。
- 处理明暗背景、动态色、文本对比度、Reduce Transparency、Increase Contrast、Reduce Motion。
- 避免用简单 `.blur` + 半透明白色矩形假称 Liquid Glass。
- 动画包括按压反馈、形状融合、页面转场、编辑模式进入/退出；节制使用，优先系统行为。
- 对 iOS 版本做 `#available` 分支；低版本降级到系统 Material，不可因 API 不存在导致整个项目无法编译。

## 6. 建议工程结构

```text
App/
  SmallPhoneApp.swift
  AppRootView.swift
  DesignSystem/
    GlassTokens.swift
    Typography.swift
    ColorTokens.swift
    MotionTokens.swift
  HomeScreen/
    HomeScreenView.swift
    AppIconView.swift
    DockView.swift
    PageIndicatorView.swift
    EditMode/
    Folders/
    Widgets/
  AppCatalog/
    AppRegistry.swift
    AppRoute.swift
    AppIconAsset.swift
  Apps/
    Phone/
    Messages/
    Browser/
    Photos/
    Camera/
    Settings/
    Calendar/
    Clock/
    Weather/
    Notes/
    Reminders/
    Music/
    Maps/
    StoreDemo/
    Files/
    Calculator/
    HealthDemo/
    WalletDemo/
    ControlCenterDemo/
    NotificationCenterDemo/
  Persistence/
  Accessibility/
  Tests/
```

## 7. 交付阶段（每阶段必须能编译）

阶段 A：检查仓库、确定 bundle ID、deployment target、Xcode/Swift 版本，搭建空白原生 SwiftUI App，先让 Actions 编译成功。
阶段 B：设计系统 tokens、壁纸、图标网格、Dock、分页和首页布局。
阶段 C：编辑模式、拖拽、文件夹、搜索、持久化。
阶段 D：小组件系统（App 内自定义组件，不混淆 WidgetKit 系统桌面组件）。
阶段 E：逐个实现上述模拟 App，按模块提交。
阶段 F：完善 Liquid Glass、动画、可访问性、深浅色、设备适配。
阶段 G：测试、修复、生成 IPA artifact、写清安装步骤与签名限制。

每阶段结束时：
- 运行 build/test；
- 修复编译错误，不把错误留给用户；
- 输出改动文件数量与文件清单；
- 更新 README 和 CHANGELOG；
- 说明已完成、未完成、已知限制。

## 8. GitHub Actions 要求

- 使用 GitHub 官方 macOS runner 和 Xcode。
- 先实现不依赖签名的 Simulator build，确保源码可编译。
- IPA 导出/签名与构建分离；没有合法证书/描述文件时，不要伪造签名成功。
- 不在公开日志打印证书、私钥、Apple ID、密码、Provisioning Profile 内容。
- 为免费个人签名提供独立说明：签名过期、设备信任、刷新步骤与限制。
- Workflow 失败时输出明确诊断，不循环重试消耗额度。
- 只用 GitHub Actions 当前可用的免费额度；达到限额后停止，不要求用户付费。

## 9. 最终验收

- App 是真正原生 iOS binary，不是网页壳。
- iPhone 15 上可安装并运行。
- 主屏幕模拟器可滑动分页、打开图标、编辑排序、创建文件夹、使用小组件。
- 每个已声明完成的模拟 App 都有真实交互逻辑。
- Liquid Glass 使用公开 API，且不会过度使用。
- 无私有 API、无越狱依赖、无未经授权的系统资源。
- 所有功能准确标注“App 内模拟”与“真实系统能力”的区别。
- 仓库有可复现构建 workflow、构建产物说明、安装说明、限制说明。

现在先检查仓库与当前文件，给出实施计划，然后完成阶段 A。不要一次性生成大量未经编译验证的代码。
