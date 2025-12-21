--[[
    MOBILE MASTER DEVELOPER SUITE
    Features: 
    - Movable Windows (Draggable)
    - Scrollable Harvester Results
    - Auto-fill Executor from Scan
    - Large Touch Targets for Mobile
]]

local cloneref = (cloneref or function(...) return ... end)
local game = workspace.Parent
local service = setmetatable({}, {
    __index = function(self, name) return cloneref(game:GetService(name)) end
})

-- 1. STEALTH & PROTECTION
local dexName = "MobileMaster_" .. math.random(100, 999)
local gethui = gethui or get_hidden_ui or get_hidden_gui
local function protect(gui)
    gui.Name = dexName
    if gethui then gui.Parent = gethui()
    elseif syn and syn.protect_gui then syn.protect_gui(gui)
    else gui.Parent = service.CoreGui end
end

-- 2. EXECUTOR INTERFACE (Movable & Fillable)
local function openExecutor(commandCode)
    local sg = Instance.new("ScreenGui"); protect(sg)
    
    local frame = Instance.new("Frame", sg)
    frame.Size = UDim2.new(0.8, 0, 0.4, 0)
    frame.Position = UDim2.new(0.1, 0, 0.3, 0)
    frame.BackgroundColor3 = Color3.fromRGB(30, 30, 30)
    frame.Active = true
    frame.Draggable = true -- Makes the window movable
    
    local title = Instance.new("TextLabel", frame)
    title.Size = UDim2.new(1, 0, 0, 30); title.Text = "EXECUTOR"; title.TextColor3 = Color3.new(1,1,1)
    title.BackgroundColor3 = Color3.fromRGB(50, 50, 50)

    local box = Instance.new("TextBox", frame)
    box.Size = UDim2.new(1, -20, 0.5, 0); box.Position = UDim2.new(0, 10, 0, 40)
    box.Text = commandCode or "-- Paste code here"
    box.MultiLine = true; box.TextWrapped = true; box.ClearTextOnFocus = false
    box.BackgroundColor3 = Color3.fromRGB(20, 20, 20); box.TextColor3 = Color3.new(0, 1, 0)
    box.Font = Enum.Font.Code; box.TextYAlignment = Enum.TextYAlignment.Top

    local execBtn = Instance.new("TextButton", frame)
    execBtn.Size = UDim2.new(0.45, 0, 0, 45); execBtn.Position = UDim2.new(0.02, 0, 0.75, 0)
    execBtn.Text = "EXECUTE"; execBtn.BackgroundColor3 = Color3.fromRGB(0, 120, 215); execBtn.TextColor3 = Color3.new(1,1,1)
    
    execBtn.MouseButton1Click:Connect(function()
        local f, err = loadstring(box.Text)
        if f then task.spawn(f) else warn(err) end
    end)

    local closeBtn = Instance.new("TextButton", frame)
    closeBtn.Size = UDim2.new(0.45, 0, 0, 45); closeBtn.Position = UDim2.new(0.53, 0, 0.75, 0)
    closeBtn.Text = "CLOSE"; closeBtn.BackgroundColor3 = Color3.fromRGB(150, 0, 0); closeBtn.TextColor3 = Color3.new(1,1,1)
    closeBtn.MouseButton1Click:Connect(function() sg:Destroy() end)
end

-- 3. HARVESTER INTERFACE (Scrollable List)
local function openHarvester()
    local sg = Instance.new("ScreenGui"); protect(sg)
    
    local frame = Instance.new("Frame", sg)
    frame.Size = UDim2.new(0.8, 0, 0.6, 0)
    frame.Position = UDim2.new(0.1, 0, 0.2, 0)
    frame.BackgroundColor3 = Color3.fromRGB(25, 25, 25)
    frame.Active = true
    frame.Draggable = true

    local scroll = Instance.new("ScrollingFrame", frame)
    scroll.Size = UDim2.new(1, -10, 1, -50); scroll.Position = UDim2.new(0, 5, 0, 40)
    scroll.BackgroundColor3 = Color3.fromRGB(20, 20, 20)
    scroll.CanvasSize = UDim2.new(0, 0, 5, 0) -- High canvas for lots of results
    scroll.ScrollBarThickness = 8

    local listLayout = Instance.new("UIListLayout", scroll)
    listLayout.Padding = UDim.new(0, 5)

    local title = Instance.new("TextLabel", frame)
    title.Size = UDim2.new(1, 0, 0, 35); title.Text = "TAP A COMMAND TO EDIT"; title.BackgroundColor3 = Color3.fromRGB(255, 100, 0)

    -- Scanning Logic
    local KEYWORDS = {"money", "cash", "gold", "tp", "admin", "give", "spawn", "inventory"}
    for _, v in pairs(game:GetDescendants()) do
        if v:IsA("RemoteEvent") or v:IsA("RemoteFunction") then
            local n = v.Name:lower()
            for _, key in ipairs(KEYWORDS) do
                if n:find(key) then
                    local btn = Instance.new("TextButton", scroll)
                    btn.Size = UDim2.new(1, -10, 0, 50)
                    btn.Text = "Found: " .. v.Name
                    btn.BackgroundColor3 = Color3.fromRGB(50, 50, 50); btn.TextColor3 = Color3.new(1,1,1)
                    
                    btn.MouseButton1Click:Connect(function()
                        local path = "game." .. v:GetFullName() .. (v:IsA("RemoteEvent") and ":FireServer()" or ":InvokeServer()")
                        openExecutor(path) -- Opens executor with path pre-filled
                    end)
                    break
                end
            end
        end
    end
end

-- 4. MASTER HUB INITIALIZATION
local function Init()
    local sg = Instance.new("ScreenGui"); protect(sg)
    
    local hubBtn = Instance.new("TextButton", sg)
    hubBtn.Size = UDim2.new(0, 80, 0, 80)
    hubBtn.Position = UDim2.new(0, 10, 0.4, 0)
    hubBtn.Text = "DEV"; hubBtn.BackgroundColor3 = Color3.fromRGB(45, 45, 45); hubBtn.TextColor3 = Color3.new(1,1,1)
    Instance.new("UICorner", hubBtn).CornerRadius = UDim.new(1, 0)

    local menu = Instance.new("Frame", hubBtn)
    menu.Size = UDim2.new(0, 220, 0, 240); menu.Position = UDim2.new(1, 10, -1, 0)
    menu.Visible = false; menu.BackgroundColor3 = Color3.fromRGB(35, 35, 35)
    Instance.new("UIListLayout", menu).Padding = UDim.new(0, 5)

    local function add(n, fn)
        local b = Instance.new("TextButton", menu)
        b.Size = UDim2.new(1, 0, 0, 55); b.Text = n; b.BackgroundColor3 = Color3.fromRGB(55, 55, 55); b.TextColor3 = Color3.new(1,1,1)
        b.MouseButton1Click:Connect(fn)
    end

    add("Harvester (Scrollable)", openHarvester)
    add("Empty Executor", function() openExecutor() end)
    add("Load Mobile Dex", function()
        loadstring(game:HttpGet("https://raw.githubusercontent.com/infyiff/backup/main/dex.lua"))()
    end)

    hubBtn.MouseButton1Click:Connect(function() menu.Visible = not menu.Visible end)
end

task.spawn(Init)
