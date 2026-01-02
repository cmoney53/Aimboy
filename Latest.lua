-- // FORCE CLEAR ALL PREVIOUS VERSIONS
local VERSION_TAG = "ELITE_V21_ULTRA_FINAL"
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

-- // UI SETUP
local ScreenGui = Instance.new("ScreenGui", player:WaitForChild("PlayerGui"))
ScreenGui.Name = VERSION_TAG
ScreenGui.ResetOnSpawn = false
ScreenGui.ZIndexBehavior = Enum.ZIndexBehavior.Global

local Main = Instance.new("Frame", ScreenGui)
Main.Size = UDim2.new(0, 200, 0, 360)
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

-- Update Player Count
spawn(function()
    while wait(1) do
        Title.Text = "  Cash_Aimbot| PLRS: " .. #Players:GetPlayers()
    end
end)

-- CONTENT
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

local LockBtn = makeBtn("SNAP LOCK: OFF", 5, Color3.fromRGB(35, 35, 35))
local ESPBtn = makeBtn("ULTRA ESP: OFF", 45, Color3.fromRGB(35, 35, 35))
local ShootBtn = makeBtn("AUTO FIRE: OFF", 85, Color3.fromRGB(35, 35, 35))
local HeadBtn = makeBtn("TARGET: FOREHEAD", 155, Color3.fromRGB(180, 0, 0))
local ChestBtn = makeBtn("TARGET: CHEST", 195, Color3.fromRGB(35, 35, 35))
local LegBtn = makeBtn("TARGET: LEGS", 235, Color3.fromRGB(35, 35, 35))

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

-- // ULTRA ESP FUNCTION
local function ApplyUltraESP(p)
    if p == player or not p.Character then return end
    local hrp = p.Character:WaitForChild("HumanoidRootPart", 5)
    if hrp and not hrp:FindFirstChild("EliteBox") then
        local box = Instance.new("BoxHandleAdornment")
        box.Name = "EliteBox"
        box.Size = Vector3.new(4, 6, 0.5)
        box.AlwaysOnTop = true
        box.ZIndex = 10
        box.Transparency = 0.5
        box.Color3 = Color3.fromRGB(255, 0, 0)
        box.Adornee = hrp
        box.Parent = hrp
    end
end

-- // CORE LOGIC
getgenv().AimConnection = RunService.RenderStepped:Connect(function()
    PListFrame.Position = Main.Position + UDim2.new(0, 0, 0, Main.AbsoluteSize.Y + 5)
    
    if AIM_ENABLED then
        local tPos, dist = nil, 2000
        for _, p in pairs(Players:GetPlayers()) do
            if p ~= player and not WHITELISTED[p.Name] then
                local char = p.Character
                if char and char:FindFirstChild("Humanoid") and char.Humanoid.Health > 0 then
                    local part = (TARGET_TYPE == "Head" and char:FindFirstChild("Head")) or 
                                 (TARGET_TYPE == "Chest" and (char:FindFirstChild("UpperTorso") or char:FindFirstChild("Torso"))) or 
                                 (char:FindFirstChild("LeftFoot") or char:FindFirstChild("LowerTorso"))
                    
                    if part then
                        local finalPos = (TARGET_TYPE == "Head") and part.Position + Vector3.new(0, 0.26, 0) or part.Position
                        local origin = camera.CFrame.Position
                        local dir = (finalPos - origin).Unit * (finalPos - origin).Magnitude
                        
                        local rp = RaycastParams.new()
                        rp.FilterType = Enum.RaycastFilterType.Blacklist
                        rp.FilterDescendantsInstances = {player.Character, char}
                        
                        if workspace:Raycast(origin, dir, rp) == nil then
                            local d = (finalPos - player.Character.HumanoidRootPart.Position).Magnitude
                            if d < dist then tPos = finalPos dist = d end
                        end
                    end
                end
            end
        end
        if tPos then camera.CFrame = CFrame.lookAt(camera.CFrame.Position, tPos) end
    end
    
    -- ULTRA ESP LOOP
    for _, p in pairs(Players:GetPlayers()) do
        if p ~= player and p.Character and p.Character:FindFirstChild("HumanoidRootPart") then
            local box = p.Character.HumanoidRootPart:FindFirstChild("EliteBox")
            if ESP_ENABLED then
                if not box then ApplyUltraESP(p) else box.Visible = true end
            else
                if box then box.Visible = false end
            end
        end
    end

    if AUTO_SHOOT then
        local tool = player.Character and player.Character:FindFirstChildOfClass("Tool")
        if tool then tool:Activate() end
    end
end)

-- // PLAYER LIST LOGIC
local function updatePlayerListUI()
    for _, c in pairs(PListFrame:GetChildren()) do if c:IsA("TextButton") then c:Destroy() end end
    local count = 0
    for _, p in pairs(Players:GetPlayers()) do
        if p ~= player then
            count = count + 1
            local b = Instance.new("TextButton", PListFrame)
            b.Size = UDim2.new(1, -10, 0, 30)
            b.ZIndex = 21
            b.BackgroundColor3 = WHITELISTED[p.Name] and Color3.fromRGB(150, 0, 0) or Color3.fromRGB(40, 40, 40)
            b.Text = p.Name .. (WHITELISTED[p.Name] and " [WL]" or "")
            b.TextColor3 = Color3.new(1, 1, 1)
            b.Font = Enum.Font.Gotham
            b.MouseButton1Click:Connect(function()
                WHITELISTED[p.Name] = not WHITELISTED[p.Name]
                b.BackgroundColor3 = WHITELISTED[p.Name] and Color3.fromRGB(150, 0, 0) or Color3.fromRGB(40, 40, 40)
                b.Text = p.Name .. (WHITELISTED[p.Name] and " [WL]" or "")
            end)
            Instance.new("UICorner", b)
        end
    end
    PListFrame.CanvasSize = UDim2.new(0, 0, 0, count * 32)
end

-- // CONNECTIONS
PListToggle.MouseButton1Click:Connect(function()
    PListFrame.Visible = not PListFrame.Visible
    if PListFrame.Visible then
        updatePlayerListUI()
        PListFrame:TweenSize(UDim2.new(0, 200, 0, 150), "Out", "Quad", 0.2, true)
    else
        PListFrame:TweenSize(UDim2.new(0, 200, 0, 0), "Out", "Quad", 0.2, true)
    end
end)

ESPBtn.MouseButton1Click:Connect(function()
    ESP_ENABLED = not ESP_ENABLED
    ESPBtn.Text = ESP_ENABLED and "ULTRA ESP: ON" or "ULTRA ESP: OFF"
    ESPBtn.BackgroundColor3 = ESP_ENABLED and Color3.fromRGB(0, 150, 200) or Color3.fromRGB(35, 35, 35)
end)

LockBtn.MouseButton1Click:Connect(function()
    AIM_ENABLED = not AIM_ENABLED
    LockBtn.Text = AIM_ENABLED and "SNAP LOCK: ON" or "SNAP LOCK: OFF"
    LockBtn.BackgroundColor3 = AIM_ENABLED and Color3.fromRGB(180, 0, 0) or Color3.fromRGB(35, 35, 35)
end)

ShootBtn.MouseButton1Click:Connect(function()
    AUTO_SHOOT = not AUTO_SHOOT
    ShootBtn.Text = AUTO_SHOOT and "FIRE: ON" or "FIRE: OFF"
    ShootBtn.BackgroundColor3 = AUTO_SHOOT and Color3.fromRGB(0, 150, 50) or Color3.fromRGB(35, 35, 35)
end)

MinBtn.MouseButton1Click:Connect(function()
    IS_MINIMIZED = not IS_MINIMIZED
    Content.Visible = not IS_MINIMIZED
    Main:TweenSize(IS_MINIMIZED and UDim2.new(0, 200, 0, 35) or UDim2.new(0, 200, 0, 360), "Out", "Quad", 0.2, true)
    if IS_MINIMIZED then PListFrame.Visible = false end
end)

local function setT(btn, t)
    TARGET_TYPE = t
    HeadBtn.BackgroundColor3, ChestBtn.BackgroundColor3, LegBtn.BackgroundColor3 = Color3.fromRGB(35,35,35), Color3.fromRGB(35,35,35), Color3.fromRGB(35,35,35)
    btn.BackgroundColor3 = Color3.fromRGB(180, 0, 0)
end
HeadBtn.MouseButton1Click:Connect(function() setT(HeadBtn, "Head") end)
ChestBtn.MouseButton1Click:Connect(function() setT(ChestBtn, "Chest") end)
LegBtn.MouseButton1Click:Connect(function() setT(LegBtn, "Legs") end)
