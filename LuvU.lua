-- Services
local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local player = Players.LocalPlayer

-------------------------------------------------
-- 🖥️ LOG UI (STABLE)
-------------------------------------------------
local ScreenGui = Instance.new("ScreenGui")
ScreenGui.Name = "SpinLogUI"
ScreenGui.ResetOnSpawn = false
ScreenGui.Parent = player:WaitForChild("PlayerGui")

local Frame = Instance.new("Frame", ScreenGui)
Frame.Size = UDim2.fromScale(0.35, 0.35)
Frame.Position = UDim2.fromScale(0.02, 0.55)
Frame.BackgroundColor3 = Color3.fromRGB(20,20,20)
Frame.BorderSizePixel = 0
Frame.Active = true
Frame.Draggable = true
Instance.new("UICorner", Frame).CornerRadius = UDim.new(0,12)

local Title = Instance.new("TextLabel", Frame)
Title.Size = UDim2.fromScale(1,0.15)
Title.BackgroundTransparency = 1
Title.Text = "🎰 Lucky Spin Log"
Title.TextScaled = true
Title.Font = Enum.Font.GothamBold
Title.TextColor3 = Color3.new(1,1,1)

local Scroll = Instance.new("ScrollingFrame", Frame)
Scroll.Position = UDim2.fromScale(0,0.15)
Scroll.Size = UDim2.fromScale(1,0.85)
Scroll.BackgroundTransparency = 1
Scroll.BorderSizePixel = 0
Scroll.ScrollBarImageTransparency = 0.3
Scroll.CanvasSize = UDim2.new(0,0,0,0)

local Log = Instance.new("TextLabel", Scroll)
Log.Position = UDim2.fromOffset(5,0)
Log.Size = UDim2.new(1,-10,0,0)
Log.BackgroundTransparency = 1
Log.TextWrapped = true
Log.TextXAlignment = Left
Log.TextYAlignment = Top
Log.AutomaticSize = Enum.AutomaticSize.Y
Log.Font = Enum.Font.Code
Log.TextSize = 14
Log.TextColor3 = Color3.fromRGB(220,220,220)
Log.Text = ""

local function AddLog(text)
    Log.Text ..= text .. "\n"
    task.wait()
    Scroll.CanvasSize = UDim2.new(0,0,0,Log.AbsoluteSize.Y + 10)
    Scroll.CanvasPosition = Vector2.new(
        0,
        math.max(0, Scroll.CanvasSize.Y.Offset - Scroll.AbsoluteWindowSize.Y)
    )
end

-------------------------------------------------
-- Knit
-------------------------------------------------
local Knit = ReplicatedStorage.Packages._Index
    :FindFirstChild("sleitnick_knit@1.7.0").knit

local SeasonService = Knit.Services.SeasonService
local StyleService = Knit.Services.StyleService

-------------------------------------------------
-- WAIT KNIT READY (สำคัญ)
-------------------------------------------------
repeat task.wait() until Knit.Started
AddLog("✅ Knit Ready")

-------------------------------------------------
-- Claim Daily (FIXED / SAFE)
-------------------------------------------------
local function ClaimDaily()
    AddLog("📦 Attempting Claim Daily...")

    local tries = {
        function() SeasonService.RF.ClaimDailyPresent:InvokeServer() end,
        function() SeasonService.RF.ClaimDailyPresent:InvokeServer(true) end,
        function() SeasonService.RF.ClaimDailyPresent:InvokeServer(1, true) end,
    }

    for _,fn in ipairs(tries) do
        local ok = pcall(fn)
        if ok then
            AddLog("✅ Claim Daily success")
            return true
        end
        task.wait(0.3)
    end

    AddLog("⚠️ Claim Daily failed / already claimed")
    return false
end

ClaimDaily()
task.wait(0.5)

-------------------------------------------------
-- Select Secret Chance = Mikage
-------------------------------------------------
AddLog("🎯 Select Secret Chance: Mikage")
pcall(function()
    StyleService.RF.SelectChance:InvokeServer("Mikage2", true)
end)
task.wait(0.5)

-------------------------------------------------
-- Secret List (ตามรูป)
-------------------------------------------------
local SecretList = {
    ["Kisuki"] = true,
    ["Sanju"]  = true,
    ["Mikage"] = true,
}

-------------------------------------------------
-- Get Current Style
-------------------------------------------------
local function GetCurrentStyle()
    local data = player:FindFirstChild("Data")
    local style = data and data:FindFirstChild("Style")
    return style and style.Value or "Unknown"
end

-------------------------------------------------
-- Lucky Spin (สูงสุด 5 ครั้ง)
-------------------------------------------------
for i = 1, 5 do
    AddLog("🔄 Spin รอบที่ "..i)

    StyleService.RF.Roll:InvokeServer(true) -- Lucky Spin
    task.wait(1) -- ⏱️ หน่วง 1 วินาทีต่อรอบ

    local result = GetCurrentStyle()
    AddLog("➡️ ได้: "..result)

    if SecretList[result] then
        AddLog("🎉 SECRET FOUND! หยุดการสุ่ม")
        return
    end
end

-------------------------------------------------
-- ไม่ได้ Secret → ออกเกม
-------------------------------------------------
AddLog("❌ ครบ 5 ครั้ง ยังไม่ได้ Secret")
AddLog("⏳ จะออกเกมใน 10 วินาที...")

task.wait(10)
player:Kick("ไม่ได้ Secret ภายใน 5 ครั้ง กำลังออกเกม")
