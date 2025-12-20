local Players = game:GetService("Players")
local RunService = game:GetService("RunService")

local player = Players.LocalPlayer
local camera = workspace.CurrentCamera

-- // SETTINGS
local AIM_ENABLED = false
local GUI_VISIBLE = true
local FOV_RADIUS = 300   -- How far from the center the target can be
local MAX_DISTANCE = 2000 -- Increased distance! (in studs)

-- // UI SETUP
local ScreenGui = Instance.new("ScreenGui", player.PlayerGui)
ScreenGui.DisplayOrder = 10
ScreenGui.ResetOnSpawn = false

local MainToggle = Instance.new("TextButton", ScreenGui)
MainToggle.Size = UDim2.new(0, 150, 0, 50)
MainToggle.Position = UDim2.new(0.1, 0, 0.5, 0)
MainToggle.BackgroundColor3 = Color3.fromRGB(30, 30, 30)
MainToggle.Text = "SNAP: OFF"
MainToggle.TextColor3 = Color3.new(1, 1, 1)
Instance.new("UICorner", MainToggle)

local HideBtn = Instance.new("TextButton", ScreenGui)
HideBtn.Size = UDim2.new(0, 40, 0, 40)
HideBtn.Position = UDim2.new(0.1, 0, 0.42, 0)
HideBtn.Text = "HIDE"
HideBtn.TextSize = 10
Instance.new("UICorner", HideBtn).CornerRadius = UDim.new(1, 0)

-- // OPTIMIZED TARGETING (No Lag)
local function getClosestPlayer()
    local target = nil
    local shortestMouseDist = FOV_RADIUS
    local screenCenter = Vector2.new(camera.ViewportSize.X / 2, camera.ViewportSize.Y / 2)

    -- ONLY loop through players (much faster than workspace:GetDescendants)
    for _, p in pairs(Players:GetPlayers()) do
        if p ~= player and p.Character and p.Character:FindFirstChild("Head") then
            local head = p.Character.Head
            
            -- Check physical distance in world (Studs)
            local worldDist = (head.Position - camera.CFrame.Position).Magnitude
            
            if worldDist <= MAX_DISTANCE then
                local pos, onScreen = camera:WorldToViewportPoint(head.Position)
                
                if onScreen then
                    -- Check distance from crosshair (Pixels)
                    local mouseDist = (Vector2.new(pos.X, pos.Y) - screenCenter).Magnitude
                    
                    if mouseDist < shortestMouseDist then
                        target = head
                        shortestMouseDist = mouseDist
                    end
                end
            end
        end
    end
    return target
end

-- // RUN SERVICE LOOP
RunService.RenderStepped:Connect(function()
    if AIM_ENABLED then
        local target = getClosestPlayer()
        if target then
            -- Instant snap for Shift Lock
            camera.CFrame = CFrame.lookAt(camera.CFrame.Position, target.Position)
        end
    end
end)

-- // UI LOGIC
MainToggle.MouseButton1Click:Connect(function()
    AIM_ENABLED = not AIM_ENABLED
    MainToggle.Text = AIM_ENABLED and "SNAP: ON" or "SNAP: OFF"
    MainToggle.BackgroundColor3 = AIM_ENABLED and Color3.fromRGB(200, 0, 0) or Color3.fromRGB(30, 30, 30)
end)

HideBtn.MouseButton1Click:Connect(function()
    GUI_VISIBLE = not GUI_VISIBLE
    MainToggle.Visible = GUI_VISIBLE
end)
