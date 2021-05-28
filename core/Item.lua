function BiSTracker:CharacterHasItem(itemId)
	local hasItem = false;
	if IsEquippedItem(itemId) then
		hasItem = true;
	else
		for bagSlot = 0, NUM_BAG_SLOTS do
		    for containerSlot = 1, GetContainerNumSlots(bagSlot) do
		        if GetContainerItemID(bagSlot, containerSlot) == itemId then
		        	hasItem = true;
		            break
		        end
		    end
		end
	end
	return hasItem;
end

function BiSTracker:GetItemData(itemId)
	if (BiSTracker.QuestieDB == nil) then
		return
	end

	local item = BiSTracker.QuestieDB:GetItem(itemId)
	print(itemId.." sources:")
	for k,v in pairs(item) do
		print(k)
	end
	
	for k,v in pairs(item.Sources) do
		print(k)
		print(v)
		print("------")
	end
	

end