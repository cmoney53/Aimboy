ua

local Players = game:GetService("Players")
local RunService = game:GetService("RunService")

local player = Players.LocalPlayer
local camera = workspace.CurrentCamera

-- // SETTINGS
local AIM_ENABLED = false
local MAX_DISTANCE = 100000 -- Infinite Range
local VERTICAL_OFFSET = 2.6 -- Keeps aim on chest, not feet (Increase to 3.0 if still low)

-- // UI SETUP (Mobile Optimized)
local ScreenGui = Instance.new("ScreenGui", player.PlayerGui)
ScreenGui.ResetOnSpawn = false
ScreenGui.IgnoreGuiInset = true
ScreenGui.DisplayOrder = 999

local MainToggle = Instance.new("TextButton", ScreenGui)
MainToggle.Name = "ChestLockToggle"
MainToggle.Size = UDim2.new(0, 150, 0, 50)
MainToggle.Position = UDim2.new(0.05, 0, 0.45, 0) -- Side of screen for thumb
MainToggle.BackgroundColor3 = Color3.fromRGB(30, 30, 30)
MainToggle.Text = "CHEST LOCK: OFF"
MainToggle.TextColor3 = Color3.new(1, 1, 1)
MainToggle.Font = Enum.Font.GothamBold
MainToggle.TextSize = 14
Instance.new("UICorner", MainToggle)

-- // TARGETING LOGIC (Full Screen Scan)
local function getTarget()
    local targetPos = nil
    local shortestMouseDist = math.huge
    local screenCenter = Vector2.new(camera.ViewportSize.X / 2, camera.ViewportSize.Y / 2)

    for _, p in pairs(Players:GetPlayers()) do
        if p ~= player and p.Character then
            -- Specifically targeting the chest area
            local root = p.Character:FindFirstChild("HumanoidRootPart")
            local hum = p.Character:FindFirstChild("Humanoid")
            
            if root and hum and hum.Health > 0 then
                -- This math creates a point at the upper-chest level
                local worldPoint = root.Position + Vector3.new(0, VERTICAL_OFFSET, 0)
                
                -- Check if they are visible on your phone screen
                local pos, onScreen = camera:WorldToViewportPoint(worldPoint)
                
                if onScreen then
                    local mouseDist = (Vector2.new(pos.X, pos.Y) - screenCenter).Magnitude
                    
                    -- Locks to the person closest to your crosshair
                    if mouseDist < shortestMouseDist then
                        targetPos = worldPoint
                        shortestMouseDist = mouseDist
                    end
                end
            end
        end
    end
    return targetPos
end

-- // THE SHIFT-LOCK BYPASS
-- We use RenderStepped to overwrite the camera's "dip" every single frame
RunService.RenderStepped:Connect(function()
    if AIM_ENABLED then
        local chestPoint = getTarget()
        if chestPoint then
            -- This forces the camera crosshair directly onto the chest point
            -- regardless of your FOV or distance from the target.
            camera.CFrame = CFrame.lookAt(camera.CFrame.Position, chestPoint)
        end
    end
end)

-- // BUTTON INTERACTION
MainToggle.MouseButton1Click:Connect(function()
    AIM_ENABLED = not AIM_ENABLED
    
    if AIM_ENABLED then
        MainToggle.Text = "CHEST LOCK: ON"
        MainToggle.BackgroundColor3 = Color3.fromRGB(200, 0, 0)
    else
        MainToggle.Text = "CHEST LOCK: OFF"
        MainToggle.BackgroundColor3 = Color3.fromRGB(30, 30, 30)
    end
end)
