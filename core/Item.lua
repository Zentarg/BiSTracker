function BiSTracker:CharacterHasItem(itemId)
	local hasItem = false;
	if IsEquippedItem(itemId) then
		hasItem = true;
	else
		for bagSlot = 0, NUM_BAG_SLOTS do
			if (C_Container) then
				for containerSlot = 1, C_Container.GetContainerNumSlots(bagSlot) do
						if C_Container.GetContainerItemID(bagSlot, containerSlot) == itemId then
							hasItem = true;
							break
						end
				end
			else
				for containerSlot = 1, GetContainerNumSlots(bagSlot) do
					if GetContainerItemID(bagSlot, containerSlot) == itemId then
						hasItem = true;
						break
					end
				end
			end
		end
	end
	return hasItem;
end