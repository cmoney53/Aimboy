local Players = game:GetService("Players")
local RunService = game:GetService("RunService")

local player = Players.LocalPlayer
local camera = workspace.CurrentCamera

-- // SETTINGS
local AIM_ENABLED = false
local GUI_VISIBLE = true
local FOV_RADIUS = 300   
local MAX_DISTANCE = 5000 
-- We use a high offset to stay on the upper chest
local CHEST_OFFSET = 1.75 

-- // UI SETUP
local ScreenGui = Instance.new("ScreenGui", player.PlayerGui)
ScreenGui.DisplayOrder = 999
ScreenGui.ResetOnSpawn = false

local MainToggle = Instance.new("TextButton", ScreenGui)
MainToggle.Size = UDim2.new(0, 160, 0, 55)
MainToggle.Position = UDim2.new(0.1, 0, 0.5, 0)
MainToggle.BackgroundColor3 = Color3.fromRGB(30, 30, 30)
MainToggle.Text = "FIXED AIM: OFF"
MainToggle.TextColor3 = Color3.new(1, 1, 1)
Instance.new("UICorner", MainToggle)

-- // LOCK LOGIC
local function getTarget()
    local target = nil
    local shortestMouseDist = FOV_RADIUS
    local screenCenter = Vector2.new(camera.ViewportSize.X / 2, camera.ViewportSize.Y / 2)

    for _, p in pairs(Players:GetPlayers()) do
        if p ~= player and p.Character then
            -- Target the RootPart but apply a height boost
            local root = p.Character:FindFirstChild("HumanoidRootPart")
            local hum = p.Character:FindFirstChild("Humanoid")
            
            if root and hum and hum.Health > 0 then
                local worldPos = root.Position + Vector3.new(0, CHEST_OFFSET, 0)
                local screenPos, onScreen = camera:WorldToViewportPoint(worldPos)
                
                if onScreen then
                    local mouseDist = (Vector2.new(screenPos.X, screenPos.Y) - screenCenter).Magnitude
                    if mouseDist < shortestMouseDist then
                        target = worldPos
                        shortestMouseDist = mouseDist
                    end
                end
            end
        end
    end
    return target
end

-- // THE FIX FOR THE "DIP"
RunService.RenderStepped:Connect(function()
    if AIM_ENABLED then
        local targetPos = getTarget()
        if targetPos then
            -- Instead of just looking at it, we force the Camera's CFrame
            -- to maintain the exact orientation toward the target
            local camPos = camera.CFrame.Position
            camera.CFrame = CFrame.new(camPos, targetPos)
        end
    end
end)

-- // BUTTONS
MainToggle.MouseButton1Click:Connect(function()
    AIM_ENABLED = not AIM_ENABLED
    MainToggle.Text = AIM_ENABLED and "FIXED AIM: ON" or "FIXED AIM: OFF"
    MainToggle.BackgroundColor3 = AIM_ENABLED and Color3.fromRGB(255, 0, 0) or Color3.fromRGB(30, 30, 30)
end)
