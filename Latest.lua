local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local player = Players.LocalPlayer

-- // SETTINGS
local AIM_ENABLED = false
local AUTO_SHOOT = false 
local TARGET_PART = "Head"

-- // UI SETUP
local function BuildUI()
    -- Destroy old UI if it exists
    local oldUI = player:WaitForChild("PlayerGui"):FindFirstChild("MobileGodSuiteV3")
    if oldUI then oldUI:Destroy() end

    local ScreenGui = Instance.new("ScreenGui")
    ScreenGui.Name = "MobileGodSuiteV3"
    ScreenGui.Parent = player:WaitForChild("PlayerGui")
    ScreenGui.ZIndexBehavior = Enum.ZIndexBehavior.Global
    ScreenGui.DisplayOrder = 99999 -- Force to front
    ScreenGui.ResetOnSpawn = false

    local function createBtn(text, pos, color, sizeX)
        local btn = Instance.new("TextButton")
        btn.Parent = ScreenGui
        btn.Size = UDim2.new(0, sizeX or 150, 0, 40)
        btn.Position = pos
        btn.BackgroundColor3 = color
        btn.Text = text
        btn.TextColor3 = Color3.new(1, 1, 1)
        btn.Font = Enum.Font.GothamBold
        btn.TextSize = 14
        btn.BorderSizePixel = 2
        btn.BorderColor3 = Color3.new(1,1,1)
        btn.ZIndex = 10
        
        Instance.new("UICorner", btn).CornerRadius = UDim.new(0, 6)
        return btn
    end

    -- MAIN TOGGLES
    local MainLock = createBtn("AIM: OFF", UDim2.new(0.05, 0, 0.3, 0), Color3.fromRGB(40, 40, 40))
    local ShootBtn = createBtn("FIRE: OFF", UDim2.new(0.05, 0, 0.36, 0), Color3.fromRGB(40, 40, 40))

    -- OPTIONS BUTTONS (Smaller, underneath)
    local HeadBtn = createBtn("HEAD", UDim2.new(0.05, 0, 0.43, 0), Color3.fromRGB(180, 50, 50), 45)
    local ChestBtn = createBtn("CHEST", UDim2.new(0.05, 50, 0.43, 0), Color3.fromRGB(40, 40, 40), 50)
    local LegBtn = createBtn("LEGS", UDim2.new(0.05, 105, 0.43, 0), Color3.fromRGB(40, 40, 40), 45)

    -- LOGIC FOR AIMING
    RunService.RenderStepped:Connect(function()
        if AIM_ENABLED then
            local target = nil
            local dist = 1000
            for _, p in pairs(Players:GetPlayers()) do
                if p ~= player and p.Character and p.Character:FindFirstChild(TARGET_PART) then
                    local hum = p.Character:FindFirstChild("Humanoid")
                    if hum and hum.Health > 0 then
                        local d = (p.Character[TARGET_PART].Position - player.Character.HumanoidRootPart.Position).Magnitude
                        if d < dist then
                            target = p.Character[TARGET_PART]
                            dist = d
                        end
                    end
                end
            end
            if target then
                workspace.CurrentCamera.CFrame = CFrame.lookAt(workspace.CurrentCamera.CFrame.Position, target.Position)
            end
        end
        if AUTO_SHOOT then
            local tool = player.Character and player.Character:FindFirstChildOfClass("Tool")
            if tool then tool:Activate() end
        end
    end)

    -- BUTTON CLICKS
    MainLock.MouseButton1Click:Connect(function()
        AIM_ENABLED = not AIM_ENABLED
        MainLock.Text = AIM_ENABLED and "AIM: ON" or "AIM: OFF"
        MainLock.BackgroundColor3 = AIM_ENABLED and Color3.fromRGB(255, 0, 0) or Color3.fromRGB(40, 40, 40)
    end)

    ShootBtn.MouseButton1Click:Connect(function()
        AUTO_SHOOT = not AUTO_SHOOT
        ShootBtn.Text = AUTO_SHOOT and "FIRE: ON" or "FIRE: OFF"
        ShootBtn.BackgroundColor3 = AUTO_SHOOT and Color3.fromRGB(0, 255, 100) or Color3.fromRGB(40, 40, 40)
    end)

    local function clearOptions()
        HeadBtn.BackgroundColor3 = Color3.fromRGB(40,40,40)
        ChestBtn.BackgroundColor3 = Color3.fromRGB(40,40,40)
        LegBtn.BackgroundColor3 = Color3.fromRGB(40,40,40)
    end

    HeadBtn.MouseButton1Click:Connect(function() TARGET_PART = "Head" clearOptions() HeadBtn.BackgroundColor3 = Color3.fromRGB(180,50,50) end)
    ChestBtn.MouseButton1Click:Connect(function() TARGET_PART = "UpperTorso" clearOptions() ChestBtn.BackgroundColor3 = Color3.fromRGB(180,50,50) end)
    LegBtn.MouseButton1Click:Connect(function() TARGET_PART = "LeftFoot" clearOptions() LegBtn.BackgroundColor3 = Color3.fromRGB(180,50,50) end)
end

-- Run the setup
task.spawn(BuildUI)
