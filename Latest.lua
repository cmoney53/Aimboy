-- Ensure the game is loaded before starting
if not game:IsLoaded() then game.Loaded:Wait() end

local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local player = Players.LocalPlayer
local camera = workspace.CurrentCamera

-- // SETTINGS
local AIM_ENABLED = false
local GUI_VISIBLE = true
local FOV_RADIUS = 250 

-- // UI CREATION (High Priority)
local ScreenGui = Instance.new("ScreenGui")
ScreenGui.Name = "FinalAimSystem"
ScreenGui.DisplayOrder = 999 -- Ensures it stays above mobile controls
ScreenGui.Parent = player:WaitForChild("PlayerGui")
ScreenGui.ResetOnSpawn = false

local MainToggle = Instance.new("TextButton", ScreenGui)
MainToggle.Size = UDim2.new(0, 160, 0, 60)
MainToggle.Position = UDim2.new(0.1, 0, 0.5, 0)
MainToggle.BackgroundColor3 = Color3.fromRGB(40, 40, 40)
MainToggle.Text = "AIMBOT: OFF"
MainToggle.TextColor3 = Color3.new(1, 1, 1)
MainToggle.TextSize = 20
Instance.new("UICorner", MainToggle)

local HideBtn = Instance.new("TextButton", ScreenGui)
HideBtn.Size = UDim2.new(0, 40, 0, 40)
HideBtn.Position = UDim2.new(0.1, 0, 0.43, 0)
HideBtn.Text = "X"
HideBtn.BackgroundColor3 = Color3.fromRGB(200, 0, 0)
HideBtn.TextColor3 = Color3.new(1, 1, 1)
Instance.new("UICorner", HideBtn).CornerRadius = UDim.new(1, 0)

local FOVGraphic = Instance.new("Frame", ScreenGui)
FOVGraphic.Size = UDim2.new(0, FOV_RADIUS * 2, 0, FOV_RADIUS * 2)
FOVGraphic.AnchorPoint = Vector2.new(0.5, 0.5)
FOVGraphic.Position = UDim2.new(0.5, 0, 0.5, 0)
FOVGraphic.BackgroundTransparency = 0.9
FOVGraphic.BackgroundColor3 = Color3.new(1, 1, 1)
FOVGraphic.Visible = false
Instance.new("UICorner", FOVGraphic).CornerRadius = UDim.new(1, 0)

-- // BUTTONS LOGIC
MainToggle.MouseButton1Click:Connect(function()
    AIM_ENABLED = not AIM_ENABLED
    MainToggle.Text = AIM_ENABLED and "AIMBOT: ON" or "AIMBOT: OFF"
    MainToggle.BackgroundColor3 = AIM_ENABLED and Color3.fromRGB(0, 180, 0) or Color3.fromRGB(40, 40, 40)
    FOVGraphic.Visible = AIM_ENABLED
end)

HideBtn.MouseButton1Click:Connect(function()
    GUI_VISIBLE = not GUI_VISIBLE
    MainToggle.Visible = GUI_VISIBLE
    HideBtn.Text = GUI_VISIBLE and "X" or "O"
end)

-- // TARGETING LOGIC (Works for Players AND NPCs)
local function getClosestTarget()
    local target = nil
    local shortestDist = FOV_RADIUS
    local center = Vector2.new(camera.ViewportSize.X / 2, camera.ViewportSize.Y / 2)

    -- Look through EVERYTHING in Workspace for a Head
    for _, obj in pairs(workspace:GetDescendants()) do
        if obj:IsA("Part") and obj.Name == "Head" then
            -- Make sure we aren't locking onto our own head
            if not obj:IsDescendantOf(player.Character) then
                local pos, onScreen = camera:WorldToViewportPoint(obj.Position)
                if onScreen then
                    local dist = (Vector2.new(pos.X, pos.Y) - center).Magnitude
                    if dist < shortestDist then
                        target = obj
                        shortestDist = dist
                    end
                end
            end
        end
    end
    return target
end

-- // THE SNAP LOOP
RunService.RenderStepped:Connect(function()
    if AIM_ENABLED then
        local target = getClosestTarget()
        if target then
            -- This is the "Pure" snap for Shiftlock
            camera.CFrame = CFrame.lookAt(camera.CFrame.Position, target.Position)
        end
    end
end)
