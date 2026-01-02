-- // CLEANUP & SAFETY
local UI_NAME = "EliteMasterV9_Stable"
if getgenv().AimConnection then getgenv().AimConnection:Disconnect() end

local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local player = Players.LocalPlayer
local camera = workspace.CurrentCamera

local oldUI = player:WaitForChild("PlayerGui"):FindFirstChild(UI_NAME)
if oldUI then oldUI:Destroy() end

-- // SETTINGS
local AIM_ENABLED = false
local AUTO_SHOOT = false 
local TARGET_TYPE = "Head"
local WHITELISTED = {}
local IS_MINIMIZED = false

-- // MAIN UI SETUP
local ScreenGui = Instance.new("ScreenGui", player:WaitForChild("PlayerGui"))
ScreenGui.Name = UI_NAME
ScreenGui.ResetOnSpawn = false

local Main = Instance.new("Frame", ScreenGui)
Main.Size = UDim2.new(0, 200, 0, 320)
Main.Position = UDim2.new(0.05, 0, 0.3, 0)
Main.BackgroundColor3 = Color3.fromRGB(15, 15, 15)
Main.BorderSizePixel = 0
Main.Active = true
Main.Draggable = true
Instance.new("UICorner", Main)

-- TITLE BAR
local Title = Instance.new("TextLabel", Main)
Title.Size = UDim2.new(1, -60, 0, 35)
Title.Text = "  ELITE V9 MASTER"
Title.TextColor3 = Color3.new(1, 1, 1)
Title.Font = Enum.Font.GothamBold
Title.TextSize = 13
Title.BackgroundTransparency = 1
Title.TextXAlignment = Enum.TextXAlignment.Left

-- TOP BUTTONS
local function createTopBtn(text, xPos)
    local b = Instance.new("TextButton", Main)
    b.Size = UDim2.new(0, 25, 0, 25)
    b.Position = UDim2.new(1, xPos, 0, 5)
    b.BackgroundColor3 = Color3.fromRGB(40, 40, 40)
    b.Text = text
    b.TextColor3 = Color3.new(1, 1, 1)
    Instance.new("UICorner", b)
    return b
end

local MinBtn = createTopBtn("-", -30)
local PListBtn = createTopBtn("👥", -60)

-- MAIN CONTENT
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

-- PLAYER LIST (COLLAPSIBLE)
local PList = Instance.new("ScrollingFrame", Main)
PList.Size = UDim2.new(1, 0, 0, 0) -- Starts at 0 height
PList.Position = UDim2.new(0, 0, 1, 5)
PList.Visible = false
PList.BackgroundColor3 = Color3.fromRGB(20, 20, 20)
PList.BorderSizePixel = 0
PList.ScrollBarThickness = 4
Instance.new("UIListLayout", PList).Padding = UDim.new(0, 2)
Instance.new("UICorner", PList)

-- // LOGIC FUNCTIONS
local function getTargetPos(char)
    local p = nil
    if TARGET_TYPE == "Head" then
        p = char:FindFirstChild("Head")
        if p then return p.Position + Vector3.new(0, 0.28, 0) end
    elseif TARGET_TYPE == "Chest" then
        p = char:FindFirstChild("UpperTorso") or char:FindFirstChild("Torso")
    else
        p = char:FindFirstChild("LeftFoot") or char:FindFirstChild("LowerTorso")
    end
    return p and p.Position or nil
end

local function isVisible(pos, char)
    local ray = RaycastParams.new()
    ray.FilterType = Enum.RaycastFilterType.Exclude
    ray.FilterDescendantsInstances = {player.Character, char}
    local hit = workspace:Raycast(camera.CFrame.Position, (pos - camera.CFrame.Position), ray)
    return hit == nil
end

-- // MAIN SNAP LOOP
getgenv().AimConnection = RunService.RenderStepped:Connect(function()
    if AIM_ENABLED then
        local tPos, dist = nil, 2000
        for _, p in pairs(Players:GetPlayers()) do
            if p ~= player and not WHITELISTED[p.Name] and (not player.Team or p.Team ~= player.Team) then
                local char = p.Character
                if char and char:FindFirstChild("Humanoid") and char.Humanoid.Health > 0 then
                    local pos = getTargetPos(char)
                    if pos and isVisible(pos, char) then
                        local d = (pos - camera.CFrame.Position).Magnitude
                        if d < dist then tPos = pos dist = d end
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

-- // UI INTERACTION LOGIC
MinBtn.MouseButton1Click:Connect(function()
    IS_MINIMIZED = not IS_MINIMIZED
    Content.Visible = not IS_MINIMIZED
    MinBtn.Text = IS_MINIMIZED and "+" or "-"
    Main:TweenSize(IS_MINIMIZED and UDim2.new(0, 200, 0, 35) or UDim2.new(0, 200, 0, 320), "Out", "Quad", 0.2, true)
end)

PListBtn.MouseButton1Click:Connect(function()
    PList.Visible = not PList.Visible
    if PList.Visible then
        PList:TweenSize(UDim2.new(1, 0, 0, 150), "Out", "Quad", 0.2, true)
        for _, c in pairs(PList:GetChildren()) do if c:IsA("TextButton") then c:Destroy() end end
        for _, p in pairs(Players:GetPlayers()) do
            if p ~= player then
                local b = Instance.new("TextButton", PList)
                b.Size = UDim2.new(1, -10, 0, 30)
                b.Text = p.Name
                b.BackgroundColor3 = WHITELISTED[p.Name] and Color3.fromRGB(150, 0, 0) or Color3.fromRGB(40, 40, 40)
                b.TextColor3 = Color3.new(1, 1, 1)
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
    else
        PList:TweenSize(UDim2.new(1, 0, 0, 0), "Out", "Quad", 0.2, true)
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

local function setPart(btn, t)
    TARGET_TYPE = t
    HeadBtn.BackgroundColor3, ChestBtn.BackgroundColor3, LegBtn.BackgroundColor3 = Color3.fromRGB(35,35,35), Color3.fromRGB(35,35,35), Color3.fromRGB(35,35,35)
    btn.BackgroundColor3 = Color3.fromRGB(180, 0, 0)
end

HeadBtn.MouseButton1Click:Connect(function() setPart(HeadBtn, "Head") end)
ChestBtn.MouseButton1Click:Connect(function() setPart(ChestBtn, "Chest") end)
LegBtn.MouseButton1Click:Connect(function() setPart(LegBtn, "Legs") end)
