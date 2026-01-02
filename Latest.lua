-- // CLEANUP PREVIOUS
local UI_NAME = "EliteV9_ForceFix"
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

-- TITLE BAR (Always Visible)
local Title = Instance.new("TextLabel", Main)
Title.Size = UDim2.new(1, -60, 0, 35)
Title.Text = "  cmoney test"
Title.TextColor3 = Color3.new(1, 1, 1)
Title.Font = Enum.Font.GothamBold
Title.TextSize = 13
Title.BackgroundTransparency = 1
Title.TextXAlignment = Enum.TextXAlignment.Left

-- CONTENT CONTAINER (Where the buttons live)
local Content = Instance.new("Frame", Main)
Content.Name = "Container"
Content.Size = UDim2.new(1, 0, 1, -35)
Content.Position = UDim2.new(0, 0, 0, 35)
Content.BackgroundTransparency = 1
Content.Visible = true -- Forced visible

-- BUTTON CREATOR FUNCTION
local function makeBtn(txt, y, color)
    local b = Instance.new("TextButton", Content)
    b.Size = UDim2.new(0, 180, 0, 38)
    b.Position = UDim2.new(0, 10, 0, y)
    b.BackgroundColor3 = color
    b.Text = txt
    b.TextColor3 = Color3.new(1, 1, 1)
    b.Font = Enum.Font.GothamBold
    b.TextSize = 11
    b.ZIndex = 5
    Instance.new("UICorner", b)
    return b
end

-- RENDER BUTTONS
local LockBtn = makeBtn("SNAP LOCK: OFF", 5, Color3.fromRGB(35, 35, 35))
local ShootBtn = makeBtn("AUTO FIRE: OFF", 48, Color3.fromRGB(35, 35, 35))
local HeadBtn = makeBtn("TARGET: FOREHEAD", 115, Color3.fromRGB(180, 0, 0))
local ChestBtn = makeBtn("TARGET: CHEST", 160, Color3.fromRGB(35, 35, 35))
local LegBtn = makeBtn("TARGET: LEGS", 205, Color3.fromRGB(35, 35, 35))

-- TOP BAR CONTROLS
local MinBtn = Instance.new("TextButton", Main)
MinBtn.Size = UDim2.new(0, 25, 0, 25)
MinBtn.Position = UDim2.new(1, -30, 0, 5)
MinBtn.Text = "-"
MinBtn.BackgroundColor3 = Color3.fromRGB(40,40,40)
MinBtn.TextColor3 = Color3.new(1,1,1)
Instance.new("UICorner", MinBtn)

-- LOGIC FUNCTIONS
local function getTargetPos(char)
    local p = (TARGET_TYPE == "Head" and char:FindFirstChild("Head")) or 
              (TARGET_TYPE == "Chest" and (char:FindFirstChild("UpperTorso") or char:FindFirstChild("Torso"))) or 
              (char:FindFirstChild("LeftFoot") or char:FindFirstChild("LowerTorso"))
    
    if p and TARGET_TYPE == "Head" then return p.Position + Vector3.new(0, 0.28, 0) end
    return p and p.Position or nil
end

-- MAIN LOOP
getgenv().AimConnection = game:GetService("RunService").RenderStepped:Connect(function()
    if AIM_ENABLED then
        local tPos, dist = nil, 2000
        for _, p in pairs(game:GetService("Players"):GetPlayers()) do
            if p ~= player and not WHITELISTED[p.Name] and (not player.Team or p.Team ~= player.Team) then
                local char = p.Character
                if char and char:FindFirstChild("Humanoid") and char.Humanoid.Health > 0 then
                    local pos = getTargetPos(char)
                    if pos then
                        local d = (pos - workspace.CurrentCamera.CFrame.Position).Magnitude
                        if d < dist then tPos = pos dist = d end
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

-- UI ACTIONS
MinBtn.MouseButton1Click:Connect(function()
    IS_MINIMIZED = not IS_MINIMIZED
    Content.Visible = not IS_MINIMIZED
    MinBtn.Text = IS_MINIMIZED and "+" or "-"
    Main:TweenSize(IS_MINIMIZED and UDim2.new(0, 200, 0, 35) or UDim2.new(0, 200, 0, 320), "Out", "Quad", 0.2, true)
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
