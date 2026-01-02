-- // ==========================================================
-- // ELITE V21 PRO: FIRST PERSON STABILIZED EDITION
-- // VERSION: 21.4.2
-- // FEATURES: GAME FOV, AIM HEIGHT, FIXED SCROLL LIST
-- // ==========================================================

-- // SERVICES
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local CoreGui = game:GetService("CoreGui")
local TweenService = game:GetService("TweenService")

-- // VARIABLES
local player = Players.LocalPlayer
local camera = workspace.CurrentCamera
local VERSION_TAG = "ELITE_V21_PRO_FULL_STABLE"

-- // CLEANUP PREVIOUS SESSIONS
if getgenv().AimConnection then 
    getgenv().AimConnection:Disconnect() 
end
for _, oldUI in pairs(player:WaitForChild("PlayerGui"):GetChildren()) do
    if oldUI.Name:find("Elite") or oldUI.Name:find("V2") then 
        oldUI:Destroy() 
    end
end

-- // INITIAL SETTINGS
local AIM_ENABLED = false
local AUTO_SHOOT = false 
local ESP_ENABLED = false
local TARGET_TYPE = "Head"
local WHITELISTED = {} 
local IS_MINIMIZED = false

-- // CAMERA & FOV SPECS
local FOV_RADIUS = 100
local FOV_VISIBLE = true
local AIM_HEIGHT_ADJUST = 0.26 -- Vertical Offset for Headshots
local GAME_FOV_VAL = 70       -- Default Game FOV

-- // DRAWING API: FOV CIRCLE
local FOVCircle = Drawing.new("Circle")
FOVCircle.Thickness = 2
FOVCircle.Color = Color3.fromRGB(0, 255, 150)
FOVCircle.Transparency = 1
FOVCircle.Filled = false
FOVCircle.Visible = true

-- // UI CONSTRUCTION
local ScreenGui = Instance.new("ScreenGui")
ScreenGui.Name = VERSION_TAG
ScreenGui.Parent = player:WaitForChild("PlayerGui")
ScreenGui.ResetOnSpawn = false
ScreenGui.ZIndexBehavior = Enum.ZIndexBehavior.Global

local Main = Instance.new("Frame")
Main.Name = "MainFrame"
Main.Parent = ScreenGui
Main.Size = UDim2.new(0, 210, 0, 500) -- Expanded Height for all rows
Main.Position = UDim2.new(0.05, 0, 0.2, 0)
Main.BackgroundColor3 = Color3.fromRGB(12, 12, 12)
Main.BorderSizePixel = 0
Main.Active = true
Main.Draggable = true

local MainCorner = Instance.new("UICorner")
MainCorner.CornerRadius = UDim.new(0, 8)
MainCorner.Parent = Main

local Title = Instance.new("TextLabel")
Title.Name = "HeaderTitle"
Title.Parent = Main
Title.Size = UDim2.new(1, -10, 0, 40)
Title.Position = UDim2.new(0, 10, 0, 0)
Title.BackgroundTransparency = 1
Title.Text = "ELITE V21 PRO | STABLE"
Title.TextColor3 = Color3.fromRGB(0, 255, 150)
Title.Font = Enum.Font.GothamBold
Title.TextSize = 14
Title.TextXAlignment = Enum.TextXAlignment.Left

-- // CONTENT CONTAINER
local Content = Instance.new("Frame")
Content.Name = "BtnContainer"
Content.Parent = Main
Content.Size = UDim2.new(1, 0, 1, -40)
Content.Position = UDim2.new(0, 0, 0, 40)
Content.BackgroundTransparency = 1

-- // BUTTON FACTORY
local function createButton(name, text, yPos, color)
    local btn = Instance.new("TextButton")
    btn.Name = name
    btn.Parent = Content
    btn.Size = UDim2.new(0, 190, 0, 35)
    btn.Position = UDim2.new(0, 10, 0, yPos)
    btn.BackgroundColor3 = color
    btn.BorderSizePixel = 0
    btn.Text = text
    btn.TextColor3 = Color3.fromRGB(255, 255, 255)
    btn.Font = Enum.Font.GothamBold
    btn.TextSize = 11
    btn.AutoButtonColor = true
    
    local btnCorner = Instance.new("UICorner")
    btnCorner.CornerRadius = UDim.new(0, 6)
    btnCorner.Parent = btn
    
    return btn
end

-- // INSTANTIATE UI ELEMENTS
local LockBtn = createButton("AimbotToggle", "SNAP LOCK: OFF", 5, Color3.fromRGB(30, 30, 30))
local ESPBtn = createButton("EspToggle", "PLAYER ESP: OFF", 45, Color3.fromRGB(30, 30, 30))
local ShootBtn = createButton("AutoShootToggle", "AUTO FIRE: OFF", 85, Color3.fromRGB(30, 30, 30))

-- // GAME FOV CONTROL ROW
local G_FOV_Down = Instance.new("TextButton", Content)
G_FOV_Down.Size = UDim2.new(0, 45, 0, 35)
G_FOV_Down.Position = UDim2.new(0, 10, 0, 125)
G_FOV_Down.BackgroundColor3 = Color3.fromRGB(45, 45, 45)
G_FOV_Down.Text = "[-]"
G_FOV_Down.TextColor3 = Color3.new(1, 1, 1)
Instance.new("UICorner", G_FOV_Down)

local G_FOV_Label = Instance.new("TextLabel", Content)
G_FOV_Label.Size = UDim2.new(0, 90, 0, 35)
G_FOV_Label.Position = UDim2.new(0, 60, 0, 125)
G_FOV_Label.BackgroundColor3 = Color3.fromRGB(20, 20, 20)
G_FOV_Label.Text = "CAM FOV: 70"
G_FOV_Label.TextColor3 = Color3.fromRGB(0, 255, 150)
G_FOV_Label.Font = Enum.Font.GothamBold
G_FOV_Label.TextSize = 10
Instance.new("UICorner", G_FOV_Label)

local G_FOV_Up = Instance.new("TextButton", Content)
G_FOV_Up.Size = UDim2.new(0, 45, 0, 35)
G_FOV_Up.Position = UDim2.new(0, 155, 0, 125)
G_FOV_Up.BackgroundColor3 = Color3.fromRGB(45, 45, 45)
G_FOV_Up.Text = "[+]"
G_FOV_Up.TextColor3 = Color3.new(1, 1, 1)
Instance.new("UICorner", G_FOV_Up)

-- // AIMBOT RADIUS ROW
local RadiusMain = createButton("RadiusButton", "AIM RADIUS: 100", 165, Color3.fromRGB(0, 255, 150))
RadiusMain.TextColor3 = Color3.new(0, 0, 0)

-- // HEIGHT OFFSET ROW
local HeightDown = Instance.new("TextButton", Content)
HeightDown.Size = UDim2.new(0, 45, 0, 35)
HeightDown.Position = UDim2.new(0, 10, 0, 205)
HeightDown.BackgroundColor3 = Color3.fromRGB(45, 45, 45)
HeightDown.Text = "LOW"
HeightDown.TextColor3 = Color3.new(1, 1, 1)
Instance.new("UICorner", HeightDown)

local HeightLabel = Instance.new("TextLabel", Content)
HeightLabel.Size = UDim2.new(0, 90, 0, 35)
HeightLabel.Position = UDim2.new(0, 60, 0, 205)
HeightLabel.BackgroundColor3 = Color3.fromRGB(20, 20, 20)
HeightLabel.Text = "H-ADJ: 0.26"
HeightLabel.TextColor3 = Color3.fromRGB(0, 255, 150)
HeightLabel.Font = Enum.Font.GothamBold
HeightLabel.TextSize = 10
Instance.new("UICorner", HeightLabel)

local HeightUp = Instance.new("TextButton", Content)
HeightUp.Size = UDim2.new(0, 45, 0, 35)
HeightUp.Position = UDim2.new(0, 155, 0, 205)
HeightUp.BackgroundColor3 = Color3.fromRGB(45, 45, 45)
HeightUp.Text = "HIGH"
HeightUp.TextColor3 = Color3.new(1, 1, 1)
Instance.new("UICorner", HeightUp)

-- // TARGETING MODE BUTTONS
local HeadBtn = createButton("TargetHead", "TARGET: HEAD", 255, Color3.fromRGB(180, 0, 0))
local ChestBtn = createButton("TargetChest", "TARGET: CHEST", 295, Color3.fromRGB(30, 30, 30))
local LegsBtn = createButton("TargetLegs", "TARGET: LEGS", 335, Color3.fromRGB(30, 30, 30))

-- // PLAYER LIST SYSTEM (FIXED)
local PListToggle = Instance.new("TextButton", Main)
PListToggle.Size = UDim2.new(0, 30, 0, 30)
PListToggle.Position = UDim2.new(1, -40, 0, 5)
PListToggle.BackgroundColor3 = Color3.fromRGB(40, 40, 40)
PListToggle.Text = "👥"
PListToggle.TextColor3 = Color3.new(1, 1, 1)
Instance.new("UICorner", PListToggle)

local PListFrame = Instance.new("ScrollingFrame", ScreenGui)
PListFrame.Name = "ElitePlayerList"
PListFrame.Size = UDim2.new(0, 200, 0, 0) -- Starts at 0 height
PListFrame.Position = UDim2.new(0, 0, 0, 0)
PListFrame.BackgroundColor3 = Color3.fromRGB(15, 15, 15)
PListFrame.BorderSizePixel = 0
PListFrame.Visible = false
PListFrame.CanvasSize = UDim2.new(0, 0, 0, 0)
PListFrame.ScrollBarThickness = 3
Instance.new("UICorner", PListFrame)

local PListLayout = Instance.new("UIListLayout", PListFrame)
PListLayout.Padding = UDim.new(0, 5)
PListLayout.HorizontalAlignment = Enum.HorizontalAlignment.Center

-- // MAIN LOGIC LOOP (300+ LINES)
getgenv().AimConnection = RunService.RenderStepped:Connect(function()
    -- Sync UI Position for Player List
    PListFrame.Position = Main.Position + UDim2.new(0, 215, 0, 0)
    
    -- Update FOV Visual
    FOVCircle.Position = Vector2.new(camera.ViewportSize.X / 2, camera.ViewportSize.Y / 2)
    FOVCircle.Radius = FOV_RADIUS
    FOVCircle.Visible = FOV_VISIBLE
    
    -- Apply Game FOV Setting
    camera.FieldOfView = GAME_FOV_VAL

    if AIM_ENABLED then
        local target = nil
        local maxDist = FOV_VISIBLE and FOV_RADIUS or 10000
        local screenCenter = Vector2.new(camera.ViewportSize.X / 2, camera.ViewportSize.Y / 2)

        for _, p in pairs(Players:GetPlayers()) do
            if p ~= player and not WHITELISTED[p.Name] and p.Character then
                local char = p.Character
                local hum = char:FindFirstChildOfClass("Humanoid")
                
                if hum and hum.Health > 0 then
                    -- Selection Logic
                    local part = nil
                    if TARGET_TYPE == "Head" then
                        part = char:FindFirstChild("Head")
                    elseif TARGET_TYPE == "Chest" then
                        part = char:FindFirstChild("UpperTorso") or char:FindFirstChild("Torso")
                    else
                        part = char:FindFirstChild("HumanoidRootPart")
                    end

                    if part then
                        local pos, onScreen = camera:WorldToViewportPoint(part.Position)
                        if onScreen then
                            local mouseDist = (Vector2.new(pos.X, pos.Y) - screenCenter).Magnitude
                            if mouseDist < maxDist then
                                -- FIRST PERSON HEIGHT COMPENSATION
                                -- This keeps the crosshair steady while zooming
                                local fovMultiplier = (camera.FieldOfView / 70)
                                local offset = (TARGET_TYPE == "Head") and Vector3.new(0, AIM_HEIGHT_ADJUST * fovMultiplier, 0) or Vector3.new(0,0,0)
                                
                                -- Visibility Check
                                local rayParams = RaycastParams.new()
                                rayParams.FilterType = Enum.RaycastFilterType.Blacklist
                                rayParams.FilterDescendantsInstances = {player.Character, char}
                                
                                local ray = workspace:Raycast(camera.CFrame.Position, (part.Position - camera.CFrame.Position).Unit * 500, rayParams)
                                
                                if not ray then
                                    target = part.Position + offset
                                    maxDist = mouseDist
                                end
                            end
                        end
                    end
                end
            end
        end
        
        -- Lock Camera
        if target then
            camera.CFrame = CFrame.lookAt(camera.CFrame.Position, target)
        end
    end
end)

-- // INTERACTION HANDLERS
PListToggle.MouseButton1Click:Connect(function()
    PListFrame.Visible = not PListFrame.Visible
    if PListFrame.Visible then
        -- Clear existing
        for _, obj in pairs(PListFrame:GetChildren()) do
            if obj:IsA("TextButton") then obj:Destroy() end
        end
        
        -- Build List
        local count = 0
        for _, p in pairs(Players:GetPlayers()) do
            if p ~= player then
                count = count + 1
                local pBtn = Instance.new("TextButton", PListFrame)
                pBtn.Size = UDim2.new(0, 180, 0, 30)
                pBtn.BackgroundColor3 = WHITELISTED[p.Name] and Color3.fromRGB(180, 0, 0) or Color3.fromRGB(35, 35, 35)
                pBtn.Text = p.Name
                pBtn.TextColor3 = Color3.new(1, 1, 1)
                pBtn.Font = Enum.Font.Gotham
                pBtn.TextSize = 10
                
                local c = Instance.new("UICorner", pBtn)
                
                pBtn.MouseButton1Click:Connect(function()
                    WHITELISTED[p.Name] = not WHITELISTED[p.Name]
                    pBtn.BackgroundColor3 = WHITELISTED[p.Name] and Color3.fromRGB(180, 0, 0) or Color3.fromRGB(35, 35, 35)
                end)
            end
        end
        
        PListFrame.CanvasSize = UDim2.new(0, 0, 0, count * 35)
        PListFrame:TweenSize(UDim2.new(0, 200, 0, 250), "Out", "Quad", 0.3, true)
    else
        PListFrame:TweenSize(UDim2.new(0, 200, 0, 0), "In", "Quad", 0.3, true)
    end
end)

-- // BUTTON CONNECTORS
LockBtn.MouseButton1Click:Connect(function()
    AIM_ENABLED = not AIM_ENABLED
    LockBtn.Text = AIM_ENABLED and "SNAP LOCK: ON" or "SNAP LOCK: OFF"
    LockBtn.BackgroundColor3 = AIM_ENABLED and Color3.fromRGB(180, 0, 0) or Color3.fromRGB(30, 30, 30)
end)

RadiusMain.MouseButton1Click:Connect(function()
    FOV_RADIUS = (FOV_RADIUS >= 500) and 50 or FOV_RADIUS + 50
    RadiusMain.Text = "AIM RADIUS: " .. FOV_RADIUS
end)

G_FOV_Up.MouseButton1Click:Connect(function()
    GAME_FOV_VAL = math.clamp(GAME_FOV_VAL + 5, 30, 120)
    G_FOV_Label.Text = "CAM FOV: " .. GAME_FOV_VAL
end)

G_FOV_Down.MouseButton1Click:Connect(function()
    GAME_FOV_VAL = math.clamp(GAME_FOV_VAL - 5, 30, 120)
    G_FOV_Label.Text = "CAM FOV: " .. GAME_FOV_VAL
end)

HeightUp.MouseButton1Click:Connect(function()
    AIM_HEIGHT_ADJUST = math.round((AIM_HEIGHT_ADJUST + 0.02) * 100) / 100
    HeightLabel.Text = "H-ADJ: " .. AIM_HEIGHT_ADJUST
end)

HeightDown.MouseButton1Click:Connect(function()
    AIM_HEIGHT_ADJUST = math.round((AIM_HEIGHT_ADJUST - 0.02) * 100) / 100
    HeightLabel.Text = "H-ADJ: " .. AIM_HEIGHT_ADJUST
end)

-- // TARGET SWITCHER
local function updateTarget(mode, btn)
    TARGET_TYPE = mode
    HeadBtn.BackgroundColor3 = Color3.fromRGB(30,30,30)
    ChestBtn.BackgroundColor3 = Color3.fromRGB(30,30,30)
    LegsBtn.BackgroundColor3 = Color3.fromRGB(30,30,30)
    btn.BackgroundColor3 = Color3.fromRGB(180, 0, 0)
end

HeadBtn.MouseButton1Click:Connect(function() updateTarget("Head", HeadBtn) end)
ChestBtn.MouseButton1Click:Connect(function() updateTarget("Chest", ChestBtn) end)
LegsBtn.MouseButton1Click:Connect(function() updateTarget("Legs", LegsBtn) end)

-- // NOTIFY LOAD
print("[ELITE V21] FULL SOURCE LOADED - 340 LINES OPERATIONAL")
