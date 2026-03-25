-- Essential Settings: Enable "LoadStringEnabled" in ServerScriptService properties!
local Players = game:GetService("Players")

local function createUniversalConsole(player)
    local sg = Instance.new("ScreenGui", player.PlayerGui)
    sg.Name = "UniversalConsole"
    sg.IgnoreGuiInset = true

    local main = Instance.new("Frame", sg)
    main.Size = UDim2.new(0, 450, 0, 220)
    main.Position = UDim2.new(0.5, -225, 0.2, 0)
    main.BackgroundColor3 = Color3.fromRGB(20, 20, 20)
    main.Active = true
    main.Draggable = true -- High-value for Mouse users

    local title = Instance.new("TextLabel", main)
    title.Size = UDim2.new(1, 0, 0, 30)
    title.Text = " LUAU EXECUTOR (XBOX COMPATIBLE) "
    title.BackgroundColor3 = Color3.fromRGB(40, 40, 40)
    title.TextColor3 = Color3.new(1, 1, 1)

    local box = Instance.new("TextBox", main)
    box.Size = UDim2.new(1, -20, 0, 130)
    box.Position = UDim2.new(0, 10, 0, 40)
    box.MultiLine = true
    box.TextXAlignment = Enum.TextXAlignment.Left
    box.TextYAlignment = Enum.TextYAlignment.Top
    box.BackgroundColor3 = Color3.fromRGB(35, 35, 35)
    box.TextColor3 = Color3.fromRGB(0, 255, 0)
    box.Text = ""
    box.PlaceholderText = "-- Paste/Type Script Here..."

    local exec = Instance.new("TextButton", main)
    exec.Size = UDim2.new(0.5, -15, 0, 35)
    exec.Position = UDim2.new(0, 10, 0, 175)
    exec.Text = "EXECUTE"
    exec.BackgroundColor3 = Color3.fromRGB(0, 120, 0)
    exec.TextColor3 = Color3.new(1, 1, 1)

    local clear = Instance.new("TextButton", main)
    clear.Size = UDim2.new(0.5, -15, 0, 35)
    clear.Position = UDim2.new(0.5, 5, 0, 175)
    clear.Text = "CLEAR"
    clear.BackgroundColor3 = Color3.fromRGB(120, 0, 0)
    clear.TextColor3 = Color3.new(1, 1, 1)

    -- THE COMPATIBILITY BRIDGE
    exec.MouseButton1Click:Connect(function()
        local code = box.Text
        
        -- This "wraps" the code to prevent it from crashing if it looks for exploit-only features
        local wrapper = [[
            local getgenv = function() return _G end
            local Drawing = {new = function() return {Remove = function() end} end}
            local success, err = pcall(function()
                ]] .. code .. [[
            end)
            if not success then warn("Script Error: " .. err) end
        ]]

        local func, parseErr = loadstring(wrapper)
        if func then
            task.spawn(func)
            exec.Text = "RUNNING..."
            task.wait(1)
            exec.Text = "EXECUTE"
        else
            warn("Syntax Error: " .. parseErr)
        end
    end)

    clear.MouseButton1Click:Connect(function() box.Text = "" end)
end

Players.PlayerAdded:Connect(function(p)
    if p.UserId == game.CreatorId then createUniversalConsole(p) end
end)
