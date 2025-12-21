--[[
    MOBILE MASTER SUITE (V17) - SMART-FIX
    - AUTO-FORMATTER: Fixes common mobile typing errors automatically.
    - SYNTAX HIGHLIGHTING: Log will tell you EXACTLY which line is broken.
    - RECYCLED UI: Prevents GUI spam.
    - FULL KEYWORDS + DEX.
]]

local cloneref = (cloneref or function(...) return ... end)
local game = workspace.Parent
local lp = game:GetService("Players").LocalPlayer

_G.CurrentHarvester = nil
_G.CurrentExecutor = nil

local function protect(gui)
    local gethui = gethui or get_hidden_ui or get_hidden_gui
    gui.Name = "SmartSuite_V17_" .. math.random(100, 999)
    if gethui then gui.Parent = gethui()
    else gui.Parent = game:GetService("CoreGui") end
end

-- 1. THE SMART EXECUTOR (FIXES SYNTAX)
local function openExecutor(commandCode)
    if _G.CurrentExecutor then _G.CurrentExecutor:Destroy() end
    local sg = Instance.new("ScreenGui"); protect(sg); _G.CurrentExecutor = sg
    local frame = Instance.new("Frame", sg)
    frame.Size = UDim2.new(0.85, 0, 0.55, 0); frame.Position = UDim2.new(0.075, 0, 0.2, 0)
    frame.BackgroundColor3 = Color3.fromRGB(15, 15, 15); frame.Active = true; frame.Draggable = true
    Instance.new("UICorner", frame)

    local box = Instance.new("TextBox", frame)
    box.Size = UDim2.new(1, -20, 0.45, 0); box.Position = UDim2.new(0, 10, 0, 45)
    box.Text = commandCode or ""; box.MultiLine = true; box.TextWrapped = true
    box.BackgroundColor3 = Color3.fromRGB(5, 5, 5); box.TextColor3 = Color3.new(1, 1, 1); box.ClearTextOnFocus = false

    local logBox = Instance.new("TextLabel", frame)
    logBox.Size = UDim2.new(1, -20, 0, 50); logBox.Position = UDim2.new(0, 10, 0.5, 10)
    logBox.BackgroundColor3 = Color3.fromRGB(0, 0, 0); logBox.Text = "Status: Idle"; logBox.TextColor3 = Color3.new(0.7,0.7,0.7); logBox.TextSize = 12; logBox.TextWrapped = true

    local execBtn = Instance.new("TextButton", frame)
    execBtn.Size = UDim2.new(0.96, 0, 0, 50); execBtn.Position = UDim2.new(0.02, 0, 0.8, 0)
    execBtn.Text = "FIX & FIRE NOW"; execBtn.BackgroundColor3 = Color3.fromRGB(0, 150, 0); execBtn.TextColor3 = Color3.new(1,1,1)

    execBtn.MouseButton1Click:Connect(function()
        local code = box.Text
        
        -- SMART FIX: Replace "Smart Quotes" from mobile keyboards with standard ones
        code = code:gsub("“", '"'):gsub("”", '"'):gsub("‘", "'"):gsub("’", "'")
        
        local func, err = loadstring(code)
        if func then
            local success, fault = pcall(func)
            if success then
                logBox.Text = "✅ EXECUTED SUCCESSFULLY"; logBox.TextColor3 = Color3.new(0, 1, 0)
            else
                logBox.Text = "❌ RUNTIME ERROR: " .. tostring(fault); logBox.TextColor3 = Color3.new(1, 0, 0)
            end
        else
            -- Extract the line number from the error string
            local lineNum = err:match(":(%d+):") or "unknown"
            logBox.Text = "⚠️ SYNTAX ERROR (Line " .. lineNum .. "):\n" .. err:gsub(".-:%d+: ", "")
            logBox.TextColor3 = Color3.new(1, 1, 0)
        end
    end)
    
    local close = Instance.new("TextButton", frame)
    close.Size = UDim2.new(0.1, 0, 0, 35); close.Position = UDim2.new(0.9, 0, 0, 0); close.Text = "X"; close.BackgroundColor3 = Color3.new(0.5,0,0); close.TextColor3 = Color3.new(1,1,1)
    close.MouseButton1Click:Connect(function() sg:Destroy(); _G.CurrentExecutor = nil end)
end

-- 2. THE MEGA-HARVESTER
local function openHarvester()
    if _G.CurrentHarvester then _G.CurrentHarvester:Destroy() end
    local sg = Instance.new("ScreenGui"); protect(sg); _G.CurrentHarvester = sg
    local frame = Instance.new("Frame", sg)
    frame.Size = UDim2.new(0.9, 0, 0.75, 0); frame.Position = UDim2.new(0.05, 0, 0.1, 0); frame.BackgroundColor3 = Color3.fromRGB(20, 20, 20); frame.Active = true; frame.Draggable = true

    local scroll = Instance.new("ScrollingFrame", frame)
    scroll.Size = UDim2.new(1, -10, 1, -10); scroll.Position = UDim2.new(0, 5, 0, 5); scroll.BackgroundColor3 = Color3.fromRGB(10,10,10); scroll.ScrollBarThickness = 12
    local layout = Instance.new("UIListLayout", scroll); layout.Padding = UDim.new(0, 5)

    local KEYS = {"money", "cash", "gold", "gems", "admin", "give", "tp", "stat", "level", "pet", "rank", "remote"}
    
    for _, v in pairs(game:GetDescendants()) do
        if v:IsA("RemoteEvent") or v:IsA("RemoteFunction") then
            local name = v.Name:lower()
            for _, k in ipairs(KEYS) do
                if name:find(k) then
                    local b = Instance.new("TextButton", scroll)
                    b.Size = UDim2.new(1, -15, 0, 50); b.Text = "["..v.ClassName:sub(1,4).."] "..v.Name; b.BackgroundColor3 = Color3.fromRGB(40,40,40); b.TextColor3 = Color3.new(1,1,1)
                    b.MouseButton1Click:Connect(function()
                        local code = "game." .. v:GetFullName() .. (v:IsA("RemoteEvent") and ":FireServer()" or ":InvokeServer()")
                        openExecutor(code)
                    end)
                    break
                end
            end
        end
    end
    scroll.CanvasSize = UDim2.new(0, 0, 0, layout.AbsoluteContentSize.Y + 20)
end

-- 3. MAIN HUB
local function Init()
    local existing = game:GetService("CoreGui"):FindFirstChild("Main_GOD_UI")
    if existing then existing:Destroy() end
    local sg = Instance.new("ScreenGui"); protect(sg); sg.Name = "Main_GOD_UI"
    local mainBtn = Instance.new("TextButton", sg)
    mainBtn.Size = UDim2.new(0, 75, 0, 75); mainBtn.Position = UDim2.new(0, 10, 0.4, 0); mainBtn.Text = "GOD"; mainBtn.BackgroundColor3 = Color3.fromRGB(120, 0, 255); mainBtn.TextColor3 = Color3.new(1,1,1)
    Instance.new("UICorner", mainBtn).CornerRadius = UDim.new(1, 0)

    local menu = Instance.new("Frame", mainBtn)
    menu.Size = UDim2.new(0, 180, 0, 160); menu.Position = UDim2.new(1, 10, -0.5, 0); menu.BackgroundColor3 = Color3.fromRGB(25, 25, 25); menu.Visible = false
    Instance.new("UIListLayout", menu)

    local function opt(n, f)
        local b = Instance.new("TextButton", menu)
        b.Size = UDim2.new(1, 0, 0, 50); b.Text = n; b.BackgroundColor3 = Color3.fromRGB(40,40,40); b.TextColor3 = Color3.new(1,1,1)
        b.MouseButton1Click:Connect(f)
    end

    opt("Harvester", openHarvester)
    opt("Mobile Dex", function() loadstring(game:HttpGet("https://raw.githubusercontent.com/infyiff/backup/main/dex.lua"))() end)
    opt("Empty Exec", function() openExecutor("") end)

    mainBtn.MouseButton1Click:Connect(function() menu.Visible = not menu.Visible end)
end

task.spawn(Init)
