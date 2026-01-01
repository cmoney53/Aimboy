local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local player = Players.LocalPlayer

-- // SETTINGS
local AIM_ENABLED = false
local AUTO_SHOOT = false 
local TARGET_PART = "Head"

-- // UI SETUP
local ScreenGui = Instance.new("ScreenGui")
ScreenGui.Name = "MobileGodSuite_V4"
ScreenGui.Parent = player:WaitForChild("PlayerGui")
ScreenGui.DisplayOrder = 999
ScreenGui.ResetOnSpawn = false

-- Background Container to keep everything together
local Frame = Instance.new("Frame", ScreenGui)
Frame.Size = UDim2.new(0, 160, 0, 260)
Frame.Position = UDim2.new(0.05, 0, 0.3, 0)
Frame.BackgroundTransparency = 0.5
Frame.BackgroundColor3 = Color3.new(0,0,0)
Instance.new("UICorner", Frame)

local function createBtn(text, pos, color)
    local btn = Instance.new("TextButton", Frame)
    btn.Size = UDim2.new(0, 140, 0, 40)
    btn.Position = pos
    btn.BackgroundColor3 = color
    btn.Text = text
    btn.TextColor3 = Color3.new(1, 1, 1)
    btn.Font = Enum.Font.GothamBold
    btn.TextSize = 12
    Instance.new("UICorner", btn)
    return btn
end

-- // BUTTONS (Stacked Vertically)
local LockBtn = createBtn("STRONG AIM: OFF", UDim2.new(0, 10, 0, 10), Color3.fromRGB(30, 30, 30))
local ShootBtn = createBtn("AUTO FIRE: OFF", UDim2.new(0, 10, 0, 55), Color3.fromRGB(30, 30, 30))

-- Divider Label
local Label = Instance.new("TextLabel", Frame)
Label.Text = "--- TARGET PART ---"
Label.Size = UDim2.new(0, 140, 0, 20)
Label.Position = UDim2.new(0, 10, 0, 100)
Label.BackgroundTransparency = 1
Label.TextColor3 = Color3.new(1,1,1)
Label.Font = Enum.Font.GothamBold
Label.TextSize = 10

-- Body Part Toggles
local HeadBtn = createBtn("AIM: HEAD (ON)", UDim2.new(0, 10, 0, 125), Color3.fromRGB(150, 50, 50))
local ChestBtn = createBtn("AIM: CHEST", UDim2.new(0, 10, 0, 170), Color3.fromRGB(30, 30, 30))
local LegBtn = createBtn("AIM: LEGS", UDim2.new(0, 10, 0, 215), Color3.fromRGB(30, 30, 30))

-- // LOGIC
RunService.RenderStepped:Connect(function()
    if AIM_ENABLED then
        local target = nil
        local dist = 1000
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
            workspace.CurrentCamera.CFrame = CFrame.lookAt(workspace.CurrentCamera.CFrame.Position, target.Position)
        end
    end
    if AUTO_SHOOT then
        local tool = player.Character and player.Character:FindFirstChildOfClass("Tool")
        if tool then tool:Activate() end
    end
end)

-- // BUTTON INTERACTION
LockBtn.MouseButton1Click:Connect(function()
    AIM_ENABLED = not AIM_ENABLED
    LockBtn.Text = AIM_ENABLED and "STRONG AIM: ON" or "STRONG AIM: OFF"
    LockBtn.BackgroundColor3 = AIM_ENABLED and Color3.fromRGB(200, 0, 0) or Color3.fromRGB(30, 30, 30)
end)

ShootBtn.MouseButton1Click:Connect(function()
    AUTO_SHOOT = not AUTO_SHOOT
    ShootBtn.Text = AUTO_SHOOT and "AUTO FIRE: ON" or "AUTO FIRE: OFF"
    ShootBtn.BackgroundColor3 = AUTO_SHOOT and Color3.fromRGB(0, 150, 50) or Color3.fromRGB(30, 30, 30)
end)

local function updateBodyBtns(active)
    HeadBtn.Text = "AIM: HEAD"
    ChestBtn.Text = "AIM: CHEST"
    LegBtn.Text = "AIM: LEGS"
    HeadBtn.BackgroundColor3 = Color3.fromRGB(30,30,30)
    ChestBtn.BackgroundColor3 = Color3.fromRGB(30,30,30)
    LegBtn.BackgroundColor3 = Color3.fromRGB(30,30,30)
    
    active.BackgroundColor3 = Color3.fromRGB(150, 50, 50)
    active.Text = active.Text .. " (ON)"
end

HeadBtn.MouseButton1Click:Connect(function() TARGET_PART = "Head" updateBodyBtns(HeadBtn) end)
ChestBtn.MouseButton1Click:Connect(function() TARGET_PART = "UpperTorso" updateBodyBtns(ChestBtn) end)
LegBtn.MouseButton1Click:Connect(function() TARGET_PART = "LeftFoot" updateBodyBtns(LegBtn) end)
