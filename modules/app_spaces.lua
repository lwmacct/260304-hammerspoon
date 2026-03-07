-- modules/app_spaces.lua
-- 应用启动后，将窗口移动到指定 Space（按应用路径匹配）
local spaces = require("hs.spaces")

local appToSpaceIndex = {
    ["/Applications/Visual Studio Code.app"] = 12,
    ["/Applications/WeChat.app"] = 2,
    ["/Applications/Telegram.app"] = 3,
}

local pendingTimers = {}

local function firstMovableWindow(app)
    local main = app:mainWindow()
    if main and main:isStandard() then
        return main
    end

    local wins = app:allWindows()
    for _, win in ipairs(wins) do
        if win and win:isStandard() then
            return win
        end
    end
end

local function resolveTargetSpace(targetIndex, win)
    local checked = {}
    local candidates = {
        win and win:screen() or nil,
        hs.screen.mainScreen(),
    }

    for _, screen in ipairs(candidates) do
        if screen then
            local key = screen:getUUID() or tostring(screen)
            if not checked[key] then
                checked[key] = true
                local list = spaces.spacesForScreen(screen)
                if list and list[targetIndex] then
                    return list[targetIndex]
                end
            end
        end
    end
end

local function stopTimer(pid)
    if pendingTimers[pid] then
        pendingTimers[pid]:stop()
        pendingTimers[pid] = nil
    end
end

local function scheduleMove(app, targetIndex, appPath)
    local pid = app:pid()
    stopTimer(pid)

    local attempts = 0
    local maxAttempts = 20
    local interval = 0.5

    pendingTimers[pid] = hs.timer.doEvery(interval, function()
        attempts = attempts + 1

        if not app or not app:isRunning() then
            stopTimer(pid)
            return
        end

        local win = firstMovableWindow(app)
        if not win then
            if attempts >= maxAttempts then
                print(string.format("⚠️ App 已启动但未找到可移动窗口: %s", appPath))
                stopTimer(pid)
            end
            return
        end

        local targetSpace = resolveTargetSpace(targetIndex, win)
        if not targetSpace then
            print(string.format("⚠️ 找不到目标 Space：%s -> 第 %d 个", appPath, targetIndex))
            stopTimer(pid)
            return
        end

        local ok, err = spaces.moveWindowToSpace(win, targetSpace)
        if not ok then
            print(string.format("❌ 移动窗口失败: %s, err=%s", appPath, tostring(err)))
        else
            print(string.format("✅ 已移动窗口: %s -> Space %d", appPath, targetIndex))
        end

        stopTimer(pid)
    end)
end

appSpacesWatcher = hs.application.watcher.new(function(_, eventType, app)
    if eventType ~= hs.application.watcher.launched or not app then
        return
    end

    local appPath = app:path()
    if not appPath then
        return
    end

    local targetIndex = appToSpaceIndex[appPath]
    if not targetIndex then
        return
    end

    scheduleMove(app, targetIndex, appPath)
end)

appSpacesWatcher:start()

print("✅ App Spaces 自动分配模块已启动...")
