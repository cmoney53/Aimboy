local rs = game:GetService('RunService')
local plr = game:GetService('Players').LocalPlayer
local char = plr.Character or plr.CharacterAdded:Wait()
local root = char:WaitForChild('HumanoidRootPart', 10)
local box = workspace:WaitForChild('BOX1', 10)
local click = box and box:FindFirstChild('ClickDetector')
local job = workspace:WaitForChild('Job', 10)
local valuestats = plr:WaitForChild('Valuestats', 10)
local wallet = valuestats and valuestats:FindFirstChild('Wallet')
local initialValue = wallet and wallet.Value or 0
local currentValue = initialValue

local gui = Instance.new('ScreenGui')
gui.Parent = plr:WaitForChild('PlayerGui', 10)
gui.Name = 'MoneyTracker'
gui.ResetOnSpawn = false

local frame = Instance.new('Frame')
frame.Size = UDim2.new(0, 200, 0, 100)
frame.Position = UDim2.new(0, 10, 0, 10)
frame.BackgroundColor3 = Color3.fromRGB(50, 50, 50)
frame.BorderSizePixel = 2
frame.Parent = gui

local totalLabel = Instance.new('TextLabel')
totalLabel.Size = UDim2.new(1, 0, 0.5, 0)
totalLabel.Position = UDim2.new(0, 0, 0, 0)
totalLabel.BackgroundTransparency = 1
totalLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
totalLabel.Font = Enum.Font.SourceSansBold
totalLabel.TextSize = 20
totalLabel.Text = 'Total Money: ' .. currentValue
totalLabel.Parent = frame

local gainedLabel = Instance.new('TextLabel')
gainedLabel.Size = UDim2.new(1, 0, 0.5, 0)
gainedLabel.Position = UDim2.new(0, 0, 0.5, 0)
gainedLabel.BackgroundTransparency = 1
gainedLabel.TextColor3 = Color3.fromRGB(0, 255, 0)
gainedLabel.Font = Enum.Font.SourceSansBold
gainedLabel.TextSize = 20
gainedLabel.Text = 'Money Gained: 0'
gainedLabel.Parent = frame

if click and job and root then
rs.Heartbeat:Connect(function()
pcall(function()
fireclickdetector(click)
job.CFrame = root.CFrame
end)
end)
end

if wallet then
wallet.Changed:Connect(function(newValue)
currentValue = newValue
totalLabel.Text = 'Total Money: ' .. currentValue
gainedLabel.Text = 'Money Gained: ' .. (currentValue - initialValue)
end)
end

