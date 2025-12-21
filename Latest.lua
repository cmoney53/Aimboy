a

--[[
    Dex: Developer Edition
    Modified for: Stealth, Command Searching, and Mid-Game Execution
    Base: LorekeeperZinnia Dex
]]

local cloneref = (cloneref or function(...) return ... end)
local service = setmetatable({}, {
    __index = function(self, name)
        local serv = game:GetService(name)
        self[name] = cloneref(serv)
        return self[name]
    end
})

-- PREVENT DETECTION: Randomize UI Name and use Hidden Containers
local dexName = ""
for i = 1, 15 do dexName = dexName .. string.char(math.random(65, 90)) end

local gethui = gethui or get_hidden_ui or get_hidden_gui
local protectgui = function(gui)
    gui.Name = dexName
    if gethui then
        gui.Parent = gethui()
    elseif syn and syn.protect_gui then
        syn.protect_gui(gui)
    else
        gui.Parent = service.CoreGui
    end
end

-- 1. COMMAND EXECUTOR MODULE
local function openExecutor(suggestion)
    local screen = Instance.new("ScreenGui")
    protectgui(screen)
    
    local frame = Instance.new("Frame", screen)
    frame.Size = UDim2.new(0, 350, 0, 150)
    frame.Position = UDim2.new(0.5, -175, 0.5, -75)
    frame.BackgroundColor3 = Color3.fromRGB(35, 35, 35)
    frame.BorderSizePixel = 0
    frame.Active = true
    frame.Draggable = true

    local title = Instance.new("TextLabel", frame)
    title.Size = UDim2.new(1, 0, 0, 30)
    title.Text = "MID-GAME COMMAND EXECUTOR"
    title.TextColor3 = Color3.new(1, 1, 1)
    title.BackgroundColor3 = Color3.fromRGB(50, 50, 50)
    title.BorderSizePixel = 0

    local box = Instance.new("TextBox", frame)
    box.Size = UDim2.new(1, -20, 0, 60)
    box.Position = UDim2.new(0, 10, 0, 40)
    box.Text = suggestion or ""
    box.BackgroundColor3 = Color3.fromRGB(25, 25, 25)
    box.TextColor3 = Color3.new(1, 1, 1)
    box.ClearTextOnFocus = false
    box.TextWrapped = true
    box.Font = Enum.Font.Code

    local btn = Instance.new("TextButton", frame)
    btn.Size = UDim2.new(1, -20, 0, 30)
    btn.Position = UDim2.new(0, 10, 0, 110)
    btn.Text = "EXECUTE"
    btn.BackgroundColor3 = Color3.fromRGB(0, 120, 215)
    btn.TextColor3 = Color3.new(1, 1, 1)

    btn.MouseButton1Click:Connect(function()
        local code = box.Text
        local func, err = loadstring(code)
        if func then 
            task.spawn(func) 
        else 
            warn("EXECUTION ERROR: " .. tostring(err))
        end
    end)
end

-- 2. SEARCH FOR COMMANDS MODULE
local function searchForCommands()
    print("Dex: Scanning for command remotes...")
    local found = "-- Search results:\n"
    local count = 0
    for _, v in pairs(game:GetDescendants()) do
        if (v:IsA("RemoteEvent") or v:IsA("RemoteFunction")) then
            local name = v.Name:lower()
            if name:find("admin") or name:find("cmd") or name:find("command") then
                found = found .. "-- Found: " .. v:GetFullName() .. "\ngame." .. v:GetFullName() .. ":FireServer('command_here')\n"
                count = count + 1
            end
        end
        if count >= 5 then break end -- Limit results for readability
    end
    
    if count == 0 then found = "-- No obvious command remotes found." end
    openExecutor(found)
end

-- 3. MAIN GUI INITIALIZATION
local function startDexSuite()
    local mainGui = Instance.new("ScreenGui")
    protectgui(mainGui)

    -- Floating Toggle Button
    local openBtn = Instance.new("TextButton", mainGui)
    openBtn.Size = UDim2.new(0, 60, 0, 30)
    openBtn.Position = UDim2.new(0, 10, 0.4, 0)
    openBtn.Text = "DEV MENU"
    openBtn.BackgroundColor3 = Color3.fromRGB(45, 45, 45)
    openBtn.TextColor3 = Color3.new(1, 1, 1)
    openBtn.BorderSizePixel = 0

    local menuFrame = Instance.new("Frame", openBtn)
    menuFrame.Size = UDim2.new(0, 180, 0, 120)
    menuFrame.Position = UDim2.new(1, 10, 0, 0)
    menuFrame.BackgroundColor3 = Color3.fromRGB(30, 30, 30)
    menuFrame.Visible = false
    menuFrame.BorderSizePixel = 0

    local layout = Instance.new("UIListLayout", menuFrame)
    layout.Padding = UDim.new(0, 2)

    local function addOption(name, fn)
        local b = Instance.new("TextButton", menuFrame)
        b.Size = UDim2.new(1, 0, 0, 38)
        b.Text = name
        b.BackgroundColor3 = Color3.fromRGB(55, 55, 55)
        b.TextColor3 = Color3.new(1, 1, 1)
        b.BorderSizePixel = 0
        b.MouseButton1Click:Connect(fn)
    end

    -- Add buttons to the developer menu
    addOption("Search for Commands", searchForCommands)
    addOption("Open Executor", function() openExecutor() end)
    addOption("Load Original Dex", function()
        menuFrame.Visible = false
        -- Load the base Dex script from your provided content
        loadstring(game:HttpGet("https://raw.githubusercontent.com/LorekeeperZinnia/Dex/master/main.lua"))()
    end)

    openBtn.MouseButton1Click:Connect(function()
        menuFrame.Visible = not menuFrame.Visible
    end)
end

-- Run
task.spawn(startDexSuite)
print("Dex Developer Suite: Bypassed & Loaded.")
