local Players = game:GetService("Players")
local RunService = game:GetService("RunService")

local player = Players.LocalPlayer
local camera = workspace.CurrentCamera

-- // SETTINGS
local AIM_ENABLED = false
local MAX_DISTANCE = 10000 -- Long distance for "sniper" FOV
-- 0.2 means the snap zone is 20% of your screen size. 
-- At FOV 20, you might want to lower this to 0.1 for precision.
local FOV_PERCENT = 0.2 

-- // UI SETUP
local ScreenGui = Instance.new("ScreenGui", player.PlayerGui)
ScreenGui.DisplayOrder = 999
ScreenGui.ResetOnSpawn = false

local MainToggle = Instance.new("TextButton", ScreenGui)
MainToggle.Size = UDim2.new(0, 160, 0, 55)
MainToggle.Position = UDim2.new(0.1, 0, 0.5, 0)
MainToggle.BackgroundColor3 = Color3.fromRGB(0, 0, 0)
MainToggle.Text = "20-FOV LOCK: OFF"
MainToggle.TextColor3 = Color3.new(1, 1, 1)
Instance.new("UICorner", MainToggle)

-- // DYNAMIC CALCULATION
local function getClosestHead()
    local target = nil
    
    -- Calculate radius based on current screen size
    local minScreenSide = math.min(camera.ViewportSize.X, camera.ViewportSize.Y)
    local dynamicRadius = minScreenSide * FOV_PERCENT
    local screenCenter = Vector2.new(camera.ViewportSize.X / 2, camera.ViewportSize.Y / 2)

    for _, p in pairs(Players:GetPlayers()) do
        if p ~= player and p.Character then
            local head = p.Character:FindFirstChild("Head")
            local humanoid = p.Character:FindFirstChild("Humanoid")
            
            if head and humanoid and humanoid.Health > 0 then
                -- Use WorldToScreenPoint to ignore the high/low FOV distortion
                local pos, onScreen = camera:WorldToScreenPoint(head.Position)
                
                if onScreen then
                    local mouseDist = (Vector2.new(pos.X, pos.Y) - screenCenter).Magnitude
                    
                    if mouseDist < dynamicRadius then
                        target = head
                        dynamicRadius = mouseDist -- Constantly narrow down to the closest
                    end
                end
            end
        end
    end
    return target
end

-- // INSTANT SNAP
RunService.RenderStepped:Connect(function()
    if AIM_ENABLED then
        local targetHead = getClosestHead()
        if targetHead then
            -- Pure CFrame snap
            camera.CFrame = CFrame.lookAt(camera.CFrame.Position, targetHead.Position)
        end
    end
end)

-- // BUTTON
MainToggle.MouseButton1Click:Connect(function()
    AIM_ENABLED = not AIM_ENABLED
    MainToggle.Text = AIM_ENABLED and "LOCK: ON" or "LOCK: OFF"
    MainToggle.BackgroundColor3 = AIM_ENABLED and Color3.fromRGB(200, 0, 0) or Color3.fromRGB(0, 0, 0)
end)
