local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local CoreGui = game:GetService("CoreGui") -- Using CoreGui as requested

local player = Players.LocalPlayer
local camera = workspace.CurrentCamera

-- // SETTINGS
local AIM_ENABLED = false
local FREE_AIM_ENABLED = false
local AUTO_SHOOT = false
local LOCKED_TARGET = nil
local VERTICAL_OFFSET = 2.6 -- Keeps aim on chest/upper body

-- // UI CLEANUP & SETUP
if CoreGui:FindFirstChild("MobileMegaSuite") then 
    CoreGui.MobileMegaSuite:Destroy() 
end

local ScreenGui = Instance.new("ScreenGui")
ScreenGui.Name = "MobileMegaSuite"
ScreenGui.Parent = CoreGui
ScreenGui.ZIndexBehavior = Enum.ZIndexBehavior.Global
ScreenGui.IgnoreGuiInset = true

local function createBtn(name, text, pos, color)
    local btn = Instance.new("TextButton", ScreenGui)
    btn.Name = name
    btn.Size = UDim2.new(0, 145, 0, 45)
    btn.Position = pos
    btn.BackgroundColor3 = color
    btn.Text = text
    btn.TextColor3 = Color3.new(1, 1, 1)
    btn.Font = Enum.Font.GothamBold
    btn.TextSize = 13
    btn.ZIndex = 100 -- Ensures it sits on top of all game UI
    btn.Active = true
    btn.Draggable = true 
    
    local Corner = Instance.new("UICorner")
    Corner.CornerRadius = UDim.new(0, 8)
    Corner.Parent = btn
    
    return btn
end

-- Create the 3 buttons on the left side
local LockBtn = createBtn("LockBtn", "STICKY LOCK: OFF", UDim2.new(0.05, 0, 0.35, 0), Color3.fromRGB(20, 20, 20))
local FreeBtn = createBtn("FreeBtn", "FREE AIM: OFF", UDim2.new(0.05, 0, 0.43, 0), Color3.fromRGB(20, 20, 20))
local ShootBtn = createBtn("ShootBtn", "AUTO SHOOT: OFF", UDim2.new(0.05, 0, 0.51, 0), Color3.fromRGB(20, 20, 20))

-- // LOGIC: FIND CLOSEST TARGET
local function getClosest()
    local target, dist = nil, math.huge
    local center = Vector2.new(camera.ViewportSize.X/2, camera.ViewportSize.Y/2)
    
    for _, p in pairs(Players:GetPlayers()) do
        if p ~= player and p.Character and p.Character:FindFirstChild("HumanoidRootPart") then
            local hum = p.Character:FindFirstChild("Humanoid")
            if hum and hum.Health > 0 then
                -- Calculate point on the upper chest
                local targetWorldPos = p.Character.HumanoidRootPart.Position + Vector3.new(0, VERTICAL_OFFSET, 0)
                local screenPos, onScreen = camera:WorldToViewportPoint(targetWorldPos)
                
                if onScreen then
                    local m = (Vector2.new(screenPos.X, screenPos.Y) - center).Magnitude
                    if m < dist then
                        target = p.Character
                        dist = m
                    end
                end
            end
        end
    end
    return target
end

-- // MAIN RUN LOOP
RunService.RenderStepped:Connect(function()
    -- Free Aim: Bypasses Perm Shift-Lock by disabling character rotation
    if player.Character and player.Character:FindFirstChild("Humanoid") then
        player.Character.Humanoid.AutoRotate = not FREE_AIM_ENABLED
    end

    -- Aim Lock Logic
    if AIM_ENABLED then
        -- Sticky Target Persistence
        if not LOCKED_TARGET or not LOCKED_TARGET:FindFirstChild("Humanoid") or LOCKED_TARGET.Humanoid.Health <= 0 then
            LOCKED_TARGET = getClosest()
        end

        if LOCKED_TARGET and LOCKED_TARGET:FindFirstChild("HumanoidRootPart") then
            local aimPoint = LOCKED_TARGET.HumanoidRootPart.Position + Vector3.new(0, VERTICAL_OFFSET, 0)
            
            -- Force Camera to Target (The Shift-Lock Bypass)
            camera.CFrame = CFrame.lookAt(camera.CFrame.Position, aimPoint)
            
            -- Auto Shoot Trigger
            if AUTO_SHOOT then
                local tool = player.Character:FindFirstChildOfClass("Tool")
                if tool then tool:Activate() end
            end
        end
    else
        LOCKED_TARGET = nil
    end
end)

-- // BUTTON CONNECTIONS
LockBtn.MouseButton1Click:Connect(function()
    AIM_ENABLED = not AIM_ENABLED
    LockBtn.Text = AIM_ENABLED and "LOCK: ACTIVE" or "STICKY LOCK: OFF"
    LockBtn.BackgroundColor3 = AIM_ENABLED and Color3.fromRGB(0, 120, 255) or Color3.fromRGB(20, 20, 20)
end)

FreeBtn.MouseButton1Click:Connect(function()
    FREE_AIM_ENABLED = not FREE_AIM_ENABLED
    FreeBtn.Text = FREE_AIM_ENABLED and "FREE AIM: ON" or "FREE AIM: OFF"
    FreeBtn.BackgroundColor3 = FREE_AIM_ENABLED and Color3.fromRGB(200, 150, 0) or Color3.fromRGB(20, 20, 20)
end)

ShootBtn.MouseButton1Click:Connect(function()
    AUTO_SHOOT = not AUTO_SHOOT
    ShootBtn.Text = AUTO_SHOOT and "SHOOTER: ON" or "AUTO SHOOT: OFF"
    ShootBtn.BackgroundColor3 = AUTO_SHOOT and Color3.fromRGB(200, 0, 50) or Color3.fromRGB(20, 20, 20)
end)
