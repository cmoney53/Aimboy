--[[
    V36: THE SMART-LOG UPDATE
    - LOGGING RESTORED: Status text now appears clearly under the text box.
    - SMART DIAGNOSTICS: Error log now translates Roblox errors into plain English.
      (Example: "Need Value", "Need On/Off", "Need Number").
    - UI CONTROLS: Back, Minimize, Close all active.
    - KEYWORDS: 100% Perserved (Brainrot + logic).
]]

local cloneref = (cloneref or function(...) return ... end)
local game = workspace.Parent
local lp = game:GetService("Players").LocalPlayer
_G.CurrentWindow = nil
_G.Minimized = false

local function protect(gui)
    local gethui = gethui or get_hidden_ui or get_hidden_gui
    gui.Name = "SmartOverlord_V36_" .. math.random(1000, 9999)
    if gethui then gui.Parent = gethui() else gui.Parent = game:GetService("CoreGui") end
end

-- 1. THE MASTER DICTIONARY
local MASTER_KEYS = {"steal", "spawn", "delete", "clear", "remove", "reset", "destroy", "clean", "purge", "wipe", "effects", "particles", "aura", "sound", "stop", "mute", "hide", "show", "toggle", "ritual", "conveyor", "fuse", "craft", "dealer", "baselock", "alert", "thief", "slow", "stripped", "teleportback", "carpet", "redcarpet", "luckyblock", "gingerbread", "winter", "adminabuse", "sammy", "spyder", "ritualspawn", "skibidini", "rizzlerino", "gyattino", "fanum", "mangia", "canta", "balla", "salti", "pomodoro", "mozzarella", "fratello", "sorella", "nonno", "noobini", "pizzanini", "lirili", "larila", "cheese", "fluri", "flura", "talpa", "fero", "svinina", "bombardino", "raccooni", "jandelini", "tartaragno", "pipi", "kiwi", "corni", "trippi", "troppi", "tung", "sahur", "footera", "bandito", "bobritto", "boneca", "ambalabu", "cacto", "hipopotamo", "koala", "tric", "trac", "baraboom", "avocado", "pinealotto", "fruttarino", "cappuccino", "assassino", "axolito", "brr", "patapim", "antilopini", "trulimero", "trulicina", "bambini", "crostini", "malame", "amarele", "bananita", "dolphinita", "perochello", "lemonchello", "bicus", "dicus", "bombicus", "guffo", "mangolini", "parrocini", "frogato", "pirato", "penguino", "cosino", "salamino", "doi", "wombo", "rollo", "mummio", "rappitto", "burbaloni", "loliloli", "chimpazini", "bananini", "ballerina", "cappuccina", "crabracadabra", "cactuseli", "quivioli", "ameleonni", "clickerino", "crabo", "glorbo", "fruttodrillo", "caramello", "filtrello", "potato", "blueberrini", "octopusin", "strawberelli", "flamingelli", "pandaccini", "quackula", "cocosini", "watermelon", "carapace", "sigma", "fuego", "frigo", "camelo", "orangutini", "ananassini", "rhino", "toasterino", "bombardiro", "crocodilo", "brutto", "gialutto", "spioniro", "golubiro", "bombombini", "gusini", "zibra", "zubra", "zibralini", "tigrilini", "watermelini", "avocadorilla", "cavallo", "virtuso", "gorillo", "subwoofero", "lerulerulerule", "ganganzelli", "trulala", "helicopterino", "magi", "ribbitini", "tracoducotulu", "delapeladustuz", "cachorrito", "melonito", "carloo", "elephanto", "jacko", "spaventosa", "carrotini", "centrucci", "nuclucci", "toiletto", "focaccino", "cocofanto", "antonio", "coco", "girafa", "celestre", "gattatino", "nyanino", "chihuanini", "taconini", "matteo", "tralalero", "crocodillitos", "trigoligre", "frutonni", "money", "espresso", "odin", "statutino", "libertino", "tipi", "topi", "taco", "unclito", "samito", "alessio", "orcalero", "orcala", "tralalita", "tukanno", "bananno", "vampira", "trenostruzzo", "turbo", "jack", "urubini", "flamenguini", "capi", "gattito", "tacoto", "traktorito", "tungtungtungcitos", "pakrahmatmamat", "bombinitos", "piccione", "macchina", "pakrahmatmatina", "tortini", "tractoro", "dinosauro", "orcalitos", "crabbo", "limonetta", "orcalita", "cacasito", "satalito", "aquanaut", "tartaruga", "cisterna", "mummy", "squalanana", "snailenzo", "dug", "ninja", "piccionetta", "mastodontico", "telepiedone", "bambu", "anpali", "babel", "polizia", "clownino", "brasilini", "berimbini", "skull", "krupuk", "belula", "beluga", "tentacolo", "tecnico", "pop", "vacca", "staturno", "saturnita", "bisonte", "giuppitere", "matteos", "karkerkar", "kurkur", "jackorilla", "sammyni", "spyderini", "tortuginni", "dragonfrutini", "dul", "blackhole", "goat", "chachechi", "agarrini", "palini", "fragola", "zombie", "tortus", "vulturino", "skeletono", "boatito", "auratito", "chimpanzini", "guerriro", "digitale", "examine", "combinasion", "frankentteo", "karker", "karkeritos", "vaquitas", "trickolino", "perrito", "burrito", "graipuss", "medussi", "hotspot", "jobcitos", "telemorte", "pirulitoita", "bicicleteira", "horegini", "boom", "quesadilla", "chicleteira", "quesadillo", "vampiro", "rang", "ring", "bus", "guest", "666", "mariachi", "corazoni", "swag", "soda", "nuclearo", "dinossauro", "tacorita", "bicicleta", "sis", "spooky", "puggy", "mobilis", "celularcini", "viciosini", "bros", "chillin", "chili", "chipso", "queso", "mieteteira", "traledon", "puggies", "esok", "sekolah", "primos", "eviledon", "ketupat", "kepat", "tictac", "orcaledon", "supreme", "ketchuru", "masturu", "garama", "madundung", "spaghetti", "tualetti", "burguro", "fryuro", "capitano", "moby", "headless", "horseman", "dragon", "cannelloni", "meowl", "elephant", "money", "cash", "gold", "gems", "ruby", "diamond", "coin", "credit", "point", "balance", "soul", "wood", "iron", "stone", "scrap", "candy", "token", "ticket", "bill", "buck", "emerald", "shard", "essence", "sphere", "orb", "ingot", "matter", "dust", "leaf", "star", "medal", "rebirth", "ascend", "multiplier", "boost", "salary", "pay", "tax", "withdraw", "deposit", "bank", "rob", "loot", "pouch", "bag", "wallet", "profit", "yield", "admin", "cmd", "remote", "server", "ban", "kick", "warn", "announce", "shutdown", "config", "debug", "test", "dev", "owner", "backdoor", "root", "sudo", "auth", "access", "bypass", "log", "report", "console", "terminal", "system", "mod", "staff", "panel", "permit", "protocol", "secret", "hack", "exploit", "key", "license", "premium", "vip", "developer", "whitelist", "blacklist", "proxy", "override", "internal", "tp", "teleport", "warp", "goto", "kill", "damage", "health", "heal", "speed", "jump", "fly", "noclip", "cframe", "pos", "hit", "attack", "dodge", "stamina", "energy", "mana", "power", "strength", "gravity", "force", "velocity", "vector", "knockback", "cooldown", "burst", "crit", "defense", "shield", "armor", "cloak", "invisible", "god", "invincible", "ragdoll", "unragdoll", "aim", "fire", "shoot", "reload", "ammo", "mag", "gun", "sword", "swing", "chakra", "ki", "haki", "quirk", "stand", "breath", "magic", "spell", "cast", "summon", "aura", "item", "tool", "weapon", "inventory", "stat", "level", "rank", "exp", "xp", "data", "save", "load", "update", "leaderstat", "value", "set", "change", "buy", "sell", "purchase", "shop", "market", "trade", "gift", "claim", "redeem", "code", "box", "crate", "case", "egg", "pet", "hatch", "rarity", "common", "rare", "epic", "legendary", "mythical", "evolve", "upgrade", "fusion", "craft", "blueprint", "material", "ingredient"}

local openHarvester

local function addControls(frame, titleText, backFunc)
    local bar = Instance.new("Frame", frame)
    bar.Size = UDim2.new(1, 0, 0, 35); bar.BackgroundColor3 = Color3.fromRGB(30,30,30); bar.BorderSizePixel = 0
    local title = Instance.new("TextLabel", bar)
    title.Size = UDim2.new(0.4, 0, 1, 0); title.Position = UDim2.new(0, backFunc and 45 or 10, 0, 0)
    title.Text = titleText; title.TextColor3 = Color3.new(1,1,1); title.BackgroundTransparency = 1; title.TextXAlignment = 0
    local close = Instance.new("TextButton", bar)
    close.Size = UDim2.new(0, 35, 0, 35); close.Position = UDim2.new(1, -35, 0, 0); close.Text = "X"; close.BackgroundColor3 = Color3.fromRGB(150,0,0); close.TextColor3 = Color3.new(1,1,1)
    close.MouseButton1Click:Connect(function() frame.Parent:Destroy(); _G.CurrentWindow = nil end)
    local min = Instance.new("TextButton", bar)
    min.Size = UDim2.new(0, 35, 0, 35); min.Position = UDim2.new(1, -75, 0, 0); min.Text = "-"; min.BackgroundColor3 = Color3.fromRGB(60,60,60); min.TextColor3 = Color3.new(1,1,1)
    min.MouseButton1Click:Connect(function() frame.Visible = false; _G.Minimized = true end)
    if backFunc then
        local b = Instance.new("TextButton", bar)
        b.Size = UDim2.new(0, 35, 0, 35); b.Text = "<"; b.BackgroundColor3 = Color3.fromRGB(50,50,50); b.TextColor3 = Color3.new(1,1,1)
        b.MouseButton1Click:Connect(backFunc)
    end
end

-- 2. SMART ERROR ANALYZER
local function analyzeError(err)
    err = tostring(err):lower()
    if err:find("boolean") then return "⚠️ ISSUE: Need 'On' or 'Off' (true/false)" end
    if err:find("string") then return "⚠️ ISSUE: Need a Value in quotes (like \"100\")" end
    if err:find("number") then return "⚠️ ISSUE: Need a Number (no quotes)" end
    if err:find("nil") then return "⚠️ ISSUE: Missing Info (nil)" end
    if err:find("argument 1") then return "⚠️ ISSUE: Target missing (LocalPlayer?)" end
    return "❌ ERROR: " .. err:sub(1,40)
end

-- 3. EXECUTOR WINDOW
local function openExec(remote, codeOverride)
    if _G.CurrentWindow then _G.CurrentWindow:Destroy() end
    local sg = Instance.new("ScreenGui"); protect(sg); _G.CurrentWindow = sg
    local frame = Instance.new("Frame", sg)
    frame.Size = UDim2.new(0.85, 0, 0.6, 0); frame.Position = UDim2.new(0.075, 0, 0.2, 0); frame.BackgroundColor3 = Color3.fromRGB(15,15,15); frame.Active = true; frame.Draggable = true
    Instance.new("UICorner", frame)

    addControls(frame, "EXECUTOR", function() openHarvester() end)

    local box = Instance.new("TextBox", frame)
    box.Size = UDim2.new(1, -20, 0.4, 0); box.Position = UDim2.new(0, 10, 0, 45)
    if remote then
        local method = remote:IsA("RemoteEvent") and "FireServer" or "InvokeServer"
        box.Text = "game." .. remote:GetFullName() .. ":" .. method .. "(game.Players.LocalPlayer)"
    else box.Text = codeOverride or "" end
    box.MultiLine = true; box.TextWrapped = true; box.BackgroundColor3 = Color3.fromRGB(5,5,5); box.TextColor3 = Color3.new(0,1,0.5); box.ClearTextOnFocus = false

    -- RESTORED LOG PANEL
    local log = Instance.new("TextLabel", frame)
    log.Size = UDim2.new(1, -20, 0, 60); log.Position = UDim2.new(0, 10, 0.45, 45)
    log.Text = "Status: Awaiting Command"; log.TextColor3 = Color3.new(1,1,1); log.BackgroundTransparency = 0.9; log.BackgroundColor3 = Color3.new(0,0,0)
    log.TextWrapped = true; log.TextSize = 14; Instance.new("UICorner", log)

    local fire = Instance.new("TextButton", frame)
    fire.Size = UDim2.new(0.9, 0, 0, 45); fire.Position = UDim2.new(0.05, 0, 0.85, 0); fire.Text = "FIX & FIRE"; fire.BackgroundColor3 = Color3.fromRGB(0,150,0); fire.TextColor3 = Color3.new(1,1,1)
    fire.MouseButton1Click:Connect(function()
        local code = box.Text:gsub("“", '"'):gsub("”", '"'):gsub("‘", "'"):gsub("’", "'")
        local func, err = loadstring(code)
        if func then
            task.spawn(function()
                local s, f = pcall(func)
                if s then 
                    log.Text = "✅ SUCCESS: Command Sent!"; log.TextColor3 = Color3.new(0,1,0)
                else 
                    log.Text = analyzeError(f); log.TextColor3 = Color3.new(1,0,0)
                end
            end)
        else
            log.Text = "⚠️ CODE ERROR: Fix your typing!"; log.TextColor3 = Color3.new(1,1,0)
        end
    end)
end

-- 4. HARVESTER
openHarvester = function()
    if _G.CurrentWindow then _G.CurrentWindow:Destroy() end
    local sg = Instance.new("ScreenGui"); protect(sg); _G.CurrentWindow = sg
    local frame = Instance.new("Frame", sg)
    frame.Size = UDim2.new(0.9, 0, 0.8, 0); frame.Position = UDim2.new(0.05, 0, 0.1, 0); frame.BackgroundColor3 = Color3.fromRGB(20,20,20); frame.Active = true; frame.Draggable = true
    addControls(frame, "HARVESTER", nil)
    local scroll = Instance.new("ScrollingFrame", frame)
    scroll.Size = UDim2.new(1, -10, 1, -45); scroll.Position = UDim2.new(0, 5, 0, 40); scroll.BackgroundColor3 = Color3.fromRGB(10,10,10); scroll.ScrollBarThickness = 12
    local layout = Instance.new("UIListLayout", scroll); layout.Padding = UDim.new(0, 5)

    for _, v in pairs(game:GetDescendants()) do
        if v:IsA("RemoteEvent") or v:IsA("RemoteFunction") then
            local n = v.Name:lower()
            for _, k in ipairs(MASTER_KEYS) do
                if n:find(k) then
                    local b = Instance.new("TextButton", scroll)
                    b.Size = UDim2.new(1, -15, 0, 55); b.Text = "["..v.ClassName:sub(1,4).."] "..v.Name; b.BackgroundColor3 = Color3.fromRGB(40,40,40); b.TextColor3 = Color3.new(1,1,1)
                    b.MouseButton1Click:Connect(function() openExec(v) end)
                    break
                end
            end
        end
    end
    scroll.CanvasSize = UDim2.new(0, 0, 0, layout.AbsoluteContentSize.Y + 20)
end

-- 5. HUB
local trigger = Instance.new("ScreenGui"); protect(trigger)
local btn = Instance.new("TextButton", trigger)
btn.Size = UDim2.new(0, 75, 0, 75); btn.Position = UDim2.new(0, 10, 0.4, 0); btn.Text = "GOD"; btn.BackgroundColor3 = Color3.fromRGB(150, 0, 255); btn.TextColor3 = Color3.new(1,1,1)
Instance.new("UICorner", btn).CornerRadius = UDim.new(1, 0)
local menu = Instance.new("Frame", btn)
menu.Size = UDim2.new(0, 180, 0, 160); menu.Position = UDim2.new(1, 10, -0.5, 0); menu.Visible = false; menu.BackgroundColor3 = Color3.fromRGB(30,30,30)
Instance.new("UIListLayout", menu)
local function opt(n, f)
    local b = Instance.new("TextButton", menu)
    b.Size = UDim2.new(1, 0, 0, 53); b.Text = n; b.BackgroundColor3 = Color3.fromRGB(45,45,45); b.TextColor3 = Color3.new(1,1,1)
    b.MouseButton1Click:Connect(f)
end
opt("Harvester", function() if _G.Minimized and _G.CurrentWindow then _G.CurrentWindow.Frame.Visible = true; _G.Minimized = false else openHarvester() end end)
opt("Mobile Dex", function() loadstring(game:HttpGet("https://raw.githubusercontent.com/infyiff/backup/main/dex.lua"))() end)
opt("Code Exec", function() openExec(nil, "") end)
btn.MouseButton1Click:Connect(function() menu.Visible = not menu.Visible end)
