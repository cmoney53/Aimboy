-- // CLEANUP PREVIOUS EXECUTION
local UI_NAME = "EliteMasterSuite_V9"
if getgenv().AimConnection then getgenv().AimConnection:Disconnect() end

local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local player = Players.LocalPlayer
local camera = workspace.CurrentCamera

local oldUI = player:WaitForChild("PlayerGui"):FindFirstChild(UI_NAME)
if oldUI then oldUI:Destroy() end

-- // SETTINGS & TABLES
local AIM_ENABLED = false
local AUTO_SHOOT = false 
local TARGET_TYPE = "Head"
local WHITELISTED_PLAYERS = {} -- Players to NOT lock onto

-- // UI SETUP
local ScreenGui = Instance.new("ScreenGui", player:WaitForChild("PlayerGui"))
ScreenGui.Name = UI_NAME
ScreenGui.ResetOnSpawn = false

-- Main Container
local MainFrame = Instance.new("Frame", ScreenGui)
MainFrame.Size = UDim2.new(0, 200, 0, 320)
MainFrame.Position = UDim2.new(0.05, 0, 0.3, 0)
MainFrame.BackgroundColor3 = Color3.fromRGB(15, 15, 15)
MainFrame.Active = true
MainFrame.Draggable = true
Instance.new("UICorner", MainFrame)

-- Title Bar
local Title = Instance.new("TextLabel", MainFrame)
Title.Size = UDim2.new(1, -60, 0, 30)
Title.Text = "  ELITE V9 MASTER"
Title.TextColor3 = Color3.new(1, 1, 1)
Title.Font = Enum.Font.GothamBold
Title.TextSize = 13
Title.BackgroundTransparency = 1
Title.TextXAlignment = Enum.TextXAlignment.Left

-- Minimize/Expand Button
local MinBtn = createMinBtn(MainFrame)

-- PLAYER LIST TOGGLE
local PlayerListBtn = Instance.new("TextButton", MainFrame)
PlayerListBtn.Size = UDim2.new(0, 25, 0, 25)
PlayerListBtn.Position = UDim2.new(1, -58, 0, 3)
PlayerListBtn.Text = "👥"
PlayerListBtn.BackgroundColor3 = Color3.fromRGB(40, 40, 40)
PlayerListBtn.TextColor3 = Color3.new(1,1,1)
Instance.new("UICorner", PlayerListBtn)

-- Scrolling Player List (Collapsible)
local PListFrame = Instance.new("ScrollingFrame", MainFrame)
PListFrame.Size = UDim2.new(1, -10, 0, 0) -- Starts collapsed
PListFrame.Position = UDim2.new(0, 5, 1, 5)
PListFrame.BackgroundColor3 = Color3.fromRGB(20, 20, 20)
PListFrame.Visible = false
PListFrame.CanvasSize = UDim2.new(0,0,0,0)
PListFrame.ScrollBarThickness = 4
Instance.new("UIListLayout", PListFrame).Padding = UDim.new(0, 2)
Instance.new("UICorner", PListFrame)

-- Main Content Area
local Content = Instance.new("Frame", MainFrame)
Content.Size = UDim2.new(1, 0, 1, -30)
Content.Position = UDim2.new(0, 0, 0, 30)
Content.BackgroundTransparency = 1

local function createBtn(text, pos, color, parent)
    local btn = Instance.new("TextButton", parent or Content)
    btn.Size = UDim2.new(0, 180, 0, 35)
    btn.Position = pos
    btn.BackgroundColor3 = color
    btn.Text = text
    btn.TextColor3 = Color3.new(1, 1, 1)
    btn.Font = Enum.Font.GothamBold
    btn.TextSize = 11
    Instance.new("UICorner", btn)
    return btn
end

-- Controls
local LockBtn = createBtn("SNAP LOCK: OFF", UDim2.new(0, 10, 0, 5), Color3.fromRGB(35, 35, 35))
local ShootBtn = createBtn("AUTO FIRE: OFF", UDim2.new(0, 10, 0, 45), Color3.fromRGB(35, 35, 35))
local HeadBtn = createBtn("TARGET: FOREHEAD", UDim2.new(0, 10, 0, 100), Color3.fromRGB(150, 0, 0))
local ChestBtn = createBtn("TARGET: CHEST", UDim2.new(0, 10, 0, 140), Color3.fromRGB(35, 35, 35))
local LegBtn = createBtn("TARGET: LEGS", UDim2.new(0, 10, 0, 180), Color3.fromRGB(35, 35, 35))

-- // PLAYER LIST REFRESH
local function updatePlayerList()
    for _, child in pairs(PListFrame:GetChildren()) do
        if child:IsA("TextButton") then child:Destroy() end
    end
    for _, p in pairs(Players:GetPlayers()) do
        if p ~= player then
            local pBtn = Instance.new("TextButton", PListFrame)
            pBtn.Size = UDim2.new(1, -10, 0, 25)
            pBtn.Text = p.Name
            pBtn.BackgroundColor3 = WHITELISTED_PLAYERS[p.Name] and Color3.fromRGB(100, 30, 30) or Color3.fromRGB(40, 40, 40)
            pBtn.TextColor3 = Color3.new(1,1,1)
            pBtn.Font = Enum.Font.Gotham
            pBtn.TextSize = 10
            Instance.new("UICorner", pBtn)
            
            pBtn.MouseButton1Click:Connect(function()
                WHITELISTED_PLAYERS[p.Name] = not WHITELISTED_PLAYERS[p.Name]
                pBtn.BackgroundColor3 = WHITELISTED_PLAYERS[p.Name] and Color3.fromRGB(100, 30, 30) or Color3.fromRGB(40, 40, 40)
                pBtn.Text = WHITELISTED_PLAYERS[p.Name] and p.Name .. " (IGNORED)" or p.Name
            end)
        end
    end
    PListFrame.CanvasSize = UDim2.new(0,0,0, #Players:GetPlayers() * 27)
end

-- // UI TOGGLES
PlayerListBtn.MouseButton1Click:Connect(function()
    local isOpening = not PListFrame.Visible
    if isOpening then updatePlayerList() end
    PListFrame.Visible = isOpening
    PListFrame:TweenSize(isOpening and UDim2.new(1, -10, 0, 150) or UDim2.new(1, -10, 0, 0), "Out", "Quad", 0.2, true)
end)

-- // TARGET LOGIC
local function getTargetPosition(char)
    local pos = nil
    if TARGET_TYPE == "Head" then
        local head = char:FindFirstChild("Head")
        if head then pos = head.Position + Vector3.new(0, 0.28, 0) end
    elseif TARGET_TYPE == "Chest" then
        local chest = char:FindFirstChild("UpperTorso") or char:FindFirstChild("Torso")
        if chest then pos = chest.Position end
    elseif TARGET_TYPE == "Legs" then
        local leg = char:FindFirstChild("LeftFoot") or char:FindFirstChild("RightFoot") or char:FindFirstChild("LowerTorso")
        if leg then pos = leg.Position end
    end
    -- Visibility Check
    if pos then
        local ray = RaycastParams.new()
        ray.FilterType = Enum.RaycastFilterType.Exclude
        ray.FilterDescendantsInstances = {player.Character, char}
        local hit = workspace:Raycast(camera.CFrame.Position, (pos - camera.CFrame.Position), ray)
        if hit then return nil end
    end
    return pos
end

-- // MAIN ENGINE
getgenv().AimConnection = RunService.RenderStepped:Connect(function()
    if AIM_ENABLED then
        local closestPos, dist = nil, 2000
        for _, p in pairs(Players:GetPlayers()) do
            -- Checks if player is NOT in Whitelist and is Enemy
            if p ~= player and not WHITELISTED_PLAYERS[p.Name] and (not player.Team or p.Team ~= player.Team) then
                local char = p.Character
                if char and char:FindFirstChild("Humanoid") and char.Humanoid.Health > 0 then
                    local pos = getTargetPosition(char)
                    if pos then
                        local d = (pos - camera.CFrame.Position).Magnitude
                        if d < dist then closestPos = pos dist = d end
                    end
                end
            end
        end
        if closestPos then camera.CFrame = CFrame.lookAt(camera.CFrame.Position, closestPos) end
    end
    if AUTO_SHOOT then
        local tool = player.Character and player.Character:FindFirstChildOfClass("Tool")
        if tool then tool:Activate() end
    end
end)

-- // BUTTONS SETUP
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

local function updateSel(btn, type)
    TARGET_TYPE = type
    HeadBtn.BackgroundColor3 = Color3.fromRGB(35, 35, 35)
    ChestBtn.BackgroundColor3 = Color3.fromRGB(35, 35, 35)
    LegBtn.BackgroundColor3 = Color3.fromRGB(35, 35, 35)
    btn.BackgroundColor3 = Color3.fromRGB(150, 0, 0)
end
HeadBtn.MouseButton1Click:Connect(function() updateSel(HeadBtn, "Head") end)
ChestBtn.MouseButton1Click:Connect(function() updateSel(ChestBtn, "Chest") end)
LegBtn.MouseButton1Click:Connect(function() updateSel(LegBtn, "Legs") end)
