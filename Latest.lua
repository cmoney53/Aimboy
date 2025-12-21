--[[
    DEX MOBILE: MASTER DEVELOPER EDITION
    Optimized for: Delta, Fluxus, Arceus X, Hydrogen, and Cod3x
    Integrated: Universal Harvester, Mobile Executor, and Hidden GUI Finder
]]

local cloneref = (cloneref or function(...) return ... end)
local game = workspace.Parent
local service = setmetatable({}, {
    __index = function(self, name) return cloneref(game:GetService(name)) end
})

-- 1. MOBILE STEALTH & TOUCH-FIX
local dexName = "MobileSuite_" .. math.random(100, 999)
local gethui = gethui or get_hidden_ui or get_hidden_gui
local function protect(gui)
    gui.Name = dexName
    if gethui then gui.Parent = gethui()
    elseif syn and syn.protect_gui then syn.protect_gui(gui)
    else gui.Parent = service.CoreGui end
end

-- 2. UNIVERSAL HARVESTER LOGIC (Mobile Optimized)
local KEYWORDS = {
    "money", "cash", "gold", "gems", "add", "give", "admin", "cmd", 
    "tp", "teleport", "kill", "ban", "spawn", "item", "inventory"
}

local function RunMobileHarvest()
    local found = "-- [[ MOBILE HARVEST RESULTS ]] --\n\n"
    local count = 0
    for _, v in pairs(game:GetDescendants()) do
        if v:IsA("RemoteEvent") or v:IsA("RemoteFunction") then
            local n = v.Name:lower()
            for _, key in ipairs(KEYWORDS) do
                if n:find(key) then
                    found = found .. "-- Found: " .. v.Name .. "\n"
                    found = found .. "game." .. v:GetFullName() .. (v:IsA("RemoteEvent") and ":FireServer()" or ":InvokeServer()") .. "\n\n"
                    count = count + 1
                    break
                end
            end
        end
        if count > 30 then break end -- Prevent mobile lag
    end
    return found
end

-- 3. MOBILE EXECUTOR UI (Large Touch Targets)
local function OpenMobileExecutor(defaultTxt)
    local sg = Instance.new("ScreenGui"); protect(sg)
    local frame = Instance.new("Frame", sg)
    frame.Size = UDim2.new(0.9, 0, 0.6, 0)
    frame.Position = UDim2.new(0.05, 0, 0.2, 0)
    frame.BackgroundColor3 = Color3.fromRGB(25, 25, 25)
    frame.Active = true; frame.Draggable = true

    local box = Instance.new("TextBox", frame)
    box.Size = UDim2.new(1, -20, 0.7, 0); box.Position = UDim2.new(0, 10, 0, 10)
    box.Text = defaultTxt or "-- Type or Paste Code Here"
    box.MultiLine = true; box.TextWrapped = true; box.ClearTextOnFocus = false
    box.BackgroundColor3 = Color3.fromRGB(15, 15, 15); box.TextColor3 = Color3.new(0, 1, 0)
    box.TextSize = 14; box.Font = Enum.Font.Code; box.TextYAlignment = Enum.TextYAlignment.Top

    local run = Instance.new("TextButton", frame)
    run.Size = UDim2.new(0.45, 0, 0, 60); run.Position = UDim2.new(0, 10, 0.8, 0)
    run.Text = "EXECUTE"; run.BackgroundColor3 = Color3.fromRGB(0, 120, 215); run.TextColor3 = Color3.new(1, 1, 1)
    run.MouseButton1Click:Connect(function() loadstring(box.Text)() end)

    local close = Instance.new("TextButton", frame)
    close.Size = UDim2.new(0.45, 0, 0, 60); close.Position = UDim2.new(0.53, 0, 0.8, 0)
    close.Text = "CLOSE"; close.BackgroundColor3 = Color3.fromRGB(150, 0, 0); close.TextColor3 = Color3.new(1, 1, 1)
    close.MouseButton1Click:Connect(function() sg:Destroy() end)
end

-- 4. THE HUB (Main Mobile Toggle)
local function InitMobileSuite()
    local sg = Instance.new("ScreenGui"); protect(sg)
    
    local btn = Instance.new("TextButton", sg)
    btn.Size = UDim2.new(0, 70, 0, 70) -- Big circle for thumbs
    btn.Position = UDim2.new(0, 5, 0.4, 0)
    btn.Text = "DEV"; btn.BackgroundColor3 = Color3.fromRGB(40, 40, 40); btn.TextColor3 = Color3.new(1,1,1)
    Instance.new("UICorner", btn).CornerRadius = UDim.new(1, 0)

    local menu = Instance.new("Frame", btn)
    menu.Size = UDim2.new(0, 220, 0, 250); menu.Position = UDim2.new(1, 10, -1, 0)
    menu.Visible = false; menu.BackgroundColor3 = Color3.fromRGB(30, 30, 30)
    local list = Instance.new("UIListLayout", menu); list.Padding = UDim.new(0, 5)

    local function addOpt(name, fn)
        local b = Instance.new("TextButton", menu)
        b.Size = UDim2.new(1, 0, 0, 55); b.Text = name
        b.BackgroundColor3 = Color3.fromRGB(50, 50, 50); b.TextColor3 = Color3.new(1,1,1)
        b.MouseButton1Click:Connect(fn)
    end

    addOpt("Harvest Money/Cmds", function() OpenMobileExecutor(RunMobileHarvest()) end)
    addOpt("Reveal Hidden GUIs", function()
        for _, v in pairs(game:GetDescendants()) do
            if v:IsA("ScreenGui") then v.Enabled = true elseif v:IsA("GuiObject") then v.Visible = true end
        end
    end)
    addOpt("Open Mobile Exec", function() OpenMobileExecutor() end)
    addOpt("Load Full Mobile Dex", function()
        loadstring(game:HttpGet("https://raw.githubusercontent.com/infyiff/backup/main/dex.lua"))()
    end)

    btn.MouseButton1Click:Connect(function() menu.Visible = not menu.Visible end)
end

task.spawn(InitMobileSuite)
print("Mobile Developer Suite Loaded Successfully.")
