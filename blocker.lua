local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local LocalPlayer = Players.LocalPlayer

-- UI Setup
local ScreenGui = Instance.new("ScreenGui", LocalPlayer.PlayerGui)
ScreenGui.Name = "FlingMenu"

local MainFrame = Instance.new("Frame", ScreenGui)
MainFrame.Size = UDim2.new(0, 200, 0, 250)
MainFrame.Position = UDim2.new(0.5, -100, 0.5, -125)
MainFrame.BackgroundColor3 = Color3.fromRGB(30, 30, 30)
MainFrame.BorderSizePixel = 0
MainFrame.Active = true

-- Top Bar (For Dragging)
local TopBar = Instance.new("Frame", MainFrame)
TopBar.Size = UDim2.new(1, 0, 0, 30)
TopBar.BackgroundColor3 = Color3.fromRGB(45, 45, 45)

local Title = Instance.new("TextLabel", TopBar)
Title.Size = UDim2.new(1, -60, 1, 0)
Title.Position = UDim2.new(0, 5, 0, 0)
Title.Text = "Fling Menu"
Title.TextColor3 = Color3.new(1, 1, 1)
Title.BackgroundTransparency = 1
Title.TextXAlignment = Enum.TextXAlignment.Left

-- Close Button
local CloseBtn = Instance.new("TextButton", TopBar)
CloseBtn.Size = UDim2.new(0, 30, 0, 30)
CloseBtn.Position = UDim2.new(1, -30, 0, 0)
CloseBtn.Text = "X"
CloseBtn.BackgroundColor3 = Color3.fromRGB(150, 0, 0)
CloseBtn.TextColor3 = Color3.new(1, 1, 1)

-- Minimize Button
local MinBtn = Instance.new("TextButton", TopBar)
MinBtn.Size = UDim2.new(0, 30, 0, 30)
MinBtn.Position = UDim2.new(1, -60, 0, 0)
MinBtn.Text = "-"
MinBtn.BackgroundColor3 = Color3.fromRGB(80, 80, 80)
MinBtn.TextColor3 = Color3.new(1, 1, 1)

-- Scrolling Player List
local ListFrame = Instance.new("ScrollingFrame", MainFrame)
ListFrame.Size = UDim2.new(1, 0, 1, -30)
ListFrame.Position = UDim2.new(0, 0, 0, 30)
ListFrame.BackgroundTransparency = 1
ListFrame.CanvasSize = UDim2.new(0, 0, 10, 0)

local UIList = Instance.new("UIListLayout", ListFrame)

--- DRAGGING LOGIC ---
local dragging, dragInput, dragStart, startPos

TopBar.InputBegan:Connect(function(input)
	if input.UserInputType == Enum.UserInputType.MouseButton1 then
		dragging = true
		dragStart = input.Position
		startPos = MainFrame.Position
	end
end)

UserInputService.InputChanged:Connect(function(input)
	if dragging and input.UserInputType == Enum.UserInputType.MouseMovement then
		local delta = input.Position - dragStart
		MainFrame.Position = UDim2.new(startPos.X.Scale, startPos.X.Offset + delta.X, startPos.Y.Scale, startPos.Y.Offset + delta.Y)
	end
end)

TopBar.InputEnded:Connect(function(input)
	if input.UserInputType == Enum.UserInputType.MouseButton1 then
		dragging = false
	end
end)

--- MINIMIZE / CLOSE LOGIC ---
local minimized = false
MinBtn.MouseButton1Click:Connect(function()
	minimized = not minimized
	ListFrame.Visible = not minimized
	MainFrame.Size = minimized and UDim2.new(0, 200, 0, 30) or UDim2.new(0, 200, 0, 250)
end)

CloseBtn.MouseButton1Click:Connect(function() ScreenGui:Destroy() end)

--- THE FLING ENGINE ---
local function flingPlayer(target)
	if not target.Character or not target.Character:FindFirstChild("HumanoidRootPart") then return end
	local hrp = LocalPlayer.Character:FindFirstChild("HumanoidRootPart")
	local oldPos = hrp.CFrame
	
	-- Disable Collisions
	local con = RunService.Stepped:Connect(function()
		for _, v in pairs(LocalPlayer.Character:GetDescendants()) do
			if v:IsA("BasePart") then v.CanCollide = false end
		end
	end)

	-- Apply Force & Teleport
	local bva = Instance.new("BodyAngularVelocity", hrp)
	bva.AngularVelocity = Vector3.new(0, 9999, 0)
	bva.MaxTorque = Vector3.new(math.huge, math.huge, math.huge)
	
	hrp.CFrame = target.Character.HumanoidRootPart.CFrame
	task.wait(1)
	
	-- Cleanup
	bva:Destroy()
	con:Disconnect()
	hrp.CFrame = oldPos
end

--- PLAYER LIST UPDATER ---
local function updateList()
	for _, v in pairs(ListFrame:GetChildren()) do if v:IsA("TextButton") then v:Destroy() end end
	for _, p in pairs(Players:GetPlayers()) do
		if p ~= LocalPlayer then
			local b = Instance.new("TextButton", ListFrame)
			b.Size = UDim2.new(1, 0, 0, 30)
			b.Text = p.DisplayName or p.Name
			b.BackgroundColor3 = Color3.fromRGB(50, 50, 50)
			b.TextColor3 = Color3.new(1,1,1)
			b.MouseButton1Click:Connect(function() flingPlayer(p) end)
		end
	end
end

updateList()
Players.PlayerAdded:Connect(updateList)
Players.PlayerRemoving:Connect(updateList)
