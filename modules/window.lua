-- 辅助函数：调整当前窗口到指定比例矩形（无动画）
local function resizeTo(unitRect)
    local win = hs.window.focusedWindow()
    if win then
        win:moveToUnit(unitRect, 0) -- 动画时长为 0，瞬间完成
    end
end

-- 左侧留 1/12 空隙，窗口占 11/12（从左边1/12处开始，到右边贴边）
local function left_11_12()
    resizeTo({1 / 12, 0, 11 / 12, 1})
end

-- 窗口最大化（占满屏幕）
local function maximize()
    resizeTo({0, 0, 1, 1})
end

-- 快捷键绑定
local modifiers = {"ctrl", "alt"} -- Control + Option

hs.hotkey.bind(modifiers, "m", left_11_12) -- ⌃⌥M → 左侧留空 11/12
hs.hotkey.bind(modifiers, "return", maximize) -- ⌃⌥↩ → 最大化
