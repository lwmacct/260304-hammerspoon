-- modules/spacebar.lua
-- 菜单栏显示当前虚拟桌面编号 (1、2、3...)
local spaceBar = hs.menubar.new()
spaceBar:setTitle("?")

local function updateSpaceNumber()
    local screen = hs.screen.mainScreen()
    -- 如果你想跟随鼠标所在屏幕，改成：local screen = hs.mouse.getCurrentScreen()

    local spaceList = hs.spaces.spacesForScreen(screen)
    local currentID = hs.spaces.focusedSpace()

    if not spaceList or not currentID then
        spaceBar:setTitle("?")
        return
    end

    for i, sid in ipairs(spaceList) do
        if sid == currentID then
            spaceBar:setTitle(" " .. i .. " ")
            return
        end
    end
    spaceBar:setTitle("?")
end

local spaceWatcher = hs.spaces.watcher.new(updateSpaceNumber)
spaceWatcher:start()

local screenWatcher = hs.screen.watcher.new(updateSpaceNumber)
screenWatcher:start()

updateSpaceNumber()

print("✅ 虚拟桌面编号菜单栏模块已启动...")

