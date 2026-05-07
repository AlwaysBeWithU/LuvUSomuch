repeat
    task.wait(0.1)
until game:IsLoaded() and _G.Horst_SetDescription

local plr = game.Players.LocalPlayer
local currencies = plr.PlayerGui:WaitForChild("Interface")
    :WaitForChild("Topbar")
    :WaitForChild("Main")
    :WaitForChild("Currencies")

local levelLabel = plr.PlayerGui.Interface.Gear_Up.HUD.Level.Title

local prestigeLevel = {
    ["CADET"] = 0,
    ["PRIVATE"] = 1,
    ["CORPORAL"] = 2,
    ["SERGEANT"] = 3,
    ["COMMANDER"] = 4,
    ["MASTER SERGEANT"] = 5,
}

local lastPrestige = 0

task.spawn(function()
    while task.wait(1) do
        local ok, result = pcall(function()
            local titleLabel = plr.PlayerGui.Interface.Equipment.Prestige.Progress.Title
            return prestigeLevel[titleLabel.Text]
        end)
        if ok and result ~= nil then
            lastPrestige = result
        end
    end
end)

while task.wait(5) do
    local gold = currencies.Gold.Amount.Text
    local gem  = currencies.Gems.Amount.Text
    local lv   = levelLabel.Text:match("%d+") or "?"

    local messages = "⚔️ Prestige : " .. lastPrestige .. " , 🏅 LV : " .. lv .. " , 💰 Gold : " .. gold .. " , 💎 Gems : " .. gem
    _G.Horst_SetDescription(messages)
end
