--[[
    MOBILE MASTER SUITE (V13) - DEBUGGER EDITION
    - LIVE DEBUG LOG: Shows exact error strings from the game engine.
    - AUTO-ARGUMENT: Automatically adds (game.Players.LocalPlayer) to fills.
    - MOVABLE & SCROLLABLE: Optimized for mobile touch.
]]

local cloneref = (cloneref or function(...) return ... end)
local game = workspace.Parent
local lp = game:GetService("Players").LocalPlayer

-- 1. PROTECTION
local function protect(gui)
    local gethui = gethui or get_hidden_ui or get_hidden_gui
    gui.Name = "DebugSuite_" .. math.random(100, 999)
    if gethui then gui.Parent = gethui()
    else gui.Parent = game:GetService("CoreGui") end
end

-- 2. EXECUTOR WITH DETAILED LOGGING
local function openExecutor(commandCode)
    local sg = Instance.new("ScreenGui"); protect(sg)
    local frame = Instance.new("Frame", sg)
    frame.Size = UDim2.new(0.85, 0, 0.55, 0); frame.Position = UDim2.new(0.075, 0, 0.2, 0)
    frame.BackgroundColor3 = Color3.fromRGB(20, 20, 20); frame.Active = true; frame.Draggable = true
    Instance.new("UICorner", frame)

    local title = Instance.new("TextLabel", frame)
    title.Size = UDim2.new(1, 0, 0, 35); title.Text = "COMMAND DEBUGGER"; title.TextColor3 = Color3.new(1,1,1)
    title.BackgroundColor3 = Color3.fromRGB(45, 45, 45)

    local box = Instance.new("TextBox", frame)
    box.Size = UDim2.new(1, -20, 0.35, 0); box.Position = UDim2.new(0, 10, 0, 45)
    box.Text = commandCode or ""; box.MultiLine = true; box.TextWrapped = true
    box.BackgroundColor3 = Color3.fromRGB(10, 10, 10); box.TextColor3 = Color3.new(1, 1, 1)
    box.ClearTextOnFocus = false; box.Font = Enum.Font.Code; box.TextSize = 14

    -- DETAILED LOG CONSOLE
    local consoleLabel = Instance.new("TextLabel", frame)
    consoleLabel.Size = UDim2.new(1, -20, 0, 20); consoleLabel.Position = UDim2.new(0, 10, 0.35, 50)
    consoleLabel.Text = "--- OUTPUT LOG ---"; consoleLabel.TextColor3 = Color3.new(0.6, 0.6, 0.6); consoleLabel.BackgroundTransparency = 1

    local logScroll = Instance.new("ScrollingFrame", frame)
    logScroll.Size = UDim2.new(1, -20, 0.25, 0); logScroll.Position = UDim2.new(0, 10, 0.35, 75)
    logScroll.BackgroundColor3 = Color3.fromRGB(5, 5, 5); logScroll.CanvasSize = UDim2.new(0,0,2,0)
    
    local logText = Instance.new("TextLabel", logScroll)
    logText.Size = UDim2.new(1, -10, 1, 0); logText.BackgroundTransparency = 1
    logText.TextColor3 = Color3.new(0.8, 0.8, 0.8); logText.Text = "Waiting for execution..."; logText.TextWrapped = true
    logText.TextYAlignment = Enum.TextYAlignment.Top; logText.Font = Enum.Font.Code; logText.TextSize = 12

    local execBtn = Instance.new("TextButton", frame)
    execBtn.Size = UDim2.new(0.45, 0, 0, 50); execBtn.Position = UDim2.new(0.02, 0, 0.85, 0)
    execBtn.Text = "FIRE NOW"; execBtn.BackgroundColor3 = Color3.fromRGB(0, 150, 0); execBtn.TextColor3 = Color3.new(1,1,1)
    
    execBtn.MouseButton1Click:Connect(function()
        logText.Text = "Executing..."
        logText.TextColor3 = Color3.new(1,1,1)
        
        local func, err = loadstring(box.Text)
        if func then
            local success, fault = pcall(func)
            if success then
                logText.Text = "✅ SUCCESS\nCommand sent to server without crashing."
                logText.TextColor3 = Color3.new(0, 1, 0)
            else
                logText.Text = "❌ RUNTIME ERROR:\n" .. tostring(fault)
                logText.TextColor3 = Color3.new(1, 0, 0)
            end
        else
            logText.Text = "⚠️ SYNTAX ERROR:\n" .. tostring(err)
            logText.TextColor3 = Color3.new(1, 1, 0)
        end
    end)

    local closeBtn = Instance.new("TextButton", frame)
    closeBtn.Size = UDim2.new(0.45, 0, 0, 50); closeBtn.Position = UDim2.new(0.53, 0, 0.85, 0)
    closeBtn.Text = "CLOSE"; closeBtn.BackgroundColor3 = Color3.fromRGB(150, 0, 0); closeBtn.TextColor3 = Color3.new(1,1,1)
    closeBtn.MouseButton1Click:Connect(function() sg:Destroy() end)
end

-- 3. THE HARVESTER
local function openHarvester()
    local sg = Instance.new("ScreenGui"); protect(sg)
    local frame = Instance.new("Frame", sg)
    frame.Size = UDim2.new(0.9, 0, 0.8, 0); frame.Position = UDim2.new(0.05, 0, 0.1, 0)
    frame.BackgroundColor3 = Color3.fromRGB(25, 25, 25); frame.Active = true; frame.Draggable = true

    local scroll = Instance.new("ScrollingFrame", frame)
    scroll.Size = UDim2.new(1, -10, 1, -20); scroll.Position = UDim2.new(0, 5, 0, 10)
    scroll.BackgroundColor3 = Color3.fromRGB(15, 15, 15); scroll.ScrollBarThickness = 12
    local layout = Instance.new("UIListLayout", scroll); layout.Padding = UDim.new(0, 5)

    -- 10x Keywords
    local KEYS = {"money", "cash", "gold", "gems", "admin", "give", "item", "tp", "stat", "level", "pet", "rank", "xp", "reward", "remote"}
    
    for _, v in pairs(game:GetDescendants()) do
        if v:IsA("RemoteEvent") or v:IsA("RemoteFunction") then
            local name = v.Name:lower()
            for _, k in ipairs(KEYS) do
                if name:find(k) then
                    local b = Instance.new("TextButton", scroll)
                    b.Size = UDim2.new(1, -15, 0, 50); b.Text = "["..v.ClassName:sub(1,4).."] "..v.Name
                    b.BackgroundColor3 = Color3.fromRGB(45, 45, 45); b.TextColor3 = Color3.new(1,1,1)
                    
                    b.MouseButton1Click:Connect(function()
                        -- Auto-filling with the LocalPlayer as a common argument
                        local arg = "game.Players.LocalPlayer"
                        local code = "game." .. v:GetFullName() .. (v:IsA("RemoteEvent") and ":FireServer("..arg..")" or ":InvokeServer("..arg..")")
                        openExecutor(code)
                    end)
                    break
                end
            end
        end
    end
    scroll.CanvasSize = UDim2.new(0, 0, 0, layout.AbsoluteContentSize.Y + 20)
end

-- 4. MASTER HUB
local function Init()
    local sg = Instance.new("ScreenGui"); protect(sg)
    local btn = Instance.new("TextButton", sg)
    btn.Size = UDim2.new(0, 75, 0, 75); btn.Position = UDim2.new(0, 10, 0.4, 0)
    btn.Text = "GOD"; btn.BackgroundColor3 = Color3.fromRGB(120, 0, 255); btn.TextColor3 = Color3.new(1,1,1)
    Instance.new("UICorner", btn).CornerRadius = UDim.new(1, 0)
    btn.MouseButton1Click:Connect(openHarvester)
end

task.spawn(Init)
