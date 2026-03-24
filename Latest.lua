local ScreenGui = Instance.new("ScreenGui")
local MainFrame = Instance.new("Frame")
local UICornerMain = Instance.new("UICorner")
local Title = Instance.new("TextLabel")
local ScrollingFrame = Instance.new("ScrollingFrame")
local ButtonLayout = Instance.new("UIListLayout")
local UIPadding = Instance.new("UIPadding")

-- Setup ScreenGui
ScreenGui.Parent = game.Players.LocalPlayer:WaitForChild("PlayerGui")
ScreenGui.ResetOnSpawn = false
ScreenGui.Name = "CashmereHub"

-- Main Window
MainFrame.Name = "MainFrame"
MainFrame.Parent = ScreenGui
MainFrame.BackgroundColor3 = Color3.fromRGB(20, 20, 20) -- Sleek dark background
MainFrame.Position = UDim2.new(0.5, -110, 0.5, -150)
MainFrame.Size = UDim2.new(0, 220, 0, 320)
MainFrame.Active = true
MainFrame.Draggable = true

UICornerMain.CornerRadius = UDim.new(0, 12)
UICornerMain.Parent = MainFrame

-- Title
Title.Parent = MainFrame
Title.Size = UDim2.new(1, 0, 0, 50)
Title.Text = "CASHMERE HUB"
Title.TextColor3 = Color3.fromRGB(0, 255, 120) -- Neon Green
Title.TextSize = 20
Title.Font = Enum.Font.GothamBold
Title.BackgroundTransparency = 1

-- Scrollable Area
ScrollingFrame.Parent = MainFrame
ScrollingFrame.Position = UDim2.new(0, 0, 0, 50)
ScrollingFrame.Size = UDim2.new(1, 0, 1, -60)
ScrollingFrame.BackgroundTransparency = 1
ScrollingFrame.ScrollBarThickness = 2
ScrollingFrame.CanvasSize = UDim2.new(0, 0, 2, 0)

ButtonLayout.Parent = ScrollingFrame
ButtonLayout.HorizontalAlignment = Enum.HorizontalAlignment.Center
ButtonLayout.Padding = UDim.new(0, 10)

UIPadding.Parent = ScrollingFrame
UIPadding.PaddingTop = UDim.new(0, 5)

-- Function to create Neon Buttons
local function CreateScriptButton(Name, URL)
    local Button = Instance.new("TextButton")
    local UICornerBtn = Instance.new("UICorner")
    local UIStroke = Instance.new("UIStroke")

    Button.Parent = ScrollingFrame
    Button.Size = UDim2.new(0.85, 0, 0, 40)
    Button.Text = Name
    Button.BackgroundColor3 = Color3.fromRGB(30, 30, 30)
    Button.TextColor3 = Color3.fromRGB(0, 255, 120) -- Green Text
    Button.Font = Enum.Font.GothamSemibold
    Button.TextSize = 14
    Button.AutoButtonColor = true

    UICornerBtn.CornerRadius = UDim.new(0, 8)
    UICornerBtn.Parent = Button

    -- Neon Border Effect
    UIStroke.Parent = Button
    UIStroke.Thickness = 2
    UIStroke.Color = Color3.fromRGB(0, 255, 120) -- Neon Green Border
    UIStroke.ApplyStrokeMode = Enum.ApplyStrokeMode.Border

    Button.MouseButton1Click:Connect(function()
        print("Executing: " .. Name)
        local success, err = pcall(function()
            loadstring(game:HttpGet(URL, true))()
        end)
        if not success then
            warn("Error: " .. err)
        end
    end)
end

--- ADD YOUR SCRIPTS HERE ---
CreateScriptButton("Aimbot", "https://raw.githubusercontent.com/cmoney53/Aimboy/refs/heads/main/Aimbot.lua")
CreateScriptButton("Modded Yield", "https://raw.githubusercontent.com/cmoney53/Aimboy/refs/heads/main/commando.lua")
CreateScriptButton("bronx", "https://raw.githubusercontent.com/cmoney53/Aimboy/refs/heads/main/blocker.lua")
CreateScriptButton("BALB", "--[[
	WARNING: Heads up! This script has not been verified by ScriptBlox. Use at your own risk!
]]
local Fluent = loadstring(game:HttpGet("https://github.com/dawid-scripts/Fluent/releases/latest/download/main.lua"))()
local SaveManager = loadstring(game:HttpGet("https://raw.githubusercontent.com/dawid-scripts/Fluent/master/Addons/SaveManager.lua"))()
local InterfaceManager = loadstring(game:HttpGet("https://raw.githubusercontent.com/dawid-scripts/Fluent/master/Addons/InterfaceManager.lua"))()
local Window = Fluent:CreateWindow({
    Title = "Be a Lucky Block",
    SubTitle = "by Phemonaz",
    TabWidth = 160,
    Size = UDim2.fromOffset(550, 430),
    Acrylic = false,
    Theme = "Darker",
    MinimizeKey = Enum.KeyCode.LeftControl
})
local Tabs = {
    Main = Window:AddTab({ Title = "Main", Icon = "box" }),
    Upgrades = Window:AddTab({ Title = "Upgrades", Icon = "gauge" }),
    Brainrots = Window:AddTab({ Title = "Brainrots", Icon = "bot" }),
    Stats = Window:AddTab({ Title = "Stats", Icon = "chart-column" }),
    Settings = Window:AddTab({ Title = "Settings", Icon = "settings" })
}



local Options = Fluent.Options
do
-----
-----
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local claimGift = ReplicatedStorage
    :WaitForChild("Packages")
    :WaitForChild("_Index")
    :WaitForChild("sleitnick_knit@1.7.0")
    :WaitForChild("knit")
    :WaitForChild("Services")
    :WaitForChild("PlaytimeRewardService")
    :WaitForChild("RF")
    :WaitForChild("ClaimGift")
local autoClaiming = false
local ACPR = Tabs.Main:AddToggle("ACPR", {
    Title = "Auto Claim Playtime Rewards",
    Default = false
})
ACPR:OnChanged(function(state)
    autoClaiming = state
    if not state then return end
    task.spawn(function()
        while autoClaiming do
            for reward = 1, 12 do
                if not autoClaiming then break end
                local success, err = pcall(function()
                    claimGift:InvokeServer(reward)
                end)
                task.wait(0.25)
            end
            task.wait(1)
        end
    end)
end)
Options.ACPR:SetValue(false)
-----
-----
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local rebirth = ReplicatedStorage
    :WaitForChild("Packages")
    :WaitForChild("_Index")
    :WaitForChild("sleitnick_knit@1.7.0")
    :WaitForChild("knit")
    :WaitForChild("Services")
    :WaitForChild("RebirthService")
    :WaitForChild("RF")
    :WaitForChild("Rebirth")
local running = false
local AR = Tabs.Main:AddToggle("AR", {
    Title = "Auto Rebirth",
    Default = false
})
AR:OnChanged(function(state)
    running = state
    if not state then return end
    task.spawn(function()
        while running do
            pcall(function()
                rebirth:InvokeServer()
            end)
            task.wait(1)
        end
    end)
end)
Options.AR:SetValue(false)
-----
-----
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Players = game:GetService("Players")
local player = Players.LocalPlayer
local claim = ReplicatedStorage
    :WaitForChild("Packages")
    :WaitForChild("_Index")
    :WaitForChild("sleitnick_knit@1.7.0")
    :WaitForChild("knit")
    :WaitForChild("Services")
    :WaitForChild("SeasonPassService")
    :WaitForChild("RF")
    :WaitForChild("ClaimPassReward")
local running = false
local ACEPR = Tabs.Main:AddToggle("ACEPR", {
    Title = "Auto Claim Event Pass Rewards",
    Default = false
})
ACEPR:OnChanged(function(state)
    running = state
    if not state then return end
    task.spawn(function()
        while running do
            local gui = player:WaitForChild("PlayerGui")
                :WaitForChild("Windows")
                :WaitForChild("Event")
                :WaitForChild("Frame")
                :WaitForChild("Frame")
                :WaitForChild("Windows")
                :WaitForChild("Pass")
                :WaitForChild("Main")
                :WaitForChild("ScrollingFrame")
            for i = 1, 10 do
                if not running then break end
                local item = gui:FindFirstChild(tostring(i))
                if item and item:FindFirstChild("Frame") and item.Frame:FindFirstChild("Free") then
                    local free = item.Frame.Free
                    local locked = free:FindFirstChild("Locked")
                    local claimed = free:FindFirstChild("Claimed")
                    while running and locked and locked.Visible do
                        task.wait(0.2)
                    end
                    if running and claimed and claimed.Visible then
                        continue
                    end
                    if running and locked and not locked.Visible then
                        pcall(function()
                            claim:InvokeServer("Free", i)
                        end)
                    end
                end
            end
            task.wait(0.5)
        end
    end)
end)
Options.ACEPR:SetValue(false)
-----
-----
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local redeem = ReplicatedStorage
    :WaitForChild("Packages")
    :WaitForChild("_Index")
    :WaitForChild("sleitnick_knit@1.7.0")
    :WaitForChild("knit")
    :WaitForChild("Services")
    :WaitForChild("CodesService")
    :WaitForChild("RF")
    :WaitForChild("RedeemCode")
local codes = {
    "release"
    -- add more codes here
}
Tabs.Main:AddButton({
    Title = "Redeem All Codes",
    Callback = function()
        for _, code in ipairs(codes) do
            pcall(function()
                redeem:InvokeServer(code)
            end)
            task.wait(1)
        end
    end
})
-----
-----
Tabs.Upgrades:AddSection("Speed Upgrades")
-----
-----
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local upgrade = ReplicatedStorage
    :WaitForChild("Packages")
    :WaitForChild("_Index")
    :WaitForChild("sleitnick_knit@1.7.0")
    :WaitForChild("knit")
    :WaitForChild("Services")
    :WaitForChild("UpgradesService")
    :WaitForChild("RF")
    :WaitForChild("Upgrade")
local amount = 1
local delayTime = 0.5
local running = false
local IMS = Tabs.Upgrades:AddInput("IMS", {
    Title = "Speed Amount",
    Default = "1",
    Placeholder = "Number",
    Numeric = true,
    Finished = false,
    Callback = function(Value)
        amount = tonumber(Value) or 1
    end
})
IMS:OnChanged(function(Value)
    amount = tonumber(Value) or 1
end)
local SMS = Tabs.Upgrades:AddSlider("SMS", {
    Title = "Upgrade Interval",
    Description = "",
    Default = 1,
    Min = 0,
    Max = 5,
    Rounding = 1,
    Callback = function(Value)
        delayTime = Value
    end
})
SMS:OnChanged(function(Value)
    delayTime = Value
end)
SMS:SetValue(1)
local AMS = Tabs.Upgrades:AddToggle("AMS", {
    Title = "Auto Upgrade Speed",
    Default = false
})
AMS:OnChanged(function(state)
    running = state
    if not state then return end
    task.spawn(function()
        while running do
            pcall(function()
                upgrade:InvokeServer("MovementSpeed", amount)
            end)
            task.wait(delayTime)
        end
    end)
end)
Options.AMS:SetValue(false)
-----
-----
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Players = game:GetService("Players")
local player = Players.LocalPlayer
local buy = ReplicatedStorage
    :WaitForChild("Packages")
    :WaitForChild("_Index")
    :WaitForChild("sleitnick_knit@1.7.0")
    :WaitForChild("knit")
    :WaitForChild("Services")
    :WaitForChild("SkinService")
    :WaitForChild("RF")
    :WaitForChild("BuySkin")
local skins = {
    "prestige_mogging_luckyblock",
    "mogging_luckyblock",
    "colossus _luckyblock",
    "inferno_luckyblock",
    "divine_luckyblock",
    "spirit_luckyblock",
    "cyborg_luckyblock",
    "void_luckyblock",
    "gliched_luckyblock",
    "lava_luckyblock",
    "freezy_luckyblock",
    "fairy_luckyblock"
}
local suffix = {
    K = 1e3,
    M = 1e6,
    B = 1e9,
    T = 1e12,
    Qa = 1e15,
    Qi = 1e18,
    Sx = 1e21,
    Sp = 1e24,
    Oc = 1e27,
    No = 1e30,
    Dc = 1e33
}
local function parseCash(text)
    text = text:gsub("%$", ""):gsub(",", ""):gsub("%s+", "")
    local num = tonumber(text:match("[%d%.]+"))
    local suf = text:match("%a+")
    if not num then return 0 end
    if suf and suffix[suf] then
        return num * suffix[suf]
    end
    return num
end
local running = false
local ABL = Tabs.Main:AddToggle("ABL", {
    Title = "Auto Buy Best Luckyblock",
    Default = false
})
ABL:OnChanged(function(state)
    running = state
    if not state then return end
    task.spawn(function()
        while running do
            local gui = player.PlayerGui:FindFirstChild("Windows")
            if not gui then 
                task.wait(1)
                continue 
            end
            local pickaxeShop = gui:FindFirstChild("PickaxeShop")
            if not pickaxeShop then 
                task.wait(1)
                continue 
            end
            local shopContainer = pickaxeShop:FindFirstChild("ShopContainer")
            if not shopContainer then 
                task.wait(1)
                continue 
            end
            local scrollingFrame = shopContainer:FindFirstChild("ScrollingFrame")
            if not scrollingFrame then 
                task.wait(1)
                continue 
            end
            local cash = player.leaderstats.Cash.Value
            local bestSkin = nil
            local bestPrice = 0
            for i = 1, #skins do
                local name = skins[i]
                local item = scrollingFrame:FindFirstChild(name)
                if item then
                    local main = item:FindFirstChild("Main")
                    if main then
                        local buyFolder = main:FindFirstChild("Buy")
                        if buyFolder then
                            local buyButton = buyFolder:FindFirstChild("BuyButton")
                            if buyButton and buyButton.Visible then
                                local cashLabel = buyButton:FindFirstChild("Cash")
                                if cashLabel then
                                    local price = parseCash(cashLabel.Text)
                                    if cash >= price and price > bestPrice then
                                        bestSkin = name
                                        bestPrice = price
                                    end
                                end
                            end
                        end
                    end
                end
            end
            if bestSkin then
                pcall(function()
                    buy:InvokeServer(bestSkin)
                end)
            end
            task.wait(0.5)
        end
    end)
end)
Options.ABL:SetValue(false)
-----
-----
Tabs.Main:AddButton({
    Title = "Sell Held Brainrot",
    Callback = function()
        Window:Dialog({
            Title = "Confirm Sale",
            Content = "Are you sure you want to sell this held Brainrot?",
            Buttons = {
                {
                    Title = "Confirm",
                    Callback = function()
                        local player = game:GetService("Players").LocalPlayer
                        local character = player.Character or player.CharacterAdded:Wait()
                        local tool = character:FindFirstChildOfClass("Tool")
                        if not tool then
                            Fluent:Notify({
                                Title = "ERROR!",
                                Content = "Equip the Brainrot you want to Sell",
                                Duration = 5
                            })
                            return
                        end
                        local entityId = tool:GetAttribute("EntityId")
                        if not entityId then return end
                        local args = {
                            entityId
                        }
                        game:GetService("ReplicatedStorage")
                            :WaitForChild("Packages")
                            :WaitForChild("_Index")
                            :WaitForChild("sleitnick_knit@1.7.0")
                            :WaitForChild("knit")
                            :WaitForChild("Services")
                            :WaitForChild("InventoryService")
                            :WaitForChild("RF")
                            :WaitForChild("SellBrainrot")
                            :InvokeServer(unpack(args))
                        Fluent:Notify({
                            Title = "SOLD!",
                            Content = "Sold: " .. tool.Name,
                            Duration = 5
                        })

                    end
                },
                {
                    Title = "Cancel",
                    Callback = function()
                    end
                }
            }
        })
    end
})
-----
-----
Tabs.Main:AddButton({
    Title = "Pickup All Your Brainrots",
    Callback = function()
        Window:Dialog({
            Title = "Confirm Pickup!",
            Content = "Pick up all Brainrots?",
            Buttons = {
                {
                    Title = "Confirm",
                    Callback = function()
                        local player = game:GetService("Players").LocalPlayer
                        local username = player.Name
                        local plotsFolder = workspace:WaitForChild("Plots")
                        local myPlot
                        for i = 1, 5 do
                            local plot = plotsFolder:FindFirstChild(tostring(i))
                            if plot and plot:FindFirstChild(tostring(i)) then
                                local inner = plot[tostring(i)]
                                for _, v in pairs(inner:GetDescendants()) do
                                    if v:IsA("BillboardGui") and string.find(v.Name, username) then
                                        myPlot = inner
                                        break
                                    end
                                end
                            end
                            if myPlot then break end
                        end
                        if not myPlot then return end
                        local containers = myPlot:FindFirstChild("Containers")
                        if not containers then return end
                        for i = 1, 30 do
                            local containerFolder = containers:FindFirstChild(tostring(i))
                            if containerFolder and containerFolder:FindFirstChild(tostring(i)) then
                                local container = containerFolder[tostring(i)]
                                local innerModel = container:FindFirstChild("InnerModel")
                                if innerModel and #innerModel:GetChildren() > 0 then
                                    local args = {
                                        tostring(i)
                                    }
                                    game:GetService("ReplicatedStorage")
                                        :WaitForChild("Packages")
                                        :WaitForChild("_Index")
                                        :WaitForChild("sleitnick_knit@1.7.0")
                                        :WaitForChild("knit")
                                        :WaitForChild("Services")
                                        :WaitForChild("ContainerService")
                                        :WaitForChild("RF")
                                        :WaitForChild("PickupBrainrot")
                                        :InvokeServer(unpack(args))
                                    task.wait(0.1)
                                end
                            end
                        end
                        Fluent:Notify({
                            Title = "Done!",
                            Content = "Picked up all Brainrots",
                            Duration = 5
                        })
                    end
                },
                {
                    Title = "Cancel",
                    Callback = function()
                    end
                }
            }
        })
    end
})
-----
-----
local storedParts = {}
local folder = workspace:WaitForChild("BossTouchDetectors")
local RBTD = Tabs.Brainrots:AddToggle("RBTD", {
    Title = "Remove Bad Boss Touch Detectors",
    Description = "will make it so only the last boss can capture you",
    Default = false
})
RBTD:OnChanged(function(state)
    if state then
        storedParts = {}
        for _, obj in ipairs(folder:GetChildren()) do
            if obj.Name ~= "base14" then
                table.insert(storedParts, obj)
                obj.Parent = nil
            end
        end
    else
        for _, obj in ipairs(storedParts) do
            if obj then
                obj.Parent = folder
            end
        end
        storedParts = {}
    end
end)
Options.RBTD:SetValue(false)
-----
-----
Tabs.Brainrots:AddButton({
    Title = "Teleport to End",
    Callback = function()
        local modelsFolder = workspace:WaitForChild("RunningModels")
        local target = workspace:WaitForChild("CollectZones"):WaitForChild("base14")
        for _, obj in ipairs(modelsFolder:GetChildren()) do
            if obj:IsA("Model") then
                if obj.PrimaryPart then
                    obj:SetPrimaryPartCFrame(target.CFrame)
                else
                    local part = obj:FindFirstChildWhichIsA("BasePart")
                    if part then
                        part.CFrame = target.CFrame
                    end
                end
            elseif obj:IsA("BasePart") then
                obj.CFrame = target.CFrame
            end
        end
    end
})
-----
-----
Tabs.Brainrots:AddSection("Farming")
local running = false
local AutoFarmToggle = Tabs.Brainrots:AddToggle("AutoFarmToggle", {
    Title = "Auto Farm Best Brainrots",
    Default = false
})
AutoFarmToggle:OnChanged(function(state)
    running = state
    if state then
        task.spawn(function()
            while running do
                local player = game.Players.LocalPlayer
                local character = player.Character or player.CharacterAdded:Wait()
                local root = character:WaitForChild("HumanoidRootPart")
                local humanoid = character:WaitForChild("Humanoid")
                local userId = player.UserId
                local modelsFolder = workspace:WaitForChild("RunningModels")
                local target = workspace:WaitForChild("CollectZones"):WaitForChild("base14")
                root.CFrame = CFrame.new(715, 39, -2122)
                task.wait(0.3)
                humanoid:MoveTo(Vector3.new(710, 39, -2122))
                local ownedModel = nil
                repeat
                    task.wait(0.3)
                    for _, obj in ipairs(modelsFolder:GetChildren()) do
                        if obj:IsA("Model") and obj:GetAttribute("OwnerId") == userId then
                            ownedModel = obj
                            break
                        end
                    end
                until ownedModel ~= nil or not running
                if not running then break end
                if ownedModel.PrimaryPart then
                    ownedModel:SetPrimaryPartCFrame(target.CFrame)
                else
                    local part = ownedModel:FindFirstChildWhichIsA("BasePart")
                    if part then
                        part.CFrame = target.CFrame
                    end
                end
                task.wait(0.7)
                if ownedModel and ownedModel.Parent == modelsFolder then
                    if ownedModel.PrimaryPart then
                        ownedModel:S")
CreateScriptButton("BALBX", "https://raw.githubusercontent.com/cmoney53/Aimboy/refs/heads/main/Balb2.lua")
-----------------------------
