local StarterGui = game:GetService("StarterGui")
local Players = game:GetService("Players")
local LocalPlayer = Players.LocalPlayer

local frame = script.Parent:WaitForChild("ScrollingFrame")
local template = frame:WaitForChild("Template")

-- Function to refresh the player list
local function updateList()
	-- Clear existing buttons (except the template)
	for _, child in pairs(frame:GetChildren()) do
		if child:IsA("TextButton") and child.Name ~= "Template" then
			child:Destroy()
		end
	end

	-- Create a button for every player in the server
	for _, player in pairs(Players:GetPlayers()) do
		if player ~= LocalPlayer then
			local btn = template:Clone()
			btn.Name = player.Name
			btn.Text = "Block: " .. player.DisplayName
			btn.Visible = true
			btn.Parent = frame

			-- When clicked, trigger the block prompt
			btn.MouseButton1Click:Connect(function()
				local success, result = pcall(function()
					StarterGui:SetCore("PromptBlockPlayer", player)
				end)
				
				if not success then
					warn("Could not open block prompt: " .. tostring(result))
				end
			end)
		end
	end
end

-- Refresh list when players join or leave
Players.PlayerAdded:Connect(updateList)
Players.PlayerRemoving:Connect(updateList)

-- Initial run
updateList()
