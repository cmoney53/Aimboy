-- // HARD CLEANUP
local UI_NAME = "Elite_V18_Refresh"
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local player = Players.LocalPlayer
local camera = workspace.CurrentCamera

if getgenv().AimConnection then getgenv().AimConnection:Disconnect() end
for _, old in pairs(player:WaitForChild("PlayerGui"):GetChildren()) do
    if old.Name:find("Elite") or old.Name:find("AIMBOT") then old:Destroy() end
end

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
ScreenGui.ZIndexBehavior = Enum.ZIndexBehavior.Global

local Main = Instance.new("Frame", ScreenGui)
Main.Size = UDim2.new(0, 200, 0, 320)
Main.Position = UDim2.new(0.05, 0, 0.3, 0)
Main.BackgroundColor3 = Color3.fromRGB(15, 15, 15)
Main.Active = true
Main.Draggable = true
Instance.new("UICorner", Main)

local Title = Instance.new("TextLabel", Main)
Title.Size = UDim2.new(1, -65, 0, 35)
Title.Text = "  ELITE MASTER V18"
Title.TextColor3 = Color3.new(1, 1, 1)
Title.Font = Enum.Font.GothamBold
Title.TextSize = 13
Title.BackgroundTransparency = 1
Title.TextXAlignment = Enum.TextXAlignment.Left

-- CONTENT
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
    Instance.new("UICorner", b)
    return b
end

local LockBtn = makeBtn("SNAP LOCK: OFF", 5, Color3.fromRGB(35, 35, 35))
local ShootBtn = makeBtn("AUTO FIRE: OFF", 48, Color3.fromRGB(35, 35, 35))
local HeadBtn = makeBtn("TARGET: FOREHEAD", 115, Color3.fromRGB(180, 0, 0))
local ChestBtn = makeBtn("TARGET: CHEST", 160, Color3.fromRGB(35, 35, 35))
local LegBtn = makeBtn("TARGET: LEGS", 205, Color3.fromRGB(35, 35, 35))

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
PListFrame.BackgroundColor3 = Color3.fromRGB(20, 20, 20)
PListFrame.BorderSizePixel = 0
PListFrame.ScrollBarThickness = 4
PListFrame.ZIndex = 10
Instance.new("UIListLayout", PListFrame).Padding = UDim.new(0, 2)
Instance.new("UICorner", PListFrame)

RunService.Heartbeat:Connect(function()
    PListFrame.Position = Main.Position + UDim2.new(0, 0, 0, Main.AbsoluteSize.Y + 5)
end)

-- // WALL CHECK
local function isVisible(targetPos, targetChar)
    local origin = camera.CFrame.Position
    local direction = (targetPos - origin).Unit * (targetPos - origin).Magnitude
    local raycastParams = RaycastParams.new()
    raycastParams.FilterType = Enum.RaycastFilterType.Blacklist
    raycastParams.FilterDescendantsInstances = {player.Character, targetChar}
    raycastParams.IgnoreWater = true
    local result = workspace:Raycast(origin, direction, raycastParams)
    return result == nil
end

-- // CORE ENGINE
getgenv().AimConnection = RunService.RenderStepped:Connect(function()
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
                        if isVisible(finalPos, char) then
                            local d = (finalPos - player.Character.HumanoidRootPart.Position).Magnitude
                            if d < dist then tPos = finalPos dist = d end
                        end
                    end
                end
            end
        end
        if tPos then camera.CFrame = CFrame.lookAt(camera.CFrame.Position, tPos) end
    end
    if AUTO_SHOOT then
        local tool = player.Character and player.Character:FindFirstChildOfClass("Tool")
        if tool then tool:Activate() end
    end
end)

-- // REFRESH PLAYER LIST FUNCTION
local function refreshList()
    for _, child in pairs(PListFrame:GetChildren()) do
        if child:IsA("TextButton") then child:Destroy() end
    end
    for _, p in pairs(Players:GetPlayers()) do
        if p ~= player then
            local b = Instance.new("TextButton", PListFrame)
            b.Size = UDim2.new(1, -10, 0, 30)
            b.BackgroundColor3 = WHITELISTED[p.Name] and Color3.fromRGB(150, 0, 0) or Color3.fromRGB(40, 40, 40)
            b.Text = WHITELISTED[p.Name] and p.Name .. " (WL)" or p.Name
            b.TextColor3 = Color3.new(1, 1, 1)
            b.Font = Enum.Font.Gotham
            b.ZIndex = 11
            b.MouseButton1Click:Connect(function()
                WHITELISTED[p.Name] = not WHITELISTED[p.Name]
                b.BackgroundColor3 = WHITELISTED[p.Name] and Color3.fromRGB(150, 0, 0) or Color3.fromRGB(40, 40, 40)
                b.Text = WHITELISTED[p.Name] and p.Name .. " (WL)" or p.Name
            end)
            Instance.new("UICorner", b)
        end
    end
end

-- // UI CONNECTIONS
PListToggle.MouseButton1Click:Connect(function()
    PListFrame.Visible = not PListFrame.Visible
    if PListFrame.Visible then
        refreshList()
        PListFrame:TweenSize(UDim2.new(0, 200, 0, 150), "Out", "Quad", 0.2, true)
    else
        PListFrame:TweenSize(UDim2.new(0, 200, 0, 0), "Out", "Quad", 0.2, true)
    end
end)

MinBtn.MouseButton1Click:Connect(function()
    IS_MINIMIZED = not IS_MINIMIZED
    Content.Visible = not IS_MINIMIZED
    MinBtn.Text = IS_MINIMIZED and "+" or "-"
    Main:TweenSize(IS_MINIMIZED and UDim2.new(0, 200, 0, 35) or UDim2.new(0, 200, 0, 320), "Out", "Quad", 0.2, true)
    if IS_MINIMIZED then PListFrame.Visible = false end
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
