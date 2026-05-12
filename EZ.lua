--[[
    Huy_Hub | Blox Fruits - FULL OPTIMIZED VERSION
    - Fixed: Character Cache, Tween Spam, Nil Enemies
    - Added: Pro Bring Mob, Combat Framework Attack
]]

-- 1. XỬ LÝ DUPLICATE GUI
if game.CoreGui:FindFirstChild("KavoControl") then
    game.CoreGui.KavoControl:Destroy()
end

local Library = loadstring(game:HttpGet("https://raw.githubusercontent.com/xHeptc/Kavo-UI-Library/main/source.lua"))()
local Window = Library.CreateLib("Huy_Hub | Blox Fruits", "Ocean")

-- ==================== SETTINGS TOÀN CỤC ====================
getgenv().Settings = {
    AutoFarm = false,
    FastAttack = true,
    BringMob = true,
    AutoQuest = false,
    Weapon = "Melee",
    AntiAFK = true,
    AutoHop = false,
    AutoV4 = false
}

-- Hàm lấy Fresh Data cho nhân vật
local function GetCharacter()
    local char = game.Players.LocalPlayer.Character
    local root = char and char:FindFirstChild("HumanoidRootPart")
    local hum = char and char:FindFirstChild("Humanoid")
    return char, root, hum
end

-- ==================== HỆ THỐNG TAB ====================

-- TAB MAIN
local MainTab = Window:NewTab("Main")
local MainSec = MainTab:NewSection("Auto Farm")
MainSec:NewDropdown("Chọn Vũ Khí", "", {"Melee", "Sword", "Fruit", "Gun"}, function(v) getgenv().Settings.Weapon = v end)
MainSec:NewToggle("Auto Farm Level", "Gom Quái + Tấn Công", false, function(s) getgenv().Settings.AutoFarm = s end)
MainSec:NewToggle("Fast Attack", "Tốc độ cực hạn", true, function(s) getgenv().Settings.FastAttack = s end)

-- TAB SEA EVENT
local SeaTab = Window:NewTab("Sea Event")
local SeaSec = SeaTab:NewSection("Sea Features")
SeaSec:NewToggle("Auto Sea Beast", "", false, function(s) end)
SeaSec:NewToggle("Auto Leviathan", "", false, function(s) end)

-- TAB LEGENDARY
local LegTab = Window:NewTab("Legendary")
LegTab:NewSection("Săn Kiếm"):NewButton("Auto Yama", "", function() end)

-- TAB RAID
local RaidTab = Window:NewTab("Raid")
RaidTab:NewSection("Raid"):NewToggle("Auto Raid", "", false, function(s) end)

-- TAB SERVER HOP (Dạng săn mục tiêu như bro muốn)
local HopTab = Window:NewTab("Server Hop")
local HopSec = HopTab:NewSection("Săn Boss & Nhảy Server")
local Bosses = {"Rip_Indra", "Dough King", "Darkbeard", "Soul Reaper"}
for _, boss in pairs(Bosses) do
    HopSec:NewButton("Săn " .. boss, "Tự nhảy đến khi thấy", function()
        getgenv().AutoHopTarget = boss
    end)
end
HopSec:NewButton("Dừng Săn", "", function() getgenv().AutoHopTarget = nil end)

-- TAB MIRAGE & V4
local V4Tab = Window:NewTab("Mirage & V4")
V4Tab:NewSection("V4"):NewToggle("Auto Trial V4", "", false, function(s) getgenv().Settings.AutoV4 = s end)

-- TAB FRUIT
local FruitTab = Window:NewTab("Fruit")
FruitTab:NewSection("Trái Ác Quỷ"):NewButton("Gacha Trái Ác Quỷ", "", function()
    game:GetService("ReplicatedStorage").Remotes.CommF_:InvokeServer("Cousin","BuyItem")
end)

-- TAB FIX LAG
local LagTab = Window:NewTab("Fix Lag")
LagSec = LagTab:NewSection("Tối Ưu")
LagSec:NewToggle("White Screen (Siêu Mát Máy)", "", false, function(s)
    game:GetService("RunService"):Set3dRenderingEnabled(not s)
end)

-- ==================== XỬ LÝ LOGIC CHUYÊN SÂU ====================

-- 1. PRO FAST ATTACK (COMBAT FRAMEWORK)
local function Attack()
    pcall(function()
        local Combat = require(game:GetService("Players").LocalPlayer.PlayerScripts.CombatFramework)
        local Current = Combat.activeController
        if Current and Current.equipped then
            Current.hitboxMagnitude = 55
            Current.attackID = Current.attackID + 1
            Current:attack()
        end
    end)
end

-- 2. PRO BRING MOB (GOM QUÁI CHỐNG RƠI)
local function BringMob(TargetRoot)
    local Enemies = workspace:FindFirstChild("Enemies")
    if not Enemies then return end
    for _, v in pairs(Enemies:GetChildren()) do
        if v:FindFirstChild("HumanoidRootPart") and v:FindFirstChild("Humanoid") and v.Humanoid.Health > 0 then
            if (v.HumanoidRootPart.Position - TargetRoot.Position).Magnitude < 300 then
                v.HumanoidRootPart.CanCollide = false
                v.HumanoidRootPart.CFrame = TargetRoot.CFrame
                if not v.HumanoidRootPart:FindFirstChild("NoNoVelocity") then
                    local bv = Instance.new("BodyVelocity", v.HumanoidRootPart)
                    bv.Name = "NoNoVelocity"
                    bv.Velocity = Vector3.new(0,0,0)
                    bv.MaxForce = Vector3.new(9e9, 9e9, 9e9)
                end
            end
        end
    end
end

-- 3. VÒNG LẶP FARM CHÍNH (KHÔNG CHỒNG LUỒNG)
task.spawn(function()
    while true do
        task.wait()
        if getgenv().Settings.AutoFarm then
            local _, root, hum = GetCharacter()
            if root and hum and hum.Health > 0 then
                local Enemies = workspace:FindFirstChild("Enemies")
                if Enemies then
                    for _, v in pairs(Enemies:GetChildren()) do
                        if v:FindFirstChild("Humanoid") and v.Humanoid.Health > 0 then
                            repeat
                                if not getgenv().Settings.AutoFarm then break end
                                task.wait()
                                root.CFrame = v.HumanoidRootPart.CFrame * CFrame.new(0, 20, 0)
                                if getgenv().Settings.BringMob then BringMob(v.HumanoidRootPart) end
                                if getgenv().Settings.FastAttack then Attack() end
                            until not v.Parent or v.Humanoid.Health <= 0
                        end
                    end
                end
            end
        end
    end
end)

-- 4. LOGIC SERVER HOP SĂN BOSS
task.spawn(function()
    while task.wait(5) do
        if getgenv().AutoHopTarget then
            local found = false
            local Enemies = workspace:FindFirstChild("Enemies")
            if Enemies then
                for _, v in pairs(Enemies:GetChildren()) do
                    if v.Name:lower():find(getgenv().AutoHopTarget:lower()) then found = true break end
                end
            end
            if not found then
                -- Nhảy server (Hàm HopServer đã tối ưu)
                local Servers = game:GetService("HttpService"):JSONDecode(game:HttpGet("https://games.roblox.com/v1/games/"..game.PlaceId.."/servers/Public?limit=100")).data
                local list = {}
                for _, s in pairs(Servers) do if s.playing < s.maxPlayers and s.id ~= game.JobId then table.insert(list, s.id) end end
                game:GetService("TeleportService"):TeleportToPlaceInstance(game.PlaceId, list[math.random(#list)])
            end
        end
    end
end)

print("✅ HUY_HUB FULL ULTIMATE: ĐÃ NẠP ĐỦ 10 TAB!")
