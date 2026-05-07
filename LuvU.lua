repeat
    task.wait(0.1)
until game:IsLoaded() and _G.Horst_SetDescription

local plr = game.Players.LocalPlayer
local currencies = plr.PlayerGui:WaitForChild("Interface")
    :WaitForChild("Topbar")
    :WaitForChild("Main")
    :WaitForChild("Currencies")

local titleLabel = plr.PlayerGui.Interface.Equipment.Prestige.Progress.Title

local prestigeLevel = {
    ["CADET"] = 0,
    ["PRIVATE"] = 1,
    ["CORPORAL"] = 2,
    ["SERGEANT"] = 3,
    ["COMMANDER"] = 4,
    ["MASTER SERGEANT"] = 5,
}

while task.wait(5) do
    local gold = currencies.Gold.Amount.Text
    local gem  = currencies.Gems.Amount.Text
    local prestige = prestigeLevel[titleLabel.Text] or 0

    local messages = "💰 Gold : " .. gold .. " , 💎 Gems : " .. gem .. " , ⚔️ Prestige : " .. prestige
    _G.Horst_SetDescription(messages)
end
