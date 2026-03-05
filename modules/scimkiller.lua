local M = {}
local targets = { "SCIM", "SCIM_Extension", "TCIM", "TCIM_Extension" }

local function restartDock()
  hs.task.new("/usr/bin/killall", nil, { "Dock" }):start()
end

local function killIME()
  for _, name in ipairs(targets) do
    hs.task.new("/usr/bin/pkill", nil, { "-9", name }):start()
  end

  restartDock()
  hs.notify
    .new({
      title = "SCIMKiller",
      informativeText = "Killed SCIM/TCIM processes and restarted Dock",
    })
    :send()
end

-- Keep references on module table so GC cannot reclaim them.
M.menubar = hs.menubar.new()
M.menubar:setTitle("IME")
M.menubar:setTooltip("Kill SCIM/TCIM and extensions, then restart Dock")
M.menubar:setMenu({
  { title = "Kill SCIM/TCIM now", fn = killIME },
  { title = "-" },
  { title = "Hotkey: Ctrl + Alt + Cmd + K", disabled = true },
})

M.hotkey = hs.hotkey.bind({ "ctrl", "alt", "cmd" }, "K", killIME)
M.killIME = killIME

return M


