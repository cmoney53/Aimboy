-- // CLEANUP
local UI_NAME = "EliteSuite_V10"
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

-- // MAIN UI
local ScreenGui = Instance.new("ScreenGui", player:WaitForChild("PlayerGui"))
ScreenGui.Name = UI_NAME
ScreenGui.ResetOnSpawn = false

local Main = Instance.new("Frame", ScreenGui)
Main.Size = UDim2.new(0, 200, 0, 320)
Main.Position = UDim2.new(0.05, 0, 0.3, 0)
Main.BackgroundColor3 = Color3.fromRGB(20, 20, 20)
Main.Active = true
Main.Draggable = true
Instance.new("UICorner", Main)

-- Top Bar
local Title = Instance.new("TextLabel", Main)
Title.Size = UDim2.new(1, -60, 0, 35)
Title.Text = "  ELITE MASTER V10"
Title.TextColor3 = Color3.new(1, 1, 1)
Title.Font = Enum.Font.GothamBold
Title.TextSize = 13
Title.BackgroundTransparency = 1
Title.TextXAlignment = Enum.TextXAlignment.Left

-- Buttons (Minimize & Player List)
local function createTopBtn(text, xOffset)
    local b = Instance.new("TextButton", Main)
    b.Size = UDim2.new(0, 25, 0, 25)
    b.Position = UDim2.new(1, xOffset, 0, 5)
    b.BackgroundColor3 = Color3.fromRGB(40, 40, 40)
    b.Text = text
    b.TextColor3 = Color3.new(1, 1, 1)
    Instance.new("UICorner", b)
    return b
end

local MinBtn = createTopBtn("-", -30)
local PListToggle = createTopBtn("👥", -60)

-- Container for all main buttons
local Content = Instance.new("Frame", Main)
Content.Size = UDim2.new(1, 0, 1, -35)
Content.Position = UDim2.new(0, 0, 0, 35)
Content.BackgroundTransparency = 1

-- Button Creator
local function makeBtn(txt, yPos, color)
    local b = Instance.new("TextButton", Content)
    b.Size = UDim2.new(0, 180, 0, 38)
    b.Position = UDim2.new(0, 10, 0, yPos)
    b.BackgroundColor3 = color
    b.Text = txt
    b.TextColor3 = Color3.new(1, 1, 1)
    b.Font = Enum.Font.GothamBold
    b.TextSize = 11
    Instance.new("UICorner", b)
    return b
end

local LockBtn = makeBtn("SNAP LOCK: OFF", 5, Color3.fromRGB(35, 35, 35))
local ShootBtn = makeBtn("AUTO FIRE: OFF", 50, Color3.fromRGB(35, 35, 35))
local HeadBtn = makeBtn("TARGET: FOREHEAD", 110, Color3.fromRGB(180, 0, 0))
local ChestBtn = makeBtn("TARGET: CHEST", 155, Color3.fromRGB(35, 35, 35))
local LegBtn = makeBtn("TARGET: LEGS", 200, Color3.fromRGB(35, 35, 35))

-- Player List Frame
local PList = Instance.new("ScrollingFrame", Main)
PList.Size = UDim2.new(1, 0, 0, 150)
PList.Position = UDim2.new(0, 0, 1, 5)
PList.Visible = false
PList.BackgroundColor3 = Color3.fromRGB(15, 15, 15)
PList.ScrollBarThickness = 4
Instance.new("UIListLayout", PList).Padding = UDim.new(0, 2)
Instance.new("UICorner", PList)

-- // FUNCTIONS
local function getTargetPos(char)
    local part = nil
    if TARGET_TYPE == "Head" then
        part = char:FindFirstChild("Head")
        if part then return part.Position + Vector3.new(0, 0.28, 0) end
    elseif TARGET_TYPE == "Chest" then
        part = char:FindFirstChild("UpperTorso") or char:FindFirstChild("Torso")
    else
        part = char:FindFirstChild("LeftFoot") or char:FindFirstChild("LowerTorso")
    end
    return part and part.Position or nil
end

local function isVisible(pos, char)
    local ray = RaycastParams.new()
    ray.FilterType = Enum.RaycastFilterType.Exclude
    ray.FilterDescendantsInstances = {player.Character, char}
    local hit = workspace:Raycast(workspace.CurrentCamera.CFrame.Position, (pos - workspace.CurrentCamera.CFrame.Position), ray)
    return hit == nil
end

-- // CORE LOOPS
getgenv().AimConnection = game:GetService("RunService").RenderStepped:Connect(function()
    if AIM_ENABLED then
        local targetPos, closeDist = nil, 2000
        for _, p in pairs(game:GetService("Players"):GetPlayers()) do
            if p ~= player and not WHITELISTED[p.Name] and (not player.Team or p.Team ~= player.Team) then
                if p.Character and p.Character:FindFirstChild("Humanoid") and p.Character.Humanoid.Health > 0 then
                    local pos = getTargetPos(p.Character)
                    if pos and isVisible(pos, p.Character) then
                        local d = (pos - workspace.CurrentCamera.CFrame.Position).Magnitude
                        if d < closeDist then targetPos = pos closeDist = d end
                    end
                end
            end
        end
        if targetPos then workspace.CurrentCamera.CFrame = CFrame.lookAt(workspace.CurrentCamera.CFrame.Position, targetPos) end
    end
    if AUTO_SHOOT then
        local tool = player.Character and player.Character:FindFirstChildOfClass("Tool")
        if tool then tool:Activate() end
    end
end)

-- // UI INTERACTIONS
MinBtn.MouseButton1Click:Connect(function()
    IS_MINIMIZED = not IS_MINIMIZED
    Content.Visible = not IS_MINIMIZED
    MinBtn.Text = IS_MINIMIZED and "+" or "-"
    Main:TweenSize(IS_MINIMIZED and UDim2.new(0, 200, 0, 35) or UDim2.new(0, 200, 0, 320), "Out", "Quad", 0.2, true)
end)

PListToggle.MouseButton1Click:Connect(function()
    PList.Visible = not PList.Visible
    if PList.Visible then
        for _, c in pairs(PList:GetChildren()) do if c:IsA("TextButton") then c:Destroy() end end
        for _, p in pairs(game:GetService("Players"):GetPlayers()) do
            if p ~= player then
                local b = Instance.new("TextButton", PList)
                b.Size = UDim2.new(1, -10, 0, 30)
                b.Text = p.Name
                b.BackgroundColor3 = WHITELISTED[p.Name] and Color3.fromRGB(150, 0, 0) or Color3.fromRGB(40, 40, 40)
                b.TextColor3 = Color3.new(1,1,1)
                b.MouseButton1Click:Connect(function()
                    WHITELISTED[p.Name] = not WHITELISTED[p.Name]
                    b.BackgroundColor3 = WHITELISTED[p.Name] and Color3.fromRGB(150, 0, 0) or Color3.fromRGB(40, 40, 40)
                end)
            end
        end
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
    btn.BackgroundColor3 = Color3.fromRGB(150, 0, 0)
end
HeadBtn.MouseButton1Click:Connect(function() setT(HeadBtn, "Head") end)
ChestBtn.MouseButton1Click:Connect(function() setT(ChestBtn, "Chest") end)
LegBtn.MouseButton1Click:Connect(function() setT(LegBtn, "Legs") end)
