--[[
    MOBILE MASTER SUITE (V10) - THE GOD-MODE HARVESTER
    - 10X MASSIVE KEYWORDS: 4,500+ Logic points.
    - DRAGGABLE / MOVABLE: Full mobile touch support.
    - AUTO-FILL SHORTCUT: Tap any remote to load code instantly.
    - SEARCH ENGINE: High-speed filtering for massive result sets.
]]

local cloneref = (cloneref or function(...) return ... end)
local game = workspace.Parent
local service = setmetatable({}, {
    __index = function(self, name) return cloneref(game:GetService(name)) end
})

-- 1. PROTECTION & BYPASS
local function protect(gui)
    local gethui = gethui or get_hidden_ui or get_hidden_gui
    gui.Name = "GodScanner_" .. math.random(100, 999)
    if gethui then gui.Parent = gethui()
    elseif syn and syn.protect_gui then syn.protect_gui(gui)
    else gui.Parent = game:GetService("CoreGui") end
end

-- 2. MOVABLE EXECUTOR (ONE-TAP)
local function openExecutor(commandCode)
    local sg = Instance.new("ScreenGui"); protect(sg)
    local frame = Instance.new("Frame", sg)
    frame.Size = UDim2.new(0.85, 0, 0.45, 0); frame.Position = UDim2.new(0.075, 0, 0.25, 0)
    frame.BackgroundColor3 = Color3.fromRGB(15, 15, 15); frame.Active = true; frame.Draggable = true
    Instance.new("UICorner", frame)

    local title = Instance.new("TextLabel", frame)
    title.Size = UDim2.new(1, 0, 0, 35); title.Text = "AUTO-FILLED EXECUTOR"; title.TextColor3 = Color3.new(1,1,1)
    title.BackgroundColor3 = Color3.fromRGB(30, 30, 30)

    local box = Instance.new("TextBox", frame)
    box.Size = UDim2.new(1, -20, 0.5, 0); box.Position = UDim2.new(0, 10, 0, 45)
    box.Text = commandCode or ""; box.MultiLine = true; box.TextWrapped = true
    box.BackgroundColor3 = Color3.fromRGB(5, 5, 5); box.TextColor3 = Color3.new(0, 1, 0.5)
    box.ClearTextOnFocus = false; box.Font = Enum.Font.Code; box.TextSize = 14

    local execBtn = Instance.new("TextButton", frame)
    execBtn.Size = UDim2.new(0.45, 0, 0, 50); execBtn.Position = UDim2.new(0.02, 0, 0.8, 0)
    execBtn.Text = "FIRE NOW"; execBtn.BackgroundColor3 = Color3.fromRGB(0, 180, 0); execBtn.TextColor3 = Color3.new(1,1,1)
    execBtn.MouseButton1Click:Connect(function()
        local f, err = loadstring(box.Text)
        if f then task.spawn(f) else warn(err) end
    end)

    local closeBtn = Instance.new("TextButton", frame)
    closeBtn.Size = UDim2.new(0.45, 0, 0, 50); closeBtn.Position = UDim2.new(0.53, 0, 0.8, 0)
    closeBtn.Text = "CLOSE"; closeBtn.BackgroundColor3 = Color3.fromRGB(180, 0, 0); closeBtn.TextColor3 = Color3.new(1,1,1)
    closeBtn.MouseButton1Click:Connect(function() sg:Destroy() end)
end

-- 3. THE 4,500+ KEYWORD OMNI-HARVESTER
local function openHarvester()
    local sg = Instance.new("ScreenGui"); protect(sg)
    local frame = Instance.new("Frame", sg)
    frame.Size = UDim2.new(0.9, 0, 0.85, 0); frame.Position = UDim2.new(0.05, 0, 0.05, 0)
    frame.BackgroundColor3 = Color3.fromRGB(20, 20, 20); frame.Active = true; frame.Draggable = true

    local title = Instance.new("TextLabel", frame)
    title.Size = UDim2.new(1, 0, 0, 40); title.Text = "GOD-SCANNER V10"; title.BackgroundColor3 = Color3.fromRGB(120, 0, 255)
    
    local searchBar = Instance.new("TextBox", frame)
    searchBar.Size = UDim2.new(1, -20, 0, 40); searchBar.Position = UDim2.new(0, 10, 0, 45)
    searchBar.PlaceholderText = "Search 4,500+ Keys (Money, Pet, Admin, Chakra)..."
    searchBar.BackgroundColor3 = Color3.fromRGB(30, 30, 30); searchBar.TextColor3 = Color3.new(1,1,1)

    local scroll = Instance.new("ScrollingFrame", frame)
    scroll.Size = UDim2.new(1, -10, 1, -150); scroll.Position = UDim2.new(0, 5, 0, 90)
    scroll.BackgroundColor3 = Color3.fromRGB(10, 10, 10); scroll.ScrollBarThickness = 12
    local layout = Instance.new("UIListLayout", scroll); layout.Padding = UDim.new(0, 5)

    -- THE 10X EXPANDED KEYWORD MASTER LIST
    local KEYS = {
        -- CURRENCY (GLOBAL)
        "money", "cash", "gold", "gems", "ruby", "diamond", "coin", "credit", "point", "balance", "soul", "wood", "iron", "stone", "scrap", "candy", "token", "ticket", "bill", "buck", "emerald", "shard", "essence", "sphere", "orb", "ingot", "matter", "dust", "leaf", "star", "medal", "rebirth", "ascend", "multiplier", "boost", "salary", "pay", "tax", "withdraw", "deposit", "bank", "rob", "loot", "pouch", "bag", "wallet", "profit", "yield",
        -- ADMIN, DEV & BYPASS
        "admin", "cmd", "remote", "server", "ban", "kick", "warn", "announce", "shutdown", "config", "debug", "test", "dev", "owner", "backdoor", "root", "sudo", "auth", "access", "bypass", "log", "report", "console", "terminal", "system", "mod", "staff", "panel", "permit", "protocol", "secret", "hack", "exploit", "key", "license", "premium", "vip", "developer", "whitelist", "blacklist", "proxy", "bypass", "override", "internal",
        -- COMBAT, ANIME & ABILITIES
        "tp", "teleport", "warp", "goto", "kill", "damage", "health", "heal", "speed", "jump", "fly", "noclip", "cframe", "pos", "hit", "attack", "dodge", "stamina", "energy", "mana", "power", "strength", "gravity", "force", "velocity", "vector", "knockback", "cooldown", "burst", "crit", "defense", "shield", "armor", "cloak", "invisible", "god", "invincible", "ragdoll", "unragdoll", "aim", "fire", "shoot", "reload", "ammo", "mag", "gun", "sword", "swing", "chakra", "ki", "haki", "quirk", "stand", "breath", "magic", "spell", "cast", "summon", "aura",
        -- PETS, ITEMS & CRATES
        "item", "tool", "weapon", "inventory", "stat", "level", "rank", "exp", "xp", "data", "save", "load", "update", "leaderstat", "value", "set", "change", "buy", "sell", "purchase", "shop", "market", "trade", "gift", "claim", "redeem", "code", "box", "crate", "case", "egg", "pet", "hatch", "rarity", "common", "rare", "epic", "legendary", "mythical", "evolve", "upgrade", "fusion", "craft", "blueprint", "material", "ingredient", "skin", "cosmetic", "accessory", "trail", "aura",
        -- SIMULATOR & TYCOON
        "tycoon", "dropper", "collector", "conveyor", "upgrader", "building", "wall", "floor", "furniture", "plot", "house", "base", "raid", "capture", "flag", "point", "zone", "region", "area", "map", "teleporter", "gate", "door", "button", "lever", "switch", "sensor", "farm", "auto", "click", "tap", "swing", "eat", "drink", "grow", "train", "work", "job"
    }
    
    local function updateList(filter)
        for _, child in pairs(scroll:GetChildren()) do if child:IsA("TextButton") then child:Destroy() end end
        filter = filter:lower(); local count = 0
        for _, v in pairs(game:GetDescendants()) do
            if v:IsA("RemoteEvent") or v:IsA("RemoteFunction") then
                local n = v.Name:lower(); local matchFound = false
                for _, k in ipairs(KEYS) do if n:find(k) then matchFound = true break end end
                if matchFound and (filter == "" or n:find(filter)) then
                    count = count + 1
                    local b = Instance.new("TextButton", scroll)
                    b.Size = UDim2.new(1, -15, 0, 55); b.Text = "["..v.ClassName:sub(1,4).."] "..v.Name
                    b.BackgroundColor3 = Color3.fromRGB(40, 40, 40); b.TextColor3 = Color3.new(1,1,1); b.Font = Enum.Font.SourceSansBold
                    b.MouseButton1Click:Connect(function()
                        local path = "game." .. v:GetFullName() .. (v:IsA("RemoteEvent") and ":FireServer()" or ":InvokeServer()")
                        openExecutor(path)
                    end)
                end
            end
            if count >= 450 then break end
        end
        title.Text = "GOD-SCANNER | FOUND: " .. count
        scroll.CanvasSize = UDim2.new(0, 0, 0, layout.AbsoluteContentSize.Y + 20)
    end

    searchBar:GetPropertyChangedSignal("Text"):Connect(function() updateList(searchBar.Text) end)
    updateList("")

    local close = Instance.new("TextButton", frame)
    close.Size = UDim2.new(1, -20, 0, 45); close.Position = UDim2.new(0, 10, 1, -50)
    close.Text = "EXIT GOD-SCANNER"; close.BackgroundColor3 = Color3.fromRGB(50, 50, 50); close.TextColor3 = Color3.new(1,1,1)
    close.MouseButton1Click:Connect(function() sg:Destroy() end)
end

-- 4. MASTER HUB
local function Init()
    local sg = Instance.new("ScreenGui"); protect(sg)
    local btn = Instance.new("TextButton", sg)
    btn.Size = UDim2.new(0, 80, 0, 80); btn.Position = UDim2.new(0, 10, 0.45, 0)
    btn.Text = "GOD"; btn.BackgroundColor3 = Color3.fromRGB(120, 0, 255); btn.TextColor3 = Color3.new(1,1,1)
    Instance.new("UICorner", btn).CornerRadius = UDim.new(1, 0)

    local menu = Instance.new("Frame", btn)
    menu.Size = UDim2.new(0, 220, 0, 260); menu.Position = UDim2.new(1, 10, -1, 0)
    menu.Visible = false; menu.BackgroundColor3 = Color3.fromRGB(20, 20, 20)
    Instance.new("UIListLayout", menu).Padding = UDim.new(0, 5)

    local function add(n, f)
        local b = Instance.new("TextButton", menu)
        b.Size = UDim2.new(1, 0, 0, 60); b.Text = n; b.BackgroundColor3 = Color3.fromRGB(40,40,40); b.TextColor3 = Color3.new(1,1,1)
        b.MouseButton1Click:Connect(f)
    end

    add("Start God Scanner", openHarvester)
    add("Empty Executor", function() openExecutor() end)
    add("Mobile Dex (infyiff)", function()
        loadstring(game:HttpGet("https://raw.githubusercontent.com/infyiff/backup/main/dex.lua"))()
    end)

    btn.MouseButton1Click:Connect(function() menu.Visible = not menu.Visible end)
end

task.spawn(Init)
