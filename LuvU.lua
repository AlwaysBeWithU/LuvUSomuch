repeat
    task.wait(0.1)
until game:IsLoaded() and _G.Horst_SetDescription

local plr = game.Players.LocalPlayer
local interface = plr.PlayerGui:WaitForChild("Interface")
local currencies = interface.Topbar.Main.Currencies
local levelLabel = interface.Gear_Up.HUD.Level.Title
local items = interface.Inventory.Main.Holder.Items

local prestigeLevel = {
    ["CADET"] = 0, ["PRIVATE"] = 1, ["CORPORAL"] = 2,
    ["SERGEANT"] = 3, ["COMMANDER"] = 4, ["CAPTAIN"] = 5,
}

local lastPrestige = 0

local function getPrestige()
    firesignal(interface.Topbar.Main.Categories.Equipment.Interact.MouseButton1Click)
    task.wait(1.5)
    local ok, result = pcall(function()
        return prestigeLevel[interface.Equipment.Prestige.Progress.Title.Text] or 0
    end)
    if ok and result ~= nil then lastPrestige = result end
    return lastPrestige
end

local function getSerumCount(name)
    local count = 0
    for _, v in pairs(items:GetDescendants()) do
        if v:IsA("TextLabel") and v.Name == "Quantity" then
            if v:GetFullName():lower():find(name:lower()) then
                count = count + (tonumber(v.Text) or 0)
            end
        end
    end
    return count
end

while task.wait(60) do
    -- เช็ค Prestige
    local prestige = getPrestige()

    -- เช็ค Serum
    firesignal(interface.Topbar.Main.Categories.Inventory.Interact.MouseButton1Click)
    task.wait(1.5)

    local gold    = currencies.Gold.Amount.Text
    local gem     = currencies.Gems.Amount.Text
    local lv      = levelLabel.Text:match("%d+") or "?"
    local armored = getSerumCount("armored serum")
    local attack  = getSerumCount("attack serum")
    local female  = getSerumCount("female serum")

    local serumList = {}
    if armored > 0 then table.insert(serumList, "Armored x" .. armored) end
    if attack  > 0 then table.insert(serumList, "Attack x" .. attack) end
    if female  > 0 then table.insert(serumList, "Female x" .. female) end

    local serumText = #serumList > 0 and " , 🧪 : " .. table.concat(serumList, " / ") or " , 🧪 : -"

    local messages = "⚔️ Prestige : " .. prestige .. " , 🏅 LV : " .. lv .. " , 💰 Gold : " .. gold .. " , 💎 Gems : " .. gem ..  serumText
    _G.Horst_SetDescription(messages)
end
