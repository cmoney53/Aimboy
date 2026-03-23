-- // SETTINGS & GLOBALS
local VERSION_TAG = "Cashmere_SkinThief_V2_Stable"
local Players = game:GetService("Players")
local LocalPlayer = Players.LocalPlayer
local PlayerGui = LocalPlayer:WaitForChild("PlayerGui")

-- Cleanup old versions
if PlayerGui:FindFirstChild(VERSION_TAG) then
    PlayerGui[VERSION_TAG]:Destroy()
end

-- // UI SETUP
local ScreenGui = Instance.new("ScreenGui", PlayerGui)
ScreenGui.Name = VERSION_TAG
ScreenGui.ResetOnSpawn = false
ScreenGui.ZIndexBehavior = Enum.ZIndexBehavior.Global

local Main = Instance.new("Frame", ScreenGui)
Main.Size = UDim2.new(0, 200, 0, 310) -- Adjusted to fit player list
Main.Position = UDim2.new(0.05, 0, 0.3, 0)
Main.BackgroundColor3 = Color3.fromRGB(15, 15, 15)
Main.Active = true
Main.Draggable = true
Instance.new("UICorner", Main)

-- Neon Green Stroke (Cashmere Style)
local Stroke = Instance.new("UIStroke", Main)
Stroke.Thickness = 2
Stroke.Color = Color3.fromRGB(0, 255, 150)

-- Header Title
local Title = Instance.new("TextLabel", Main)
Title.Size = UDim2.new(1, -65, 0, 35)
Title.Position = UDim2.new(0, 10, 0, 0)
Title.Text = "  Cashmere Skin Thief"
Title.TextColor3 = Color3.fromRGB(0, 255, 150)
Title.Font = Enum.Font.GothamBold
Title.TextSize = 12
Title.BackgroundTransparency = 1
Title.TextXAlignment = Enum.TextXAlignment.Left

-- // THE SKIN STEAL ENGINE
local function stealSkin(targetPlayer)
    local myChar = LocalPlayer.Character
    local targetChar = targetPlayer.Character
    
    if myChar and targetChar then
        -- 1. Wipe current appearance
        for _, item in pairs(myChar:GetChildren()) do
            if item:IsA("Accessory") or item:IsA("Shirt") or item:IsA("Pants") or item:IsA("BodyColors") or item:IsA("ShirtGraphic") then
                item:Destroy()
            end
        end
        
        -- 2. Deep Clone Clothing & Body Colors
        for _, item in pairs(targetChar:GetChildren()) do
            if item:IsA("Shirt") or item:IsA("Pants") or item:IsA("BodyColors") or item:IsA("ShirtGraphic") then
                item:Clone().Parent = myChar
            elseif item:IsA("Accessory") then
                -- 3. Clone Hats/Hair
                local clone = item:Clone()
                clone.Parent = myChar
            end
        end
        
        -- 4. Sync Face
        local tHead = targetChar:FindFirstChild("Head")
        local mHead = myChar:FindFirstChild("Head")
        if tHead and mHead and tHead:FindFirstChild("face") then
            if mHead:FindFirstChild("face") then mHead.face:Destroy() end
            tHead.face:Clone().Parent = mHead
        end
    end
end

-- // PLAYER LIST SETUP (From Cash V2)
local PListFrame = Instance.new("ScrollingFrame", Main)
PListFrame.Size = UDim2.new(1, -20, 0, 250)
PListFrame.Position = UDim2.new(0, 10, 0, 45)
PListFrame.BackgroundColor3 = Color3.fromRGB(20, 20, 20)
PListFrame.BorderSizePixel = 0
PListFrame.ScrollBarThickness = 2
PListFrame.ScrollBarImageColor3 = Color3.fromRGB(0, 255, 150)
PListFrame.CanvasSize = UDim2.new(0, 0, 0, 0)
Instance.new("UICorner", PListFrame)

local UIList = Instance.new("UIListLayout", PListFrame)
UIList.Padding = UDim.new(0, 5)
UIList.HorizontalAlignment = Enum.HorizontalAlignment.Center

-- // REFRESH FUNCTION
local function RefreshPlayerList()
    for _, c in pairs(PListFrame:GetChildren()) do 
        if c:IsA("TextButton") then c:Destroy() end 
    end
    
    local pCount = 0
    for _, p in pairs(Players:GetPlayers()) do
        if p ~= LocalPlayer then
            pCount = pCount + 1
            local b = Instance.new("TextButton", PListFrame)
            b.Size = UDim2.new(1, -10, 0, 30)
            b.BackgroundColor3 = Color3.fromRGB(35, 35, 35)
            -- Using DisplayName for Life Together compatibility
            b.Text = p.DisplayName or p.Name
            b.TextColor3 = Color3.new(1, 1, 1)
            b.Font = Enum.Font.Gotham
            b.TextSize = 10
            Instance.new("UICorner", b)
            
            -- Action: Steal Skin on Click
            b.MouseButton1Click:Connect(function()
                stealSkin(p)
                -- Visual Feedback
                local oldColor = b.BackgroundColor3
                b.BackgroundColor3 = Color3.fromRGB(0, 255, 150)
                b.TextColor3 = Color3.new(0, 0, 0)
                task.wait(0.2)
                b.BackgroundColor3 = oldColor
                b.TextColor3 = Color3.new(1, 1, 1)
            end)
        end
    end
    PListFrame.CanvasSize = UDim2.new(0, 0, 0, pCount * 35)
end

-- // MINIMIZE BUTTON
local MinBtn = Instance.new("TextButton", Main)
MinBtn.Size = UDim2.new(0, 25, 0, 25)
MinBtn.Position = UDim2.new(1, -30, 0, 5)
MinBtn.BackgroundColor3 = Color3.fromRGB(45, 45, 45)
MinBtn.Text = "-"
MinBtn.TextColor3 = Color3.new(1, 1, 1)
Instance.new("UICorner", MinBtn)

local isMinimized = false
MinBtn.MouseButton1Click:Connect(function()
    isMinimized = not isMinimized
    PListFrame.Visible = not isMinimized
    Main:TweenSize(isMinimized and UDim2.new(0, 200, 0, 35) or UDim2.new(0, 200, 0, 310), "Out", "Quad", 0.2, true)
    MinBtn.Text = isMinimized and "+" or "-"
end)

-- // INITIALIZE
RefreshPlayerList()
Players.PlayerAdded:Connect(RefreshPlayerList)
Players.PlayerRemoving:Connect(RefreshPlayerList)

print("Cashmere Skin Thief V2 Loaded Successfully.")
