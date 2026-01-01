local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local CoreGui = game:GetService("CoreGui")

local player = Players.LocalPlayer
local camera = workspace.CurrentCamera

-- // SETTINGS
local AIM_ENABLED = false
local AUTO_SHOOT = false 
local LOCKED_TARGET = nil

-- // PC & MOBILE TUNING
local VERTICAL_OFFSET = 0 -- 0 = Stomach/Chest (Perfect for Shift Lock)
local SMOOTHNESS = 0.25   -- Lower = smoother/legit, Higher = snappier/stronger
local FOV_RADIUS = 300    -- How close the enemy must be to your crosshair to lock

-- // UI SETUP
if CoreGui:FindFirstChild("MobileMegaSuite") then CoreGui.MobileMegaSuite:Destroy() end

local ScreenGui = Instance.new("ScreenGui", CoreGui)
ScreenGui.Name = "MobileMegaSuite"

local function createBtn(text, pos, color)
    local btn = Instance.new("TextButton", ScreenGui)
    btn.Size = UDim2.new(0, 140, 0, 45)
    btn.Position = pos
    btn.BackgroundColor3 = color
    btn.Text = text
    btn.TextColor3 = Color3.new(1, 1, 1)
    btn.Font = Enum.Font.GothamBold
    btn.TextSize = 13
    btn.Draggable = true -- VERY IMPORTANT FOR PHONE USERS
    btn.Active = true
    Instance.new("UICorner", btn)
    return btn
end

local LockBtn = createBtn("AIM: OFF", UDim2.new(0.05, 0, 0.35, 0), Color3.fromRGB(30, 30, 30))
local ShootBtn = createBtn("TRIGGER: OFF", UDim2.new(0.05, 0, 0.43, 0), Color3.fromRGB(30, 30, 30))

-- // TARGETING LOGIC
local function getBodyPart(char)
    return char:FindFirstChild("HumanoidRootPart") or char:FindFirstChild("UpperTorso") or char:FindFirstChild("Torso")
end

local function getBestTarget()
    local target, shortestDist = nil, math.huge
    local screenCenter = Vector2.new(camera.ViewportSize.X / 2, camera.ViewportSize.Y / 2)

    for _, p in pairs(Players:GetPlayers()) do
        if p ~= player and p.Character and (p.Team ~= player.Team or p.Team == nil) then
            local part = getBodyPart(p.Character)
            local hum = p.Character:FindFirstChild("Humanoid")
            
            if part and hum and hum.Health > 0 then
                local pos, onScreen = camera:WorldToViewportPoint(part.Position)
                if onScreen then
                    local dist = (Vector2.new(pos.X, pos.Y) - screenCenter).Magnitude
                    if dist < FOV_RADIUS and dist < shortestDist then
                        target = p.Character
                        shortestDist = dist
                    end
                end
            end
        end
    end
    return target
end

-- // PC & PHONE INPUT (Taps or Clicks)
local IsActiveInput = false
UserInputService.InputBegan:Connect(function(input, gp)
    if gp then return end
    if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
        IsActiveInput = true
    end
end)
UserInputService.InputEnded:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
        IsActiveInput = false
    end
end)

-- // PC KEYBINDS (Q to toggle Aim, Z to toggle Shoot)
UserInputService.InputBegan:Connect(function(input, gp)
    if gp then return end
    if input.KeyCode == Enum.KeyCode.Q then
        LockBtn.MouseButton1Click:Fire()
    elseif input.KeyCode == Enum.KeyCode.Z then
        ShootBtn.MouseButton1Click:Fire()
    end
end)

-- // MAIN ENGINE
RunService.RenderStepped:Connect(function()
    if AIM_ENABLED then
        if not LOCKED_TARGET or not LOCKED_TARGET:FindFirstChild("Humanoid") or LOCKED_TARGET.Humanoid.Health <= 0 then
            LOCKED_TARGET = getBestTarget()
        end
        
        if LOCKED_TARGET then
            local part = getBodyPart(LOCKED_TARGET)
            if part then
                local targetPos = part.Position + Vector3.new(0, VERTICAL_OFFSET, 0)
                local targetCF = CFrame.lookAt(camera.CFrame.Position, targetPos)
                -- LERP creates the "Sticky/Magnetic" feel for Phones and PC
                camera.CFrame = camera.CFrame:Lerp(targetCF, SMOOTHNESS)
            end
        end
    else
        LOCKED_TARGET = nil
    end

    -- TRIGGER BOT: Shoots while you are touching/holding screen or mouse
    if AUTO_SHOOT and IsActiveInput then
        local tool = player.Character:FindFirstChildOfClass("Tool")
        if tool then tool:Activate() end
    end
end)

-- // BUTTON LOGIC
LockBtn.MouseButton1Click:Connect(function()
    AIM_ENABLED = not AIM_ENABLED
    LockBtn.Text = AIM_ENABLED and "AIM: ON" or "AIM: OFF"
    LockBtn.BackgroundColor3 = AIM_ENABLED and Color3.fromRGB(0, 120, 255) or Color3.fromRGB(30, 30, 30)
end)

ShootBtn.MouseButton1Click:Connect(function()
    AUTO_SHOOT = not AUTO_SHOOT
    ShootBtn.Text = AUTO_SHOOT and "TRIGGER: ON" or "TRIGGER: OFF"
    ShootBtn.BackgroundColor3 = AUTO_SHOOT and Color3.fromRGB(255, 60, 60) or Color3.fromRGB(30, 30, 30)
end)
