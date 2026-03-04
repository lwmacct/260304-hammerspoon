-- modules/1password.lua
-- 开机自动执行 1Password SSH Agent 软链接.
local command = [[ln -sfn ~/Library/Group\ Containers/2BUA8C4S2C.com.1password/t/agent.sock "$SSH_AUTH_SOCK"]]

local output, success = hs.execute(command, true)

if success then
    print("✅ 1Password SSH Agent 软链接已创建成功！")
else
    print("❌ 1Password SSH Agent 软链接创建失败")
    if output and output ~= "" then
        print("   输出: " .. output)
    end
end
