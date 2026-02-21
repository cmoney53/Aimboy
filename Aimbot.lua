-- // FORCE CLEAR ALL PREVIOUS VERSIONS
local VERSION_TAG = "ELITE_Cash_PRO_STABLE_FULL"
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local player = Players.LocalPlayer
local camera = workspace.CurrentCamera

-- Cleanup
if getgenv().AimConnection then getgenv().AimConnection:Disconnect() end
for _, oldUI in pairs(player:WaitForChild("PlayerGui"):GetChildren()) do
    if oldUI.Name:find("Elite") or oldUI.Name:find("AIMBOT") or oldUI.Name:find("V2") then
        oldUI:Destroy()
    end
end

-- // SETTINGS
local AIM_ENABLED = false
local AUTO_SHOOT = false 
local ESP_ENABLED = false
local TARGET_TYPE = "Head"
local WHITELISTED = {} 
local IS_MINIMIZED = false

-- // FOV & CAMERA SETTINGS
local FOV_RADIUS = 100
local FOV_VISIBLE = false
local AIM_HEIGHT_ADJUST = 0.26
local GAME_FOV_VAL = 70 -- Default Roblox FOV
local FOVCircle = Drawing.new("Circle")
FOVCircle.Thickness = 1.5
FOVCircle.Color = Color3.fromRGB(0, 255, 150)
FOVCircle.Transparency = 1
FOVCircle.Filled = false

-- // UI SETUP
local ScreenGui = Instance.new("ScreenGui", player:WaitForChild("PlayerGui"))
ScreenGui.Name = VERSION_TAG
ScreenGui.ResetOnSpawn = false
ScreenGui.ZIndexBehavior = Enum.ZIndexBehavior.Global

local Main = Instance.new("Frame", ScreenGui)
Main.Size = UDim2.new(0, 200, 0, 490)
Main.Position = UDim2.new(0.05, 0, 0.3, 0)
Main.BackgroundColor3 = Color3.fromRGB(15, 15, 15)
Main.Active = true
Main.Draggable = true
Instance.new("UICorner", Main)

local Title = Instance.new("TextLabel", Main)
Title.Size = UDim2.new(1, -65, 0, 35)
Title.Text = "  Cash V2 | PLRS: " .. #Players:GetPlayers()
Title.TextColor3 = Color3.fromRGB(0, 255, 150)
Title.Font = Enum.Font.GothamBold
Title.TextSize = 13
Title.BackgroundTransparency = 1
Title.TextXAlignment = Enum.TextXAlignment.Left

spawn(function()
    while wait(1) do 
        Title.Text = "  Cash | PLRS: " .. #Players:GetPlayers() 
    end
end)

local Content = Instance.new("Frame", Main)
Content.Size = UDim2.new(1, 0, 1, -35)
Content.Position = UDim2.new(0, 0, 0, 35)
Content.BackgroundTransparency = 1

local function makeBtn(txt, y, color)
    local b = Instance.new("TextButton", Content)
    b.Size = UDim2.new(0, 180, 0, 35)
    b.Position = UDim2.new(0, 10, 0, y)
    b.BackgroundColor3 = color
    b.Text = txt
    b.TextColor3 = Color3.new(1, 1, 1)
    b.Font = Enum.Font.GothamBold
    b.TextSize = 10
    b.ZIndex = 5
    Instance.new("UICorner", b)
    return b
end

-- // CORE BUTTONS
local LockBtn = makeBtn("SNAP LOCK: OFF", 5, Color3.fromRGB(35, 35, 35))
local ESPBtn = makeBtn("ALIVE ESP: OFF", 45, Color3.fromRGB(35, 35, 35))
local ShootBtn = makeBtn("AUTO FIRE: OFF", 85, Color3.fromRGB(35, 35, 35))

-- // GAME FOV ROW
local GameFOVDown = Instance.new("TextButton", Content)
GameFOVDown.Size = UDim2.new(0, 40, 0, 35)
GameFOVDown.Position = UDim2.new(0, 10, 0, 125)
GameFOVDown.BackgroundColor3 = Color3.fromRGB(60, 60, 60)
GameFOVDown.Text = "[-]"
GameFOVDown.TextColor3 = Color3.new(1, 1, 1)
Instance.new("UICorner", GameFOVDown)

local GameFOVMain = Instance.new("TextLabel", Content)
GameFOVMain.Size = UDim2.new(0, 95, 0, 35)
GameFOVMain.Position = UDim2.new(0, 53, 0, 125)
GameFOVMain.BackgroundColor3 = Color3.fromRGB(20, 20, 20)
GameFOVMain.Text = "GAME FOV: " .. GAME_FOV_VAL
GameFOVMain.TextColor3 = Color3.fromRGB(0, 255, 150)
GameFOVMain.Font = Enum.Font.GothamBold
GameFOVMain.TextSize = 9
Instance.new("UICorner", GameFOVMain)

local GameFOVUp = Instance.new("TextButton", Content)
GameFOVUp.Size = UDim2.new(0, 40, 0, 35)
GameFOVUp.Position = UDim2.new(0, 150, 0, 125)
GameFOVUp.BackgroundColor3 = Color3.fromRGB(60, 60, 60)
GameFOVUp.Text = "[+]"
GameFOVUp.TextColor3 = Color3.new(1, 1, 1)
Instance.new("UICorner", GameFOVUp)

-- // AIM FOV ROW
local FOVDown = Instance.new("TextButton", Content)
FOVDown.Size = UDim2.new(0, 40, 0, 35)
FOVDown.Position = UDim2.new(0, 10, 0, 165)
FOVDown.BackgroundColor3 = Color3.fromRGB(45, 45, 45)
FOVDown.Text = "-"
FOVDown.TextColor3 = Color3.new(1, 1, 1)
Instance.new("UICorner", FOVDown)

local FOVMain = makeBtn("AIM FOV: " .. FOV_RADIUS, 165, Color3.fromRGB(0, 255, 150))
FOVMain.Size = UDim2.new(0, 95, 0, 35)
FOVMain.Position = UDim2.new(0, 53, 0, 165)
FOVMain.TextColor3 = Color3.new(0, 0, 0)
FOVMain.TextSize = 9

local FOVUp = Instance.new("TextButton", Content)
FOVUp.Size = UDim2.new(0, 40, 0, 35)
FOVUp.Position = UDim2.new(0, 150, 0, 165)
FOVUp.BackgroundColor3 = Color3.fromRGB(45, 45, 45)
FOVUp.Text = "+"
FOVUp.TextColor3 = Color3.new(1, 1, 1)
Instance.new("UICorner", FOVUp)

-- // HEIGHT ROW
local HeightDown = Instance.new("TextButton", Content)
HeightDown.Size = UDim2.new(0, 40, 0, 35)
HeightDown.Position = UDim2.new(0, 10, 0, 205)
HeightDown.BackgroundColor3 = Color3.fromRGB(45, 45, 45)
HeightDown.Text = "LOW"
HeightDown.TextColor3 = Color3.new(1, 1, 1)
Instance.new("UICorner", HeightDown)

local HeightMain = Instance.new("TextLabel", Content)
HeightMain.Size = UDim2.new(0, 95, 0, 35)
HeightMain.Position = UDim2.new(0, 53, 0, 205)
HeightMain.BackgroundColor3 = Color3.fromRGB(30, 30, 30)
HeightMain.Text = "H-ADJ: " .. AIM_HEIGHT_ADJUST
HeightMain.TextColor3 = Color3.fromRGB(0, 255, 150)
HeightMain.Font = Enum.Font.GothamBold
HeightMain.TextSize = 9
Instance.new("UICorner", HeightMain)

local HeightUp = Instance.new("TextButton", Content)
HeightUp.Size = UDim2.new(0, 40, 0, 35)
HeightUp.Position = UDim2.new(0, 150, 0, 205)
HeightUp.BackgroundColor3 = Color3.fromRGB(45, 45, 45)
HeightUp.Text = "HIGH"
HeightUp.TextColor3 = Color3.new(1, 1, 1)
Instance.new("UICorner", HeightUp)

-- // TARGET BUTTONS
local HeadBtn = makeBtn("TARGET: FOREHEAD", 255, Color3.fromRGB(180, 0, 0))
local ChestBtn = makeBtn("TARGET: CHEST", 295, Color3.fromRGB(35, 35, 35))
local LegBtn = makeBtn("TARGET: LEGS", 335, Color3.fromRGB(35, 35, 35))

local function createTopBtn(text, xPos)
    local b = Instance.new("TextButton", Main)
    b.Size = UDim2.new(0, 25, 0, 25)
    b.Position = UDim2.new(1, xPos, 0, 5)
    b.BackgroundColor3 = Color3.fromRGB(45, 45, 45)
    b.Text = text
    b.TextColor3 = Color3.new(1, 1, 1)
    b.ZIndex = 6
    Instance.new("UICorner", b)
    return b
end

local MinBtn = createTopBtn("-", -30)
local PListToggle = createTopBtn("👥", -60)

-- // PLAYER LIST SETUP
local PListFrame = Instance.new("ScrollingFrame", ScreenGui)
PListFrame.Size = UDim2.new(0, 200, 0, 0) -- Starts closed
PListFrame.Visible = false
PListFrame.BackgroundColor3 = Color3.fromRGB(25, 25, 25)
PListFrame.BorderSizePixel = 0
PListFrame.ZIndex = 20
PListFrame.ScrollBarThickness = 4
PListFrame.CanvasSize = UDim2.new(0, 0, 0, 0)

local UIList = Instance.new("UIListLayout", PListFrame)
UIList.Padding = UDim.new(0, 2)
UIList.SortOrder = Enum.SortOrder.LayoutOrder
Instance.new("UICorner", PListFrame)

-- // PLAYER LIST REFRESH FUNCTION
local function RefreshPlayerList()
    for _, c in pairs(PListFrame:GetChildren()) do 
        if c:IsA("TextButton") then c:Destroy() end 
    end
    
    local pCount = 0
    for _, p in pairs(Players:GetPlayers()) do
        if p ~= player then
            pCount = pCount + 1
            local b = Instance.new("TextButton", PListFrame)
            b.Size = UDim2.new(1, -10, 0, 30)
            b.BackgroundColor3 = WHITELISTED[p.Name] and Color3.fromRGB(150, 0, 0) or Color3.fromRGB(40, 40, 40)
            b.Text = p.Name .. (WHITELISTED[p.Name] and " [WL]" or "")
            b.TextColor3 = Color3.new(1, 1, 1)
            b.Font = Enum.Font.Gotham
            b.TextSize = 10
            b.ZIndex = 21
            
            b.MouseButton1Click:Connect(function()
                WHITELISTED[p.Name] = not WHITELISTED[p.Name]
                b.BackgroundColor3 = WHITELISTED[p.Name] and Color3.fromRGB(150, 0, 0) or Color3.fromRGB(40, 40, 40)
                b.Text = p.Name .. (WHITELISTED[p.Name] and " [WL]" or "")
            end)
            Instance.new("UICorner", b)
        end
    end
    PListFrame.CanvasSize = UDim2.new(0, 0, 0, pCount * 32)
end

-- Initial refresh
RefreshPlayerList()

-- Update list automatically when people join/leave
Players.PlayerAdded:Connect(function() RefreshPlayerList() end)
Players.PlayerRemoving:Connect(function() RefreshPlayerList() end)

-- // SIMPLE ESP SYSTEM
local function applyESP(char)
    if not char:FindFirstChild("HumanoidRootPart") then return end
    if char:FindFirstChild("EliteESP") then return end

    local hl = Instance.new("Highlight")
    hl.Name = "EliteESP"
    hl.FillColor = Color3.fromRGB(0, 255, 150)
    hl.OutlineColor = Color3.fromRGB(0, 80, 50)
    hl.FillTransparency = 0.5
    hl.OutlineTransparency = 0
    hl.Parent = char
end

local function removeESP(char)
    local hl = char:FindFirstChild("EliteESP")
    if hl then hl:Destroy() end
end

-- // MAIN LOGIC LOOP
getgenv().AimConnection = RunService.RenderStepped:Connect(function()
    PListFrame.Position = Main.Position + UDim2.new(0, 0, 0, Main.AbsoluteSize.Y + 5)
    FOVCircle.Position = Vector2.new(camera.ViewportSize.X / 2, camera.ViewportSize.Y / 2)
    FOVCircle.Radius = FOV_RADIUS
    FOVCircle.Visible = FOV_VISIBLE
    camera.FieldOfView = GAME_FOV_VAL

    -- ESP handling
    for _, p in pairs(Players:GetPlayers()) do
        if p ~= player and p.Character then
            if ESP_ENABLED then
                applyESP(p.Character)
            else
                removeESP(p.Character)
            end
        end
    end

    -- AIM logic
    if AIM_ENABLED then
        local target = nil
        local maxDist = FOV_VISIBLE and FOV_RADIUS or math.huge
        local screenCenter = Vector2.new(camera.ViewportSize.X / 2, camera.ViewportSize.Y / 2)
        local fovMultiplier = camera.FieldOfView / 70  -- Adjust for FOV scaling

        for _, p in pairs(Players:GetPlayers()) do
            if p ~= player and not WHITELISTED[p.Name] and p.Character then
                local char = p.Character
                local hum = char:FindFirstChild("Humanoid")
                if hum and hum.Health > 0 then
                    -- Select target part based on the type
                    local part = (TARGET_TYPE == "Head" and char:FindFirstChild("Head")) or 
                                 (TARGET_TYPE == "Chest" and (char:FindFirstChild("UpperTorso") or char:FindFirstChild("Torso"))) or 
                                 (char:FindFirstChild("HumanoidRootPart"))
                    
                    if part then
                        local screenPos, onScreen = camera:WorldToViewportPoint(part.Position)
                        if onScreen or not FOV_VISIBLE then
                            -- Calculate distance from the center of the screen (aiming point)
                            local distFromMouse = (Vector2.new(screenPos.X, screenPos.Y) - screenCenter).Magnitude
                            local adjustedDist = distFromMouse * fovMultiplier  -- Adjust distance for FOV scaling

                            -- Check if this target is within the FOV range
                            if adjustedDist < maxDist then
                                -- Adjust aiming height based on the FOV multiplier
                                local fpComp = AIM_HEIGHT_ADJUST * (camera.FieldOfView / 70)
                                local finalPos = (TARGET_TYPE == "Head") and part.Position + Vector3.new(0, fpComp, 0) or part.Position
                                
                                local rp = RaycastParams.new()
                                rp.FilterType = Enum.RaycastFilterType.Blacklist
                                rp.FilterDescendantsInstances = {player.Character, char}
                                
                                -- Raycast to ensure no obstruction between camera and target
                                if workspace:Raycast(camera.CFrame.Position, (finalPos - camera.CFrame.Position), rp) == nil then
                                    target = finalPos
                                    maxDist = adjustedDist  -- Keep track of the nearest target
                                end
                            end
                        end
                    end
                end
            end
        end

        -- If a valid target is found, adjust the camera to aim at it
        if target then 
            camera.CFrame = CFrame.lookAt(camera.CFrame.Position, target)
        end
    end
end)

-- // BUTTON CONNECTORS
GameFOVUp.MouseButton1Click:Connect(function()
    GAME_FOV_VAL = math.clamp(GAME_FOV_VAL + 5, 30, 200)
    GameFOVMain.Text = "GAME FOV: " .. GAME_FOV_VAL
end)

GameFOVDown.MouseButton1Click:Connect(function()
    GAME_FOV_VAL = math.clamp(GAME_FOV_VAL - 5, 0, 120)
    GameFOVMain.Text = "GAME FOV: " .. GAME_FOV_VAL
end)

HeightUp.MouseButton1Click:Connect(function()
    AIM_HEIGHT_ADJUST = math.round((AIM_HEIGHT_ADJUST + 0.02) * 100) / 100
    HeightMain.Text = "H-ADJ: " .. AIM_HEIGHT_ADJUST
end)

HeightDown.MouseButton1Click:Connect(function()
    AIM_HEIGHT_ADJUST = math.round((AIM_HEIGHT_ADJUST - 0.02) * 100) / 100
    HeightMain.Text = "H-ADJ: " .. AIM_HEIGHT_ADJUST
end)

LockBtn.MouseButton1Click:Connect(function()
    AIM_ENABLED = not AIM_ENABLED
    LockBtn.Text = AIM_ENABLED and "SNAP LOCK: ON" or "SNAP LOCK: OFF"
    LockBtn.BackgroundColor3 = AIM_ENABLED and Color3.fromRGB(180, 0, 0) or Color3.fromRGB(35, 35, 35)
end)

ESPBtn.MouseButton1Click:Connect(function()
    ESP_ENABLED = not ESP_ENABLED
    ESPBtn.Text = ESP_ENABLED and "ALIVE ESP: ON" or "ALIVE ESP: OFF"
    ESPBtn.BackgroundColor3 = ESP_ENABLED and Color3.fromRGB(0, 150, 200) or Color3.fromRGB(35, 35, 35)
end)

FOVUp.MouseButton1Click:Connect(function()
    FOV_RADIUS = math.clamp(FOV_RADIUS + 10, 10, 2000)
    FOVMain.Text = "AIM FOV: " .. FOV_RADIUS
end)

FOVDown.MouseButton1Click:Connect(function()
    FOV_RADIUS = math.clamp(FOV_RADIUS - 10, 10, 2000)
    FOVMain.Text = "AIM FOV: " .. FOV_RADIUS
end)

FOVMain.MouseButton1Click:Connect(function()
    FOV_VISIBLE = not FOV_VISIBLE
    FOVMain.BackgroundColor3 = FOV_VISIBLE and Color3.fromRGB(0, 255, 150) or Color3.fromRGB(150, 0, 0)
    FOVMain.Text = FOV_VISIBLE and "AIM FOV: " .. FOV_RADIUS or "GLOBAL SNAP"
end)

MinBtn.MouseButton1Click:Connect(function()
    IS_MINIMIZED = not IS_MINIMIZED
    Content.Visible = not IS_MINIMIZED
    Main:TweenSize(IS_MINIMIZED and UDim2.new(0, 200, 0, 35) or UDim2.new(0, 200, 0, 490), "Out", "Quad", 0.2, true)
end)

PListToggle.MouseButton1Click:Connect(function()
    if not PListFrame.Visible then
        RefreshPlayerList()
        PListFrame.Visible = true
        PListFrame:TweenSize(UDim2.new(0, 200, 0, 200), "Out", "Quad", 0.2, true)
    else
        PListFrame:TweenSize(UDim2.new(0, 200, 0, 0), "Out", "Quad", 0.2, true)
        task.wait(0.2)
        PListFrame.Visible = false
    end
end)

local function setT(btn, t)
    TARGET_TYPE = t
    HeadBtn.BackgroundColor3 = Color3.fromRGB(35,35,35)
    ChestBtn.BackgroundColor3 = Color3.fromRGB(35,35,35)
    LegBtn.BackgroundColor3 = Color3.fromRGB(35,35,35)
    btn.BackgroundColor3 = Color3.fromRGB(180, 0, 0)
end

HeadBtn.MouseButton1Click:Connect(function() setT(HeadBtn, "Head") end)
ChestBtn.MouseButton1Click:Connect(function() setT(ChestBtn, "Chest") end)
LegBtn.MouseButton1Click:Connect(function() setT(LegBtn, "Legs") end)
