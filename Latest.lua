local Players = game:GetService("Players")
local RunService = game:GetService("RunService")

local player = Players.LocalPlayer
local camera = workspace.CurrentCamera

-- // SETTINGS
local AIM_ENABLED = false
local MAX_DISTANCE = 100000 -- Infinite Range (100k studs)
local SNAP_ZONE = 500       -- How many pixels away from the head to trigger the snap

-- // UI SETUP
local ScreenGui = Instance.new("ScreenGui", player.PlayerGui)
ScreenGui.DisplayOrder = 999
ScreenGui.ResetOnSpawn = false

local MainToggle = Instance.new("TextButton", ScreenGui)
MainToggle.Size = UDim2.new(0, 160, 0, 55)
MainToggle.Position = UDim2.new(0.1, 0, 0.5, 0)
MainToggle.BackgroundColor3 = Color3.fromRGB(0, 0, 0)
MainToggle.Text = "MAX RANGE: OFF"
MainToggle.TextColor3 = Color3.new(1, 1, 1)
MainToggle.Font = Enum.Font.SourceSansBold
Instance.new("UICorner", MainToggle)

-- // LONG RANGE TARGETING
local function getLongRangeTarget()
    local target = nil
    local shortestMouseDist = SNAP_ZONE
    local screenCenter = Vector2.new(camera.ViewportSize.X / 2, camera.ViewportSize.Y / 2)

    for _, p in pairs(Players:GetPlayers()) do
        if p ~= player and p.Character then
            local head = p.Character:FindFirstChild("Head")
            local hum = p.Character:FindFirstChild("Humanoid")
            
            if head and hum and hum.Health > 0 then
                -- Direct world distance check
                local dist = (head.Position - camera.CFrame.Position).Magnitude
                
                if dist <= MAX_DISTANCE then
                    -- Use WorldToViewportPoint for exact pixel math
                    local pos, onScreen = camera:WorldToViewportPoint(head.Position)
                    
                    if onScreen then
                        local mouseDist = (Vector2.new(pos.X, pos.Y) - screenCenter).Magnitude
                        
                        -- If the player is within our screen snap zone
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

-- // SNAP LOOP
RunService.RenderStepped:Connect(function()
    if AIM_ENABLED then
        local target = getLongRangeTarget()
        if target then
            -- Pure CFrame lookAt for instant lock
            camera.CFrame = CFrame.lookAt(camera.CFrame.Position, target.Position)
        end
    end
end)

-- // BUTTON LOGIC
MainToggle.MouseButton1Click:Connect(function()
    AIM_ENABLED = not AIM_ENABLED
    MainToggle.Text = AIM_ENABLED and "MAX RANGE: ON" or "MAX RANGE: OFF"
    MainToggle.BackgroundColor3 = AIM_ENABLED and Color3.fromRGB(255, 0, 0) or Color3.fromRGB(0, 0, 0)
end)
