local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local CoreGui = game:GetService("CoreGui")

local player = Players.LocalPlayer
local camera = workspace.CurrentCamera

-- // SETTINGS
local AIM_ENABLED = false
local AUTO_SHOOT = false 
local TARGET_PART = "Head"
local CHECK_VISIBILITY = true -- Won't lock through walls if true

-- // UI SETUP
if CoreGui:FindFirstChild("MobileGodSuite") then CoreGui.MobileGodSuite:Destroy() end

local ScreenGui = Instance.new("ScreenGui", CoreGui)
ScreenGui.Name = "MobileGodSuite"

local function createBtn(text, pos, color, sizeX)
    local btn = Instance.new("TextButton", ScreenGui)
    btn.Size = UDim2.new(0, sizeX or 160, 0, 45)
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

-- // MAIN BUTTONS
local MainLock = createBtn("AIMBOT: OFF", UDim2.new(0.05, 0, 0.3, 0), Color3.fromRGB(30, 30, 30))
local ShootBtn = createBtn("AUTO FIRE: OFF", UDim2.new(0.05, 0, 0.37, 0), Color3.fromRGB(30, 30, 30))

-- // OPTION BUTTONS (TARGETING)
local HeadBtn = createBtn("AIM: HEAD", UDim2.new(0.05, 0, 0.47, 0), Color3.fromRGB(150, 50, 50), 100)
local ChestBtn = createBtn("AIM: CHEST", UDim2.new(0.05, 110, 0.47, 0), Color3.fromRGB(50, 50, 50), 100)
local LegBtn = createBtn("AIM: LEGS", UDim2.new(0.05, 220, 0.47, 0), Color3.fromRGB(50, 50, 50), 100)

-- // VISIBILITY CHECK FUNCTION
local function isVisible(targetPart)
    if not CHECK_VISIBILITY then return true end
    local ray = Ray.new(camera.CFrame.Position, (targetPart.Position - camera.CFrame.Position).Unit * 1000)
    local hit = workspace:FindPartOnRayWithIgnoreList(ray, {player.Character, targetPart.Parent})
    return hit == nil
end

-- // TARGETING ENGINE
local function getBestTarget()
    local closestTarget = nil
    local maxDist = 2000

    for _, p in pairs(Players:GetPlayers()) do
        if p ~= player and p.Character and p.Character:FindFirstChild("Humanoid") and p.Character.Humanoid.Health > 0 then
            local part = p.Character:FindFirstChild(TARGET_PART) or p.Character:FindFirstChild("HumanoidRootPart")
            if part then
                local screenPos, onScreen = camera:WorldToViewportPoint(part.Position)
                if onScreen then -- Only targets people you can actually see on screen
                    local dist = (part.Position - player.Character.HumanoidRootPart.Position).Magnitude
                    if dist < maxDist and isVisible(part) then
                        closestTarget = part
                        maxDist = dist
                    end
                end
            end
        end
    end
    return closestTarget
end

-- // RUN LOOP
RunService.RenderStepped:Connect(function()
    if AIM_ENABLED then
        local target = getBestTarget()
        if target then
            camera.CFrame = CFrame.lookAt(camera.CFrame.Position, target.Position)
        end
    end

    if AUTO_SHOOT then
        local tool = player.Character and player.Character:FindFirstChildOfClass("Tool")
        if tool then tool:Activate() end
    end
end)

-- // BUTTON LOGIC
MainLock.MouseButton1Click:Connect(function()
    AIM_ENABLED = not AIM_ENABLED
    MainLock.Text = AIM_ENABLED and "AIMBOT: ON" or "AIMBOT: OFF"
    MainLock.BackgroundColor3 = AIM_ENABLED and Color3.fromRGB(200, 0, 0) or Color3.fromRGB(30, 30, 30)
end)

ShootBtn.MouseButton1Click:Connect(function()
    AUTO_SHOOT = not AUTO_SHOOT
    ShootBtn.Text = AUTO_SHOOT and "AUTO FIRE: ON" or "AUTO FIRE: OFF"
    ShootBtn.BackgroundColor3 = AUTO_SHOOT and Color3.fromRGB(0, 180, 50) or Color3.fromRGB(30, 30, 30)
end)

-- // TARGET SELECTOR LOGIC
local function updateTargetVisuals(activeBtn)
    HeadBtn.BackgroundColor3 = Color3.fromRGB(50, 50, 50)
    ChestBtn.BackgroundColor3 = Color3.fromRGB(50, 50, 50)
    LegBtn.BackgroundColor3 = Color3.fromRGB(50, 50, 50)
    activeBtn.BackgroundColor3 = Color3.fromRGB(150, 50, 50)
end

HeadBtn.MouseButton1Click:Connect(function()
    TARGET_PART = "Head"
    updateTargetVisuals(HeadBtn)
end)

ChestBtn.MouseButton1Click:Connect(function()
    TARGET_PART = "UpperTorso" -- Works for R15 (Chest)
    updateTargetVisuals(ChestBtn)
end)

LegBtn.MouseButton1Click:Connect(function()
    TARGET_PART = "LeftFoot" -- Aiming for lower body
    updateTargetVisuals(LegBtn)
end)
