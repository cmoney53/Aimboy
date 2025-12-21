--[[
    MOBILE MASTER SUITE (V16) - DEX INTEGRATED
    - ALL KEYWORDS RESTORED (4,500+ Logic)
    - MOBILE DEX: One-tap button to explore game files.
    - CLEAN UI: Recycles windows to prevent screen clutter.
    - DEBUG LOG: Live feedback on every execution.
]]

local cloneref = (cloneref or function(...) return ... end)
local game = workspace.Parent
local lp = game:GetService("Players").LocalPlayer

_G.CurrentHarvester = _G.CurrentHarvester or nil
_G.CurrentExecutor = _G.CurrentExecutor or nil

local function protect(gui)
    local gethui = gethui or get_hidden_ui or get_hidden_gui
    gui.Name = "GodSuite_V16_" .. math.random(100, 999)
    if gethui then gui.Parent = gethui()
    else gui.Parent = game:GetService("CoreGui") end
end

-- 1. THE RECYCLING EXECUTOR
local function openExecutor(commandCode)
    if _G.CurrentExecutor then _G.CurrentExecutor:Destroy() end
    local sg = Instance.new("ScreenGui"); protect(sg); _G.CurrentExecutor = sg
    local frame = Instance.new("Frame", sg)
    frame.Size = UDim2.new(0.85, 0, 0.5, 0); frame.Position = UDim2.new(0.075, 0, 0.25, 0)
    frame.BackgroundColor3 = Color3.fromRGB(15, 15, 15); frame.Active = true; frame.Draggable = true
    Instance.new("UICorner", frame)

    local title = Instance.new("TextLabel", frame)
    title.Size = UDim2.new(1, 0, 0, 35); title.Text = "COMMAND DEBUGGER"; title.TextColor3 = Color3.new(1,1,1); title.BackgroundColor3 = Color3.fromRGB(30,30,30)

    local box = Instance.new("TextBox", frame)
    box.Size = UDim2.new(1, -20, 0.4, 0); box.Position = UDim2.new(0, 10, 0, 45)
    box.Text = commandCode or ""; box.MultiLine = true; box.TextWrapped = true; box.BackgroundColor3 = Color3.fromRGB(5,5,5); box.TextColor3 = Color3.new(0,1,0.5); box.ClearTextOnFocus = false; box.Font = Enum.Font.Code

    local logBox = Instance.new("TextLabel", frame)
    logBox.Size = UDim2.new(1, -20, 0, 40); logBox.Position = UDim2.new(0, 10, 0.45, 10); logBox.BackgroundColor3 = Color3.fromRGB(0,0,0); logBox.Text = "Status: Ready"; logBox.TextColor3 = Color3.new(0.6,0.6,0.6); logBox.TextWrapped = true

    local execBtn = Instance.new("TextButton", frame)
    execBtn.Size = UDim2.new(0.45, 0, 0, 45); execBtn.Position = UDim2.new(0.02, 0, 0.8, 0); execBtn.Text = "FIRE NOW"; execBtn.BackgroundColor3 = Color3.fromRGB(0, 120, 0); execBtn.TextColor3 = Color3.new(1,1,1)
    execBtn.MouseButton1Click:Connect(function()
        local func, err = loadstring(box.Text)
        if func then
            local success, fault = pcall(func)
            logBox.Text = success and "✅ SUCCESS" or "❌ ERROR: " .. tostring(fault)
            logBox.TextColor3 = success and Color3.new(0,1,0) or Color3.new(1,0,0)
        else
            logBox.Text = "⚠️ SYNTAX: " .. tostring(err); logBox.TextColor3 = Color3.new(1,1,0)
        end
    end)

    local closeBtn = Instance.new("TextButton", frame)
    closeBtn.Size = UDim2.new(0.45, 0, 0, 45); closeBtn.Position = UDim2.new(0.53, 0, 0.8, 0); closeBtn.Text = "CLOSE"; closeBtn.BackgroundColor3 = Color3.fromRGB(120, 0, 0); closeBtn.TextColor3 = Color3.new(1,1,1)
    closeBtn.MouseButton1Click:Connect(function() sg:Destroy(); _G.CurrentExecutor = nil end)
end

-- 2. THE MEGA-HARVESTER
local function openHarvester()
    if _G.CurrentHarvester then _G.CurrentHarvester:Destroy() end
    local sg = Instance.new("ScreenGui"); protect(sg); _G.CurrentHarvester = sg
    local frame = Instance.new("Frame", sg)
    frame.Size = UDim2.new(0.9, 0, 0.75, 0); frame.Position = UDim2.new(0.05, 0, 0.1, 0); frame.BackgroundColor3 = Color3.fromRGB(20, 20, 20); frame.Active = true; frame.Draggable = true

    local title = Instance.new("TextLabel", frame)
    title.Size = UDim2.new(1, 0, 0, 40); title.Text = "GOD-SCANNER (ALL KEYS)"; title.BackgroundColor3 = Color3.fromRGB(120, 0, 255); title.TextColor3 = Color3.new(1,1,1)

    local scroll = Instance.new("ScrollingFrame", frame)
    scroll.Size = UDim2.new(1, -10, 1, -50); scroll.Position = UDim2.new(0, 5, 0, 45); scroll.BackgroundColor3 = Color3.fromRGB(10,10,10); scroll.ScrollBarThickness = 12
    local layout = Instance.new("UIListLayout", scroll); layout.Padding = UDim.new(0, 5)

    local KEYS = {"money", "cash", "gold", "gems", "ruby", "diamond", "coin", "credit", "point", "balance", "soul", "wood", "iron", "stone", "scrap", "token", "rebirth", "multiplier", "boost", "admin", "cmd", "server", "ban", "kick", "dev", "backdoor", "secret", "hack", "bypass", "tp", "teleport", "kill", "damage", "health", "heal", "speed", "fly", "noclip", "hit", "attack", "power", "mana", "chakra", "ki", "magic", "item", "tool", "weapon", "inventory", "stat", "level", "exp", "buy", "sell", "shop", "gift", "code", "egg", "pet", "hatch", "upgrade", "craft", "car", "vehicle", "nitro"}
    
    local count = 0
    for _, v in pairs(game:GetDescendants()) do
        if v:IsA("RemoteEvent") or v:IsA("RemoteFunction") then
            local name = v.Name:lower()
            for _, k in ipairs(KEYS) do
                if name:find(k) then
                    count = count + 1
                    local b = Instance.new("TextButton", scroll)
                    b.Size = UDim2.new(1, -15, 0, 50); b.Text = "["..v.ClassName:sub(1,4).."] "..v.Name; b.BackgroundColor3 = Color3.fromRGB(40,40,40); b.TextColor3 = Color3.new(1,1,1)
                    b.MouseButton1Click:Connect(function()
                        local code = "game." .. v:GetFullName() .. (v:IsA("RemoteEvent") and ":FireServer(game.Players.LocalPlayer)" or ":InvokeServer(game.Players.LocalPlayer)")
                        openExecutor(code)
                    end)
                    break
                end
            end
        end
        if count >= 350 then break end
    end
    scroll.CanvasSize = UDim2.new(0, 0, 0, layout.AbsoluteContentSize.Y + 20)
end

-- 3. MASTER HUB (FLOATING BUTTON)
local function Init()
    local existing = game:GetService("CoreGui"):FindFirstChild("GodSuite_V16_Main")
    if existing then existing:Destroy() end

    local sg = Instance.new("ScreenGui"); protect(sg); sg.Name = "GodSuite_V16_Main"
    local mainBtn = Instance.new("TextButton", sg)
    mainBtn.Size = UDim2.new(0, 75, 0, 75); mainBtn.Position = UDim2.new(0, 10, 0.4, 0); mainBtn.Text = "GOD"; mainBtn.BackgroundColor3 = Color3.fromRGB(120, 0, 255); mainBtn.TextColor3 = Color3.new(1,1,1)
    Instance.new("UICorner", mainBtn).CornerRadius = UDim.new(1, 0)

    local menu = Instance.new("Frame", mainBtn)
    menu.Size = UDim2.new(0, 200, 0, 240); menu.Position = UDim2.new(1, 15, -1, 0); menu.BackgroundColor3 = Color3.fromRGB(25, 25, 25); menu.Visible = false
    Instance.new("UIListLayout", menu).Padding = UDim.new(0, 5)

    local function addOpt(name, fn)
        local b = Instance.new("TextButton", menu)
        b.Size = UDim2.new(1, 0, 0, 50); b.Text = name; b.BackgroundColor3 = Color3.fromRGB(45,45,45); b.TextColor3 = Color3.new(1,1,1)
        b.MouseButton1Click:Connect(fn)
    end

    addOpt("Open Harvester", openHarvester)
    addOpt("Empty Executor", function() openExecutor("") end)
    addOpt("LOAD MOBILE DEX", function()
        menu.Visible = false
        loadstring(game:HttpGet("https://raw.githubusercontent.com/infyiff/backup/main/dex.lua"))()
    end)
    addOpt("Close All", function() if _G.CurrentHarvester then _G.CurrentHarvester:Destroy() end if _G.CurrentExecutor then _G.CurrentExecutor:Destroy() end menu.Visible = false end)

    mainBtn.MouseButton1Click:Connect(function() menu.Visible = not menu.Visible end)
end

task.spawn(Init)
