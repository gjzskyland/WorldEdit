
function Initialize(Plugin)
	OnePlayerX = {}
	OnePlayerY = {}
	OnePlayerZ = {}
	TwoPlayerX = {}
	TwoPlayerY = {}
	TwoPlayerZ = {}
	Blocks = {}
	SP = {}
	PLUGIN = Plugin
	PLUGIN:SetName("WorldEdit")
	PLUGIN:SetVersion(1)
	
	PluginManager = cRoot:Get():GetPluginManager()
	PluginManager:AddHook(PLUGIN, cPluginManager.HOOK_PLAYER_BREAKING_BLOCK)
	PluginManager:AddHook(PLUGIN, cPluginManager.HOOK_PLAYER_RIGHT_CLICK)
	PluginManager:AddHook(PLUGIN, cPluginManager.HOOK_PLAYER_LEFT_CLICK)
	
	PluginManager:BindCommand("//set",	    "worldedit.set",	HandleSetCommand,   		" - switches volume selection mode")
	PluginManager:BindCommand("//replace",  "worldedit.replace", HandleReplaceCommand, " - switches volume selection mode")
	PluginManager:BindCommand("//wand",	    "worldedit.wand",	HandleWandCommand,   		" - switches volume selection mode")
	PluginManager:BindCommand("//setbiome",	"worldedit.setbiome",	HandleSetBiomeCommand,   		" - switches volume selection mode")
	PluginManager:BindCommand("/biomelist",	"worldedit.biomelist",	HandleBiomeListCommand,   		" - switches volume selection mode")
	PluginManager:BindCommand("/snow",	"worldedit.snow",	HandleSnowCommand,   		" - switches volume selection mode")
	PluginManager:BindCommand("/thaw",	"worldedit.thaw",	HandleThawCommand,   		" - switches volume selection mode")
	PluginManager:BindCommand("//",	        "worldedit.superpick",	HandleSuperPickCommand,   		" - switches volume selection mode")

	LoadSettings()
	LOG("Initialized " .. PLUGIN:GetName() .. " v" .. PLUGIN:GetVersion())
	return true
end

function HandleWandCommand( Split, Player )
	Item = cItem( E_ITEM_WOODEN_AXE, 1 )
	if( Player:GetInventory():AddItem( Item ) == true ) then
		Player:SendMessage( cChatColor.Green .. "You have a wooden axe now." )
	else
		Player:SendMessage( cChatColor.Green .. "Not enough inventory space" )
	end
	return true
end

function LoadSettings()
	SettingsIni = cIniFile( PLUGIN:GetLocalDirectory() .. "/Config.ini" )
	SettingsIni:ReadFile()
	Wand = SettingsIni:GetValueSetI("General", "Wand", 271 )
	
	SettingsIni:WriteFile()
end

function HandleSuperPickCommand( Split, Player )
	if SP[Player:GetName()] == nil or SP[Player:GetName()] == false then
		SP[Player:GetName()] = true
		Player:SendMessage( cChatColor.LightPurple .. "Super pick deactivated" )
	elseif SP[Player:GetName()] == true then
		SP[Player:GetName()] = false
		Player:SendMessage( cChatColor.LightPurple .. "Super pick activated" )
	end
	return true
end

function HandleThawCommand( Split, Player )
	World = Player:GetWorld()
	if Split[2] == nil then
		Radius = 5
	elseif tonumber(Split[2]) == nil then
		Player:SendMessage( cChatColor.Green .. "Usage: /snow [Radius]" )
	else
		Radius = Split[2]
	end
	X = Player:GetPosX()
	Z = Player:GetPosZ()
	for x=X - Radius, X + Radius do
		for z=Z - Radius, Z + Radius do
			y = World:GetHeight(x, z)
			if World:GetBlock(x, y, z) == 78 then
				World:SetBlock(x, y, z, 0, 0)
			elseif World:GetBlock(x, y, z) == 79 then
				World:SetBlock(x, y, z, 8, 0)
			end
		end
	end
	return true
end

function HandleSnowCommand( Split, Player )
	World = Player:GetWorld()
	if Split[2] == nil then
		Radius = 5
	elseif tonumber(Split[2]) == nil then
		Player:SendMessage( cChatColor.Green .. "Usage: /snow [Radius]" )
	else
		Radius = Split[2]
	end
	X = Player:GetPosX()
	Z = Player:GetPosZ()
	for x=X - Radius, X + Radius do
		for z=Z - Radius, Z + Radius do
			y = World:GetHeight(x, z)
			if World:GetBlock(x, y, z) == 8 then
				World:SetBlock(x, y, z, 79, 0)
			elseif World:GetBlock(x, y, z) == 10 then
				World:SetBlock(x, y, z, 49, 0)
			else
				World:SetBlock(x, y + 1, z, 78, 0)
			end
		end
	end
	return true
end

function OnPlayerBreakingBlock(Player, BlockX, BlockY, BlockZ, BlockFace, BlockType, BlockMeta)
	if Player:GetEquippedItem().m_ItemType == 271 then
		OnePlayerX[Player:GetName()] = BlockX
		OnePlayerY[Player:GetName()] = BlockY
		OnePlayerZ[Player:GetName()] = BlockZ
		if OnePlayerX[Player:GetName()] ~= nil and TwoPlayerX[Player:GetName()] ~= nil then
			if OnePlayerX[Player:GetName()] < TwoPlayerX[Player:GetName()] then
				OneX = OnePlayerX[Player:GetName()]
				TwoX = TwoPlayerX[Player:GetName()]
			else
				OneX = TwoPlayerX[Player:GetName()]
				TwoX = OnePlayerX[Player:GetName()]
			end
			if OnePlayerY[Player:GetName()] < TwoPlayerY[Player:GetName()] then
				OneY = OnePlayerY[Player:GetName()]
				TwoY = TwoPlayerY[Player:GetName()]
			else
				OneY = TwoPlayerY[Player:GetName()]
				TwoY = OnePlayerY[Player:GetName()]
			end
			if OnePlayerZ[Player:GetName()] < TwoPlayerZ[Player:GetName()] then
				OneZ = OnePlayerZ[Player:GetName()]
				TwoZ = TwoPlayerZ[Player:GetName()]
			else
				OneZ = TwoPlayerZ[Player:GetName()]
				TwoZ = OnePlayerZ[Player:GetName()]
			end
			Blocks[Player:GetName()] = 0
			for X = OneX, TwoX do
				for Y = OneY, TwoY do
					for Z = OneZ, TwoZ do
						Blocks[Player:GetName()] = Blocks[Player:GetName()] + 1
					end
				end
			end
			Player:SendMessage( cChatColor.LightPurple .. 'First position set to (' .. BlockX .. ".0, " .. BlockY .. ".0, " .. BlockZ .. ".0) (" .. Blocks[Player:GetName()] .. ")." )
		else
			Player:SendMessage( cChatColor.LightPurple .. 'First position set to (' .. BlockX .. ".0, " .. BlockY .. ".0, " .. BlockZ .. ".0)." )
		end
		return true
	end
end

function OnPlayerLeftClick(Player, BlockX, BlockY, BlockZ, BlockFace, CursorX, CursorY, CursorZ)
	if SP[Player:GetName()] == true then
		World = Player:GetWorld()
		World:SetBlock( BlockX, BlockY, BlockZ, 0, 0 ) 
	end
end

function OnPlayerRightClick(Player, BlockX, BlockY, BlockZ, BlockFace, CursorX, CursorY, CursorZ)
	if Player:GetEquippedItem().m_ItemType == 271 then
		if BlockX == -1 and BlockZ == -1 and BlockY == 255 then
			return false
		end
		TwoPlayerX[Player:GetName()] = BlockX
		TwoPlayerY[Player:GetName()] = BlockY
		TwoPlayerZ[Player:GetName()] = BlockZ
		if OnePlayerX[Player:GetName()] ~= nil and TwoPlayerX[Player:GetName()] ~= nil then
			if OnePlayerX[Player:GetName()] < TwoPlayerX[Player:GetName()] then
				OneX = OnePlayerX[Player:GetName()]
				TwoX = TwoPlayerX[Player:GetName()]
			else
				OneX = TwoPlayerX[Player:GetName()]
				TwoX = OnePlayerX[Player:GetName()]
			end
			if OnePlayerY[Player:GetName()] < TwoPlayerY[Player:GetName()] then
				OneY = OnePlayerY[Player:GetName()]
				TwoY = TwoPlayerY[Player:GetName()]
			else
				OneY = TwoPlayerY[Player:GetName()]
				TwoY = OnePlayerY[Player:GetName()]
			end
			if OnePlayerZ[Player:GetName()] < TwoPlayerZ[Player:GetName()] then
				OneZ = OnePlayerZ[Player:GetName()]
				TwoZ = TwoPlayerZ[Player:GetName()]
			else
				OneZ = TwoPlayerZ[Player:GetName()]
				TwoZ = OnePlayerZ[Player:GetName()]
			end
			Blocks[Player:GetName()] = 0
			for X = OneX, TwoX do
				for Y = OneY, TwoY do
					for Z = OneZ, TwoZ do
						Blocks[Player:GetName()] = Blocks[Player:GetName()] + 1
					end
				end
			end
			Player:SendMessage( cChatColor.LightPurple .. 'Second position set to (' .. BlockX .. ".0, " .. BlockY .. ".0, " .. BlockZ .. ".0) (" .. Blocks[Player:GetName()] .. ")." )
		else
			Player:SendMessage( cChatColor.LightPurple .. 'Second position set to (' .. BlockX .. ".0, " .. BlockY .. ".0, " .. BlockZ .. ".0)." )
		end
		return true
	end
end

function HandleBiomeListCommand( Split, Player )
	if Split[2] == nil then 
		Split[2] = 1 
	end
	if tonumber(Split[2]) == 1 then
		Player:SendMessage( cChatColor.Green .. "Page 1" )
		Player:SendMessage( "Ocean" )
		Player:SendMessage( "Plains" )
		Player:SendMessage( "Desert" )
		Player:SendMessage( "Extreme_Hills" )
		Player:SendMessage( "Forest" )
		Player:SendMessage( "Taiga" )
		Player:SendMessage( "Swampland" )
		Player:SendMessage( "River" )
	elseif tonumber(Split[2]) == 2 then
		Player:SendMessage( cChatColor.Green .. "Page 2" )
		Player:SendMessage( "Hell" )
		Player:SendMessage( "Sky" )
		Player:SendMessage( "FrozenOcean" )
		Player:SendMessage( "FrozenRiver" )
		Player:SendMessage( "Ice_Plains" )
		Player:SendMessage( "Ice_Mountains" )
		Player:SendMessage( "MushroomIsland" )
		Player:SendMessage( "MushroomIslandShore" )
	elseif tonumber(Split[2]) == 3 then
		Player:SendMessage( cChatColor.Green .. "Page 3" )
		Player:SendMessage( "Beach" )
		Player:SendMessage( "DesertHills" )
		Player:SendMessage( "ForestHills" )
		Player:SendMessage( "TaigaHills " )
		Player:SendMessage( "Extreme_Hills_Edge" )
		Player:SendMessage( "Jungle" )
		Player:SendMessage( "JungleHills" )
	else
		Player:SendMessage( "/biomelist [Page]" )
	end
	return true
end

function SetBiomeFromString( Split, Player )
	Split[2] = string.upper(Split[2])
	if Split[2] == "OCEAN" then
		return 0
	elseif Split[2] == "PLAINS" then
		return 1
	elseif Split[2] == "DESERT" then
		return 2
	elseif Split[2] == "EXTEME_HILLS" then
		return 3
	elseif Split[2] == "FOREST" then
		return 4
	elseif Split[2] == "TAIGA" then
		return 5
	elseif Split[2] == "SWAMPLAND" then
		return 6
	elseif Split[2] == "RIVER" then
		return 7
	elseif Split[2] == "HELL" then
		return 8
	elseif Split[2] == "SKY" then
		return 9
	elseif Split[2] == "FROZENOCEAN" then
		return 10
	elseif Split[2] == "FROZENRIVER" then
		return 11
	elseif Split[2] == "ICE_PLAINS" then
		return 12
	elseif Split[2] == "ICE_MOUNTAINS" then
		return 13
	elseif Split[2] == "MUSHROOMISLAND" then
		return 14
	elseif Split[2] == "MUSHROOMISLANDSHORE" then
		return 15
	elseif Split[2] == "BEACH" then
		return 16
	elseif Split[2] == "DESERTHILLS" then
		return 17
	elseif Split[2] == "FORESTHILLS" then
		return 18
	elseif Split[2] == "TAIGAHILLS" then
		return 19
	elseif Split[2] == "EXTEME_HILLS_EDGE" then
		return 20
	elseif Split[2] == "JUNGLE" then
		return 21
	elseif Split[2] == "JUNGLEHILLS" then
		return 22
	else
		return false
	end
end

function HandleSetBiomeCommand( Split, Player )
	if Split[2] == nil then
		Player:SendMessage( cChatColor.Rose .. "Please say a biome" )
		return true
	end
	if OnePlayerX[Player:GetName()] == nil or TwoPlayerX[Player:GetName()] == nil then
		Player:SendMessage( cChatColor.Rose .. "No Region set" )
		return true
	end
	Biome = SetBiomeFromString( Split, Player )
	if Biome == false then
		Player:SendMessage( "Please specify a valid biome" )
		return true
	end
	--World = Player:GetWorld()
	if OnePlayerX[Player:GetName()] < TwoPlayerX[Player:GetName()] then
		OneX = OnePlayerX[Player:GetName()]
		TwoX = TwoPlayerX[Player:GetName()]
	else
		OneX = TwoPlayerX[Player:GetName()]
		TwoX = OnePlayerX[Player:GetName()]
	end
	if OnePlayerZ[Player:GetName()] < TwoPlayerZ[Player:GetName()] then
		OneZ = OnePlayerZ[Player:GetName()]
		TwoZ = TwoPlayerZ[Player:GetName()]
	else
		OneZ = TwoPlayerZ[Player:GetName()]
		TwoZ = OnePlayerZ[Player:GetName()]
	end
	for X=OneX, TwoX do
		for Z=OneZ, TwoZ do
			cChunkDesc:SetBiome( X, Z, Biome )
		end
	end
end

function HandleSetCommand( Split, Player )
	if OnePlayerX[Player:GetName()] == nil or TwoPlayerX[Player:GetName()] == nil then
		Player:SendMessage( cChatColor.Rose .. "No Region set" )
		return true
	end
	if Split[2] == nil then
		Player:SendMessage( cChatColor.Rose .. "Please say a block ID" )
	end
	Block = StringSplit( Split[2], ":" )
	if Block[1] == nil then
		Block[1] = 0
	end
	if Block[2] == nil then
		Block[2] = 0
	end
	if OnePlayerX[Player:GetName()] < TwoPlayerX[Player:GetName()] then
		OneX = OnePlayerX[Player:GetName()]
		TwoX = TwoPlayerX[Player:GetName()]
	else
		OneX = TwoPlayerX[Player:GetName()]
		TwoX = OnePlayerX[Player:GetName()]
	end
	if OnePlayerY[Player:GetName()] < TwoPlayerY[Player:GetName()] then
		OneY = OnePlayerY[Player:GetName()]
		TwoY = TwoPlayerY[Player:GetName()]
	else
		OneY = TwoPlayerY[Player:GetName()]
		TwoY = OnePlayerY[Player:GetName()]
	end
	if OnePlayerZ[Player:GetName()] < TwoPlayerZ[Player:GetName()] then
		OneZ = OnePlayerZ[Player:GetName()]
		TwoZ = TwoPlayerZ[Player:GetName()]
	else
		OneZ = TwoPlayerZ[Player:GetName()]
		TwoZ = OnePlayerZ[Player:GetName()]
	end
	World = Player:GetWorld()
	BlockArea = cBlockArea()
	BlockArea:Read( World, OneX, TwoX, OneY, TwoY, OneZ, TwoZ )
	BlockArea:Fill( 1, Block[1], Block[2] )
	BlockArea:Write( World, OneX, OneY, OneZ )
	--[[for X=OneX, TwoX do
		for Z=OneZ, TwoZ do
			for Y=OneY,TwoY do
				World:SetBlock(X, Y, Z, Block[1], Block[2])
			end
		end
	end]]
	Player:SendMessage( cChatColor.LightPurple .. Blocks[Player:GetName()] .. " block(s) have been changed." )
	return true
end




function HandleReplaceCommand( Split, Player )
	if OnePlayerX[Player:GetName()] == nil or TwoPlayerX[Player:GetName()] == nil then
		Player:SendMessage( cChatColor.Rose .. "No Region set" )
		return true
	end
	if Split[2] == nil or Split[3] == nil then
		Player:SendMessage( cChatColor.Rose .. "Please say a block ID" )
	end
	ChangeBlock = StringSplit( Split[2], ":" )
	if ChangeBlock[1] == nil then
		ChangeBlock[1] = 0
	end
	if ChangeBlock[2] == nil then
		ChangeBlock[2] = 0
	end
	ToChangeBlock = StringSplit( Split[3], ":" )
	if ToChangeBlock[1] == nil then
		ToChangeBlock[1] = 0
	end
	if ToChangeBlock[2] == nil then
		ToChangeBlock[2] = 0
	end
	ChangeBlock[1] = tonumber(ChangeBlock[1])
	ChangeBlock[2] = tonumber(ChangeBlock[2])
	ToChangeBlock[1] = tonumber(ToChangeBlock[1])
	ToChangeBlock[2] = tonumber(ToChangeBlock[2])
	if OnePlayerX[Player:GetName()] < TwoPlayerX[Player:GetName()] then
		OneX = OnePlayerX[Player:GetName()]
		TwoX = TwoPlayerX[Player:GetName()]
	else
		OneX = TwoPlayerX[Player:GetName()]
		TwoX = OnePlayerX[Player:GetName()]
	end
	if OnePlayerY[Player:GetName()] < TwoPlayerY[Player:GetName()] then
		OneY = OnePlayerY[Player:GetName()]
		TwoY = TwoPlayerY[Player:GetName()]
	else
		OneY = TwoPlayerY[Player:GetName()]
		TwoY = OnePlayerY[Player:GetName()]
	end
	if OnePlayerZ[Player:GetName()] < TwoPlayerZ[Player:GetName()] then
		OneZ = OnePlayerZ[Player:GetName()]
		TwoZ = TwoPlayerZ[Player:GetName()]
	else
		OneZ = TwoPlayerZ[Player:GetName()]
		TwoZ = OnePlayerZ[Player:GetName()]
	end
	World = Player:GetWorld()
	Blocks[Player:GetName()] = 0
	for X=OneX, TwoX do
		for Z=OneZ, TwoZ do
			for Y=OneY,TwoY do
				if World:GetBlock(X, Y, Z) == ChangeBlock[1] then 
					if World:GetBlockMeta(X, Y, Z) == ChangeBlock[2] then
						Blocks[Player:GetName()] = Blocks[Player:GetName()] + 1
						World:FastSetBlock(X, Y, Z, ToChangeBlock[1], ToChangeBlock[2])
					end
				end
			end
		end
	end
	Player:SendMessage( cChatColor.LightPurple .. Blocks[Player:GetName()] .. " block(s) have been changed." )
	return true
end