local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local CoreGui = game:GetService("CoreGui")

local player = Players.LocalPlayer
local camera = workspace.CurrentCamera

-- // SETTINGS
local AIM_ENABLED = false
local FREE_AIM_ENABLED = false
local AUTO_SHOOT = false 
local LOCKED_TARGET = nil

-- // CHANGED: Set to 0 to aim at the body (Center Mass). 
-- // Set to roughly 2.0 for Head, or -2.0 for Legs.
local VERTICAL_OFFSET = 0 

-- // UI CLEANUP
if CoreGui:FindFirstChild("MobileMegaSuite") then CoreGui.MobileMegaSuite:Destroy() end

local ScreenGui = Instance.new("ScreenGui", CoreGui)
ScreenGui.Name = "MobileMegaSuite"

local function createBtn(text, pos, color)
    local btn = Instance.new("TextButton", ScreenGui)
    btn.Size = UDim2.new(0, 150, 0, 45)
    btn.Position = pos
    btn.BackgroundColor3 = color
    btn.Text = text
    btn.TextColor3 = Color3.new(1, 1, 1)
    btn.Font = Enum.Font.GothamBold
    btn.TextSize = 12
    btn.Draggable = true
    Instance.new("UICorner", btn)
    return btn
end

local LockBtn = createBtn("AIMBOT: OFF", UDim2.new(0.05, 0, 0.35, 0), Color3.fromRGB(30, 30, 30))
local FreeBtn = createBtn("FREE AIM: OFF", UDim2.new(0.05, 0, 0.43, 0), Color3.fromRGB(30, 30, 30))
local ShootBtn = createBtn("ANYWHERE SHOOT: OFF", UDim2.new(0.05, 0, 0.51, 0), Color3.fromRGB(30, 30, 30))

-- // HELPER: Get Body Part
-- // This specifically looks for the Torso for better body aiming
local function getBodyPart(character)
    return character:FindFirstChild("UpperTorso") -- R15 Body
        or character:FindFirstChild("Torso")      -- R6 Body
        or character:FindFirstChild("HumanoidRootPart") -- Fallback
end

-- // TARGETING LOGIC
local function getBestTarget()
    local target, shortestDist = nil, math.huge
    local screenCenter = Vector2.new(camera.ViewportSize.X / 2, camera.ViewportSize.Y / 2)

    for _, p in pairs(Players:GetPlayers()) do
        if p ~= player and p.Character then
            local part = getBodyPart(p.Character)
            local hum = p.Character:FindFirstChild("Humanoid")
            
            if part and hum and hum.Health > 0 then
                -- Calculate position with the offset (0 means direct center of body)
                local worldPoint = part.Position + Vector3.new(0, VERTICAL_OFFSET, 0)
                local pos, onScreen = camera:WorldToViewportPoint(worldPoint)
                
                if onScreen then
                    local dist = (Vector2.new(pos.X, pos.Y) - screenCenter).Magnitude
                    if dist < shortestDist then 
                        target = p.Character 
                        shortestDist = dist 
                    end
                end
            end
        end
    end
    return target
end

-- // INPUT DETECTION (SHOOT ANYWHERE)
local IsTouching = false
UserInputService.InputBegan:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
        IsTouching = true
    end
end)
UserInputService.InputEnded:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
        IsTouching = false
    end
end)

-- // MAIN ENGINE
RunService.RenderStepped:Connect(function()
    -- 1. FREE AIM: Forcefully kill Shift-Lock rotation
    if player.Character and player.Character:FindFirstChild("Humanoid") then
        player.Character.Humanoid.AutoRotate = not FREE_AIM_ENABLED
    end

    -- 2. AIMBOT: Logic
    if AIM_ENABLED then
        if not LOCKED_TARGET or not LOCKED_TARGET:FindFirstChild("Humanoid") or LOCKED_TARGET.Humanoid.Health <= 0 then
            LOCKED_TARGET = getBestTarget()
        end
        
        if LOCKED_TARGET then
            local part = getBodyPart(LOCKED_TARGET)
            if part then
                local targetPos = part.Position + Vector3.new(0, VERTICAL_OFFSET, 0)
                camera.CFrame = CFrame.lookAt(camera.CFrame.Position, targetPos)
            end
        end
    else
        LOCKED_TARGET = nil
    end

    -- 3. SHOOT ANYWHERE: Triggers when you touch the screen
    if AUTO_SHOOT and IsTouching then
        local tool = player.Character:FindFirstChildOfClass("Tool")
        if tool then
            tool:Activate()
        end
    end
end)

-- // BUTTONS
LockBtn.MouseButton1Click:Connect(function()
    AIM_ENABLED = not AIM_ENABLED
    LockBtn.Text = AIM_ENABLED and "AIM: ACTIVE" or "AIMBOT: OFF"
    LockBtn.BackgroundColor3 = AIM_ENABLED and Color3.fromRGB(0, 150, 255) or Color3.fromRGB(30, 30, 30)
end)

FreeBtn.MouseButton1Click:Connect(function()
    FREE_AIM_ENABLED = not FREE_AIM_ENABLED
    FreeBtn.Text = FREE_AIM_ENABLED and "FREE AIM: ON" or "FREE AIM: OFF"
    FreeBtn.BackgroundColor3 = FREE_AIM_ENABLED and Color3.fromRGB(200, 150, 0) or Color3.fromRGB(30, 30, 30)
end)

ShootBtn.MouseButton1Click:Connect(function()
    AUTO_SHOOT = not AUTO_SHOOT
    ShootBtn.Text = AUTO_SHOOT and "SHOOT ANYWHERE: ON" or "ANYWHERE SHOOT: OFF"
    ShootBtn.BackgroundColor3 = AUTO_SHOOT and Color3.fromRGB(200, 0, 50) or Color3.fromRGB(30, 30, 30)
end)
