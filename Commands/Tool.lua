




function HandleReplCommand(a_Split, a_Player)
	-- //repl <item>
	
	if a_Split[2] == nil then -- check if the player gave a block id
		a_Player:SendMessage(cChatColor.Rose .. "Too few arguments.")
		a_Player:SendMessage(cChatColor.Rose .. "/repl <block ID>")
		return true
	end
	
	local BlockType, BlockMeta = GetBlockTypeMeta(a_Split[2])
	
	if (not BlockType) then
		a_Player:SendMessage(cChatColor.Rose .. "Unknown character \"" .. a_Split[2] .. "\"")
		return true
	end
	
	if not IsValidBlock(BlockType) then -- check if the player gave a valid block id
		a_Player:SendMessage(cChatColor.Rose .. a_Split[2] .. " isn't a valid block")
		return true
	end
	
	-- Initialize the handler.
	local function ReplaceHandler(a_Player, a_BlockX, a_BlockY, a_BlockZ, a_BlockFace)
		if (a_BlockFace == BLOCK_FACE_NONE) then
			return true
		end
		
		if CheckIfInsideAreas(a_BlockX, a_BlockX, a_BlockY, a_BlockY, a_BlockZ, a_BlockZ, a_Player, a_Player:GetWorld(), "replacetool") then
			return true
		end
		
		a_Player:GetWorld():SetBlock(a_BlockX, a_BlockY, a_BlockZ, BlockType, BlockMeta)
		return false
	end
	
	local State = GetPlayerState(a_Player)
	local Succes, error = State.ToolRegistrator:BindRightClickTool(a_Player:GetEquippedItem().m_ItemType, ReplaceHandler, "replacetool")
	
	if (not Succes) then
		a_Player:SendMessage(cChatColor.Rose .. error)
		return true
	end
	
	a_Player:SendMessage(cChatColor.LightPurple .. "Block replacer tool bound to " .. ItemToString(a_Player:GetEquippedItem()))
	return true
end


------------------------------------------------
----------------------NONE----------------------
------------------------------------------------
function HandleNoneCommand(a_Split, a_Player)
	local State = GetPlayerState(a_Player)
	local Success, error = State.ToolRegistrator:UnbindTool(a_Player:GetEquippedItem().m_ItemType)
	local SuccessMask, errorMask = State.ToolRegistrator:UnbindMask(a_Player:GetEquippedItem().m_ItemType)
	
	if ((not Success) and (not SuccessMask)) then
		a_Player:SendMessage(cChatColor.Rose .. error)
		return true
	end
	
	a_Player:SendMessage(cChatColor.LightPurple .. "Tool unbound from your current item.")
	return true
end
		
	
------------------------------------------------
----------------------TREE----------------------
------------------------------------------------
function HandleTreeCommand(a_Split, a_Player)

	local function HandleTree(a_Player, a_BlockX, a_BlockY, a_BlockZ, a_BlockFace)
		if (a_BlockFace == BLOCK_FACE_NONE) then
			return false
		end
		
		local World = a_Player:GetWorld()
		if (World:GetBlock(a_BlockX, a_BlockY, a_BlockZ) == E_BLOCK_GRASS) or (World:GetBlock(a_BlockX, a_BlockY, a_BlockZ) == E_BLOCK_DIRT) then
			World:GrowTree(a_BlockX, a_BlockY + 1, a_BlockZ)
		else
			a_Player:SendMessage(cChatColor.Rose .. "A tree can't go there.")
		end
	end
	
	local State = GetPlayerState(a_Player)
	local Succes, error = State.ToolRegistrator:BindRightClickTool(a_Player:GetEquippedItem().m_ItemType, HandleTree, "tree")
	
	if (not Succes) then
		a_Player:SendMessage(cChatColor.Rose .. error)
		return true
	end
	
	a_Player:SendMessage(cChatColor.LightPurple .. "Tree tool bound to " .. ItemToString(a_Player:GetEquippedItem()))
	return true
end


-----------------------------------------------
-------------------SUPERPICK-------------------
-----------------------------------------------
function HandleSuperPickCommand(a_Split, a_Player)
	-- //
	-- /,
	
	-- A table containing all the ID's of the pickaxes
	local Pickaxes = 
	{
		E_ITEM_WOODEN_PICKAXE,
		E_ITEM_STONE_PICKAXE,
		E_ITEM_IRON_PICKAXE,
		E_ITEM_GOLD_PICKAXE,
		E_ITEM_DIAMOND_PICKAXE,
	}
	
	-- The handler that breaks the block of the superpickaxe.
	local function SuperPickaxe(a_Player, a_BlockX, a_BlockY, a_BlockZ, a_BlockFace)
		if CheckIfInsideAreas(a_BlockX, a_BlockX, a_BlockY, a_BlockY, a_BlockZ, a_BlockZ, a_Player, a_Player:GetWorld(), "superpickaxe") then
			return true
		end
		
		local World = a_Player:GetWorld()
		World:BroadcastSoundParticleEffect(2001, a_BlockX, a_BlockY, a_BlockZ, World:GetBlock(a_BlockX, a_BlockY, a_BlockZ))
		World:DigBlock(a_BlockX, a_BlockY, a_BlockZ)
	end
	
	local State = GetPlayerState(a_Player)
	
	-- Check if at least one of the pickaxe types has the superpickaxe tool. 
	-- If not then we bind the superpickaxe tool, otherwise unbind all the pickaxes
	local WasActivated = false
	for Idx, Pickaxe in ipairs(Pickaxes) do
		local Info = State.ToolRegistrator:GetLeftClickCallbackInfo(Pickaxe)
		if (Info) then
			WasActivated = WasActivated or (Info.ToolName == "superpickaxe")
		end
	end
	
	if (WasActivated) then
		a_Player:SendMessage(cChatColor.LightPurple .. "Super pick axe disabled")
		State.ToolRegistrator:UnbindTool(Pickaxes, "superpickaxe")
	else
		a_Player:SendMessage(cChatColor.LightPurple .. "Super pick axe enabled")
		State.ToolRegistrator:BindLeftClickTool(Pickaxes, SuperPickaxe, "superpickaxe")
	end
	
	return true
end



