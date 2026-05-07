local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local HttpService = game:GetService("HttpService")
local LocalPlayer = Players.LocalPlayer
while not LocalPlayer do task.wait(0.1); LocalPlayer = Players.LocalPlayer end
local statsFile = "AOTR_HorstStats_" .. tostring(LocalPlayer.UserId) .. ".json"
local cache = {
    level = "0", prestige = "0", title = "None", family = "None", slot = "A",
    gold = "N/A", gems = "N/A", serum = "0", ts = "0", ekey = "0", scroll = "0"
}
local KNOWN_FAMILIES = {
    "Shiki", "Fritz", "Helos",
    "Ackerman", "Yeager", "Reiss",
    "Zoe", "Braun", "Ksaver", "Tybur", "Leonhart", "Galliard", "Finger", "Arlert",
    "Azumabito", "Braus", "Smith", "Kirstein", "Grice", "Springer", "Kruger",
    "Reeves", "Blouse", "Inocenio", "Munsell", "Boyega", "Ral", "Bozado", "Pikale", "Hume", "Iglehaut"
}
if isfile and readfile and isfile(statsFile) then
    pcall(function()
        local data = HttpService:JSONDecode(readfile(statsFile))
        for k, v in pairs(data) do
            if v and v ~= "0" and v ~= "N/A" and v ~= "None" then
                cache[k] = v
            end
        end
    end)
end
local function saveStats()
    if writefile then
        pcall(function() writefile(statsFile, HttpService:JSONEncode(cache)) end)
    end
end
local function formatNumber(n)
    if type(n) ~= "number" then return tostring(n) end
    local formatted = tostring(n)
    local k
    repeat
        formatted, k = string.gsub(formatted, "^(-?%d+)(%d%d%d)", '%1,%2')
    until k == 0
    return formatted
end
task.spawn(function()
    while true do
        pcall(function()
            local remotes = ReplicatedStorage:WaitForChild("Assets", 5):WaitForChild("Remotes", 5)
            local getRemote = remotes:FindFirstChild("GET")
            if getRemote and getRemote:IsA("RemoteFunction") then
                local requests = {"Data", "Get_Data", "PlayerData", "RequestData", "Stats"}
                for _, req in ipairs(requests) do
                    local success, data = pcall(function() return getRemote:InvokeServer(req) end)
                    if success and type(data) == "table" and (data.Gold or data.Level) then
                        local u = false
                        if data.Gold then cache.gold = formatNumber(data.Gold); u = true end
                        if data.Gems then cache.gems = formatNumber(data.Gems); u = true end
                        if data.Level then cache.level = tostring(data.Level); u = true end
                        if data.Prestige then cache.prestige = tostring(data.Prestige); u = true end
                        if data.Title then cache.title = string.gsub(tostring(data.Title), "^_", ""); u = true end
                        if data.Family then cache.family = tostring(data.Family); u = true end
                        if data.Clan then cache.family = tostring(data.Clan); u = true end
                        if data.Slot then cache.slot = tostring(data.Slot); u = true end
                        if u then saveStats() end
                        break
                    end
                end
            end
        end)
        task.wait(30)
    end
end)
task.spawn(function()
    pcall(function()
        local remotes = ReplicatedStorage:WaitForChild("Assets", 5):WaitForChild("Remotes", 5)
        local post = remotes and remotes:FindFirstChild("POST")
        if post then
            post.OnClientEvent:Connect(function(...)
                for _, arg in ipairs({...}) do
                    if type(arg) == "table" then
                        local u = false
                        if arg.Gold then cache.gold = formatNumber(arg.Gold); u = true end
                        if arg.TotalGold then cache.gold = formatNumber(arg.TotalGold); u = true end
                        if arg.Gems then cache.gems = formatNumber(arg.Gems); u = true end
                        if arg.TotalGems then cache.gems = formatNumber(arg.TotalGems); u = true end
                        if arg.Level then cache.level = tostring(arg.Level); u = true end
                        if arg.Prestige then cache.prestige = tostring(arg.Prestige); u = true end
                        if arg.Title then cache.title = string.gsub(tostring(arg.Title), "^_", ""); u = true end
                        if arg.Family then cache.family = tostring(arg.Family); u = true end
                        if arg.Clan then cache.family = tostring(arg.Clan); u = true end
                        if arg.Slot then cache.slot = tostring(arg.Slot); u = true end
                        if u then saveStats() end
                        break
                    end
                end
            end)
        end
    end)
end)
local oldSerum = "0"
local oldTS = "0"
local oldEkey = "0"
local oldScroll = "0"
local _cachedItems = nil
local _cachedInvBtn = nil

task.spawn(function()
    local pg = LocalPlayer:WaitForChild("PlayerGui", 60)
    if not pg then return end

    local fullscreen = pg:FindFirstChild("Fullscreen")
    if fullscreen then
        local loadingScreen = fullscreen:FindFirstChild("Loading_Screen")
        if loadingScreen and loadingScreen.Visible then
            loadingScreen:GetPropertyChangedSignal("Visible"):Wait()
        end
    end

    local function findItems()
        local ok, result = pcall(function()
            return pg.Interface.Inventory.Main.Holder.Items
        end)
        return ok and result or nil
    end

    local function findInvBtn()
        if _cachedInvBtn and _cachedInvBtn.Parent then
            return _cachedInvBtn
        end
        _cachedInvBtn = nil
        for _, obj in ipairs(pg:GetDescendants()) do
            if not string.find(obj:GetFullName(), "Inventory.Main") then
                local ok, text = pcall(function()
                    if obj:IsA("TextLabel") or obj:IsA("TextButton") then
                        return string.upper(obj.Text)
                    end
                    return ""
                end)
                if ok and text == "INVENTORY" then
                    _cachedInvBtn = obj
                    return obj
                end
            end
        end
        return nil
    end

    local function clickBtn(btn)
        if not btn then return end
        pcall(function()
            local pos = btn.AbsolutePosition
            local size = btn.AbsoluteSize
            local cx = pos.X + (size.X / 2)
            local cy = pos.Y + (size.Y / 2) + 36
            local vim = game:GetService("VirtualInputManager")
            vim:SendMouseButtonEvent(cx, cy, 0, true, game, 1)
            task.wait(0.1)
            vim:SendMouseButtonEvent(cx, cy, 0, false, game, 1)
        end)
    end

    local function countGuiItems(container)
        local c = 0
        if not container then return 0 end
        local ok = pcall(function()
            for _, ch in ipairs(container:GetChildren()) do
                if ch:IsA("GuiObject") then c = c + 1 end
            end
        end)
        return ok and c or 0
    end

    while true do
        local items = findItems()
        local count = countGuiItems(items)

        if count > 2 then
            _cachedItems = items

            pcall(function()
                local sCnt = { ATK = 0, ARM = 0, FEM = 0, COL = 0, UNK = 0 }
                local tsCnt = {}
                local ekeyCount = 0
                local scrollCount = 0
                local foundSerumUI = false
                local foundTSUI = false
                local foundEkeyUI = false
                local foundScrollUI = false
                for _, item in ipairs(_cachedItems:GetChildren()) do
                    if item:IsA("GuiObject") then
                        local attrName = item:GetAttribute("Item")
                        local name = attrName and tostring(attrName):lower() or item.Name:lower()
                        local qty = 1
                        local qtyLabel = item:FindFirstChild("Quantity", true)
                        if qtyLabel and qtyLabel:IsA("TextLabel") and qtyLabel.Text ~= "" then
                            local num = tonumber((qtyLabel.Text:gsub(",", "")))
                            if num and num > 0 then qty = num end
                        end
                        if name:find("serum") then
                            foundSerumUI = true
                            if name:find("attack") then sCnt.ATK = sCnt.ATK + qty
                            elseif name:find("armored") then sCnt.ARM = sCnt.ARM + qty
                            elseif name:find("female") then sCnt.FEM = sCnt.FEM + qty
                            elseif name:find("colossal") then sCnt.COL = sCnt.COL + qty
                            else sCnt.UNK = sCnt.UNK + qty end
                        elseif name:find("thruster") then
                            foundTSUI = true
                            tsCnt[name] = (tsCnt[name] or 0) + qty
                        elseif name:find("emperor") then
                            foundEkeyUI = true
                            ekeyCount = ekeyCount + qty
                        elseif name:find("memory") then
                            foundScrollUI = true
                            scrollCount = scrollCount + qty
                        end
                    end
                end

                if foundSerumUI then
                    local pSerum = {}
                    if sCnt.ATK > 0 then table.insert(pSerum, "attack serum ( " .. sCnt.ATK .. " )") end
                    if sCnt.ARM > 0 then table.insert(pSerum, "armored serum ( " .. sCnt.ARM .. " )") end
                    if sCnt.FEM > 0 then table.insert(pSerum, "female serum ( " .. sCnt.FEM .. " )") end
                    if sCnt.COL > 0 then table.insert(pSerum, "colossal serum ( " .. sCnt.COL .. " )") end
                    if sCnt.UNK > 0 then table.insert(pSerum, "unknown serum ( " .. sCnt.UNK .. " )") end
                    local newSerumStr = table.concat(pSerum, " : ")
                    if newSerumStr ~= "" then cache.serum = newSerumStr end
                end

                if foundTSUI then
                    local pTS = {}
                    for nm, n in pairs(tsCnt) do table.insert(pTS, string.upper(nm) .. " (x" .. n .. ")") end
                    local newTSStr = table.concat(pTS, " : ")
                    if newTSStr ~= "" then cache.ts = newTSStr end
                end
                if foundEkeyUI then
                    cache.ekey = tostring(ekeyCount)
                end
                if foundScrollUI then
                    cache.scroll = tostring(scrollCount)
                end
            end)
            local updated = false
            if cache.serum ~= (oldSerum or "0") then
                oldSerum = cache.serum
                updated = true
            end
            if cache.ts ~= (oldTS or "0") then
                oldTS = cache.ts
                updated = true
            end
            if cache.ekey ~= (oldEkey or "0") then
                oldEkey = cache.ekey
                updated = true
            end
            if cache.scroll ~= (oldScroll or "0") then
                oldScroll = cache.scroll
                updated = true
            end
            if updated then saveStats() end
            task.wait(20)
        else
            local hasPlayerlist = false
            pcall(function()
                local pl = pg.Interface.Gear_Up.Playerlist
                if pl and pl:IsA("GuiObject") and pl.Visible then
                    hasPlayerlist = true
                end
            end)
            if hasPlayerlist then
                pcall(function()
                    local vim = game:GetService("VirtualInputManager")
                    vim:SendKeyEvent(true, Enum.KeyCode.Tab, false, game)
                    task.wait(0.1)
                    vim:SendKeyEvent(false, Enum.KeyCode.Tab, false, game)
                end)
            else
                local ok, invTitle = pcall(function()
                    return pg.Interface.Topbar.Main.Categories.Inventory.Title
                end)
                if ok and invTitle then
                    clickBtn(invTitle)
                end
            end
            task.wait(3)
        end
    end
end)
local PlayerGui = LocalPlayer:FindFirstChild("PlayerGui")
local function scanItems()
    if not PlayerGui then PlayerGui = LocalPlayer:FindFirstChild("PlayerGui") end
    local c = false
    local rl = LocalPlayer:GetAttribute("Level")
    if rl and rl ~= 0 and cache.level ~= tostring(rl) then cache.level = tostring(rl); c = true end
    local rp = LocalPlayer:GetAttribute("Prestige")
    if rp and cache.prestige ~= tostring(rp) then cache.prestige = tostring(rp); c = true end
    local rt = LocalPlayer:GetAttribute("Title")
    if rt and rt ~= "" then
        local t = string.gsub(tostring(rt), "^_", "")
        if cache.title ~= t then cache.title = t; c = true end
    end
    local rf = LocalPlayer:GetAttribute("Family") or LocalPlayer:GetAttribute("Clan")
    if rf and rf ~= "" and cache.family ~= tostring(rf) then cache.family = tostring(rf); c = true end
    local rs = LocalPlayer:GetAttribute("Slot")
    if rs and rs ~= "" and cache.slot ~= tostring(rs) then cache.slot = tostring(rs); c = true end

    if cache.family == "None" then
        local famFound = false
        if LocalPlayer.Character then
            for _, desc in ipairs(LocalPlayer.Character:GetDescendants()) do
                if desc.ClassName == "TextLabel" and desc.Text ~= "" then
                    for _, fam in ipairs(KNOWN_FAMILIES) do
                        if string.find(desc.Text, fam) then
                            cache.family = fam; c = true; famFound = true; break
                        end
                    end
                end
                if famFound then break end
            end
        end
        if not famFound and PlayerGui then
            local ui = PlayerGui:FindFirstChild("Interface") or PlayerGui
            for _, desc in ipairs(ui:GetDescendants()) do
                if desc.ClassName == "TextLabel" and desc.Text ~= "" then
                    for _, fam in ipairs(KNOWN_FAMILIES) do
                        if string.find(desc.Text, fam) then
                            cache.family = fam; c = true; famFound = true; break
                        end
                    end
                end
                if famFound then break end
            end
        end
    end

    if PlayerGui then
        local main = PlayerGui:FindFirstChild("Interface")
            and PlayerGui.Interface:FindFirstChild("Topbar")
            and PlayerGui.Interface.Topbar:FindFirstChild("Main")
        if main and main:FindFirstChild("Currencies") then
            local cur = main.Currencies
            local gTxt = cur:FindFirstChild("Gold") and cur.Gold:FindFirstChild("Amount") and cur.Gold.Amount.Text
            if gTxt and gTxt ~= "" and gTxt ~= "0" and gTxt ~= "N/A" and cache.gold ~= gTxt then
                cache.gold = gTxt; c = true
            end
            local dTxt = cur:FindFirstChild("Gems") and cur.Gems:FindFirstChild("Amount") and cur.Gems.Amount.Text
            if dTxt and dTxt ~= "" and dTxt ~= "0" and dTxt ~= "N/A" and cache.gems ~= dTxt then
                cache.gems = dTxt; c = true
            end
        end
    end

    if c then saveStats() end
    local fStr = cache.family ~= "None" and cache.family or cache.title
    return string.format("🏆 Lv: %s 👑 P: %s 🛡️ Family: %s 🪪 Slot: %s 💰 Gold: %s 💎 Gems: %s 🔑 Emperor Key: %s 📜 Memory Scroll: %s 💉 Serum: %s ⚡ TS: %s",
        cache.level, cache.prestige, fStr, cache.slot, cache.gold, cache.gems, cache.ekey or "0", cache.scroll or "0", cache.serum or "0", cache.ts or "0")
end
local lastMsg = ""
task.spawn(function()
    while task.wait(5) do
        pcall(function()
            local msg = scanItems()
            if _G.Horst_SetDescription and msg ~= lastMsg then
                lastMsg = msg
                _G.Horst_SetDescription(msg)

                        if tonumber(cache.level) == 225 then
                if _G.Horst_AccountChangeDone then
                    _G.Horst_AccountChangeDone()
                end
            end
        end)
    end
end)
            end
        end)
    end
end)
