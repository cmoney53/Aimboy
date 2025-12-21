a

--[[
    ULTIMATE DEVELOPER DEX WRAPPER
    Base: LorekeeperZinnia Dex
    Features: Remote Spy, Money Finder, Hidden GUI Reveal, Mid-Game Executor
]]

local cloneref = (cloneref or function(...) return ... end)
local game = workspace.Parent
local service = setmetatable({}, {
    __index = function(self, name)
        return cloneref(game:GetService(name))
    end
})

-- 1. STEALTH & PROTECTION
local dexName = "DevSuite_" .. math.random(100, 999)
local gethui = gethui or get_hidden_ui or get_hidden_gui
local function protect(gui)
    gui.Name = dexName
    if gethui then gui.Parent = gethui()
    elseif syn and syn.protect_gui then syn.protect_gui(gui)
    else gui.Parent = service.CoreGui end
end

-- 2. SCANNER LOGIC (SUSPICIOUS COMMANDS & MONEY)
local KEYWORDS = {
    "money", "cash", "gold", "gems", "currency", "add", "give", "reward",
    "teleport", "tp", "admin", "cmd", "ban", "kick", "kill", "spawn"
}

local function RunDeepScan()
    local results = "-- [[ SCANNER FOUND EXPLOITABLE REMOTES ]] --\n\n"
    local found = 0
    for _, v in pairs(game:GetDescendants()) do
        if v:IsA("RemoteEvent") or v:IsA("RemoteFunction") then
            local name = v.Name:lower()
            for _, key in ipairs(KEYWORDS) do
                if name:find(key) then
                    results = results .. "-- Target: " .. v.Name .. " (" .. v.ClassName .. ")\n"
                    results = results .. "game." .. v:GetFullName() .. (v:IsA("RemoteEvent") and ":FireServer(" or ":InvokeServer(") .. ")\n\n"
                    found = found + 1
                    break
                end
            end
        end
    end
    return (found > 0 and results or "-- No suspicious remotes found.")
end

-- 3. GUI REVEALER
local function RevealAll()
    local c = 0
    for _, v in pairs(game:GetDescendants()) do
        if v:IsA("ScreenGui") then
            v.Enabled = true; c = c + 1
        elseif v:IsA("GuiObject") then
            v.Visible = true; v.Transparency = 0
        end
    end
    print("[Dex Dev] Forced " .. c .. " GUIs to show.")
end

-- 4. THE INTERFACE
local function OpenExecutor(txt)
    local sg = Instance.new("ScreenGui"); protect(sg)
    local f = Instance.new("Frame", sg)
    f.Size = UDim2.new(0, 450, 0, 300); f.Position = UDim2.new(0.5, -225, 0.5, -150)
    f.BackgroundColor3 = Color3.fromRGB(30,30,30); f.Active = true; f.Draggable = true
    
    local t = Instance.new("TextBox", f)
    t.Size = UDim2.new(1, -20, 1, -100); t.Position = UDim2.new(0, 10, 0, 40)
    t.Text = txt or "-- Mid-Game Scripting"; t.MultiLine = true; t.TextWrapped = true
    t.BackgroundColor3 = Color3.fromRGB(20,20,20); t.TextColor3 = Color3.new(0,1,0); t.ClearTextOnFocus = false
    
    local run = Instance.new("TextButton", f)
    run.Size = UDim2.new(0, 210, 0, 40); run.Position = UDim2.new(0, 10, 1, -50)
    run.Text = "EXECUTE"; run.BackgroundColor3 = Color3.fromRGB(0, 120, 215); run.TextColor3 = Color3.new(1,1,1)
    run.MouseButton1Click:Connect(function() loadstring(t.Text)() end)

    local close = Instance.new("TextButton", f)
    close.Size = UDim2.new(0, 210, 0, 40); close.Position = UDim2.new(1, -220, 1, -50)
    close.Text = "CLOSE"; close.BackgroundColor3 = Color3.fromRGB(150, 0, 0); close.TextColor3 = Color3.new(1,1,1)
    close.MouseButton1Click:Connect(function() sg:Destroy() end)
end

-- 5. THE MASTER TOGGLE
local function Init()
    local sg = Instance.new("ScreenGui"); protect(sg)
    local btn = Instance.new("TextButton", sg)
    btn.Size = UDim2.new(0, 100, 0, 40); btn.Position = UDim2.new(0, 10, 0.4, 0)
    btn.Text = "DEV PANEL"; btn.BackgroundColor3 = Color3.fromRGB(45,45,45); btn.TextColor3 = Color3.new(1,1,1)

    local menu = Instance.new("Frame", btn)
    menu.Size = UDim2.new(0, 200, 0, 200); menu.Position = UDim2.new(1, 10, 0, 0)
    menu.Visible = false; menu.BackgroundColor3 = Color3.fromRGB(35,35,35)
    local l = Instance.new("UIListLayout", menu)

    local function add(n, fn)
        local b = Instance.new("TextButton", menu)
        b.Size = UDim2.new(1, 0, 0, 50); b.Text = n
        b.BackgroundColor3 = Color3.fromRGB(55,55,55); b.TextColor3 = Color3.new(1,1,1)
        b.MouseButton1Click:Connect(fn)
    end

    add("Scan for Money/Cmds", function() OpenExecutor(RunDeepScan()) end)
    add("Reveal Hidden GUIs", RevealAll)
    add("Open Blank Executor", function() OpenExecutor() end)
    add("Load Original Dex", function()
        loadstring(game:HttpGet("https://raw.githubusercontent.com/LorekeeperZinnia/Dex/master/main.lua"))()
    end)

    btn.MouseButton1Click:Connect(function() menu.Visible = not menu.Visible end)
end

task.spawn(Init)
print("Dex Developer Toolset Loaded.")
