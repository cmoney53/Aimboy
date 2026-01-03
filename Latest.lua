-- Create the Library
local ScreenGui = Instance.new("ScreenGui")
local MainFrame = Instance.new("Frame")
local Title = Instance.new("TextLabel")
local ButtonLayout = Instance.new("UIListLayout")
local ScrollingFrame = Instance.new("ScrollingFrame")

-- Properties
ScreenGui.Parent = game.Players.LocalPlayer:WaitForChild("PlayerGui")
ScreenGui.ResetOnSpawn = false

MainFrame.Name = "ScriptHUD"
MainFrame.Parent = ScreenGui
MainFrame.BackgroundColor3 = Color3.fromRGB(35, 35, 35)
MainFrame.Position = UDim2.new(0.5, -100, 0.5, -150)
MainFrame.Size = UDim2.new(0, 200, 0, 300)
MainFrame.Active = true
MainFrame.Draggable = true -- Allows you to move the HUD around

Title.Parent = MainFrame
Title.Size = UDim2.new(1, 0, 0, 40)
Title.Text = "Script Manager"
Title.TextColor3 = Color3.fromRGB(255, 255, 255)
Title.BackgroundColor3 = Color3.fromRGB(50, 50, 50)

ScrollingFrame.Parent = MainFrame
ScrollingFrame.Position = UDim2.new(0, 0, 0, 45)
ScrollingFrame.Size = UDim2.new(1, 0, 1, -45)
ScrollingFrame.BackgroundTransparency = 1
ScrollingFrame.CanvasSize = UDim2.new(0, 0, 2, 0) -- Scrollable area

ButtonLayout.Parent = ScrollingFrame
ButtonLayout.HorizontalAlignment = Enum.HorizontalAlignment.Center
ButtonLayout.Padding = UDim.new(0, 5)

-- Function to create buttons
local function CreateScriptButton(Name, URL)
    local Button = Instance.new("TextButton")
    Button.Parent = ScrollingFrame
    Button.Size = UDim2.new(0.9, 0, 0, 35)
    Button.Text = Name
    Button.BackgroundColor3 = Color3.fromRGB(60, 60, 60)
    Button.TextColor3 = Color3.fromRGB(255, 255, 255)
    
    Button.MouseButton1Click:Connect(function()
        print("Loading: " .. Name)
        local success, err = pcall(function()
            loadstring(game:HttpGet(URL, true))()
        end)
        if not success then
            warn("Failed to load script: " .. err)
        end
    end)
end

--- CONFIGURATION AREA ---
-- Add your GitHub links here!
CreateScriptButton("Aimbot", "https://raw.githubusercontent.com/cmoney53/Aimboy/refs/heads/main/Aimbot.lua")
CreateScriptButton("Speed Hack", "https://raw.githubusercontent.com/User/Repo/main/speed.lua")
CreateScriptButton("ESP Script", "https://raw.githubusercontent.com/User/Repo/main/esp.lua")
--------------------------
