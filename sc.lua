--[[
Consider this proof of work, some scripts I have done in the past. I can show more proof upon request.
]]







--SCRIPT 1, A CLIENT DATA STORE SYSTEM

--SERVER SCRIPT IN SERVERSCRIPT SERVICE
local folder = game:GetService('ReplicatedStorage'):WaitForChild('clientada')
local setdata = folder:WaitForChild('SetData')
local getdata = folder:WaitForChild('GetData')
local incrememntdata = folder:WaitForChild('IncrementData')
local updatedata = folder:WaitForChild('UpdateData')
local removedata = folder:WaitForChild('RemoveData')
local dsv = game:GetService('DataStoreService')
local config = require(script:WaitForChild('config'))
local key = config.Key
local kickoninckey = config.kickOnIncorrectKey

if typeof(key) == 'boolean' then
	error("Incorrect key config.")
end

if typeof(kickoninckey) ~= 'boolean' then
	error('Incorrect kick on key config.')
end


setdata.OnServerInvoke = function(plr, userkey, ds, dkey, data)
	if not userkey or userkey ~= key then
		if kickoninckey == true then
			plr:Kick("Attempted to access Clientada with an incorrect key. Possible exploit detected. Key provided: ".. userkey)
			return end
		if kickoninckey == false then  
			warn("Attempted to access Clientada with incorrect key")
			return end
	end
	local success, errorm = pcall(function()
		ds = dsv:GetDataStore(ds)
		ds:SetAsync(dkey, data)
	end)
	if errorm then
		return errorm
	else
		return 0
	end
end

getdata.OnServerInvoke = function(plr, userkey, ds, dkey)
	if not userkey or userkey ~= key then
		if kickoninckey == true then
			plr:Kick("Attempted to access Clientada with an incorrect key. Possible exploit detected. Key provided: ".. userkey)
			return end
		if kickoninckey == false then  
			warn("Attempted to access Clientada with incorrect key")
			return end
	end
	local rdata
	local success, errorm = pcall(function()
		ds = dsv:GetDataStore(ds)
		rdata = ds:GetAsync(dkey)
	end)
	if errorm then
		return errorm
	else
		return rdata
	end
end

incrememntdata.OnServerInvoke = function(plr, userkey, ds, dkey, increment, incrementoptions)
	if not userkey or userkey ~= key then
		if kickoninckey == true then
			plr:Kick("Attempted to access Clientada with an incorrect key. Possible exploit detected. Key provided: ".. userkey)
			return end
		if kickoninckey == false then  
			warn("Attempted to access Clientada with incorrect key")
			return end
	end
	if typeof(increment) ~= "number" then
		return "Increment value must be a number" end
	local success, errorm = pcall(function()
		ds = dsv:GetDataStore(ds)
		ds:IncrementAsync(dkey, increment, incrementoptions)
	end)
	if errorm then
		return errorm
	else
		return 0
	end
end

removedata.OnServerInvoke = function(plr, userkey, ds, dkey)
	if not userkey or userkey ~= key then
		if kickoninckey == true then
			plr:Kick("Attempted to access Clientada with an incorrect key. Possible exploit detected. Key provided: ".. userkey)
			return end
		if kickoninckey == false then  
			warn("Attempted to access Clientada with incorrect key")
			return end
	end
	local success, errorm = pcall(function()
		ds = dsv:GetDataStore(ds)
		ds:RemoveAsync(dkey)
	end)
	if errorm then
		return errorm
	else
		return 0
	end
end


--SCRIPT 2, A RANDOM VOXEL GENERATOR (fun script i made no purpose LOL)

--[[
Random voxel generator, made by MushyToast
set the mx-my values to accomadate your workspace, change the max variable to how many voxels MAX
Put this script inside ServerScriptService, put a part called 'voxel' in the dimensions that you want the voxel in ServerStorage
Finally, put a folder called 'voxels' in workspace, this is where all voxels go.
This is not a ModuleScript, this is a normal ServerScript
]]
local mx = 255
local mix = -255
local mz = 255
local miz = -255
local miy = 1
local my = 255
local maxvoxels = 50000

local folder = game.Workspace:WaitForChild('voxels')
local voxel = game:GetService('ServerStorage'):WaitForChild('voxel')
local count = 0
wait(5)

while #folder:GetChildren() <= maxvoxels do
	count = count + 1
	local x = math.random(mix, mx)
	local y = math.random(miy, my)
	local z = math.random(miz, mz)
	local clone = voxel:Clone()
	clone.Parent = folder
	clone.Position = Vector3.new(x, y, z)
	clone.Color = Color3.fromRGB(math.random(1, 255), math.random(1, 255), math.random(1, 255))
	clone.Anchored = true
	clone.Name = ('Voxel#' .. tostring(count))
	wait()
end

--SCRIPT 3, A BAN SCRIPT

local button = script.Parent
local players = game.Players
local BanEvent = game.ReplicatedStorage.BanStuff:WaitForChild("BanEvent")
local dataStoreServ = game:GetService("DataStoreService")
local Bans = dataStoreServ:GetDataStore("Bans")
local UUID
local permBan
local function getCurrentTimeFormat(seconds)
	local currentTime = os.date("!*t")
	if seconds then
		currentTime = os.date("*t", seconds)
	end

	local hour = currentTime.hour
	local minute = currentTime.min
	local second = currentTime.sec

	local day = currentTime.day
	local month = currentTime.month
	local year = currentTime.year

	if hour < 10 then
		hour = 0 .. hour
	end
	if minute < 10 then
		minute = 0 .. minute
	end
	if second < 10 then
		second = 0 .. second
	end
	if day < 10 then
		day = 0 .. day
	end
	if month < 10 then
		month = 0 .. month
	end
	if year < 10 then
		year = 0 .. year
	end

	return ("%s:%s:%s, %s/%s/%s"):format(hour, minute, second, month, day, year)
end
BanEvent.OnServerEvent:Connect(function(banner, username, reason, etime)
	local bandata = {}
	if username ~= "" then
		local success, error1 = pcall(function()
			UUID = players:GetUserIdFromNameAsync(tostring(username))
		end)
		if error1 then
			warn(error1)
			local output = script.Parent.Parent:WaitForChild("Output")
			output.TextColor3 = Color3.new(1, 0, 0.0156863)
			output.Text = error1
		else --condition one - the username given is correct
			--get whether the ban is permanent
			if etime == "" then --permanent ban
				permBan = true
				bandata = {
					admin = banner.Name;
					rsn = reason;
					tme = false;
					timeatban = nil;
					rtimeban = getCurrentTimeFormat()
					
				}
				local success, errorm = pcall(function()
					Bans:SetAsync(UUID, bandata)
					for i, v in pairs(players:GetPlayers()) do
						if v.UserId == UUID then
							v:Kick("You have been permanently banned by [" .. banner.Name .. "] \n\n\n Reason: [" .. reason .. "] \n\n\n [" .. getCurrentTimeFormat() .. "] (UTC)")
						end
					end
				end)
				if success then
					local output = script.Parent.Parent:WaitForChild("Output")
					output.TextColor3 = Color3.new(0, 1, 0.0313725)
					output.Text = ("User successfully banned!")
				end
				if errorm then
					warn(errorm)
					local output = script.Parent.Parent:WaitForChild("Output")
					output.TextColor3 = Color3.new(1, 0, 0.0156863)
					output.Text = errorm
				end
			elseif permBan ~= true and tonumber(etime) ~= nil and tonumber(etime)*86400 < os.time() and tonumber(etime) > 0 then
				permBan = false --non perm ban with a time
				etime = math.floor(tonumber(etime) + 0.5)
				if etime == 0 then
					etime = 1
				end
				etime = etime * 86400
				local curtime = math.floor(tonumber(os.time()) + 0.5)
				bandata = {
					admin = banner.Name;
					rsn = reason;
					tme = etime;
					timeatban = curtime;
					rtimeban = getCurrentTimeFormat()

				}
				local success, errorm = pcall(function()
					Bans:SetAsync(UUID, bandata)
					for i, v in pairs(game.Players:GetPlayers()) do
						if v.UserId == UUID then
							v:Kick("You have been banned for " .. tostring(etime/86400) .. " \n\n\n day(s) by [" .. banner.Name .. "] \n\n\n Reason: [" .. reason .. "] \n\n\n You will be unbanned in " .. tostring(etime/86400) .. " day(s) \n\n\n" .. " [" .. getCurrentTimeFormat() .. "] (UTC)")
						end
					end
				end)
				if success then
					local output = script.Parent.Parent:WaitForChild("Output")
					output.TextColor3 = Color3.new(0, 1, 0.0313725)
					output.Text = ("User successfully banned!")
				end
				if errorm then
					warn(errorm)
					local output = script.Parent.Parent:WaitForChild("Output")
					output.TextColor3 = Color3.new(1, 0, 0.0156863)
					output.Text = errorm
				end
			elseif tonumber(etime) == nil then
				local output = script.Parent.Parent:WaitForChild("Output")
				output.TextColor3 = Color3.new(1, 0, 0.0156863)
				output.Text = "Time must be a number!"
			elseif tonumber(etime) > os.time() or tonumber(etime) < 0 then
				local output = script.Parent.Parent:WaitForChild("Output")
				output.TextColor3 = Color3.new(1, 0, 0.0156863)
				output.Text = "Invalid time. Either too big of a number or a negative number. Note due to how the script was written you can only ban people for up to ~52 years."
			end
		end
	else
		local output = script.Parent.Parent:WaitForChild("Output")
		output.TextColor3 = Color3.new(1, 0, 0.0156863)
		output.Text = "Enter a username!"
	end
end)

--SCRIPT 4, A BAN CHECKER (it works in conjuction with the script above)

local dataStoreServ = game:GetService("DataStoreService")
local banData = {}
local bstore = dataStoreServ:GetDataStore("Bans")


game.Players.PlayerAdded:Connect(function(plr)
	local success, errorm = pcall(function()
		banData = bstore:GetAsync(plr.UserId)
	end)
	if errorm then
		warn(errorm)
		plr:Kick("Unable to load ban data. This does not mean you are banned, it is a failsafe in case you are banned but the data failed to load. It's just mainly to prevent banned people from playing on the game during a roblox data oopsie. Again, there is a high chance you aren't banned, just the data failed to load and we don't know if you're banned or not.")
	end
	if banData ~= nil and banData ~= "" and banData ~= {} then
		print(banData)
		if banData["tme"] == false then --perm ban
			local reason = banData["rsn"]
			local banner = banData["admin"]
			local rtimeatban = banData["rtimeban"]
			plr:Kick("You have been permanently banned by [" .. banner .. "] \n\n\n Reason: [" .. reason .. "] \n\n\n [" .. rtimeatban .. "]")
		end
		if banData["tme"] ~= false then
			local timeAtBan = banData["timeatban"]
			local reason = banData["rsn"]
			local banner = banData["admin"]
			local banDuration = banData["tme"]
			local rtimeatban = banData["rtimeban"]
			if tonumber(timeAtBan) + tonumber(banDuration) <= math.floor(tonumber(os.time()) + 0.5) then --PLAYERS BAN DURATION HAS PASSED
				local success, errorm = pcall(function()
					bstore:RemoveAsync(plr.UserId)
				end)
			else
				local timeRemainingInDays = tostring(math.floor((((timeAtBan + banDuration)-(math.floor(os.time() + 0.5)))/86400) + 0.5))
				plr:Kick("You have been banned for " .. tostring(banDuration/86400) .. " \n\n\n day(s) by [" .. banner .. "] \n\n\n Reason: [" .. reason .. "] \n\n\n You will be unbanned in " .. timeRemainingInDays .. " day(s) \n\n\n" .. " [" .. rtimeatban .. "] (UTC)")
			end
		end
	end
end)
