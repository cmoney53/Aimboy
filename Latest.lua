local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local CoreGui = game:GetService("CoreGui") -- Using CoreGui to ensure visibility

local player = Players.LocalPlayer
local camera = workspace.CurrentCamera

-- Wait for character to ensure script doesn't error on start
if not player.Character then player.CharacterAdded:Wait() end

-- // SETTINGS
local AIM_ENABLED = false
local MAX_DISTANCE = 100000 
local VERTICAL_OFFSET = 2.6 

-- // CLEAN UP PREVIOUS UI (Prevents multiple buttons if you run it twice)
local oldGui = CoreGui:FindFirstChild("MobileChestLock")
if oldGui then oldGui:Destroy() end

-- // UI SETUP
local ScreenGui = Instance.new("ScreenGui")
ScreenGui.Name = "MobileChestLock"
ScreenGui.Parent = CoreGui -- This puts it above all game menus
ScreenGui.IgnoreGuiInset = true

local MainToggle = Instance.new("TextButton")
MainToggle.Parent = ScreenGui
MainToggle.Size = UDim2.new(0, 150, 0, 50)
MainToggle.Position = UDim2.new(0.05, 0, 0.45, 0)
MainToggle.BackgroundColor3 = Color3.fromRGB(30, 30, 30)
MainToggle.BorderSizePixel = 2
MainToggle.BorderColor3 = Color3.fromRGB(255, 255, 255)
MainToggle.Text = "CHEST LOCK: OFF"
MainToggle.TextColor3 = Color3.new(1, 1, 1)
MainToggle.Font = Enum.Font.GothamBold
MainToggle.TextSize = 14
MainToggle.Active = true
MainToggle.Draggable = true -- You can move it if it's in the way

local Corner = Instance.new("UICorner")
Corner.Parent = MainToggle

-- // TARGETING LOGIC
local function getTarget()
    local targetPos = nil
    local shortestMouseDist = math.huge
    local screenCenter = Vector2.new(camera.ViewportSize.X / 2, camera.ViewportSize.Y / 2)

    for _, p in pairs(Players:GetPlayers()) do
        if p ~= player and p.Character then
            local root = p.Character:FindFirstChild("HumanoidRootPart")
            local hum = p.Character:FindFirstChild("Humanoid")
            
            if root and hum and hum.Health > 0 then
                local worldPoint = root.Position + Vector3.new(0, VERTICAL_OFFSET, 0)
                local pos, onScreen = camera:WorldToViewportPoint(worldPoint)
                
                if onScreen then
                    local mouseDist = (Vector2.new(pos.X, pos.Y) - screenCenter).Magnitude
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

-- // SHIFT-LOCK BYPASS LOOP
RunService.RenderStepped:Connect(function()
    if AIM_ENABLED then
        local chestPoint = getTarget()
        if chestPoint then
            camera.CFrame = CFrame.lookAt(camera.CFrame.Position, chestPoint)
        end
    end
end)

-- // BUTTON INTERACTION
MainToggle.MouseButton1Click:Connect(function()
    AIM_ENABLED = not AIM_ENABLED
    MainToggle.Text = AIM_ENABLED and "CHEST LOCK: ON" or "CHEST LOCK: OFF"
    MainToggle.BackgroundColor3 = AIM_ENABLED and Color3.fromRGB(200, 0, 0) or Color3.fromRGB(30, 30, 30)
end)
