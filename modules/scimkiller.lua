-- ~/.hammerspoon/init.lua
local targets = { "SCIM", "SCIM_Extension", "TCIM", "TCIM_Extension" }

local function restartDock()
  hs.task.new("/usr/bin/killall", nil, { "Dock" }):start()
end

local function killIME()
  for _, name in ipairs(targets) do
    hs.task.new("/usr/bin/pkill", nil, { "-9", name }):start()
  end
  restartDock()
  hs.notify.new({
    title = "SCIMKiller",
    informativeText = "Killed SCIM/TCIM processes and restarted Dock",
  }):send()
end

-- 菜单栏按钮（左键直接执行）
local mb = hs.menubar.new()
mb:setTitle("IME")
mb:setClickCallback(killIME)
mb:setTooltip("Kill SCIM/TCIM and extensions, then restart Dock")

-- 快捷键：Ctrl + Alt + Cmd + K
hs.hotkey.bind({ "ctrl", "alt", "cmd" }, "K", killIME)
