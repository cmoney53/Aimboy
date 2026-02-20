local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local LocalPlayer = Players.LocalPlayer

-- Create a simple ScreenGui
local ScreenGui = Instance.new("ScreenGui", LocalPlayer.PlayerGui)
local Frame = Instance.new("ScrollingFrame", ScreenGui)
Frame.Size = UDim2.new(0, 200, 0, 300)
Frame.Position = UDim2.new(0.5, -100, 0.5, -150)
Frame.CanvasSize = UDim2.new(0, 0, 5, 0)

local UIListLayout = Instance.new("UIListLayout", Frame)

-- Function to execute the fling
local function flingPlayer(target)
    if not target.Character or not target.Character:FindFirstChild("HumanoidRootPart") then return end
    
    local char = LocalPlayer.Character
    local hrp = char:FindFirstChild("HumanoidRootPart")
    local oldPos = hrp.CFrame
    
    -- 1. Disable Collisions to prevent self-flinging
    local connection = RunService.Stepped:Connect(function()
        for _, part in pairs(char:GetDescendants()) do
            if part:IsA("BasePart") then part.CanCollide = false end
        end
    end)

    -- 2. Teleport to Target and Spin like a tornado
    hrp.CFrame = target.Character.HumanoidRootPart.CFrame
    local velocity = Instance.new("BodyAngularVelocity")
    velocity.MaxTorque = Vector3.new(1, 1, 1) * math.huge
    velocity.P = math.huge
    velocity.AngularVelocity = Vector3.new(0, 99999, 0) -- The "Fling" force
    velocity.Parent = hrp

    -- 3. Wait and Return
    task.wait(1)
    
    velocity:Destroy()
    connection:Disconnect()
    hrp.CFrame = oldPos
end

-- Refresh the list of players
local function refreshList()
    for _, child in pairs(Frame:GetChildren()) do
        if child:IsA("TextButton") then child:Destroy() end
    end

    for _, p in pairs(Players:GetPlayers()) do
        if p ~= LocalPlayer then
            local btn = Instance.new("TextButton", Frame)
            btn.Size = UDim2.new(1, 0, 0, 30)
            btn.Text = p.Name
            btn.MouseButton1Click:Connect(function()
                flingPlayer(p)
            end)
        end
    end
end

refreshList()
Players.PlayerAdded:Connect(refreshList)
Players.PlayerRemoving:Connect(refreshList)
