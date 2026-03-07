-- modules/app_spaces.lua
-- 应用启动后，将窗口移动到指定 Space（按应用路径匹配）
local spaces = require("hs.spaces")

local appToSpaceIndex = {
    ["/Applications/Visual Studio Code.app"] = 12,
    ["/Applications/Code.app"] = 12,
    ["/Applications/WeChat.app"] = 2,
    ["/Applications/微信.app"] = 2,
    ["/Applications/Telegram.app"] = 3,
}

local appNameToSpaceIndex = {
    ["Visual Studio Code"] = 12,
    ["Code"] = 12,
    ["WeChat"] = 2,
    ["微信"] = 2,
    ["Telegram"] = 3,
    ["Telegram Desktop"] = 3,
}

local pendingTimers = {}

local function hasValue(tbl, expected)
    for _, value in ipairs(tbl or {}) do
        if value == expected then
            return true
        end
    end
    return false
end

local function listToString(tbl)
    if not tbl or #tbl == 0 then
        return "[]"
    end

    local out = {}
    for i, value in ipairs(tbl) do
        out[i] = tostring(value)
    end
    return "[" .. table.concat(out, ", ") .. "]"
end

local function spaceTypeSafe(spaceID)
    if not spaceID then
        return "unknown"
    end
    local ok, value = pcall(spaces.spaceType, spaceID)
    if ok and value then
        return tostring(value)
    end
    return "unknown"
end

local function firstMovableWindow(app)
    local main = app:mainWindow()
    if main and main:isStandard() and main:id() then
        return main
    end

    local wins = app:allWindows()
    for _, win in ipairs(wins) do
        if win and win:isStandard() and win:id() then
            return win
        end
    end
end

local function resolveTargetSpace(targetIndex, win)
    local checked = {}
    local candidates = {
        hs.screen.mainScreen(),
        win and win:screen() or nil,
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
    local maxAttempts = 40
    local interval = 0.4

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

        local wins = app:allWindows()
        local moved = false
        local errMsg = nil

        for _, eachWin in ipairs(wins) do
            if eachWin and eachWin:isStandard() and eachWin:id() then
                if eachWin:isMinimized() then
                    eachWin:unminimize()
                end

                local winID = eachWin:id()
                local before = spaces.windowSpaces(winID) or {}
                if hasValue(before, targetSpace) then
                    moved = true
                else
                    local ok, err = spaces.moveWindowToSpace(winID, targetSpace, true)
                    if not ok then
                        errMsg = tostring(err)
                    end
                end

                local after = spaces.windowSpaces(winID) or {}
                if hasValue(after, targetSpace) then
                    moved = true
                    print(
                        string.format(
                            "✅ 已移动窗口: %s -> Space %d (targetID=%s, targetType=%s, before=%s, after=%s)",
                            appPath,
                            targetIndex,
                            tostring(targetSpace),
                            spaceTypeSafe(targetSpace),
                            listToString(before),
                            listToString(after)
                        )
                    )
                    break
                end
            end
        end

        if moved then
            stopTimer(pid)
            return
        end

        if attempts >= maxAttempts then
            print(
                string.format(
                    "⚠️ moveWindowToSpace 未生效: %s (targetID=%s, targetType=%s, separateSpaces=%s, lastErr=%s)",
                    appPath,
                    tostring(targetSpace),
                    spaceTypeSafe(targetSpace),
                    tostring(spaces.screensHaveSeparateSpaces()),
                    tostring(errMsg)
                )
            )
            stopTimer(pid)
        end
    end)
end

appSpacesWatcher = hs.application.watcher.new(function(_, eventType, app)
    if eventType ~= hs.application.watcher.launched or not app then
        return
    end

    local appPath = app:path()
    local targetIndex = appPath and appToSpaceIndex[appPath] or nil
    if not targetIndex then
        local appName = app:name()
        targetIndex = appName and appNameToSpaceIndex[appName] or nil
    end
    if not targetIndex then
        return
    end

    scheduleMove(app, targetIndex, appPath or (app:name() or "unknown-app"))
end)

appSpacesWatcher:start()

print("✅ App Spaces 自动分配模块已启动...")
