-- // CLEANUP PREVIOUS
local UI_NAME = "EliteV9_Final"
if getgenv().AimConnection then getgenv().AimConnection:Disconnect() end
local player = game:GetService("Players").LocalPlayer
local oldUI = player:WaitForChild("PlayerGui"):FindFirstChild(UI_NAME)
if oldUI then oldUI:Destroy() end

-- // SETTINGS
local AIM_ENABLED = false
local AUTO_SHOOT = false 
local TARGET_TYPE = "Head"
local WHITELISTED = {}
local IS_MINIMIZED = false

-- // UI SETUP
local ScreenGui = Instance.new("ScreenGui", player:WaitForChild("PlayerGui"))
ScreenGui.Name = UI_NAME
ScreenGui.ResetOnSpawn = false

local Main = Instance.new("Frame", ScreenGui)
Main.Size = UDim2.new(0, 200, 0, 320)
Main.Position = UDim2.new(0.05, 0, 0.3, 0)
Main.BackgroundColor3 = Color3.fromRGB(15, 15, 15)
Main.Active = true
Main.Draggable = true
Instance.new("UICorner", Main)

-- TITLE BAR
local Title = Instance.new("TextLabel", Main)
Title.Size = UDim2.new(1, -65, 0, 35)
Title.Text = "  ELITE V9 MASTER"
Title.TextColor3 = Color3.new(1, 1, 1)
Title.Font = Enum.Font.GothamBold
Title.TextSize = 13
Title.BackgroundTransparency = 1
Title.TextXAlignment = Enum.TextXAlignment.Left

-- CONTENT CONTAINER
local Content = Instance.new("Frame", Main)
Content.Size = UDim2.new(1, 0, 1, -35)
Content.Position = UDim2.new(0, 0, 0, 35)
Content.BackgroundTransparency = 1

local function makeBtn(txt, y, color)
    local b = Instance.new("TextButton", Content)
    b.Size = UDim2.new(0, 180, 0, 38)
    b.Position = UDim2.new(0, 10, 0, y)
    b.BackgroundColor3 = color
    b.Text = txt
    b.TextColor3 = Color3.new(1, 1, 1)
    b.Font = Enum.Font.GothamBold
    b.TextSize = 11
    Instance.new("UICorner", b).CornerRadius = UDim.new(0, 6)
    return b
end

local LockBtn = makeBtn("SNAP LOCK: OFF", 5, Color3.fromRGB(35, 35, 35))
local ShootBtn = makeBtn("AUTO FIRE: OFF", 48, Color3.fromRGB(35, 35, 35))
local HeadBtn = makeBtn("TARGET: FOREHEAD", 115, Color3.fromRGB(180, 0, 0))
local ChestBtn = makeBtn("TARGET: CHEST", 160, Color3.fromRGB(35, 35, 35))
local LegBtn = makeBtn("TARGET: LEGS", 205, Color3.fromRGB(35, 35, 35))

-- TOP CONTROLS
local MinBtn = Instance.new("TextButton", Main)
MinBtn.Size = UDim2.new(0, 25, 0, 25)
MinBtn.Position = UDim2.new(1, -30, 0, 5)
MinBtn.Text = "-"
MinBtn.BackgroundColor3 = Color3.fromRGB(45,45,45)
MinBtn.TextColor3 = Color3.new(1,1,1)
Instance.new("UICorner", MinBtn)

local PListToggle = Instance.new("TextButton", Main)
PListToggle.Size = UDim2.new(0, 25, 0, 25)
PListToggle.Position = UDim2.new(1, -60, 0, 5)
PListToggle.Text = "👥"
PListToggle.BackgroundColor3 = Color3.fromRGB(45,45,45)
PListToggle.TextColor3 = Color3.new(1,1,1)
Instance.new("UICorner", PListToggle)

-- PLAYER LIST FRAME (COLLAPSIBLE)
local PListFrame = Instance.new("ScrollingFrame", Main)
PListFrame.Size = UDim2.new(1, 0, 0, 0) -- Hidden by default
PListFrame.Position = UDim2.new(0, 0, 1, 5)
PListFrame.BackgroundColor3 = Color3.fromRGB(20, 20, 20)
PListFrame.Visible = false
PListFrame.BorderSizePixel = 0
PListFrame.ScrollBarThickness = 3
local UIList = Instance.new("UIListLayout", PListFrame)
UIList.Padding = UDim.new(0, 2)
Instance.new("UICorner", PListFrame)

-- // PLAYER LIST UPDATE
local function UpdateList()
    for _, child in pairs(PListFrame:GetChildren()) do
        if child:IsA("TextButton") then child:Destroy() end
    end
    for _, p in pairs(game:GetService("Players"):GetPlayers()) do
        if p ~= player then
            local b = Instance.new("TextButton", PListFrame)
            b.Size = UDim2.new(1, -10, 0, 30)
            b.BackgroundColor3 = WHITELISTED[p.Name] and Color3.fromRGB(150, 0, 0) or Color3.fromRGB(40, 40, 40)
            b.Text = WHITELISTED[p.Name] and p.Name .. " (IGNORED)" or p.Name
            b.TextColor3 = Color3.new(1,1,1)
            b.Font = Enum.Font.Gotham
            b.TextSize = 10
            Instance.new("UICorner", b)
            
            b.MouseButton1Click:Connect(function()
                WHITELISTED[p.Name] = not WHITELISTED[p.Name]
                b.BackgroundColor3 = WHITELISTED[p.Name] and Color3.fromRGB(150, 0, 0) or Color3.fromRGB(40, 40, 40)
                b.Text = WHITELISTED[p.Name] and p.Name .. " (IGNORED)" or p.Name
            end)
        end
    end
    PListFrame.CanvasSize = UDim2.new(0, 0, 0, #PListFrame:GetChildren() * 32)
end

-- // CORE ENGINE
getgenv().AimConnection = game:GetService("RunService").RenderStepped:Connect(function()
    if AIM_ENABLED then
        local tPos, dist = nil, 2000
        for _, p in pairs(game:GetService("Players"):GetPlayers()) do
            if p ~= player and not WHITELISTED[p.Name] and (not player.Team or p.Team ~= player.Team) then
                if p.Character and p.Character:FindFirstChild("Humanoid") and p.Character.Humanoid.Health > 0 then
                    local part = (TARGET_TYPE == "Head" and p.Character:FindFirstChild("Head")) or 
                                 (TARGET_TYPE == "Chest" and (p.Character:FindFirstChild("UpperTorso") or p.Character:FindFirstChild("Torso"))) or 
                                 (p.Character:FindFirstChild("LeftFoot") or p.Character:FindFirstChild("LowerTorso"))
                    
                    if part then
                        local finalPos = (TARGET_TYPE == "Head") and part.Position + Vector3.new(0, 0.28, 0) or part.Position
                        local d = (finalPos - workspace.CurrentCamera.CFrame.Position).Magnitude
                        if d < dist then tPos = finalPos dist = d end
                    end
                end
            end
        end
        if tPos then workspace.CurrentCamera.CFrame = CFrame.lookAt(workspace.CurrentCamera.CFrame.Position, tPos) end
    end
    if AUTO_SHOOT then
        local tool = player.Character and player.Character:FindFirstChildOfClass("Tool")
        if tool then tool:Activate() end
    end
end)

-- // BUTTON CONNECTIONS
MinBtn.MouseButton1Click:Connect(function()
    IS_MINIMIZED = not IS_MINIMIZED
    Content.Visible = not IS_MINIMIZED
    MinBtn.Text = IS_MINIMIZED and "+" or "-"
    Main:TweenSize(IS_MINIMIZED and UDim2.new(0, 200, 0, 35) or UDim2.new(0, 200, 0, 320), "Out", "Quad", 0.2, true)
    if IS_MINIMIZED then PListFrame.Visible = false end
end)

PListToggle.MouseButton1Click:Connect(function()
    if IS_MINIMIZED then return end
    PListFrame.Visible = not PListFrame.Visible
    if PListFrame.Visible then
        UpdateList()
        PListFrame:TweenSize(UDim2.new(1, 0, 0, 150), "Out", "Quad", 0.2, true)
    else
        PListFrame:TweenSize(UDim2.new(1, 0, 0, 0), "Out", "Quad", 0.2, true)
    end
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

local function setT(btn, t)
    TARGET_TYPE = t
    HeadBtn.BackgroundColor3, ChestBtn.BackgroundColor3, LegBtn.BackgroundColor3 = Color3.fromRGB(35,35,35), Color3.fromRGB(35,35,35), Color3.fromRGB(35,35,35)
    btn.BackgroundColor3 = Color3.fromRGB(180, 0, 0)
end
HeadBtn.MouseButton1Click:Connect(function() setT(HeadBtn, "Head") end)
ChestBtn.MouseButton1Click:Connect(function() setT(ChestBtn, "Chest") end)
LegBtn.MouseButton1Click:Connect(function() setT(LegBtn, "Legs") end)
