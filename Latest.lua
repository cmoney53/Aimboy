local Players = game:GetService("Players")
local RunService = game:GetService("RunService")

local player = Players.LocalPlayer
local camera = workspace.CurrentCamera

-- // SETTINGS
local AIM_ENABLED = false
local GUI_VISIBLE = true
local FOV_RADIUS = 200 

-- // UI SETUP
local ScreenGui = Instance.new("ScreenGui", player.PlayerGui)
ScreenGui.Name = "ShiftLockAim"
ScreenGui.ResetOnSpawn = false

-- Button Container
local ButtonContainer = Instance.new("Frame", ScreenGui)
ButtonContainer.Size = UDim2.new(0, 150, 0, 60)
ButtonContainer.Position = UDim2.new(0.05, 0, 0.45, 0)
ButtonContainer.BackgroundTransparency = 1

-- Instant Aim Toggle
local AimButton = Instance.new("TextButton", ButtonContainer)
AimButton.Size = UDim2.new(1, 0, 1, 0)
AimButton.BackgroundColor3 = Color3.fromRGB(130, 0, 0)
AimButton.Text = "SNAP: OFF"
AimButton.TextColor3 = Color3.new(1, 1, 1)
AimButton.Font = Enum.Font.SecondaryGeneric
AimButton.TextSize = 20
Instance.new("UICorner", AimButton)

-- Hide/Show Button
local HideBtn = Instance.new("TextButton", ScreenGui)
HideBtn.Size = UDim2.new(0, 50, 0, 50)
HideBtn.Position = UDim2.new(0.05, 0, 0.35, 0)
HideBtn.BackgroundColor3 = Color3.fromRGB(20, 20, 20)
HideBtn.Text = "UI"
HideBtn.TextColor3 = Color3.new(1, 1, 1)
Instance.new("UICorner", HideBtn).CornerRadius = UDim.new(1, 0)

-- FOV Circle
local Circle = Instance.new("Frame", ScreenGui)
Circle.Size = UDim2.new(0, FOV_RADIUS * 2, 0, FOV_RADIUS * 2)
Circle.AnchorPoint = Vector2.new(0.5, 0.5)
Circle.Position = UDim2.new(0.5, 0, 0.5, 0)
Circle.BackgroundTransparency = 0.85
Circle.BackgroundColor3 = Color3.new(1, 0, 0)
Circle.Visible = false
Instance.new("UICorner", Circle).CornerRadius = UDim.new(1, 0)

-- // BUTTONS
AimButton.MouseButton1Click:Connect(function()
    AIM_ENABLED = not AIM_ENABLED
    AimButton.Text = AIM_ENABLED and "SNAP: ON" or "SNAP: OFF"
    AimButton.BackgroundColor3 = AIM_ENABLED and Color3.fromRGB(255, 0, 0) or Color3.fromRGB(130, 0, 0)
    Circle.Visible = AIM_ENABLED
end)

HideBtn.MouseButton1Click:Connect(function()
    GUI_VISIBLE = not GUI_VISIBLE
    ButtonContainer.Visible = GUI_VISIBLE
    HideBtn.Text = GUI_VISIBLE and "UI" or "OFF"
end)

-- // SHIFT LOCK TARGETING
local function getClosestPlayer()
    local target = nil
    local shortestDist = FOV_RADIUS

    for _, p in pairs(Players:GetPlayers()) do
        -- Only target other players with health
        if p ~= player and p.Character and p.Character:FindFirstChild("Head") then
            local humanoid = p.Character:FindFirstChild("Humanoid")
            if humanoid and humanoid.Health > 0 then
                local head = p.Character.Head
                -- Find screen position
                local pos, onScreen = camera:WorldToViewportPoint(head.Position)

                if onScreen then
                    -- Check distance from the center of the screen (where Shift Lock crosshair sits)
                    local screenCenter = Vector2.new(camera.ViewportSize.X / 2, camera.ViewportSize.Y / 2)
                    local dist = (Vector2.new(pos.X, pos.Y) - screenCenter).Magnitude

                    if dist < shortestDist then
                        target = head
                        shortestDist = dist
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
        local target = getClosestPlayer()
        if target then
            -- This line forces the Camera to look at the target
            -- Because you are in Shift Lock, the character will follow the camera automatically
            camera.CFrame = CFrame.lookAt(camera.CFrame.Position, target.Position)
        end
    end
end)
