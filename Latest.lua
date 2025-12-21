local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local CoreGui = game:GetService("CoreGui")

local player = Players.LocalPlayer
local camera = workspace.CurrentCamera

-- // SETTINGS
local AIM_ENABLED = false
local FREE_AIM_ACTIVE = false
local IS_TOUCHING = false
local LOCKED_TARGET = nil
local VERTICAL_OFFSET = 2.4 -- Chest/Upper Body height

-- // UI SETUP
if CoreGui:FindFirstChild("MobileControlSuite") then CoreGui.MobileControlSuite:Destroy() end
local ScreenGui = Instance.new("ScreenGui", CoreGui)
ScreenGui.Name = "MobileControlSuite"

local function createBtn(text, pos, color)
    local btn = Instance.new("TextButton", ScreenGui)
    btn.Size = UDim2.new(0, 160, 0, 45)
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

local LockBtn = createBtn("AIMBOT: OFF", UDim2.new(0.05, 0, 0.4, 0), Color3.fromRGB(30, 30, 30))
local FreeBtn = createBtn("FREE AIM (TAP TO SHOOT): OFF", UDim2.new(0.05, 0, 0.48, 0), Color3.fromRGB(30, 30, 30))

-- // INPUT DETECTION: Detects any tap on the screen
UserInputService.InputBegan:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
        IS_TOUCHING = true
    end
end)
UserInputService.InputEnded:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
        IS_TOUCHING = false
    end
end)

-- // TARGETING LOGIC
local function getBestTarget()
    local target, shortestDist = nil, math.huge
    local screenCenter = Vector2.new(camera.ViewportSize.X / 2, camera.ViewportSize.Y / 2)

    for _, p in pairs(Players:GetPlayers()) do
        if p ~= player and p.Character and p.Character:FindFirstChild("HumanoidRootPart") then
            local hum = p.Character:FindFirstChild("Humanoid")
            if hum and hum.Health > 0 then
                local worldPoint = p.Character.HumanoidRootPart.Position + Vector3.new(0, VERTICAL_OFFSET, 0)
                local pos, onScreen = camera:WorldToViewportPoint(worldPoint)
                if onScreen then
                    local dist = (Vector2.new(pos.X, pos.Y) - screenCenter).Magnitude
                    if dist < shortestDist then target = p.Character shortestDist = dist end
                end
            end
        end
    end
    return target
end

-- // MAIN RUN LOOP
RunService.RenderStepped:Connect(function()
    -- 1. THE FREE AIM OVERRIDE
    if player.Character and player.Character:FindFirstChild("Humanoid") then
        if FREE_AIM_ACTIVE then
            -- Force character to stop turning with the camera
            player.Character.Humanoid.AutoRotate = false 
            
            -- SHOOT ANYWHERE: Trigger tool whenever screen is touched
            if IS_TOUCHING then
                local tool = player.Character:FindFirstChildOfClass("Tool")
                if tool then tool:Activate() end
            end
        else
            -- Restore game's default Shift Lock behavior
            player.Character.Humanoid.AutoRotate = true 
        end
    end

    -- 2. AIMBOT: Chest/Body Correction
    if AIM_ENABLED then
        if not LOCKED_TARGET or not LOCKED_TARGET:FindFirstChild("Humanoid") or LOCKED_TARGET.Humanoid.Health <= 0 then
            LOCKED_TARGET = getBestTarget()
        end
        if LOCKED_TARGET and LOCKED_TARGET:FindFirstChild("HumanoidRootPart") then
            local targetPos = LOCKED_TARGET.HumanoidRootPart.Position + Vector3.new(0, VERTICAL_OFFSET, 0)
            
            -- Force camera to look at target
            camera.CFrame = CFrame.lookAt(camera.CFrame.Position, targetPos)
        end
    else
        LOCKED_TARGET = nil
    end
end)

-- // BUTTON CONNECTORS
LockBtn.MouseButton1Click:Connect(function()
    AIM_ENABLED = not AIM_ENABLED
    LockBtn.Text = AIM_ENABLED and "AIMBOT: ACTIVE" or "AIMBOT: OFF"
    LockBtn.BackgroundColor3 = AIM_ENABLED and Color3.fromRGB(0, 150, 255) or Color3.fromRGB(30, 30, 30)
end)

FreeBtn.MouseButton1Click:Connect(function()
    FREE_AIM_ACTIVE = not FREE_AIM_ACTIVE
    FreeBtn.Text = FREE_AIM_ACTIVE and "FREE AIM: ON" or "FREE AIM (TAP TO SHOOT): OFF"
    FreeBtn.BackgroundColor3 = FREE_AIM_ACTIVE and Color3.fromRGB(200, 150, 0) or Color3.fromRGB(30, 30, 30)
end)
