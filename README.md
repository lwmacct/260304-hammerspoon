# 260304-hammerspoon

Hammerspoon 配置集合，启动后会自动加载 `modules/` 下的模块。

## 使用方法

将项目克隆到 `~/.hammerspoon` 即可：

```bash
git clone https://github.com/lwmacct/260304-hammerspoon.git ~/.hammerspoon
```

然后打开 Hammerspoon，点击菜单栏图标并执行 `Reload Config`（或快捷键 `Cmd + Ctrl + R`）。

## 当前模块

- `modules/1password.lua`：创建 1Password SSH Agent 软链接
- `modules/spacebar.lua`：菜单栏显示当前虚拟桌面编号
- `modules/vscode.lua`：监听 VS Code 启动/退出并执行命令
- `modules/window.lua`：窗口管理（含快捷键）
