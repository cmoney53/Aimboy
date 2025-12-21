local getsynasset = getsynasset or getcustomasset
local syn = syn or nil
if syn == nil then
	local Hash = loadstring(game:HttpGet("https://raw.githubusercontent.com/zzerexx/scripts/main/Libraries/Hash.lua"), "HashLib")()
	local gethui = gethui or get_hidden_ui or get_hidden_gui or hiddenUI
	syn = {
		crypt = {
			hash = Hash.sha384
		},
		protect_gui = function(obj)
			obj.Parent = gethui()
		end
	}
end

-- Main vars
local Main, Explorer, Properties, ScriptViewer, DefaultSettings, Notebook, Serializer, Lib
local API, RMD

-- Default Settings [cite: 6, 7]
DefaultSettings = (function()
	local rgb = Color3.fromRGB
	return {
		Explorer = { _Recurse = true, Sorting = true, TeleportToOffset = Vector3.new(0,0,0), ClickToRename = true, AutoUpdateSearch = true, AutoUpdateMode = 0, PartSelectionBox = true, GuiSelectionBox = true, CopyPathUseGetChildren = true },
		Properties = { _Recurse = true, MaxConflictCheck = 50, ShowDeprecated = false, ShowHidden = false, ClearOnFocus = false, LoadstringInput = true, NumberRounding = 3, ShowAttributes = false, MaxAttributes = 50, ScaleType = 1 },
		Theme = {
			_Recurse = true,
			Main1 = rgb(52,52,52), Main2 = rgb(45,45,45), Outline1 = rgb(33,33,33), Outline2 = rgb(55,55,55), Outline3 = rgb(30,30,30), TextBox = rgb(38,38,38), Menu = rgb(32,32,32), ListSelection = rgb(11,90,175), Button = rgb(60,60,60), Highlight = rgb(75,75,75), Text = rgb(255,255,255), PlaceholderText = rgb(100,100,100), Important = rgb(255,0,0),
			Syntax = { Text = rgb(204,204,204), Background = rgb(36,36,36), Keyword = rgb(248,109,124), String = rgb(173,241,149), Number = rgb(255,198,0) }
		}
	}
end)()

local Settings = {}
local Apps = {}
local env = {}
local service = setmetatable({},{__index = function(self,name) local serv = game:GetService(name) self[name] = serv return serv end})
local plr = service.Players.LocalPlayer or service.Players.PlayerAdded:wait()

-- UI Creation Helper [cite: 8]
local create = function(data)
	local insts = {}
	for i,v in pairs(data) do insts[v[1]] = Instance.new(v[2]) end
	for _,v in pairs(data) do
		for prop,val in pairs(v[3]) do
			if type(val) == "table" then insts[v[1]][prop] = insts[val[1]] else insts[v[1]][prop] = val end
		end
	end
	return insts[1]
end

Main = (function()
	local Main = {}
	Main.ModuleList = {"Explorer","Properties","ScriptViewer"}
	Main.Elevated = false
	Main.GitRepoName = "zzerexx/Dex"
	Main.AppControls = {}

	-- BYPASS & STEALTH INIT 
	Main.InitEnv = function()
		-- Randomize interface name to bypass detection
		local randomName = ""
		for i = 1, 12 do randomName = randomName .. string.char(math.random(65, 90)) end
		
		env.readfile = readfile; env.writefile = writefile; env.appendfile = appendfile;
		env.getupvalues = debug.getupvalues or getupvals; env.getconstants = debug.getconstants or getconsts;
		env.getreg = getreg; env.gethui = gethui or get_hidden_ui;
		
		env.protectgui = function(obj)
			obj.Name = randomName
			if env.gethui then obj.Parent = env.gethui() elseif syn and syn.protect_gui then syn.protect_gui(obj) end
		end
		
		Main.Elevated = pcall(function() return service.CoreGui:GetFullName() end)
		Main.GuiHolder = (env.gethui and env.gethui()) or (Main.Elevated and service.CoreGui) or plr:FindFirstChildOfClass("PlayerGui")
	end

	-- CUSTOM COMMAND EXECUTOR [NEW FEATURE]
	Main.OpenExecutor = function(foundCmd)
		local execFrame = create({
			{1,"Frame",{BackgroundColor3=Color3.fromRGB(45,45,45),BorderSizePixel=0,Name="ExecutorWindow",Size=UDim2.new(0,350,0,120),Position=UDim2.new(0.5,-175,0.5,-60)}},
			{2,"TextBox",{BackgroundColor3=Color3.fromRGB(30,30,30),BorderSizePixel=0,Name="Input",Parent={1},Position=UDim2.new(0,10,0,40),Size=UDim2.new(1,-20,0,30),Text=foundCmd or "",TextColor3=Color3.new(1,1,1),PlaceholderText="Enter script/command..."}},
			{3,"TextButton",{BackgroundColor3=Color3.fromRGB(60,60,60),BorderSizePixel=0,Name="Run",Parent={1},Position=UDim2.new(0,10,0,80),Size=UDim2.new(1,-20,0,30),Text="Execute Mid-Game",TextColor3=Color3.new(1,1,1)}}
		})
		Main.ShowGui(execFrame)
		execFrame.Run.MouseButton1Click:Connect(function()
			local code = execFrame.Input.Text
			local func, err = loadstring(code)
			if func then task.spawn(func) else warn("DEX EXEC ERROR: "..err) end
		end)
	end

	-- SEARCH FOR COMMANDS LOGIC [NEW FEATURE]
	Main.SearchForCommands = function()
		print("DEX: Searching for vulnerable remotes...")
		local found = "print('No remotes found')"
		for _, v in pairs(game:GetDescendants()) do
			if (v:IsA("RemoteEvent") or v:IsA("RemoteFunction")) and (v.Name:lower():find("admin") or v.Name:lower():find("cmd")) then
				found = "-- Remote Found: " .. v:GetFullName() .. "\ngame." .. v:GetFullName() .. ":FireServer('args_here')"
				break
			end
		end
		Main.OpenExecutor(found)
	end

	Main.LoadModule = function(name) [cite: 9, 10]
		local filePath = "dex/ModuleCache/"..name..".lua"
		local moduleStr = game:HttpGet("https://raw.githubusercontent.com/"..Main.GitRepoName.."/master/modules/"..name..".lua")
		if env.writefile then pcall(env.writefile, filePath, moduleStr) end
		local control = loadstring(moduleStr)()
		Main.AppControls[name] = control
		control.InitDeps(Main.GetInitDeps())
		Apps[name] = control.Main()
		return Apps[name]
	end

	Main.LoadModules = function() [cite: 11]
		for _,v in pairs(Main.ModuleList) do Main.LoadModule(v) end
		Explorer, Properties, ScriptViewer = Apps.Explorer, Apps.Properties, Apps.ScriptViewer
	end

	Main.CreateMainGui = function() [cite: 26]
		-- Core Dex Menu creation
		Main.InitEnv()
		local gui = create({
			{1,"ScreenGui",{IgnoreGuiInset=true,Name="DexMenu"}},
			{2,"TextButton",{BackgroundColor3=Color3.fromRGB(45,45,45),Name="OpenButton",Parent={1},Position=UDim2.new(0.5,-16,0,2),Size=UDim2.new(0,32,0,32),Text="Dex",TextColor3=Color3.new(1,1,1)}},
			{3,"Frame",{BackgroundColor3=Color3.fromRGB(45,45,45),Name="MainFrame",Parent={2},Position=UDim2.new(0.5,-112,1,5),Size=UDim2.new(0,224,0,250),Visible=false}},
			{4,"UIGridLayout",{CellSize=UDim2.new(0,66,0,74),Parent={3},Position=UDim2.new(0,7,0,8)}}
		})
		
		-- Add the new Search for Commands button
		local cmdBtn = Instance.new("TextButton", gui.OpenButton.MainFrame)
		cmdBtn.Size = UDim2.new(0,66,0,74)
		cmdBtn.Text = "Search Cmds"
		cmdBtn.BackgroundColor3 = Color3.fromRGB(60,60,60)
		cmdBtn.TextColor3 = Color3.new(1,1,1)
		cmdBtn.MouseButton1Click:Connect(Main.SearchForCommands)

		gui.OpenButton.MouseButton1Click:Connect(function()
			gui.OpenButton.MainFrame.Visible = not gui.OpenButton.MainFrame.Visible
		end)
		
		Main.ShowGui(gui)
	end

	Main.ShowGui = function(gui) [cite: 20]
		if env.protectgui then env.protectgui(gui) end
		gui.Parent = Main.GuiHolder
	end

	Main.FetchAPI = function() return service.HttpService:JSONDecode(game:HttpGet("http://setup.roblox.com/".. (Main.RobloxVersion or "version-43e6015569f64757") .."-API-Dump.json")) end
	Main.FetchRMD = function() return game:HttpGet("https://raw.githubusercontent.com/CloneTrooper1019/Roblox-Client-Tracker/roblox/ReflectionMetadata.xml") end

	Main.Init = function() [cite: 27, 32]
		Main.InitEnv()
		if env.makefolder then makefolder("dex"); makefolder("dex/ModuleCache") end
		API = Main.FetchAPI()
		RMD = Main.FetchRMD()
		Main.LoadModules()
		Main.CreateMainGui()
		print("DEX: Developer Mode Active. UI Hidden and Protected.")
	end

	Main.GetInitDeps = function() return {Main=Main, env=env, service=service, plr=plr, Settings=Settings} end

	return Main
end)()

Main.Init()
