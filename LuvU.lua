repeat
    task.wait(0.1)
until game:IsLoaded() and _G.Horst_SetDescription 

local Players = game:GetService("Players")
local plr = Players.LocalPlayer
local stats = plr:WaitForChild("leaderstats") 

local function updateStatus()
    local gold = stats:FindFirstChild("Gold") and stats.Gold.Value or 0
    local gem = stats:FindFirstChild("Gems") and stats.Gems.Value or 0
    local lv = stats:FindFirstChild("Level") and stats.Level.Value or 0
    
    local prestige = stats:FindFirstChild("Prestige") and stats.Prestige.Value or 0

    local messages = "LV : " .. tostring(lv) .. " | ⚔️ Prestige : " .. tostring(prestige) .. " | 💰 : " .. tostring(gold) .. " | 💎 : " .. tostring(gem)
 
    
    _G.Horst_SetDescription(messages)
end
