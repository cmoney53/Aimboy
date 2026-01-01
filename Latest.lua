local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local CoreGui = game:GetService("CoreGui")

local player = Players.LocalPlayer
local camera = workspace.CurrentCamera

-- // SETTINGS
local AIM_ENABLED = false
local AUTO_SHOOT = false 
local LOCKED_TARGET = nil

-- // AGGRESSIVE SETTINGS
local VERTICAL_OFFSET = 0 -- 0 = Stomach (Direct Center)
local SNAP_STRENGTH = 1   -- 1 = Instant Lock (No smoothing, very strong)
local MAX_DISTANCE = 2000 -- Increased range

-- // UI SETUP
if CoreGui:FindFirstChild("MobileGodSuite") then CoreGui.MobileGodSuite:Destroy() end

local ScreenGui = Instance.new("ScreenGui", CoreGui)
ScreenGui.Name = "MobileGodSuite"

local function createBtn(text, pos, color)
    local btn = Instance.new("TextButton", ScreenGui)
    btn.Size = UDim2.new(0, 160, 0, 50)
    btn.Position = pos
    btn.BackgroundColor3 = color
    btn.Text = text
    btn.TextColor3 = Color3.new(1, 1, 1)
    btn.Font = Enum.Font.GothamBold
    btn.TextSize = 14
    btn.Draggable = true
    btn.Active = true
    Instance.new("UICorner", btn)
    return btn
end

local LockBtn = createBtn("STRONG AIM: OFF", UDim2.new(0.05, 0, 0.4, 0), Color3.fromRGB(20, 20, 20))
local ShootBtn = createBtn("AUTO FIRE: OFF", UDim2.new(0.05, 0, 0.5, 0), Color3.fromRGB(20, 20, 20))

-- // AGGRESSIVE TARGETING
local function getClosestPlayer()
    local target, shortestDistance = nil, MAX_DISTANCE

    if not player.Character or not player.Character:FindFirstChild("HumanoidRootPart") then return nil end
    local myPos = player.Character.HumanoidRootPart.Position

    for _, p in pairs(Players:GetPlayers()) do
        if p ~= player and p.Character then
            local root = p.Character:FindFirstChild("HumanoidRootPart")
            local hum = p.Character:FindFirstChild("Humanoid")
            
            -- Team check can be removed if you want to aim at everyone
            if root and hum and hum.Health > 0 then
                local dist = (root.Position - myPos).Magnitude
                if dist < shortestDistance then
                    target = p.Character
                    shortestDistance = dist
                end
            end
        end
    end
    return target
end

-- // INPUT
local IsActive = false
UserInputService.InputBegan:Connect(function(input, gp)
    if gp then return end
    if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
        IsActive = true
    end
end)
UserInputService.InputEnded:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
        IsActive = false
    end
end)

-- // MAIN ENGINE (STRENGTH FOCUS)
RunService.RenderStepped:Connect(function()
    if AIM_ENABLED then
        LOCKED_TARGET = getClosestPlayer()
        
        if LOCKED_TARGET and LOCKED_TARGET:FindFirstChild("HumanoidRootPart") then
            local targetPos = LOCKED_TARGET.HumanoidRootPart.Position + Vector3.new(0, VERTICAL_OFFSET, 0)
            
            -- FORCED CAMERA LOCK (Strongest Method)
            camera.CFrame = CFrame.lookAt(camera.CFrame.Position, targetPos)
            
            -- Prevent character from spinning wildly on mobile
            if player.Character and player.Character:FindFirstChild("Humanoid") then
                player.Character.Humanoid.AutoRotate = false
                -- Force player to face target (Optional, very strong)
                player.Character.HumanoidRootPart.CFrame = CFrame.lookAt(player.Character.HumanoidRootPart.Position, Vector3.new(targetPos.X, player.Character.HumanoidRootPart.Position.Y, targetPos.Z))
            end
        end
    else
        if player.Character and player.Character:FindFirstChild("Humanoid") then
            player.Character.Humanoid.AutoRotate = true
        end
        LOCKED_TARGET = nil
    end

    -- FIRE LOGIC
    if AUTO_SHOOT and IsActive then
        local tool = player.Character:FindFirstChildOfClass("Tool")
        if tool then tool:Activate() end
    end
end)

-- // BUTTONS
LockBtn.MouseButton1Click:Connect(function()
    AIM_ENABLED = not AIM_ENABLED
    LockBtn.Text = AIM_ENABLED and "AIM: LOCKED" or "STRONG AIM: OFF"
    LockBtn.BackgroundColor3 = AIM_ENABLED and Color3.fromRGB(255, 0, 0) or Color3.fromRGB(20, 20, 20)
end)

ShootBtn.MouseButton1Click:Connect(function()
    AUTO_SHOOT = not AUTO_SHOOT
    ShootBtn.Text = AUTO_SHOOT and "FIRE: ACTIVE" or "AUTO FIRE: OFF"
    ShootBtn.BackgroundColor3 = AUTO_SHOOT and Color3.fromRGB(0, 255, 100) or Color3.fromRGB(20, 20, 20)
end)
