local Players = game:GetService("Players")
local RunService = game:GetService("RunService")

local player = Players.LocalPlayer
local camera = workspace.CurrentCamera

-- // SETTINGS
local AIM_ENABLED = false
local GUI_VISIBLE = true
local FOV_RADIUS = 300   -- Increase this if 120 FOV makes targets too "small"
local MAX_DISTANCE = 5000 

-- // UI SETUP
local ScreenGui = Instance.new("ScreenGui", player.PlayerGui)
ScreenGui.DisplayOrder = 999
ScreenGui.ResetOnSpawn = false

local MainToggle = Instance.new("TextButton", ScreenGui)
MainToggle.Size = UDim2.new(0, 160, 0, 55)
MainToggle.Position = UDim2.new(0.1, 0, 0.5, 0)
MainToggle.BackgroundColor3 = Color3.fromRGB(10, 10, 10)
MainToggle.Text = "120 FOV SNAP: OFF"
MainToggle.TextColor3 = Color3.new(1, 1, 1)
MainToggle.Font = Enum.Font.SourceSansBold
MainToggle.TextSize = 16
Instance.new("UICorner", MainToggle)

-- // TARGETING LOGIC
local function getClosestHead()
    local target = nil
    local shortestMouseDist = FOV_RADIUS
    
    -- Using ScreenCenter to account for High FOV distortion
    local screenCenter = Vector2.new(camera.ViewportSize.X / 2, camera.ViewportSize.Y / 2)

    for _, p in pairs(Players:GetPlayers()) do
        if p ~= player and p.Character then
            local head = p.Character:FindFirstChild("Head")
            local humanoid = p.Character:FindFirstChild("Humanoid")
            
            if head and humanoid and humanoid.Health > 0 then
                -- Calculate distance from you to enemy
                local worldDist = (head.Position - camera.CFrame.Position).Magnitude
                
                if worldDist <= MAX_DISTANCE then
                    -- WorldToScreenPoint is better for high FOVs than WorldToViewportPoint
                    local pos, onScreen = camera:WorldToScreenPoint(head.Position)
                    
                    if onScreen then
                        local mouseDist = (Vector2.new(pos.X, pos.Y) - screenCenter).Magnitude
                        
                        if mouseDist < shortestMouseDist then
                            target = head
                            shortestMouseDist = mouseDist
                        end
                    end
                end
            end
        end
    end
    return target
end

-- // THE UPDATE LOOP
RunService.RenderStepped:Connect(function()
    if AIM_ENABLED then
        local targetHead = getClosestHead()
        if targetHead then
            -- We force the camera to point at the target 
            -- We keep the camera's original Position to prevent "teleporting"
            camera.CFrame = CFrame.lookAt(camera.CFrame.Position, targetHead.Position)
        end
    end
end)

-- // UI LOGIC
MainToggle.MouseButton1Click:Connect(function()
    AIM_ENABLED = not AIM_ENABLED
    MainToggle.Text = AIM_ENABLED and "SNAP: ON" or "SNAP: OFF"
    MainToggle.BackgroundColor3 = AIM_ENABLED and Color3.fromRGB(255, 0, 0) or Color3.fromRGB(10, 10, 10)
end)
