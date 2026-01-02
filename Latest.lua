-- // FORCE CLEAR ALL PREVIOUS VERSIONS
local VERSION_TAG = "ELITE_V21_PRO_STABLE"
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

-- // FOV SYSTEM SETTINGS
local FOV_RADIUS = 100
local FOV_VISIBLE = true
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
Main.Size = UDim2.new(0, 200, 0, 410) -- Adjusted height for new row
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

-- // CORE BUTTONS
local LockBtn = makeBtn("SNAP LOCK: OFF", 5, Color3.fromRGB(35, 35, 35))
local ESPBtn = makeBtn("ALIVE ESP: OFF", 45, Color3.fromRGB(35, 35, 35))
local ShootBtn = makeBtn("AUTO FIRE: OFF", 85, Color3.fromRGB(35, 35, 35))

-- // NEW: FOV BUTTONS SIDE-BY-SIDE
local FOVDown = Instance.new("TextButton", Content)
FOVDown.Size = UDim2.new(0, 40, 0, 35)
FOVDown.Position = UDim2.new(0, 10, 0, 125)
FOVDown.BackgroundColor3 = Color3.fromRGB(45, 45, 45)
FOVDown.Text = "-"
FOVDown.TextColor3 = Color3.new(1, 1, 1)
Instance.new("UICorner", FOVDown)

local FOVMain = Instance.new("TextButton", Content)
FOVMain.Size = UDim2.new(0, 95, 0, 35)
FOVMain.Position = UDim2.new(0, 53, 0, 125)
FOVMain.BackgroundColor3 = Color3.fromRGB(0, 255, 150)
FOVMain.Text = "AIM FOV: " .. FOV_RADIUS
FOVMain.TextColor3 = Color3.fromRGB(0, 0, 0)
FOVMain.Font = Enum.Font.GothamBold
FOVMain.TextSize = 9
Instance.new("UICorner", FOVMain)

local FOVUp = Instance.new("TextButton", Content)
FOVUp.Size = UDim2.new(0, 40, 0, 35)
FOVUp.Position = UDim2.new(0, 150, 0, 125)
FOVUp.BackgroundColor3 = Color3.fromRGB(45, 45, 45)
FOVUp.Text = "+"
FOVUp.TextColor3 = Color3.new(1, 1, 1)
Instance.new("UICorner", FOVUp)

-- // TARGET BUTTONS (Shifted down)
local HeadBtn = makeBtn("TARGET: FOREHEAD", 175, Color3.fromRGB(180, 0, 0))
local ChestBtn = makeBtn("TARGET: CHEST", 215, Color3.fromRGB(35, 35, 35))
local LegBtn = makeBtn("TARGET: LEGS", 255, Color3.fromRGB(35, 35, 35))

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
PListFrame.Size = UDim2.new(0, 200, 0, 0)
PListFrame.Visible = false
PListFrame.BackgroundColor3 = Color3.fromRGB(25, 25, 25)
PListFrame.ZIndex = 20
PListFrame.CanvasSize = UDim2.new(0, 0, 0, 0)
PListFrame.ScrollBarThickness = 4
local UIList = Instance.new("UIListLayout", PListFrame)
UIList.Padding = UDim.new(0, 2)
Instance.new("UICorner", PListFrame)

-- // HIGHLIGHT FUNCTION
local function ApplyHighlight(p)
    if p == player then return end
    local char = p.Character or p.CharacterAdded:Wait()
    local highlight = char:FindFirstChild("EliteHighlight") or Instance.new("Highlight", char)
    highlight.Name = "EliteHighlight"
    highlight.FillColor = Color3.fromRGB(255, 0, 0)
    highlight.OutlineColor = Color3.fromRGB(255, 255, 255)
    highlight.FillTransparency = 0.5
    highlight.DepthMode = Enum.HighlightDepthMode.AlwaysOnTop
    highlight.Enabled = ESP_ENABLED
end

-- // MAIN LOGIC LOOP
getgenv().AimConnection = RunService.RenderStepped:Connect(function()
    PListFrame.Position = Main.Position + UDim2.new(0, 0, 0, Main.AbsoluteSize.Y + 5)
    
    -- Sync FOV Circle
    FOVCircle.Position = Vector2.new(camera.ViewportSize.X / 2, camera.ViewportSize.Y / 2)
    FOVCircle.Radius = FOV_RADIUS
    FOVCircle.Visible = FOV_VISIBLE

    if AIM_ENABLED then
        local target = nil
        local maxDist = FOV_RADIUS -- Must be inside circle
        local screenCenter = Vector2.new(camera.ViewportSize.X / 2, camera.ViewportSize.Y / 2)

        for _, p in pairs(Players:GetPlayers()) do
            if p ~= player and not WHITELISTED[p.Name] and p.Character then
                local char = p.Character
                local hum = char:FindFirstChild("Humanoid")
                if hum and hum.Health > 0 then
                    local part = (TARGET_TYPE == "Head" and char:FindFirstChild("Head")) or 
                                 (TARGET_TYPE == "Chest" and (char:FindFirstChild("UpperTorso") or char:FindFirstChild("Torso"))) or 
                                 (char:FindFirstChild("LeftFoot") or char:FindFirstChild("LowerTorso"))
                    
                    if part then
                        local screenPos, onScreen = camera:WorldToViewportPoint(part.Position)
                        if onScreen then
                            local distFromMouse = (Vector2.new(screenPos.X, screenPos.Y) - screenCenter).Magnitude
                            if distFromMouse < maxDist then
                                -- Raycast Check (Your original logic)
                                local finalPos = (TARGET_TYPE == "Head") and part.Position + Vector3.new(0, 0.26, 0) or part.Position
                                local dir = (finalPos - camera.CFrame.Position).Unit * (finalPos - camera.CFrame.Position).Magnitude
                                local rp = RaycastParams.new()
                                rp.FilterType = Enum.RaycastFilterType.Blacklist
                                rp.FilterDescendantsInstances = {player.Character, char}
                                
                                if workspace:Raycast(camera.CFrame.Position, dir, rp) == nil then
                                    target = finalPos
                                    maxDist = distFromMouse
                                end
                            end
                        end
                    end
                end
            end
        end
        if target then camera.CFrame = CFrame.lookAt(camera.CFrame.Position, target) end
    end
    
    -- ESP UPDATE
    for _, p in pairs(Players:GetPlayers()) do
        if p ~= player and p.Character then
            local highlight = p.Character:FindFirstChild("EliteHighlight")
            if ESP_ENABLED then
                if not highlight then ApplyHighlight(p) else highlight.Enabled = true end
            elseif highlight then highlight.Enabled = false end
        end
    end

    if AUTO_SHOOT then
        local tool = player.Character and player.Character:FindFirstChildOfClass("Tool")
        if tool then tool:Activate() end
    end
end)

-- // BUTTON CONNECTORS
FOVUp.MouseButton1Click:Connect(function()
    FOV_RADIUS = math.clamp(FOV_RADIUS + 10, 10, 600)
    FOVMain.Text = "AIM FOV: " .. FOV_RADIUS
end)

FOVDown.MouseButton1Click:Connect(function()
    FOV_RADIUS = math.clamp(FOV_RADIUS - 10, 10, 600)
    FOVMain.Text = "AIM FOV: " .. FOV_RADIUS
end)

FOVMain.MouseButton1Click:Connect(function()
    FOV_VISIBLE = not FOV_VISIBLE
    FOVMain.BackgroundColor3 = FOV_VISIBLE and Color3.fromRGB(0, 255, 150) or Color3.fromRGB(150, 0, 0)
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

ShootBtn.MouseButton1Click:Connect(function()
    AUTO_SHOOT = not AUTO_SHOOT
    ShootBtn.Text = AUTO_SHOOT and "FIRE: ON" or "FIRE: OFF"
    ShootBtn.BackgroundColor3 = AUTO_SHOOT and Color3.fromRGB(0, 150, 50) or Color3.fromRGB(35, 35, 35)
end)

MinBtn.MouseButton1Click:Connect(function()
    IS_MINIMIZED = not IS_MINIMIZED
    Content.Visible = not IS_MINIMIZED
    Main:TweenSize(IS_MINIMIZED and UDim2.new(0, 200, 0, 35) or UDim2.new(0, 200, 0, 410), "Out", "Quad", 0.2, true)
    if IS_MINIMIZED then PListFrame.Visible = false end
end)

-- Whitelist / Player List
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
