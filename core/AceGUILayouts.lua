BiSTracker.AceGUI:RegisterLayout("BiSTrackerSheet",
	function(content, children)
		local height = 0
		local width = content.width or content:GetWidth() or 0
		for i = 1, #children do
			local child = children[i]

			local frame = child.frame
			frame:ClearAllPoints()
            frame:Show()
            
            if i == 1 then
                frame:SetPoint("TOPLEFT", content, 0, 10) 	-- TopLeftButtonGroup
            elseif i == 2 then
                frame:SetPoint("TOPRIGHT", content, 0, 10) 	-- TopRightButtonGroup
            elseif i == 3 then
                frame:SetPoint("TOP", content, 0, 5) 		-- SetName
            elseif i == 4 then
                frame:SetPoint("TOPLEFT", content, 0, -30) 	-- LeftSlots
            elseif i == 5 then
                frame:SetPoint("BOTTOM", content, 0, 40)	-- BottomSlots
            elseif i == 6 then
                frame:SetPoint("TOPRIGHT", content, 0, -30) -- RightSlots
            elseif i == 7 then
                frame:SetPoint("BOTTOM", content, 0, -5) 	-- ActionsGroup
            end

			if child.width == "fill" then
				child:SetWidth(width)
				frame:SetPoint("RIGHT", content)

				if child.DoLayout then
					child:DoLayout()
				end
			elseif child.width == "relative" then
				child:SetWidth(width * child.relWidth)

				if child.DoLayout then
					child:DoLayout()
				end
			end

			height = height + (frame.height or frame:GetHeight() or 0)
		end
    end)

BiSTracker.AceGUI:RegisterLayout("BiSTrackerSheetCompact",
	function(content, children)
		local height = 0
		local width = content.width or content:GetWidth() or 0
		for i = 1, #children do
			local child = children[i]

			local frame = child.frame
			frame:ClearAllPoints()
            frame:Show()
            
            if i == 1 then
                frame:SetPoint("TOPLEFT", content, 0, 10) 	-- TopLeftButtonGroup
            elseif i == 2 then
                frame:SetPoint("TOPRIGHT", content, 0, 10) 	-- TopRightButtonGroup
            elseif i == 3 then
                frame:SetPoint("TOP", content, 0, 5) 		-- SetName
            elseif i == 4 then
                frame:SetPoint("TOP", content, 0, -20) 	-- SlotsList
            elseif i == 5 then
                frame:SetPoint("BOTTOM", content, 0, -5) 	-- ActionsGroup
            end

			if child.width == "fill" then
				child:SetWidth(width)
				frame:SetPoint("RIGHT", content)

				if child.DoLayout then
					child:DoLayout()
				end
			elseif child.width == "relative" then
				child:SetWidth(width * child.relWidth)

				if child.DoLayout then
					child:DoLayout()
				end
			end

			height = height + (frame.height or frame:GetHeight() or 0)
		end
    end)
    
BiSTracker.AceGUI:RegisterLayout("BiSTrackerEditSlot",
    function(content, children)

		local height = 0
		local width = content.width or content:GetWidth() or 0
		for i = 1, #children do
			local child = children[i]

			local frame = child.frame
			frame:ClearAllPoints()
            frame:Show()
            
            if i == 1 then
                frame:SetPoint("TOP", content, 0, 10) -- ID
            elseif i == 2 then
                frame:SetPoint("TOP", content, 0, -35) -- Obtain Method
            elseif i == 3 then
                frame:SetPoint("TOP", content, 0, -80) -- Obtain ID
            elseif i == 4 then
                frame:SetPoint("TOP", content, 0, -125) -- Zone
            elseif i == 5 then
                frame:SetPoint("TOP", content, 0, -170) -- Npc Name
            elseif i == 6 then
                frame:SetPoint("TOP", content, 0, -215) -- Drop Chance
            elseif i == 7 then
                frame:SetPoint("BOTTOMLEFT", content, 0, 0) -- Cancel Button
            elseif i == 8 then
                frame:SetPoint("BOTTOMRIGHT", content, 0, 0) -- Save Button
            end

			if child.width == "fill" then
				child:SetWidth(width)
				frame:SetPoint("RIGHT", content)

				if child.DoLayout then
					child:DoLayout()
				end
			elseif child.width == "relative" then
				child:SetWidth(width * child.relWidth)

				if child.DoLayout then
					child:DoLayout()
				end
			end

			height = height + (frame.height or frame:GetHeight() or 0)
		end
    end)

BiSTracker.AceGUI:RegisterLayout("BiSTrackerConfirmDelete",
    function(content, children)

		local height = 0
		local width = content.width or content:GetWidth() or 0
		for i = 1, #children do
			local child = children[i]

			local frame = child.frame
			frame:ClearAllPoints()
            frame:Show()
            
            if i == 1 then
                frame:SetPoint("TOP", content, 0, 0) -- Text
            elseif i == 2 then
                frame:SetPoint("BOTTOMLEFT", content, 0, 0) -- Cancel Button
            elseif i == 3 then
                frame:SetPoint("BOTTOMRIGHT", content, 0, 0) -- Confirm Button
            end

			if child.width == "fill" then
				child:SetWidth(width)
				frame:SetPoint("RIGHT", content)

				if child.DoLayout then
					child:DoLayout()
				end
			elseif child.width == "relative" then
				child:SetWidth(width * child.relWidth)

				if child.DoLayout then
					child:DoLayout()
				end
			end

			height = height + (frame.height or frame:GetHeight() or 0)
		end
	end)

BiSTracker.AceGUI:RegisterLayout("BiSTrackerCompactListItem",
    function(content, children)

		for i = 1, #children do
			local child = children[i]

			local frame = child.frame
			frame:ClearAllPoints()
            frame:Show()
            
            if i == 1 then
                frame:SetPoint("TOPLEFT", content, 0, 0) -- Item Icon
            elseif i == 2 then
                frame:SetPoint("TOPLEFT", content, 20, -7) -- Item Name
            elseif i == 3 then
                frame:SetPoint("TOPRIGHT", content, 0, 0) -- Acquired Icon
            end
		end
	end)