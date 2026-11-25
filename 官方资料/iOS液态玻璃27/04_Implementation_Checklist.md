# 实施与验收 Checklist

## 工程
- [ ] 原生 SwiftUI 工程，可在 GitHub macOS runner 编译
- [ ] bundle ID、最低系统版本、Xcode 版本写入 README
- [ ] 没有 WebView / HTML / CSS / JS / Flutter / React Native
- [ ] 没有私有 API、越狱或系统注入

## 首页
- [ ] 壁纸与安全区
- [ ] 图标网格、标签、分页
- [ ] Dock 与页面指示器
- [ ] 左右滑动
- [ ] 长按编辑、抖动、拖动排序
- [ ] 文件夹创建/编辑/关闭
- [ ] 搜索/应用列表
- [ ] 布局持久化

## App 内小组件
- [ ] 小/中/大尺寸
- [ ] 拖放、编辑、删除
- [ ] 点击跳转
- [ ] 数据状态与空状态
- [ ] 明确说明这是 App 内组件，不是系统桌面 Widget

## Liquid Glass
- [ ] 先用系统标准控件
- [ ] 关键浮层再使用 glassEffect
- [ ] GlassEffectContainer 用于合理的融合组
- [ ] regular / clear 使用场景正确
- [ ] 深浅色、对比度、Reduce Transparency、Reduce Motion 测试
- [ ] 未把普通 blur 冒充 Liquid Glass

## 内置 App
- [ ] 每个模块有交互、返回、状态与本地数据
- [ ] 不声称控制真实系统设置/通知/电话/短信/钱包
- [ ] 权限请求清晰、最小化
- [ ] 不使用未经授权的 Apple 图标、壁纸或专有资源

## 构建与安装
- [ ] GitHub Actions Simulator build 成功
- [ ] IPA 导出成功且签名状态可验证
- [ ] 未将密钥写入仓库或日志
- [ ] 免费签名有效期/刷新步骤写明
- [ ] iPhone 15 真机测试通过
- [ ] README、CHANGELOG、改动文件数量与清单更新
