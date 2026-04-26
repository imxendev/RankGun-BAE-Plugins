--[[
	Basic Admin v2 Plugin
	Promote User via RankGun API
--]]

local Plugin = function(...)
	local Data = {...}


	local remoteEvent = Data[1][1]
	local remoteFunction = Data[1][2]
	local returnPermissions = Data[1][3]
	local Commands = Data[1][4]
	local Prefix = Data[1][5]
	local actionPrefix = Data[1][6]
	local returnPlayers = Data[1][7]
	local cleanData = Data[1][8]

	local pluginName = "promote"
	local pluginPrefix = Prefix
	local pluginLevel = 2 -- You can change this. | The level of admin that can run the command.
	local pluginUsage = "<User(s)>"
	local pluginDescription = "Promotes a user to the next rank."

	local API_KEY = "abc123" -- CHANGE THIS | To find your API key, navigate to RankGun, click 'Settings & Billing,' scroll down to API key, and copy+paste it here.
	local API_URL = "https://api.rankgun.works/api/roblox/promote"

	local HttpService = game:GetService("HttpService")
	local function promoteUser(userId)
		local success, response = pcall(function()
			return HttpService:RequestAsync({
				Url = API_URL,
				Method = "POST",
				Headers = {
					["x-api-key"] = API_KEY,
					["Content-Type"] = "application/json"
				},
				Body = HttpService:JSONEncode({
					userId = userId,
					reason = "Promoted via Basic Admin."
				})
			})
		end)

		if not success then
			warn("HTTP request failed:", response)
			return nil
		end

		if response.Success then
			return HttpService:JSONDecode(response.Body)
		else
			warn("API error:", response.StatusCode, response.Body)
			return nil
		end
	end

	local function pluginFunction(Args)
		local Player = Args[1]
		if not Args[3] then return end

		local Targets = returnPlayers(Player, Args[3])
		if not Targets then return end

		for _, target in pairs(Targets) do
			local result = promoteUser(target.UserId)

			-- SAFE CHECK (prevents concat error)
			if result and result.success then
				local oldRank = tostring(result.oldRank or "Unknown")
				local newRank = tostring(result.newRank or "Unknown")
				local username = tostring(result.username or target.Name)

				remoteEvent:FireClient(
					Player,
					"Notif",
					"Promotion Successful",
					username .. " was promoted.",
					{
						"Old Rank: " .. oldRank, -- Previous rank of the user before promotion.
						"New Rank: " .. 10 -- You can change this | Rank increment applied (e.g., 240 becomes 250 when +10 is applied)
					}
				)

				target:Kick("Congratulations, you have been promoted.") -- You can change this.

			else
				local errMsg = "Unknown error"

				if result and result.message then
					errMsg = result.message
				end

				remoteEvent:FireClient(
					Player,
					"Notif",
					"Promotion Failed",
					target.Name .. " was not promoted.",
					{errMsg}
				)
			end
		end
	end

	return pluginName, pluginFunction, pluginLevel, pluginPrefix,
	{pluginName, pluginUsage, pluginDescription}
end

return Plugin
