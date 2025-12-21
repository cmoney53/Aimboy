local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local CoreGui = game:GetService("CoreGui")

local player = Players.LocalPlayer
local camera = workspace.CurrentCamera

-- // SETTINGS
local AIM_ENABLED = false
local FREE_AIM_ENABLED = false
local AUTO_SHOOT = false
local LOCKED_TARGET = nil
local VERTICAL_OFFSET = 2.6 

-- // UI CLEANUP
if CoreGui:FindFirstChild("MobileMegaSuite") then CoreGui.MobileMegaSuite:Destroy() end

-- // UI SETUP
local ScreenGui = Instance.new("ScreenGui", CoreGui)
ScreenGui.Name = "MobileMegaSuite"
ScreenGui.IgnoreGuiInset = true

local function createBtn(name, text, pos, color)
    local btn = Instance.new("TextButton", ScreenGui)
    btn.Name = name
    btn.Size = UDim2.new(0, 140, 0, 42)
    btn.Position = pos
    btn.BackgroundColor3 = color
    btn.Text = text
    btn.TextColor3 = Color3.new(1, 1, 1)
    btn.Font = Enum.Font.GothamBold
    btn.TextSize = 12
    btn.Active = true
    btn.Draggable = true 
    Instance.new("UICorner", btn)
    return btn
end

-- Create the 3 buttons
local LockBtn = createBtn("LockBtn", "STICKY LOCK: OFF", UDim2.new(0.05, 0, 0.4, 0), Color3.fromRGB(30, 30, 30))
local FreeBtn = createBtn("FreeBtn", "FREE AIM: OFF", UDim2.new(0.05, 0, 0.48, 0), Color3.fromRGB(30, 30, 30))
local ShootBtn = createBtn("ShootBtn", "AUTO SHOOT: OFF", UDim2.new(0.05, 0, 0.56, 0), Color3.fromRGB(30, 30, 30))

-- // AUTO-SHOOT DETECTION
local function isPointingAtEnemy()
    -- Create a ray from the center of the screen (the crosshair)
    local mouseRay = camera:ViewportPointToRay(camera.ViewportSize.X / 2, camera.ViewportSize.Y / 2)
    local raycastParams = RaycastParams.new()
    raycastParams.FilterDescendantsInstances = {player.Character}
    raycastParams.FilterType = Enum.RaycastFilterType.Exclude
    
    local result = workspace:Raycast(mouseRay.Origin, mouseRay.Direction * 2000, raycastParams)
    
    if result and result.Instance then
        local model = result.Instance:FindFirstAncestorOfClass("Model")
        if model and model:FindFirstChild("Humanoid") and model ~= player.Character then
            return true
        end
    end
    return false
end

-- // TARGETING FUNCTION
local function getClosestToCrosshair()
    local closest = nil
    local shortestDist = math.huge
    local center = Vector2.new(camera.ViewportSize.X / 2, camera.ViewportSize.Y / 2)

    for _, p in pairs(Players:GetPlayers()) do
        if p ~= player and p.Character and p.Character:FindFirstChild("HumanoidRootPart") then
            local hum = p.Character:FindFirstChild("Humanoid")
            if hum and hum.Health > 0 then
                local worldPos = p.Character.HumanoidRootPart.Position + Vector3.new(0, VERTICAL_OFFSET, 0)
                local screenPos, onScreen = camera:WorldToViewportPoint(worldPos)
                
                if onScreen then
                    local mag = (Vector2.new(screenPos.X, screenPos.Y) - center).Magnitude
                    if mag < shortestDist then
                        closest = p.Character
                        shortestDist = mag
                    end
                end
            end
        end
    end
    return closest
end

-- // MAIN ENGINE
RunService.RenderStepped:Connect(function()
    -- Free Aim Logic
    if player.Character and player.Character:FindFirstChild("Humanoid") then
        player.Character.Humanoid.AutoRotate = not FREE_AIM_ENABLED
    end

    -- Aim Lock & Auto Shoot Logic
    if AIM_ENABLED then
        if not LOCKED_TARGET or not LOCKED_TARGET:FindFirstChild("Humanoid") or LOCKED_TARGET.Humanoid.Health <= 0 then
            LOCKED_TARGET = getClosestToCrosshair()
        end

        if LOCKED_TARGET and LOCKED_TARGET:FindFirstChild("HumanoidRootPart") then
            local targetPos = LOCKED_TARGET.HumanoidRootPart.Position + Vector3.new(0, VERTICAL_OFFSET, 0)
            camera.CFrame = CFrame.lookAt(camera.CFrame.Position, targetPos)
            
            if AUTO_SHOOT and isPointingAtEnemy() then
                local tool = player.Character:FindFirstChildOfClass("Tool")
                if tool then
                    tool:Activate()
                end
            end
        end
    else
        LOCKED_TARGET = nil
    end
end)

-- // BUTTON CONNECTORS
LockBtn.MouseButton1Click:Connect(function()
    AIM_ENABLED = not AIM_ENABLED
    LockBtn.Text = AIM_ENABLED and "LOCK: ON" or "STICKY LOCK: OFF"
    LockBtn.BackgroundColor3 = AIM_ENABLED and Color3.fromRGB(0, 150, 255) or Color3.fromRGB(30, 30, 30)
end)

FreeBtn.MouseButton1Click:Connect(function()
    FREE_AIM_ENABLED = not FREE_AIM_ENABLED
    FreeBtn.Text = FREE_AIM_ENABLED and "FREE AIM: ON" or "FREE AIM: OFF"
    FreeBtn.BackgroundColor3 = FREE_AIM_ENABLED and Color3.fromRGB(200, 150, 0) or Color3.fromRGB(30, 30, 30)
end)

ShootBtn.MouseButton1Click:Connect(function()
    AUTO_SHOOT = not AUTO_SHOOT
    ShootBtn.Text = AUTO_SHOOT and "SHOOT: ON" or "AUTO SHOOT: OFF"
    ShootBtn.BackgroundColor3 = AUTO_SHOOT and Color3.fromRGB(200, 0, 50) or Color3.fromRGB(30, 30, 30)
end)
