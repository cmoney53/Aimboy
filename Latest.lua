-- // FORCE CLEAR ALL PREVIOUS VERSIONS
local VERSION_TAG = "ELITE_V21_FULL_PRO"
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local player = Players.LocalPlayer
local camera = workspace.CurrentCamera

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
-- FOV SETTINGS
local FOV_VISIBLE = true
local FOV_RADIUS = 100

-- // DRAWING FOV CIRCLE
local FOVCircle = Drawing.new("Circle")
FOVCircle.Thickness = 1.5
FOVCircle.Color = Color3.fromRGB(0, 255, 150)
FOVCircle.Filled = false
FOVCircle.Transparency = 1
FOVCircle.Visible = FOV_VISIBLE
FOVCircle.Radius = FOV_RADIUS

-- // UI SETUP
local ScreenGui = Instance.new("ScreenGui", player:WaitForChild("PlayerGui"))
ScreenGui.Name = VERSION_TAG
ScreenGui.ResetOnSpawn = false
ScreenGui.ZIndexBehavior = Enum.ZIndexBehavior.Global

local Main = Instance.new("Frame", ScreenGui)
Main.Size = UDim2.new(0, 200, 0, 420) -- Increased to fit FOV row
Main.Position = UDim2.new(0.05, 0, 0.3, 0)
Main.BackgroundColor3 = Color3.fromRGB(15, 15, 15)
Main.Active = true
Main.Draggable = true
Instance.new("UICorner", Main)

local Title = Instance.new("TextLabel", Main)
Title.Size = UDim2.new(1, -65, 0, 35)
Title.Text = "  V21 | PLRS: " .. #Players:GetPlayers()
Title.TextColor3 = Color3.fromRGB(0, 255, 150)
Title.Font = Enum.Font.GothamBold
Title.TextSize = 13
Title.BackgroundTransparency = 1
Title.TextXAlignment = Enum.TextXAlignment.Left

spawn(function()
    while wait(1) do Title.Text = "  V21 | PLRS: " .. #Players:GetPlayers() end
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

-- BUTTONS
local LockBtn = makeBtn("SNAP LOCK: OFF", 5, Color3.fromRGB(35, 35, 35))
local ESPBtn = makeBtn("ALIVE ESP: OFF", 45, Color3.fromRGB(35, 35, 35))
local ShootBtn = makeBtn("AUTO FIRE: OFF", 85, Color3.fromRGB(35, 35, 35))

-- // FOV TRIPLE BUTTON ROW
local FOVDown = Instance.new("TextButton", Content)
FOVDown.Size = UDim2.new(0, 40, 0, 35)
FOVDown.Position = UDim2.new(0, 10, 0, 125)
FOVDown.BackgroundColor3 = Color3.fromRGB(45, 45, 45)
FOVDown.Text = "-"
FOVDown.TextColor3 = Color3.new(1, 1, 1)
Instance.new("UICorner", FOVDown)

local FOVAimBtn = Instance.new("TextButton", Content)
FOVAimBtn.Size = UDim2.new(0, 95, 0, 35)
FOVAimBtn.Position = UDim2.new(0, 53, 0, 125)
FOVAimBtn.BackgroundColor3 = Color3.fromRGB(0, 255, 150)
FOVAimBtn.Text = "AIM FOV: " .. FOV_RADIUS
FOVAimBtn.TextColor3 = Color3.fromRGB(0, 0, 0)
FOVAimBtn.Font = Enum.Font.GothamBold
FOVAimBtn.TextSize = 9
Instance.new("UICorner", FOVAimBtn)

local FOVUp = Instance.new("TextButton", Content)
FOVUp.Size = UDim2.new(0, 40, 0, 35)
FOVUp.Position = UDim2.new(0, 150, 0, 125)
FOVUp.BackgroundColor3 = Color3.fromRGB(45, 45, 45)
FOVUp.Text = "+"
FOVUp.TextColor3 = Color3.new(1, 1, 1)
Instance.new("UICorner", FOVUp)

-- TARGET BUTTONS (Shifted down)
local HeadBtn = makeBtn("TARGET: FOREHEAD", 185, Color3.fromRGB(180, 0, 0))
local ChestBtn = makeBtn("TARGET: CHEST", 225, Color3.fromRGB(35, 35, 35))
local LegBtn = makeBtn("TARGET: LEGS", 265, Color3.fromRGB(35, 35, 35))

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

-- PLAYER LIST
local PListFrame = Instance.new("ScrollingFrame", ScreenGui)
PListFrame.Size = UDim2.new(0, 200, 0, 0)
PListFrame.Visible = false
PListFrame.BackgroundColor3 = Color3.fromRGB(25, 25, 25)
PListFrame.ZIndex = 20
PListFrame.CanvasSize = UDim2.new(0, 0, 0, 0)
PListFrame.ScrollBarThickness = 4
local UIList = Instance.new("UIListLayout", PListFrame)
UIList.Padding = UDim.new(0, 2)
Instance.new("UICorner", PListFrame)

-- // ESP HIGHLIGHTER
local function ApplyHighlight(p)
    if p == player then return end
    local char = p.Character or p.CharacterAdded:Wait()
    local hl = char:FindFirstChild("EliteHighlight") or Instance.new("Highlight", char)
    hl.Name = "EliteHighlight"
    hl.FillColor = Color3.fromRGB(255, 0, 0)
    hl.OutlineColor = Color3.fromRGB(255, 255, 255)
    hl.DepthMode = Enum.HighlightDepthMode.AlwaysOnTop
    hl.Enabled = ESP_ENABLED
end

-- // CORE LOGIC
getgenv().AimConnection = RunService.RenderStepped:Connect(function()
    PListFrame.Position = Main.Position + UDim2.new(0, 0, 0, Main.AbsoluteSize.Y + 5)
    
    -- Sync Circle
    FOVCircle.Position = Vector2.new(camera.ViewportSize.X / 2, camera.ViewportSize.Y / 2)
    FOVCircle.Radius = FOV_RADIUS
    FOVCircle.Visible = FOV_VISIBLE

    if AIM_ENABLED then
        local tPos, dist = nil, FOV_RADIUS -- Limits detection to FOV radius
        local center = Vector2.new(camera.ViewportSize.X / 2, camera.ViewportSize.Y / 2)

        for _, p in pairs(Players:GetPlayers()) do
            if p ~= player and not WHITELISTED[p.Name] and p.Character then
                local char = p.Character
                local hum = char:FindFirstChildOfClass("Humanoid")
                if hum and hum.Health > 0 then
                    local part = (TARGET_TYPE == "Head" and char:FindFirstChild("Head")) or 
                                 (TARGET_TYPE == "Chest" and (char:FindFirstChild("UpperTorso") or char:FindFirstChild("Torso"))) or 
                                 (char:FindFirstChild("LeftFoot") or char:FindFirstChild("LowerTorso"))
                    
                    if part then
                        local screenPos, onScreen = camera:WorldToViewportPoint(part.Position)
                        if onScreen then
                            local mouseDist = (Vector2.new(screenPos.X, screenPos.Y) - center).Magnitude
                            if mouseDist < dist then
                                -- Original Raycast Check
                                local finalPos = (TARGET_TYPE == "Head") and part.Position + Vector3.new(0, 0.26, 0) or part.Position
                                local dir = (finalPos - camera.CFrame.Position).Unit * (finalPos - camera.CFrame.Position).Magnitude
                                local rp = RaycastParams.new()
                                rp.FilterType = Enum.RaycastFilterType.Blacklist
                                rp.FilterDescendantsInstances = {player.Character, char}
                                
                                if workspace:Raycast(camera.CFrame.Position, dir, rp) == nil then
                                    tPos = finalPos
                                    dist = mouseDist
                                end
                            end
                        end
                    end
                end
            end
        end
        if tPos then camera.CFrame = CFrame.lookAt(camera.CFrame.Position, tPos) end
    end
    
    -- ESP Loop
    for _, p in pairs(Players:GetPlayers()) do
        if p ~= player and p.Character then
            local hl = p.Character:FindFirstChild("EliteHighlight")
            if ESP_ENABLED then
                if not hl then ApplyHighlight(p) else hl.Enabled = true end
            elseif hl then hl.Enabled = false end
        end
    end

    if AUTO_SHOOT then
        local tool = player.Character and player.Character:FindFirstChildOfClass("Tool")
        if tool then tool:Activate() end
    end
end)

-- // BUTTON LOGIC
FOVUp.MouseButton1Click:Connect(function()
    FOV_RADIUS = math.clamp(FOV_RADIUS + 10, 10, 600)
    FOVAimBtn.Text = "AIM FOV: " .. FOV_RADIUS
end)

FOVDown.MouseButton1Click:Connect(function()
    FOV_RADIUS = math.clamp(FOV_RADIUS - 10, 10, 600)
    FOVAimBtn.Text = "AIM FOV: " .. FOV_RADIUS
end)

FOVAimBtn.MouseButton1Click:Connect(function()
    FOV_VISIBLE = not FOV_VISIBLE
    FOVAimBtn.BackgroundColor3 = FOV_VISIBLE and Color3.fromRGB(0, 255, 150) or Color3.fromRGB(150, 0, 0)
end)

-- Original UI Listeners
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

ShootBtn.MouseButton1Click:Connect(function()
    AUTO_SHOOT = not AUTO_SHOOT
    ShootBtn.Text = AUTO_SHOOT and "FIRE: ON" or "FIRE: OFF"
    ShootBtn.BackgroundColor3 = AUTO_SHOOT and Color3.fromRGB(0, 150, 50) or Color3.fromRGB(35, 35, 35)
end)

MinBtn.MouseButton1Click:Connect(function()
    IS_MINIMIZED = not IS_MINIMIZED
    Content.Visible = not IS_MINIMIZED
    Main:TweenSize(IS_MINIMIZED and UDim2.new(0, 200, 0, 35) or UDim2.new(0, 200, 0, 420), "Out", "Quad", 0.2, true)
end)

PListToggle.MouseButton1Click:Connect(function()
    PListFrame.Visible = not PListFrame.Visible
    if PListFrame.Visible then
        for _, c in pairs(PListFrame:GetChildren()) do if c:IsA("TextButton") then c:Destroy() end end
        for _, p in pairs(Players:GetPlayers()) do
            if p ~= player then
                local b = Instance.new("TextButton", PListFrame)
                b.Size = UDim2.new(1, -10, 0, 30)
                b.BackgroundColor3 = WHITELISTED[p.Name] and Color3.fromRGB(150, 0, 0) or Color3.fromRGB(40, 40, 40)
                b.Text = p.Name .. (WHITELISTED[p.Name] and " [WL]" or "")
                b.TextColor3 = Color3.new(1, 1, 1)
                b.MouseButton1Click:Connect(function()
                    WHITELISTED[p.Name] = not WHITELISTED[p.Name]
                    b.BackgroundColor3 = WHITELISTED[p.Name] and Color3.fromRGB(150, 0, 0) or Color3.fromRGB(40, 40, 40)
                    b.Text = p.Name .. (WHITELISTED[p.Name] and " [WL]" or "")
                end)
                Instance.new("UICorner", b)
            end
        end
        PListFrame:TweenSize(UDim2.new(0, 200, 0, 150), "Out", "Quad", 0.2, true)
    else
        PListFrame:TweenSize(UDim2.new(0, 200, 0, 0), "Out", "Quad", 0.2, true)
    end
end)

local function setT(btn, t)
    TARGET_TYPE = t
    HeadBtn.BackgroundColor3, ChestBtn.BackgroundColor3, LegBtn.BackgroundColor3 = Color3.fromRGB(35,35,35), Color3.fromRGB(35,35,35), Color3.fromRGB(35,35,35)
    btn.BackgroundColor3 = Color3.fromRGB(180, 0, 0)
end
HeadBtn.MouseButton1Click:Connect(function() setT(HeadBtn, "Head") end)
ChestBtn.MouseButton1Click:Connect(function() setT(ChestBtn, "Chest") end)
LegBtn.MouseButton1Click:Connect(function() setT(LegBtn, "Legs") end)
