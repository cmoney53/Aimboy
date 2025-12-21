--[[
    Dex: Ultimate Developer Edition
    Features: Hidden GUI Reveal, Money/Admin Remote Scanner, Mid-Game Executor
]]

local cloneref = (cloneref or function(...) return ... end)
local service = setmetatable({}, {
    __index = function(self, name)
        return cloneref(game:GetService(name))
    end
})

-- STEALTH SETUP
local dexName = "DevSuite_" .. math.random(100, 999)
local gethui = gethui or get_hidden_ui or get_hidden_gui
local protectgui = function(gui)
    gui.Name = dexName
    if gethui then gui.Parent = gethui()
    elseif syn and syn.protect_gui then syn.protect_gui(gui)
    else gui.Parent = service.CoreGui end
end

-- 1. DEEP SCANNER (Finds Money, Admin, and Spawners)
local function runDeepScan()
    print("--- STARTING DEEP SCAN ---")
    local results = "-- DEEP SCAN RESULTS --\n\n"
    local count = 0
    
    -- Search all game descendants for vulnerability patterns
    for _, v in pairs(game:GetDescendants()) do
        if v:IsA("RemoteEvent") or v:IsA("RemoteFunction") then
            local n = v.Name:lower()
            -- Keywords that usually indicate "Money" or "Commands"
            if n:find("money") or n:find("cash") or n:find("currency") or n:find("gold") or 
               n:find("admin") or n:find("cmd") or n:find("give") or n:find("spawn") or
               n:find("remote") or n:find("update") then
                
                results = results .. "-- Found Potential Command: " .. v.Name .. "\n"
                results = results .. "game." .. v:GetFullName() .. ":FireServer('ENTER_VALUE_HERE')\n\n"
                count = count + 1
            end
        end
    end
    
    if count == 0 then results = results .. "-- No obvious vulnerabilities found." end
    return results
end

-- 2. GUI REVEALER (Finds Hidden Menus)
local function revealHiddenGuis()
    print("Revealing all hidden GUIs...")
    local total = 0
    for _, v in pairs(game:GetDescendants()) do
        if v:IsA("ScreenGui") then
            v.Enabled = true
            total = total + 1
        elseif v:IsA("GuiObject") then
            v.Visible = true
            v.Transparency = 0
        end
    end
    print("Revealed " .. total .. " hidden interfaces.")
end

-- 3. THE EXECUTOR INTERFACE
local function openDevWindow(defaultText)
    local screen = Instance.new("ScreenGui")
    protectgui(screen)
    
    local frame = Instance.new("Frame", screen)
    frame.Size = UDim2.new(0, 400, 0, 250)
    frame.Position = UDim2.new(0.5, -200, 0.5, -125)
    frame.BackgroundColor3 = Color3.fromRGB(30, 30, 30)
    frame.Active = true; frame.Draggable = true

    local title = Instance.new("TextLabel", frame)
    title.Size = UDim2.new(1, 0, 0, 30); title.Text = "ULTIMATE DEV EXECUTOR"
    title.BackgroundColor3 = Color3.fromRGB(50, 50, 50); title.TextColor3 = Color3.new(1,1,1)

    local box = Instance.new("TextBox", frame)
    box.Size = UDim2.new(1, -20, 0, 150); box.Position = UDim2.new(0, 10, 0, 40)
    box.Text = defaultText or "-- Run code here"
    box.MultiLine = true; box.TextWrapped = true; box.ClearTextOnFocus = false
    box.BackgroundColor3 = Color3.fromRGB(20, 20, 20); box.TextColor3 = Color3.new(0, 1, 0)
    box.Font = Enum.Font.Code; box.TextXAlignment = Enum.TextXAlignment.Left; box.TextYAlignment = Enum.TextYAlignment.Top

    local run = Instance.new("TextButton", frame)
    run.Size = UDim2.new(0, 180, 0, 40); run.Position = UDim2.new(0, 10, 0, 200)
    run.Text = "EXECUTE CODE"; run.BackgroundColor3 = Color3.fromRGB(0, 150, 0); run.TextColor3 = Color3.new(1,1,1)
    
    run.MouseButton1Click:Connect(function()
        local f, err = loadstring(box.Text)
        if f then task.spawn(f) else warn("DEV ERROR: " .. tostring(err)) end
    end)
    
    local close = Instance.new("TextButton", frame)
    close.Size = UDim2.new(0, 180, 0, 40); close.Position = UDim2.new(0, 210, 0, 200)
    close.Text = "CLOSE"; close.BackgroundColor3 = Color3.fromRGB(150, 0, 0); close.TextColor3 = Color3.new(1,1,1)
    close.MouseButton1Click:Connect(function() screen:Destroy() end)
end

-- 4. THE MAIN TOGGLE MENU
local function init()
    local main = Instance.new("ScreenGui")
    protectgui(main)

    local btn = Instance.new("TextButton", main)
    btn.Size = UDim2.new(0, 100, 0, 40); btn.Position = UDim2.new(0, 10, 0.4, 0)
    btn.Text = "DEV MENU"; btn.BackgroundColor3 = Color3.fromRGB(45, 45, 45); btn.TextColor3 = Color3.new(1,1,1)

    local menu = Instance.new("Frame", btn)
    menu.Size = UDim2.new(0, 200, 0, 150); menu.Position = UDim2.new(1, 10, 0, 0)
    menu.Visible = false; menu.BackgroundColor3 = Color3.fromRGB(35, 35, 35)
    Instance.new("UIListLayout", menu)

    local function addOpt(name, fn)
        local b = Instance.new("TextButton", menu)
        b.Size = UDim2.new(1, 0, 0, 50); b.Text = name
        b.BackgroundColor3 = Color3.fromRGB(55, 55, 55); b.TextColor3 = Color3.new(1,1,1)
        b.MouseButton1Click:Connect(fn)
    end

    addOpt("Scan for Money/Cmds", function() openDevWindow(runDeepScan()) end)
    addOpt("Reveal Hidden GUIs", revealHiddenGuis)
    addOpt("Open Blank Executor", function() openDevWindow() end)

    btn.MouseButton1Click:Connect(function() menu.Visible = not menu.Visible end)
end

task.spawn(init)
print("Dev Suite Loaded. Click 'Scan for Money/Cmds' to find hidden game functions.")
