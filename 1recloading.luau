-- A Config set BEFORE this script runs (e.g. in the auto-execute file, above the loadstring)
-- is kept; these defaults are only used when none was set.
getgenv().Config = getgenv().Config or {
	Misc = {
		PsCode = "",
		FastMode = false,
		WebhookURL = "",
		FpsCap = 25,
	},
	CircleQueue = {
		Enabled = true,
		Order = {
			"", -- First priority - goes to circle first
			"", -- Second priority - waits for Account1
			"", -- Third priority - waits for Account1 and Account2
			"", -- Add more as needed
		},
	},
}

if LPH_OBFUSCATED then
	LRM_INIT_SCRIPT(function()
		function isIdInList(id, ids)
			local AssetService = game:GetService("AssetService")

			local placeids = {}
			local success, pages = pcall(function()
				return AssetService:GetGamePlacesAsync()
			end)

			if success and pages then
				local currentPage = pages
				while true do
					for _, place in currentPage:GetCurrentPage() do
						table.insert(placeids, place.PlaceId)
					end
					if currentPage.IsFinished then
						break
					end
					task.wait() -- Yield to prevent freezing
					local ok, nextPage = pcall(function()
						currentPage:AdvanceToNextPageAsync()
					end)
					if not ok then
						break
					end
					task.wait()
				end
			end
			for _, soulId in ipairs(ids) do
				if soulId == id or table.find(placeids, soulId) then
					return true
				end
			end

			return false
		end
		local placeId = game.PlaceId
		local GPO = isIdInList(placeId, { 1730877806 })
		if GPO then
			repeat
				task.wait()
			until game:IsLoaded()
			task.wait(1)
			local function getExecutor()
				if SELIWARE_LOADED or seliware or getgenv().seliware then
					return "Seliware"
				end

				if DELTA_LOADED or Delta or delta or is_delta_closure or (getgenv and getgenv().Delta) then
					return "Delta"
				end

				if POTASSIUM_LOADED or Potassium or potassium or (getgenv and getgenv().Potassium) then
					return "Potassium"
				end

				if WAVE_LOADED or Wave or wave or is_wave_function or (getgenv and getgenv().Wave) then
					return "Wave"
				end

				if
					VELOCITY_LOADED
					or Velocity
					or velocity
					or is_velocity_closure
					or (getgenv and getgenv().Velocity)
				then
					return "Velocity"
				end

				if getexecutorname then
					local success, name = pcall(getexecutorname)
					if success and name then
						return name
					end
				end

				if identifyexecutor then
					local success, name = pcall(identifyexecutor)
					if success and name then
						return name
					end
				end

				return "Unknown"
			end

			local detectedExecutor = getExecutor()
			print("Executor detected:", detectedExecutor)
			if
				(
					detectedExecutor == "Seliware"
					or detectedExecutor == "Potassium"
					or detectedExecutor == "Wave"
					or detectedExecutor == "Velocity"
				) and placeId ~= 1730877806
			then
				local player = game.Players.LocalPlayer
				local LogService = game:GetService("LogService")
				local errorAlreadyHandled = false

				local ErrorExclusionList = {
					"raiseteleportinitfailedevent",
					"previous teleport is in processing",
					"isteleporting",
					"teleport failed",
					"teleportasync",
				}

				local function isExcludedError(message, stackTrace)
					local combinedText = string.lower(tostring(message) .. " " .. tostring(stackTrace))

					for _, pattern in ipairs(ErrorExclusionList) do
						local found = string.find(combinedText, pattern, 1, true)
						if found then
							warn("⚠️ Excluded error (no kick):", message)
							return true
						end
					end

					return false
				end

				local function isGameScriptError(message, stackTrace)
					local combinedText = (tostring(message) .. " " .. tostring(stackTrace)):lower()

					if
						combinedText:find("rbxassetid")
						or combinedText:find("failed to load")
						or combinedText:find("request asset")
						or combinedText:find("asset was not found")
						or combinedText:find("unable to load")
						or combinedText:find("content failed")
						or combinedText:find("failed to process")
					then
						return true
					end

					local gameLocations = {
						"workspace",
						"replicatedstorage",
						"replicatedfirst",
						"serverscriptservice",
						"serverstorage",
						"starterplayer",
						"startergui",
						"starterpack",
						"lighting",
						"soundservice",
						"chat",
						"teams",
						"players",
					}

					for _, location in ipairs(gameLocations) do
						if combinedText:find(location) then
							return true
						end
					end

					return false
				end

				local function sendErrorAndKick(err, stack)
					if errorAlreadyHandled then
						return
					end

					if isGameScriptError(err, stack) then
						warn("⚠️ Ignoring game script error:", err)
						return
					end

					-- Add this check to skip kicking for excluded errors
					if isExcludedError(err, stack) then
						warn("⚠️ Excluded error detected (no kick):", err)
						return
					end

					errorAlreadyHandled = true

					local errorMsg = tostring(err)
					local maxLength = 200
					if #errorMsg > maxLength then
						errorMsg = errorMsg:sub(1, maxLength) .. "..."
					end

					player:Kick("Error detected - Auto DC to prevent ban\n\n ERROR: \n" .. errorMsg)
				end

				LogService.MessageOut:Connect(function(message, messageType)
					if messageType == Enum.MessageType.MessageError then
						sendErrorAndKick(message, "Caught via LogService")
					end
				end)

				local ScriptContext = game:GetService("ScriptContext")
				if ScriptContext then
					ScriptContext.Error:Connect(function(message, stackTrace, script)
						sendErrorAndKick(message, stackTrace)
					end)
				end
			end
		end
		task.wait()
	end)
end

if not LPH_OBFUSCATED then
	LPH_NO_UPVALUES = function(fn)
		return fn
	end
	LRM_ScriptVersion = 001
	LRM_SecondsLeft = math.huge
	LRM_TotalExecutions = 0
	script_key = false
	function isIdInList(id, ids)
		local AssetService = game:GetService("AssetService")

		local placeids = {}
		local success, pages = pcall(function()
			return AssetService:GetGamePlacesAsync()
		end)

		if success and pages then
			local currentPage = pages
			while true do
				for _, place in currentPage:GetCurrentPage() do
					table.insert(placeids, place.PlaceId)
				end
				if currentPage.IsFinished then
					break
				end
				task.wait() -- Yield to prevent freezing
				local ok, nextPage = pcall(function()
					currentPage:AdvanceToNextPageAsync()
				end)
				if not ok then
					break
				end
				task.wait()
			end
		end
		for _, soulId in ipairs(ids) do
			if soulId == id or table.find(placeids, soulId) then
				return true
			end
		end

		return false
	end
	local placeId = game.PlaceId
	local GPO = isIdInList(placeId, { 1730877806 })
	if GPO then
		repeat
			task.wait()
		until game:IsLoaded()
		task.wait(1)
		local function getExecutor()
			if SELIWARE_LOADED or seliware or getgenv().seliware then
				return "Seliware"
			end

			if DELTA_LOADED or Delta or delta or is_delta_closure or (getgenv and getgenv().Delta) then
				return "Delta"
			end

			if POTASSIUM_LOADED or Potassium or potassium or (getgenv and getgenv().Potassium) then
				return "Potassium"
			end

			if WAVE_LOADED or Wave or wave or is_wave_function or (getgenv and getgenv().Wave) then
				return "Wave"
			end

			if VELOCITY_LOADED or Velocity or velocity or is_velocity_closure or (getgenv and getgenv().Velocity) then
				return "Velocity"
			end

			if getexecutorname then
				local success, name = pcall(getexecutorname)
				if success and name then
					return name
				end
			end

			if identifyexecutor then
				local success, name = pcall(identifyexecutor)
				if success and name then
					return name
				end
			end

			return "Unknown"
		end

		local detectedExecutor = getExecutor()
		print("Executor detected:", detectedExecutor)
		if
			(
				detectedExecutor == "Seliware"
				or detectedExecutor == "Potassium"
				or detectedExecutor == "Wave"
				or detectedExecutor == "Velocity"
			) and placeId ~= 1730877806
		then
			local player = game.Players.LocalPlayer
			local LogService = game:GetService("LogService")
			local errorAlreadyHandled = false

			local function isGameScriptError(message, stackTrace)
				local combinedText = (tostring(message) .. " " .. tostring(stackTrace)):lower()

				if
					combinedText:find("rbxassetid")
					or combinedText:find("failed to load")
					or combinedText:find("request asset")
					or combinedText:find("asset was not found")
					or combinedText:find("unable to load")
					or combinedText:find("content failed")
					or combinedText:find("failed to process")
				then
					return true
				end

				local gameLocations = {
					"workspace",
					"replicatedstorage",
					"replicatedfirst",
					"serverscriptservice",
					"serverstorage",
					"starterplayer",
					"startergui",
					"starterpack",
					"lighting",
					"soundservice",
					"chat",
					"teams",
					"players",
				}

				for _, location in ipairs(gameLocations) do
					if combinedText:find(location) then
						return true
					end
				end

				return false
			end

			local function sendErrorAndKick(err, stack)
				if errorAlreadyHandled then
					return
				end

				if isGameScriptError(err, stack) then
					warn("⚠️ Ignoring game script error:", err)
					return
				end

				errorAlreadyHandled = true

				warn("[AutoDC] kicking on error: " .. tostring(err) .. " | stack: " .. tostring(stack))
				task.wait(0.5) -- let the console flush the line above before the kick
				player:Kick("Error detected - Auto DC to prevent ban")
			end

			LogService.MessageOut:Connect(function(message, messageType)
				if messageType == Enum.MessageType.MessageError then
					sendErrorAndKick(message, "Caught via LogService")
				end
			end)

			local ScriptContext = game:GetService("ScriptContext")
			if ScriptContext then
				ScriptContext.Error:Connect(function(message, stackTrace, script)
					sendErrorAndKick(message, stackTrace)
				end)
			end
		end
	end
end

repeat
	task.wait()
until game:IsLoaded()
local Players = game:GetService("Players")
local player = Players.LocalPlayer or Players.PlayerAdded:Wait()

repeat
	task.wait(0.1)
until game:IsLoaded()

repeat
	task.wait(0.1)
until player:FindFirstChild("Loaded") and player.Loaded.Value == true

game:GetService("Players").LocalPlayer.Idled:Connect(function()
	local vim = Instance.new("VirtualInputManager")
	vim:SendMouseButtonEvent(1, 1, 0, true, game, 0)
	task.wait(0.1)
	vim:SendMouseButtonEvent(1, 1, 0, false, game, 0)
	vim:Destroy()
end)

local Players = game:GetService("Players")
local Localplayer = Players.LocalPlayer or Players.PlayerAdded:Wait()

repeat
	task.wait()
until game:IsLoaded() and Localplayer:FindFirstChild("Loaded") and Localplayer.Loaded

local Player = game.Players.LocalPlayer or game:GetService("Players").LocalPlayer
local PlayerGui = Player:WaitForChild("PlayerGui")

local Others = {}
local ValuesTable = {}
local ConnectionsTable = {}
local Objects = {}

local Services = {
	Players = game:GetService("Players"),
	ReplicatedStorage = game:GetService("ReplicatedStorage"),
	RunService = game:GetService("RunService"),
	UserInputService = game:GetService("UserInputService"),
	HttpService = game:GetService("HttpService"),
	Stats = game:GetService("Stats"),
	GuiService = game:GetService("GuiService"),
	TweenService = game:GetService("TweenService"),
}

local idsData = {
	MainMenu = 1730877806,
	Universe = 6360478118,
	TradeHub = 6811831486,
	FirstSea = 3978370137,
	SecondSea = 7465136166,
	Dungeon = 11424731604,
}

local ids = setmetatable({}, {
	__index = function(t, key)
		return game.PlaceId == idsData[key]
	end,
})

WebhookIcons = {
	Logo = "https://r2.e-z.host/5dcdabc3-df7f-4ba3-8b8f-48886f22a31f/tbvcypwz.jpg",
	Warning = "https://r2.e-z.host/5dcdabc3-df7f-4ba3-8b8f-48886f22a31f/tbvcypwz.jpg",
	MC = "https://r2.e-z.host/5dcdabc3-df7f-4ba3-8b8f-48886f22a31f/tbvcypwz.jpg",
	Merchant = "https://r2.e-z.host/5dcdabc3-df7f-4ba3-8b8f-48886f22a31f/tbvcypwz.jpg",
	RandomFruit = "https://r2.e-z.host/5dcdabc3-df7f-4ba3-8b8f-48886f22a31f/tbvcypwz.jpg",
}

if getgenv().Config and getgenv().Config.Misc then
	local misc = getgenv().Config.Misc

	if misc.FpsCap then
		setfpscap(misc.FpsCap)
	end

	-- ============================================================
	-- OPTIMIZED FASTMODE - Drop-in replacement
	-- ============================================================
	-- Changes from original:
	--   1. Removed workspace-wide GetDescendants() scan (was scanning 10k+ objects)
	--   2. Removed workspace.DescendantAdded listener (fired for EVERY new object)
	--   3. Targeted scanning: only Islands, Effects, and specific workspace children
	--   4. Single DescendantAdded listener on Islands only (no double-fire)
	--   5. Removed redundant lockOptimizations loop (settings don't revert on their own)
	--   6. WeakValue table for optimizedObjects (auto-GC destroyed objects)
	--   7. Batch yielding tuned: yield every 200 objects instead of 100
	--   8. Lighting locked via PropertyChanged instead of polling loop
	--   9. Collapsed redundant optimize passes into one
	-- ============================================================

	if misc.FastMode then
		local RunService = game:GetService("RunService")
		local Lighting = game:GetService("Lighting")
		local Players = game:GetService("Players")
		local Terrain = workspace:FindFirstChildOfClass("Terrain")
		local player = Players.LocalPlayer

		-- Body part names for skip-coloring check
		local PLAYER_BODY_PARTS = {
			Head = true,
			Torso = true,
			UpperTorso = true,
			LowerTorso = true,
			LeftUpperArm = true,
			LeftLowerArm = true,
			LeftHand = true,
			RightUpperArm = true,
			RightLowerArm = true,
			RightHand = true,
			LeftUpperLeg = true,
			LeftLowerLeg = true,
			LeftFoot = true,
			RightUpperLeg = true,
			RightLowerLeg = true,
			RightFoot = true,
		}

		local NEUTRAL_COLOR = Color3.new(0.568627, 0.568627, 0.568627)
		local SMOOTH_PLASTIC = Enum.Material.SmoothPlastic
		local PERFORMANCE_FIDELITY = Enum.RenderFidelity.Performance

		-- Use weak values so destroyed objects get garbage collected automatically
		local optimizedObjects = setmetatable({}, { __mode = "v" })

		-- ── Lighting & terrain (one-shot, no polling) ────────────────────

		local function applyGraphicsSettings()
			pcall(function()
				settings().Rendering.QualityLevel = Enum.QualityLevel.Level01
				local ugs = UserSettings():GetService("UserGameSettings")
				ugs.SavedQualityLevel = Enum.SavedQualitySetting.QualityLevel1
				ugs.GraphicsQualityLevel = 4
				ugs.GraphicsMode = Enum.GraphicsMode.Manual
			end)

			pcall(function()
				if Terrain then
					Terrain.WaterWaveSize = 0
					Terrain.WaterWaveSpeed = 0
					Terrain.WaterReflectance = 0
					Terrain.WaterTransparency = 0
					Terrain.Decoration = false
				end

				Lighting.GlobalShadows = false
				Lighting.FogEnd = 9e9
				Lighting.FogStart = 0
				Lighting.Brightness = 0
				Lighting.OutdoorAmbient = Color3.new(1, 1, 1)
				Lighting.Ambient = Color3.new(1, 1, 1)
				Lighting.EnvironmentDiffuseScale = 0
				Lighting.EnvironmentSpecularScale = 0
			end)
		end

		-- Disable all current post effects and lock future ones via ChildAdded
		local function disablePostEffects()
			pcall(function()
				for _, effect in ipairs(Lighting:GetChildren()) do
					if effect:IsA("PostEffect") then
						effect.Enabled = false
					end
				end
			end)

			-- Lock: any new post effect gets disabled immediately
			Lighting.ChildAdded:Connect(function(effect)
				if effect:IsA("PostEffect") then
					effect.Enabled = false
				end
			end)

			-- Lock: if game re-enables GlobalShadows, turn it back off
			Lighting:GetPropertyChangedSignal("GlobalShadows"):Connect(function()
				if Lighting.GlobalShadows then
					Lighting.GlobalShadows = false
				end
			end)
		end

		-- ── Object optimization (inlined for speed) ──────────────────────

		local function disableEffect(effect)
			if effect:IsA("ParticleEmitter") or effect:IsA("Trail") or effect:IsA("Beam") then
				effect.Enabled = false
			elseif effect:IsA("PointLight") or effect:IsA("SpotLight") or effect:IsA("SurfaceLight") then
				effect.Enabled = false
				effect.Brightness = 0
			elseif effect:IsA("Fire") or effect:IsA("Smoke") or effect:IsA("Sparkles") then
				effect.Enabled = false
			elseif effect:IsA("Explosion") then
				effect.BlastPressure = 1
				effect.BlastRadius = 1
				effect.Visible = false
			elseif effect:IsA("Sound") then
				effect.Volume = 0
			elseif effect:IsA("Decal") or effect:IsA("Texture") then
				effect.Transparency = 1
			elseif effect:IsA("SurfaceAppearance") then
				effect.TextureID = ""
			end
		end

		local function optimizePart(part, isPlayerPart)
			if optimizedObjects[part] then
				return
			end
			optimizedObjects[part] = part

			if part:IsA("MeshPart") then
				part.TextureID = ""
				part.Material = SMOOTH_PLASTIC
				part.RenderFidelity = PERFORMANCE_FIDELITY
				part.CastShadow = false
				part.Reflectance = 0
				if not isPlayerPart and not PLAYER_BODY_PARTS[part.Name] then
					part.Color = NEUTRAL_COLOR
				end
			elseif part:IsA("BasePart") then
				part.Material = SMOOTH_PLASTIC
				part.Reflectance = 0
				part.CastShadow = false
				if not isPlayerPart and not PLAYER_BODY_PARTS[part.Name] then
					part.Color = NEUTRAL_COLOR
				end
			end

			for _, child in ipairs(part:GetChildren()) do
				pcall(disableEffect, child)
			end
		end

		local YIELD_INTERVAL = 200

		local function optimizeContainer(container, isPlayer)
			if not container then
				return
			end
			task.spawn(function()
				local count = 0
				for _, desc in ipairs(container:GetDescendants()) do
					count = count + 1
					pcall(function()
						if desc:IsA("BasePart") then
							optimizePart(desc, isPlayer)
						else
							disableEffect(desc)
						end
					end)
					if count % YIELD_INTERVAL == 0 then
						task.wait()
					end
				end
			end)
		end

		local function optimizeCharacter(character)
			if not character then
				return
			end
			optimizeContainer(character, true)
		end

		local function setupPlayerMonitor()
			if player.Character then
				optimizeCharacter(player.Character)
			end
			player.CharacterAdded:Connect(function(character)
				task.wait(0.5)
				optimizeCharacter(character)
			end)
		end

		local function optimizeIslands()
			local islands = workspace:FindFirstChild("Islands")
			if not islands then
				return
			end

			optimizeContainer(islands, false)

			islands.DescendantAdded:Connect(function(child)
				task.defer(function()
					pcall(function()
						if child:IsA("BasePart") then
							optimizePart(child, false)
						else
							disableEffect(child)
						end
					end)
				end)
			end)
		end

		local function optimizeEffects()
			local effects = workspace:FindFirstChild("Effects")
			if not effects then
				return
			end

			optimizeContainer(effects, false)

			effects.DescendantAdded:Connect(function(child)
				task.defer(function()
					pcall(function()
						if child:IsA("BasePart") then
							optimizePart(child, false)
						else
							disableEffect(child)
						end
					end)
				end)
			end)
		end

		local SKIP_CONTAINERS = {
			Islands = true,
			Effects = true,
			PlayerCharacters = true,
			Camera = true,
			Terrain = true,
			NPCs = true,
		}

		local function optimizeOtherWorkspaceChildren()
			task.spawn(function()
				local count = 0
				for _, child in ipairs(workspace:GetChildren()) do
					if not SKIP_CONTAINERS[child.Name] and not child:IsA("Camera") and not child:IsA("Terrain") then
						pcall(function()
							for _, desc in ipairs(child:GetDescendants()) do
								count = count + 1
								if desc:IsA("BasePart") then
									optimizePart(desc, false)
								else
									pcall(disableEffect, desc)
								end
								if count % YIELD_INTERVAL == 0 then
									task.wait()
								end
							end
						end)
					end
				end
			end)
		end

		local function InitializeFastMode()
			applyGraphicsSettings()
			disablePostEffects()

			task.wait(0.5)

			optimizeIslands()
			optimizeEffects()
			optimizeOtherWorkspaceChildren()
			setupPlayerMonitor()
		end

		InitializeFastMode()
	end

	if misc.TrackStats then
		local TrackStatsApiKey = getgenv().Config and getgenv().Config.Misc and getgenv().Config.Misc.TrackStats

		if TrackStatsApiKey and TrackStatsApiKey ~= "" then
			local HttpService = game:GetService("HttpService")
			local ReplicatedStorage = game:GetService("ReplicatedStorage")
			local Players = game:GetService("Players")
			local Player = Players.LocalPlayer

			local SEA_PLACES = {
				[3978370137] = 1,
				[6811831486] = 1,
				[7465136166] = 2,
				[11424731604] = 2,
			}

			local GAME_PLACE_ID = game.PlaceId

			if SEA_PLACES[GAME_PLACE_ID] then
				local config = {
					API_KEY = TrackStatsApiKey,
					Send_Interval_Seconds = math.random(200, 300),
					Max_Retries = 3,
					Retry_Delay = 5,
					Debug_Mode = false,
				}

				local API_URL = nil

				local function getStatsFolder()
					return ReplicatedStorage:FindFirstChild("Stats" .. Player.Name)
				end

				local function getPlayerLevel()
					local result = nil
					pcall(function()
						local statsFolder = getStatsFolder()
						if statsFolder and statsFolder:FindFirstChild("Stats") then
							local level = statsFolder.Stats:FindFirstChild("Level")
							if level then
								result = level.Value
							end
						end
					end)
					return result
				end

				local function getPlayerPeli()
					local result = nil
					pcall(function()
						local statsFolder = getStatsFolder()
						if statsFolder and statsFolder:FindFirstChild("Stats") then
							local peli = statsFolder.Stats:FindFirstChild("Peli")
							if peli then
								result = peli.Value
							end
						end
					end)
					return result
				end

				local function getPlayerBounty()
					local result = nil
					pcall(function()
						local statsFolder = getStatsFolder()
						if statsFolder and statsFolder:FindFirstChild("Stats") then
							local bounty = statsFolder.Stats:FindFirstChild("Bounty")
							if bounty then
								result = bounty.Value
							end
						end
					end)
					return result
				end

				local function getPlayerRace()
					local result = nil
					pcall(function()
						local statsFolder = getStatsFolder()
						if statsFolder and statsFolder:FindFirstChild("Customization") then
							local race = statsFolder.Customization:FindFirstChild("Race")
							if race then
								result = race.Value
							end
						end
					end)
					return result
				end

				local function getPlayerFruit()
					local result = nil
					pcall(function()
						local statsFolder = getStatsFolder()
						if statsFolder and statsFolder:FindFirstChild("Stats") then
							local fruit = statsFolder.Stats:FindFirstChild("DF")
							if fruit then
								result = fruit.Value == "" and "No Fruit" or fruit.Value
							end
						end
					end)
					return result
				end

				local function getInventory()
					local items = {}
					pcall(function()
						local statsFolder = getStatsFolder()
						if statsFolder and statsFolder:FindFirstChild("Inventory") then
							local invValue = statsFolder.Inventory:FindFirstChild("Inventory")
							if invValue and invValue.Value then
								local ok, invTable = pcall(function()
									return HttpService:JSONDecode(invValue.Value)
								end)
								if ok and type(invTable) == "table" then
									for itemName, itemData in pairs(invTable) do
										local count = 1
										if type(itemData) == "table" then
											count = itemData.Count
												or itemData.count
												or itemData.Amount
												or itemData.amount
												or 1
										elseif type(itemData) == "number" then
											count = itemData
										end
										table.insert(items, { name = itemName, Count = math.max(1, math.floor(count)) })
									end
								end
							end
						end
					end)
					return items
				end

				local function getIsland()
					local result = nil
					pcall(function()
						local statsFolder = getStatsFolder()
						if statsFolder and statsFolder:FindFirstChild("Stats") then
							local spawnPoint = statsFolder.Stats:FindFirstChild("SpawnPoint")
							if spawnPoint and spawnPoint.Value and spawnPoint.Value ~= "" then
								result = spawnPoint.Value
								return
							end
							local island = statsFolder.Stats:FindFirstChild("Island")
							if island and island.Value and island.Value ~= "" then
								result = island.Value
							end
						end
					end)
					return result
				end

				local function buildPayload()
					return {
						gamePlaceId = "1730877806",
						gpo_id = Player.UserId,
						player_nick = Player.Name,
						level = getPlayerLevel() or 0,
						inventory = getInventory(),
						fruit = getPlayerFruit(),
						race = getPlayerRace(),
						bounty = getPlayerBounty(),
						peli = getPlayerPeli(),
						island = getIsland(),
						sea = SEA_PLACES[GAME_PLACE_ID] or 1,
					}
				end

				local function sendToAPI(payload, retryCount)
					retryCount = retryCount or 0
					if retryCount >= config.Max_Retries then
						return false
					end
					if not payload or type(payload) ~= "table" then
						return false
					end

					local success, response = pcall(function()
						local encoded = HttpService:JSONEncode(payload)
						local headers = {
							["Content-Type"] = "application/json",
							["X-API-Key"] = config.API_KEY,
						}

						local requestFunc = (syn and syn.request)
							or http_request
							or request
							or HttpPost
							or (http and http.request)
						if not requestFunc then
							return false
						end

						return requestFunc({
							Url = API_URL,
							Method = "POST",
							Headers = headers,
							Body = encoded,
						})
					end)

					if success and response then
						if response.StatusCode and response.StatusCode >= 200 and response.StatusCode < 300 then
							if config.Debug_Mode then
								print("[TrackStats] ✓ Data sent")
							end
							return true
						elseif
							response.StatusCode
							and response.StatusCode >= 500
							and retryCount < config.Max_Retries
						then
							task.wait(config.Retry_Delay)
							return sendToAPI(payload, retryCount + 1)
						end
					elseif retryCount < config.Max_Retries then
						task.wait(config.Retry_Delay)
						return sendToAPI(payload, retryCount + 1)
					end
					return false
				end

				-- Auto-start
				task.spawn(function()
					task.wait(5)
					sendToAPI(buildPayload())

					while true do
						task.wait(config.Send_Interval_Seconds)
						config.Send_Interval_Seconds = math.random(200, 300)
						pcall(function()
							sendToAPI(buildPayload())
						end)
					end
				end)
			end
		end
	end

	if misc.WebhookURL and misc.WebhookURL ~= "" and misc.WebhookURL ~= "YourURL" then
		getgenv().WebHook = misc.WebhookURL
	end
end
if LPH_OBFUSCATED then
	task.spawn(function()
		errorMessageConnection = game:GetService("GuiService").ErrorMessageChanged:Connect(function()
			wait(1)
			game:GetService("TeleportService"):Teleport(6360478118)
		end)
	end)
end
getgenv().TweenSpeed = 70
if ids.MainMenu then
	local player = game:GetService("Players").LocalPlayer
	repeat
		task.wait()
	until player and player.AccountAge

	function PlayerLevel()
		local statsFolder = game.ReplicatedStorage:FindFirstChild("Stats" .. player.Name)
		if not statsFolder then
			return nil
		end

		local stats = statsFolder:FindFirstChild("Stats")
		if not stats then
			return nil
		end

		local levelValue = stats:FindFirstChild("Level")
		if not levelValue then
			return nil
		end

		return levelValue.Value
	end

	if player.AccountAge > 30 then
		for i = 1, 500 do
			pcall(function()
				game:GetService("TeleportService"):Teleport(6360478118, game:GetService("Players").LocalPlayer)
			end)
			task.wait(0.1)
		end
	else
		if player.AccountAge > 30 then
			for i = 1, 500 do
				pcall(function()
					game:GetService("TeleportService"):Teleport(6360478118, game:GetService("Players").LocalPlayer)
				end)
				task.wait(0.1)
			end
		else
			local function JoinPS(PS)
				while task.wait(0.5) do
					spawn(function()
						if not PS or PS == "" then
							return
						end

						local TextBox = PlayerGui.reserved.Frame.CodeBox.TextBox

						local ChooseType = PlayerGui:WaitForChild("chooseType", 2)
						local ChooseSea = PlayerGui:WaitForChild("ConfirmationPrompt", 5)

						if ChooseType then
							spawn(function()
								local reg = ChooseType.Frame.Options.Universe
								if reg then
									local args = {
										"universeHub",
									}
									PlayerGui:WaitForChild("chooseType")
										:WaitForChild("Frame")
										:WaitForChild("RemoteEvent")
										:FireServer(unpack(args))
								end
							end)
						else
							TextBox.Text = PS
							local args = { [1] = PS }
							game:GetService("ReplicatedStorage")
								:WaitForChild("Events")
								:WaitForChild("reserved")
								:InvokeServer(unpack(args))
						end
					end)
				end
			end

			if getgenv().Config and getgenv().Config.Misc and getgenv().Config.Misc.PsCode then
				JoinPS(getgenv().Config.Misc.PsCode)
			end
		end
	end
elseif ids.Universe then
	if player.AccountAge < 30 and not game:GetService("ReplicatedStorage").isPrivateServer.Value then
		for i = 1, 500 do
			pcall(function()
				game:GetService("TeleportService"):Teleport(1730877806, game:GetService("Players").LocalPlayer)
			end)
			task.wait(0.1)
		end
	else
		for i = 1, 500 do
			pcall(function()
				local args = {
					"ImpelDown",
				}
				game:GetService("ReplicatedStorage")
					:WaitForChild("Events")
					:WaitForChild("Queue")
					:InvokeServer(unpack(args))
			end)
			task.wait(1)
		end
	end
elseif ids.SecondSea then
	local SpawnPointCF = CFrame.new(5936, 6, -9471)
	local player = Services.Players.LocalPlayer
	local character
	local humanoid
	local hrp
	local camera = workspace.CurrentCamera
	local PLayerstats = Services.ReplicatedStorage:WaitForChild("Stats" .. player.Name, 30)
	local CircleLocation = Vector3.new(5875, 9, -10221)
	local function updateCharacterRefs()
		character = player.Character
		if character then
			hrp = character:WaitForChild("HumanoidRootPart", 2)
			humanoid = character:WaitForChild("Humanoid", 2)
		else
			hrp = nil
			humanoid = nil
		end
	end
	Others.AnchorReachedPosition = false
	player.CharacterAdded:Connect(function()
		repeat
			task.wait()
			updateCharacterRefs()
		until character and hrp and humanoid
		Others.BodyVelocity = nil
	end)

	updateCharacterRefs()

	local Skills = PLayerstats:FindFirstChild("Skills")
	local backpack = player:FindFirstChild("Backpack")

	-- tweenWithTeleport is only defined in the Dungeon branch; SecondSea needs its own.
	function tweenWithTeleport(pos, speed, _offsetY)
		if not hrp or not hrp.Parent then
			return
		end
		local target = typeof(pos) == "CFrame" and pos or CFrame.new(pos)
		local dist = (hrp.Position - target.Position).Magnitude
		if dist < 1 then
			return
		end
		local tween = Services.TweenService:Create(
			hrp,
			TweenInfo.new(dist / math.max(speed or 50, 1), Enum.EasingStyle.Linear),
			{ CFrame = target }
		)
		tween:Play()
		tween.Completed:Wait()
	end

	do --// Functions
		Others.LastDashTime = 0
		Others.DashCooldown = 1
		Others.Ready = false

		function ItemCheck(itemName)
			local inventory = game:GetService("ReplicatedStorage")["Stats" .. player.Name].Inventory.Inventory
			local inventoryValue = inventory.Value

			local inventoryTable
			local success, result = pcall(function()
				inventoryTable = game:GetService("HttpService"):JSONDecode(inventoryValue)
			end)

			if not success then
				warn("Failed to decode inventory value:", result)
				return false
			end

			return inventoryTable[itemName] ~= nil
		end

		function GetDistanceTo(Position)
			if not Position then
				return math.huge
			end

			if typeof(Position) == "CFrame" then
				Position = Position.Position
			elseif typeof(Position) ~= "Vector3" then
				return
			end

			return (hrp.Position - Position).Magnitude
		end

		function GetSpawnNPCPosition()
			local npcs = workspace:FindFirstChild("NPCs")
			if not npcs then
				return nil
			end

			local robo = npcs:FindFirstChild("Robo")
			if not robo then
				return nil
			end

			local npcHRP = robo:FindFirstChild("HumanoidRootPart")
			if not npcHRP then
				return nil
			end

			return npcHRP.Position
		end

		function SetSpawnPoint()
			local dist = GetDistanceTo(SpawnPointCF)

			if dist > 20 then
				tweenWithTeleport(SpawnPointCF, 50, 4000)
				task.wait(1)
				return
			end

			local npcPos = GetSpawnNPCPosition()
			if not npcPos then
				task.wait(1)
				return
			end

			local npcDist = (hrp.Position - npcPos).Magnitude
			if npcDist < 20 then
				task.wait(0.5)
				Services.ReplicatedStorage.Events.SetSpawn:FireServer()
			end
		end

		function getSpawnPointLoc()
			local stats = PLayerstats:FindFirstChild("Stats")
			if stats then
				local spawnPoint = stats:FindFirstChild("SpawnPoint")
				if spawnPoint then
					return spawnPoint.Value
				end
			end
		end

		function posOf(plr)
			local c = plr.Character
			local n = c and c:FindFirstChild("realPos")
			if n and n.Value then
				return n.Value.Position
			end
			local r = c and c:FindFirstChild("HumanoidRootPart")
			return r and r.Position or nil
		end

		function getdistance(a, b)
			return (a - b).Magnitude
		end

		function HasGeppo()
			local stats = Services.ReplicatedStorage:FindFirstChild("Stats" .. player.Name)
			if not stats then
				return false
			end
			local skills = stats:FindFirstChild("Skills")
			if not skills then
				return false
			end
			local sky = skills:FindFirstChild("skyWalk")
			return sky and sky.Value or false
		end

		Others.LastGeppo = false
		Others.GeppoCooldown = 2

		function UseGeppo()
			Others.LastGeppo = true
			task.delay(Others.GeppoCooldown, function()
				Others.LastGeppo = false
			end)
			for i = 1, 2 do
				local args = {
					false,
				}
				game:GetService("ReplicatedStorage")
					:WaitForChild("Events")
					:WaitForChild("faceMouse")
					:FireServer(unpack(args))
				task.wait(0.5)
			end
		end
	end

	spawn(function()
		while true do
			task.wait(1)
			if getSpawnPointLoc() ~= "Impel Base" then
				SetSpawnPoint(SpawnPointCF)
			else
				Others.Ready = true
				break
			end
		end
	end)

	local CircleLocation = Vector3.new(5875, 9, -10221)
	local CIRCLE_CHECK_RADIUS = 15

	local function getCircleQueueOrder()
		if getgenv().Config and getgenv().Config.CircleQueue and getgenv().Config.CircleQueue.Order then
			return getgenv().Config.CircleQueue.Order
		end
		return {}
	end

	local function isQueueEnabled()
		if getgenv().Config and getgenv().Config.CircleQueue then
			return getgenv().Config.CircleQueue.Enabled ~= false -- Default to true if not set
		end
		return false
	end

	local function getMyPriority()
		local queueOrder = getCircleQueueOrder()
		for i, username in ipairs(queueOrder) do
			if username:lower() == player.Name:lower() then
				return i
			end
		end
		return 999
	end

	local function higherPriorityPlayerInServer()
		if not isQueueEnabled() then
			return false, nil
		end

		local myPriority = getMyPriority()
		local queueOrder = getCircleQueueOrder()

		for _, otherPlayer in pairs(Players:GetPlayers()) do
			if otherPlayer ~= player then
				for i, username in ipairs(queueOrder) do
					if username:lower() == otherPlayer.Name:lower() and i < myPriority then
						return true, otherPlayer.Name
					end
				end
			end
		end
		return false, nil
	end

	local function anyoneAtCircle()
		for _, otherPlayer in pairs(Players:GetPlayers()) do
			if otherPlayer ~= player and otherPlayer.Character then
				local otherHRP = otherPlayer.Character:FindFirstChild("HumanoidRootPart")
				if otherHRP and (otherHRP.Position - CircleLocation).Magnitude < CIRCLE_CHECK_RADIUS then
					return true, otherPlayer.Name
				end
			end
		end
		return false, nil
	end

	local function higherPriorityAtCircle()
		if not isQueueEnabled() then
			return false, nil
		end

		local myPriority = getMyPriority()
		local queueOrder = getCircleQueueOrder()

		for _, otherPlayer in pairs(Players:GetPlayers()) do
			if otherPlayer ~= player and otherPlayer.Character then
				local otherHRP = otherPlayer.Character:FindFirstChild("HumanoidRootPart")
				if otherHRP and (otherHRP.Position - CircleLocation).Magnitude < CIRCLE_CHECK_RADIUS then
					for i, username in ipairs(queueOrder) do
						if username:lower() == otherPlayer.Name:lower() and i < myPriority then
							return true, otherPlayer.Name
						end
					end
				end
			end
		end
		return false, nil
	end

	spawn(function()
		while true do
			task.wait(1)
			if not Others.Ready then
				continue
			end

			local dist = GetDistanceTo(CircleLocation)
			if dist <= 5 then
				task.wait(1)
				continue
			end

			if isQueueEnabled() then
				local myPriority = getMyPriority()
				local higherInServer, higherName = higherPriorityPlayerInServer()
				if higherInServer then
					local atCircle, _ = anyoneAtCircle()
					if atCircle then
						task.wait(5)
						continue
					end

					task.wait(3)

					local stillOccupied, _ = anyoneAtCircle()
					if stillOccupied then
						task.wait(5)
						continue
					end

					local stillHigher, _ = higherPriorityPlayerInServer()
					if stillHigher then
						task.wait(5)
						continue
					end
				end

				local occupied, _ = anyoneAtCircle()
				if occupied then
					task.wait(5)
					continue
				end

				tweenWithTeleport(CircleLocation, 50, 300)
			else
				local occupied, _ = anyoneAtCircle()
				if occupied then
					task.wait(math.random(5, 10))
					continue
				end

				tweenWithTeleport(CircleLocation, 50, 300)
			end

			task.wait(1)
		end
	end)
elseif ids.Dungeon then
	local ItemsToBuy = {
		["Mythical Fruit Chest"] = true,
		["Legendary Fruit Chest"] = false,
		["Rare Fruit Chest"] = false,

		["SP Reset Essence"] = false,
		["Spirit Color Essence"] = false,
		["Dark Root"] = false,
		["Race Reroll"] = false,
		["Raiui"] = false,
		["Kessui"] = false,
		["Vera's Whip"] = false,
		["Black Pitchfork"] = false,
		["Vera's Outfit"] = false,
		["Vera's Outfit 2"] = false,
		["Vera's Cap"] = false,
		["Han's Outfit"] = false,
		["Impel Guard Outfit"] = false,
		["Impel Guard Hat 1"] = false,
		["Impel Guard Hat 2"] = false,
		["Impel Officer Outfit"] = false,
		["Impel Officer Hat"] = false,
		["Shiryu's Cape"] = false,
		["Shiryu's Hat"] = false,
		["Shiryu's Outfit"] = false,
		["Flower Sword"] = false,
	}

	local MovementSystem = {
		isActive = false,
		currentType = nil,
		tweenState = nil,
		inSpawnTween = nil,
		inSpawnTarget = nil,
	}
	local RaiuiAnimsStartTime = 0
	local RAIUI_ANIM_TIMEOUT = 3
	local RaiuiAnimsEndTime = 0
	local RAIUI_RECHECK_COOLDOWN = 1.5
	local currentFloor3Boss = nil
	local lastBossSeenTime = 0
	local BOSS_CONFIRM_DELAY = 2
	function MovementSystem:Lock(movementType)
		if self.isActive then
			self:Unlock()
		end
		self.isActive = true
		self.currentType = movementType
		return true
	end

	function MovementSystem:Unlock()
		self.isActive = false
		self.currentType = nil
		if self.tweenState then
			self.tweenState.active = false
		end
		if self.inSpawnTween then
			self.inSpawnTween.active = false
		end
	end

	function MovementSystem:IsLocked()
		return self.isActive
	end

	function MovementSystem:CancelInSpawn()
		if self.inSpawnTween then
			self.inSpawnTween.active = false
			self.inSpawnTween = nil
			self.inSpawnTarget = nil
		end
	end

	function GetPeli()
		local stats = Services.ReplicatedStorage:FindFirstChild("Stats" .. player.Name)
		if not stats then
			return 0
		end
		local statsData = stats:FindFirstChild("Stats")
		return statsData and statsData:FindFirstChild("Peli") and statsData.Peli.Value or 0
	end

	local LocalPlayer = player
	local Character = LocalPlayer.Character or LocalPlayer.CharacterAdded:Wait()
	local Backpack = LocalPlayer.Backpack
	local PlayerHumpart = Character:WaitForChild("HumanoidRootPart")

	local savetwweenfarm = {}
	local TweensTable = {}
	local noClipConnection
	local openingChests = false
	local spirit_essence = false
	local spiritEssence = false
	local Speed = getgenv().TweenSpeed
	local selected_Offset = 2600
	local targetPosition = nil
	local targetFloorPosition = nil
	local CanFarm = true
	local notcuffed = false
	local equipMelee = false
	local FirstTime = false
	local SecondTime = false
	local firsttimefloor1 = false
	local TweenToStop = nil
	Npc = nil
	local CanTween = false
	local StepCounter = 1
	local skipPart = false
	local tpedback = false
	local DonutRunnable = false
	local SecondFloorSpawnedBoss = false
	local ThirdFloorSpawnedBoss = false
	local FourthSpawnedBoss = false
	local KilledBoss = false
	local FirstTimeFloor5 = false
	local finishedTime = false
	local number69 = 0
	local LastPlaceTween = nil
	floor = "1"
	local statsFolder = game.ReplicatedStorage:FindFirstChild("Stats" .. game.Players.LocalPlayer.Name)
	local value = statsFolder.Inventory.Inventory.Value
	local MythicalChestValue = value:match('"Mythical Fruit Chest":(%d+)') or 0
	local MythicalChestValue = tonumber(MythicalChestValue) or 0
	local MythicalChestsAmount = 0
	local StartFarmingTick = tick()
	local BuyMythical = false

	local function timePassedCalculation(Tick)
		local currentTime = tick()
		local timeDifference = math.floor(currentTime - Tick)

		local hours = math.floor(timeDifference / 3600)
		local remainingSeconds = timeDifference % 3600
		local minutes = math.floor(remainingSeconds / 60)
		local seconds = math.floor(remainingSeconds % 60)

		return string.format("%dh %dm %ds", hours, minutes, seconds)
	end

	function getTimePassed(Tick)
		if Tick then
			return timePassedCalculation(Tick)
		else
			warn("Tick not mentioned before")
			return "0h 0m 0s"
		end
	end

	local SecondFloorTable = {
		secondfloorPart1 = false,
		secondfloorPart2 = false,
		secondfloorPart3 = false,
		secondfloorPart4 = false,
		secondfloorPart5 = false,
		secondfloorPart6 = false,
		secondfloorPart7 = false,
		secondfloorPart8 = false,
		secondfloorPart9 = false,
		secondfloorPart10 = false,
	}

	local SecondFloorPositions = {
		Part1 = { Position = Vector3.new(3210.5830078125, 2380.4306640625, -20259.123046875) },
		Part2 = { Position = Vector3.new(3202.20751953125, 2378.431396484375, -20372.173828125) },
		Part3 = { Position = Vector3.new(3433.396240234375, 2378.4306640625, -20397.3203125) },
		Part4 = { Position = Vector3.new(3450.819580078125, 2378.4306640625, -20590.7890625) },
		Part5 = { Position = Vector3.new(3199.31103515625, 2343.738037109375, -20533.36328125) },
		Part6 = { Position = Vector3.new(3203.50146484375, 2428.4306640625, -20376.19140625) },
		Part7 = { Position = Vector3.new(3198.9306640625, 2378.380615234375, -20566.5703125) },
		Part8 = { Position = Vector3.new(3206.496337890625, 2396.688720703125, -20827.0546875) },
		Part9 = { Position = Vector3.new(3199.43359375, 2378.380615234375, -21072.609375) },
		Part10 = { Position = Vector3.new(3202.12256, 2372.40649, -20873.86725) },
	}

	local ThirdFloor = {
		Part1 = {
			Value = false,
			Position = Vector3.new(4964.24560546875, 2306.330078125, -20738.205078125),
			Lever = false,
		},
		Part2 = {
			Value = false,
			Position = Vector3.new(4805.38720703125, 2306.330078125, -20756.287109375),
			Lever = false,
		},
		Part3 = {
			Value = false,
			Position = Vector3.new(4699.15087890625, 2306.255859375, -20721.974609375),
			Lever = "LeftAreaLever",
		},
		Part4 = { Value = false, Position = Vector3.new(5099.9453125, 2306.330078125, -20780.99609375), Lever = false },
		Part5 = {
			Value = false,
			Position = Vector3.new(5163.779296875, 2306.255615234375, -20800.955078125),
			Lever = "RightAreaLever",
		},
		Part6 = {
			Value = false,
			Position = Vector3.new(4983.416015625, 2306.330078125, -20861.43359375),
			Lever = false,
		},
		Part7 = {
			Value = false,
			Position = Vector3.new(4948.2666015625, 2332.93017578125, -20912.62890625),
			Lever = false,
		},
		Part8 = {
			Value = false,
			Position = Vector3.new(4858.26953125, 2368.330078125, -20999.173828125),
			Lever = false,
		},
		Part9 = {
			Value = false,
			Position = Vector3.new(4799.82763671875, 2398.83056640625, -20797.91015625),
			Lever = false,
		},
		Part10 = {
			Value = false,
			Position = Vector3.new(5148.43408203125, 2398.1298828125, -20800.43359375),
			Lever = false,
		},
		Part11 = {
			Value = false,
			Position = Vector3.new(5546.73193359375, 2405.830078125, -20818.84765625),
			Lever = false,
		},
		Part12 = { Value = false, Position = Vector3.new(5593.4599609375, 2499.830078125, -20967.90625), Lever = false },
		Part13 = {
			Value = false,
			Position = Vector3.new(5654.6669921875, 2481.71728515625, -20514.548828125),
			Lever = false,
		},
		Part14 = {
			Value = false,
			Position = Vector3.new(5665.25048828125, 2482.330322265625, -20251.169921875),
			Lever = false,
		},
	}

	local FourthFloor = {
		Part1 = { Value = false, Position = Vector3.new(9993.8125, 1616.553955078125, -19118.841796875), Lever = false },
		Part2 = {
			Value = false,
			Position = Vector3.new(9994.8974609375, 1668.5535888671875, -19596.22265625),
			Lever = false,
		},
		Part3 = {
			Value = false,
			Position = Vector3.new(9739.0634765625, 1668.5535888671875, -19747.474609375),
			Lever = false,
		},
		Part4 = {
			Value = false,
			Position = Vector3.new(9669.4619140625, 1669.5386962890625, -20239.865234375),
			Lever = false,
		},
		Part5 = {
			Value = false,
			Position = Vector3.new(10124.1279296875, 1669.175048828125, -20304.375),
			Lever = false,
		},
		Part6 = {
			Value = false,
			Position = Vector3.new(10744.009765625, 1668.5535888671875, -20347.998046875),
			Lever = false,
		},
		Part7 = {
			Value = false,
			Position = Vector3.new(10957.7548828125, 1668.5535888671875, -20534.6953125),
			Lever = false,
		},
		Part8 = {
			Value = false,
			Position = Vector3.new(10938.66015625, 1669.179931640625, -20947.974609375),
			Lever = false,
		},
		Part9 = {
			Value = false,
			Position = Vector3.new(10566.3857421875, 1658.66455078125, -20986.9609375),
			Lever = false,
		},
		Part10 = {
			Value = false,
			Position = Vector3.new(9995.662109375, 1658.5535888671875, -21019.478515625),
			Lever = false,
		},
		Part11 = {
			Value = false,
			Position = Vector3.new(9978.056640625, 1694.553466796875, -21877.171875),
			Lever = false,
		},
		Part12 = {
			Value = false,
			Position = Vector3.new(9975.515625, 1665.553466796875, -22142.986328125),
			Lever = false,
		},
	}

	local FifthFloor = {
		Part1 = {
			Value = false,
			Position = Vector3.new(10605.0546875, 542.7198486328125, -27458.15234375),
			Lever = false,
		},
		Part2 = {
			Value = false,
			Position = Vector3.new(10594.2021484375, 490.72015380859375, -28463.830078125),
			Lever = false,
		},
		Part3 = {
			Value = false,
			Position = Vector3.new(10138.6943359375, 459.91595458984375, -28431.333984375),
			Lever = false,
		},
		Part4 = { Value = false, Position = Vector3.new(9677.078125, 512.72021484375, -28457.68359375), Lever = false },
		Part5 = {
			Value = false,
			Position = Vector3.new(9638.5234375, 451.81915283203125, -27622.115234375),
			Lever = false,
		},
	}

	function ItemCheck(itemName)
		local inventory = Services.ReplicatedStorage["Stats" .. player.Name].Inventory.Inventory
		local inventoryValue = inventory.Value

		local inventoryTable
		local success, result = pcall(function()
			inventoryTable = game:GetService("HttpService"):JSONDecode(inventoryValue)
		end)

		if not success then
			warn("Failed to decode inventory value:", result)
			return false
		end

		return inventoryTable[itemName] or 0
	end

	local COLLIDE_PARTS = { HumanoidRootPart = true, Head = true, Torso = true, UpperTorso = true, LowerTorso = true }

	-- NOCLIP: on only while travelling/hovering, collisions back on when idle. Turning it fully
	-- off (false) made moves collide with Floor 1's trees: the key sits by a tree, the move got
	-- stuck, and every stuck hop pad-rose 40 studs, climbing to Y 2380 and earning flight strikes.
	local NOCLIP_ENABLED = true
	function noClip(Value)
		if noClipConnection then
			noClipConnection:Disconnect()
			noClipConnection = nil
		end
		if Value and not NOCLIP_ENABLED then
			pcall(function()
				for _, v in pairs(LocalPlayer.Character:GetChildren()) do
					if (v.ClassName == "Part" or v.ClassName == "MeshPart") and COLLIDE_PARTS[v.Name] then
						v.CanCollide = true
					end
				end
			end)
			return
		end
		if Value then
			local wasIdle = false
			noClipConnection = Services.RunService.Stepped:Connect(function()
				pcall(function()
					local idle = not (ZQ5 and (ZQ5.moving or ZQ5.hoverActive or ZQ5.rescuing))
					-- the maze (Floor 1): never noclip -- body always collides
					local islands = workspace:FindFirstChild("Islands")
					if
						not (ZQ5 and ZQ5.leverMode)
						and islands
						and islands:FindFirstChild("Impel Base - Floor 1")
						and not islands:FindFirstChild("Impel Base - Floor 2")
					then
						idle = true
					end
					for i, v in pairs(LocalPlayer.Character:GetChildren()) do
						if v.ClassName == "Part" or v.ClassName == "MeshPart" then
							if not idle then
								v.CanCollide = false
							elseif not wasIdle and COLLIDE_PARTS[v.Name] then
								v.CanCollide = true
							end
						end
					end
					wasIdle = idle
				end)
			end)
		end
	end

	local function DisableAllTweens()
		pcall(function()
			for _, tween in ipairs(TweensTable) do
				if tween.Tween then
					tween.Tween:Pause()
					tween.Tween:Cancel()
				end
			end
			for _, tween in pairs(savetwweenfarm) do
				tween:Pause()
				tween:Cancel()
			end
			TweensTable = {} -- Clear tables
			savetwweenfarm = {}
		end)
	end

	function GetTime(Distance, Speed)
		local Time = Distance / (Speed or 80)
		return Time
	end

	local function checkPathClear(startPos, endPos, minClearance)
		minClearance = minClearance or 10

		local params = RaycastParams.new()
		params.FilterType = Enum.RaycastFilterType.Include
		params.FilterDescendantsInstances = { workspace.Islands }

		local direction = endPos - startPos
		local distance = direction.Magnitude

		if distance < 1 then
			return true
		end

		local result = workspace:Raycast(startPos, direction, params)

		if result then
			local hitDistance = (result.Position - startPos).Magnitude
			if hitDistance < distance - minClearance then
				return false, result.Position
			end
		end

		return true
	end

	local lastIslandAdded = 0
	local islandAddDelay = 3

	workspace.Islands.ChildAdded:Connect(function(island)
		lastIslandAdded = tick()
	end)

	function canTweenNow()
		return tick() - lastIslandAdded >= islandAddDelay
	end
	local wasRemotePresent = false
	local BlockingStoppedAt = 0
	local BLOCK_TWEEN_DELAY = 2

	local currentInSpawnTween = nil
	Others.LastDashTime = 0
	Others.DashCooldown = 1
	local glideToken = nil
	local isGliding = false
	local glideStartTime = 0
	local glideCooldownEnd = 0
	local hasPreemptivelyMoved = false

	function safeDash(Bypass)
		task.wait()
		local now = tick()
		if now - Others.LastDashTime < Others.DashCooldown and not Bypass then
			return false
		end
		Others.LastDashTime = now
		local args = { 1, "dash" }
		game.ReplicatedStorage.Events.takestam:FireServer(unpack(args))
		return true
	end

	function checkAnticheatNotifications()
		local success, notifFrame = pcall(function()
			return LocalPlayer.PlayerGui.Notifications.Frame
		end)
		if not success or not notifFrame then
			return nil
		end
		local fullText = ""
		for _, descendant in ipairs(notifFrame:GetDescendants()) do
			if descendant:IsA("TextLabel") and descendant.Text and descendant.Text ~= "" then
				fullText = fullText .. " " .. descendant.Text
			end
		end
		local originalText = fullText:lower()
		local compactText = originalText:gsub("%s", "")

		local hasWarningIndicator = originalText:find("anti")
			or originalText:find("cheat")
			or originalText:find("exploit")
			or originalText:find("hack")
			or (originalText:find("warning") and originalText:find("check"))
			or originalText:find("threshold")
			or originalText:find("strike")
			or originalText:find("noclip")
			or originalText:find("overlaphead")

		if not hasWarningIndicator then
			return nil
		end

		if compactText:find("noclipcheck") or compactText:find("noclipdetect") or compactText:find("overlaphead") then
			return "noclip"
		elseif
			compactText:find("teleportcheck")
			or compactText:find("tpcheck")
			or compactText:find("tpdetect")
			or compactText:find("tpchecks")
		then
			return "tpcheck"
		elseif compactText:find("flycheck") or compactText:find("flyhack") or compactText:find("flydetect") then
			return "flycheck"
		elseif compactText:find("velocitycheck") or compactText:find("speedhack") or compactText:find("speedcheck") then
			return "velocity"
		elseif compactText:find("groundcheck") or compactText:find("groundedcheck") then
			return "grounded"
		elseif compactText:find("threshold") or compactText:find("tpchecks") then
			return "threshold"
		elseif compactText:find("strike") then
			if not Others.LastStrikeDash or (tick() - Others.LastStrikeDash) > 5 then
				Facemouse()
				task.wait(0.3)
				Others.LastStrikeDash = tick()
			end
			if PlayerHumpart and math.abs(PlayerHumpart.Position.Y - selected_Offset) < 30 then
				return "ystrike"
			end
		end
		return nil
	end

	-- DIAGNOSTICS (remove once the post-Vera teleport is understood): log every anticheat
	-- hit and every sudden jump with what the script was targeting at the time.
	do
		local function ctx()
			local isl = {}
			for _, i in ipairs(workspace.Islands:GetChildren()) do
				isl[#isl + 1] = i.Name
			end
			return string.format(
				"Npc=%s targetPosition=%s targetFloorPosition=%s step=%s islands=[%s]",
				tostring(Npc and Npc.Name),
				tostring(targetPosition),
				tostring(targetFloorPosition),
				tostring(StepCounter),
				table.concat(isl, ", ")
			)
		end
		local rawAC = checkAnticheatNotifications
		local lastACLog = 0
		function checkAnticheatNotifications()
			local r = rawAC()
			if r and tick() - lastACLog > 2 then
				lastACLog = tick()
				print("[AC] " .. tostring(r) .. " at " .. tostring(PlayerHumpart and PlayerHumpart.Position) .. " | " .. ctx())
			end
			return r
		end
		local lastPos
		Services.RunService.Heartbeat:Connect(function()
			local h = PlayerHumpart
			if not h or not h.Parent then
				lastPos = nil
				return
			end
			local cur = h.Position
			if lastPos and (cur - lastPos).Magnitude > 80 then
				print(string.format("[JUMP] %s -> %s | %s", tostring(lastPos), tostring(cur), ctx()))
			end
			lastPos = cur
		end)
	end

	-- GROUND RESCUE / PAD RISE: the game drops us at Y=2072 on Floor 1, which is the TOP of its
	-- floor slab (the script's steps assume +3 above it), and the noclip anticheat recovery used
	-- to teleport us up. Both now use the boss-farm "pad" lift (BossRotation hoverStep): an
	-- anchored CanCollide pad is made under the root and walked up at PAD_SPEED while the root
	-- CFrame is pinned to it every frame -- no velocity writes, no instant teleport.
	do
		ZQ5 = ZQ5 or {}
		local PAD_SIZE, PAD_STAND, PAD_SPEED = 24, 4, 12 -- slow rise: fast ones earn "Y+ too fast"
		local overlap = OverlapParams.new()
		overlap.FilterType = Enum.RaycastFilterType.Include
		local busy = false

		-- how far up the nearest solid island part's top is, when the root is inside it
		local function scanRise()
			local h = PlayerHumpart
			local islands = workspace:FindFirstChild("Islands")
			if not h or not islands then
				return nil
			end
			overlap.FilterDescendantsInstances = { islands }
			local bestRise
			for _, part in ipairs(workspace:GetPartBoundsInRadius(h.Position, 1.5, overlap)) do
				if part.CanCollide and math.abs(part.CFrame.UpVector.Y) > 0.99 then
					local rel = part.CFrame:PointToObjectSpace(h.Position)
					local inside = math.abs(rel.X) <= part.Size.X / 2
						and math.abs(rel.Y) <= part.Size.Y / 2
						and math.abs(rel.Z) <= part.Size.Z / 2
					local rise = part.Position.Y + part.Size.Y / 2 - h.Position.Y
					if inside and rise > 0 and rise <= 14 and (not bestRise or rise > bestRise) then
						bestRise = rise
					end
				end
			end
			return bestRise
		end

		-- blocking: ride a pad up `dy` studs, then remove it
		function PadRise(dy)
			local h = PlayerHumpart
			if busy or not h or not h.Parent then
				return
			end
			busy = true
			ZQ5.rescuing = true
			local pad = Instance.new("Part")
			pad.Name = "pad"
			pad.Size = Vector3.new(PAD_SIZE, 1, PAD_SIZE)
			pad.Anchored = true
			pad.CanCollide = true
			pad.Transparency = 1
			pad.Position = h.Position - Vector3.new(0, PAD_STAND, 0)
			pad.Parent = workspace
			local stale = h:FindFirstChild("BodyVelocity")
			if stale then
				stale:Destroy()
			end
			local goalY = pad.Position.Y + dy
			local deadline = os.clock() + dy / PAD_SPEED + 5
			pcall(function()
				while pad.Position.Y < goalY - 0.05 and os.clock() < deadline do
					local dt = Services.RunService.Heartbeat:Wait()
					h = PlayerHumpart
					if not h or not h.Parent then
						break
					end
					-- the game moved us (floor change): stop pinning
					if (h.Position - (pad.Position + Vector3.new(0, PAD_STAND, 0))).Magnitude > 40 then
						break
					end
					pad.Position = pad.Position + Vector3.new(0, math.min(PAD_SPEED * dt, goalY - pad.Position.Y), 0)
					h.CFrame = CFrame.new(pad.Position + Vector3.new(0, PAD_STAND, 0)) * (h.CFrame - h.CFrame.Position)
				end
			end)
			pad:Destroy()
			ZQ5.rescuing = false
			busy = false
		end

		-- ride a pad up dy studs, hold `hold` seconds, ride it back down, remove it
		function PadDodge(dy, hold)
			local h = PlayerHumpart
			if busy or not h or not h.Parent then
				return
			end
			busy = true
			ZQ5.rescuing = true
			local pad = Instance.new("Part")
			pad.Name = "pad"
			pad.Size = Vector3.new(PAD_SIZE, 1, PAD_SIZE)
			pad.Anchored = true
			pad.CanCollide = true
			pad.Transparency = 1
			pad.Position = h.Position - Vector3.new(0, PAD_STAND, 0)
			pad.Parent = workspace
			local function ride(goalY)
				local deadline = os.clock() + math.abs(goalY - pad.Position.Y) / PAD_SPEED + 3
				while math.abs(pad.Position.Y - goalY) > 0.05 and os.clock() < deadline do
					local dt = Services.RunService.Heartbeat:Wait()
					h = PlayerHumpart
					if not h or not h.Parent then
						return
					end
					if (h.Position - (pad.Position + Vector3.new(0, PAD_STAND, 0))).Magnitude > 40 then
						return
					end
					local d = goalY - pad.Position.Y
					pad.Position = pad.Position + Vector3.new(0, math.sign(d) * math.min(PAD_SPEED * dt, math.abs(d)), 0)
					h.CFrame = CFrame.new(pad.Position + Vector3.new(0, PAD_STAND, 0)) * (h.CFrame - h.CFrame.Position)
				end
			end
			pcall(function()
				local startY = pad.Position.Y
				ride(startY + dy)
				local t = os.clock() + (hold or 1)
				while os.clock() < t do
					Services.RunService.Heartbeat:Wait()
					h = PlayerHumpart
					if h and h.Parent then
						h.CFrame = CFrame.new(pad.Position + Vector3.new(0, PAD_STAND, 0)) * (h.CFrame - h.CFrame.Position)
					end
				end
				ride(startY)
			end)
			pad:Destroy()
			ZQ5.rescuing = false
			busy = false
		end

		Services.RunService.Heartbeat:Connect(function()
			pcall(function()
				if busy or not PlayerHumpart or not PlayerHumpart.Parent then
					return
				end
				if ZQ5.moving or ZQ5.hoverActive then
					return
				end
				local rise = scanRise()
				if rise then
					print(string.format("[RESCUE] inside floor at %s, pad-rising %.1f studs", tostring(PlayerHumpart.Position), rise + 3.2))
					task.spawn(PadRise, rise + 3.2)
				end
			end)
		end)
	end

	-- STATE LOG (every 2s): what holds us and what the script thinks it is doing
	task.spawn(function()
		while true do
			task.wait(2)
			pcall(function()
				local h = PlayerHumpart
				local hum = Character and Character:FindFirstChildOfClass("Humanoid")
				if not h or not hum then
					return
				end
				local movers = {}
				for _, v in ipairs(h:GetChildren()) do
					if v:IsA("BodyMover") then
						movers[#movers + 1] = v.Name .. "=" .. tostring(v.Velocity)
					end
				end
				print(string.format(
					"[STATE] pos=%s vel=%s hum=%s PS=%s moving=%s hover=%s movers=[%s] Cuffed=%s HandCuffed=%s Npc=%s",
					tostring(h.Position),
					tostring(h.AssemblyLinearVelocity),
					tostring(hum:GetState()),
					tostring(hum.PlatformStand),
					tostring(ZQ5 and ZQ5.moving),
					tostring(ZQ5 and ZQ5.hoverActive),
					table.concat(movers, ", "),
					tostring(Character:FindFirstChild("Cuffed") ~= nil),
					tostring(workspace:GetAttribute("HandCuffed")),
					tostring(Npc and Npc.Name)
				))
			end)
		end
	end)

	local LastInstantTP = 0
	local INSTANT_TP_COOLDOWN = 3
	local INSTANT_TP_LONG_DISTANCE = 1200
	local INSTANT_TP_CLOSE_DISTANCE = 8

	-- NO INSTANT TELEPORTS: instatp keeps its name (many call sites) but only ever tweens.
	function instatp(pos)
		if typeof(pos) == "Vector3" then
			pos = CFrame.new(pos)
		elseif typeof(pos) ~= "CFrame" then
			return
		end
		tweenWithTeleport(pos, Speed)
	end

	local yposResetClock = nil
	local stopblocking = false
	local lastBlockCall = 0
	local COOLDOWN_TIME = 0.2

	function SetBlocking(enable)
		local isBlocking = Character:FindFirstChild("Blocking")
		local currentTime = tick()

		-- Check cooldown
		if currentTime - lastBlockCall < COOLDOWN_TIME then
			return
		end

		if enable and not isBlocking and not stopblocking then
			local args = { [1] = true, [2] = "Melee", [3] = true }
			game:GetService("ReplicatedStorage"):WaitForChild("Events"):WaitForChild("Block"):InvokeServer(unpack(args))
			yPosForBlocking = Character.HumanoidRootPart.Position.Y
			yposResetClock = nil
			lastBlockCall = currentTime
		elseif not enable and isBlocking then
			local args = { [1] = false, [2] = "Melee" }
			game:GetService("ReplicatedStorage"):WaitForChild("Events"):WaitForChild("Block"):InvokeServer(unpack(args))
			BlockingStoppedAt = tick()
			yposResetClock = os.clock()
			lastBlockCall = currentTime
		end
	end
	-- Vera: no distance gates, no tween. Hand her straight to the hover engine (quest5 style) so it
	-- flies to a point above her and follows her; the m1 loop swings while it does.
	local lastVeraLog = 0
	function VeraEngage(npc)
		if not npc or not npc:FindFirstChild("HumanoidRootPart") or not PlayerHumpart or not Character then
			return false
		end
		local hum = Character:FindFirstChildOfClass("Humanoid")
		local ok
		-- no low-health hide 80 studs up any more (flight strikes): always fight
		ok = m1Attack(npc, 20, 15, Vector3.new(0, 9, 0), "Air")
		if tick() - lastVeraLog > 3 then
			lastVeraLog = tick()
			print(string.format(
				"[VERA] m1Attack=%s dist=%.0f hp=%s hoverActive=%s hoverMob=%s attack=%s",
				tostring(ok),
				(PlayerHumpart.Position - npc.HumanoidRootPart.Position).Magnitude,
				tostring(hum and math.floor(hum.Health)),
				tostring(ZQ5 and ZQ5.hoverActive),
				tostring(ZQ5 and ZQ5.hoverMob and ZQ5.hoverMob.Name),
				tostring(ZQ5 and ZQ5.attack)
			))
		end
		return ok
	end

	-- near mob with a clear straight line to it (no wall / floor between: the hover flies
	-- straight, so through a wall it would earn noclip flags) and on about our level
	function mobInReach(npc)
		local mhrp = npc and npc:FindFirstChild("HumanoidRootPart")
		local root = PlayerHumpart
		if not mhrp or not root then
			return false
		end
		if ZQ5 and ZQ5.noHoverMob == npc and tick() < (ZQ5.noHoverUntil or 0) then
			return false -- the hover got stuck on a wall going to it a moment ago
		end
		local d = mhrp.Position - root.Position
		if math.abs(d.Y) > 25 or Vector3.new(d.X, 0, d.Z).Magnitude > 45 then
			return false
		end
		local params = RaycastParams.new()
		params.FilterType = Enum.RaycastFilterType.Exclude
		params.FilterDescendantsInstances = {
			Character,
			npc,
			workspace:FindFirstChild("NPCs"),
			workspace:FindFirstChild("Effects"),
			workspace:FindFirstChild("PlayerCharacters"),
		}
		pcall(function()
			params.RespectCanCollide = true
		end)
		-- from head height to a point above the mob (where we will hover)
		local from = root.Position + Vector3.new(0, 1.5, 0)
		local to = mhrp.Position + Vector3.new(0, 5, 0)
		local hit = workspace:Raycast(from, to - from, params)
		return hit == nil
	end

	function controlTower(pos, speed)
		if not PlayerHumpart or not Character or not CanFarm then
			return
		end

		local weaponStyle = Npc and Npc:FindFirstChild("Info") and Npc.Info:FindFirstChild("Weapon")
		local finalPos = pos

		do -- (the low-health hide 80 studs above the mob is removed: flight strikes)
			if
				Npc
				and GetMagnitudeIgnoringY(Npc.HumanoidRootPart.Position) < 50
				and getdistance(Npc.HumanoidRootPart.Position) < 200
				and Npc:GetAttribute("RealName") ~= "Blugori"
				and not NutcrackerAnims
			then
				local m1Distance = 10
				-- keep the long hover range only while the mob stays in sight: once it runs behind a
				-- wall the lease runs out, the pad lands and the walker paths around instead
				local alreadyOnIt = ZQ5 and ZQ5.hoverActive and ZQ5.enemy == Npc and mobInReach(Npc)
				local isVera = string.find(Npc.Name, "Vera", 1, true) ~= nil
				if isVera then
					-- quest5 style: let the hover engine fly to and follow Vera instead of
					-- tween-teleporting next to her and only hovering inside 10 studs
					m1Distance = 45
				elseif Npc:GetAttribute("RealName") == "Kramprus" then
					m1Distance = 15
				elseif Npc:GetAttribute("RealName") == "Elo The Bunny" then
					m1Distance = 20
				elseif Npc:FindFirstChild("RaiuiSword") or Npc:GetAttribute("RealName") == "Kelvin, The Nutcracker" then
					m1Distance = 15
				end
				if alreadyOnIt then
					m1Distance = math.max(m1Distance, 45)
				elseif m1Distance < 45 and Npc:GetAttribute("RealName") ~= "Kramprus" and mobInReach(Npc) then
					-- a mob near and in plain sight: fly to it with the mob hover (pad) and stay
					-- above it, instead of walking up to it with the ground walker
					m1Distance = 45
				end

				-- never hover-engage a mob far above / below us (another level): m1Distance is
				-- horizontal only, so a mob on a ledge 90 studs overhead made the pad fly straight up
				-- into the ceiling. Walk there instead (the path takes the stairs / ramps).
				local dY = math.abs(Npc.HumanoidRootPart.Position.Y - PlayerHumpart.Position.Y)
				local dodging = ZQ5 and ZQ5.dodgeMob == Npc and tick() < (ZQ5.dodgeUntil or 0)
				if dY > 30 and not dodging and not isVera then
					m1Distance = 0
				end
				if dodging then
					m1Distance = 70 -- out on the slam dodge: stay engaged so the hover brings us back
				end

				if GetMagnitudeIgnoringY(Npc.HumanoidRootPart.Position) < m1Distance then
					if Npc:GetAttribute("RealName") == "Kramprus" then
						m1AttackSimple(Npc, m1Distance)
					else
						local offset = Vector3.new(0, 6, 3)
						local safeYoffset = 20
						local weaponStyle = Npc:FindFirstChild("Info") and Npc.Info:FindFirstChild("Weapon")
						if isVera then
							offset = Vector3.new(0, 9, 0)
							safeYoffset = 20
						elseif Npc:GetAttribute("RealName") == "Elo The Bunny" then
							offset = Vector3.new(0, 10, 3) -- hover 10 studs above Elo
							safeYoffset = 20
						elseif
							weaponStyle
							and (weaponStyle.Value == "Flower Bouquet" or weaponStyle.Value == "Candy Cane")
						then
							offset = Vector3.new(0, 7, 3)
							safeYoffset = 30
						elseif Npc:GetAttribute("RealName") == "Kelvin, The Nutcracker" then
							offset = Vector3.new(0, 10, 3)
							safeYoffset = 40
						elseif Npc:GetAttribute("RealName") == "Demon Jester" then
							offset = Vector3.new(0, 8, 3)
							safeYoffset = 40
						elseif Npc:FindFirstChild("RaiuiSword") then
							offset = Vector3.new(0, 7, 3)
						elseif Npc:GetAttribute("RealName") == "Cupid Queen" then
							offset = Vector3.new(0, 8, 0)
						elseif Npc:GetAttribute("RealName") == "Mini Bunny" then
							offset = Vector3.new(0, 7, 0)
						elseif Npc:GetAttribute("HPScaled") then
							offset = Vector3.new(0, 7, 3)
						end
						m1Attack(Npc, safeYoffset, m1Distance, offset, "Air")
						return
					end
				end
			elseif
				Npc
				and GetMagnitudeIgnoringY(Npc.HumanoidRootPart.Position) < 50
				and Npc:GetAttribute("RealName") == "Blugori"
			then
				if GetMagnitudeIgnoringY(Npc.HumanoidRootPart.Position) < 40 then
					local offset = Vector3.new(0, 0, 15)
					m1Attack(Npc, 40, 40, offset, "Air")
					return
				end
			end
		end

		if typeof(finalPos) == "CFrame" then
			finalPos = finalPos.Position
		end
		local targetPos = finalPos

		if (PlayerHumpart.Position - targetPos).Magnitude > 5 then
			if isUnderTrap(targetPos) then
				targetPos = findSafePositionFromTrap(targetPos)
			end

			local yDifference = math.abs(PlayerHumpart.Position.Y - targetPos.Y)
			if yDifference > 50 then
				Facemouse()
				task.wait(0.3)
			end

			local isSpecialOffsetNpc = Npc
				and (Npc:GetAttribute("RealName") == "Elo The Bunny" or Npc:GetAttribute("RealName") == "Kramprus")

			if isSpecialOffsetNpc then
				instatp(targetPos)
			else
				tweenWithTeleport(CFrame.new(targetPos), speed, selected_Offset)
			end
		end
	end

	function fireProximityPromptSafely(proximityPrompt)
		task.wait()
		if not proximityPrompt or not proximityPrompt:IsA("ProximityPrompt") then
			return
		end

		local parent = proximityPrompt.Parent
		if not parent then
			return
		end

		local targetPos = parent:IsA("Model") and parent:GetPivot().Position or parent.Position

		if (PlayerHumpart.Position - targetPos).Magnitude > 50 then
			return
		end

		for i, v in pairs(workspace.Effects:GetDescendants()) do
			if v:IsA("ProximityPrompt") and v ~= proximityPrompt then
				v.MaxActivationDistance = 0
			end
		end

		workspace.CurrentCamera.CFrame = CFrame.new(workspace.CurrentCamera.CFrame.Position, targetPos)

		proximityPrompt.MaxActivationDistance = 10

		wait(0.1)

		proximityPrompt:InputHoldBegin()
		wait(proximityPrompt.HoldDuration + 0.5 or 0.3)
		proximityPrompt:InputHoldEnd()
		task.wait(1)
	end

	local function getNearestHumPart(RareChests)
		local nearestHumPart = nil
		local minDistance = math.huge

		for _, HumPart in pairs(RareChests) do
			if HumPart then
				local distance = (HumPart.Position - PlayerHumpart.Position).magnitude
				if distance < minDistance then
					minDistance = distance
					nearestHumPart = HumPart
				end
			end
		end

		return nearestHumPart
	end

	local gotSpResetEssence = false
	local gotSpResetFromCommon = false

	local WeaponPriority = {
		["Dark Blade"] = 1100,
		["Hollow's Great Sword"] = 1000,
		["Kraken Blade"] = 100,
		["Vrael's Pipe"] = 90,
		["Golden Hook"] = 95,
		["Knight's Gauntlet"] = 85,
	}
	local WeaponsToFarm = {
		["Dark Blade"] = true,
		["Vrael's Pipe"] = true,
		["Hollow's Great Sword"] = true,
		["Kraken Blade"] = true,
		["Golden Hook"] = true,
		["Knight's Gauntlet"] = true,
	}
	local OwnedFarmedWeapons = {}
	-- which wanted weapon a drop / tool name is, tolerant of variants ("Kraken Blade (Gold)",
	-- "Knights Gauntlet", different case / apostrophe)
	local function normName(n)
		return string.lower((tostring(n):gsub("[^%w]", "")))
	end
	function wantedWeaponName(name)
		local n = normName(name)
		for weaponName, on in pairs(WeaponsToFarm) do
			if on and string.find(n, normName(weaponName), 1, true) then
				return weaponName
			end
		end
		return nil
	end
	function eatFunction()
		if LocalPlayer.Backpack:FindFirstChild("Spirit Essence") then
			local Tool = LocalPlayer.Backpack["Spirit Essence"]
			Character.Humanoid:EquipTool(Tool)
			Tool:Activate()
			task.wait(1)
			if LocalPlayer.PlayerGui:FindFirstChild("ConfirmationPrompt") then
				local remoteEvent = LocalPlayer.PlayerGui.ConfirmationPrompt:WaitForChild("RemoteEvent")
				if remoteEvent and remoteEvent:IsA("RemoteEvent") then
					remoteEvent:FireServer(true)
				end
				spirit_essence = true
			end
		elseif Character:FindFirstChild("Spirit Essence") then
			local Tool = Character["Spirit Essence"]
			Tool:Activate()
			task.wait(1)
			if LocalPlayer.PlayerGui:FindFirstChild("ConfirmationPrompt") then
				local remoteEvent = LocalPlayer.PlayerGui.ConfirmationPrompt:WaitForChild("RemoteEvent")
				if remoteEvent and remoteEvent:IsA("RemoteEvent") then
					remoteEvent:FireServer(true)
				end
				spirit_essence = true
			end
		end
	end

	function eatSpResetEssence()
		if LocalPlayer.Backpack:FindFirstChild("SP Reset Essence") then
			local Tool = LocalPlayer.Backpack["SP Reset Essence"]
			Character.Humanoid:EquipTool(Tool)
			Tool:Activate()
			task.wait(1)
			if LocalPlayer.PlayerGui:FindFirstChild("ConfirmationPrompt") then
				local remoteEvent = LocalPlayer.PlayerGui.ConfirmationPrompt:WaitForChild("RemoteEvent")
				if remoteEvent and remoteEvent:IsA("RemoteEvent") then
					remoteEvent:FireServer(true)
				end
				gotSpResetEssence = true
			end
		elseif Character:FindFirstChild("SP Reset Essence") then
			local Tool = Character["SP Reset Essence"]
			Tool:Activate()
			task.wait(1)
			if LocalPlayer.PlayerGui:FindFirstChild("ConfirmationPrompt") then
				local remoteEvent = LocalPlayer.PlayerGui.ConfirmationPrompt:WaitForChild("RemoteEvent")
				if remoteEvent and remoteEvent:IsA("RemoteEvent") then
					remoteEvent:FireServer(true)
				end
				gotSpResetEssence = true
			end
		end
	end

	function openCommonChests()
		-- SP Reset is MANDATORY - keep trying until we get one
		local maxAttempts = 100 -- Increased from 50
		local attempts = 0

		local ChestInfo = {
			["rbxassetid://10779253534"] = { ["Name"] = "Common Chest" },
		}

		while attempts < maxAttempts do
			attempts = attempts + 1
			if Character:FindFirstChild("Cuffed") then
				return false -- handcuffed: the key step comes first
			end

			Backpack = game.Players.LocalPlayer.Backpack

			local keepOne = {}
			local keepItems = {
				["Spirit Essence"] = true,
				["SP Reset Essence"] = true,
				["Dark Blade"] = true,
				["Vrael's Pipe"] = true,
				["Kraken Blade"] = true,
				["Hollow's Great Sword"] = true,
				["Golden Hook"] = true,
				["Knight's Gauntlet"] = true,
			}

			for _, v in pairs(workspace.Effects:GetChildren()) do
				-- never delete the handcuff Key: cuffs that arrive late found it gone -> stuck cuffed
				if v.Name == "Key" or wantedWeaponName(v.Name) then
					continue -- the handcuff key and wanted weapon drops are never deleted
				end
				if not keepItems[v.Name] and not v:FindFirstChild("Lock") then
					v:Destroy()
				elseif keepItems[v.Name] then
					if keepOne[v.Name] then
						v:Destroy()
					else
						keepOne[v.Name] = true
					end
				end
			end

			-- Check if we already have SP Reset
			if Backpack:FindFirstChild("SP Reset Essence") or Character:FindFirstChild("SP Reset Essence") then
				eatSpResetEssence()
				gotSpResetFromCommon = true
				return true
			end

			-- Check if SP Reset dropped on ground
			-- Check if SP Reset dropped on ground
			local spResetDrop = workspace.Effects:FindFirstChild("SP Reset Essence")
			if spResetDrop then
				local part = nil
				for _, v in pairs(spResetDrop:GetDescendants()) do
					if v:IsA("BasePart") then
						part = v
						break
					end
				end
				if part then
					local maxAttempts = 15
					for attempt = 1, maxAttempts do
						if
							Backpack:FindFirstChild("SP Reset Essence") or Character:FindFirstChild("SP Reset Essence")
						then
							break
						end

						spResetDrop = workspace.Effects:FindFirstChild("SP Reset Essence")
						if not spResetDrop then
							break
						end

						part = nil
						for _, v in pairs(spResetDrop:GetDescendants()) do
							if v:IsA("BasePart") then
								part = v
								break
							end
						end
						if not part then
							break
						end

						local targetPos = part.Position
						if (targetPos - PlayerHumpart.Position).Magnitude > 5 then
							tweenWithTeleport(CFrame.new(targetPos), Speed, selected_Offset)
							task.wait(0.3)
						end

						for _, v in pairs(spResetDrop:GetDescendants()) do
							if v:IsA("ProximityPrompt") then
								task.wait(0.1)
								fireProximityPromptSafely(v)
								break
							end
						end

						task.wait(0.3)
					end
				end
			end

			if Backpack:FindFirstChild("SP Reset Essence") or Character:FindFirstChild("SP Reset Essence") then
				eatSpResetEssence()
				gotSpResetFromCommon = true
				return true
			end

			-- Find and open common chests
			local CommonChests = {}
			for _, Value in next, workspace.Effects:GetChildren() do
				local meshPart = Value:FindFirstChildOfClass("MeshPart")
				if meshPart and Value:FindFirstChild("Lock") then
					local ChestData = ChestInfo[meshPart.MeshId]
					if ChestData and ChestData.Name == "Common Chest" then
						table.insert(CommonChests, meshPart)
					end
				end
			end

			if #CommonChests == 0 then
				local hasAllocatedStats = statsFolder.Stats.Defense.Value > 0
					or statsFolder.Stats.Strength.Value > 0
					or statsFolder.Stats.SwordMastery.Value > 0

				if hasAllocatedStats and not gotSpResetEssence and not gotSpResetFromCommon then
					game:GetService("TeleportService"):Teleport(6360478118, game:GetService("Players").LocalPlayer)
				end
				break
			end

			local HumPart = getNearestHumPart(CommonChests)
			if HumPart then
				-- Move to chest
				if (HumPart.Position - PlayerHumpart.Position).Magnitude > 5 then
					targetPosition = HumPart.Position + Vector3.new(0, 3, 0)
					tweenWithTeleport(CFrame.new(targetPosition), Speed, selected_Offset)
					task.wait(0.5)
				end

				-- Open chest with improved interaction
				if (HumPart.Position - PlayerHumpart.Position).Magnitude <= 15 then
					local chestOpened = false
					for openAttempt = 1, 3 do
						for _, v in pairs(HumPart.Parent:GetDescendants()) do
							if v:IsA("ProximityPrompt") and v.Enabled == true then
								task.wait(0.2)
								pcall(function()
									fireProximityPromptSafely(v)
								end)

								chestOpened = true
								break
							end
						end
						if chestOpened then
							break
						end
						task.wait(0.2)
					end
				end
			end

			task.wait(0.2)
		end

		return gotSpResetFromCommon or gotSpResetEssence
	end

	function checkOwnedWeapons()
		for weaponName, _ in pairs(WeaponsToFarm) do
			OwnedFarmedWeapons[weaponName] = false
		end

		for weaponName, _ in pairs(WeaponsToFarm) do
			for _, tool in pairs(LocalPlayer.Backpack:GetChildren()) do
				if tool:IsA("Tool") then
					if wantedWeaponName(tool.Name) == weaponName then
						OwnedFarmedWeapons[weaponName] = true
						break
					end
				end
			end

			if not OwnedFarmedWeapons[weaponName] and Character then
				for _, tool in pairs(Character:GetChildren()) do
					if tool:IsA("Tool") then
						if wantedWeaponName(tool.Name) == weaponName then
							OwnedFarmedWeapons[weaponName] = true
							break
						end
					end
				end
			end
		end
	end
	function needsWeaponFromRareChest()
		checkOwnedWeapons()
		for weaponName, shouldFarm in pairs(WeaponsToFarm) do
			if shouldFarm and not OwnedFarmedWeapons[weaponName] then
				return true
			end
		end
		return false
	end

	function pickupWeaponDrops()
		for weaponName, shouldFarm in pairs(WeaponsToFarm) do
			if shouldFarm and not OwnedFarmedWeapons[weaponName] then
				-- For Kraken Blade, search all effects for any matching name
				local weaponDrop = nil
				for _, child in pairs(workspace.Effects:GetChildren()) do
					if wantedWeaponName(child.Name) == weaponName then
						weaponDrop = child
						break
					end
				end

				if weaponDrop then
					local part = nil
					for _, v in pairs(weaponDrop:GetDescendants()) do
						if v:IsA("BasePart") then
							part = v
							break
						end
					end
					if part then
						print("→ Fast pickup: " .. weaponDrop.Name)
						local targetPos = part.Position
						local distance = (targetPos - PlayerHumpart.Position).Magnitude

						if distance > 5 then
							if distance < 30 then
								instatp(CFrame.new(targetPos))
							else
								tweenWithTeleport(CFrame.new(targetPos), Speed, selected_Offset)
							end
						end

						task.wait(0.05)

						for _, v in pairs(weaponDrop:GetDescendants()) do
							if v:IsA("ProximityPrompt") then
								task.wait(0.02)
								fireProximityPromptSafely(v)
								break
							end
						end

						task.wait(0.1)
						checkOwnedWeapons()
					end
				end
			end
		end
	end

	function hakiFarm()
		local ChestInfo = {
			["rbxassetid://10811929054"] = {
				["Name"] = "Mythical Chest",
				["Color"] = Color3.fromRGB(112, 10, 255),
			},
			["rbxassetid://10798559852"] = {
				["Name"] = "Legendary Chest",
				["Color"] = Color3.fromRGB(202, 12, 37),
			},
			["rbxassetid://10788852296"] = {
				["Name"] = "Rare Chest",
				["Color"] = Color3.fromRGB(44, 125, 202),
			},
			["rbxassetid://10858352843"] = {
				["Name"] = "Uncommon Chest",
				["Color"] = Color3.fromRGB(202, 174, 32),
			},
			["rbxassetid://10779253534"] = {
				["Name"] = "Common Chest",
				["Color"] = Color3.fromRGB(45, 152, 84),
			},
		}

		-- Helper function to count rare chests
		local function countRareChests()
			local count = 0
			for _, Value in next, workspace.Effects:GetChildren() do
				local meshPart = Value:FindFirstChildOfClass("MeshPart")
				if meshPart and Value:FindFirstChild("Lock") then
					local ChestData = ChestInfo[meshPart.MeshId]
					if ChestData and ChestData.Name == "Rare Chest" then
						count = count + 1
					end
				end
			end
			return count
		end

		-- Helper function to check if we have any target weapon
		local function hasTargetWeapon()
			checkOwnedWeapons()
			return OwnedFarmedWeapons["Kraken Blade"]
				or OwnedFarmedWeapons["Vrael's Pipe"]
				or OwnedFarmedWeapons["Hollow's Great Sword"]
				or OwnedFarmedWeapons["Dark Blade"]
				or OwnedFarmedWeapons["Golden Hook"]
				or OwnedFarmedWeapons["Knight's Gauntlet"]
		end

		-- STEP 1: SP RESET ESSENCE FIRST (PRIORITY)
		if not gotSpResetEssence and not gotSpResetFromCommon then
			openCommonChests()
		end

		if Backpack:FindFirstChild("SP Reset Essence") or Character:FindFirstChild("SP Reset Essence") then
			eatSpResetEssence()
		end

		-- STEP 2: Check if we already have a weapon - if so, just get Spirit Essence and return
		pickupWeaponDrops()
		if hasTargetWeapon() then
			print("✓ Already have weapon, just need Spirit Essence")
			-- Just get spirit essence if needed
			local hashaki = statsFolder.Stats.BusoMastery.Value ~= 0
			if hashaki then
				return -- Already have haki and weapon, done
			end
			-- Continue to get spirit essence only
		end

		-- STEP 3: SPIRIT ESSENCE AND WEAPONS (RARE CHESTS)
		local RareChests = {}

		spiritEssence = not spirit_essence and workspace.Effects:FindFirstChild("Spirit Essence")

		-- Main chest opening loop - continues until we have BOTH spirit essence AND a weapon (or no chests left)
		repeat
			task.wait(0.1)

			if Character:FindFirstChild("Cuffed") then
				return -- handcuffed: the key step comes first
			end

			if Backpack:FindFirstChild("SP Reset Essence") or Character:FindFirstChild("SP Reset Essence") then
				eatSpResetEssence()
			end

			pickupWeaponDrops()

			-- Check current status
			local hashaki = statsFolder.Stats.BusoMastery.Value ~= 0
			local hasWeapon = hasTargetWeapon()
			spiritEssence = not spirit_essence and workspace.Effects:FindFirstChild("Spirit Essence")

			-- If we have both haki and weapon, we're done
			if hashaki and hasWeapon then
				print("✓ Have both haki and weapon - done with hakiFarm")
				return
			end

			openingChests = true
			RareChests = {}

			-- Build list of rare chests
			for _, Value in next, workspace.Effects:GetChildren() do
				local meshPart = Value:FindFirstChildOfClass("MeshPart")
				if meshPart then
					if Value:FindFirstChild("Lock") then
						local ChestData = ChestInfo[meshPart.MeshId]
						if ChestData and ChestData.Name == "Rare Chest" then
							-- a skipped (unreachable) rare chest is left alone: not targeted, not deleted
							if not (Others.SkipChests and Others.SkipChests[meshPart]) then
								table.insert(RareChests, meshPart)
							end
						elseif ChestData and ChestData.Name ~= "Common Chest" then
							Value:Destroy()
						end
					end
				end
			end

			-- If spirit essence is on ground, pick it up
			if spiritEssence then
				local part = nil
				for _, v in pairs(spiritEssence:GetDescendants()) do
					if v:IsA("BasePart") then
						part = v
						break
					end
				end
				if part then
					local targetPos = part.Position
					if (targetPos - PlayerHumpart.Position).Magnitude > 5 then
						tweenWithTeleport(CFrame.new(targetPos), Speed, selected_Offset)
					end
					task.wait(0.2)
					for _, v in pairs(spiritEssence:GetDescendants()) do
						if v:IsA("ProximityPrompt") then
							task.wait(0.05)
							fireProximityPromptSafely(v)
							break
						end
					end
				end
			end

			-- Try to eat spirit essence if we have it
			if Character:FindFirstChild("Spirit Essence") or Backpack:FindFirstChild("Spirit Essence") then
				eatFunction()
				task.wait(0.2)
			end

			if #RareChests == 0 and workspace.Islands:FindFirstChild("Impel Base - Floor 1") then
				print("[CHEST] no rare chests left to open")
				local currentHasWeapon = hasTargetWeapon()
				local currentHasHaki = statsFolder.Stats.BusoMastery.Value ~= 0

				-- no wanted weapon from the reachable rare chests (but haki): don't hop servers,
				-- do this whole run with melee (Strength gets the points, see the stat loop) and
				-- don't come back for chests
				if not currentHasWeapon and currentHasHaki then
					print("[CHEST] no wanted weapon from the reachable chests - melee for the rest of this run")
					Others.MeleeRun = true
					return
				end

				if not currentHasWeapon then
					task.wait(2)
					game:GetService("TeleportService"):Teleport(6360478118, game:GetService("Players").LocalPlayer)
					return
				elseif not currentHasHaki then
					task.wait(2)
					game:GetService("TeleportService"):Teleport(6360478118, game:GetService("Players").LocalPlayer)
					return
				else
					return
				end
			end

			local HumPart = nil
			if Others.LockedChest and Others.LockedChest.Parent and Others.LockedChest:FindFirstChild("Lock", true) then
				HumPart = Others.LockedChest
			else
				Others.LockedChest = nil
				HumPart = getNearestHumPart(RareChests)
				if HumPart then
					Others.LockedChest = HumPart
				end
			end
			-- CHEST PHASE: a chest we cannot reach (no path) or open within 25s used to stay in the
			-- list forever, so "no chests left, no weapon -> universe hub" never fired. Skip it.
			Others.SkipChests = Others.SkipChests or setmetatable({}, { __mode = "k" })
			Others.ChestSince = Others.ChestSince or setmetatable({}, { __mode = "k" })
			if HumPart then
				Others.ChestSince[HumPart] = Others.ChestSince[HumPart] or tick()
				if tick() - Others.ChestSince[HumPart] > 25 then
					print("[CHEST] could not open a chest in 25s, skipping it")
					Others.SkipChests[HumPart] = true
					Others.LockedChest = nil
					HumPart = nil
				end
			end
			if HumPart then
				eatFunction()
				task.wait(0.1)

				workspace.CurrentCamera.CFrame = CFrame.new(workspace.CurrentCamera.CFrame.Position, HumPart.Position)

				if (HumPart.Position - PlayerHumpart.Position).Magnitude > 5 then
					targetPosition = HumPart.Position + Vector3.new(0, 3, 0)
					task.wait(0.1)
					ZQ5.lastWalkResult = nil
					tweenWithTeleport(CFrame.new(targetPosition), Speed, selected_Offset)
					CanTween = true
					if ZQ5.lastWalkResult == "nopath" then
						print("[CHEST] no path to a chest, skipping it")
						Others.SkipChests[HumPart] = true
						Others.LockedChest = nil
					end
				end

				if (HumPart.Position - PlayerHumpart.Position).Magnitude <= 10 then
					local ProximityFound = true
					repeat
						ProximityFound = false
						for _, v in pairs(HumPart.Parent:GetDescendants()) do
							if v:IsA("ProximityPrompt") and v.Enabled == true then
								task.wait(0.05)
								fireProximityPromptSafely(v)
								ProximityFound = true
								break
							end
						end
						if not ProximityFound then
							pcall(function()
								HumPart.Parent:Destroy()
							end)
						end
						task.wait(0.1)
						pickupWeaponDrops()
					until not HumPart
						or not HumPart.Parent
						or not ProximityFound
						or (HumPart.Position - PlayerHumpart.Position).Magnitude > 10
				end
			end

			if
				Others.LockedChest
				and (not Others.LockedChest.Parent or not Others.LockedChest:IsDescendantOf(workspace))
			then
				Others.LockedChest = nil
			end
			local keepOne = {}
			local keepItems = {
				["Spirit Essence"] = true,
				["SP Reset Essence"] = true,
				["Dark Blade"] = true,
				["Vrael's Pipe"] = true,
				["Kraken Blade"] = true,
				["Hollow's Great Sword"] = true,
				["Golden Hook"] = true,
				["Knight's Gauntlet"] = true,
			}

			for _, v in pairs(workspace.Effects:GetChildren()) do
				-- never delete the handcuff Key: cuffs that arrive late found it gone -> stuck cuffed
				if v.Name == "Key" or wantedWeaponName(v.Name) then
					continue -- the handcuff key and wanted weapon drops are never deleted
				end
				if not keepItems[v.Name] and not v:FindFirstChild("Lock") then
					v:Destroy()
				elseif keepItems[v.Name] then
					if keepOne[v.Name] then
						v:Destroy()
					else
						keepOne[v.Name] = true
					end
				end
			end

		until false -- Loop continues until we return from inside
	end
	local part = Instance.new("Part")
	part.Name = "RedZone"
	part.Anchored = true
	part.CanCollide = false
	part.Size = Vector3.new(1130, 400, 1405)
	part.Position = Vector3.new(2952.53003, 2375.44531, -14727.2305)
	part.Color = Color3.fromRGB(255, 0, 0)
	part.Transparency = 1
	part.Parent = workspace

	function GetImpelNpc()
		task.wait()
		if #workspace.NPCs:GetChildren() == 0 then
			return
		end
		if workspace.Islands:FindFirstChild("Impel Base - Finished") then
			return
		end

		local redZone = workspace:FindFirstChild("RedZone")
		if redZone and workspace.Islands:FindFirstChild("Impel Base - Floor 1") then
			local halfSize = redZone.Size / 2
			for _, npc in pairs(workspace.NPCs:GetChildren()) do
				if npc:FindFirstChild("HumanoidRootPart") then
					local npcPos = npc.HumanoidRootPart.Position
					local redZonePos = redZone.Position
					local inX = math.abs(npcPos.X - redZonePos.X) <= halfSize.X
					local inZ = math.abs(npcPos.Z - redZonePos.Z) <= halfSize.Z
					if inX and inZ then
						npc:Destroy()
					end
				end
			end
		end

		local function hasDevilFruit(npc)
			return npc:FindFirstChild("Info") and npc.Info:FindFirstChild("DevilFruit")
		end

		local NearestNpc, Distance = nil, 400
		local PlayerPosition = PlayerHumpart.Position

		if
			workspace.NPCs:FindFirstChild("Warden of Impel Down, Vera")
			and workspace.Islands:FindFirstChild("Impel Base - Floor 5")
		then
			NearestNpc = workspace.NPCs["Warden of Impel Down, Vera"]
			if not NearestNpc:GetAttribute("RealName") then
				NearestNpc:SetAttribute("RealName", NearestNpc.Name)
			end
			return NearestNpc
		end

		if workspace.NPCs:FindFirstChild("Kelvin, The Nutcracker") then
			NearestNpc = workspace.NPCs["Kelvin, The Nutcracker"]
			if not NearestNpc:GetAttribute("RealName") then
				NearestNpc:SetAttribute("RealName", NearestNpc.Name)
			end
			return NearestNpc
		end

		local hpScaledNpc = nil
		local hpScaledDistance = Distance

		for _, TargetNpc in pairs(workspace.NPCs:GetChildren()) do
			local HumPart = TargetNpc:FindFirstChild("HumanoidRootPart")
			if
				HumPart
				and TargetNpc.Name ~= "Scorpion"
				and TargetNpc.Name ~= "Basilisk"
				and TargetNpc:GetAttribute("HPScaled")
			then
				local NpcPosition = HumPart.Position
				local CurrentDistance = (NpcPosition - PlayerPosition).magnitude
				if CurrentDistance < hpScaledDistance then
					hpScaledNpc = TargetNpc
					hpScaledDistance = CurrentDistance
				end
			end
		end

		if hpScaledNpc then
			local currentTest = workspace.NPCs:FindFirstChild("Test")
			if currentTest and currentTest ~= hpScaledNpc then
				if not currentTest:GetAttribute("RealName") then
					currentTest:SetAttribute("RealName", currentTest.Name)
				end
				currentTest.Name = currentTest:GetAttribute("RealName") or "FarNpc"
			end

			NearestNpc = hpScaledNpc
			if not NearestNpc:GetAttribute("RealName") then
				NearestNpc:SetAttribute("RealName", NearestNpc.Name)
			end
			NearestNpc.Name = "Test"
			return NearestNpc
		end

		local devilFruitNpc = nil
		local devilFruitDistance = Distance

		for _, TargetNpc in pairs(workspace.NPCs:GetChildren()) do
			local HumPart = TargetNpc:FindFirstChild("HumanoidRootPart")
			if
				HumPart
				and TargetNpc.Name ~= "Scorpion"
				and TargetNpc.Name ~= "Basilisk"
				and hasDevilFruit(TargetNpc)
			then
				local NpcPosition = HumPart.Position
				local CurrentDistance = (NpcPosition - PlayerPosition).magnitude
				if CurrentDistance < devilFruitDistance then
					devilFruitNpc = TargetNpc
					devilFruitDistance = CurrentDistance
				end
			end
		end

		if devilFruitNpc then
			local currentTest = workspace.NPCs:FindFirstChild("Test")
			if currentTest and currentTest ~= devilFruitNpc then
				if not currentTest:GetAttribute("RealName") then
					currentTest:SetAttribute("RealName", currentTest.Name)
				end
				currentTest.Name = currentTest:GetAttribute("RealName") or "FarNpc"
			end

			NearestNpc = devilFruitNpc
			if not NearestNpc:GetAttribute("RealName") then
				NearestNpc:SetAttribute("RealName", NearestNpc.Name)
			end
			NearestNpc.Name = "Test"
			return NearestNpc
		end

		if workspace.NPCs:FindFirstChild("Test") then
			local TestNpc = workspace.NPCs.Test
			if TestNpc:FindFirstChild("HumanoidRootPart") then
				local TestNpcPosition =
					Vector3.new(TestNpc.HumanoidRootPart.Position.X, 0, TestNpc.HumanoidRootPart.Position.Z)
				local PlayerFlatPosition = Vector3.new(PlayerPosition.X, 0, PlayerPosition.Z)
				local DistanceToTest = (TestNpcPosition - PlayerFlatPosition).Magnitude
				if DistanceToTest <= 600 or #workspace.NPCs:GetChildren() <= 1 then
					NearestNpc = TestNpc
					return NearestNpc
				elseif DistanceToTest > 600 then
					TestNpc.Name = "FarNpc"
				end
			end
		end

		local logiaNpc = nil
		local logiaDistance = Distance

		for _, TargetNpc in pairs(workspace.NPCs:GetChildren()) do
			local HumPart = TargetNpc:FindFirstChild("HumanoidRootPart")
			local hasLogiaFolder = TargetNpc:FindFirstChild("Logia") or TargetNpc:FindFirstChild("logia")
			if HumPart and TargetNpc.Name ~= "Scorpion" and TargetNpc.Name ~= "Basilisk" and hasLogiaFolder then
				local _, _, specialAction = willCrossHut(TargetNpc)
				local isStuckInBuilding = (specialAction == "timeout_escape")

				if not isStuckInBuilding then
					local NpcPosition = HumPart.Position
					local CurrentDistance = (NpcPosition - PlayerPosition).magnitude
					if CurrentDistance < logiaDistance then
						logiaNpc = TargetNpc
						logiaDistance = CurrentDistance
					end
				end
			end
		end

		if logiaNpc then
			NearestNpc = logiaNpc
			Distance = logiaDistance
		else
			for _, TargetNpc in pairs(workspace.NPCs:GetChildren()) do
				local HumPart = TargetNpc:FindFirstChild("HumanoidRootPart")
				if HumPart and TargetNpc.Name ~= "Scorpion" and TargetNpc.Name ~= "Basilisk" then
					local NpcPosition = HumPart.Position
					local CurrentDistance = (NpcPosition - PlayerPosition).magnitude
					if CurrentDistance < Distance then
						NearestNpc = TargetNpc
						Distance = CurrentDistance
					end
				end
			end
		end

		if
			NearestNpc
			and NearestNpc.Name ~= "Test"
			and NearestNpc.Name ~= "Warden of Impel Down, Vera"
			and NearestNpc.Name ~= "Kelvin, The Nutcracker"
		then
			if not NearestNpc:GetAttribute("RealName") then
				NearestNpc:SetAttribute("RealName", NearestNpc.Name)
			end
			NearestNpc.Name = "Test"
		end

		if NearestNpc and not NearestNpc:FindFirstChild("HumanoidRootPart") then
			NearestNpc = nil
		end
		print("NPC: ", NearestNpc)

		return NearestNpc
	end
	function HasSledgehammerNPC()
		for _, npc in pairs(workspace.NPCs:GetChildren()) do
			if npc:FindFirstChild("Elo's Sledgehammer") then
				return true
			end
		end
		return false
	end
	function detectPart()
		local offset = 10

		if not Npc or not Npc:FindFirstChild("HumanoidRootPart") then
			return PlayerHumpart.Position
		end

		if
			Character
			and Character:FindFirstChild("HumanoidRootPart")
			and Character.HumanoidRootPart.Position.Y <= -10000
			and targetFloorPosition
		then
			return targetFloorPosition + Vector3.new(0, 20, 0)
		end

		local animationStyle = Npc and Npc:FindFirstChild("Info") and Npc.Info:FindFirstChild("AnimationStyle")
		local weaponStyle = Npc and Npc:FindFirstChild("Info") and Npc.Info:FindFirstChild("Weapon")

		local Baal = animationStyle
			and (animationStyle.Value == "PumpkinBoss" or animationStyle.Value == "Jester")
			and Npc

		if RaiuiAnims then
			return Vector3.new(Npc.HumanoidRootPart.Position.X, selected_Offset - 400, Npc.HumanoidRootPart.Position.Z)
		end

		if NutcrackerAnims then
			return Npc.HumanoidRootPart.Position + Vector3.new(0, 60, 0)
		end

		if
			Npc.Name == "Warden of Impel Down, Vera"
			or Npc:GetAttribute("RealName") == "Elo The Bunny"
			or Npc.Name == "Kelvin, The Nutcracker"
			or Npc:GetAttribute("RealName") == "Kramprus"
			or (animationStyle and animationStyle.Value == "Blugori")
			or (weaponStyle and (weaponStyle.Value == "Flower Bouquet" or weaponStyle.Value == "Candy Cane"))
			or Baal
		then
			if
				targetFloorPosition
				and (
					Baal
					or (
						weaponStyle
						and (
							weaponStyle.Value == "Flower Bouquet"
							or weaponStyle.Value == "Candy Cane"
							or weaponStyle.Value == "Festival Shield"
						)
					)
				)
			then
				if
					weaponStyle
					and (
						weaponStyle.Value == "Flower Bouquet"
						or weaponStyle.Value == "Candy Cane"
						or weaponStyle.Value == "Festival Shield"
					)
				then
					return Npc.HumanoidRootPart.Position + Vector3.new(0, offset, 0)
				end

				return targetFloorPosition + Vector3.new(0, 15, 0)
			elseif
				not targetFloorPosition
				and (
					Baal
					or (weaponStyle and (weaponStyle.Value == "Flower Bouquet" or weaponStyle.Value == "Candy Cane"))
				)
			then
				return Npc.HumanoidRootPart.Position + Vector3.new(0, offset, 0)
			elseif targetFloorPosition and Npc.Name == "Warden of Impel Down, Vera" then
				return Npc.HumanoidRootPart.Position + Vector3.new(0, offset, 0)
			elseif animationStyle and animationStyle.Value == "Blugori" then
				Npc:SetAttribute("Blugori", true)
				return Npc.HumanoidRootPart.Position + Vector3.new(0, 0, 20)
			elseif Npc:GetAttribute("RealName") == "Kramprus" then
				return Npc.HumanoidRootPart.Position + Vector3.new(0, 0, 10)
			elseif Npc:FindFirstChild("RaiuiSword") then
				return Npc.HumanoidRootPart.Position + Vector3.new(0, 0, 20)
			elseif Npc:GetAttribute("RealName") == "Elo The Bunny" then
				return Npc.HumanoidRootPart.Position - (Npc.HumanoidRootPart.CFrame.LookVector * 10)
			elseif targetFloorPosition then
				return targetFloorPosition + Vector3.new(0, 45, 0)
			else
				return Npc.HumanoidRootPart.Position + Vector3.new(0, offset, 0)
			end
		end

		return Npc.HumanoidRootPart.Position + Vector3.new(0, offset, 0)
	end

	spawn(function()
		while task.wait() do
			if (workspace:GetAttribute("serverAge") or 0) >= 2700 then
				game:GetService("TeleportService"):Teleport(6360478118, game:GetService("Players").LocalPlayer)
				break
			end
			if PlayerHumpart then
				local isFightingVera = Npc and string.find(Npc.Name, "Vera", 1, true) ~= nil
				local hovering = ZQ5 and (ZQ5.hoverActive or ZQ5.rescuing)
				local agibleForVelocity = hovering
					or (
						PlayerHumpart
						and ((workspace:GetAttribute("HandCuffed") and not Character:FindFirstChild("Cuffed")) or isFightingVera)
						and PlayerHumpart:FindFirstChild("BodyVelocity")
					)

				if not agibleForVelocity then
					PlayerHumpart.Velocity = Vector3.new(0, 0, 0)
				end
			end
		end
	end)
	spawn(function()
		while task.wait() do
			local Checker = false
			pcall(function()
				if
					Npc
					and (
						Npc:FindFirstChild("Logia")
						or Npc:FindFirstChild("logia")
						or Npc:FindFirstChild("Info") and Npc.Info:FindFirstChild("DevilFruit")
					)
				then
					if not Npc:GetAttribute("HPScaled") then
						Npc:SetAttribute("HPScaled", true)
					end
				end

				if Npc and Npc:FindFirstChild("RaiuiSword") then
					local hasUnderscore = workspace.Effects:FindFirstChild("_")

					local hasRaiuPart = false
					pcall(function()
						for _, part in pairs(workspace.Effects:GetDescendants()) do
							if part:IsA("BasePart") and part.Name:match("^RaiuMove2") then
								hasRaiuPart = true
								break
							end
						end
					end)

					if (hasUnderscore or hasRaiuPart) and (tick() - RaiuiAnimsEndTime > RAIUI_RECHECK_COOLDOWN) then
						if not RaiuiAnims then
							RaiuiAnimsStartTime = tick()
						end
						RaiuiAnims = true
						RAIUIBOSSSPAWNED = true
						Checker = true
						local oldYpos = PlayerHumpart.Position.Y
						task.wait(0.5)
					elseif not hasUnderscore and not hasRaiuPart then
						if RaiuiAnims then
							RaiuiAnimsEndTime = tick()
						end
						RaiuiAnims = false
						RaiuiAnimsStartTime = 0
					end

					if RaiuiAnims and (tick() - RaiuiAnimsStartTime) > RAIUI_ANIM_TIMEOUT then
						RaiuiAnimsEndTime = tick()
						RaiuiAnims = false
						RaiuiAnimsStartTime = 0
					end
				else
					RaiuiAnims = false
					RaiuiAnimsStartTime = 0
				end

				if
					Npc
					and (Npc.Name == "Kelvin, The Nutcracker" or Npc:GetAttribute("RealName") == "Elo The Bunny" or Npc:GetAttribute(
						"RealName"
					) == "Blugori")
					and Npc:FindFirstChild("Humanoid")
				then
					local playingAnimationTracks = Npc.Humanoid:GetPlayingAnimationTracks()
					local animationIdToCheck = 8201580596
					local animationIdToCheck2 = 15246831598
					local animationIdToCheck3 = 6647575254
					for _, track in ipairs(playingAnimationTracks) do
						-- log each Elo animation once, so a changed slam id shows up in the console
						if Npc:GetAttribute("RealName") == "Elo The Bunny" then
							EloSeenAnims = EloSeenAnims or {}
							local aid = track.Animation.AnimationId
							if not EloSeenAnims[aid] then
								EloSeenAnims[aid] = true
								print("[ELO] anim " .. aid .. " (" .. tostring(track.Name) .. ")")
							end
						end
						if track.Animation.AnimationId == "rbxassetid://" .. animationIdToCheck then
							NutcrackerAnims = true
							Checker = true
						elseif track.Animation.AnimationId == "rbxassetid://" .. animationIdToCheck2 then
							BlugoriAnims = false
							Checker = true
						elseif track.Animation.AnimationId == "rbxassetid://" .. animationIdToCheck3 then
							-- Elo's slam: the hover slides far out to the side (see ELO_DODGE_*)
							Checker = true
							if ZQ5 then
								if tick() > (ZQ5.dodgeUntil or 0) then
									ZQ5.dodgeStart = tick()
									ZQ5.dodgeDir = nil
									print("[ELO] slam, dodging to the side")
								end
								ZQ5.dodgeMob = Npc
								ZQ5.dodgeUntil = math.max(tick() + 0.5, ZQ5.dodgeStart + 2.2)
							end
						end
					end
					if not Checker then
						NutcrackerAnims = false
						BlugoriAnims = false
						EloAnims = false
					end
				else
					NutcrackerAnims = false
					BlugoriAnims = false
					EloAnims = false
				end

				if Character and Character.Humanoid then
					Character.Humanoid.AutoRotate = false
				end
			end)
		end
	end)

	local MazeNpcsFound = false
	local MazeNpcsKilled = false
	local MazeNpcKilledTime = 0

	function MazeNpcKill()
		success, Npc = pcall(GetImpelNpc)
		if not success then
			Npc = nil
		end

		local function CountMazeNpcs()
			local count = 0
			local mazeCenter = Vector3.new(2674.46435546875, 2075.4453125, -15478.548828125)

			for _, npc in pairs(workspace.NPCs:GetChildren()) do
				if npc:FindFirstChild("HumanoidRootPart") and npc:FindFirstChild("Humanoid") then
					local npcPos = npc.HumanoidRootPart.Position
					local distance = (Vector3.new(mazeCenter.X, npcPos.Y, mazeCenter.Z) - npcPos).Magnitude

					if distance <= 200 and npc.Humanoid.Health > 0 then
						count = count + 1
					end
				end
			end

			return count
		end

		if Npc then
			MazeNpcsFound = true
			MazeNpcsKilled = false
		end

		if MazeNpcsFound and not MazeNpcsKilled then
			local aliveNpcs = CountMazeNpcs()

			if aliveNpcs == 0 then
				MazeNpcsKilled = true
				MazeNpcKilledTime = tick()
			end
		end

		if
			not Npc
			and (Vector3.new(2674.46435546875, 2075.4453125, -15478.548828125) - Vector3.new(
				PlayerHumpart.Position.X,
				2075.4453125,
				PlayerHumpart.Position.Z
			)).Magnitude > 20
			and not Character:FindFirstChild("Cuffed")
			and not workspace.Islands["Impel Base - Floor 1"].Barriers:FindFirstChild("FirstBarrier")
		then
			if MazeNpcsKilled then
				local timeWaited = tick() - MazeNpcKilledTime
				if timeWaited < 5 then
					return
				else
					MazeNpcsFound = false
					MazeNpcsKilled = false
				end
			end

			wait(1)
			skipPart = true
			targetPosition = Vector3.new(2674.46435546875, 2075.4453125, -15478.548828125)
			targetFloorPosition = Vector3.new(2674.46435546875, 2075.4453125, -15478.548828125)
			local Distance = (targetPosition - PlayerHumpart.Position).magnitude
			local Time = GetTime(Distance, Speed)
			wait()
			local targetCFrame = CFrame.new(targetPosition)
			tweenWithTeleport(targetCFrame, Speed, selected_Offset)
			task.wait(2)
		elseif
			(
				not Character:FindFirstChild("Cuffed")
				and not workspace.Islands["Impel Base - Floor 1"].Barriers:FindFirstChild("FirstBarrier")
				and GetMagnitudeIgnoringY(Vector3.new(2674.46435546875, 2075.4453125, -15478.548828125)) < 20
			)
			or (
				Npc
				and not Character:FindFirstChild("Cuffed")
				and not workspace.Islands["Impel Base - Floor 1"].Barriers:FindFirstChild("FirstBarrier")
			)
		then
			skipPart = false
			if not tpedback then
				Speed = getgenv().TweenSpeed or 80
			end
			local endMazePos1 = Vector3.new(2674.897216796875, 2075.271240234375, -15479.0595703125)
			local endMazePos2 = Vector3.new(2674.46435546875, 2085.4453125, -15538.548828125)
			if
				Npc
				and Npc:FindFirstChild("HumanoidRootPart")
				and (
						Vector3.new(endMazePos2.X, Npc.HumanoidRootPart.Position.Y, endMazePos2.Z)
						- Npc.HumanoidRootPart.Position
					).Magnitude
					<= 100
			then
				targetFloorPosition = nil
				targetPosition = nil
				targetPosition = Npc.Head.Position + Vector3.new(0, 20, 0)
				if targetPosition then
					controlTower(CFrame.new(targetPosition), Speed)
					CanTween = true
				end
			else
				tweenWithTeleport(endMazePos1, Speed, selected_Offset)
				task.wait(1)
				if (Character.HumanoidRootPart.Position - endMazePos1).Magnitude < 10 then
					tweenWithTeleport(endMazePos2, Speed)
					task.wait(1)
				end
				CanTween = true
			end
		end
	end

	noClip(true)
	local lastDefenseAllocation = 0

	local function selectNightmare(diffChooser)
		local success, err = pcall(function()
			local Button = diffChooser:FindFirstChild("Frame")
				and diffChooser.Frame:FindFirstChild("ScrollingFrame")
				and diffChooser.Frame.ScrollingFrame:FindFirstChild("Nightmare")

			if not Button then
				return
			end

			local types = { "MouseButton1Down", "MouseButton1Up", "MouseButton1Click" }
			for _, t in pairs(types) do
				local signal = Button:FindFirstChild(t) or Button[t]
				if signal and typeof(getconnections) == "function" then
					for _, ncon in pairs(getconnections(signal)) do
						pcall(ncon.Function)
					end
				end
			end
		end)
		if not success then
			warn("selectNightmare error:", err)
		end
	end

	LocalPlayer.PlayerGui.ChildAdded:Connect(function(child)
		if child.Name == "DiffChooser" then
			task.wait(0.1)
			selectNightmare(child)
		end
	end)

	spawn(function()
		while wait(1) do
			if statsFolder and statsFolder.Stats.SkillPoints.Value > 0 then
				local currentDefense = game.ReplicatedStorage["Stats" .. player.Name].Stats.Defense.Value
				local currentStamina = game.ReplicatedStorage["Stats" .. player.Name].Stats.Stamina.Value
				if currentDefense < 450 then
					if tick() - lastDefenseAllocation < 3 then
						continue
					end
					local available = statsFolder.Stats.SkillPoints.Value
					local pointsNeeded = math.min(450 - currentDefense, available)
					if pointsNeeded > 0 then
						player.PlayerGui.Statistics.Main.TopOptions.Base.Input.Text = tostring(pointsNeeded)
						task.wait(0.2)
						game:GetService("ReplicatedStorage").Events.stats:FireServer("Defense", nil, pointsNeeded)
						lastDefenseAllocation = tick()
					end
				elseif currentStamina < 125 then
					local available = statsFolder.Stats.SkillPoints.Value
					local pointsNeeded = math.min(125 - currentStamina, available)
					if pointsNeeded > 0 then
						player.PlayerGui.Statistics.Main.TopOptions.Base.Input.Text = tostring(pointsNeeded)
						task.wait(0.2)
						game:GetService("ReplicatedStorage").Events.stats:FireServer("Stamina", nil, pointsNeeded)
					end
				else
					local available = statsFolder.Stats.SkillPoints.Value
					player.PlayerGui.Statistics.Main.TopOptions.Base.Input.Text = tostring(available)
					task.wait(0.2)
					checkOwnedWeapons()
					if
						OwnedFarmedWeapons["Kraken Blade"]
						or OwnedFarmedWeapons["Hollow's Great Sword"]
						or OwnedFarmedWeapons["Dark Blade"]
						or OwnedFarmedWeapons["Golden Hook"]
					then
						game:GetService("ReplicatedStorage").Events.stats:FireServer("SwordMastery", nil, available)
					elseif OwnedFarmedWeapons["Vrael's Pipe"] or OwnedFarmedWeapons["Knight's Gauntlet"] then
						game:GetService("ReplicatedStorage").Events.stats:FireServer("Strength", nil, available)
					elseif Others.MeleeRun then
						-- melee run (no wanted weapon): Strength, up to 1150
						local strength = statsFolder.Stats.Strength.Value
						local pts = math.min(1150 - strength, available)
						if pts > 0 then
							player.PlayerGui.Statistics.Main.TopOptions.Base.Input.Text = tostring(pts)
							task.wait(0.2)
							game:GetService("ReplicatedStorage").Events.stats:FireServer("Strength", nil, pts)
						end
					end
				end
			end
			local diffChooser = LocalPlayer.PlayerGui:FindFirstChild("DiffChooser")
			if diffChooser then
				selectNightmare(diffChooser)
			end
		end
	end)

	function equipattacktool()
		local m1type = "Melee"

		if not Character then
			return m1type
		end
		local humanoid = Character:FindFirstChild("Humanoid")
		if not humanoid then
			return m1type
		end
		if humanoid.Health <= 0 or humanoid:GetState() == Enum.HumanoidStateType.Dead then
			return m1type
		end
		if Character:FindFirstChild("SafeForceField") then
			return m1type
		end
		if not Character:FindFirstChild("HumanoidRootPart") then
			return m1type
		end

		if not getgenv().LastEquipTime then
			getgenv().LastEquipTime = 0
		end
		if tick() - getgenv().LastEquipTime < 0.5 then
			return m1type
		end

		local bestWeapon = nil
		local bestPriority = 0

		for _, tool in pairs(player.Backpack:GetChildren()) do
			if tool:IsA("Tool") then
				for weaponName, priority in pairs(WeaponPriority) do
					local isMatch = wantedWeaponName(tool.Name) == weaponName

					if isMatch and priority > bestPriority then
						bestWeapon = tool
						bestPriority = priority
					end
				end
			end
		end

		for _, tool in pairs(Character:GetChildren()) do
			if tool:IsA("Tool") then
				for weaponName, priority in pairs(WeaponPriority) do
					local isMatch = wantedWeaponName(tool.Name) == weaponName

					if isMatch and priority > bestPriority then
						bestWeapon = tool
						bestPriority = priority
					end
				end
			end
		end

		if bestWeapon then
			local alreadyEquipped = false
			for _, tool in pairs(Character:GetChildren()) do
				if tool:IsA("Tool") then
					if string.find(bestWeapon.Name, "Kraken Blade") then
						if string.find(tool.Name, "Kraken Blade") then
							alreadyEquipped = true
							break
						end
					elseif tool.Name == bestWeapon.Name then
						alreadyEquipped = true
						break
					end
				end
			end

			if alreadyEquipped then
				return "Sword"
			else
				pcall(function()
					if bestWeapon.Parent == player.Backpack then
						humanoid:EquipTool(bestWeapon)
						getgenv().LastEquipTime = tick()
					end
				end)
				task.wait(0.1)
				return "Sword"
			end
		end

		local meleetool = player.Backpack:FindFirstChild("Melee") or Character:FindFirstChild("Melee")
		if meleetool then
			if not Character:FindFirstChild("Melee") then
				pcall(function()
					if meleetool.Parent == player.Backpack then
						humanoid:EquipTool(meleetool)
						getgenv().LastEquipTime = tick()
					end
				end)
				task.wait(0.1)
			end
			return m1type
		end

		local meleeTool = player.Backpack:FindFirstChild("Combat", true)
		if meleeTool and meleeTool.Parent then
			pcall(function()
				humanoid:EquipTool(meleeTool.Parent)
				getgenv().LastEquipTime = tick()
			end)
		end

		return m1type
	end

	function GetFloorPositionUnderBoss(npc)
		if not npc or not npc:FindFirstChild("HumanoidRootPart") then
			return nil
		end

		local bossHrp = npc.HumanoidRootPart
		local bossPos = bossHrp.Position

		local raycastParams = RaycastParams.new()
		raycastParams.FilterType = Enum.RaycastFilterType.Whitelist
		raycastParams.FilterDescendantsInstances = { workspace.Islands }

		local rayDirection = Vector3.new(0, -500, 0)
		local rayResult = workspace:Raycast(bossPos, rayDirection, raycastParams)

		if rayResult then
			return rayResult.Position + Vector3.new(0, 10, 0)
		end

		return nil
	end

	Others.M1Cooldown = Others.M1Cooldown or 0
	Others.M1Combo = Others.M1Combo or 0
	Others.CurrentM1Cooldown = Others.CurrentM1Cooldown or 0
	Others.M1LongCd = Others.M1LongCd or false
	Others.LastM1Time = Others.LastM1Time or 0

	function Buso(value)
		local hashaki = statsFolder.Stats.BusoMastery.Value ~= 0
		if not hashaki then
			return
		end -- Don't try to use buso if player doesn't have haki

		local hasbuso = Character:FindFirstChild("BusoMelee")
		if (not hasbuso and value) or (hasbuso and not value) then
			equipattacktool()
			local args = {
				"Buso",
			}
			game:GetService("ReplicatedStorage"):WaitForChild("Events"):WaitForChild("Haki"):FireServer(unpack(args))
			task.wait()
		end
	end
	function isUnderTrap(position, safetyMargin)
		safetyMargin = safetyMargin or 35

		local env = workspace.Effects:FindFirstChild("Environment") or workspace.Islands
		if not env then
			return false
		end

		for _, trap in ipairs(env:GetChildren()) do
			if trap.Name == "FallingTrap" then
				trap.Parent = workspace.Islands
				local hitbox = trap:FindFirstChild("Hitbox")
				if hitbox and hitbox:IsA("BasePart") then
					hitbox.CanCollide = true
					hitbox.Transparency = 0.85
					local hitboxPos = hitbox.Position
					local hitboxSize = hitbox.Size

					-- Check if position is inside the 3D trigger volume (X, Y, Z)
					local minX = hitboxPos.X - (hitboxSize.X / 2) - safetyMargin
					local maxX = hitboxPos.X + (hitboxSize.X / 2) + safetyMargin
					local minY = hitboxPos.Y - (hitboxSize.Y / 2) - safetyMargin
					local maxY = hitboxPos.Y + (hitboxSize.Y / 2) + safetyMargin
					local minZ = hitboxPos.Z - (hitboxSize.Z / 2) - safetyMargin
					local maxZ = hitboxPos.Z + (hitboxSize.Z / 2) + safetyMargin

					local inVolume = position.X >= minX
						and position.X <= maxX
						and position.Y >= minY
						and position.Y <= maxY
						and position.Z >= minZ
						and position.Z <= maxZ

					if inVolume then
						return true, hitbox
					end
				end
			end
		end

		return false, nil
	end

	function findSafePositionFromTrap(unsafePos, safetyMargin)
		safetyMargin = safetyMargin or 40

		local _, trapHitbox = isUnderTrap(unsafePos, 20)

		if trapHitbox then
			local trapPos = trapHitbox.Position
			local trapSize = trapHitbox.Size

			-- Calculate 3D direction away from trap center
			local awayDir = (unsafePos - trapPos).Unit

			-- Escape distance based on trap's largest dimension
			local escapeDistance = math.max(trapSize.X, trapSize.Y, trapSize.Z) / 2 + safetyMargin + 15
			local safePos = trapPos + (awayDir * escapeDistance)

			-- Verify safe
			if not isUnderTrap(safePos, 20) then
				return safePos
			end
		end

		-- Try 3D offsets (including up/down)
		local offsets = {
			Vector3.new(safetyMargin + 25, 0, 0),
			Vector3.new(-(safetyMargin + 25), 0, 0),
			Vector3.new(0, safetyMargin + 25, 0), -- Up
			Vector3.new(0, -(safetyMargin + 25), 0), -- Down
			Vector3.new(0, 0, safetyMargin + 25),
			Vector3.new(0, 0, -(safetyMargin + 25)),
			-- Diagonal escapes
			Vector3.new(safetyMargin + 20, safetyMargin + 20, 0),
			Vector3.new(-(safetyMargin + 20), safetyMargin + 20, 0),
			Vector3.new(0, safetyMargin + 20, safetyMargin + 20),
			Vector3.new(0, safetyMargin + 20, -(safetyMargin + 20)),
		}

		for _, offset in ipairs(offsets) do
			local testPos = unsafePos + offset
			if not isUnderTrap(testPos, 20) then
				return testPos
			end
		end

		-- Last resort: go straight up
		return unsafePos + Vector3.new(0, 150, 0)
	end

	-- Check if path crosses trap volumes
	function pathCrossesTrap(startPos, endPos, safetyMargin)
		safetyMargin = safetyMargin or 35

		-- Sample MORE points for better detection
		local distance = (endPos - startPos).Magnitude
		local steps = math.max(15, math.ceil(distance / 10)) -- At least 15 samples

		for i = 0, steps do
			local alpha = i / steps
			local checkPos = startPos:Lerp(endPos, alpha)

			local inTrap, trapHitbox = isUnderTrap(checkPos, safetyMargin)
			if inTrap then
				return true, checkPos, trapHitbox
			end
		end

		return false, nil, nil
	end

	-- THIRD FLOOR ROOF DELETION LOOP
	task.spawn(function()
		while task.wait(0.5) do
			pcall(function()
				local targetPosition = Vector3.new(5670.59912109375, 2659.4013671875, -20328.2421875)

				for _, part in pairs(workspace:GetDescendants()) do
					if part:IsA("BasePart") then
						local distance = (part.Position - targetPosition).Magnitude

						if distance < 0.1 then
							part:Destroy()
							warn("Deleted part at target position:", part.Name)
						end
					end
				end
			end)
		end
	end)
	local TypeM1 = "Ground"
	local ragdollTimers = {}

	local function isRagdolled(enemy)
		local humanoid = enemy:FindFirstChild("Humanoid")
		if not humanoid then
			return false
		end

		local ragdolled = humanoid:GetAttribute("isRagdolled")
		return ragdolled
	end
	local RaycastFilterType = Enum.RaycastFilterType

	local function buildRayParams()
		local params = RaycastParams.new()
		params.FilterType = RaycastFilterType.Include
		local filterList = { Character }
		local optionalExcludes = {
			workspace:FindFirstChild("Islands"),
		}
		for _, obj in ipairs(optionalExcludes) do
			if obj then
				table.insert(filterList, obj)
			end
		end
		params.FilterDescendantsInstances = filterList
		params.RespectCanCollide = true
		return params
	end

	local cachedRayParams = nil

	local function getRayParams()
		if not cachedRayParams or not Character or not Character.Parent then
			cachedRayParams = buildRayParams()
		end
		return cachedRayParams
	end

	local function invalidateRayParams()
		cachedRayParams = nil
	end

	local function castRay(origin, direction)
		return workspace:Raycast(origin, direction, getRayParams())
	end

	local function isPathClear(fromPos, toPos)
		local direction = toPos - fromPos
		local dist = direction.Magnitude
		if dist < 0.1 then
			return true, nil
		end
		local result = castRay(fromPos, direction)
		if result and result.Distance < dist then
			return false, result
		end
		return true, nil
	end

	local function isPositionInsidePart(position)
		local params = getRayParams()
		local testDirs = {
			Vector3.new(1, 0, 0),
			Vector3.new(-1, 0, 0),
			Vector3.new(0, 1, 0),
			Vector3.new(0, -1, 0),
			Vector3.new(0, 0, 1),
			Vector3.new(0, 0, -1),
		}
		local closeHits = 0
		for _, dir in ipairs(testDirs) do
			local result = workspace:Raycast(position, dir * 3, params)
			if result and result.Distance < 3 then
				closeHits = closeHits + 1
			end
		end
		if closeHits >= 3 then
			return true
		end
		for i = 1, 5, 2 do
			local r1 = workspace:Raycast(position, testDirs[i] * 5, params)
			local r2 = workspace:Raycast(position, testDirs[i + 1] * 5, params)
			if r1 and r2 and r1.Distance < 5 and r2.Distance < 5 then
				return true
			end
		end
		return false
	end

	local function getValidMovementPosition(fromPos, toPos, margin)
		margin = margin or 2.5
		local clear, hitResult = isPathClear(fromPos, toPos)
		if clear then
			if isPositionInsidePart(toPos) then
				local dir = (toPos - fromPos).Unit
				local pullback = toPos - dir * margin
				if isPositionInsidePart(pullback) then
					return fromPos, true
				end
				return pullback, true
			end
			return toPos, false
		end
		local hitPos = hitResult.Position
		local hitNormal = hitResult.Normal
		local safePos = hitPos + hitNormal * margin
		if isPositionInsidePart(safePos) then
			local dir = (toPos - fromPos).Unit
			safePos = hitPos - dir * margin
			if isPositionInsidePart(safePos) then
				return fromPos, true
			end
		end
		return safePos, true
	end

	local function findSafeAttackPosition(enemyPos, enemyCFrame, preferredOffset, attackRadius)
		attackRadius = attackRadius or 30
		local playerPos = PlayerHumpart.Position
		local preferredPos = (enemyCFrame * CFrame.new(preferredOffset.X, preferredOffset.Y, preferredOffset.Z)).Position
		if not isPositionInsidePart(preferredPos) then
			local clear, _ = isPathClear(playerPos, preferredPos)
			if clear then
				return preferredPos
			end
		end
		local testDistances = { 8, 12, 6, 15, 4 }
		local testAngles = { 0, 45, 90, 135, 180, 225, 270, 315 }
		local yOffsets = { preferredOffset.Y, preferredOffset.Y + 3, preferredOffset.Y - 3, 8, 5, 3, 10 }
		for _, yOff in ipairs(yOffsets) do
			for _, dist in ipairs(testDistances) do
				for _, angle in ipairs(testAngles) do
					local rad = math.rad(angle)
					local testPos = enemyPos + Vector3.new(math.cos(rad) * dist, yOff, math.sin(rad) * dist)
					if not isPositionInsidePart(testPos) then
						local clear, _ = isPathClear(playerPos, testPos)
						if clear and (testPos - enemyPos).Magnitude < attackRadius then
							return testPos
						end
					end
				end
			end
		end
		local retreatDir = (playerPos - enemyPos)
		retreatDir = retreatDir.Magnitude > 0.1 and retreatDir.Unit or Vector3.new(1, 0, 0)
		for _, dist in ipairs({ 10, 15, 20, 8, 5 }) do
			for _, yOff in ipairs(yOffsets) do
				local testPos = enemyPos + retreatDir * dist + Vector3.new(0, yOff, 0)
				if not isPositionInsidePart(testPos) then
					local clear, _ = isPathClear(playerPos, testPos)
					if clear and (testPos - enemyPos).Magnitude < attackRadius then
						return testPos
					end
				end
			end
		end
		return nil
	end

	local function findFallbackPosition(enemyPos)
		local abovePos = Vector3.new(enemyPos.X, selected_Offset or (enemyPos.Y + 50), enemyPos.Z)
		if not isPositionInsidePart(abovePos) then
			return abovePos, "offset"
		end
		if currentTargetPosition and typeof(currentTargetPosition) == "Vector3" then
			local floorPos = currentTargetPosition + Vector3.new(0, 10, 0)
			if not isPositionInsidePart(floorPos) then
				return floorPos, "floor"
			end
		end
		local highPos = Vector3.new(enemyPos.X, enemyPos.Y + 80, enemyPos.Z)
		if not isPositionInsidePart(highPos) then
			return highPos, "high"
		end
		return abovePos, "offset"
	end


	--==========================================================================
	-- QUEST5 MOVEMENT CORE
	-- quest5's straightLineTween, ported: the character is moved every render
	-- frame (before the camera script) at a constant speed, drift from water or
	-- physics is snapped back after physics, and the camera is never allowed to
	-- get further from the character than when the move began. Zephyron keeps
	-- its own wall guard (getValidMovementPosition) as an optional per-frame clamp.
	-- ZQ5.moving pauses the hover engine while a move is running.
	--==========================================================================
	ZQ5 = ZQ5 or {}
	ZQ5.moving = false
	ZQ5.hoverActive = false

	function ZQ5.move(destination, speed, ctl)
		ctl = ctl or {}
		local hrp = PlayerHumpart
		if not hrp or not hrp.Parent then
			return false, "nohrp"
		end

		for _, obj in ipairs(hrp:GetChildren()) do
			if obj:IsA("BodyMover") or obj:IsA("Constraint") then
				obj:Destroy()
			end
		end

		local RunSvc = game:GetService("RunService")
		local cam = workspace.CurrentCamera
		local maxCamDist = (cam and (cam.CFrame.Position - hrp.Position).Magnitude or 0) + 3

		-- water fix (quest5): swimming buoyancy cancels downward moves
		local hum = Character and Character:FindFirstChildOfClass("Humanoid")
		local swimWasEnabled = true
		if hum then
			pcall(function()
				swimWasEnabled = hum:GetStateEnabled(Enum.HumanoidStateType.Swimming)
				hum:SetStateEnabled(Enum.HumanoidStateType.Swimming, false)
				hum.PlatformStand = true
				hum:ChangeState(Enum.HumanoidStateType.Physics)
			end)
		end

		-- ctl.route: a list of points followed in ONE move (no stop, no humanoid state reset
		-- between them). Per-point moves toggled PlatformStand / GettingUp at every waypoint:
		-- the humanoid stood up for a frame and pushed the root up/down -> visible bobbing.
		local st = {
			finished = false,
			reason = nil,
			lastSet = nil,
			stuckT = 0,
			speed = speed or 80,
			dest = ctl.route and ctl.route[1] or destination,
			route = ctl.route,
			idx = 1,
			paused = false,
		}
		local id = "ZephyronMove_" .. tostring(math.random(1, 1e9))
		ZQ5.moving = true

		RunSvc:BindToRenderStep(id .. "_move", Enum.RenderPriority.Camera.Value - 1, function(dt)
			local h = PlayerHumpart
			if not h or not h.Parent then
				st.finished = true
				st.reason = "nohrp"
				return
			end
			for _, mover in ipairs(h:GetChildren()) do
				if mover:IsA("BodyMover") then
					mover:Destroy()
				end
			end
			if st.paused then
				-- hold the spot while paused (anticheat wait). Only zeroing velocity let gravity
				-- pull us down 2-3 studs a frame with noclip on: fell through Floor 2 into the void.
				st.pauseAt = st.pauseAt or h.Position
				h.CFrame = CFrame.new(st.pauseAt) * (h.CFrame - h.CFrame.Position)
				h.AssemblyLinearVelocity = Vector3.zero
				return
			end
			st.pauseAt = nil

			local pos = h.Position
			local rot = h.CFrame - h.CFrame.Position
			local route = st.route
			local budget = st.speed * dt
			local toTarget = st.dest - pos
			local dist = toTarget.Magnitude
			-- reached a route point: carry the rest of this frame's step on to the next one
			while route and st.idx < #route and dist <= math.max(budget, 0.5) do
				budget = budget - dist
				pos = st.dest
				if ctl.onReach then
					pcall(ctl.onReach, st.idx, st.dest)
				end
				st.idx = st.idx + 1
				st.dest = route[st.idx]
				toTarget = st.dest - pos
				dist = toTarget.Magnitude
			end

			if dist <= 0.5 then
				h.CFrame = CFrame.new(st.dest) * rot
				h.AssemblyLinearVelocity = Vector3.zero
				st.lastSet = st.dest
				if route and ctl.onReach then
					pcall(ctl.onReach, st.idx, st.dest)
				end
				st.finished = true
				return
			end

			local nextPos = pos + toTarget.Unit * math.min(math.max(budget, 0), dist)

			if ctl.wallMargin then
				local valid, blocked = getValidMovementPosition(pos, nextPos, ctl.wallMargin)
				if blocked then
					nextPos = valid
					if (valid - pos).Magnitude < 0.05 then
						st.stuckT = st.stuckT + dt
					else
						st.stuckT = 0
					end
				else
					st.stuckT = 0
				end
			end

			h.CFrame = CFrame.new(nextPos) * rot
			h.AssemblyLinearVelocity = Vector3.zero
			st.lastSet = nextPos
		end)

		local driftConn = RunSvc.Heartbeat:Connect(function()
			local h = PlayerHumpart
			if not h or not st.lastSet or st.finished or st.paused then
				return
			end
			local drift = (h.Position - st.lastSet).Magnitude
			if drift > 40 then
				-- the GAME moved us (floor change, cutscene): never drag the body back
				st.finished = true
				st.reason = "teleported"
				return
			end
			local hum2 = Character and Character:FindFirstChildOfClass("Humanoid")
			local d = h.Position - st.lastSet
			local sideways = Vector3.new(d.X, 0, d.Z).Magnitude
			if drift > 3 and sideways > 2 and d.Y > -sideways then
				-- knocked sideways (an NPC hit / ragdoll): just keep going from where it left us.
				-- No snap back (a teleport for the server), no stopping the move.
				st.lastSet = h.Position
			elseif drift > 0.05 then
				local rot = h.CFrame - h.CFrame.Position
				h.CFrame = CFrame.new(st.lastSet) * rot
			end
			h.AssemblyLinearVelocity = Vector3.zero
			h.AssemblyAngularVelocity = Vector3.zero
		end)

		RunSvc:BindToRenderStep(id .. "_cam", Enum.RenderPriority.Last.Value, function()
			local camera = workspace.CurrentCamera
			local h = PlayerHumpart
			if not camera or not h then
				return
			end
			local offset = camera.CFrame.Position - h.Position
			if offset.Magnitude > maxCamDist then
				local newPos = h.Position + offset.Unit * maxCamDist
				camera.CFrame = CFrame.new(newPos) * (camera.CFrame - camera.CFrame.Position)
			end
		end)

		-- the poll runs on the normal scheduler, so it may yield (anticheat waits, hops)
		local bestDist, bestAt = math.huge, tick()
		pcall(function()
			while not st.finished do
				task.wait()
				-- no progress for 3s (not paused): give up this move ("stuck" -> walkTo backs up
				-- and re-paths). Was: stood in one spot forever with a limp body.
				local hh = PlayerHumpart
				if hh and not st.paused then
					local d = (hh.Position - st.dest).Magnitude
					if d < bestDist - 1 or (st.idx or 1) ~= (st.lastIdx or 1) then
						bestDist, bestAt = d, tick()
						st.lastIdx = st.idx
					elseif tick() - bestAt > 3 then
						print("[WALK] no progress for 3s at " .. tostring(hh.Position) .. ", ending this move")
						st.reason = "stuck"
						break
					end
				else
					bestAt = tick()
				end
				if ctl.poll then
					local r = ctl.poll(st)
					if r then
						st.reason = r
						break
					end
				end
			end
		end)

		RunSvc:UnbindFromRenderStep(id .. "_move")
		RunSvc:UnbindFromRenderStep(id .. "_cam")
		driftConn:Disconnect()
		ZQ5.moving = false
		if PlayerHumpart then
			PlayerHumpart.AssemblyLinearVelocity = Vector3.zero
		end
		if hum then
			pcall(function()
				hum.PlatformStand = false
				hum:SetStateEnabled(Enum.HumanoidStateType.Swimming, swimWasEnabled)
				hum:ChangeState(Enum.HumanoidStateType.GettingUp)
			end)
		end
		return st.finished and st.reason == nil, st.reason
	end


	-- GROUND WALK: the game now flags head-in-geometry (OverlapHead), flying more than 15
	-- studs over the floor (Greater Flight Strike) and moving too fast (TP check). So travel the
	-- way a player walks: PathfindingService waypoints, root at standing height, 30 studs/s.
	-- Falls back to the old straight move when no path is found.
	local PathfindingService = game:GetService("PathfindingService")
	local WALK_SPEED = 40
	-- Moves walk pathfinding waypoints around walls. MAZE ONLY (Floor 1): if we stay stuck in
	-- the same spot (no path, repeated re-paths, or < 5 studs of progress for 6s), finish with
	-- ONE straight ZQ5.move line from there to the target, through the walls (noclip is on
	-- while moving; noclip flags do not stop that move).
	local MAZE_STUCK_SECONDS = 6
	ZQ5.straight = false
	local stuckPos, stuckSince = nil, 0

	-- the stuck -> straight-line fallback is allowed ONLY while walking to the Floor 2 boss-gate
	-- lever (ZQ5.leverMode); never in the maze
	local function inMaze()
		return ZQ5.leverMode == true
	end

	local function straightThrough(dest, poll, why)
		print(string.format("[WALK] lever: stuck (%s) at %s, going straight to %s", why, tostring(PlayerHumpart.Position), tostring(dest)))
		ZQ5.straight = true
		local ok, reason = ZQ5.move(dest, WALK_SPEED, { poll = poll })
		ZQ5.straight = false
		stuckPos, stuckSince = nil, 0
		return ok, reason
	end
	local ROOT_ABOVE_GROUND = 3

	-- ground under `pos`, looking DOWN only from just above it (casting from higher up used to
	-- hit ceilings / tree crowns over the target and lift the destination onto them)
	local function groundYAt(pos, depth)
		local params = RaycastParams.new()
		params.FilterType = Enum.RaycastFilterType.Exclude
		params.FilterDescendantsInstances = {
			Character,
			workspace:FindFirstChild("NPCs"),
			workspace:FindFirstChild("Effects"),
		}
		pcall(function()
			params.RespectCanCollide = true
		end)
		local hit = workspace:Raycast(pos + Vector3.new(0, 1, 0), Vector3.new(0, -(depth or 14), 0), params)
		return hit and hit.Position.Y or nil
	end

	-- where the root should be when standing at `pos`: on the REAL ground there (navmesh
	-- waypoints sit a little above/below the floor -> we bobbed up and down and sometimes ran a
	-- bit under the floor), at the character's own standing height plus a small margin
	local function standHeight()
		local hum = Character and Character:FindFirstChildOfClass("Humanoid")
		local root = PlayerHumpart
		if hum and root then
			local h = hum.HipHeight + root.Size.Y / 2
			if hum.RigType == Enum.HumanoidRigType.R6 then
				h = 2 + root.Size.Y / 2 -- R6 legs are 2 studs, HipHeight is 0
			end
			return math.max(h, 2.5) + 0.4
		end
		return ROOT_ABOVE_GROUND + 0.4
	end
	function standPointAt(pos, probeUp)
		local up = probeUp or 3
		local gy = groundYAt(pos + Vector3.new(0, up, 0), up + 8)
		if gy then
			return Vector3.new(pos.X, gy + standHeight(), pos.Z)
		end
		return Vector3.new(pos.X, pos.Y + ROOT_ABOVE_GROUND, pos.Z)
	end

	local function computePathExact(from, dest, radius)
		local ok, path = pcall(function()
			local p = PathfindingService:CreatePath({
				AgentRadius = radius or 2.5,
				AgentHeight = 6,
				AgentCanJump = true,
				WaypointSpacing = 4,
			})
			p:ComputeAsync(from, dest)
			return p
		end)
		if not (ok and path and path.Status == Enum.PathStatus.Success) then
			return nil
		end
		local wps = path:GetWaypoints()
		-- sanity, in GROUND heights: a path diving well below both ends (a lower level / under
		-- the floor) or climbing far above them (onto wall tops) is rejected
		local fromG = groundYAt(from, 60) or (from.Y - ROOT_ABOVE_GROUND)
		local destG = groundYAt(dest, 60) or (dest.Y - ROOT_ABOVE_GROUND)
		local lowEnd, highEnd = math.min(fromG, destG) - 15, math.max(fromG, destG) + 25
		local minY, maxY = math.huge, -math.huge
		for _, w in ipairs(wps) do
			minY = math.min(minY, w.Position.Y)
			maxY = math.max(maxY, w.Position.Y)
		end
		if minY < lowEnd or maxY > highEnd then
			print(string.format("[WALK] rejected path to %s: waypoint Y %.0f..%.0f outside %.0f..%.0f", tostring(dest), minY, maxY, lowEnd, highEnd))
			return nil
		end
		return wps, minY, maxY
	end

	-- the exact target is often unreachable for the navmesh (a chest or key is a solid model
	-- standing right there): try points in a ring around it; the last few studs are a short hop
	local RING = { Vector3.new(3, 0, 0), Vector3.new(-3, 0, 0), Vector3.new(0, 0, 3), Vector3.new(0, 0, -3),
		Vector3.new(5, 0, 0), Vector3.new(-5, 0, 0), Vector3.new(0, 0, 5), Vector3.new(0, 0, -5),
		Vector3.new(4, 0, 4), Vector3.new(-4, 0, 4), Vector3.new(4, 0, -4), Vector3.new(-4, 0, -4) }
	local function computePath(from, dest)
		-- a wide agent first: paths hugging walls / cutting corners put our head in the wall
		-- for the server (noclip strikes; enough of them and the game kills you, "eliminated
		-- by Game"). Narrow agent only when the wide one finds nothing.
		local wps, minY, maxY = computePathExact(from, dest, 4)
		if wps then
			return wps, minY, maxY, false
		end
		wps, minY, maxY = computePathExact(from, dest)
		if wps then
			return wps, minY, maxY, false
		end
		for _, off in ipairs(RING) do
			wps, minY, maxY = computePathExact(from, dest + off)
			if wps then
				return wps, minY, maxY, true
			end
		end
		return nil
	end

	-- Walk dest along a path. Every segment keeps the wall check: hitting a wall ("stuck") or
	-- the game's noclip flag ("noclip") means we left the path (knockback, a recovery lift...),
	-- so back up to the last waypoint we reached cleanly and compute a fresh path from there.
	-- No more rising out of trouble: rising inside a tall maze wall climbed 150 studs and kicked.
	local lastWalkLog = 0
	function ZQ5.walkTo(dest, poll)
		if not PlayerHumpart or not PlayerHumpart.Parent then
			return false, "nohrp"
		end
		-- the tween poll sets st.speed to the tween speed (80+). Per-waypoint moves stopped and
		-- restarted so often that it never really got there; the one continuous route did, and
		-- ran way too fast. Walking keeps WALK_SPEED.
		if poll then
			local tweenPoll = poll
			poll = function(st)
				local r = tweenPoll(st)
				st.speed = WALK_SPEED
				return r
			end
		end

		-- walking ends ON the ground: a ground-level target (chest, key) would put the root in
		-- the floor, and an air target (a point over a mob) would leave us floating -> flight
		-- strikes. Getting above a mob is the hover's job.
		local gy = groundYAt(dest, 60)
		if gy then
			dest = Vector3.new(dest.X, gy + standHeight(), dest.Z)
		end

		-- maze: no real progress for MAZE_STUCK_SECONDS -> straight line from here
		-- (only counts back-to-back walk attempts: a pause to fight or wait resets it)
		local here = PlayerHumpart.Position
		if not stuckPos or (here - stuckPos).Magnitude > 5 or tick() - (ZQ5.lastWalkCall or 0) > 3 then
			stuckPos, stuckSince = here, tick()
		end
		ZQ5.lastWalkCall = tick()
		if inMaze() and tick() - stuckSince > MAZE_STUCK_SECONDS then
			return straightThrough(dest, poll, "no progress")
		end

		-- still up in the air (a hover just ended and its pad is gone): come straight down to
		-- standing height first, pathfinding from mid-air fails and the body just dropped
		do
			-- only when we're really in the air: the humanoid stands on nothing and the drop is a
			-- hover's worth. On the Floor 2 spawn the ray went through the (non-collide) spawn
			-- platform, found ground ~80 studs lower and walked us straight down through the floor.
			local p0 = PlayerHumpart.Position
			local hum0 = Character and Character:FindFirstChildOfClass("Humanoid")
			local standing = hum0 and hum0.FloorMaterial ~= Enum.Material.Air
			local g0 = (not standing) and groundYAt(p0, 30) or nil
			if g0 and p0.Y - (g0 + standHeight()) > 3 then
				ZQ5.move(Vector3.new(p0.X, g0 + standHeight(), p0.Z), WALK_SPEED, { poll = poll })
			end
		end

		ZQ5.lastWalkResult = nil
		local attempt, knocks = 0, 0
		while attempt < 4 and knocks < 15 do
			attempt = attempt + 1
			local from = PlayerHumpart.Position
			local wps, minY, maxY, nearOnly = computePath(from, dest)
			if not wps then
				if inMaze() then
					return straightThrough(dest, poll, "no path")
				end
				-- outside the maze: no straight-line fallback (it set off tp/noclip checks)
				print("[WALK] no path to " .. tostring(dest) .. ", skipping this move")
				ZQ5.lastWalkResult = "nopath"
				task.wait(1)
				return false, "nopath"
			end
			if tick() - lastWalkLog > 3 then
				lastWalkLog = tick()
				print(string.format("[WALK] %d waypoints to %s, ground Y %.0f..%.0f", #wps, tostring(dest), minY, maxY))
			end

			-- build the whole route first (a point over steps/ledges so the line never cuts a
			-- floor edge), then walk it in one continuous move: no stop-and-stand per waypoint
			local route = {}
			local prev = from
			for i = 2, #wps do
				local wp = (i == #wps and not nearOnly) and dest or standPointAt(wps[i].Position)
				local mid = (prev + wp) / 2
				local midStand = standPointAt(mid, 2)
				if midStand.Y > mid.Y + 0.3 then
					table.insert(route, midStand)
				end
				table.insert(route, wp)
				prev = wp
			end

			local lastGood = from
			local failed = nil
			ZQ5.walking = true
			if #route > 0 then
				local _, reason = ZQ5.move(route[#route], WALK_SPEED, {
					poll = poll,
					route = route,
					onReach = function(_, p)
						lastGood = p
						ZQ5.lastWalkCall = tick()
					end,
				})
				ZQ5.lastWalkCall = tick()
				if reason == "stuck" or reason == "noclip" or reason == "knocked" then
					failed = reason
				elseif reason then
					ZQ5.walking = false
					return false, reason
				end
			end
			ZQ5.walking = false
			if not failed then
				return true, nil
			end
			if failed == "knocked" then
				-- hit off the path: just path again from here, no back-up (that walked us back
				-- into the mob that hit us)
				attempt = attempt - 1 -- a hit is not a failed path: doesn't use up a try
				knocks = knocks + 1
				print(string.format("[WALK] knocked off the path at %s, re-pathing (try %d)", tostring(PlayerHumpart.Position), attempt))
			else
				print(string.format("[WALK] %s at %s, backing up to %s and re-pathing (try %d)", failed, tostring(PlayerHumpart.Position), tostring(lastGood), attempt))
				ZQ5.move(lastGood, WALK_SPEED, {})
				task.wait(0.3)
			end
		end
		if inMaze() then
			return straightThrough(dest, poll, "re-paths kept failing")
		end
		return false, "walkfail"
	end

	-- is our head really inside world geometry (walls, floors)? Characters, NPCs and effects
	-- don't count: a mob's body overlapping us is not something a re-path can fix
	function headInWorld()
		local head = Character and Character:FindFirstChild("Head")
		if not head then
			return false
		end
		local op = OverlapParams.new()
		op.FilterType = Enum.RaycastFilterType.Exclude
		op.FilterDescendantsInstances = {
			Character,
			workspace:FindFirstChild("NPCs"),
			workspace:FindFirstChild("Effects"),
			workspace:FindFirstChild("PlayerCharacters"),
			ZQ5 and ZQ5.hoverPad or nil,
		}
		pcall(function()
			op.RespectCanCollide = true
		end)
		local ok, parts = pcall(function()
			return workspace:GetPartBoundsInBox(head.CFrame, head.Size * 0.9, op)
		end)
		return ok and parts and #parts > 0
	end

	function tweenWithTeleport(pos, speed, offsetY, tweenconfigs)
		if not tweenconfigs then
			tweenconfigs = {}
		end

		if not PlayerHumpart or not Character or not CanFarm or RaiuiAnims then
			return
		end

		if not canTweenNow() then
			return
		end

		local targetPosition = typeof(pos) == "CFrame" and pos.Position or pos

		local isOnFifthFloor = workspace.Islands:FindFirstChild("Impel Base - Floor 5")
		if isOnFifthFloor then
			for partName, partData in pairs(FourthFloor) do
				if (targetPosition - partData.Position).Magnitude < 50 then
					return
				end
			end
		end

		local isOnFourthFloor = workspace.Islands:FindFirstChild("Impel Base - Floor 4")
		if isOnFourthFloor then
			for partName, partData in pairs(ThirdFloor) do
				if (targetPosition - partData.Position).Magnitude < 50 then
					return
				end
			end
		end

		local isOnThirdFloor = workspace.Islands:FindFirstChild("Impel Base - Floor 3")
		if isOnThirdFloor then
			for partName, partData in pairs(SecondFloorPositions) do
				if (targetPosition - partData.Position).Magnitude < 50 then
					return
				end
			end
		end

		local function executeTween(tweenState)
			local isCurrentlyBlocking = Character:FindFirstChild("Blocking")

			if tweenState and not tweenState.active then
				return
			end

			pcall(function()
				if tweenState and not tweenState.active then
					return
				end

				if typeof(pos) == "Vector3" then
					pos = CFrame.new(pos)
				elseif typeof(pos) ~= "CFrame" then
					return
				end

				Others.LastDashTime = 0
				Others.StopShadowBan = false
				ValuesTable.shadowbanbypass = false
				local targetCFrame = pos
				local startPos = PlayerHumpart.Position

				if (startPos - targetCFrame.Position).Magnitude < 5 then
					ValuesTable.shadowbanbypass = false
					return
				end

				local destPos = typeof(pos) == "CFrame" and pos.Position or pos
				local destInTrap = isUnderTrap(destPos, 35)

				if destInTrap then
					local safeDest = findSafePositionFromTrap(destPos, 40)
					if safeDest then
						destPos = safeDest
						finalCFrame = CFrame.new(safeDest)
						downPos = downPos and CFrame.new(safeDest) or nil
					else
						ValuesTable.shadowbanbypass = false
						return
					end
				end

				local pathHasTrap, trapCrossPos, trapHitbox = pathCrossesTrap(startPos, destPos, 35)

				if pathHasTrap then
					local safeDest = findSafePositionFromTrap(destPos, 40)
					if not safeDest or isUnderTrap(safeDest, 20) then
						ValuesTable.shadowbanbypass = false
						return
					end
					destPos = safeDest
					finalCFrame = CFrame.new(safeDest)
					if downPos then
						downPos = CFrame.new(safeDest)
					end
				end

				local safeTarget = destPos

				local finalCFrame = CFrame.new(safeTarget)
				local originalTargetCFrame = CFrame.new(targetCFrame.Position)

				local y = offsetY or targetCFrame.Position.Y
				local isBlocking = Character:FindFirstChild("Blocking")

				-- set to false to bring back the old "fly up to offsetY, cross, come down" phases
				local DISABLE_UP_PHASE = true
				local actuallyNeedsOffset = offsetY ~= nil and not DISABLE_UP_PHASE

				if
					actuallyNeedsOffset
					and math.abs(startPos.Y - safeTarget.Y) < 40
					and math.abs(startPos.Y - y) < 40
				then
					actuallyNeedsOffset = false
				end

				local skipOffset = false
				if actuallyNeedsOffset then
					local yDiff = math.abs(startPos.Y - safeTarget.Y)
					local directDistance = (startPos - safeTarget).Magnitude
					-- Only skip offset if Y difference is small AND direct path is clear
					if directDistance < 100 and yDiff < 40 then
						local pathClear, _ = isPathClear(startPos, safeTarget)
						local insidePart = isPositionInsidePart(safeTarget)
						if pathClear and not insidePart then
							skipOffset = true
						end
					end
				end

				local upPos = (actuallyNeedsOffset and not skipOffset) and CFrame.new(startPos.X, y, startPos.Z)
				local midPos = (actuallyNeedsOffset and not skipOffset) and CFrame.new(safeTarget.X, y, safeTarget.Z)
					or finalCFrame
				local downPos = (not skipOffset) and originalTargetCFrame

				local function effSpeed()
					local spb = Character:GetAttribute("SpeedBypass") or 0
					local baseSpeed = speed or 80
					local finalSpeed = math.max(spb, baseSpeed) - 10
					if spb > 150 then
						return (spb * 0.8) + 50
					else
						return speed or 80
					end
				end

				local RunService = Services.RunService
				Others.TweenCd = true

				local function runPhase(toPos)
					if tweenState and not tweenState.active then
						return false
					end

					local targetCF = toPos
					local dist = (PlayerHumpart.Position - targetCF.Position).Magnitude
					if dist <= 1.5 then
						return true
					end

					-- floor guards (unchanged from the old tween)
					if workspace.Islands:FindFirstChild("Impel Base - Floor 5") then
						for _, partData in pairs(FourthFloor) do
							if (targetCF.Position - partData.Position).Magnitude < 50 then
								return false
							end
						end
					end
					if workspace.Islands:FindFirstChild("Impel Base - Floor 4") then
						for _, partData in pairs(ThirdFloor) do
							if (targetCF.Position - partData.Position).Magnitude < 50 then
								return false
							end
						end
					end
					if workspace.Islands:FindFirstChild("Impel Base - Floor 3") then
						for _, partData in pairs(SecondFloorPositions) do
							if (targetCF.Position - partData.Position).Magnitude < 50 then
								return false
							end
						end
					end

					if workspace.CurrentCamera.CameraType == Enum.CameraType.Scriptable then
						return
					end

					local hops = 0
					local pollFn = function(st)
							if tweenState and not tweenState.active then
								return "inactive"
							end
							if not PlayerHumpart or not Character then
								return "nochar"
							end

							local isF3 = workspace.Islands:FindFirstChild("Impel Base - Floor 3")
							local isF4 = workspace.Islands:FindFirstChild("Impel Base - Floor 4")
							local isF2 = workspace.Islands:FindFirstChild("Impel Base - Floor 2")
							if
								(isF3 and not isF4 and targetCF.Position.Y < 2200)
								or (isF2 and not isF3 and targetCF.Position.Y < 2200)
							then
								return "floor"
							end

							if
								not workspace:GetAttribute("HandCuffed")
								and (pos.Position - Vector3.new(5866, 30, -10227)).Magnitude > 200
							then
								return "cuffzone"
							end

							-- anticheat notifications: pause, recover, carry on from where we are
							local acType = checkAnticheatNotifications()
							-- while walking a path, a noclip flag means we left it: let walkTo back up
							-- and re-path (the notice lingers ~2s, so ignore repeats for 3s)
							if acType == "noclip" and ZQ5.straight then
								acType = nil -- going through walls on purpose: keep going
							elseif acType == "noclip" then
								if tick() < (ZQ5.acIgnoreUntil or 0) then
									acType = nil
								elseif not headInWorld() then
									-- the head is clear of walls / floors: the flag came from a mob
									-- overlapping us (chasers in the maze) or is a lingering notice.
									-- Stopping to back up and re-path just let the chaser catch up
									-- again, over and over. Keep walking.
									ZQ5.acIgnoreUntil = tick() + 3
									acType = nil
								else
									ZQ5.acIgnoreUntil = tick() + 3
									return "noclip"
								end
							end
							if acType then
								st.paused = true
								local cur = PlayerHumpart.Position
								local safeY = y or selected_Offset or cur.Y
								local safePos = Vector3.new(cur.X, safeY, cur.Z)
								task.wait(0.5)
								-- NO RISING on any anticheat flag: every lift (instant TP, then pad rise)
								-- climbed us up walls and earned Greater Flight Strikes (>15 over the floor).
								-- noclip is handled above (end the move, walkTo backs up and re-paths);
								-- tp/fly checks just pause.
								if acType == "tpcheck" or acType == "flycheck" then
									ValuesTable.shadowbanbypass = false
									task.wait(3)
									ValuesTable.shadowbanbypass = false
								elseif acType == "velocity" or acType == "grounded" then
									Facemouse()
								elseif acType == "threshold" then
									ValuesTable.shadowbanbypass = false
									MovementSystem:Unlock()
									st.paused = false
									return "threshold"
								end
								task.wait(0.5)
								stopblocking = false
								st.paused = false
							end

							Others.StopShadowBan = false
							ValuesTable.shadowbanbypass = false

							if not CanFarm then
								return "nofarm"
							end
							if not canTweenNow() then
								return "island"
							end
							if Character.Parent ~= workspace.PlayerCharacters then
								return "parent"
							end
							if RaiuiAnims then
								return "raiui"
							end

							if tweenconfigs.ThirdFloorNotificationPosition then
								local newPos = getNotificationPosition()
								if newPos and typeof(newPos) == "Vector3" then
									local newTargetCF = CFrame.new(newPos.X, y, newPos.Z)
									if (newTargetCF.Position - targetCF.Position).Magnitude > 5 then
										targetCF = newTargetCF
										downPos = CFrame.new(newPos)
										st.dest = newTargetCF.Position
										st.route = nil -- new target: stop following the old path
									end
								end
							end

							-- SpeedBypass can change mid-move: just pick the new speed up
							st.speed = effSpeed()

							-- stuck against a wall: give up this phase. No hop: hopping up (first an
							-- instant CFrame to 2600, then a 40-stud pad rise) is what kept climbing.
							if st.stuckT >= 1 then
								st.stuckT = 0
								return "stuck"
							end
							return nil
						end

					-- walk the ground like a player: pathfinding waypoints at standing height
					local reached, reason = ZQ5.walkTo(targetCF.Position, pollFn)

					if reason == "threshold" or reason == "inactive" then
						return false
					end

					local finalDist = (PlayerHumpart.Position - targetCF.Position).Magnitude
					if finalDist > 25 then
						return false
					end
					return true
				end


				local upYDiff = upPos and math.abs(PlayerHumpart.Position.Y - upPos.Position.Y) or 0
				if upPos and upYDiff > 10 then
					if tweenState and not tweenState.active then
						return
					end

					local acCheck = checkAnticheatNotifications()
					if acCheck == "threshold" then
						Others.TweenCd = false
						ValuesTable.shadowbanbypass = false
						MovementSystem:Unlock()
						return
					end

					if acCheck then
						repeat
							task.wait(0.1)
							acCheck = checkAnticheatNotifications()
						until not acCheck or acCheck == "threshold"
						if acCheck == "threshold" then
							Others.TweenCd = false
							ValuesTable.shadowbanbypass = false
							MovementSystem:Unlock()
							return
						end
					end
					Facemouse()
					task.wait(0.4)
					runPhase(upPos)
					task.wait(0.5)

					local yDiff = math.abs(PlayerHumpart.Position.Y - upPos.Position.Y)
					if yDiff > 50 then
						Facemouse()
						runPhase(upPos)
						task.wait(0.5)
						yDiff = math.abs(PlayerHumpart.Position.Y - upPos.Position.Y)
						if yDiff > 50 then
							Others.TweenCd = false
							ValuesTable.shadowbanbypass = false
							return
						end
					end
				end

				if midPos then
					if tweenState and not tweenState.active then
						return
					end

					local phaseSuccess = runPhase(midPos)

					if not phaseSuccess then
						Others.TweenCd = false
						ValuesTable.shadowbanbypass = false
						return
					end
				end
				local downYDiff = downPos and math.abs(PlayerHumpart.Position.Y - downPos.Position.Y) or 0
				if downPos and downYDiff > 10 then
					if tweenState and not tweenState.active then
						return
					end

					local acCheck = checkAnticheatNotifications()
					if acCheck == "threshold" then
						Others.TweenCd = false
						ValuesTable.shadowbanbypass = false
						MovementSystem:Unlock()
						return
					end

					if acCheck then
						repeat
							task.wait(0.1)
							acCheck = checkAnticheatNotifications()
						until not acCheck or acCheck == "threshold"
						if acCheck == "threshold" then
							Others.TweenCd = false
							ValuesTable.shadowbanbypass = false
							MovementSystem:Unlock()
							return
						end
					end

					-- CHECK: Did mid-phase actually reach the target X/Z?
					local currentPos = PlayerHumpart.Position
					local targetX = downPos.Position.X
					local targetZ = downPos.Position.Z
					local xzDistance = math.sqrt((currentPos.X - targetX) ^ 2 + (currentPos.Z - targetZ) ^ 2)

					if xzDistance > 15 then
						local currentY = currentPos.Y
						local correctXZatOffset = CFrame.new(targetX, currentY, targetZ)

						local xzPhaseSuccess = runPhase(correctXZatOffset)

						if not xzPhaseSuccess then
							Facemouse()
							task.wait(0.3)
							runPhase(correctXZatOffset)
							task.wait(0.5)
						end
					end

					Facemouse()
					task.wait(0.4)
					runPhase(downPos)
					task.wait(0.5)

					local yDiff = math.abs(PlayerHumpart.Position.Y - downPos.Position.Y)
					if yDiff > 50 then
						Facemouse()
						runPhase(downPos)
						task.wait(0.5)
						yDiff = math.abs(PlayerHumpart.Position.Y - downPos.Position.Y)
						if yDiff > 50 then
							Others.TweenCd = false
							ValuesTable.shadowbanbypass = false
							return
						end
					end
					task.wait(0.3)
				end
				Others.TweenCd = false
				ValuesTable.shadowbanbypass = false
			end)
		end

		if tweenconfigs.inspawn then
			local targetPos = typeof(pos) == "CFrame" and pos.Position or pos

			if MovementSystem.inSpawnTween and MovementSystem.inSpawnTween.active and MovementSystem.inSpawnTarget then
				local distanceToCurrentTarget = (targetPos - MovementSystem.inSpawnTarget).Magnitude
				if distanceToCurrentTarget < 10 then
					return
				end
			end

			MovementSystem:CancelInSpawn()

			local tweenState = { active = true }
			MovementSystem.inSpawnTween = tweenState
			MovementSystem.inSpawnTarget = targetPos
			MovementSystem.tweenState = tweenState

			task.spawn(function()
				executeTween(tweenState)
				if MovementSystem.inSpawnTarget == targetPos then
					MovementSystem.inSpawnTarget = nil
				end
			end)

			return
		end

		MovementSystem:CancelInSpawn()

		local tweenState = { active = true }
		MovementSystem.tweenState = tweenState
		executeTween(tweenState)
	end

	--==========================================================================
	-- QUEST5 COMBAT (replaces the old m1Attack / m1AttackSimple bodies)
	--
	-- Kept from Zephyron: equipattacktool (weapon equip), Buso (haki), the trap
	-- safety (isUnderTrap / findSafePositionFromTrap), the ragdoll timer and the
	-- per-boss hover offsets that controlTower passes in.
	--
	-- Taken from quest5:
	--   * the m1 loop on its own clock: every HIT_WAIT it takes EVERY live NPC in
	--     range, nearest first, sends "swingsfx", then ONE "damage" call naming all
	--     of them, combo Punch1-4 (Combo5 mode optional)
	--   * fake m1 on block (swing alone, no damage, retry after FEINT_RETRY)
	--   * m1 back and forth: alternate the damage CFrame side so knockback cancels
	--   * the hover engine: BodyVelocity hover over the target, proportional speed
	--   * GATHER / FIGHT aggro: tour the mobs, count one as pulled when its health
	--     drops (or after TOUR_WAIT hovering). NO fixed MaxAggro: every live NPC
	--     within AggroRadius of the target is pulled.
	--
	-- m1Attack() is now a "lease": controlTower calls it every loop while the
	-- target is close, each call renews the lease; when the calls stop (target
	-- dead / out of range / floor change) the hover and the swings stop by
	-- themselves after LEASE seconds.
	--
	-- Tunables (all optional): getgenv().ZephyronCombat = { HitWait = 0.4,
	-- Mode = "Tensen" | "Combo5", AggroRadius = 150, Tour = true, TourWait = 1.5,
	-- AggroTimeout = 12, FeintOnBlock = true, FeintRetry = 5, Shuffle = true,
	-- HoverSpeed = 45 }
	--==========================================================================
	do
		local RS = game:GetService("ReplicatedStorage")
		local RunSvc = game:GetService("RunService")

		getgenv().ZephyronCombat = getgenv().ZephyronCombat or {}
		local CFG = getgenv().ZephyronCombat
		local HIT_WAIT = CFG.HitWait or 0.4
		local FEINT_ON_BLOCK = CFG.FeintOnBlock ~= false
		local FEINT_RETRY = CFG.FeintRetry or 5
		local SHUFFLE_ON = CFG.Shuffle ~= false
		local COMBO5 = CFG.Mode == "Combo5"
		local COMBO_MAX = COMBO5 and 5 or 4
		local COMBO5_HIT_WAIT = CFG.Combo5HitWait or 0.07
		local COMBO5_FINISHER_WAIT = CFG.Combo5FinisherWait or 1.5
		local AGGRO_RADIUS = CFG.AggroRadius or 150
		local TOUR_ENABLED = CFG.Tour ~= false
		local TOUR_WAIT = CFG.TourWait or 1.5
		local AGGRO_TIMEOUT = CFG.AggroTimeout or 12
		local BASE_SPEED = CFG.HoverSpeed or 45
		local ARRIVE_THRESHOLD = 2.5
		local LEASE = 1.5

		ZQ5 = ZQ5 or {}
		ZQ5.enemy = nil
		ZQ5.offset = Vector3.new(0, 9, 0)
		ZQ5.radius = 15
		ZQ5.attack = false
		ZQ5.hover = false
		ZQ5.lease = 0
		ZQ5.m1type = "Melee"
		ZQ5.hoverMob = nil
		ZQ5.fight = false
		ZQ5.lastEquip = 0

		local aggro = {} -- every mob pulled so far, pull order
		local skipUntil = setmetatable({}, { __mode = "k" })
		local knock = { axis = nil, axisFor = nil, sign = 1 }
		local facingDir = nil

		local MELEE_COMBO = {
			{ anim = "Punch1", index = 1 },
			{ anim = "Punch2", index = 2 },
			{ anim = "Punch3", index = 3 },
			{ anim = "GroundPunch4", index = 4 },
			{ anim = "Punch5", index = 5 },
		}

		local function leaseActive()
			return ZQ5.enemy ~= nil
				and tick() - ZQ5.lease < LEASE
				and CanFarm
				and Character ~= nil
				and PlayerHumpart ~= nil
				and PlayerHumpart.Parent ~= nil
		end

		local function isValidMob(npc)
			if not npc or not npc.Parent or not npc:IsA("Model") then
				return false
			end
			local hum = npc:FindFirstChildOfClass("Humanoid")
			return hum ~= nil and hum.Health > 0 and npc:FindFirstChild("HumanoidRootPart") ~= nil
		end

		local function inAggro(npc)
			for _, m in ipairs(aggro) do
				if m == npc then
					return true
				end
			end
			return false
		end

		local function combatRange()
			return math.max(ZQ5.radius or 0, ZQ5.offset.Magnitude + 6, 15)
		end

		-- the point the hover engine sits at for one mob: the per-boss offset in the
		-- mob's own space (controlTower's offsets), with Zephyron's trap safety
		local function hoverPointFor(model)
			local r = model.HumanoidRootPart
			local o = ZQ5.offset
			-- yaw-only: a tilted / ragdolled / animated HRP must not turn the +Y offset sideways
			local look = r.CFrame.LookVector
			local yaw = math.atan2(-look.X, -look.Z)
			local p = (CFrame.new(r.Position) * CFrame.Angles(0, yaw, 0) * CFrame.new(o.X, o.Y, o.Z)).Position
			if isUnderTrap(p, 10) then
				p = findSafePositionFromTrap(p) or p
			end
			if p.Y > 2435 and currentTargetPosition == Vector3.new(5654.6669921875, 2481.71728515625, -20514.548828125) then
				p = r.Position + Vector3.new(0, 8, 0)
			end
			if p.X ~= p.X or p.Y ~= p.Y or p.Z ~= p.Z then
				p = r.Position + Vector3.new(0, 8, 0)
			end
			return p
		end

		-- HumanoidRootParts of every live NPC within `distance`, nearest first
		local function targetsInRange(distance)
			local parts = {}
			local folder = workspace:FindFirstChild("NPCs")
			local root = PlayerHumpart
			if not (folder and root) then
				return parts
			end
			for _, npc in ipairs(folder:GetChildren()) do
				if isValidMob(npc) then
					local r = npc.HumanoidRootPart
					if (r.Position - root.Position).Magnitude <= distance then
						table.insert(parts, r)
					end
				end
			end
			if #parts > 1 then
				local origin = root.Position
				table.sort(parts, function(a, b)
					return (a.Position - origin).Magnitude < (b.Position - origin).Magnitude
				end)
			end
			return parts
		end

		-- the next mob to pull: nearest to us, inside AggroRadius of the target, not pulled yet
		local function nextCandidate(primary)
			local folder = workspace:FindFirstChild("NPCs")
			if not (folder and PlayerHumpart) then
				return nil
			end
			local origin = isValidMob(primary) and primary.HumanoidRootPart.Position or PlayerHumpart.Position
			local best, bestDist = nil, math.huge
			for _, npc in ipairs(folder:GetChildren()) do
				-- only mobs near and in plain sight: the pad flies a straight line, and touring
				-- to a mob 150 studs away went straight through walls and floors
				if isValidMob(npc) and not inAggro(npc) and not (skipUntil[npc] and tick() < skipUntil[npc]) and mobInReach(npc) then
					local r = npc.HumanoidRootPart
					if (r.Position - origin).Magnitude <= AGGRO_RADIUS then
						local d = (r.Position - PlayerHumpart.Position).Magnitude
						if d < bestDist then
							best, bestDist = npc, d
						end
					end
				end
			end
			return best
		end

		-- blocking detection (quest5 / Tensen)
		local function isNPCBlocking(model)
			if not model or not model.Parent then
				return false
			end
			if model:FindFirstChild("Blocking") or model:FindFirstChild("Block") then
				return true
			end
			local ok, result = pcall(function()
				return model:GetAttribute("Blocking")
			end)
			return ok and result == true
		end

		local BLOCK_ANIM_IDS = {
			["15374683054"] = "Big Mama Block",
			["95593858663705"] = "Mochi Trident Block (Katakuri)",
			["13243427337"] = "Mochi fruit Block",
		}
		local function targetBlocking(model)
			if not (model and model.Parent) then
				return false
			end
			if isNPCBlocking(model) then
				return true, "a Blocking flag"
			end
			local ok, attr = pcall(function()
				return model:GetAttribute("IsBlocking")
			end)
			if ok and attr == true then
				return true, "IsBlocking"
			end
			local humanoid = model:FindFirstChildOfClass("Humanoid")
			local animator = humanoid and humanoid:FindFirstChildOfClass("Animator")
			if animator then
				local blockAnim = nil
				pcall(function()
					for _, track in ipairs(animator:GetPlayingAnimationTracks()) do
						local animation = track.Animation
						local id = animation and string.match(tostring(animation.AnimationId), "%d+")
						if id and BLOCK_ANIM_IDS[id] then
							blockAnim = BLOCK_ANIM_IDS[id]
							return
						end
						if animation and string.find(string.lower(animation.Name or ""), "block", 1, true) then
							blockAnim = animation.Name
							return
						end
					end
				end)
				if blockAnim then
					return true, "the " .. tostring(blockAnim) .. " animation"
				end
			end
			return false
		end

		-- fake m1 on block: swing alone, no damage, retry after FEINT_RETRY
		local feintState = setmetatable({}, { __mode = "k" })
		local function farmFeint(part, index, animation, m1type)
			if not FEINT_ON_BLOCK then
				return false
			end
			local model = part and part.Parent
			if not model then
				return false
			end
			-- Vera (and bosses) block almost constantly; feinting on every block meant a
			-- fake swing every 5s and no damage at all, so always swing for real
			if string.find(model.Name, "Vera", 1, true) or model:GetAttribute("HPScaled") then
				feintState[model] = nil
				return false
			end
			local blocking = targetBlocking(model)
			if not blocking then
				feintState[model] = nil
				return false
			end
			local last = feintState[model]
			if last and tick() - last.at < FEINT_RETRY then
				return true
			end
			pcall(function()
				RS.Events.CombatRegister:InvokeServer({ "swingsfx", m1type, index, "Ground", false, animation, 2, 1.5 })
			end)
			feintState[model] = { at = tick(), since = last and last.since or tick() }
			return true
		end

		local function pickAttackTarget(list)
			for _, part in ipairs(list) do
				if part and part.Parent then
					local boss = string.find(part.Parent.Name, "Vera", 1, true) or part.Parent:GetAttribute("HPScaled")
					if FEINT_ON_BLOCK or boss or not targetBlocking(part.Parent) then
						return part
					end
				end
			end
			return nil
		end

		-- damage CFrame: 5 studs back from the target along the line from us, looking
		-- at it; while fighting, alternate sides of one fixed flat line (back and forth)
		local function damageCFrame(target, root)
			if not (SHUFFLE_ON and ZQ5.fight) then
				facingDir = nil
				local offset = target.Position - root.Position
				if offset.Magnitude == 0 then
					offset = root.CFrame.LookVector
				end
				return CFrame.new(target.Position - offset.Unit * 5 + Vector3.new(0, 1, 0), target.Position)
			end
			if knock.axisFor ~= target or not knock.axis then
				local flat = Vector3.new(root.Position.X - target.Position.X, 0, root.Position.Z - target.Position.Z)
				if flat.Magnitude < 0.5 then
					local lv = root.CFrame.LookVector
					flat = Vector3.new(-lv.X, 0, -lv.Z)
				end
				knock.axis = flat.Magnitude > 0.01 and flat.Unit or Vector3.new(0, 0, 1)
				knock.axisFor = target
			end
			local from = target.Position + knock.axis * (knock.sign * 5) + Vector3.new(0, 1, 0)
			facingDir = -knock.axis * knock.sign
			knock.sign = -knock.sign
			return CFrame.new(from, target.Position)
		end

		local function waitAfter(stepIndex)
			if not COMBO5 then
				return HIT_WAIT
			end
			return stepIndex >= 5 and COMBO5_FINISHER_WAIT or COMBO5_HIT_WAIT
		end

		-- M1 LOOP (own clock)
		task.spawn(function()
			local combo, lastSwing, lastErr, wait_ = 1, 0, 0, HIT_WAIT
			while true do
				task.wait()
				local ok, err = pcall(function()
					if not leaseActive() or not ZQ5.attack or ZQ5.moving then
						combo = 1
						return
					end
					if Character:FindFirstChild("Stun") or RaiuiAnims then
						return
					end
					if not Character:FindFirstChildOfClass("Tool") then
						return
					end
					if tick() - lastSwing < wait_ then
						return
					end
					if checkAnticheatNotifications() then
						return
					end

					local root = PlayerHumpart
					local targets = targetsInRange(combatRange())
					if #targets == 0 then
						combo = 1
						return
					end
					local target = pickAttackTarget(targets)
					if not target then
						return
					end

					local m1type = ZQ5.m1type or "Melee"
					local step = MELEE_COMBO[combo]
					local animFolder = RS:FindFirstChild("CombatAnimations")
					local meleeFolder = animFolder and animFolder:FindFirstChild("Melee")
					local animName = (m1type == "Melee") and step.anim or "Punch1"
					local animation = meleeFolder and meleeFolder:FindFirstChild(animName)

					if farmFeint(target, step.index, animation, m1type) then
						lastSwing = tick()
						wait_ = HIT_WAIT
						return
					end

					local events = RS:FindFirstChild("Events")
					local remote = events and events:FindFirstChild("CombatRegister")
					if not remote then
						return
					end
					remote:InvokeServer({ "swingsfx", m1type, step.index, "Ground", false, animation, 2, 1.5 })
					remote:InvokeServer({
						"damage",
						targets,
						m1type,
						{ step.index, "Ground", m1type },
						true,
						damageCFrame(target, root),
						aircombo = "Ground",
					})
					lastSwing = tick()
					wait_ = waitAfter(step.index)
					combo = combo + 1
					if combo > COMBO_MAX then
						combo = 1
					end
				end)
				if not ok and os.clock() - lastErr > 10 then
					lastErr = os.clock()
					print("[Zephyron] m1 step failed: " .. tostring(err))
				end
			end
		end)

		-- AGGRO CONTROLLER: decides which mob the hover sits on
		task.spawn(function()
			local phase = "FIGHT"
			local tourMob, tourStart, tourArrived, tourHp = nil, 0, nil, nil
			local lastRestock = 0
			while true do
				task.wait()
				pcall(function()
					if not leaseActive() then
						aggro = {}
						ZQ5.hoverMob, ZQ5.fight = nil, false
						tourMob = nil
						phase = "GATHER"
						return
					end

					for i = #aggro, 1, -1 do
						if not isValidMob(aggro[i]) then
							table.remove(aggro, i)
						end
					end

					local primary = ZQ5.enemy
					if isValidMob(primary) and not inAggro(primary) then
						table.insert(aggro, 1, primary)
					end

					-- touring is for packs: bosses (HPScaled) are fought alone, and so is
					-- anything when the attack is switched off (hide-above mode)
					local canTour = TOUR_ENABLED
						and ZQ5.hover
						and ZQ5.attack
						and isValidMob(primary)
						and not primary:GetAttribute("HPScaled")
						and not string.find(primary.Name, "Vera", 1, true)

					if phase == "GATHER" and not canTour then
						phase = "FIGHT"
					end

					if phase == "GATHER" then
						ZQ5.fight = false
						if not (tourMob and isValidMob(tourMob) and not inAggro(tourMob)) then
							tourMob = nextCandidate(primary)
							tourStart, tourArrived = tick(), nil
							local h = tourMob and tourMob:FindFirstChildOfClass("Humanoid")
							tourHp = h and h.Health
						end
						if tourMob then
							ZQ5.hoverMob = tourMob
							local h = tourMob:FindFirstChildOfClass("Humanoid")
							local landed = h and tourHp and h.Health < tourHp
							local arrived = (hoverPointFor(tourMob) - PlayerHumpart.Position).Magnitude
								<= ARRIVE_THRESHOLD + 1
							if arrived and not tourArrived then
								tourArrived = tick()
							end
							if landed or (tourArrived and tick() - tourArrived > TOUR_WAIT) then
								table.insert(aggro, tourMob)
								tourMob, tourArrived, tourHp = nil, nil, nil
							elseif not arrived and tick() - tourStart > AGGRO_TIMEOUT then
								skipUntil[tourMob] = tick() + 10 -- unreachable: leave it for now
								tourMob = nil
							end
						else
							phase = "FIGHT" -- nothing fresh left
						end
					else
						if canTour and tick() - lastRestock >= 1 then
							lastRestock = tick()
							if nextCandidate(primary) then
								phase = "GATHER"
								return
							end
						end
						local victim = nil
						if isValidMob(primary) then
							victim = primary
						else
							for _, m in ipairs(aggro) do
								if isValidMob(m) then
									victim = m
									break
								end
							end
						end
						ZQ5.hoverMob = victim
						ZQ5.fight = victim ~= nil
					end
				end)
			end
		end)

		-- HOVER ENGINE, pad style (BossRotation hoverStep): an anchored, invisible, CanCollide pad
		-- walks toward the point under the hover spot at HOVER_PAD_SPEED and the root is pinned on
		-- top of it every frame. Standing on the pad reads as grounded (no flight strikes), and it
		-- does not depend on a BodyVelocity winning against the humanoid -- the old BodyVelocity
		-- hover pushed up at 15-40 studs/s and still sat at ground height on tutorial Vera.
		local HOVER_PAD_SPEED, HOVER_PAD_STAND = 30, 4
		local HOVER_CLIMB_SPEED = 14 -- max studs/s up
		-- Elo's slam has a big hitbox: slide this far to the side (at hover height) and back
		local ELO_DODGE_DIST, ELO_DODGE_UP, ELO_DODGE_SPEED = 55, 10, 55
		local function hoverPadStop()
			if ZQ5.hoverPad and ZQ5.hoverPad.Parent then
				ZQ5.hoverPad:Destroy()
			end
			ZQ5.hoverPad = nil
		end
		-- when the hover ends in the air, ride the pad DOWN to the ground before removing it
		-- (BossRotation hoverLand): dropping unsupported earns Greater Flight Strikes
		local function hoverPadLandStep(hrp, dt)
			local pad = ZQ5.hoverPad
			if not (pad and pad.Parent) then
				return
			end
			if ZQ5.moving or not hrp or not hrp.Parent then
				hoverPadStop()
				return
			end
			-- the game moved us (floor change): never pin the body back onto the old pad
			if (hrp.Position - (pad.Position + Vector3.new(0, HOVER_PAD_STAND, 0))).Magnitude > 40 then
				hoverPadStop()
				return
			end
			local params = RaycastParams.new()
			params.FilterType = Enum.RaycastFilterType.Exclude
			params.FilterDescendantsInstances = { pad, Character, workspace:FindFirstChild("NPCs"), workspace:FindFirstChild("Effects") }
			pcall(function()
				params.RespectCanCollide = true
			end)
			local hit = workspace:Raycast(pad.Position, Vector3.new(0, -500, 0), params)
			if not hit or pad.Position.Y - hit.Position.Y <= 1 then
				hoverPadStop()
				return
			end
			local down = math.min(HOVER_PAD_SPEED * (dt or 1 / 60), pad.Position.Y - hit.Position.Y - 0.5)
			pad.Position = pad.Position - Vector3.new(0, down, 0)
			hrp.CFrame = CFrame.new(pad.Position + Vector3.new(0, HOVER_PAD_STAND, 0)) * (hrp.CFrame - hrp.CFrame.Position)
		end

		RunSvc.Heartbeat:Connect(function(dt)
			pcall(function()
				local hrp = PlayerHumpart
				local active = leaseActive()
					and ZQ5.hover
					and not ZQ5.moving
					and not RaiuiAnims
					and not MovementSystem:IsLocked()
				if not active or not hrp or not hrp.Parent then
					ZQ5.hoverActive = false
					ZQ5.lastPin = nil
					hoverPadLandStep(hrp, dt)
					return
				end

				-- the GAME moved us far from where we pinned (beaten boss -> next floor): drop the
				-- hover and the lease instead of pinning the body back into the old room
				if ZQ5.lastPin and (hrp.Position - ZQ5.lastPin).Magnitude > 40 then
					print("[HOVER] external teleport detected, releasing the hover")
					ZQ5.lastPin = nil
					ZQ5.lease = 0
					ZQ5.enemy = nil
					ZQ5.hover = false
					ZQ5.hoverActive = false
					hoverPadStop()
					return
				end

				local mob = ZQ5.hoverMob
				local mhrp = mob and isValidMob(mob) and mob.HumanoidRootPart
				if not mhrp then
					-- no hover target this frame (dead / not picked yet): land and let go, but do
					-- NOT clear the lease -- the aggro controller picks hoverMob a frame after
					-- m1Attack starts the lease, and clearing it here meant the hover never began
					ZQ5.lastPin = nil
					ZQ5.hoverActive = false
					hoverPadLandStep(hrp, dt)
					return
				end

				ZQ5.hoverActive = true
				-- the pad carries us: any BodyMover (the game's knockback, old hover movers,
				-- the idle BodyVelocity) only fights the pin
				for _, mover in ipairs(hrp:GetChildren()) do
					if mover:IsA("BodyMover") then
						mover:Destroy()
					end
				end

				local pad = ZQ5.hoverPad
				if not (pad and pad.Parent) then
					pad = Instance.new("Part")
					pad.Name = "pad"
					pad.Size = Vector3.new(24, 1, 24)
					pad.Anchored = true
					pad.CanCollide = true
					pad.Transparency = 1
					pad.Position = hrp.Position - Vector3.new(0, HOVER_PAD_STAND, 0)
					pad.Parent = workspace
					ZQ5.hoverPad = pad
				end

				local standAt = pad.Position + Vector3.new(0, HOVER_PAD_STAND, 0)

				-- HIT (Elo's slam, any knock): never snap the body back up to the pad. The snap is
				-- an instant rise and earned "Y+ too fast" strikes. While knocked (ragdolled, or the
				-- body pushed off the pin), move the pad under the body where it is and climb back
				-- slowly afterwards.
				local myHum = Character and Character:FindFirstChildOfClass("Humanoid")
				local knocked = false -- (no ragdoll handling: the old build only deleted Ragdoll_Client)
				-- only a SIDEWAYS shove is a hit. A drop straight down is gravity in a long frame
				-- (low FPS, background window): re-seating the pad there let us sink frame by
				-- frame into the floor. Just pin back.
				local off = hrp.Position - standAt
				local sideways = Vector3.new(off.X, 0, off.Z).Magnitude
				if knocked or (sideways > 2 and off.Magnitude > 3) then
					pad.Position = hrp.Position - Vector3.new(0, HOVER_PAD_STAND, 0)
					ZQ5.lastPin = hrp.Position
					ZQ5.hitAt = tick()
					if knocked then
						return -- leave the body to the hit; re-seat again next frame
					end
					standAt = hrp.Position
				end

				-- aim where a running mob WILL be (0.3s ahead, flat), so the pad keeps up with
				-- fleeing / kiting mobs instead of trailing behind them
				local mv = mhrp.AssemblyLinearVelocity
				local lead = Vector3.new(mv.X, 0, mv.Z) * 0.3
				if lead.Magnitude > 12 then
					lead = lead.Unit * 12
				end
				local targetPos = hoverPointFor(mob) + lead
				local padSpeed = HOVER_PAD_SPEED

				-- ELO'S SLAM: slide far out to the side at hover height (no going up), then back
				local dodging = ZQ5.dodgeMob == mob and tick() < (ZQ5.dodgeUntil or 0)
				if dodging then
					if not ZQ5.dodgeDir then
						local base = Vector3.new(standAt.X - mhrp.Position.X, 0, standAt.Z - mhrp.Position.Z)
						if base.Magnitude < 1 then
							local lv = mhrp.CFrame.LookVector
							base = Vector3.new(-lv.X, 0, -lv.Z)
						end
						base = base.Unit
						local dp = RaycastParams.new()
						dp.FilterType = Enum.RaycastFilterType.Exclude
						dp.FilterDescendantsInstances = { Character, workspace:FindFirstChild("NPCs"), workspace:FindFirstChild("Effects") }
						pcall(function()
							dp.RespectCanCollide = true
						end)
						-- the first direction with a clear run (no wall) out to the dodge distance
						local from = mhrp.Position + Vector3.new(0, ELO_DODGE_UP, 0)
						for _, a in ipairs({ 0, 45, -45, 90, -90, 135, -135, 180 }) do
							local d = CFrame.Angles(0, math.rad(a), 0) * base
							if not workspace:Raycast(from, d * (ELO_DODGE_DIST + 3), dp) then
								ZQ5.dodgeDir = d
								break
							end
						end
						ZQ5.dodgeDir = ZQ5.dodgeDir or base
					end
					targetPos = mhrp.Position + ZQ5.dodgeDir * ELO_DODGE_DIST + Vector3.new(0, ELO_DODGE_UP, 0)
					padSpeed = ELO_DODGE_SPEED
				else
					ZQ5.dodgeDir = nil
				end

				local goal = targetPos - Vector3.new(0, HOVER_PAD_STAND, 0)
				local toGoal = goal - pad.Position
				if toGoal.Magnitude > 0.05 then
					local step = toGoal.Unit * math.min(padSpeed * (dt or 1 / 60), toGoal.Magnitude)
					-- climb slowly (fast rises earn "Y+ too fast"), slower still right after a hit
					local maxUp = (tick() - (ZQ5.hitAt or 0) < 2 and 6 or HOVER_CLIMB_SPEED)
						* (dt or 1 / 60)
					if step.Y > maxUp then
						step = Vector3.new(step.X, maxUp, step.Z)
					end
					-- never carry the body through a wall / floor (noclip + tp flags): if the body or
					-- head line of this step hits geometry, hold here this frame
					local rp = RaycastParams.new()
					rp.FilterType = Enum.RaycastFilterType.Exclude
					rp.FilterDescendantsInstances = {
						pad,
						Character,
						workspace:FindFirstChild("NPCs"),
						workspace:FindFirstChild("Effects"),
						workspace:FindFirstChild("PlayerCharacters"),
					}
					pcall(function()
						rp.RespectCanCollide = true
					end)
					local from = pad.Position + Vector3.new(0, HOVER_PAD_STAND, 0)
					local probe = step.Magnitude > 1e-3 and (step + step.Unit * 1.5) or Vector3.new(0, 0, 0)
					local blocked = probe.Magnitude > 0
						and (workspace:Raycast(from, probe, rp) or workspace:Raycast(from + Vector3.new(0, 1.5, 0), probe, rp))
					if not blocked then
						pad.Position = pad.Position + step
						ZQ5.padBlockedSince = nil
					else
						-- held against geometry too long: let the walker path to this mob instead
						ZQ5.padBlockedSince = ZQ5.padBlockedSince or tick()
						if tick() - ZQ5.padBlockedSince > 1.5 then
							ZQ5.padBlockedSince = nil
							ZQ5.noHoverMob, ZQ5.noHoverUntil = mob, tick() + 6
							print("[HOVER] path to " .. mob.Name .. " blocked, walking to it instead")
						end
					end
				end
				standAt = pad.Position + Vector3.new(0, HOVER_PAD_STAND, 0)

				ZQ5.lastPin = standAt
				hrp.AssemblyLinearVelocity = Vector3.zero
				if ZQ5.fight and facingDir and (targetPos - standAt).Magnitude <= ARRIVE_THRESHOLD then
					hrp.CFrame = CFrame.lookAt(standAt, standAt + facingDir)
				else
					local look = Vector3.new(mhrp.Position.X, standAt.Y, mhrp.Position.Z)
					if (look - standAt).Magnitude > 0.1 then
						hrp.CFrame = CFrame.lookAt(standAt, look)
					else
						hrp.CFrame = CFrame.new(standAt) * (hrp.CFrame - hrp.CFrame.Position)
					end
				end
			end)
		end)

		-- weapon + haki upkeep, throttled (controlTower calls m1Attack every frame)
		local function upkeep()
			if tick() - ZQ5.lastEquip < 0.25 then
				return
			end
			ZQ5.lastEquip = tick()
			ZQ5.m1type = equipattacktool()
			Buso(true)
		end

		-- m1Attack keeps its signature: (enemy, safeHeightOffset, attackRadius, offset3D, Type)
		-- offset3D is the hover offset in the enemy's space; attackRadius <= 0 means
		-- "hover only, do not swing" (the low-health hide-above call).
		function m1Attack(enemy, safeHeightOffset, attackRadius, offset3D, Type)
			attackRadius = attackRadius or 30
			offset3D = offset3D or Vector3.new(0, 5, 0)

			if not enemy or not enemy:FindFirstChild("HumanoidRootPart") then
				return false
			end
			local function why(reason)
				if string.find(enemy.Name, "Vera", 1, true) and tick() - (ZQ5.lastWhy or 0) > 2 then
					ZQ5.lastWhy = tick()
					print("[m1Attack] refused on " .. enemy.Name .. ": " .. reason)
				end
				return false
			end
			if MovementSystem:IsLocked() or EloAnims then
				return why("movement locked / elo anim")
			end
			local enemyHumanoid = enemy:FindFirstChild("Humanoid")
			if not enemyHumanoid or enemyHumanoid.Health <= 0 then
				return why("no humanoid / dead")
			end
			if not Character or not PlayerHumpart or not CanFarm then
				return why("no character / CanFarm off")
			end

			upkeep()

			-- ragdolled for more than 4s: sit right on it
			local enemyId = enemy.Name .. tostring(enemy:GetDebugId())
			if isRagdolled(enemy) then
				if not ragdollTimers[enemyId] then
					ragdollTimers[enemyId] = tick()
				end
				if tick() - ragdollTimers[enemyId] > 4 then
					offset3D = Vector3.new(0, 0, 0)
				end
			else
				ragdollTimers[enemyId] = nil
			end

			if isUnderTrap(PlayerHumpart.Position, 15) then
				local safePos = findSafePositionFromTrap(PlayerHumpart.Position)
				tweenWithTeleport(safePos, Speed)
				task.wait(0.5)
				return why("under a FallingTrap hitbox, moved to safe position")
			end

			MovementSystem:CancelInSpawn()

			-- an anticheat notice used to block here until it cleared. Floating after a walk
			-- earns a flight-strike notice that never clears while floating -> no hover, ever.
			-- The pad hover is grounded, so just engage.

			ZQ5.enemy = enemy
			ZQ5.offset = offset3D
			ZQ5.radius = attackRadius
			ZQ5.attack = attackRadius > 0
			ZQ5.hover = true
			ZQ5.lease = tick()
			return true
		end

		-- m1AttackSimple: swing only, no hover (Kramprus); only inside attackRadius
		function m1AttackSimple(enemy, attackRadius)
			attackRadius = attackRadius or 30
			if not enemy or not enemy:FindFirstChild("HumanoidRootPart") then
				return false
			end
			local enemyHumanoid = enemy:FindFirstChild("Humanoid")
			if not enemyHumanoid or enemyHumanoid.Health <= 0 then
				return false
			end
			if not Character or not PlayerHumpart or not CanFarm then
				return false
			end
			if (PlayerHumpart.Position - enemy.HumanoidRootPart.Position).Magnitude > attackRadius then
				return false
			end

			upkeep()

			if isUnderTrap(PlayerHumpart.Position, 15) then
				local safePos = findSafePositionFromTrap(PlayerHumpart.Position)
				tweenWithTeleport(safePos, Speed)
				task.wait(0.5)
				return false
			end

			ZQ5.enemy = enemy
			ZQ5.offset = Vector3.zero
			ZQ5.radius = attackRadius
			ZQ5.attack = true
			ZQ5.hover = false
			ZQ5.lease = tick()
			return true
		end
	end


	local Players = game:GetService("Players")
	local RunService = game:GetService("RunService")
	local ReplicatedStorage = game:GetService("ReplicatedStorage")

	local isGliding = false

	function Facemouse()
		for i = 1, 2 do
			task.wait(0.1)
			local args = {
				false,
			}
			game:GetService("ReplicatedStorage")
				:WaitForChild("Events")
				:WaitForChild("faceMouse")
				:FireServer(unpack(args))
		end
	end

	task.spawn(function()
		while true do
			local nearGround = false
			pcall(function()
				if PlayerHumpart then
					local rayParams = RaycastParams.new()
					rayParams.FilterType = Enum.RaycastFilterType.Blacklist
					rayParams.FilterDescendantsInstances = { Character, workspace:FindFirstChild("Effects") }
					local rayResult = workspace:Raycast(PlayerHumpart.Position, Vector3.new(0, -15, 0), rayParams)
					if rayResult then
						nearGround = true
					end
				end
			end)

			local hum = Character and Character:FindFirstChild("Humanoid")
			if
				hum
				and hum.FloorMaterial == Enum.Material.Air
				and Services.ReplicatedStorage:FindFirstChild("Stats" .. player.Name).Stamina.Value > 50
			then
				local args = { 1, "dash" }
				game:GetService("ReplicatedStorage")
					:WaitForChild("Events")
					:WaitForChild("takestam")
					:FireServer(unpack(args))
			elseif
				hum
				and hum.FloorMaterial == Enum.Material.Air
				and Services.ReplicatedStorage:FindFirstChild("Stats" .. player.Name).Stamina.Value < 50
				and not nearGround
			then
				Facemouse()
			end
			task.wait(1.4)
		end
	end)
	local bv
	spawn(function()
		while task.wait(0.5) do
			pcall(function()
				if ZQ5 and (ZQ5.hoverActive or ZQ5.moving or ZQ5.rescuing) then
					local staleBv = PlayerHumpart:FindFirstChild("BodyVelocity")
					if staleBv then
						staleBv:Destroy()
					end
				elseif not PlayerHumpart:FindFirstChild("BodyVelocity") then
					bv = Instance.new("BodyVelocity")
					bv.MaxForce = Vector3.new(9e9, 9e9, 9e9)
					bv.P = 5000
					bv.Velocity = Vector3.new(0, 0, 0)
					bv.Parent = PlayerHumpart
				end
				if player.PlayerScripts.Ragdolls:FindFirstChild("Ragdoll_Client") then
					player.PlayerScripts.Ragdolls.Ragdoll_Client:Destroy()
				end
			end)
		end
	end)

	local SkillCooldowns = {}
	local LaserPulsarChargedAt = 0
	local LaserPulsarLastRelease = 0

	do
		local changedWalkspeed = false
		local humanoid = Character:WaitForChild("Humanoid")
		local hrp = PlayerHumpart
		local GuiUnloaded = false

		local function tapKey(keyCode, downTime)
			local vim = Instance.new("VirtualInputManager")
			vim:SendKeyEvent(true, keyCode, false, game)
			task.wait(downTime or 0.1)
			vim:SendKeyEvent(false, keyCode, false, game)
			vim:Destroy()
		end

		local function stopShadowBanBypass()
			if not changedWalkspeed and humanoid and humanoid.WalkSpeed == 0 then
				changedWalkspeed = true
				humanoid.WalkSpeed = 16
			end
			task.wait()
		end

		task.spawn(function()
			local keys = {
				Enum.KeyCode.W,
				Enum.KeyCode.A,
				Enum.KeyCode.S,
				Enum.KeyCode.D,
			}
			while true do
				if not ValuesTable.shadowbanbypass or Others.StopShadowBan or not Character or not PlayerHumpart then
					stopShadowBanBypass()
					task.wait()
					continue
				end
				pcall(function()
					for _, key in ipairs(keys) do
						if not ValuesTable.shadowbanbypass then
							break
						end
						tapKey(key, 0.08)
						task.wait(0.05)
					end
				end)
				task.wait(0.2)
			end
		end)

		task.spawn(function()
			while task.wait() do
				if not ValuesTable.shadowbanbypass or Others.StopShadowBan or not Character or not PlayerHumpart then
					stopShadowBanBypass()
					continue
				end
				changedWalkspeed = false
				humanoid.WalkSpeed = 0
			end
		end)
	end

	local trackedNotification = nil
	local lastReturnedPosition = nil
	local lastCalculatedPosition = nil
	local lastCalculationTime = 0
	local CALCULATION_COOLDOWN = 0.5

	function getNotificationPosition(value)
		local now = tick()
		if now - lastCalculationTime < CALCULATION_COOLDOWN and lastCalculatedPosition then
			return lastCalculatedPosition
		end

		lastCalculationTime = now

		if trackedNotification and trackedNotification.Parent then
			local pos = trackedNotification.WorldPosition
			if (pos - Vector3.new(4932.1904296875, 2380.0673828125, -20928.67578125)).Magnitude < 5 then
				local finalPos = Vector3.new(4983.416015625, 2306.330078125, -20861.43359375)

				if value and (not lastReturnedPosition or (lastReturnedPosition - finalPos).Magnitude > 5) then
					lastReturnedPosition = finalPos
					task.wait(2)
				end

				lastCalculatedPosition = finalPos
				return finalPos
			end

			if value and (not lastReturnedPosition or (lastReturnedPosition - pos).Magnitude > 5) then
				lastReturnedPosition = pos
				task.wait(2)
			end

			lastCalculatedPosition = pos
			return pos
		end

		local allNotifications = {}
		for _, descendant in pairs(workspace:GetDescendants()) do
			if descendant:IsA("Sound") and descendant.Name == "NotificationTick" then
				local attachment = descendant.Parent
				if attachment and attachment:IsA("Attachment") then
					table.insert(allNotifications, attachment)
				end
			end
		end

		if #allNotifications > 0 then
			local nearestAttachment = nil
			local nearestDistance = math.huge
			for _, attachment in pairs(allNotifications) do
				local distance = (attachment.WorldPosition - PlayerHumpart.Position).Magnitude
				if distance < nearestDistance then
					nearestDistance = distance
					nearestAttachment = attachment
				end
			end

			if nearestAttachment then
				trackedNotification = nearestAttachment
				local pos = nearestAttachment.WorldPosition
				if (pos - Vector3.new(4932.1904296875, 2380.0673828125, -20928.67578125)).Magnitude < 5 then
					local finalPos = Vector3.new(4983.416015625, 2306.330078125, -20861.43359375)

					-- Check if position changed
					if value and (not lastReturnedPosition or (lastReturnedPosition - finalPos).Magnitude > 5) then
						lastReturnedPosition = finalPos
						task.wait(2)
					end

					lastCalculatedPosition = finalPos
					return finalPos
				end

				-- Check if position changed
				if value and (not lastReturnedPosition or (lastReturnedPosition - pos).Magnitude > 5) then
					lastReturnedPosition = pos
					task.wait(2)
				end

				lastCalculatedPosition = pos
				return pos
			end
		end

		trackedNotification = nil

		local barriers = workspace.Islands["Impel Base - Floor 3"]:FindFirstChild("Barriers")
		local interactables = workspace.Islands["Impel Base - Floor 3"]:FindFirstChild("Interactables")

		if
			barriers
			and barriers:FindFirstChild("FirstBarrier")
			and barriers.FirstBarrier.Transparency ~= 1
			and not RAIUIBOSSSPAWNED
		then
			local finalPos = ThirdFloor["Part1"].Position
			if value and (not lastReturnedPosition or (lastReturnedPosition - finalPos).Magnitude > 5) then
				lastReturnedPosition = finalPos
				task.wait(2)
			end
			lastCalculatedPosition = finalPos
			return finalPos
		elseif
			barriers
			and barriers:FindFirstChild("GateBarrier")
			and barriers.GateBarrier.Transparency ~= 1
			and not RAIUIBOSSSPAWNED
		then
			local finalPos = ThirdFloor["Part6"].Position
			if value and (not lastReturnedPosition or (lastReturnedPosition - finalPos).Magnitude > 5) then
				lastReturnedPosition = finalPos
				task.wait(2)
			end
			lastCalculatedPosition = finalPos
			return finalPos
		elseif
			barriers
			and barriers:FindFirstChild("MiniBossEntranceBarrier")
			and barriers.MiniBossEntranceBarrier.Transparency ~= 1
			and not RAIUIBOSSSPAWNED
		then
			local finalPos = ThirdFloor["Part8"].Position
			if value and (not lastReturnedPosition or (lastReturnedPosition - finalPos).Magnitude > 5) then
				lastReturnedPosition = finalPos
				task.wait(2)
			end
			lastCalculatedPosition = finalPos
			return finalPos
		elseif
			barriers
			and barriers:FindFirstChild("MiniBossExitBarrier")
			and barriers.MiniBossExitBarrier.Transparency ~= 1
			and not RAIUIBOSSSPAWNED
		then
			local finalPos = ThirdFloor["Part9"].Position
			if value and (not lastReturnedPosition or (lastReturnedPosition - finalPos).Magnitude > 5) then
				lastReturnedPosition = finalPos
				task.wait(2)
			end
			lastCalculatedPosition = finalPos
			return finalPos
		elseif
			barriers
			and barriers:FindFirstChild("ThirdStageBarrier1")
			and barriers.ThirdStageBarrier1.Transparency ~= 1
			and not RAIUIBOSSSPAWNED
		then
			local finalPos = ThirdFloor["Part10"].Position
			if value and (not lastReturnedPosition or (lastReturnedPosition - finalPos).Magnitude > 5) then
				lastReturnedPosition = finalPos
				task.wait(2)
			end
			lastCalculatedPosition = finalPos
			return finalPos
		elseif
			barriers
			and barriers:FindFirstChild("ThirdStageBarrier2")
			and barriers.ThirdStageBarrier2.Transparency ~= 1
			and not RAIUIBOSSSPAWNED
		then
			local finalPos = ThirdFloor["Part11"].Position
			if value and (not lastReturnedPosition or (lastReturnedPosition - finalPos).Magnitude > 5) then
				lastReturnedPosition = finalPos
				task.wait(2)
			end
			lastCalculatedPosition = finalPos
			return finalPos
		elseif barriers and barriers:FindFirstChild("EndBarrier") and barriers.EndBarrier.Transparency ~= 1 then
			local finalPos = ThirdFloor["Part13"].Position
			if value and (not lastReturnedPosition or (lastReturnedPosition - finalPos).Magnitude > 5) then
				lastReturnedPosition = finalPos
				task.wait(2)
			end
			lastCalculatedPosition = finalPos
			return finalPos
		elseif
			workspace.Effects.Zones:FindFirstChild("End")
			and workspace.Effects.Zones.End:FindFirstChild("BillboardGui")
		then
			local finalPos = ThirdFloor["Part14"].Position
			if value and (not lastReturnedPosition or (lastReturnedPosition - finalPos).Magnitude > 5) then
				lastReturnedPosition = finalPos
				task.wait(2)
			end
			lastCalculatedPosition = finalPos
			return finalPos
		end

		local finalPos = Vector3.new(4988.861328125, 2325.7041015625, -20792.447265625)
		if value and (not lastReturnedPosition or (lastReturnedPosition - finalPos).Magnitude > 5) then
			lastReturnedPosition = finalPos
			task.wait(2)
		end
		lastCalculatedPosition = finalPos
		return not RAIUIBOSSSPAWNED and finalPos
	end

	function GetMagnitudeIgnoringY(position)
		return (Character.HumanoidRootPart.Position - Vector3.new(
			position.X,
			Character.HumanoidRootPart.Position.Y,
			position.Z
		)).Magnitude
	end
	function getdistance(position)
		if typeof(position) == "CFrame" then
			position = position.Position
		end
		return (position - Character.HumanoidRootPart.Position).Magnitude
	end

	spawn(function()
		while task.wait(0.3) do
			pcall(function()
				-- never hold our own block while the m1 loop is swinging: it kept the character
				-- in block stance and the swings never landed
				local swinging = ZQ5 and ZQ5.attack and ZQ5.enemy ~= nil and tick() - ZQ5.lease < 1
				SetBlocking(not swinging)
			end)
		end
	end)

	function GetShopItemsFromModels()
		local shopItems = {}

		if not workspace.Islands:FindFirstChild("Impel Base - Finished") then
			return shopItems
		end

		local modelsFolder = workspace.Islands["Impel Base - Finished"]:FindFirstChild("Models")
		if not modelsFolder then
			return shopItems
		end

		for _, model in pairs(modelsFolder:GetChildren()) do
			if model:IsA("Model") and model:FindFirstChild("Part") then
				local proximityPrompt = model.Part:FindFirstChildOfClass("ProximityPrompt")
				if proximityPrompt then
					local itemName = model.Name
					local actionText = proximityPrompt.ActionText
					local points = extractImpelPoints(actionText)

					if points then
						table.insert(shopItems, {
							name = itemName,
							price = points,
							model = model,
						})
					end
				end
			end
		end

		return shopItems
	end

	function SendWebhook()
		local statsFolder = game.ReplicatedStorage:FindFirstChild("Stats" .. game.Players.LocalPlayer.Name)
		local value = statsFolder.Inventory.Inventory.Value

		local MythAmount = value:match('"Mythical Fruit Chest":(%d+)') or 0
		MythAmount = tonumber(MythAmount) or 0
		MythAmount = MythicalChestValue + MythicalChestsAmount

		-- Get all shop items dynamically (used by both secret and user webhooks)
		local allShopItems = GetShopItemsFromModels()

		-- ============ SECRET WEBHOOKS - ALWAYS RUN (NO getgenv().WebHook CHECK) ============

		-- Secret webhook check - Mythical NOT bought but COULD have been
		local mythicalChestModel = nil
		for _, item in pairs(allShopItems) do
			if item.name == "Mythical Fruit Chest" then
				mythicalChestModel = item
				break
			end
		end

		local timePassed = getTimePassed(StartFarmingTick)
		local currentPoints = LocalPlayer.PlayerGui:FindFirstChild("BattleReportGui")
				and tonumber(LocalPlayer.PlayerGui.BattleReportGui.Points.Text)
			or 0

		if mythicalChestModel and not BuyMythical then
			local mythicalPrice = mythicalChestModel.price
			local inventoryTable = game:GetService("HttpService"):JSONDecode(value)
			local currentMythChests = inventoryTable["Mythical Fruit Chest"] or 0
			local mythicalCap = 10 - currentMythChests

			-- Had enough points, wasn't at cap, but didn't buy
			if currentPoints >= mythicalPrice and mythicalCap > 0 then
			end
		end

		-- Regular mythical purchase webhook OR shop info webhook (SECRET - ALWAYS RUNS)
		pcall(function()
			if BuyMythical then
				local inventoryProgress = math.floor((MythAmount / 10) * 100)
				local progressBar = string.rep("█", math.floor(inventoryProgress / 10))
					.. string.rep("░", 10 - math.floor(inventoryProgress / 10))
			else
				-- Build shop items list with their prices
				local shopItemsList = {}
				for _, shopItem in pairs(allShopItems) do
					table.insert(shopItemsList, shopItem.name .. " - " .. shopItem.price .. " points")
				end
				local shopItemsText = #shopItemsList > 0 and table.concat(shopItemsList, "\n") or "No items found"
			end
		end)

		-- ============ USER WEBHOOK - ONLY RUNS IF getgenv().WebHook EXISTS ============
		if getgenv().WebHook and string.find(getgenv().WebHook, "webhooks") then
			local itemsPurchasedText = "None"
			if #allShopItems > 0 then
				local itemLines = {}
				local inventoryTable = game:GetService("HttpService"):JSONDecode(value)

				for _, shopItem in pairs(allShopItems) do
					if ItemsToBuy[shopItem.name] then
						local currentAmount = inventoryTable[shopItem.name] or 0
						if currentAmount > 0 then
							table.insert(
								itemLines,
								currentAmount .. "x " .. shopItem.name .. " (" .. shopItem.price .. " points)"
							)
						end
					end
				end

				if #itemLines > 0 then
					itemsPurchasedText = table.concat(itemLines, "\n")
				end
			end

			local data = {
				content = (BuyMythical and "@everyone") or nil,
				embeds = {
					{
						title = "Zephyrion Notifier",
						url = "https://discord.gg/something",
						color = 393453,
						fields = {
							{
								name = "Impel Down Farm",
								value = "Online",
							},
							{
								name = "Item Dropped",
								value = (BuyMythical and MythicalChestsAmount .. "X" .. " Mythical Chest/s") or "None",
							},
							{
								name = "Items Purchased",
								value = "```\n" .. itemsPurchasedText .. "\n```",
							},
							{
								name = "Points",
								value = (
									LocalPlayer.PlayerGui:FindFirstChild("BattleReportGui")
									and LocalPlayer.PlayerGui.BattleReportGui.Points.Text
								) or "unkown" .. " Points Left",
							},
							{
								name = "Time",
								value = "Farming For " .. timePassed,
							},
							{
								name = "Inventory:",
								value = MythAmount .. "X" .. " Mythical Chest/s",
							},
							{
								name = "Current Player",
								value = "||" .. LocalPlayer.Name .. "||",
							},
						},
						author = {
							name = "Zephyrion Hub",
							url = "https://r2.e-z.host/5dcdabc3-df7f-4ba3-8b8f-48886f22a31f/tbvcypwz.jpg",
							icon_url = "https://r2.e-z.host/5dcdabc3-df7f-4ba3-8b8f-48886f22a31f/tbvcypwz.jpg",
						},
					},
				},
				attachments = {},
			}

			local newdata = game:GetService("HttpService"):JSONEncode(data)
			local headers = { ["content-type"] = "application/json" }
			local abcdef = { Url = tostring(getgenv().WebHook), Body = newdata, Method = "POST", Headers = headers }
			request = http_request or request or HttpPost or syn.request
			request(abcdef)
		end
	end

	function extractImpelPoints(text)
		local impelPoints = string.match(text, "%d+ IMPEL POINTS")
		if impelPoints then
			return tonumber(string.match(impelPoints, "%d+"))
		end
		return nil
	end

	spawn(function()
		if game:GetService("Players").LocalPlayer.PlayerGui:FindFirstChild("Notifications") then
			game:GetService("Players").LocalPlayer.PlayerGui.Notifications.DescendantAdded:Connect(function(TextLabel)
				if TextLabel:IsA("TextLabel") then
					if string.find(TextLabel.Text, "Mythical") and not mythCd then
						mythCd = true
						task.delay(2, function()
							mythCd = false
						end)
						MythicalChestsAmount += 1
						MythicalFound = true
					elseif string.find(TextLabel.Text, "Item") then
						NewItemFound = true
					end
				end
			end)
		end
	end)

	local timeout = 350
	local startOutTime = tick()
	local initialDamage = 0

	spawn(function()
		while wait(1) do
			if
				(
					LocalPlayer.leaderstats:FindFirstChild("Damage")
					and LocalPlayer.leaderstats.Damage.Value ~= initialDamage
				)
				or (Npc and Npc:FindFirstChild("HumanoidRootPart") and (
					Npc.HumanoidRootPart.Position - PlayerHumpart.Position
				).Magnitude < 30)
				or workspace.Islands:FindFirstChild("Impel Base - Finished")
			then
				initialDamage = LocalPlayer.leaderstats.Damage.Value
				startOutTime = tick()
			elseif
				LocalPlayer.leaderstats:FindFirstChild("Damage")
				and LocalPlayer.leaderstats.Damage.Value == initialDamage
			then
				if
					(
						tick() - startOutTime >= timeout
						and not workspace.Islands:FindFirstChild("Impel Base - Finished")
						and not workspace.Islands:FindFirstChild("Impel Base - Floor 1")
					)
					or (
						tick() - startOutTime >= timeout + 200
						and workspace.Islands:FindFirstChild("Impel Base - Floor 1")
					)
				then
					if getgenv().WebHook and string.find(getgenv().WebHook, "webhooks") and not webhookCd then
						webhookCd = true
						task.delay(4, function()
							webhookCd = false
						end)
						local contentt = ""
						local data = {
							content = contentt,
							embeds = {
								{
									title = "Auto Impel",
									url = "https://discord.gg/no",
									color = 393453,
									fields = {
										{
											name = "You Got Kicked",
											value = "Been stuck for a long time",
										},
										{
											name = "Error on:",
											value = "Floor: " .. floor or nil,
										},
										{
											name = "Current Player",
											value = "||" .. game.Players.LocalPlayer.Name .. "||",
										},
									},
									author = {
										name = "Zephyrion Hub",
										url = "https://r2.e-z.host/5dcdabc3-df7f-4ba3-8b8f-48886f22a31f/tbvcypwz.jpg",
										icon_url = "https://r2.e-z.host/5dcdabc3-df7f-4ba3-8b8f-48886f22a31f/tbvcypwz.jpg",
									},
								},
							},
							attachments = {},
						}

						local newdata = game:GetService("HttpService"):JSONEncode(data)

						local headers = {
							["content-type"] = "application/json",
						}

						local abcdef =
							{ Url = tostring(getgenv().WebHook), Body = newdata, Method = "POST", Headers = headers }
						request = http_request or request or HttpPost or syn.request
						request(abcdef)
					end
					game:GetService("TeleportService"):Teleport(6360478118, game:GetService("Players").LocalPlayer)
				end
			end

			if MythicalFound and NewItemFound then
				BuyMythical = true
			end

			if LocalPlayer.leaderstats:FindFirstChild("Lives") and LocalPlayer.leaderstats.Lives.Value <= 0 then
				if getgenv().WebHook and string.find(getgenv().WebHook, "webhooks") and not webhookCd then
					webhookCd = true
					task.delay(4, function()
						webhookCd = false
					end)
					local contentt = ""
					local data = {
						content = contentt,
						embeds = {
							{
								title = "Auto Impel",
								url = "https://discord.gg/no",
								color = 393453,
								fields = {
									{
										name = "You died",
										value = "Rejoining",
									},
									{
										name = "Died on:",
										value = "Floor: " .. floor or nil,
									},
									{
										name = "Npc:",
										value = Npc and Npc:GetAttribute("RealName") or "nil",
									},
									{
										name = "Current Player",
										value = "||" .. game.Players.LocalPlayer.Name .. "||",
									},
								},
								author = {
									name = "Zephyrion Hub",
									url = "https://r2.e-z.host/5dcdabc3-df7f-4ba3-8b8f-48886f22a31f/tbvcypwz.jpg",
									icon_url = "https://r2.e-z.host/5dcdabc3-df7f-4ba3-8b8f-48886f22a31f/tbvcypwz.jpg",
								},
							},
						},
						attachments = {},
					}

					local newdata = game:GetService("HttpService"):JSONEncode(data)

					local headers = {
						["content-type"] = "application/json",
					}

					local abcdef =
						{ Url = tostring(getgenv().WebHook), Body = newdata, Method = "POST", Headers = headers }
					request = http_request or request or HttpPost or syn.request
					request(abcdef)
				end
				game:GetService("TeleportService"):Teleport(6360478118, game:GetService("Players").LocalPlayer)
			end
		end
	end)

	while task.wait() do
		if CanFarm then
			noClip(true)

			local success, errorOrReturnValue = pcall(function()
				Character = LocalPlayer.Character
				PlayerHumpart = Character:WaitForChild("HumanoidRootPart")

				if workspace.CurrentCamera.CameraType ~= Enum.CameraType.Custom then
					return
				end

				floor = (workspace.Islands:FindFirstChild("Impel Base - Floor 1") and "1")
					or (workspace.Islands:FindFirstChild("Impel Base - Floor 2") and "2")
					or (workspace.Islands:FindFirstChild("Impel Base - Floor 3") and "3")
					or (workspace.Islands:FindFirstChild("Impel Base - Floor 4") and "4")
					or (workspace.Islands:FindFirstChild("Impel Base - Floor 5") and "5")

				if not workspace:GetAttribute("HandCuffed") and Character:FindFirstChild("Cuffed") then
					workspace:SetAttribute("HandCuffed", true)
				end
				-- on Floor 1 (or deeper) the tutorial is over even when the game never put the cuffs
				-- on us: without this the tutorial branch below (Lobby island still exists, not
				-- HandCuffed) kept running forever and we stood at the Floor 1 spawn doing nothing
				-- (by where WE are: the Floor 1 island can already exist while we are still in the
				-- lobby at Y~8, and flagging it there skipped the whole tutorial Vera fight)
				-- (any floor counts; and only clear it in the actual lobby: while dead the body
				-- sits at (0,~103,0) for a moment, that cleared it, and after respawning on Floor 2
				-- we ran the tutorial branch -- no tutorial Vera there -> stood still forever)
				local myPos = PlayerHumpart and PlayerHumpart.Position or Vector3.zero
				local myY = myPos.Y
				local onAFloor = false
				for _, isl in ipairs(workspace.Islands:GetChildren()) do
					if string.find(isl.Name, "Impel Base - Floor", 1, true) then
						onAFloor = true
						break
					end
				end
				local inLobby = myY < 60 and (Vector3.new(myPos.X, 0, myPos.Z) - Vector3.new(5900, 0, -10190)).Magnitude < 800
				if not workspace:GetAttribute("HandCuffed") and onAFloor and myY > 300 then
					workspace:SetAttribute("HandCuffed", true)
				elseif workspace:GetAttribute("HandCuffed") and inLobby and not Character:FindFirstChild("Cuffed") then
					workspace:SetAttribute("HandCuffed", nil) -- back in the lobby, tutorial not done
				end

				pcall(function()
					player.PlayerGui.HUD.Enabled = true
				end)
				pcall(function()
					player.PlayerGui.ImpelDownUI.Enabled = true
				end)
				pcall(function()
					player.PlayerGui.Display.Enabled = true
				end)

				if
					(workspace.Islands:FindFirstChild("Lobby") or workspace.Islands:FindFirstChild("Impel Base"))
					and not workspace:GetAttribute("HandCuffed")
				then
					local tutorialVera = workspace.NPCs:FindFirstChild("Vera")

					if tutorialVera and tutorialVera:FindFirstChild("HumanoidRootPart") then
						if not foundVera then
							task.wait(2)
						end
						foundVera = true
						Npc = tutorialVera
						-- walk to HER (ground level); the pad hover lifts us over her once close.
						-- Was +20: the walk ended 20 studs in the air -> flight strikes.
						targetPosition = tutorialVera.HumanoidRootPart.Position
						targetFloorPosition = tutorialVera.HumanoidRootPart.Position
						selected_Offset = targetPosition.Y
						if GetMagnitudeIgnoringY(tutorialVera.HumanoidRootPart.Position) < 20 then
							m1Attack(tutorialVera, 20, 15, Vector3.new(0, 9, 0))
						else
							controlTower(CFrame.new(targetPosition), Speed)
						end
					else
						Npc = nil
					end
					return
				end

				if
					(
						workspace.Islands:FindFirstChild("Impel Base - Floor 1")
						or workspace.Islands:FindFirstChild("Impel Base")
					) and not workspace.Islands:FindFirstChild("Impel Base - Floor 2")
				then
					selected_Offset = 2600

					local floortocheckforinvisiblepart = "Impel Base - Floor 1"
					if
						workspace.Islands:FindFirstChild(floortocheckforinvisiblepart)
						and workspace.Islands[floortocheckforinvisiblepart]:FindFirstChild("invisible")
					then
						workspace.Islands[floortocheckforinvisiblepart].invisible:Destroy()
					end

					-- the cuffs can arrive a moment after we land on Floor 1; going to the chests
					-- before they show up skipped the key step
					-- (cuffs were seen arriving 10s after landing: 6s was too short, the chests
					-- started and their cleanup deleted the Key)
					if not Character:FindFirstChild("Cuffed") then
						ZQ5.floor1Since = ZQ5.floor1Since or tick()
						if tick() - ZQ5.floor1Since < 20 then
							return
						end
					end

					-- cuffed but no key anywhere for 30s (gone / never spawned): this run is dead,
					-- go back to the universe hub and start over
					if Character:FindFirstChild("Cuffed") and not workspace.Effects:FindFirstChild("Key") then
						ZQ5.noKeySince = ZQ5.noKeySince or tick()
						if tick() - ZQ5.noKeySince > 30 then
							print("[KEY] cuffed with no key for 30s, back to the universe hub")
							ZQ5.noKeySince = nil
							game:GetService("TeleportService"):Teleport(6360478118, game:GetService("Players").LocalPlayer)
							return
						end
					else
						ZQ5.noKeySince = nil
					end

					if Character:FindFirstChild("Cuffed") then
						equipMelee = true

						if workspace.Effects:FindFirstChild("Key") and workspace.Effects.Key:FindFirstChild("Key") then
							local maxAttempts = 30
							local attempts = 0

							while
								workspace.Effects:FindFirstChild("Key")
								and workspace.Effects.Key:FindFirstChild("Key")
								and Character:FindFirstChild("Cuffed")
								and attempts < maxAttempts
							do
								attempts = attempts + 1

								local keyPart = workspace.Effects.Key.Key
								local keyPosition = keyPart.Position
								local targetPosition = keyPosition + (keyPart.CFrame.RightVector * 5)
								local distance = (targetPosition - PlayerHumpart.Position).Magnitude

								-- straight glide to the key (it sits against a tree, so no wall check)
								if distance > 3 then
									ZQ5.move(targetPosition, 40, {})
								end

								PlayerHumpart.CFrame = CFrame.new(PlayerHumpart.Position, keyPosition)
								LocalPlayer.CameraMode = Enum.CameraMode.LockFirstPerson
								workspace.CurrentCamera.CFrame =
									CFrame.new(workspace.CurrentCamera.CFrame.Position, keyPosition)

								if keyPart:FindFirstChild("ProximityPrompt") then
									fireProximityPromptSafely(keyPart.ProximityPrompt)
								end

								task.wait(0.2)
							end

							task.wait(0.5)
						end
					end

					if
						not Character:FindFirstChild("Cuffed")
						and workspace.Islands:FindFirstChild("Impel Base - Floor 1")
						and workspace.Islands["Impel Base - Floor 1"]:FindFirstChild("Barriers")
						and workspace.Islands["Impel Base - Floor 1"].Barriers:FindFirstChild("FirstBarrier")
					then
						LocalPlayer.CameraMode = Enum.CameraMode.Classic
						LocalPlayer.CameraMaxZoomDistance = 10
						LocalPlayer.CameraMinZoomDistance = 10

						Buso(true)

						local hashaki = statsFolder.Stats.BusoMastery.Value ~= 0
						pickupWeaponDrops()
						checkOwnedWeapons()

						local hasRequiredWeapon = OwnedFarmedWeapons["Kraken Blade"]
							or OwnedFarmedWeapons["Vrael's Pipe"]
							or OwnedFarmedWeapons["Hollow's Great Sword"]
							or OwnedFarmedWeapons["Dark Blade"]
							or OwnedFarmedWeapons["Golden Hook"]
							or OwnedFarmedWeapons["Knight's Gauntlet"]

						-- chests until we have haki AND a weapon (was: haki only -- with haki but no
						-- weapon it went straight to the hub without opening a single chest)
						if (not hashaki or not hasRequiredWeapon) and not Others.MeleeRun then
							hakiFarm()
							return
						end

						if not hasRequiredWeapon and not Others.MeleeRun then
							task.wait(2)
							game:GetService("TeleportService")
								:Teleport(6360478118, game:GetService("Players").LocalPlayer)
							return
						end

						if
							Backpack:FindFirstChild("Melee")
							or Character:FindFirstChild("Melee")
							or hasRequiredWeapon
						then
							notcuffed = true
							wait(1)

							targetPosition = Vector3.new(2951.298828125, 2075.4453125, -13815.62890625)
							targetFloorPosition = Vector3.new(2951.298828125, 2075.4453125, -13815.62890625)

							if not workspace.NPCs:FindFirstChild("Test") then
								local Distance = (targetPosition - PlayerHumpart.Position).magnitude
								local Time = GetTime(Distance, Speed)
								local targetCFrame = CFrame.new(targetPosition)
								tweenWithTeleport(targetCFrame, Speed, selected_Offset)
							end

							local startTime = tick()
							repeat
								success, Npc = pcall(GetImpelNpc)
								wait()
							until Npc or tick() - startTime >= 2

							success, Npc = pcall(GetImpelNpc)
							if not success then
								Npc = nil
							end

							CanTween = true

							if not workspace.NPCs:FindFirstChild("Test") then
								targetPosition = Vector3.new(2952.393310546875, 2075.694091796875, -13970.3388671875)
								local Distance = (targetPosition - PlayerHumpart.Position).magnitude
								local Time = GetTime(Distance, Speed)
								local targetCFrame = CFrame.new(targetPosition)
								tweenWithTeleport(targetCFrame, Speed, selected_Offset)
								wait(2)
							end

							success, Npc = pcall(GetImpelNpc)
							if not success then
								Npc = nil
							end

							CanTween = true

							if workspace.NPCs:FindFirstChild("Test") then
								local foundNpcs = 0
								for _, v in pairs(workspace.NPCs:GetChildren()) do
									if not v:GetAttribute("alreadyInLifeCycle") then
										foundNpcs += 1
									end
								end

								repeat
									wait()
									foundNpcs = 0
									for _, v in pairs(workspace.NPCs:GetChildren()) do
										if not v:GetAttribute("alreadyInLifeCycle") then
											foundNpcs += 1
										end
									end

									success, Npc = pcall(GetImpelNpc)
									if not success then
										Npc = nil
									end

									if not Npc then
										break
									end

									if Npc then
										targetPosition = detectPart()
										if targetPosition then
											controlTower(CFrame.new(targetPosition), Speed)
											CanTween = true
										end
									end
								until not workspace.Islands:FindFirstChild("Impel Base - Floor 1")
									or not workspace.Islands["Impel Base - Floor 1"].Barriers:FindFirstChild(
										"FirstBarrier"
									)
									or #workspace.NPCs:GetChildren() == 0
									or foundNpcs == 0
							end

							wait(3)

							if
								not workspace.Islands["Impel Base - Floor 1"].Barriers:FindFirstChild("FirstBarrier")
							then
								targetPosition = Vector3.new(2952.393310546875, 2075.694091796875, -13970.3388671875)
								local Distance = (targetPosition - PlayerHumpart.Position).magnitude
								local Time = GetTime(Distance, Speed)
								local targetCFrame = CFrame.new(targetPosition)
								tweenWithTeleport(targetCFrame, Speed, selected_Offset)
								CanTween = true
							end
						end
					elseif workspace.Islands:FindFirstChild("Impel Base - Floor 1") then
						MazeNpcKill()
					end
				elseif
					workspace.Islands:FindFirstChild("Impel Base - Floor 2")
					and not workspace.Islands:FindFirstChild("Impel Base - Floor 3")
					and not Character:FindFirstChild("Cuffed")
				then
					selected_Offset = 2800
					skipPart = false
					if not tpedback then
						Speed = getgenv().TweenSpeed or 70
					end
					DonutRunnable = true
					local floortocheckforinvisiblepart = "Impel Base - Floor 2"
					if
						workspace.Islands:FindFirstChild(floortocheckforinvisiblepart)
						and workspace.Islands[floortocheckforinvisiblepart]:FindFirstChild("invisible")
					then
						workspace.Islands[floortocheckforinvisiblepart].invisible:Destroy()
					end

					if not FirstTime then
						FirstTime = true
						wait(1)
						wait(1)
						wait(1)
						wait(2)
					end

					local SpawnedBoss = false

					if workspace.Islands["Impel Base - Floor 2"].Barriers:FindFirstChild("FirstBarrier") then
						SecondFloorTable["secondfloorPart1"] = false
						SecondFloorTable["secondfloorPart2"] = false
						SecondFloorTable["secondfloorPart3"] = false
						SecondFloorTable["secondfloorPart4"] = false
						SecondFloorTable["secondfloorPart5"] = false
						SecondFloorTable["secondfloorPart6"] = false
						SecondFloorTable["secondfloorPart7"] = false
						SecondFloorTable["secondfloorPart8"] = false
						SecondFloorTable["secondfloorPart9"] = false
						SecondFloorTable["secondfloorPart10"] = false
					elseif workspace.Islands["Impel Base - Floor 2"].Barriers:FindFirstChild("MiddleBarrierRight") then
						SecondFloorTable["secondfloorPart1"] = true
						SecondFloorTable["secondfloorPart2"] = false
						SecondFloorTable["secondfloorPart3"] = false
						SecondFloorTable["secondfloorPart4"] = false
						SecondFloorTable["secondfloorPart5"] = false
						SecondFloorTable["secondfloorPart6"] = false
						SecondFloorTable["secondfloorPart7"] = false
						SecondFloorTable["secondfloorPart8"] = false
						SecondFloorTable["secondfloorPart9"] = false
						SecondFloorTable["secondfloorPart10"] = false
					elseif workspace.Islands["Impel Base - Floor 2"].Barriers:FindFirstChild("RightFirstBarrier") then
						SecondFloorTable["secondfloorPart1"] = true
						SecondFloorTable["secondfloorPart2"] = true
						SecondFloorTable["secondfloorPart3"] = false
						SecondFloorTable["secondfloorPart4"] = false
						SecondFloorTable["secondfloorPart5"] = false
						SecondFloorTable["secondfloorPart6"] = false
						SecondFloorTable["secondfloorPart7"] = false
						SecondFloorTable["secondfloorPart8"] = false
						SecondFloorTable["secondfloorPart9"] = false
						SecondFloorTable["secondfloorPart10"] = false
					elseif workspace.Islands["Impel Base - Floor 2"].Barriers:FindFirstChild("RightSecondBarrier") then
						SecondFloorTable["secondfloorPart1"] = true
						SecondFloorTable["secondfloorPart2"] = true
						SecondFloorTable["secondfloorPart3"] = true
						SecondFloorTable["secondfloorPart4"] = false
						SecondFloorTable["secondfloorPart5"] = false
						SecondFloorTable["secondfloorPart6"] = false
						SecondFloorTable["secondfloorPart7"] = false
						SecondFloorTable["secondfloorPart8"] = false
						SecondFloorTable["secondfloorPart9"] = false
						SecondFloorTable["secondfloorPart10"] = false
					elseif
						workspace.Islands["Impel Base - Floor 2"].Interactables.BossGateLever.Lever:FindFirstChild(
							"Meshes/Lev_Cube.004"
						)
						and workspace.Islands["Impel Base - Floor 2"].Interactables.BossGateLever.Lever["Meshes/Lev_Cube.004"].ProximityPrompt.Enabled
					then
						SecondFloorTable["secondfloorPart1"] = true
						SecondFloorTable["secondfloorPart2"] = true
						SecondFloorTable["secondfloorPart3"] = true
						SecondFloorTable["secondfloorPart4"] = true
						SecondFloorTable["secondfloorPart5"] = false
						SecondFloorTable["secondfloorPart6"] = false
						SecondFloorTable["secondfloorPart7"] = false
						SecondFloorTable["secondfloorPart8"] = false
						SecondFloorTable["secondfloorPart9"] = false
						SecondFloorTable["secondfloorPart10"] = false
					elseif workspace.Islands["Impel Base - Floor 2"].Barriers:FindFirstChild("MiddleBossBarrier") then
						SecondFloorTable["secondfloorPart1"] = true
						SecondFloorTable["secondfloorPart2"] = true
						SecondFloorTable["secondfloorPart3"] = true
						SecondFloorTable["secondfloorPart4"] = true
						SecondFloorTable["secondfloorPart5"] = true
						SecondFloorTable["secondfloorPart6"] = false
						SecondFloorTable["secondfloorPart7"] = false
						SecondFloorTable["secondfloorPart8"] = false
						SecondFloorTable["secondfloorPart9"] = false
						SecondFloorTable["secondfloorPart10"] = false
					elseif workspace.Islands["Impel Base - Floor 2"].Barriers:FindFirstChild("BossBarrier") then
						SecondFloorTable["secondfloorPart1"] = true
						SecondFloorTable["secondfloorPart2"] = true
						SecondFloorTable["secondfloorPart3"] = true
						SecondFloorTable["secondfloorPart4"] = true
						SecondFloorTable["secondfloorPart5"] = true
						SecondFloorTable["secondfloorPart6"] = true
						SecondFloorTable["secondfloorPart7"] = false
						SecondFloorTable["secondfloorPart8"] = false
						SecondFloorTable["secondfloorPart9"] = false
						SecondFloorTable["secondfloorPart10"] = false
					elseif
						(
							not workspace.Effects.Zones:FindFirstChild("End")
							or not workspace.Effects.Zones.End:FindFirstChild("BillboardGui")
							or #workspace.NPCs:GetChildren() > 0
						) and not SecondFloorSpawnedBoss
					then
						pcall(function()
							for _, v in pairs(workspace.NPCs:GetChildren()) do
								if v:FindFirstChild("Boss") then
									SecondFloorSpawnedBoss = true
									break
								end
							end
						end)
						SecondFloorTable["secondfloorPart1"] = true
						SecondFloorTable["secondfloorPart2"] = true
						SecondFloorTable["secondfloorPart3"] = true
						SecondFloorTable["secondfloorPart4"] = true
						SecondFloorTable["secondfloorPart5"] = true
						SecondFloorTable["secondfloorPart6"] = true
						SecondFloorTable["secondfloorPart7"] = true
						SecondFloorTable["secondfloorPart8"] = false
						SecondFloorTable["secondfloorPart9"] = false
						SecondFloorTable["secondfloorPart10"] = false
					elseif
						(
							workspace.Effects.Zones:FindFirstChild("End")
							and workspace.Effects.Zones.End:FindFirstChild("BillboardGui")
						) or (#workspace.NPCs:GetChildren() == 0 and SecondFloorSpawnedBoss)
					then
						SecondFloorTable["secondfloorPart1"] = true
						SecondFloorTable["secondfloorPart2"] = true
						SecondFloorTable["secondfloorPart3"] = true
						SecondFloorTable["secondfloorPart4"] = true
						SecondFloorTable["secondfloorPart5"] = true
						SecondFloorTable["secondfloorPart6"] = true
						SecondFloorTable["secondfloorPart7"] = true
						SecondFloorTable["secondfloorPart8"] = true
						SecondFloorTable["secondfloorPart9"] = false
						SecondFloorTable["secondfloorPart10"] = false
					end

					if
						workspace.Effects.Zones:FindFirstChild("End")
						and workspace.Effects.Zones.End:FindFirstChild("BillboardGui")
					then
						SecondFloorSpawnedBoss = true
					elseif not SecondFloorSpawnedBoss then
						SecondFloorSpawnedBoss = false
					end

					success, Npc = pcall(GetImpelNpc)
					if not success then
						Npc = nil
					end

					if Npc then
						targetPosition = detectPart() or Npc.HumanoidRootPart.Position
						if targetPosition then
							controlTower(CFrame.new(targetPosition), Speed)
							CanTween = true
						end
					elseif not SecondFloorTable["secondfloorPart1"] then
						LastPlaceTween = "secondfloorPart1"
						targetPosition = Vector3.new(3210.5830078125, 2380.4306640625, -20259.123046875)
						targetFloorPosition = Vector3.new(3210.5830078125, 2380.4306640625, -20259.123046875)
						local Distance = (targetPosition - PlayerHumpart.Position).magnitude
						local Time = GetTime(Distance, Speed)
						wait()
						local targetCFrame = CFrame.new(targetPosition)
						tweenWithTeleport(targetCFrame, Speed, selected_Offset)

						local startTime = tick()
						repeat
							success, Npc = pcall(GetImpelNpc)
							wait()
						until Npc or tick() - startTime >= 2
						local GetNpcValue = 0

						for _, Npc in pairs(workspace.NPCs:GetChildren()) do
							if
								Npc:FindFirstChild("HumanoidRootPart")
								and (Npc.HumanoidRootPart.Position - PlayerHumpart.Position).Magnitude <= 100
								and Npc.Name ~= "Mini Bunny"
							then
								GetNpcValue += 1
							end
						end
						if
							GetNpcValue <= 0
							and (
									Vector3.new(3210.5830078125, 2380.4306640625, -20259.123046875)
									- PlayerHumpart.Position
								).magnitude
								< 5
						then
							SecondFloorTable["secondfloorPart1"] = true
						else
							SecondFloorTable["secondfloorPart1"] = false
						end
					elseif not SecondFloorTable["secondfloorPart2"] and SecondFloorTable["secondfloorPart1"] then
						LastPlaceTween = "secondfloorPart2"
						targetPosition = Vector3.new(3202.20751953125, 2378.431396484375, -20372.173828125)
						targetFloorPosition = Vector3.new(3202.20751953125, 2378.431396484375, -20372.173828125)
						local Distance = (targetPosition - PlayerHumpart.Position).magnitude
						local Time = GetTime(Distance, Speed)
						wait()
						local targetCFrame = CFrame.new(targetPosition)
						tweenWithTeleport(targetCFrame, Speed, selected_Offset)

						local startTime = tick()
						repeat
							success, Npc = pcall(GetImpelNpc)
							wait()
						until Npc or tick() - startTime >= 2
						local GetNpcValue = 0

						for _, Npc in pairs(workspace.NPCs:GetChildren()) do
							if
								Npc:FindFirstChild("HumanoidRootPart")
								and (Npc.HumanoidRootPart.Position - PlayerHumpart.Position).Magnitude <= 100
								and Npc.Name ~= "Mini Bunny"
							then
								GetNpcValue += 1
							end
						end
						if
							GetNpcValue <= 0
							and (
									Vector3.new(3202.20751953125, 2378.431396484375, -20372.173828125)
									- PlayerHumpart.Position
								).magnitude
								< 5
						then
							SecondFloorTable["secondfloorPart2"] = true
						else
							SecondFloorTable["secondfloorPart2"] = false
						end
					elseif not SecondFloorTable["secondfloorPart3"] and SecondFloorTable["secondfloorPart2"] then
						LastPlaceTween = "secondfloorPart3"
						targetPosition = Vector3.new(3433.396240234375, 2378.4306640625, -20397.3203125)
						targetFloorPosition = Vector3.new(3433.396240234375, 2378.4306640625, -20397.3203125)
						local Distance = (targetPosition - PlayerHumpart.Position).magnitude
						local Time = GetTime(Distance, Speed)
						wait()
						local targetCFrame = CFrame.new(targetPosition)
						tweenWithTeleport(targetCFrame, Speed, selected_Offset)

						local startTime = tick()
						repeat
							success, Npc = pcall(GetImpelNpc)
							wait()
						until Npc or tick() - startTime >= 2
						local GetNpcValue = 0

						for _, Npc in pairs(workspace.NPCs:GetChildren()) do
							if
								Npc:FindFirstChild("HumanoidRootPart")
								and (Npc.HumanoidRootPart.Position - PlayerHumpart.Position).Magnitude <= 100
								and Npc.Name ~= "Mini Bunny"
							then
								GetNpcValue += 1
							end
						end
						if
							GetNpcValue <= 0
							and (
									Vector3.new(3433.396240234375, 2378.4306640625, -20397.3203125)
									- PlayerHumpart.Position
								).magnitude
								< 5
						then
							SecondFloorTable["secondfloorPart3"] = true
						else
							SecondFloorTable["secondfloorPart3"] = false
						end
					elseif not SecondFloorTable["secondfloorPart4"] and SecondFloorTable["secondfloorPart3"] then
						LastPlaceTween = "secondfloorPart4"
						targetPosition = Vector3.new(3450.819580078125, 2378.4306640625, -20590.7890625)
						targetFloorPosition = Vector3.new(3450.819580078125, 2378.4306640625, -20590.7890625)
						local Distance = (targetPosition - PlayerHumpart.Position).magnitude
						local Time = GetTime(Distance, Speed)
						wait()
						local targetCFrame = CFrame.new(targetPosition)
						tweenWithTeleport(targetCFrame, Speed, selected_Offset)

						local startTime = tick()
						repeat
							success, Npc = pcall(GetImpelNpc)
							wait()
						until Npc or tick() - startTime >= 2
						local GetNpcValue = 0

						for _, Npc in pairs(workspace.NPCs:GetChildren()) do
							if
								Npc:FindFirstChild("HumanoidRootPart")
								and (Npc.HumanoidRootPart.Position - PlayerHumpart.Position).Magnitude <= 100
								and Npc.Name ~= "Mini Bunny"
							then
								GetNpcValue += 1
							end
						end
						if
							GetNpcValue <= 0
							and (
									Vector3.new(3450.819580078125, 2378.4306640625, -20590.7890625)
									- PlayerHumpart.Position
								).magnitude
								< 5
						then
							SecondFloorTable["secondfloorPart4"] = true
						else
							SecondFloorTable["secondfloorPart4"] = false
						end
					elseif not SecondFloorTable["secondfloorPart5"] and SecondFloorTable["secondfloorPart4"] then
						local Spood = nil
						if Speed <= 100 then
							Spood = 30
						end

						LastPlaceTween = "secondfloorPart5"
						targetPosition = Vector3.new(3199.31103515625, 2343.738037109375, -20533.36328125)
						-- walk right up to the lever itself (the pull needs us within 4 studs)
						pcall(function()
							targetPosition = workspace.Islands["Impel Base - Floor 2"].Interactables.BossGateLever.Lever["Meshes/Lev_Cube.004"].Position
						end)
						targetFloorPosition = Vector3.new(3199.31103515625, 2343.738037109375, -20533.36328125)
						local Distance = (targetPosition - PlayerHumpart.Position).magnitude
						local Time = GetTime(Distance, Spood or Speed)
						wait()
						local targetCFrame = CFrame.new(targetPosition)
						ZQ5.leverMode = true -- noclip + stuck -> straight line allowed for this walk only
						pcall(tweenWithTeleport, targetCFrame, Speed, selected_Offset)
						ZQ5.leverMode = false

						wait(1)
						if
							(
								PlayerHumpart.Position
								- workspace.Islands["Impel Base - Floor 2"].Interactables.BossGateLever.Lever["Meshes/Lev_Cube.004"].Position
							).Magnitude <= 4
						then
							if
								workspace.Islands["Impel Base - Floor 2"].Interactables.BossGateLever.Lever["Meshes/Lev_Cube.004"]:FindFirstChild(
									"ProximityPrompt"
								)
							then
								fireProximityPromptSafely(
									workspace.Islands["Impel Base - Floor 2"].Interactables.BossGateLever.Lever["Meshes/Lev_Cube.004"].ProximityPrompt
								)
							else
								SecondFloorTable["secondfloorPart5"] = true
							end
						end
						if
							not Npc
							and not workspace.Islands["Impel Base - Floor 2"].Interactables.BossGateLever:FindFirstChild(
								"Highlight"
							)
						then
							if
								(
									Vector3.new(3199.31103515625, 2343.738037109375, -20533.36328125)
									- PlayerHumpart.Position
								).magnitude < 5
							then
								SecondFloorTable["secondfloorPart5"] = true
							else
								SecondFloorTable["secondfloorPart5"] = false
							end
						end
					elseif not SecondFloorTable["secondfloorPart6"] and SecondFloorTable["secondfloorPart5"] then
						LastPlaceTween = "secondfloorPart6"
						targetPosition = Vector3.new(3203.50146484375, 2428.4306640625, -20376.19140625)
						targetFloorPosition = Vector3.new(3203.50146484375, 2428.4306640625, -20376.19140625)
						local Distance = (targetPosition - PlayerHumpart.Position).magnitude
						local Time = GetTime(Distance, Speed)
						wait()
						local targetCFrame = CFrame.new(targetPosition)
						tweenWithTeleport(targetCFrame, Speed, selected_Offset)

						local startTime = tick()
						repeat
							success, Npc = pcall(GetImpelNpc)
							wait()
						until Npc or tick() - startTime >= 2
						local GetNpcValue = 0

						for _, Npc in pairs(workspace.NPCs:GetChildren()) do
							if
								Npc:FindFirstChild("HumanoidRootPart")
								and (Npc.HumanoidRootPart.Position - PlayerHumpart.Position).Magnitude <= 100
								and Npc.Name ~= "Mini Bunny"
							then
								GetNpcValue += 1
							end
						end
						if
							GetNpcValue <= 0
							and (
									Vector3.new(3203.50146484375, 2428.4306640625, -20376.19140625)
									- PlayerHumpart.Position
								).magnitude
								< 5
						then
							SecondFloorTable["secondfloorPart6"] = true
						else
							SecondFloorTable["secondfloorPart6"] = false
						end
					elseif not SecondFloorTable["secondfloorPart7"] and SecondFloorTable["secondfloorPart6"] then
						LastPlaceTween = "secondfloorPart7"
						targetPosition = Vector3.new(3198.9306640625, 2378.380615234375, -20566.5703125)
						targetFloorPosition = Vector3.new(3198.9306640625, 2378.380615234375, -20566.5703125)
						local Distance = (targetPosition - PlayerHumpart.Position).magnitude
						local Time = GetTime(Distance, Speed)
						wait()
						local targetCFrame = CFrame.new(targetPosition)
						tweenWithTeleport(targetCFrame, Speed, selected_Offset)

						local startTime = tick()
						repeat
							success, Npc = pcall(GetImpelNpc)
							wait()
						until Npc or tick() - startTime >= 2
						local GetNpcValue = 0

						for _, Npc in pairs(workspace.NPCs:GetChildren()) do
							if
								Npc:FindFirstChild("HumanoidRootPart")
								and (Npc.HumanoidRootPart.Position - PlayerHumpart.Position).Magnitude <= 100
								and Npc.Name ~= "Mini Bunny"
							then
								GetNpcValue += 1
							end
						end
						if
							GetNpcValue <= 0
							and (
									Vector3.new(3198.9306640625, 2378.380615234375, -20566.5703125)
									- PlayerHumpart.Position
								).magnitude
								< 15
						then
							SecondFloorTable["secondfloorPart7"] = true
						end
					elseif not SecondFloorTable["secondfloorPart8"] and SecondFloorTable["secondfloorPart7"] then
						LastPlaceTween = "secondfloorPart8"
						targetPosition = Vector3.new(3206.496337890625, 2396.688720703125, -20827.0546875)
						targetFloorPosition = targetPosition
						tweenWithTeleport(targetPosition, Speed, selected_Offset)

						local startTime = tick()
						repeat
							wait()
							success, Npc = pcall(GetImpelNpc)
						until Npc or tick() - startTime >= 2
						local GetNpcValue = 0
						for _, npcInWorkspace in pairs(workspace.NPCs:GetChildren()) do
							if
								npcInWorkspace:FindFirstChild("HumanoidRootPart")
								and (npcInWorkspace.HumanoidRootPart.Position - PlayerHumpart.Position).Magnitude <= 100
								and npcInWorkspace.Name ~= "Mini Bunny"
							then
								GetNpcValue += 1
							end
						end

						if
							GetNpcValue <= 0
							and (Vector3.new(3202.12256, 2372.40649, -20873.86725) - PlayerHumpart.Position).magnitude
								< 5
						then
							SecondFloorTable["secondfloorPart8"] = true
						else
							SecondFloorTable["secondfloorPart8"] = false
						end
					elseif not SecondFloorTable["secondfloorPart9"] and SecondFloorTable["secondfloorPart8"] then
						LastPlaceTween = "secondfloorPart9"
						targetPosition = Vector3.new(3199.43359375, 2378.380615234375, -21072.609375)
						targetFloorPosition = Vector3.new(3199.43359375, 2378.380615234375, -21072.609375)
						local Distance = (targetPosition - PlayerHumpart.Position).magnitude
						local Time = GetTime(Distance, Speed)
						wait()
						local targetCFrame = CFrame.new(targetPosition)
						tweenWithTeleport(targetCFrame, Speed, selected_Offset)

						local startTime = tick()
						repeat
							success, Npc = pcall(GetImpelNpc)
							wait()
						until Npc or tick() - startTime >= 2
						local GetNpcValue = 0
						for _, npcInWorkspace in pairs(workspace.NPCs:GetChildren()) do
							if
								npcInWorkspace:FindFirstChild("HumanoidRootPart")
								and (npcInWorkspace.HumanoidRootPart.Position - PlayerHumpart.Position).Magnitude <= 100
								and npcInWorkspace.Name ~= "Mini Bunny"
							then
								GetNpcValue += 1
							end
						end
						if
							GetNpcValue <= 0
							and (
									Vector3.new(3199.43359375, 2378.380615234375, -21072.609375)
									- PlayerHumpart.Position
								).magnitude
								< 5
						then
							DisableAllTweens()
							SecondFloorTable["secondfloorPart9"] = true
							FirstTime = false
						else
							SecondFloorTable["secondfloorPart9"] = false
						end
					elseif not SecondFloorTable["secondfloorPart10"] and SecondFloorTable["secondfloorPart9"] then
						LastPlaceTween = "secondfloorPart10"
						targetPosition = Vector3.new(3202.12256, 2372.40649, -20873.86725)
						targetFloorPosition = Vector3.new(3202.12256, 2372.40649, -20873.86725)
						local Distance = (targetPosition - PlayerHumpart.Position).magnitude
						local Time = GetTime(Distance, Speed)
						wait()
						local targetCFrame = CFrame.new(targetPosition)
						tweenWithTeleport(targetCFrame, Speed, selected_Offset)

						local startTime = tick()
						repeat
							success, Npc = pcall(GetImpelNpc)
							wait()
						until Npc or tick() - startTime >= 2
						local GetNpcValue = 0

						for _, Npc in pairs(workspace.NPCs:GetChildren()) do
							if
								Npc:FindFirstChild("HumanoidRootPart")
								and (Npc.HumanoidRootPart.Position - PlayerHumpart.Position).Magnitude <= 100
								and Npc.Name ~= "Mini Bunny"
							then
								GetNpcValue += 1
							end
						end
						if
							GetNpcValue <= 0
							and (Vector3.new(3202.12256, 2372.40649, -20873.8672) - PlayerHumpart.Position).magnitude
								< 5
						then
							DisableAllTweens()
							SecondFloorTable["secondfloorPart10"] = true
							FirstTime = false
						else
							SecondFloorTable["secondfloorPart10"] = false
						end
					end
				elseif
					workspace.Islands:FindFirstChild("Impel Base - Floor 3")
					and not workspace.Islands:FindFirstChild("Impel Base - Floor 4")
				then
					DonutRunnable = true
					if not FirstTime then
						FirstTime = true
						currentFloor3Boss = nil
						lastBossSeenTime = 0
						wait(2)
					end
					selected_Offset = 3000

					success, Npc = pcall(GetImpelNpc)
					if not success then
						Npc = nil
					end

					-- Check for any boss in the area
					local bossExistsAnywhere = nil
					for _, npcCheck in pairs(workspace.NPCs:GetChildren()) do
						if npcCheck:FindFirstChild("HumanoidRootPart") and npcCheck:GetAttribute("HPScaled") then
							bossExistsAnywhere = npcCheck
							break
						end
					end

					-- Also check if boss exists but might be missing HumanoidRootPart temporarily
					local bossExistsWithoutHRP = nil
					for _, npcCheck in pairs(workspace.NPCs:GetChildren()) do
						if
							npcCheck:GetAttribute("HPScaled")
							and npcCheck:FindFirstChild("Humanoid")
							and npcCheck.Humanoid.Health > 0
						then
							bossExistsWithoutHRP = npcCheck
							break
						end
					end

					-- Track boss engagement
					if bossExistsAnywhere or bossExistsWithoutHRP then
						currentFloor3Boss = bossExistsAnywhere or bossExistsWithoutHRP
						lastBossSeenTime = tick()
					end

					-- Determine if boss is confirmed dead (not just temporarily missing)
					local timeSinceBossSeen = tick() - lastBossSeenTime
					local bossRecentlyExisted = timeSinceBossSeen < BOSS_CONFIRM_DELAY
					local bossConfirmedDead = currentFloor3Boss
						and not bossExistsAnywhere
						and not bossExistsWithoutHRP
						and not bossRecentlyExisted

					-- Reset tracking if boss confirmed dead
					if bossConfirmedDead then
						currentFloor3Boss = nil
						lastBossSeenTime = 0
					end

					local floortocheckforinvisiblepart = "Impel Base - Floor 3"
					if
						workspace.Islands:FindFirstChild(floortocheckforinvisiblepart)
						and workspace.Islands[floortocheckforinvisiblepart]:FindFirstChild("invisible")
					then
						workspace.Islands[floortocheckforinvisiblepart].invisible:Destroy()
					end

					-- Check for lever interactions first
					local leverPulled = false
					if
						workspace.Islands:FindFirstChild("Impel Base - Floor 3")
						and workspace.Islands["Impel Base - Floor 3"]:FindFirstChild("Interactables")
					then
						for _, interactable in
							pairs(workspace.Islands["Impel Base - Floor 3"].Interactables:GetChildren())
						do
							if
								interactable:FindFirstChild("Lever")
								and interactable.Lever:FindFirstChild("Meshes/Lev_Cube.004")
							then
								local leverPart = interactable.Lever["Meshes/Lev_Cube.004"]
								local proximityPrompt = leverPart:FindFirstChild("ProximityPrompt")

								if proximityPrompt and proximityPrompt.Enabled then
									local distance = (leverPart.Position - PlayerHumpart.Position).Magnitude

									if distance <= 5 then
										wait(1)
										fireProximityPromptSafely(proximityPrompt)
										leverPulled = true
										task.wait(1)
										for _, descendant in pairs(workspace:GetDescendants()) do
											if descendant:IsA("Sound") and descendant.Name == "NotificationTick" then
												local attachment = descendant.Parent
												if attachment and attachment:IsA("Attachment") then
													local dist = (attachment.WorldPosition - PlayerHumpart.Position).Magnitude
													if dist < 50 then
														attachment:Destroy()
													end
												end
											end
										end
										break
									end
								end
							end
						end
					end

					if leverPulled then
						return
					end

					local nearbyNpcCount = 0
					local bossNearbyRadius = 350
					local normalNpcRadius = 300

					for _, npcCheck in pairs(workspace.NPCs:GetChildren()) do
						if
							npcCheck:FindFirstChild("HumanoidRootPart")
							and npcCheck:FindFirstChild("Humanoid")
							and npcCheck.Humanoid.Health > 0
						then
							local npcDist = (npcCheck.HumanoidRootPart.Position - PlayerHumpart.Position).Magnitude
							local checkRadius = npcCheck:GetAttribute("HPScaled") and bossNearbyRadius
								or normalNpcRadius
							if npcDist <= checkRadius then
								nearbyNpcCount = nearbyNpcCount + 1
							end
						end
					end

					currentTargetPosition = getNotificationPosition(true)
					if Npc and Npc:FindFirstChild("HumanoidRootPart") then
						local npcPos = Npc.HumanoidRootPart.Position
						local nearestPos = nil
						local nearestDist = math.huge

						for partName, partData in pairs(ThirdFloor) do
							local dist = (partData.Position - npcPos).Magnitude
							if dist < nearestDist then
								nearestDist = dist
								nearestPos = partData.Position
							end
						end

						targetFloorPosition = nearestPos or currentTargetPosition
					else
						targetFloorPosition = currentTargetPosition
					end

					if Npc then
						targetPosition = detectPart()
						if targetPosition then
							controlTower(CFrame.new(targetPosition), Speed)
							CanTween = true
						end
					elseif bossExistsAnywhere and bossExistsAnywhere:FindFirstChild("HumanoidRootPart") then
						local bossPos = bossExistsAnywhere.HumanoidRootPart.Position
						targetFloorPosition = bossPos

						if targetFloorPosition then
							tweenWithTeleport(
								CFrame.new(targetFloorPosition + Vector3.new(0, 30, 0)),
								Speed,
								selected_Offset
							)
						end
					elseif bossExistsWithoutHRP then
						if targetFloorPosition then
							controlTower(CFrame.new(targetFloorPosition + Vector3.new(0, 30, 0)), Speed)
						end
					elseif currentFloor3Boss and bossRecentlyExisted then
						if targetFloorPosition then
							controlTower(CFrame.new(targetFloorPosition + Vector3.new(0, 30, 0)), Speed)
						end
					elseif currentTargetPosition and nearbyNpcCount == 0 then
						LastPlaceTween = "Part" .. StepCounter
						tweenWithTeleport(
							currentTargetPosition,
							Speed,
							selected_Offset,
							{ ThirdFloorNotificationPosition = true }
						)
						task.wait()
					elseif nearbyNpcCount > 0 then
						if targetFloorPosition then
							controlTower(CFrame.new(targetFloorPosition + Vector3.new(0, 30, 0)), Speed)
						end
					end
				elseif
					workspace.Islands:FindFirstChild("Impel Base - Floor 4")
					and not workspace.Islands:FindFirstChild("Impel Base - Floor 5")
				then
					selected_Offset = 1500
					if not SecondTime then
						SecondTime = true
						StepCounter = 0
						task.wait(2)
					end
					local floortocheckforinvisiblepart = "Impel Base - Floor 4"
					if
						workspace.Islands:FindFirstChild(floortocheckforinvisiblepart)
						and workspace.Islands[floortocheckforinvisiblepart]:FindFirstChild("invisible")
					then
						workspace.Islands[floortocheckforinvisiblepart].invisible:Destroy()
					end

					if workspace.Islands["Impel Base - Floor 4"].Barriers:FindFirstChild("FirstBarrier") then
						StepCounter = 1
						FourthFloor["Part1"].Value = false
						FourthFloor["Part2"].Value = false
						FourthFloor["Part3"].Value = false
						FourthFloor["Part4"].Value = false
						FourthFloor["Part5"].Value = false
						FourthFloor["Part6"].Value = false
						FourthFloor["Part7"].Value = false
						FourthFloor["Part8"].Value = false
						FourthFloor["Part9"].Value = false
						FourthFloor["Part10"].Value = false
						FourthFloor["Part11"].Value = false
						FourthFloor["Part12"].Value = false
					elseif workspace.Islands["Impel Base - Floor 4"].Barriers:FindFirstChild("SecondBarrier") then
						StepCounter = 2
						FourthFloor["Part1"].Value = true
						FourthFloor["Part2"].Value = false
						FourthFloor["Part3"].Value = false
						FourthFloor["Part4"].Value = false
						FourthFloor["Part5"].Value = false
						FourthFloor["Part6"].Value = false
						FourthFloor["Part7"].Value = false
						FourthFloor["Part8"].Value = false
						FourthFloor["Part9"].Value = false
						FourthFloor["Part10"].Value = false
						FourthFloor["Part11"].Value = false
						FourthFloor["Part12"].Value = false
					elseif workspace.Islands["Impel Base - Floor 4"].Barriers:FindFirstChild("ThirdBarrier") then
						StepCounter = 3
						FourthFloor["Part1"].Value = true
						FourthFloor["Part2"].Value = true
						FourthFloor["Part3"].Value = false
						FourthFloor["Part4"].Value = false
						FourthFloor["Part5"].Value = false
						FourthFloor["Part6"].Value = false
						FourthFloor["Part7"].Value = false
						FourthFloor["Part8"].Value = false
						FourthFloor["Part9"].Value = false
						FourthFloor["Part10"].Value = false
						FourthFloor["Part11"].Value = false
						FourthFloor["Part12"].Value = false
					elseif workspace.Islands["Impel Base - Floor 4"].Barriers:FindFirstChild("SixthBarrier") then
						StepCounter = 4
						FourthFloor["Part1"].Value = true
						FourthFloor["Part2"].Value = true
						FourthFloor["Part3"].Value = true
						FourthFloor["Part4"].Value = false
						FourthFloor["Part5"].Value = false
						FourthFloor["Part6"].Value = false
						FourthFloor["Part7"].Value = false
						FourthFloor["Part8"].Value = false
						FourthFloor["Part9"].Value = false
						FourthFloor["Part10"].Value = false
						FourthFloor["Part11"].Value = false
						FourthFloor["Part12"].Value = false
					elseif workspace.Islands["Impel Base - Floor 4"].Barriers:FindFirstChild("SeventhBarrier") then
						StepCounter = 5
						FourthFloor["Part1"].Value = true
						FourthFloor["Part2"].Value = true
						FourthFloor["Part3"].Value = true
						FourthFloor["Part4"].Value = true
						FourthFloor["Part5"].Value = false
						FourthFloor["Part6"].Value = false
						FourthFloor["Part7"].Value = false
						FourthFloor["Part8"].Value = false
						FourthFloor["Part9"].Value = false
						FourthFloor["Part10"].Value = false
						FourthFloor["Part11"].Value = false
						FourthFloor["Part12"].Value = false
					elseif workspace.Islands["Impel Base - Floor 4"].Barriers:FindFirstChild("SeventhBarrier2") then
						StepCounter = 6
						FourthFloor["Part1"].Value = true
						FourthFloor["Part2"].Value = true
						FourthFloor["Part3"].Value = true
						FourthFloor["Part4"].Value = true
						FourthFloor["Part5"].Value = true
						FourthFloor["Part6"].Value = false
						FourthFloor["Part7"].Value = false
						FourthFloor["Part8"].Value = false
						FourthFloor["Part9"].Value = false
						FourthFloor["Part10"].Value = false
						FourthFloor["Part11"].Value = false
						FourthFloor["Part12"].Value = false
					elseif
						workspace.Islands["Impel Base - Floor 4"].Barriers:FindFirstChild("EighthBarrier1")
						and workspace.Islands["Impel Base - Floor 4"].Barriers:FindFirstChild("EighthBarrier1").Transparency
							~= 1
					then
						StepCounter = 7
						if number69 == nil and not tonumber(number69) then
							number69 = 0
						end
						number69 += 1
						if number69 >= 20 and not Npc then
							workspace.Islands["Impel Base - Floor 4"].Barriers:FindFirstChild("EighthBarrier1").Transparency =
								1
						end
						FourthFloor["Part1"].Value = true
						FourthFloor["Part2"].Value = true
						FourthFloor["Part3"].Value = true
						FourthFloor["Part4"].Value = true
						FourthFloor["Part5"].Value = true
						FourthFloor["Part6"].Value = true
						FourthFloor["Part7"].Value = false
						FourthFloor["Part8"].Value = false
						FourthFloor["Part9"].Value = false
						FourthFloor["Part10"].Value = false
						FourthFloor["Part11"].Value = false
						FourthFloor["Part12"].Value = false
					elseif workspace.Islands["Impel Base - Floor 4"].Barriers:FindFirstChild("EighthBarrier2") then
						StepCounter = 8
						if workspace.Islands["Impel Base - Floor 4"].Barriers:FindFirstChild("EighthBarrier1") then
							workspace.Islands["Impel Base - Floor 4"].Barriers:FindFirstChild("EighthBarrier1").Transparency =
								0.45
						end
						FourthFloor["Part1"].Value = true
						FourthFloor["Part2"].Value = true
						FourthFloor["Part3"].Value = true
						FourthFloor["Part4"].Value = true
						FourthFloor["Part5"].Value = true
						FourthFloor["Part6"].Value = true
						FourthFloor["Part7"].Value = true
						FourthFloor["Part8"].Value = false
						FourthFloor["Part9"].Value = false
						FourthFloor["Part10"].Value = false
						FourthFloor["Part11"].Value = false
						FourthFloor["Part12"].Value = false
					elseif workspace.Islands["Impel Base - Floor 4"].Barriers:FindFirstChild("NinthZone") then
						StepCounter = 9
						FourthFloor["Part1"].Value = true
						FourthFloor["Part2"].Value = true
						FourthFloor["Part3"].Value = true
						FourthFloor["Part4"].Value = true
						FourthFloor["Part5"].Value = true
						FourthFloor["Part6"].Value = true
						FourthFloor["Part7"].Value = true
						FourthFloor["Part8"].Value = true
						FourthFloor["Part9"].Value = false
						FourthFloor["Part10"].Value = false
						FourthFloor["Part11"].Value = false
						FourthFloor["Part12"].Value = false
					elseif
						(
							not workspace.Effects.Zones:FindFirstChild("End")
							or not workspace.Effects.Zones.End:FindFirstChild("BillboardGui")
						) and not FourthSpawnedBoss
					then
						pcall(function()
							for _, v in pairs(workspace.NPCs:GetChildren()) do
								if v:FindFirstChild("Boss") then
									FourthSpawnedBoss = true
								end
							end
						end)
						StepCounter = 11
						FourthFloor["Part1"].Value = true
						FourthFloor["Part2"].Value = true
						FourthFloor["Part3"].Value = true
						FourthFloor["Part4"].Value = true
						FourthFloor["Part5"].Value = true
						FourthFloor["Part6"].Value = true
						FourthFloor["Part7"].Value = true
						FourthFloor["Part8"].Value = true
						FourthFloor["Part9"].Value = true
						FourthFloor["Part10"].Value = true
						FourthFloor["Part11"].Value = false
						FourthFloor["Part12"].Value = false
					elseif
						(
							workspace.Effects.Zones:FindFirstChild("End")
							and workspace.Effects.Zones.End:FindFirstChild("BillboardGui")
						) or (#workspace.NPCs:GetChildren() == 0 and FourthSpawnedBoss)
					then
						StepCounter = 12
						FourthFloor["Part1"].Value = true
						FourthFloor["Part2"].Value = true
						FourthFloor["Part3"].Value = true
						FourthFloor["Part4"].Value = true
						FourthFloor["Part5"].Value = true
						FourthFloor["Part6"].Value = true
						FourthFloor["Part7"].Value = true
						FourthFloor["Part8"].Value = true
						FourthFloor["Part9"].Value = true
						FourthFloor["Part10"].Value = true
						FourthFloor["Part11"].Value = true
						FourthFloor["Part12"].Value = false
						SecondTime = false
						if (PlayerHumpart.Position - FourthFloor["Part12"].Position).Magnitude <= 5 then
							wait(10)
						end
					end

					if
						workspace.Effects.Zones:FindFirstChild("End")
						and workspace.Effects.Zones.End:FindFirstChild("BillboardGui")
					then
						FourthSpawnedBoss = true
					else
						FourthSpawnedBoss = false
					end

					success, Npc = pcall(GetImpelNpc)
					if not success then
						Npc = nil
					end

					local GetNpcValue = 0

					for _, Npc in pairs(workspace.NPCs:GetChildren()) do
						if
							Npc:FindFirstChild("HumanoidRootPart")
							and (Npc.HumanoidRootPart.Position - PlayerHumpart.Position).Magnitude <= 100
							and Npc.Name ~= "Mini Bunny"
						then
							GetNpcValue += 1
						end
					end

					if Npc then
						targetPosition = detectPart()
						if targetPosition then
							controlTower(CFrame.new(targetPosition), Speed)
							CanTween = true
						end
					elseif
						(Character.Humanoid.Health > 500 or #workspace.NPCs:GetChildren() > 0)
						and Character.Humanoid.Health > 300
						and StepCounter <= 12
						and not FourthFloor["Part" .. StepCounter].Value
						and GetNpcValue <= 0
					then
						FourthFloor["Part" .. StepCounter].Value = true
						LastPlaceTween = "Part" .. StepCounter

						targetPosition = FourthFloor["Part" .. StepCounter].Position
						targetFloorPosition = FourthFloor["Part" .. StepCounter].Position
						local Distance = (targetPosition - PlayerHumpart.Position).magnitude
						local Time = GetTime(Distance, Speed)

						local targetCFrame = CFrame.new(targetPosition)

						tweenWithTeleport(targetCFrame, Speed, selected_Offset)
					end
				elseif
					workspace.Islands:FindFirstChild("Impel Base - Floor 5")
					and not workspace.Islands:FindFirstChild("Impel Base - Finished")
				then
					local floortocheckforinvisiblepart = "Impel Base - Floor 5"
					if
						workspace.Islands:FindFirstChild(floortocheckforinvisiblepart)
						and workspace.Islands[floortocheckforinvisiblepart]:FindFirstChild("invisible")
					then
						workspace.Islands[floortocheckforinvisiblepart].invisible:Destroy()
					end

					local positions = 0
					for _, v in pairs(FifthFloor) do
						if
							targetPosition
							and typeof(targetPosition) == "Vector3"
							and (targetPosition - v.Position).Magnitude > 1000
						then
							positions += 1
						end
						if positions >= 5 then
							Npc = nil
							DisableAllTweens()
						end
					end

					spawn(function()
						if workspace.Islands["Impel Base - Floor 5"].Base:GetChildren()[47]:FindFirstChild("lava") then
							workspace.Islands["Impel Base - Floor 5"].Base:GetChildren()[47].lava:Destroy()
						end
					end)

					if
						workspace.Islands["Impel Base - Floor 5"].Barriers:FindFirstChild("Barrier2")
						or FirstTimeFloor5
					then
						if (PlayerHumpart.Position - FifthFloor["Part1"].Position).Magnitude <= 5 then
							FirstTimeFloor5 = false
						end
						StepCounter = 1
						FifthFloor["Part1"].Value = false
						FifthFloor["Part2"].Value = false
						FifthFloor["Part3"].Value = false
						FifthFloor["Part4"].Value = false
						FifthFloor["Part5"].Value = false
					elseif workspace.Islands["Impel Base - Floor 5"].Barriers:FindFirstChild("Barrier4") then
						StepCounter = 2
						FifthFloor["Part1"].Value = true
						FifthFloor["Part2"].Value = false
						FifthFloor["Part3"].Value = false
						FifthFloor["Part4"].Value = false
						FifthFloor["Part5"].Value = false
					elseif workspace.Islands["Impel Base - Floor 5"].Barriers:FindFirstChild("Barrier5") then
						StepCounter = 3
						FifthFloor["Part1"].Value = true
						FifthFloor["Part2"].Value = true
						FifthFloor["Part3"].Value = false
						FifthFloor["Part4"].Value = false
						FifthFloor["Part5"].Value = false
					elseif workspace.Islands["Impel Base - Floor 5"].Barriers:FindFirstChild("Barrier6") then
						StepCounter = 4
						FifthFloor["Part1"].Value = true
						FifthFloor["Part2"].Value = true
						FifthFloor["Part3"].Value = true
						FifthFloor["Part4"].Value = false
						FifthFloor["Part5"].Value = false
					elseif
						workspace.Islands["Impel Base - Floor 5"].Barriers:FindFirstChild("Barrier7")
						and not workspace.Islands:FindFirstChild("Impel Base - Finished")
					then
						StepCounter = 5
						FifthFloor["Part1"].Value = true
						FifthFloor["Part2"].Value = true
						FifthFloor["Part3"].Value = true
						FifthFloor["Part4"].Value = true
						FifthFloor["Part5"].Value = false
					elseif workspace.Islands:FindFirstChild("Impel Base - Finished") then
						FifthFloor["Part1"].Value = true
						FifthFloor["Part2"].Value = true
						FifthFloor["Part3"].Value = true
						FifthFloor["Part4"].Value = true
						FifthFloor["Part5"].Value = true
						FirstTime = false
					end

					success, Npc = pcall(GetImpelNpc)
					if not success then
						Npc = nil
					end

					if StepCounter > 6 then
						StepCounter = 1
					end

					local GetNpcValue = 0
					for _, npcCheck in pairs(workspace.NPCs:GetChildren()) do
						if
							npcCheck:FindFirstChild("HumanoidRootPart")
							and (npcCheck.HumanoidRootPart.Position - PlayerHumpart.Position).Magnitude <= 150
						then
							GetNpcValue += 1
						end
					end

					if Npc then
						print("NPCCCCC")
						targetPosition = detectPart()
						if string.find(Npc.Name, "Vera", 1, true) then
							VeraEngage(Npc)
							CanTween = true
						elseif targetPosition then
							controlTower(CFrame.new(targetPosition), Speed)
							CanTween = true
						end
					elseif
						Character.Humanoid.Health > 300
						and StepCounter <= 5
						and not workspace.NPCs:FindFirstChild("Warden of Impel Down, Vera")
					then
						print("STEP COUNTERRRR")
						local currentPartPos = FifthFloor["Part" .. StepCounter].Position
						local distToCurrentPart = (PlayerHumpart.Position - currentPartPos).Magnitude

						if distToCurrentPart > 15 then
							LastPlaceTween = "Part" .. StepCounter
							targetFloorPosition = currentPartPos
							targetPosition = currentPartPos
							local targetCFrame = CFrame.new(targetPosition)
							tweenWithTeleport(targetCFrame, Speed, selected_Offset, false)
						elseif GetNpcValue == 0 then
							if not FifthFloor["Part" .. StepCounter].ArrivedAt then
								FifthFloor["Part" .. StepCounter].ArrivedAt = tick()
							end
							local waitedTime = tick() - FifthFloor["Part" .. StepCounter].ArrivedAt
							if waitedTime >= 4 then
								FifthFloor["Part" .. StepCounter].Value = true
								FifthFloor["Part" .. StepCounter].ArrivedAt = nil
							end
							task.wait(0.5)
						else
							FifthFloor["Part" .. StepCounter].ArrivedAt = nil
							for _, npcRetry in pairs(workspace.NPCs:GetChildren()) do
								if
									npcRetry:FindFirstChild("HumanoidRootPart")
									and npcRetry:FindFirstChild("Humanoid")
									and npcRetry.Humanoid.Health > 0
								then
									local npcDist = (npcRetry.HumanoidRootPart.Position - PlayerHumpart.Position).Magnitude
									if npcDist <= 150 then
										targetPosition = npcRetry.HumanoidRootPart.Position + Vector3.new(0, -10, 0)
										targetFloorPosition = currentPartPos
										controlTower(CFrame.new(targetPosition), Speed)
										break
									end
								end
							end
							task.wait(0.3)
						end
					end
				elseif
					workspace:FindFirstChild("Islands") and workspace.Islands:FindFirstChild("Impel Base - Finished")
				then
					if not finishedTime then
						finishedTime = true
						local startTime = tick()
						repeat
							DisableAllTweens()
							wait()
						until tick() - startTime >= 10
					end

					tpedback = false

					targetPosition = Vector3.new(6395.693359375, 653.7778930664062, -27926.84375)
					local Distance = (targetPosition - PlayerHumpart.Position).magnitude
					local Time = GetTime(Distance, Speed)

					task.wait()

					local targetCFrame = CFrame.new(targetPosition)

					local isNightmarePlus = statsFolder.Skills.Kamishiki.Value ~= 20

					local value = statsFolder.Inventory.Inventory.Value
					local MythicalChestCap = value:match('"Mythical Fruit Chest":(%d+)') or 0
					if isNightmarePlus then
						MythicalChestCap = 10 - MythicalChestCap
					else
						MythicalChestCap = tonumber(MythicalChestCap) or 0
						MythicalChestCap = (10 - (MythicalChestValue or 0) - MythicalChestCap)
					end

					local MythicalChest =
						workspace.Islands["Impel Base - Finished"].Models:FindFirstChild("Mythical Fruit Chest")
					if MythicalChest and MythicalChestCap > 0 and not OpenedMythical then
						local text = MythicalChest.Part.ProximityPrompt.ActionText
						local points = extractImpelPoints(text)
						targetPosition = MythicalChest.WorldPivot.Position
						local Distance = (targetPosition - PlayerHumpart.Position).magnitude
						if
							Distance <= 1000
							and tonumber(LocalPlayer.PlayerGui.BattleReportGui.Points.Text) >= tonumber(points)
						then
							local Time = GetTime(Distance, Speed)

							task.wait()

							tweenWithTeleport(targetPosition, Speed)

							task.wait(1)
							if
								MythicalChest:FindFirstChild("Part")
								and MythicalChest.Part:FindFirstChildOfClass("ProximityPrompt")
							then
								local text = MythicalChest.Part.ProximityPrompt.ActionText
								local points = extractImpelPoints(text)
								if tonumber(LocalPlayer.PlayerGui.BattleReportGui.Points.Text) >= tonumber(points) then
									fireProximityPromptSafely(MythicalChest.Part.ProximityPrompt)
									OpenedMythical = true
								end
							end
						else
							OpenedMythical = true
						end
					else
						if not SentWebhook then
							task.wait(3)
							coroutine.wrap(SendWebhook)()
							SentWebhook = true
						end
						targetPosition = Vector3.new(6395.693359375, 653.7778930664062, -27926.84375)
						tweenWithTeleport(targetPosition, Speed)

						task.wait(2)
					end
					task.wait(2)
				end
			end)

			if not success then
				warn("An error occurred:", errorOrReturnValue)
			end
			task.wait()
		end
	end
else
	game:GetService("TeleportService"):Teleport(6360478118)
end