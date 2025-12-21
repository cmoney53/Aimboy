--[[
    MOBILE MASTER SUITE (V14) - CLEAN UI EDITION
    - SINGLE INSTANCE: Only one Harvester and one Executor at a time.
    - RECYCLING: Opening a new menu automatically closes the previous ones.
    - PERFORMANCE: Limits scan to the first 100 matches to prevent "GUI Spam."
]]

local cloneref = (cloneref or function(...) return ... end)
local game = workspace.Parent
local lp = game:GetService("Players").LocalPlayer

-- Global variables to track open GUIs
_G.CurrentHarvester = _G.CurrentHarvester or nil
_G.CurrentExecutor = _G.CurrentExecutor or nil

local function protect(gui)
    local gethui = gethui or get_hidden_ui or get_hidden_gui
    gui.Name = "MasterSuite_" .. math.random(100, 999)
    if gethui then gui.Parent = gethui()
    else gui.Parent = game:GetService("CoreGui") end
end

-- 1. THE SINGLE-INSTANCE EXECUTOR
local function openExecutor(commandCode)
    if _G.CurrentExecutor then _G.CurrentExecutor:Destroy() end
    
    local sg = Instance.new("ScreenGui"); protect(sg)
    _G.CurrentExecutor = sg
    
    local frame = Instance.new("Frame", sg)
    frame.Size = UDim2.new(0.85, 0, 0.5, 0); frame.Position = UDim2.new(0.075, 0, 0.25, 0)
    frame.BackgroundColor3 = Color3.fromRGB(20, 20, 20); frame.Active = true; frame.Draggable = true
    Instance.new("UICorner", frame)

    local title = Instance.new("TextLabel", frame)
    title.Size = UDim2.new(1, 0, 0, 35); title.Text = "EXECUTOR DEBUGGER"; title.TextColor3 = Color3.new(1,1,1)
    title.BackgroundColor3 = Color3.fromRGB(40, 40, 40)

    local box = Instance.new("TextBox", frame)
    box.Size = UDim2.new(1, -20, 0.4, 0); box.Position = UDim2.new(0, 10, 0, 45)
    box.Text = commandCode or ""; box.MultiLine = true; box.TextWrapped = true
    box.BackgroundColor3 = Color3.fromRGB(10, 10, 10); box.TextColor3 = Color3.new(1, 1, 1); box.Font = Enum.Font.Code

    local logText = Instance.new("TextLabel", frame)
    logText.Size = UDim2.new(1, -20, 0, 40); logText.Position = UDim2.new(0, 10, 0.45, 10)
    logText.BackgroundColor3 = Color3.fromRGB(5, 5, 5); logText.Text = "Waiting..."; logText.TextColor3 = Color3.new(0.7,0.7,0.7)
    logText.TextWrapped = true

    local execBtn = Instance.new("TextButton", frame)
    execBtn.Size = UDim2.new(0.45, 0, 0, 45); execBtn.Position = UDim2.new(0.02, 0, 0.8, 0)
    execBtn.Text = "FIRE NOW"; execBtn.BackgroundColor3 = Color3.fromRGB(0, 150, 0); execBtn.TextColor3 = Color3.new(1,1,1)
    
    execBtn.MouseButton1Click:Connect(function()
        local func, err = loadstring(box.Text)
        if func then
            local success, fault = pcall(func)
            logText.Text = success and "✅ SENT SUCCESSFULLY" or "❌ ERROR: "..tostring(fault)
            logText.TextColor3 = success and Color3.new(0,1,0) or Color3.new(1,0,0)
        else
            logText.Text = "⚠️ SYNTAX ERR: "..tostring(err)
            logText.TextColor3 = Color3.new(1,1,0)
        end
    end)

    local closeBtn = Instance.new("TextButton", frame)
    closeBtn.Size = UDim2.new(0.45, 0, 0, 45); closeBtn.Position = UDim2.new(0.53, 0, 0.8, 0)
    closeBtn.Text = "CLOSE"; closeBtn.BackgroundColor3 = Color3.fromRGB(150, 0, 0); closeBtn.TextColor3 = Color3.new(1,1,1)
    closeBtn.MouseButton1Click:Connect(function() sg:Destroy(); _G.CurrentExecutor = nil end)
end

-- 2. THE SINGLE-INSTANCE HARVESTER
local function openHarvester()
    if _G.CurrentHarvester then _G.CurrentHarvester:Destroy() end
    
    local sg = Instance.new("ScreenGui"); protect(sg)
    _G.CurrentHarvester = sg
    
    local frame = Instance.new("Frame", sg)
    frame.Size = UDim2.new(0.9, 0, 0.7, 0); frame.Position = UDim2.new(0.05, 0, 0.15, 0)
    frame.BackgroundColor3 = Color3.fromRGB(25, 25, 25); frame.Active = true; frame.Draggable = true

    local scroll = Instance.new("ScrollingFrame", frame)
    scroll.Size = UDim2.new(1, -10, 1, -60); scroll.Position = UDim2.new(0, 5, 0, 10)
    scroll.BackgroundColor3 = Color3.fromRGB(15, 15, 15); scroll.ScrollBarThickness = 10
    local layout = Instance.new("UIListLayout", scroll); layout.Padding = UDim.new(0, 5)

    local KEYS = {"money", "cash", "gold", "gems", "admin", "give", "item", "tp", "stat", "level", "pet"}
    local count = 0
    
    for _, v in pairs(game:GetDescendants()) do
        if v:IsA("RemoteEvent") or v:IsA("RemoteFunction") then
            local name = v.Name:lower()
            for _, k in ipairs(KEYS) do
                if name:find(k) then
                    count = count + 1
                    local b = Instance.new("TextButton", scroll)
                    b.Size = UDim2.new(1, -15, 0, 50); b.Text = "["..v.ClassName:sub(1,4).."] "..v.Name
                    b.BackgroundColor3 = Color3.fromRGB(45, 45, 45); b.TextColor3 = Color3.new(1,1,1)
                    b.MouseButton1Click:Connect(function()
                        local code = "game."..v:GetFullName()..(v:IsA("RemoteEvent") and ":FireServer(game.Players.LocalPlayer)" or ":InvokeServer(game.Players.LocalPlayer)")
                        openExecutor(code)
                    end)
                    break
                end
            end
        end
        if count >= 100 then break end -- Stop at 100 to prevent GUI spam
    end

    local close = Instance.new("TextButton", frame)
    close.Size = UDim2.new(1, -20, 0, 40); close.Position = UDim2.new(0, 10, 1, -45)
    close.Text = "CLOSE HARVESTER"; close.BackgroundColor3 = Color3.fromRGB(70, 70, 70); close.TextColor3 = Color3.new(1,1,1)
    close.MouseButton1Click:Connect(function() sg:Destroy(); _G.CurrentHarvester = nil end)
    
    scroll.CanvasSize = UDim2.new(0, 0, 0, layout.AbsoluteContentSize.Y + 20)
end

-- 3. FLOATING MAIN BUTTON
local function Init()
    -- Clear any existing buttons from previous runs
    local existing = game:GetService("CoreGui"):FindFirstChild("MasterSuite_Main")
    if existing then existing:Destroy() end

    local sg = Instance.new("ScreenGui"); protect(sg); sg.Name = "MasterSuite_Main"
    local btn = Instance.new("TextButton", sg)
    btn.Size = UDim2.new(0, 70, 0, 70); btn.Position = UDim2.new(0, 10, 0.4, 0)
    btn.Text = "GOD"; btn.BackgroundColor3 = Color3.fromRGB(120, 0, 255); btn.TextColor3 = Color3.new(1,1,1)
    Instance.new("UICorner", btn).CornerRadius = UDim.new(1, 0)
    
    btn.MouseButton1Click:Connect(function()
        if _G.CurrentHarvester then 
            _G.CurrentHarvester:Destroy()
            _G.CurrentHarvester = nil
        else
            openHarvester()
        end
    end)
end

task.spawn(Init)
