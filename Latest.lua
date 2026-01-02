-- // FORCE CLEAR ALL PREVIOUS VERSIONS
local VERSION_TAG = "ELITE_V26_COMPLETE_BUILD"
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local player = Players.LocalPlayer
local camera = workspace.CurrentCamera

-- Global Clean-up to prevent overlap
if getgenv().AimConnection then getgenv().AimConnection:Disconnect() end
if getgenv().EliteTracers then 
    for _, v in pairs(getgenv().EliteTracers) do v:Remove() end 
end
getgenv().EliteTracers = {}

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
Title.Text = "  ELITE V26 | STABLE"
Title.TextColor3 = Color3.fromRGB(0, 255, 150)
Title.Font = Enum.Font.GothamBold
Title.TextSize = 13
Title.BackgroundTransparency = 1
Title.TextXAlignment = Enum.TextXAlignment.Left

-- Dynamic Title Script (Restored)
spawn(function()
    while task.wait(1) do
        local count = #Players:GetPlayers()
        Title.Text = "  V26 | PLAYERS: " .. tostring(count)
    end
end)

-- CONTENT CONTAINER
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
    Instance.new("UICorner", b)
    return b
end

local LockBtn = makeBtn("SNAP LOCK: OFF", 5, Color3.fromRGB(35, 35, 35))
local ESPBtn = makeBtn("UNLIMITED ESP: OFF", 45, Color3.fromRGB(35, 35, 35))
local ShootBtn = makeBtn("AUTO FIRE: OFF", 85, Color3.fromRGB(35, 35, 35))
local HeadBtn = makeBtn("TARGET: FOREHEAD", 155, Color3.fromRGB(180, 0, 0))
local ChestBtn = makeBtn("TARGET: CHEST", 195, Color3.fromRGB(35, 35, 35))
local LegBtn = makeBtn("TARGET: LEGS", 235, Color3.fromRGB(35, 35, 35))

-- TOP BUTTONS
local function createTopBtn(text, xPos)
    local b = Instance.new("TextButton", Main)
    b.Size = UDim2.new(0, 25, 0, 25)
    b.Position = UDim2.new(1, xPos, 0, 5)
    b.BackgroundColor3 = Color3.fromRGB(45, 45, 45)
    b.Text = text
    b.TextColor3 = Color3.new(1, 1, 1)
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
PListFrame.ScrollBarThickness = 4
Instance.new("UIListLayout", PListFrame).Padding = UDim.new(0, 2)
Instance.new("UICorner", PListFrame)

-- // TRACER DRAWING FUNCTION
local function createTracer(p)
    local line = Drawing.new("Line")
    line.Visible = false
    line.Color = Color3.new(1, 1, 1)
    line.Thickness = 1
    line.Transparency = 0.5
    getgenv().EliteTracers[p.Name] = line
end

-- // UNLIMITED ESP LOGIC
local function applyESP(p)
    if p == player then return end
    local folder = Instance.new("Folder", ScreenGui)
    folder.Name = "EliteESP_" .. p.Name
    local bill = Instance.new("BillboardGui", folder)
    bill.AlwaysOnTop = true
    bill.Size = UDim2.new(0, 100, 0, 50)
    bill.Name = "Tag"
    local name = Instance.new("TextLabel", bill)
    name.Text = p.Name
    name.Size = UDim2.new(1, 0, 1, 0)
    name.BackgroundTransparency = 1
    name.TextColor3 = Color3.new(1, 0, 0)
    name.TextStrokeTransparency = 0
    name.Font = Enum.Font.GothamBold
    name.TextSize = 10
    return folder
end

-- // CORE ENGINE LOOP
getgenv().AimConnection = RunService.RenderStepped:Connect(function()
    PListFrame.Position = Main.Position + UDim2.new(0, 0, 0, Main.AbsoluteSize.Y + 5)
    
    for _, p in pairs(Players:GetPlayers()) do
        if p ~= player then
            local esp = ScreenGui:FindFirstChild("EliteESP_" .. p.Name)
            local tracer = getgenv().EliteTracers[p.Name]
            
            if ESP_ENABLED then
                if not esp then esp = applyESP(p) end
                if not tracer then createTracer(p) tracer = getgenv().EliteTracers[p.Name] end
                
                if p.Character and p.Character:FindFirstChild("HumanoidRootPart") then
                    local root = p.Character.HumanoidRootPart
                    esp.Tag.Adornee = root
                    esp.Tag.Enabled = true
                    
                    -- Update Tracer Line
                    local screenPos, onScreen = camera:WorldToViewportPoint(root.Position)
                    if onScreen then
                        tracer.From = Vector2.new(camera.ViewportSize.X / 2, camera.ViewportSize.Y)
                        tracer.To = Vector2.new(screenPos.X, screenPos.Y)
                        tracer.Visible = true
                    else
                        tracer.Visible = false
                    end

                    -- Force Highlight (Restored Highlight Logic)
                    if not p.Character:FindFirstChild("EliteGlow") then
                        local h = Instance.new("Highlight", p.Character)
                        h.Name = "EliteGlow"
                        h.FillColor = Color3.new(1, 0, 0)
                    end
                else
                    if esp then esp.Tag.Enabled = false end
                    if tracer then tracer.Visible = false end
                end
            else
                if esp then esp:Destroy() end
                if tracer then tracer.Visible = false end
                if p.Character and p.Character:FindFirstChild("EliteGlow") then
                    p.Character.EliteGlow:Destroy()
                end
            end
        end
    end

    if AIM_ENABLED then
        local tPos, dist = nil, 15000 -- Extra range
        for _, p in pairs(Players:GetPlayers()) do
            if p ~= player and not WHITELISTED[p.Name] then
                local char = p.Character
                if char and char:FindFirstChild("HumanoidRootPart") and char.Humanoid.Health > 0 then
                    local part = (TARGET_TYPE == "Head" and char:FindFirstChild("Head")) or char.HumanoidRootPart
                    local d = (part.Position - player.Character.HumanoidRootPart.Position).Magnitude
                    if d < dist then tPos = part.Position dist = d end
                end
            end
        end
        if tPos then camera.CFrame = CFrame.lookAt(camera.CFrame.Position, tPos) end
    end
    
    if AUTO_SHOOT then
        local tool = player.Character and player.Character:FindFirstChildOfClass("Tool")
        if tool and tool:Activate() then end
    end
end)

-- // UI LIST REFRESH
local function refreshPList()
    for _, c in pairs(PListFrame:GetChildren()) do if c:IsA("TextButton") then c:Destroy() end end
    for _, p in pairs(Players:GetPlayers()) do
        if p ~= player then
            local b = makeBtn(p.Name, 0, WHITELISTED[p.Name] and Color3.new(0.6,0,0) or Color3.new(0.2,0.2,0.2))
            b.Parent = PListFrame
            b.MouseButton1Click:Connect(function()
                WHITELISTED[p.Name] = not WHITELISTED[p.Name]
                refreshPList()
            end)
        end
    end
    PListFrame.CanvasSize = UDim2.new(0, 0, 0, #Players:GetPlayers() * 32)
end

-- // UI CONNECTIONS
PListToggle.MouseButton1Click:Connect(function()
    PListFrame.Visible = not PListFrame.Visible
    if PListFrame.Visible then refreshPList() end
    PListFrame:TweenSize(PListFrame.Visible and UDim2.new(0, 200, 0, 150) or UDim2.new(0, 200, 0, 0), "Out", "Quad", 0.2, true)
end)

ESPBtn.MouseButton1Click:Connect(function()
    ESP_ENABLED = not ESP_ENABLED
    ESPBtn.Text = ESP_ENABLED and "UNLIMITED ESP: ON" or "UNLIMITED ESP: OFF"
    ESPBtn.BackgroundColor3 = ESP_ENABLED and Color3.new(0, 0.5, 1) or Color3.fromRGB(35, 35, 35)
end)

LockBtn.MouseButton1Click:Connect(function()
    AIM_ENABLED = not AIM_ENABLED
    LockBtn.Text = AIM_ENABLED and "SNAP LOCK: ON" or "SNAP LOCK: OFF"
    LockBtn.BackgroundColor3 = AIM_ENABLED and Color3.new(0.7, 0, 0) or Color3.fromRGB(35, 35, 35)
end)

ShootBtn.MouseButton1Click:Connect(function()
    AUTO_SHOOT = not AUTO_SHOOT
    ShootBtn.Text = AUTO_SHOOT and "FIRE: ON" or "FIRE: OFF"
    ShootBtn.BackgroundColor3 = AUTO_SHOOT and Color3.new(0, 0.6, 0) or Color3.fromRGB(35, 35, 35)
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
