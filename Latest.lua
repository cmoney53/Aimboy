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

-- // TUNING
local VERTICAL_OFFSET = 0 -- 0 = Stomach/Chest (Center of Body)
local SMOOTHNESS = 0.25   -- 1 is instant lock, 0.1 is very slow/legit
local MAX_DISTANCE = 1000 -- Max studs away to target someone

-- // UI SETUP
if CoreGui:FindFirstChild("UniversalAimbot") then CoreGui.UniversalAimbot:Destroy() end

local ScreenGui = Instance.new("ScreenGui", CoreGui)
ScreenGui.Name = "UniversalAimbot"

local function createBtn(text, pos, color)
    local btn = Instance.new("TextButton", ScreenGui)
    btn.Size = UDim2.new(0, 150, 0, 45)
    btn.Position = pos
    btn.BackgroundColor3 = color
    btn.Text = text
    btn.TextColor3 = Color3.new(1, 1, 1)
    btn.Font = Enum.Font.GothamBold
    btn.TextSize = 13
    btn.Draggable = true
    btn.Active = true
    Instance.new("UICorner", btn)
    return btn
end

local LockBtn = createBtn("AIMBOT: OFF", UDim2.new(0.05, 0, 0.4, 0), Color3.fromRGB(30, 30, 30))
local ShootBtn = createBtn("TRIGGER: OFF", UDim2.new(0.05, 0, 0.48, 0), Color3.fromRGB(30, 30, 30))

-- // CLOSEST PLAYER LOGIC
local function getClosestPlayer()
    local target, shortestDistance = nil, MAX_DISTANCE

    if not player.Character or not player.Character:FindFirstChild("HumanoidRootPart") then return nil end
    local myPos = player.Character.HumanoidRootPart.Position

    for _, p in pairs(Players:GetPlayers()) do
        if p ~= player and p.Character then
            local root = p.Character:FindFirstChild("HumanoidRootPart")
            local hum = p.Character:FindFirstChild("Humanoid")
            
            -- Check if player is alive and on a different team
            if root and hum and hum.Health > 0 and (p.Team ~= player.Team or p.Team == nil) then
                local dist = (root.Position - myPos).Magnitude
                
                if dist < shortestDistance then
                    -- Final check: Ensure they are actually visible on screen before locking
                    local _, onScreen = camera:WorldToViewportPoint(root.Position)
                    if onScreen then
                        target = p.Character
                        shortestDistance = dist
                    end
                end
            end
        end
    end
    return target
end

-- // INPUT (PC + PHONE)
local IsPressed = false
UserInputService.InputBegan:Connect(function(input, gp)
    if gp then return end
    if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
        IsPressed = true
    end
end)
UserInputService.InputEnded:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
        IsPressed = false
    end
end)

-- // MAIN LOOP
RunService.RenderStepped:Connect(function()
    if AIM_ENABLED then
        -- Always check for the closest person every frame
        LOCKED_TARGET = getClosestPlayer()
        
        if LOCKED_TARGET and LOCKED_TARGET:FindFirstChild("HumanoidRootPart") then
            local targetPos = LOCKED_TARGET.HumanoidRootPart.Position + Vector3.new(0, VERTICAL_OFFSET, 0)
            local targetCF = CFrame.lookAt(camera.CFrame.Position, targetPos)
            
            -- Smoothing for Phone/PC
            camera.CFrame = camera.CFrame:Lerp(targetCF, SMOOTHNESS)
        end
    else
        LOCKED_TARGET = nil
    end

    -- Trigger Bot
    if AUTO_SHOOT and IsPressed then
        local tool = player.Character:FindFirstChildOfClass("Tool")
        if tool then tool:Activate() end
    end
end)

-- // BUTTON CLICKS
LockBtn.MouseButton1Click:Connect(function()
    AIM_ENABLED = not AIM_ENABLED
    LockBtn.Text = AIM_ENABLED and "AIMBOT: ACTIVE" or "AIMBOT: OFF"
    LockBtn.BackgroundColor3 = AIM_ENABLED and Color3.fromRGB(0, 120, 255) or Color3.fromRGB(30, 30, 30)
end)

ShootBtn.MouseButton1Click:Connect(function()
    AUTO_SHOOT = not AUTO_SHOOT
    ShootBtn.Text = AUTO_SHOOT and "TRIGGER: ON" or "TRIGGER: OFF"
    ShootBtn.BackgroundColor3 = AUTO_SHOOT and Color3.fromRGB(255, 60, 60) or Color3.fromRGB(30, 30, 30)
end)
