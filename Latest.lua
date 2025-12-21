local Players = game:GetService("Players")
local RunService = game:GetService("RunService")

local player = Players.LocalPlayer
local camera = workspace.CurrentCamera

-- // SETTINGS
local AIM_ENABLED = false
local FREE_AIM_ENABLED = false
local AUTO_SHOOT = false
local LOCKED_TARGET = nil
local VERTICAL_OFFSET = 2.6

-- // FORCE GUI TO APPEAR
local function createForceUI()
    -- We try to put it in PlayerGui, if that fails, we try the executor's hidden storage
    local targetFolder = player:FindFirstChild("PlayerGui") or game:GetService("CoreGui")
    
    if targetFolder:FindFirstChild("MobileMegaSuite") then 
        targetFolder.MobileMegaSuite:Destroy() 
    end
    
    local ScreenGui = Instance.new("ScreenGui")
    ScreenGui.Name = "MobileMegaSuite"
    ScreenGui.Parent = targetFolder
    ScreenGui.DisplayOrder = 99999 -- Forces it above everything else
    ScreenGui.IgnoreGuiInset = true
    ScreenGui.ResetOnSpawn = false

    local function createBtn(text, pos, color)
        local btn = Instance.new("TextButton", ScreenGui)
        btn.Size = UDim2.new(0, 150, 0, 45)
        btn.Position = pos
        btn.BackgroundColor3 = color
        btn.Text = text
        btn.TextColor3 = Color3.new(1, 1, 1)
        btn.Font = Enum.Font.SourceSansBold
        btn.TextSize = 16
        btn.ZIndex = 10
        btn.Draggable = true -- Drag them to the left side after they show up
        Instance.new("UICorner", btn)
        return btn
    end

    -- Creating buttons in the CENTER so they are impossible to miss
    local LockBtn = createBtn("LOCK: OFF", UDim2.new(0.4, 0, 0.4, 0), Color3.fromRGB(40, 40, 40))
    local FreeBtn = createBtn("FREE AIM: OFF", UDim2.new(0.4, 0, 0.48, 0), Color3.fromRGB(40, 40, 40))
    local ShootBtn = createBtn("AUTO SHOOT: OFF", UDim2.new(0.4, 0, 0.56, 0), Color3.fromRGB(40, 40, 40))

    LockBtn.MouseButton1Click:Connect(function()
        AIM_ENABLED = not AIM_ENABLED
        LockBtn.Text = AIM_ENABLED and "LOCK: ON" or "LOCK: OFF"
        LockBtn.BackgroundColor3 = AIM_ENABLED and Color3.fromRGB(0, 120, 255) or Color3.fromRGB(40, 40, 40)
    end)

    FreeBtn.MouseButton1Click:Connect(function()
        FREE_AIM_ENABLED = not FREE_AIM_ENABLED
        FreeBtn.Text = FREE_AIM_ENABLED and "FREE AIM: ON" or "FREE AIM: OFF"
        FreeBtn.BackgroundColor3 = FREE_AIM_ENABLED and Color3.fromRGB(200, 150, 0) or Color3.fromRGB(40, 40, 40)
    end)

    ShootBtn.MouseButton1Click:Connect(function()
        AUTO_SHOOT = not AUTO_SHOOT
        ShootBtn.Text = AUTO_SHOOT and "SHOOTER: ON" or "AUTO SHOOT: OFF"
        ShootBtn.BackgroundColor3 = AUTO_SHOOT and Color3.fromRGB(200, 0, 50) or Color3.fromRGB(40, 40, 40)
    end)
end

createForceUI()

-- // LOGIC ENGINE (Remains the same for performance)
local function getClosest()
    local target, dist = nil, math.huge
    local center = Vector2.new(camera.ViewportSize.X/2, camera.ViewportSize.Y/2)
    for _, p in pairs(Players:GetPlayers()) do
        if p ~= player and p.Character and p.Character:FindFirstChild("HumanoidRootPart") then
            if p.Character.Humanoid.Health > 0 then
                local pos, vis = camera:WorldToViewportPoint(p.Character.HumanoidRootPart.Position + Vector3.new(0, VERTICAL_OFFSET, 0))
                if vis then
                    local m = (Vector2.new(pos.X, pos.Y) - center).Magnitude
                    if m < dist then target, dist = p.Character, m end
                end
            end
        end
    end
    return target
end

RunService.RenderStepped:Connect(function()
    if player.Character and player.Character:FindFirstChild("Humanoid") then
        player.Character.Humanoid.AutoRotate = not FREE_AIM_ENABLED
    end
    if AIM_ENABLED then
        if not LOCKED_TARGET or not LOCKED_TARGET:FindFirstChild("Humanoid") or LOCKED_TARGET.Humanoid.Health <= 0 then
            LOCKED_TARGET = getClosest()
        end
        if LOCKED_TARGET and LOCKED_TARGET:FindFirstChild("HumanoidRootPart") then
            camera.CFrame = CFrame.lookAt(camera.CFrame.Position, LOCKED_TARGET.HumanoidRootPart.Position + Vector3.new(0, VERTICAL_OFFSET, 0))
            if AUTO_SHOOT then
                local tool = player.Character:FindFirstChildOfClass("Tool")
                if tool then tool:Activate() end
            end
        end
    else
        LOCKED_TARGET = nil
    end
end)
