-- // FORCE CLEAR ALL PREVIOUS VERSIONS
local VERSION_TAG = "ELITE_V28_ULTIMATE_RESTORE"
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local player = Players.LocalPlayer
local camera = workspace.CurrentCamera

-- Global Clean-up for Tracers and UI
if getgenv().AimConnection then getgenv().AimConnection:Disconnect() end
if getgenv().EliteTracers then 
    for _, v in pairs(getgenv().EliteTracers) do v:Remove() end 
end
getgenv().EliteTracers = {}

for _, oldUI in pairs(player:WaitForChild("PlayerGui"):GetChildren()) do
    if oldUI.Name:find("Elite") or oldUI.Name:find("AIMBOT") then
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
Title.Text = "  ELITE V28 | FULL"
Title.TextColor3 = Color3.fromRGB(0, 255, 150)
Title.Font = Enum.Font.GothamBold
Title.TextSize = 12
Title.BackgroundTransparency = 1
Title.TextXAlignment = Enum.TextXAlignment.Left

-- Dynamic Title Update (Line Restore)
spawn(function()
    while task.wait(1) do
        local plrs = Players:GetPlayers()
        Title.Text = "  V28 | PLRS: " .. tostring(#plrs)
    end
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

-- MAIN BUTTONS
local LockBtn = makeBtn("SNAP LOCK: OFF", 5, Color3.fromRGB(35, 35, 35))
local ESPBtn = makeBtn("FULL VISUALS: OFF", 45, Color3.fromRGB(35, 35, 35))
local ShootBtn = makeBtn("AUTO FIRE: OFF", 85, Color3.fromRGB(35, 35, 35))
local HeadBtn = makeBtn("TARGET: HEAD", 155, Color3.fromRGB(180, 0, 0))
local ChestBtn = makeBtn("TARGET: CHEST", 195, Color3.fromRGB(35, 35, 35))
local LegBtn = makeBtn("TARGET: LEGS", 235, Color3.fromRGB(35, 35, 35))

-- TOP CONTROL BUTTONS
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

-- PLAYER LIST FRAME
local PListFrame = Instance.new("ScrollingFrame", ScreenGui)
PListFrame.Size = UDim2.new(0, 200, 0, 0)
PListFrame.Visible = false
PListFrame.BackgroundColor3 = Color3.fromRGB(20, 20, 20)
PListFrame.ZIndex = 20
PListFrame.ScrollBarThickness = 4
local UIList = Instance.new("UIListLayout", PListFrame)
UIList.Padding = UDim.new(0, 2)
Instance.new("UICorner", PListFrame)

-- // VISIBILITY & TRACER LOGIC
local function isVisible(part, char)
    local ray = RaycastParams.new()
    ray.FilterDescendantsInstances = {player.Character, char, camera}
    ray.FilterType = Enum.RaycastFilterType.Blacklist
    local result = workspace:Raycast(camera.CFrame.Position, (part.Position - camera.CFrame.Position).Unit * 5000, ray)
    return result == nil
end

local function applyVisuals(p)
    if p == player then return end
    local folder = Instance.new("Folder", ScreenGui)
    folder.Name = "EliteV28_" .. p.Name
    local bill = Instance.new("BillboardGui", folder)
    bill.AlwaysOnTop = true
    bill.Size = UDim2.new(0, 80, 0, 40)
    bill.Name = "Tag"
    local txt = Instance.new("TextLabel", bill)
    txt.Text = p.Name
    txt.Size = UDim2.new(1, 0, 1, 0)
    txt.TextColor3 = Color3.new(1, 1, 1)
    txt.BackgroundTransparency = 1
    txt.Font = Enum.Font.GothamBold
    txt.TextSize = 9
    return folder
end

-- // CORE ENGINE
getgenv().AimConnection = RunService.RenderStepped:Connect(function()
    PListFrame.Position = Main.Position + UDim2.new(0, 0, 0, Main.AbsoluteSize.Y + 5)
    
    for _, p in pairs(Players:GetPlayers()) do
        if p ~= player then
            local esp = ScreenGui:FindFirstChild("EliteV28_" .. p.Name)
            local tracer = getgenv().EliteTracers[p.Name]
            
            if ESP_ENABLED then
                if not esp then esp = applyVisuals(p) end
                if not tracer then
                    tracer = Drawing.new("Line")
                    tracer.Thickness = 1
                    getgenv().EliteTracers[p.Name] = tracer
                end
                
                if p.Character and p.Character:FindFirstChild("HumanoidRootPart") then
                    local root = p.Character.HumanoidRootPart
                    local screenPos, onScreen = camera:WorldToViewportPoint(root.Position)
                    esp.Tag.Adornee = root
                    esp.Tag.Enabled = true
                    
                    if onScreen then
                        tracer.From = Vector2.new(camera.ViewportSize.X / 2, camera.ViewportSize.Y)
                        tracer.To = Vector2.new(screenPos.X, screenPos.Y)
                        tracer.Visible = true
                        tracer.Color = isVisible(root, p.Character) and Color3.new(0,1,0) or Color3.new(1,0,0)
                    else tracer.Visible = false end
                else
                    if esp then esp.Tag.Enabled = false end
                    if tracer then tracer.Visible = false end
                end
            else
                if esp then esp:Destroy() end
                if tracer then tracer.Visible = false end
            end
        end
    end

    if AIM_ENABLED then
        local target, dist = nil, 2000
        for _, p in pairs(Players:GetPlayers()) do
            if p ~= player and not WHITELISTED[p.Name] and p.Character then
                local char = p.Character
                local part = (TARGET_TYPE == "Head" and char:FindFirstChild("Head")) or char:FindFirstChild("HumanoidRootPart")
                if part and char:FindFirstChild("Humanoid") and char.Humanoid.Health > 0 then
                    if isVisible(part, char) then
                        local d = (part.Position - camera.CFrame.Position).Magnitude
                        if d < dist then target = part.Position dist = d end
                    end
                end
            end
        end
        if target then camera.CFrame = CFrame.lookAt(camera.CFrame.Position, target) end
    end
end)

-- // PLAYER LIST UPDATE
local function updatePList()
    for _, v in pairs(PListFrame:GetChildren()) do if v:IsA("TextButton") then v:Destroy() end end
    for _, p in pairs(Players:GetPlayers()) do
        if p ~= player then
            local b = makeBtn(p.Name, 0, WHITELISTED[p.Name] and Color3.new(0.6,0,0) or Color3.new(0.2,0.2,0.2))
            b.Parent = PListFrame
            b.MouseButton1Click:Connect(function()
                WHITELISTED[p.Name] = not WHITELISTED[p.Name]
                updatePList()
            end)
        end
    end
    PListFrame.CanvasSize = UDim2.new(0, 0, 0, #Players:GetPlayers() * 32)
end

-- // CONNECTIONS
PListToggle.MouseButton1Click:Connect(function()
    PListFrame.Visible = not PListFrame.Visible
    if PListFrame.Visible then updatePList() end
    PListFrame:TweenSize(PListFrame.Visible and UDim2.new(0, 200, 0, 150) or UDim2.new(0, 200, 0, 0), "Out", "Quad", 0.2, true)
end)

LockBtn.MouseButton1Click:Connect(function()
    AIM_ENABLED = not AIM_ENABLED
    LockBtn.Text = AIM_ENABLED and "SNAP LOCK: ON" or "SNAP LOCK: OFF"
    LockBtn.BackgroundColor3 = AIM_ENABLED and Color3.new(0.7,0,0) or Color3.fromRGB(35,35,35)
end)

ESPBtn.MouseButton1Click:Connect(function()
    ESP_ENABLED = not ESP_ENABLED
    ESPBtn.Text = ESP_ENABLED and "FULL VISUALS: ON" or "FULL VISUALS: OFF"
    ESPBtn.BackgroundColor3 = ESP_ENABLED and Color3.new(0,0.5,1) or Color3.fromRGB(35,35,35)
end)

MinBtn.MouseButton1Click:Connect(function()
    IS_MINIMIZED = not IS_MINIMIZED
    Content.Visible = not IS_MINIMIZED
    Main:TweenSize(IS_MINIMIZED and UDim2.new(0, 200, 0, 35) or UDim2.new(0, 200, 0, 360), "Out", "Quad", 0.2, true)
end)

local function setT(btn, t)
    TARGET_TYPE = t
    HeadBtn.BackgroundColor3, ChestBtn.BackgroundColor3, LegBtn.BackgroundColor3 = Color3.fromRGB(35,35,35), Color3.fromRGB(35,35,35), Color3.fromRGB(35,35,35)
    btn.BackgroundColor3 = Color3.fromRGB(180, 0, 0)
end
HeadBtn.MouseButton1Click:Connect(function() setT(HeadBtn, "Head") end)
ChestBtn.MouseButton1Click:Connect(function() setT(ChestBtn, "Chest") end)
LegBtn.MouseButton1Click:Connect(function() setT(LegBtn, "Legs") end)
