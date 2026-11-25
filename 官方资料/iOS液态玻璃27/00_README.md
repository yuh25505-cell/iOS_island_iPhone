# Apple Liquid Glass / iOS 原生 App 资料包

资料整理日期：2026-11-25  
用途：作为 Claude（通过 GitHub 仓库与 GitHub Actions）开发原生 iOS App 的官方资料索引和项目提示词。  
范围：Apple Developer 文档、Human Interface Guidelines、WWDC、Apple 官方示例代码，以及必要的构建/签名说明。

> 重要边界
> - 这不是 Apple 提供的 iOS 系统源码，也不是完整的 iOS 27 私有设计规范。Apple 没有公开 SpringBoard、锁屏、控制中心等系统的全部实现与私有资源。
> - 第三方 App 不能替换真实 iPhone 主屏幕，也不能获得系统级权限；本项目只能在 App 自己的窗口内制作一个可交互的“仿主屏幕/小手机”体验。
> - 使用公开 SwiftUI/UIKit API 可以高度接近公开的 Liquid Glass 设计语言，但无法承诺逐像素、逐动画与系统完全一致。
> - 本包提供的是官方文档索引链接，不打包复制 Apple 文档全文、图片或视频。
> - Apple ID 密码不要交给不可信脚本、第三方服务器或仓库 Actions。优先使用 Apple 官方签名流程；对任何第三方自签工具先审计源码。

## 文件清单

1. `00_README.md`：资料包说明和限制
2. `01_Apple_Official_Document_Index.md`：Apple 官方文档/视频/示例代码链接索引
3. `02_Claude_Project_Brief.md`：可直接交给 Claude 的完整项目任务书
4. `03_Build_and_Signing_Notes.md`：无 Mac、GitHub Actions、免费签名的现实边界
5. `04_Implementation_Checklist.md`：开发验收清单

## 最重要的官方入口

- Liquid Glass 总览：<https://developer.apple.com/documentation/TechnologyOverviews/liquid-glass>
- Adopting Liquid Glass：<https://developer.apple.com/documentation/TechnologyOverviews/adopting-liquid-glass>
- HIG Materials：<https://developer.apple.com/design/human-interface-guidelines/materials>
- SwiftUI 自定义 Liquid Glass：<https://developer.apple.com/documentation/swiftui/applying-liquid-glass-to-custom-views>
- WWDC25 Meet Liquid Glass：<https://developer.apple.com/videos/play/wwdc2025/219/>
- WWDC25 Build a SwiftUI app with the new design：<https://developer.apple.com/videos/play/wwdc2025/323/>
- Apple 示例 Landmarks：<https://developer.apple.com/documentation/swiftui/landmarks-building-an-app-with-liquid-glass>

请 Claude 在编码前先逐条阅读官方链接，并以当前 Xcode/iOS SDK 的 API 可用性为准，不要凭空创造 API。
