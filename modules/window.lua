-- 辅助函数：调整当前窗口到指定比例矩形（无动画）
local function resizeToFunc(unitRect)
    local win = hs.window.focusedWindow()
    if win then
        win:moveToUnit(unitRect, 0) -- 动画时长为 0，瞬间完成
    end
end

-- 左侧留 1/12 空隙，窗口占 11/12（从左边1/12处开始，到右边贴边）
local function resizeToL11_12()
    resizeToFunc({1 / 12, 0, 11 / 12, 1})
end

-- 窗口最大化（占满屏幕）
local function resizeToMax()
    resizeToFunc({0, 0, 1, 1})
end

-- 直接关闭当前前台窗口（等同点左上角关闭按钮，不模拟 Cmd+W）
local function closeFocusedWindow()
    local win = hs.window.focusedWindow()
    if win then
        local ok = win:close()
        if not ok then
            hs.alert.show("当前窗口不支持关闭")
        end
    else
        hs.alert.show("没有可关闭的前台窗口")
    end
end

-- 快捷键绑定
local modifiers = {"ctrl", "alt", "cmd"} -- Control + Option + Command 作为修饰键

-- 这里配合 karabiner 使用 capslock + m 做二段快捷键比较合适
hs.hotkey.bind(modifiers, "m", resizeToMax) -- ⌃⌥⌘M → 最大化
hs.hotkey.bind(modifiers, "n", resizeToL11_12) -- ⌃⌥⌘N → 左侧留空 11/12

hs.hotkey.bind({"cmd", "alt"}, "w", closeFocusedWindow) -- ⌘⌥W → 直接关闭前台窗口,不模拟 Cmd+W 的行为
