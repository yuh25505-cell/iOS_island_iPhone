# 构建与免费自签：现实边界

## 设备组合意味着什么

你只有 Android 电脑、Android 手机和 iPhone 15。原生 iOS App 的编译需要 Apple 的 Xcode 工具链（macOS）。Android 设备本身不能原生运行 Xcode。可行路线是把 Swift 项目放在 GitHub，由 GitHub Actions 的 macOS runner 编译。

## GitHub Actions

- GitHub-hosted macOS runner 可运行 Xcode，因此可用于 Swift/iOS 编译。
- 免费额度、并发、macOS 分钟倍率、仓库可见性与账户政策可能变化；以 GitHub 当前 Billing 页面为准。
- 建议先做 Simulator build（无需签名）验证工程，再研究 IPA 导出。
- Actions artifact 是构建产物，不等于已经签名、可安装的 IPA。
- 公开仓库不要提交证书、私钥、Provisioning Profile、Apple ID 密码。

## Apple 免费个人签名

- 免费 Apple Account 的个人开发签名通常存在有效期限制，常见为 7 天；过期后需要重新签名/安装。
- 设备端需要信任开发者证书；具体菜单随 iOS 版本变化。
- 免费个人团队的能力、App ID、设备数量、扩展等有额外限制；WidgetKit Extension 等目标可能增加配置复杂度。
- 以 Apple 当前 membership / code signing 文档和你实际账号的 Xcode 签名结果为准。
- 不要把“免费”理解为永久安装、后台无限刷新或免掉所有证书限制。

## AltLoad / altpair 核查结果（重要）

你描述的 AltLoad 流程并非 Apple 官方方案。其公开仓库 README 声称需要 iOS 27+、Developer Mode、rootshell、Open Minis、LocalDevVPN，并用 Apple ID 完成签名。README 还明确列出多项尚未在真实 iPhone 上验证的环节，包括 iOS 27 自配对、VPN 回环、Apple ID 登录和安装全流程。

安全建议：
1. 不要直接把常用 Apple ID 密码输入未经审计的第三方脚本。
2. 先检查 GitHub 仓库源码、release、安装脚本、依赖和 issue。
3. 若决定测试，使用专用 Apple Account，启用双重认证，绝不复用密码。
4. 不要在 GitHub Actions 日志、聊天记录或仓库中存放 Apple ID 密码。
5. 对 anisette 服务、VPN 配置和本地网络权限保持谨慎。
6. 任何“100%稳定”“永久签名”“完全模拟系统”的宣传都应独立验证。

## 官方/项目链接

- Apple membership：<https://developer.apple.com/programs/>
- Membership 对比：<https://developer.apple.com/support/compare-memberships/>
- Code signing：<https://developer.apple.com/documentation/xcode/code-signing>
- GitHub macOS runners：<https://docs.github.com/en/actions/using-github-hosted-runners/about-github-hosted-runners>
- GitHub Actions billing：<https://docs.github.com/en/billing/managing-billing-for-your-products/about-billing-for-github-actions>
- AltLoad README：<https://github.com/mirazbakis/AltLoad/blob/main/altpair/README.md>
