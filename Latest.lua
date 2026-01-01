local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local player = Players.LocalPlayer
local camera = workspace.CurrentCamera

-- // SETTINGS
local AIM_ENABLED = false
local AUTO_SHOOT = false 
local TARGET_TYPE = "Head" -- Options: "Head", "Chest", "Legs"

-- // UI SETUP
local ScreenGui = Instance.new("ScreenGui", player:WaitForChild("PlayerGui"))
ScreenGui.Name = "UniversalAimSuite"
ScreenGui.ResetOnSpawn = false
ScreenGui.DisplayOrder = 999

local MainFrame = Instance.new("Frame", ScreenGui)
MainFrame.Size = UDim2.new(0, 160, 0, 250)
MainFrame.Position = UDim2.new(0.05, 0, 0.3, 0)
MainFrame.BackgroundColor3 = Color3.fromRGB(20, 20, 20)
MainFrame.BackgroundTransparency = 0.3
Instance.new("UICorner", MainFrame)

local function createBtn(text, pos, color)
    local btn = Instance.new("TextButton", MainFrame)
    btn.Size = UDim2.new(0, 140, 0, 35)
    btn.Position = pos
    btn.BackgroundColor3 = color
    btn.Text = text
    btn.TextColor3 = Color3.new(1, 1, 1)
    btn.Font = Enum.Font.GothamBold
    btn.TextSize = 12
    Instance.new("UICorner", btn)
    return btn
end

local LockBtn = createBtn("AIMBOT: OFF", UDim2.new(0, 10, 0, 10), Color3.fromRGB(50, 50, 50))
local ShootBtn = createBtn("AUTO FIRE: OFF", UDim2.new(0, 10, 0, 50), Color3.fromRGB(50, 50, 50))

-- Body Part Buttons
local HeadBtn = createBtn("TARGET: HEAD", UDim2.new(0, 10, 0, 110), Color3.fromRGB(150, 0, 0))
local ChestBtn = createBtn("TARGET: CHEST", UDim2.new(0, 10, 0, 155), Color3.fromRGB(50, 50, 50))
local LegBtn = createBtn("TARGET: LEGS", UDim2.new(0, 10, 0, 200), Color3.fromRGB(50, 50, 50))

-- // TARGETING HELPER (Finds the right part for R6 and R15)
local function getBodyPart(char)
    if TARGET_TYPE == "Head" then
        return char:FindFirstChild("Head")
    elseif TARGET_TYPE == "Chest" then
        return char:FindFirstChild("UpperTorso") or char:FindFirstChild("Torso") or char:FindFirstChild("HumanoidRootPart")
    elseif TARGET_TYPE == "Legs" then
        return char:FindFirstChild("LowerTorso") or char:FindFirstChild("LeftLeg") or char:FindFirstChild("LeftLowerLeg")
    end
    return char:FindFirstChild("HumanoidRootPart")
end

-- // MAIN ENGINE
RunService.RenderStepped:Connect(function()
    if AIM_ENABLED then
        local targetPart = nil
        local shortestDist = 2000
        
        for _, p in pairs(Players:GetPlayers()) do
            if p ~= player and p.Character and p.Character:FindFirstChild("Humanoid") then
                if p.Character.Humanoid.Health > 0 then
                    local part = getBodyPart(p.Character)
                    if part then
                        local dist = (part.Position - player.Character.HumanoidRootPart.Position).Magnitude
                        if dist < shortestDist then
                            targetPart = part
                            shortestDist = dist
                        end
                    end
                end
            end
        end
        
        if targetPart then
            camera.CFrame = CFrame.lookAt(camera.CFrame.Position, targetPart.Position)
        end
    end

    if AUTO_SHOOT then
        local tool = player.Character and player.Character:FindFirstChildOfClass("Tool")
        if tool then tool:Activate() end
    end
end)

-- // BUTTON LOGIC
LockBtn.MouseButton1Click:Connect(function()
    AIM_ENABLED = not AIM_ENABLED
    LockBtn.Text = AIM_ENABLED and "AIMBOT: ON" or "AIMBOT: OFF"
    LockBtn.BackgroundColor3 = AIM_ENABLED and Color3.fromRGB(200, 0, 0) or Color3.fromRGB(50, 50, 50)
end)

ShootBtn.MouseButton1Click:Connect(function()
    AUTO_SHOOT = not AUTO_SHOOT
    ShootBtn.Text = AUTO_SHOOT and "AUTO FIRE: ON" or "AUTO FIRE: OFF"
    ShootBtn.BackgroundColor3 = AUTO_SHOOT and Color3.fromRGB(0, 150, 50) or Color3.fromRGB(50, 50, 50)
end)

local function updateUI(btn, type)
    TARGET_TYPE = type
    HeadBtn.BackgroundColor3 = Color3.fromRGB(50, 50, 50)
    ChestBtn.BackgroundColor3 = Color3.fromRGB(50, 50, 50)
    LegBtn.BackgroundColor3 = Color3.fromRGB(50, 50, 50)
    btn.BackgroundColor3 = Color3.fromRGB(150, 0, 0)
end

HeadBtn.MouseButton1Click:Connect(function() updateUI(HeadBtn, "Head") end)
ChestBtn.MouseButton1Click:Connect(function() updateUI(ChestBtn, "Chest") end)
LegBtn.MouseButton1Click:Connect(function() updateUI(LegBtn, "Legs") end)
