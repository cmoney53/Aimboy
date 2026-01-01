local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local player = Players.LocalPlayer
local camera = workspace.CurrentCamera

-- // SETTINGS
local AIM_ENABLED = false
local AUTO_SHOOT = false 
local TARGET_TYPE = "Head"

-- // UI SETUP
local ScreenGui = Instance.new("ScreenGui", player:WaitForChild("PlayerGui"))
ScreenGui.Name = "VisibleSnapSuite"
ScreenGui.ResetOnSpawn = false
ScreenGui.DisplayOrder = 999

local MainFrame = Instance.new("Frame", ScreenGui)
MainFrame.Size = UDim2.new(0, 160, 0, 250)
MainFrame.Position = UDim2.new(0.05, 0, 0.3, 0)
MainFrame.BackgroundColor3 = Color3.fromRGB(10, 10, 10)
MainFrame.BackgroundTransparency = 0.1
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

local LockBtn = createBtn("SNAP LOCK: OFF", UDim2.new(0, 10, 0, 10), Color3.fromRGB(40, 40, 40))
local ShootBtn = createBtn("AUTO FIRE: OFF", UDim2.new(0, 10, 0, 50), Color3.fromRGB(40, 40, 40))
local HeadBtn = createBtn("TARGET: FOREHEAD", UDim2.new(0, 10, 0, 110), Color3.fromRGB(200, 0, 0))
local ChestBtn = createBtn("TARGET: CHEST", UDim2.new(0, 10, 0, 155), Color3.fromRGB(40, 40, 40))
local LegBtn = createBtn("TARGET: LEGS", UDim2.new(0, 10, 0, 200), Color3.fromRGB(40, 40, 40))

-- // VISIBILITY CHECK (WALL CHECK)
local function isVisible(targetPos, targetChar)
    local origin = camera.CFrame.Position
    local direction = (targetPos - origin).Unit * (targetPos - origin).Magnitude
    
    local raycastParams = RaycastParams.new()
    raycastParams.FilterType = Enum.RaycastFilterType.Blacklist
    -- Ignore your own character and the target's character parts
    raycastParams.FilterDescendantsInstances = {player.Character, targetChar}
    raycastParams.IgnoreWater = true

    local result = workspace:Raycast(origin, direction, raycastParams)
    
    -- If result is nil, nothing hit between camera and target (Path is clear)
    return result == nil
end

-- // THE TARGET FINDER
local function getTargetPosition(char)
    local pos = nil
    if TARGET_TYPE == "Head" then
        local head = char:FindFirstChild("Head")
        if head then pos = head.Position + Vector3.new(0, 0.26, 0) end -- Forehead
    elseif TARGET_TYPE == "Chest" then
        local chest = char:FindFirstChild("UpperTorso") or char:FindFirstChild("Torso") or char:FindFirstChild("HumanoidRootPart")
        if chest then pos = chest.Position end
    elseif TARGET_TYPE == "Legs" then
        local leg = char:FindFirstChild("LeftFoot") or char:FindFirstChild("RightFoot") or char:FindFirstChild("LowerTorso")
        if leg then pos = leg.Position end
    end
    
    -- Only return the position if it's visible
    if pos and isVisible(pos, char) then
        return pos
    end
    return nil
end

-- // INSTANT SNAP ENGINE
RunService.RenderStepped:Connect(function()
    if AIM_ENABLED then
        local closestTargetPos = nil
        local shortestDist = 2000
        
        for _, p in pairs(Players:GetPlayers()) do
            if p ~= player and p.Character and p.Character:FindFirstChild("Humanoid") then
                if p.Character.Humanoid.Health > 0 then
                    local pos = getTargetPosition(p.Character)
                    if pos then
                        local dist = (pos - player.Character.HumanoidRootPart.Position).Magnitude
                        if dist < shortestDist then
                            closestTargetPos = pos
                            shortestDist = dist
                        end
                    end
                end
            end
        end
        
        if closestTargetPos then
            camera.CFrame = CFrame.lookAt(camera.CFrame.Position, closestTargetPos)
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
    LockBtn.Text = AIM_ENABLED and "SNAP LOCK: ON" or "SNAP LOCK: OFF"
    LockBtn.BackgroundColor3 = AIM_ENABLED and Color3.fromRGB(255, 0, 0) or Color3.fromRGB(40, 40, 40)
end)

ShootBtn.MouseButton1Click:Connect(function()
    AUTO_SHOOT = not AUTO_SHOOT
    ShootBtn.Text = AUTO_SHOOT and "FIRE: ON" or "FIRE: OFF"
    ShootBtn.BackgroundColor3 = AUTO_SHOOT and Color3.fromRGB(0, 200, 50) or Color3.fromRGB(40, 40, 40)
end)

local function updateUI(btn, type)
    TARGET_TYPE = type
    HeadBtn.BackgroundColor3 = Color3.fromRGB(40, 40, 40)
    ChestBtn.BackgroundColor3 = Color3.fromRGB(40, 40, 40)
    LegBtn.BackgroundColor3 = Color3.fromRGB(40, 40, 40)
    btn.BackgroundColor3 = Color3.fromRGB(200, 0, 0)
end

HeadBtn.MouseButton1Click:Connect(function() updateUI(HeadBtn, "Head") end)
ChestBtn.MouseButton1Click:Connect(function() updateUI(ChestBtn, "Chest") end)
LegBtn.MouseButton1Click:Connect(function() updateUI(LegBtn, "Legs") end)
