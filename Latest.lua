local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local player = Players.LocalPlayer
local camera = workspace.CurrentCamera

-- // SETTINGS
local AIM_ENABLED = false
local AUTO_SHOOT = false 
local TARGET_PART = "Head"

-- // UI SETUP (Now using PlayerGui for better visibility)
local ScreenGui = Instance.new("ScreenGui")
ScreenGui.Name = "AimOptionsSuite"
ScreenGui.Parent = player:WaitForChild("PlayerGui")
ScreenGui.ResetOnSpawn = false

-- Function to make buttons easily
local function createBtn(text, pos, color, sizeX)
    local btn = Instance.new("TextButton")
    btn.Parent = ScreenGui
    btn.Size = UDim2.new(0, sizeX or 160, 0, 45)
    btn.Position = pos
    btn.BackgroundColor3 = color
    btn.Text = text
    btn.TextColor3 = Color3.new(1, 1, 1)
    btn.Font = Enum.Font.GothamBold
    btn.TextSize = 14
    btn.Active = true
    btn.Draggable = true -- You can drag them if they block your view
    
    local corner = Instance.new("UICorner")
    corner.CornerRadius = UDim.new(0, 8)
    corner.Parent = btn
    
    return btn
end

-- // CREATE BUTTONS (Positioned on the left)
local MainLock = createBtn("AIMBOT: OFF", UDim2.new(0.02, 0, 0.2, 0), Color3.fromRGB(30, 30, 30))
local ShootBtn = createBtn("AUTO FIRE: OFF", UDim2.new(0.02, 0, 0.27, 0), Color3.fromRGB(30, 30, 30))

-- Small labels for the options
local label = Instance.new("TextLabel", ScreenGui)
label.Text = "TARGET OPTIONS:"
label.Position = UDim2.new(0.02, 0, 0.35, 0)
label.Size = UDim2.new(0, 160, 0, 20)
label.BackgroundTransparency = 1
label.TextColor3 = Color3.new(1,1,1)
label.Font = Enum.Font.GothamBold
label.TextSize = 12

local HeadBtn = createBtn("HEAD", UDim2.new(0.02, 0, 0.38, 0), Color3.fromRGB(150, 50, 50), 50)
local ChestBtn = createBtn("CHEST", UDim2.new(0.02, 55, 0.38, 0), Color3.fromRGB(50, 50, 50), 50)
local LegBtn = createBtn("LEGS", UDim2.new(0.02, 110, 0.38, 0), Color3.fromRGB(50, 50, 50), 50)

-- // LOGIC
RunService.RenderStepped:Connect(function()
    if AIM_ENABLED then
        local target = nil
        local dist = 2000
        for _, p in pairs(Players:GetPlayers()) do
            if p ~= player and p.Character and p.Character:FindFirstChild(TARGET_PART) then
                local hum = p.Character:FindFirstChild("Humanoid")
                if hum and hum.Health > 0 then
                    local d = (p.Character[TARGET_PART].Position - player.Character.HumanoidRootPart.Position).Magnitude
                    if d < dist then
                        target = p.Character[TARGET_PART]
                        dist = d
                    end
                end
            end
        end
        if target then
            camera.CFrame = CFrame.lookAt(camera.CFrame.Position, target.Position)
        end
    end
    if AUTO_SHOOT then
        local tool = player.Character and player.Character:FindFirstChildOfClass("Tool")
        if tool then tool:Activate() end
    end
end)

-- // BUTTON CONNECTIONS
MainLock.MouseButton1Click:Connect(function()
    AIM_ENABLED = not AIM_ENABLED
    MainLock.Text = AIM_ENABLED and "AIMBOT: ON" or "AIMBOT: OFF"
    MainLock.BackgroundColor3 = AIM_ENABLED and Color3.fromRGB(200, 0, 0) or Color3.fromRGB(30, 30, 30)
end)

ShootBtn.MouseButton1Click:Connect(function()
    AUTO_SHOOT = not AUTO_SHOOT
    ShootBtn.Text = AUTO_SHOOT and "AUTO FIRE: ON" or "AUTO FIRE: OFF"
    ShootBtn.BackgroundColor3 = AUTO_SHOOT and Color3.fromRGB(0, 180, 50) or Color3.fromRGB(30, 30, 30)
end)

local function resetSelection()
    HeadBtn.BackgroundColor3 = Color3.fromRGB(50,50,50)
    ChestBtn.BackgroundColor3 = Color3.fromRGB(50,50,50)
    LegBtn.BackgroundColor3 = Color3.fromRGB(50,50,50)
end

HeadBtn.MouseButton1Click:Connect(function()
    TARGET_PART = "Head"
    resetSelection()
    HeadBtn.BackgroundColor3 = Color3.fromRGB(150, 50, 50)
end)

ChestBtn.MouseButton1Click:Connect(function()
    TARGET_PART = "UpperTorso"
    resetSelection()
    ChestBtn.BackgroundColor3 = Color3.fromRGB(150, 50, 50)
end)

LegBtn.MouseButton1Click:Connect(function()
    TARGET_PART = "LeftFoot"
    resetSelection()
    LegBtn.BackgroundColor3 = Color3.fromRGB(150, 50, 50)
end)
