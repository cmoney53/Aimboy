local Players = game:GetService("Players")
local RunService = game:GetService("RunService")

local player = Players.LocalPlayer
local camera = workspace.CurrentCamera

-- // SETTINGS
local AIM_ENABLED = false
local GUI_VISIBLE = true
local FOV_RADIUS = 300   -- The "Snap" zone size
local MAX_DISTANCE = 3000 -- How far away it detects players

-- // UI SETUP
local ScreenGui = Instance.new("ScreenGui", player.PlayerGui)
ScreenGui.DisplayOrder = 999
ScreenGui.ResetOnSpawn = false

local MainToggle = Instance.new("TextButton", ScreenGui)
MainToggle.Size = UDim2.new(0, 160, 0, 55)
MainToggle.Position = UDim2.new(0.1, 0, 0.5, 0)
MainToggle.BackgroundColor3 = Color3.fromRGB(50, 50, 50)
MainToggle.Text = "DIRECT CHEST: OFF"
MainToggle.TextColor3 = Color3.new(1, 1, 1)
MainToggle.Font = Enum.Font.SourceSansBold
MainToggle.TextSize = 18
Instance.new("UICorner", MainToggle)

local HideBtn = Instance.new("TextButton", ScreenGui)
HideBtn.Size = UDim2.new(0, 45, 0, 45)
HideBtn.Position = UDim2.new(0.1, 0, 0.42, 0)
HideBtn.Text = "HIDE"
HideBtn.BackgroundColor3 = Color3.fromRGB(15, 15, 15)
HideBtn.TextColor3 = Color3.new(1, 1, 1)
Instance.new("UICorner", HideBtn).CornerRadius = UDim.new(1, 0)

-- // PURE SNAP LOGIC
local function getClosestPlayer()
    local target = nil
    local shortestMouseDist = FOV_RADIUS
    local screenCenter = Vector2.new(camera.ViewportSize.X / 2, camera.ViewportSize.Y / 2)

    for _, p in pairs(Players:GetPlayers()) do
        -- Locks onto everyone except the local player
        if p ~= player and p.Character then
            local chest = p.Character:FindFirstChild("HumanoidRootPart")
            local humanoid = p.Character:FindFirstChild("Humanoid")
            
            -- Ensure they are alive and have a chest to hit
            if chest and humanoid and humanoid.Health > 0 then
                local worldDist = (chest.Position - camera.CFrame.Position).Magnitude
                
                if worldDist <= MAX_DISTANCE then
                    local pos, onScreen = camera:WorldToViewportPoint(chest.Position)
                    
                    if onScreen then
                        local mouseDist = (Vector2.new(pos.X, pos.Y) - screenCenter).Magnitude
                        
                        if mouseDist < shortestMouseDist then
                            target = chest
                            shortestMouseDist = mouseDist
                        end
                    end
                end
            end
        end
    end
    return target
end

-- // INSTANT SNAP LOOP
RunService.RenderStepped:Connect(function()
    if AIM_ENABLED then
        local target = getClosestPlayer()
        if target then
            -- Snap camera directly to the center of the character
            camera.CFrame = CFrame.lookAt(camera.CFrame.Position, target.Position)
        end
    end
end)

-- // UI TOGGLES
MainToggle.MouseButton1Click:Connect(function()
    AIM_ENABLED = not AIM_ENABLED
    MainToggle.Text = AIM_ENABLED and "DIRECT CHEST: ON" or "DIRECT CHEST: OFF"
    MainToggle.BackgroundColor3 = AIM_ENABLED and Color3.fromRGB(255, 0, 0) or Color3.fromRGB(50, 50, 50)
end)

HideBtn.MouseButton1Click:Connect(function()
    GUI_VISIBLE = not GUI_VISIBLE
    MainToggle.Visible = GUI_VISIBLE
end)
