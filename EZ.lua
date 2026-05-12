-- Huy_Hub | Blox Fruits - Full Version
local Library = loadstring(game:HttpGet("https://raw.githubusercontent.com/xHeptc/Kavo-UI-Library/main/source.lua"))()
local Window = Library.CreateLib("Huy_Hub | Blox Fruits", "Ocean")

local Players = game:GetService("Players")
local LocalPlayer = Players.LocalPlayer
local Workspace = game:GetService("Workspace")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")

local TweenSpeed = 250
local isAutoGunMode = true

-- ==================== TOGGLE GUI ====================
local guiVisible = true

local function ToggleGUI()
    guiVisible = not guiVisible
    for _, v in pairs(Window:GetDescendants()) do
        if v:IsA("Frame") or v:IsA("TextLabel") or v:IsA("TextButton") or v:IsA("ScrollingFrame") then
            v.Visible = guiVisible
        end
    end
    print("Huy_Hub GUI: " .. (guiVisible and "ĐÃ HIỆN" or "ĐÃ ẨN"))
end

-- ==================== TABS ====================
local MainTab = Window:NewTab("Main")
local MainSec = MainTab:NewSection("Control")

MainSec:NewToggle("Auto Gun Mode", "Cầm súng = Tự Aim + Tự Bắn", true, function(state)
    isAutoGunMode = state
end)

MainSec:NewButton("Ẩn / Hiện Menu", "Nhấn để gọn màn hình", function()
    ToggleGUI()
end)

MainSec:NewLabel("Hotkey: Right Control - Ẩn/Hiện Menu")

-- ==================== FARM ====================
local FarmTab = Window:NewTab("Farm")
local FarmSec = FarmTab:NewSection("Farm Options")

FarmSec:NewDropdown("Select Weapon", "", {"Melee", "Sword", "Fruit", "Gun"}, function() end)
FarmSec:NewToggle("Auto Farm Level", "", false, function() end)
FarmSec:NewToggle("Auto Farm Mastery", "", false, function() end)

-- ==================== COMBAT ====================
local CombatTab = Window:NewTab("Combat")
CombatTab:NewSection("Gun Combat"):NewToggle("No Cooldown Gun", "", true, function(state)
    NoGunCooldown(state)
end)

-- ==================== SEA & LEGENDARY ====================
local SeaTab = Window:NewTab("Sea / Boat")
SeaTab:NewSection("Sea"):NewToggle("Auto Drive to Sea - VÔ HẠN", "", false, function(state)
    if state then spawn(InfiniteSeaDrive) end
end)

local LegTab = Window:NewTab("Legendary Items")
local LegSec = LegTab:NewSection("Auto Legendary")
LegSec:NewToggle("Auto Get Yama", "", false, function() end)
LegSec:NewToggle("Auto Get Tushita", "", false, function() end)
LegSec:NewToggle("Auto Get Twin Hooks", "", false, function() end)
LegSec:NewToggle("Auto Get Guitar", "", false, function() end)
LegSec:NewToggle("Auto Get Dragon Sword", "", false, function() end)
LegSec:NewToggle("Auto Get Dragon Gun", "", false, function() end)

-- ==================== AUTO GUN SYSTEM ====================
function IsGunEquipped()
    local tool = LocalPlayer.Character and LocalPlayer.Character:FindFirstChildOfClass("Tool")
    if tool then
        local n = tool.Name:lower()
        return n:find("gun") or n:find("pistol") or n:find("rifle") or n:find("musket")
    end
    return false
end

function GetNearestEnemy()
    local nearest, dist = nil, math.huge
    local root = LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart")
    if not root then return nil end

    for _, enemy in pairs(Workspace.Enemies:GetChildren()) do
        if enemy:FindFirstChild("HumanoidRootPart") and enemy.Humanoid.Health > 0 then
            local d = (enemy.HumanoidRootPart.Position - root.Position).Magnitude
            if d < dist and d < 220 then
                dist = d
                nearest = enemy
            end
        end
    end
    return nearest
end

function AutoGunSystem()
    while isAutoGunMode do
        if IsGunEquipped() then
            pcall(function()
                local cam = Workspace.CurrentCamera
                local target = GetNearestEnemy()
                if target then
                    local tp = target.HumanoidRootPart.Position + Vector3.new(0, 2.5, 0)
                    cam.CFrame = CFrame.lookAt(cam.CFrame.Position, tp)
                end
            end)

            pcall(function()
                game:GetService("VirtualUser"):CaptureController()
                game:GetService("VirtualUser"):Button1Down(Vector2.new(0,0), Workspace.CurrentCamera.CFrame)
            end)
        end
        RunService.RenderStepped:Wait()
    end
end

spawn(AutoGunSystem)

-- ==================== HOTKEY ====================
UserInputService.InputBegan:Connect(function(input, gp)
    if gp then return end
    if input.KeyCode == Enum.KeyCode.RightControl then
        ToggleGUI()
    end
end)

-- ==================== KHÁC ====================
function NoGunCooldown(state)
    if state then
        spawn(function()
            while state do
                pcall(function()
                    local char = LocalPlayer.Character
                    if char then
                        for _, tool in pairs(char:GetChildren()) do
                            if tool:IsA("Tool") then
                                local cd = tool:FindFirstChild("Cooldown") or tool:FindFirstChild("ReloadTime")
                                if cd then cd.Value = 0 end
                            end
                        end
                    end
                end)
                wait(0.25)
            end
        end)
    end
end

function InfiniteSeaDrive()
    while true do
        pcall(function()
            local root = LocalPlayer.Character:FindFirstChild("HumanoidRootPart")
            if root then root.CFrame = root.CFrame + Vector3.new(0, 0, 350) end
        end)
        wait(0.3)
    end
end

print("✅ Huy_Hub Loaded Thành Công!")
print("Nhấn Right Control để ẩn / hiện menu")
