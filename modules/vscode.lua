---@meta
_G.hs = _G.hs or {}

-- ===== VS Code 启动/退出 测试版（用 hs.alert，绝不会被权限挡住）=====

local vscodeBundleID = "com.microsoft.VSCode"

local function vscodeLaunched()
    print(os.date("%Y-%m-%d %H:%M:%S") .. " [Hammerspoon] VS Code 已启动")
    -- osascript -e 'display notification "VS Code 已启动" with title "Hammerspoon"'
    hs.execute([==[PATH=/opt/homebrew/bin:/usr/local/bin:$PATH

    cd /Volumes/Code/project/250427-docker-context || exit 1;
    docker compose -p srv-db up -d

  ]==])

end

local function vscodeTerminated()
    print(os.date("%Y-%m-%d %H:%M:%S") .. " [Hammerspoon] VS Code 已完全退出，准备执行命令")
    -- osascript -e 'display notification "VS Code 已完全退出" with title "Hammerspoon"'
    hs.execute([==[PATH=/opt/homebrew/bin:/usr/local/bin:$PATH

    docker context use default && docker ps -q | xargs -r  docker stop

  ]==])
    -- 这里以后放你的真实命令
    -- hs.execute("~/bin/vscode-did-quit.sh")
end

local vscodeWatcher = hs.application.watcher.new(function(appName, eventType, app)
    if app:bundleID() ~= vscodeBundleID then
        return
    end

    if eventType == hs.application.watcher.launched then
        vscodeLaunched()
    elseif eventType == hs.application.watcher.terminated then
        vscodeTerminated()
    end
end)

vscodeWatcher:start()

print("Hammerspoon: VS Code watcher 已加载")

