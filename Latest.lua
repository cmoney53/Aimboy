local ScreenGui = Instance.new("ScreenGui")
local MainFrame = Instance.new("Frame")
local UICornerMain = Instance.new("UICorner")
local Title = Instance.new("TextLabel")
local ScrollingFrame = Instance.new("ScrollingFrame")
local ButtonLayout = Instance.new("UIListLayout")
local UIPadding = Instance.new("UIPadding")

-- Setup ScreenGui
ScreenGui.Parent = game.Players.LocalPlayer:WaitForChild("PlayerGui")
ScreenGui.ResetOnSpawn = false
ScreenGui.Name = "CashmereHub"

-- Main Window
MainFrame.Name = "MainFrame"
MainFrame.Parent = ScreenGui
MainFrame.BackgroundColor3 = Color3.fromRGB(20, 20, 20) -- Sleek dark background
MainFrame.Position = UDim2.new(0.5, -110, 0.5, -150)
MainFrame.Size = UDim2.new(0, 220, 0, 320)
MainFrame.Active = true
MainFrame.Draggable = true

UICornerMain.CornerRadius = UDim.new(0, 12)
UICornerMain.Parent = MainFrame

-- Title
Title.Parent = MainFrame
Title.Size = UDim2.new(1, 0, 0, 50)
Title.Text = "CASHMERE HUB"
Title.TextColor3 = Color3.fromRGB(0, 255, 120) -- Neon Green
Title.TextSize = 20
Title.Font = Enum.Font.GothamBold
Title.BackgroundTransparency = 1

-- Scrollable Area
ScrollingFrame.Parent = MainFrame
ScrollingFrame.Position = UDim2.new(0, 0, 0, 50)
ScrollingFrame.Size = UDim2.new(1, 0, 1, -60)
ScrollingFrame.BackgroundTransparency = 1
ScrollingFrame.ScrollBarThickness = 2
ScrollingFrame.CanvasSize = UDim2.new(0, 0, 2, 0)

ButtonLayout.Parent = ScrollingFrame
ButtonLayout.HorizontalAlignment = Enum.HorizontalAlignment.Center
ButtonLayout.Padding = UDim.new(0, 10)

UIPadding.Parent = ScrollingFrame
UIPadding.PaddingTop = UDim.new(0, 5)

-- Function to create Neon Buttons
local function CreateScriptButton(Name, URL)
    local Button = Instance.new("TextButton")
    local UICornerBtn = Instance.new("UICorner")
    local UIStroke = Instance.new("UIStroke")

    Button.Parent = ScrollingFrame
    Button.Size = UDim2.new(0.85, 0, 0, 40)
    Button.Text = Name
    Button.BackgroundColor3 = Color3.fromRGB(30, 30, 30)
    Button.TextColor3 = Color3.fromRGB(0, 255, 120) -- Green Text
    Button.Font = Enum.Font.GothamSemibold
    Button.TextSize = 14
    Button.AutoButtonColor = true

    UICornerBtn.CornerRadius = UDim.new(0, 8)
    UICornerBtn.Parent = Button

    -- Neon Border Effect
    UIStroke.Parent = Button
    UIStroke.Thickness = 2
    UIStroke.Color = Color3.fromRGB(0, 255, 120) -- Neon Green Border
    UIStroke.ApplyStrokeMode = Enum.ApplyStrokeMode.Border

    Button.MouseButton1Click:Connect(function()
        print("Executing: " .. Name)
        local success, err = pcall(function()
            loadstring(game:HttpGet(URL, true))()
        end)
        if not success then
            warn("Error: " .. err)
        end
    end)
end

--- ADD YOUR SCRIPTS HERE ---
CreateScriptButton("Aimbot", "https://raw.githubusercontent.com/cmoney53/Aimboy/refs/heads/main/Aimbot.lua")
CreateScriptButton("Modded Yield", "https://raw.githubusercontent.com/cmoney53/Aimboy/refs/heads/main/commando.lua")
CreateScriptButton("Script Three", "https://raw.githubusercontent.com/Example/Script3")
-----------------------------
