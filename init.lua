-- ==================== Hammerspoon 入口文件（init.lua） ====================
-- 这里只负责加载所有模块
print("🚀 Hammerspoon 启动中... 开始加载模块")

-- 模块
require("modules.1password") -- 1Password SSH 软链接
require("modules.spacebar") -- 菜单栏显示虚拟桌面编号

print("✅ 所有模块加载完成！")
