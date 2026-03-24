--[[
    Be a Lucky Block - Optimized Script
    Modified for GitHub Loadstring
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

-- [[ AUTO CLAIM PLAYTIME ]]
local claimGift = game:GetService("ReplicatedStorage"):WaitForChild("Packages"):WaitForChild("_Index"):WaitForChild("sleitnick_knit@1.7.0"):WaitForChild("knit"):WaitForChild("Services"):WaitForChild("PlaytimeRewardService"):WaitForChild("RF"):WaitForChild("ClaimGift")
local autoClaiming = false
local ACPR = Tabs.Main:AddToggle("ACPR", {Title = "Auto Claim Playtime Rewards", Default = false})
ACPR:OnChanged(function(state)
    autoClaiming = state
    task.spawn(function()
        while autoClaiming do
            for reward = 1, 12 do
                if not autoClaiming then break end
                pcall(function() claimGift:InvokeServer(reward) end)
                task.wait(0.25)
            end
            task.wait(1)
        end
    end)
end)

-- [[ AUTO REBIRTH ]]
local rebirth = game:GetService("ReplicatedStorage"):WaitForChild("Packages"):WaitForChild("_Index"):WaitForChild("sleitnick_knit@1.7.0"):WaitForChild("knit"):WaitForChild("Services"):WaitForChild("RebirthService"):WaitForChild("RF"):WaitForChild("Rebirth")
local runningRebirth = false
local AR = Tabs.Main:AddToggle("AR", {Title = "Auto Rebirth", Default = false})
AR:OnChanged(function(state)
    runningRebirth = state
    task.spawn(function()
        while runningRebirth do
            pcall(function() rebirth:InvokeServer() end)
            task.wait(1)
        end
    end)
end)

-- [[ AUTO FARM BRAINROTS (Fixed Ending) ]]
local runningFarm = false
local AutoFarmToggle = Tabs.Brainrots:AddToggle("AutoFarmToggle", {Title = "Auto Farm Best Brainrots", Default = false})
AutoFarmToggle:OnChanged(function(state)
    runningFarm = state
    if state then
        task.spawn(function()
            while runningFarm do
                local player = game.Players.LocalPlayer
                local character = player.Character or player.CharacterAdded:Wait()
                local root = character:WaitForChild("HumanoidRootPart")
                local humanoid = character:WaitForChild("Humanoid")
                local modelsFolder = workspace:WaitForChild("RunningModels")
                local target = workspace:WaitForChild("CollectZones"):WaitForChild("base14")
                
                root.CFrame = CFrame.new(715, 39, -2122)
                task.wait(0.3)
                humanoid:MoveTo(Vector3.new(710, 39, -2122))
                
                local ownedModel = nil
                repeat
                    task.wait(0.3)
                    for _, obj in ipairs(modelsFolder:GetChildren()) do
                        if obj:IsA("Model") and obj:GetAttribute("OwnerId") == player.UserId then
                            ownedModel = obj
                            break
                        end
                    end
                until ownedModel ~= nil or not runningFarm
                
                if not runningFarm then break end
                
                if ownedModel then
                    local pPart = ownedModel.PrimaryPart or ownedModel:FindFirstChildWhichIsA("BasePart")
                    if pPart then
                        pPart.CFrame = target.CFrame
                    end
                end
                task.wait(0.7)
            end
        end)
    end
end)

-- Finish Window
SaveManager:SetLibrary(Fluent)
InterfaceManager:SetLibrary(Fluent)
SaveManager:IgnoreThemeSettings()
SaveManager:SetIgnoreIndexes({})
InterfaceManager:BuildInterfaceSection(Tabs.Settings)
SaveManager:BuildConfigSection(Tabs.Settings)
Window:SelectTab(1)
