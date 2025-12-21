local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local CoreGui = game:GetService("CoreGui")

local player = Players.LocalPlayer
local camera = workspace.CurrentCamera

-- // SETTINGS
local AIM_ENABLED = false
local VERTICAL_OFFSET = 2.4 -- Perfect chest height
local MAX_DIST = 100000

-- // UI CLEANUP
if CoreGui:FindFirstChild("PerfectLock") then CoreGui.PerfectLock:Destroy() end

-- // UI SETUP
local ScreenGui = Instance.new("ScreenGui", CoreGui)
ScreenGui.Name = "PerfectLock"

local MainToggle = Instance.new("TextButton", ScreenGui)
MainToggle.Size = UDim2.new(0, 160, 0, 50)
MainToggle.Position = UDim2.new(0.05, 0, 0.45, 0)
MainToggle.BackgroundColor3 = Color3.fromRGB(40, 40, 40)
MainToggle.Text = "WAITING..."
MainToggle.TextColor3 = Color3.new(1, 1, 1)
MainToggle.Font = Enum.Font.GothamBold
MainToggle.TextSize = 14
MainToggle.Draggable = true
Instance.new("UICorner", MainToggle)

-- // HELPER: CHECK IF AIMING AT CHARACTER
local function isCrosshairOnTarget(targetCharacter)
    local mouseRay = camera:ViewportPointToRay(camera.ViewportSize.X / 2, camera.ViewportSize.Y / 2)
    local raycastParams = RaycastParams.new()
    raycastParams.FilterDescendantsInstances = {player.Character}
    raycastParams.FilterType = Enum.RaycastFilterType.Exclude
    
    local result = workspace:Raycast(mouseRay.Origin, mouseRay.Direction * 1000, raycastParams)
    
    if result and result.Instance:IsDescendantOf(targetCharacter) then
        return true
    end
    return false
end

-- // CORE LOGIC
local function getBestTarget()
    local closestPlayer = nil
    local shortestMouseDist = math.huge
    local screenCenter = Vector2.new(camera.ViewportSize.X / 2, camera.ViewportSize.Y / 2)

    for _, p in pairs(Players:GetPlayers()) do
        if p ~= player and p.Character then
            local root = p.Character:FindFirstChild("HumanoidRootPart")
            local hum = p.Character:FindFirstChild("Humanoid")
            
            if root and hum and hum.Health > 0 then
                local worldPoint = root.Position + Vector3.new(0, VERTICAL_OFFSET, 0)
                local pos, onScreen = camera:WorldToViewportPoint(worldPoint)
                
                if onScreen then
                    -- Calculate distance from crosshair to target
                    local mouseDist = (Vector2.new(pos.X, pos.Y) - screenCenter).Magnitude
                    
                    if mouseDist < shortestMouseDist then
                        closestPlayer = {Part = root, Position = worldPoint, Character = p.Character}
                        shortestMouseDist = mouseDist
                    end
                end
            end
        end
    end
    return closestPlayer
end

-- // MAIN LOOP
RunService.RenderStepped:Connect(function()
    local targetData = getBestTarget()
    
    if AIM_ENABLED and targetData then
        -- FORCED SHIFTLOCK BYPASS: Direct CFrame Overwrite
        camera.CFrame = CFrame.lookAt(camera.CFrame.Position, targetData.Position)
        
        -- VISUAL DETECTION: Change UI color if crosshair is actually on the body
        if isCrosshairOnTarget(targetData.Character) then
            MainToggle.BackgroundColor3 = Color3.fromRGB(0, 200, 100) -- Green for "On Target"
            MainToggle.Text = "TARGET LOCKED"
        else
            MainToggle.BackgroundColor3 = Color3.fromRGB(200, 0, 0) -- Red for "Snapping"
            MainToggle.Text = "SNAPPING..."
        end
    elseif not AIM_ENABLED then
        MainToggle.BackgroundColor3 = Color3.fromRGB(40, 40, 40)
        MainToggle.Text = "AIMBOT: OFF"
    else
        MainToggle.Text = "SCANNING..."
        MainToggle.BackgroundColor3 = Color3.fromRGB(40, 40, 40)
    end
end)

MainToggle.MouseButton1Click:Connect(function()
    AIM_ENABLED = not AIM_ENABLED
end)
