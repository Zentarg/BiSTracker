BiSTracker.MainFrame = BiSTracker.AceGUI:Create("Window")
BiSTracker.MainFrame:Hide()

local ClassList = {}
BiSTracker.ClassSetList = {}

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
                frame:SetPoint("TOPLEFT", content, 0, 10)
            elseif i == 2 then
                frame:SetPoint("TOPRIGHT", content, 0, 10)
            elseif i == 3 then
                frame:SetPoint("TOP", content)
            elseif i == 4 then
                frame:SetPoint("TOPLEFT", content, 0, -30)
            elseif i == 5 then
                frame:SetPoint("BOTTOM", content, 0, 40)
            elseif i == 6 then
                frame:SetPoint("TOPRIGHT", content, 0, -30)
            elseif i == 7 then
                frame:SetPoint("BOTTOM", content, 0, -10)
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

local inventorySlotName = {
    Head = "HEADSLOT",
    Neck = "NECKSLOT",
    Shoulder = "SHOULDERSLOT",
    Back = "BACKSLOT",
    Chest = "CHESTSLOT",
    Shirt = "SHIRTSLOT",
    Tabard = "TABARDSLOT",
    Wrists = "WRISTSLOT",
    Hands = "HANDSSLOT",
    Waist = "WAISTSLOT",
    Legs = "LEGSSLOT",
    Feet = "FEETSLOT",
    Finger = "FINGER0SLOT",
    RFinger = "FINGER1SLOT",
    Trinket = "TRINKET0SLOT",
    RTrinket = "TRINKET1SLOT",
    MainHand = "MAINHANDSLOT",
    SecondaryHand = "SECONDARYHANDSLOT",
    Relic = "RANGEDSLOT"
}

local function UpdateModelFrame()
	BiSTracker.MainFrame.Model:SetAllPoints(BiSTracker.MainFrame.frame)
	BiSTracker.MainFrame.Model:SetModelScale(0.75)
	BiSTracker.MainFrame.Model:SetUnit("PLAYER")
	BiSTracker.MainFrame.Model:SetCustomCamera(1)
	BiSTracker.MainFrame.Model:SetPosition(0,0,0)
	BiSTracker.MainFrame.Model:SetLight(true, false, 0, 0.8, -1, 1, 1, 1, 1, 0.3, 1, 1, 1)
end

function BiSTracker.MainFrame:UpdateSetDisplay()
    UpdateModelFrame()
    BiSTracker.MainFrame.SetName:SetText(BiSTracker.SelectedSetName)


    if (BiSTracker.SelectedSetName == nil) then
        for k, v in pairs(BiSTracker.MainFrame.Slots) do
            if (type(k) == "number") then
                BiSTracker.MainFrame.Slots[v]:SetImage(BiSTracker.MainFrame.DefaultSlotIcons[v])
                BiSTracker.MainFrame.Model:UndressSlot(GetInventorySlotInfo(inventorySlotName[v]))
                BiSTracker.MainFrame.Slots[v]:SetCallback("OnEnter", function()
                    GameTooltip:SetText("")
                end)
            end
        end
    else
        local SelectedSetSlots = None

        if (BiSTracker.SelectedClass ~= "Custom") then
            SelectedSetSlots = BiSData[BiSTracker.SelectedClass][BiSTracker.SelectedSetName]
        else
            SelectedSetSlots = BiSTracker.Settings.CustomSpecs[BiSTracker.SelectedSetName].Slots
        end
        local errorOccured = false
        for key, value in pairs(SelectedSetSlots) do
            if (value.ID == 0) then
                BiSTracker.MainFrame.Slots[key]:SetImage(BiSTracker.MainFrame.DefaultSlotIcons[key])
                BiSTracker.MainFrame.Slots[key]:SetCallback("OnEnter", function()
                end)
            else
                local _,itemLink,_,_,_,_,_,_,_,itemTexture,_,_,_,_,_,_,_ = GetItemInfo(value.ID)
                if (itemLink == nil) then
                    errorOccured = true
                    BiSTracker.MainFrame.Model:UndressSlot(GetInventorySlotInfo(inventorySlotName[key]))
                    BiSTracker.MainFrame.Slots[key]:SetImage(BiSTracker.MainFrame.DefaultSlotIcons[key])
                    BiSTracker.MainFrame.Slots[key]:SetCallback("OnEnter", function()
                        GameTooltip:SetOwner(BiSTracker.MainFrame.Slots[key].frame, "ANCHOR_RIGHT")
                        GameTooltip:SetText("|cffff0000An error occured while loading this item.\nPlease try reloading the set.")
                    end)
                else
                    if (key ~= "Relic" or BiSTracker.SelectedClass == "Hunter") then
                        BiSTracker.MainFrame.Model:TryOn(itemLink)
                    end
                    BiSTracker.MainFrame.Slots[key]:SetImage(itemTexture)
                    BiSTracker.MainFrame.Slots[key]:SetCallback("OnEnter", function()
                        GameTooltip:SetOwner(BiSTracker.MainFrame.Slots[key].frame, "ANCHOR_RIGHT")
                        GameTooltip:SetHyperlink(itemLink)
                        GameTooltip:AddDoubleLine("---------::","::---------")
                        if (value.Obtain.Kill) then
                            GameTooltip:AddDoubleLine("Kill npc:", value.Obtain.NpcName .. " |cffffffff(ID: " .. value.Obtain.NpcID ..")")
                            GameTooltip:AddDoubleLine("Acquired in: ", value.Obtain.Zone)
                            GameTooltip:AddDoubleLine("Drop chance: ", value.Obtain.DropChance .. "%")
                        elseif(value.Obtain.Quest) then
                            local questTitle = C_QuestLog.GetQuestInfo(value.Obtain.QuestID)
                            if (questTitle == nil) then
                                questTitle = "QuestName Not Found"
                            end
                            GameTooltip:AddDoubleLine("Quest:", questTitle .. " |cffffffff(ID: " .. value.Obtain.QuestID .. ")")
                            GameTooltip:AddDoubleLine("Quest Location: ", value.Obtain.Zone)
                        elseif(value.Obtain.Recipe) then
                            GameTooltip:SetHyperlink("Spell: |Hspell:" .. value.Obtain.RecipeID .."|h|r|cff71d5ff[" .. GetSpellLink(value.Obtain.RecipeID) .. "]|r|h")
                        else
                            GameTooltip:AddDoubleLine("Acquired in:", "PVP")
                        end
                        if (value.Obtain.Recipe ~= true) then
                            GameTooltip:AddDoubleLine("---------::","::---------")
                        end
                        GameTooltip:Show()
                    end)

                end
            end
        end
        if (errorOccured == true) then
            BiSTracker:Print("|cffff0000An error occured while loading an item in the |cffffff00" .. BiSTracker.SelectedClass .. "|cffff0000 set |cffffff00" .. BiSTracker.SelectedSetName .. "|cffff0000. Please try reloading the set.")
        end
    end
end

local function CreateEditBox(text, label, disabled, disableButton, maxLetters, width)
    local o = BiSTracker.AceGUI:Create("EditBox")
    o:SetText(text)
    o:SetLabel(label)
    o:SetDisabled(disabled)
    o:DisableButton(disableButton)
    o:SetMaxLetters(maxLetters)
    o:SetWidth(width)
    return o
end

local function CreateSimpleGroup(layout, width, height)
    local o = BiSTracker.AceGUI:Create("SimpleGroup")
    o:SetLayout(layout)
    if (width ~= 0) then o:SetWidth(width) end
    if (height ~= 0) then o:SetHeight(height) end
    return o
end

local function CreateDropdownMenu(label, defaultValue, children, width)
    local o = BiSTracker.AceGUI:Create("Dropdown")
    o:SetList(children)
    o:SetValue(defaultValue)
    o:SetLabel(label)
    o:SetWidth(width)
    return o
end

function BiSTracker.MainFrame:UpdateSetDropdown()
    BiSTracker.MainFrame.ActionsGroup.SetDropdown:SetList(BiSTracker.ClassSetList[BiSTracker.SelectedClass])
    local firstSetInClass, _ = next(BiSTracker.ClassSetList[BiSTracker.SelectedClass])
    BiSTracker.MainFrame.ActionsGroup.SetDropdown:SetValue(firstSetInClass)
    BiSTracker.SelectedSetName = firstSetInClass
end

local function CreateSlotIcon(image, imagex, imagey, width, height)
    local o = BiSTracker.AceGUI:Create("Icon")
    o:SetImage(image)
    o:SetImageSize(imagex,imagey)
    o:SetWidth(width)
    o:SetHeight(height)

    o:SetCallback("OnEnter", function()
        GameTooltip:SetOwner(o.frame, "ANCHOR_RIGHT")
        GameTooltip:SetHyperlink("|cffa335ee|Hitem:172187::::::::50:72:::::::|h[Devastation's Hour]|h|r")
    end)
    o:SetCallback("OnLeave", function()
        GameTooltip:Hide()
        GameTooltip:SetText("")
    end)

    return o
end

local function ToggleIcon(icon)
    if (icon.Height == nil) then
        icon.height = icon:GetHeight()
        icon.width = icon:GetWidth()
    end
    if (icon:GetHeight() == 0) then
        icon:SetHeight(icon.height)
        icon:SetWidth(icon.width)
    else
        icon:SetHeight(0)
        icon:SetWidth(0)
    end
end

function BiSTracker:InitUI()
    BiSTracker.MainFrame:EnableResize(false)
    BiSTracker.MainFrame:SetTitle("BiS Tracker")
    BiSTracker.MainFrame:SetHeight(520)
    BiSTracker.MainFrame:SetLayout("BiSTrackerSheet")
    BiSTracker.MainFrame:SetWidth(250)
    
    
    for key, value in pairs(BiSData) do
        ClassList[key] = key
        BiSTracker.ClassSetList[key] = {}
        for k, v in pairs(value) do
            BiSTracker.ClassSetList[key][k] = k
        end
    end
    
    ClassList["Custom"] = "Custom"
    BiSTracker.ClassSetList["Custom"] = {}
    for key, value in pairs(BiSTracker.Settings.CustomSpecs) do
        BiSTracker.ClassSetList["Custom"][key] = key
    end



    BiSTracker.MainFrame.TopLeftButtonGroup = CreateSimpleGroup("flow", 20, 20)
    BiSTracker.MainFrame.TopRightButtonGroup = CreateSimpleGroup("flow", 50, 20)
    
    BiSTracker.MainFrame.TopLeftButtonGroup.Reload = BiSTracker.AceGUI:Create("Icon")
    BiSTracker.MainFrame.TopLeftButtonGroup.Reload:SetImageSize(20, 20)
    BiSTracker.MainFrame.TopLeftButtonGroup.Reload:SetHeight(25)
    BiSTracker.MainFrame.TopLeftButtonGroup.Reload:SetWidth(25)
    BiSTracker.MainFrame.TopLeftButtonGroup.Reload:SetImage("Interface\\AddOns\\BiSTracker\\assets\\reload")
    BiSTracker.MainFrame.TopLeftButtonGroup:AddChild(BiSTracker.MainFrame.TopLeftButtonGroup.Reload)
    BiSTracker.MainFrame.TopLeftButtonGroup.Reload:SetCallback("OnEnter", function()
        GameTooltip:SetOwner(BiSTracker.MainFrame.TopLeftButtonGroup.Reload.frame, "ANCHOR_RIGHT")
        GameTooltip:SetText("Reload")
    end)
    BiSTracker.MainFrame.TopLeftButtonGroup.Reload:SetCallback("OnLeave", function()
        GameTooltip:SetText("")
    end)
    BiSTracker.MainFrame.TopLeftButtonGroup.Reload:SetCallback("OnClick", function()
        BiSTracker.MainFrame:UpdateSetDisplay()
    end)




    BiSTracker.MainFrame.TopRightButtonGroup.CreateSet = BiSTracker.AceGUI:Create("Icon")
    BiSTracker.MainFrame.TopRightButtonGroup.CreateSet:SetImageSize(20, 20)
    BiSTracker.MainFrame.TopRightButtonGroup.CreateSet:SetHeight(25)
    BiSTracker.MainFrame.TopRightButtonGroup.CreateSet:SetWidth(25)
    BiSTracker.MainFrame.TopRightButtonGroup.CreateSet:SetImage("Interface\\AddOns\\BiSTracker\\assets\\pen50")

    BiSTracker.MainFrame.TopRightButtonGroup.RemoveSet = BiSTracker.AceGUI:Create("Icon")
    BiSTracker.MainFrame.TopRightButtonGroup.RemoveSet:SetImageSize(20, 20)
    BiSTracker.MainFrame.TopRightButtonGroup.RemoveSet:SetHeight(25)
    BiSTracker.MainFrame.TopRightButtonGroup.RemoveSet:SetWidth(25)
    BiSTracker.MainFrame.TopRightButtonGroup.RemoveSet:SetImage("Interface\\AddOns\\BiSTracker\\assets\\delete")
    

    BiSTracker.MainFrame.TopRightButtonGroup:AddChild(BiSTracker.MainFrame.TopRightButtonGroup.CreateSet)
    BiSTracker.MainFrame.TopRightButtonGroup:AddChild(BiSTracker.MainFrame.TopRightButtonGroup.RemoveSet)
    BiSTracker.MainFrame.TopRightButtonGroup.CreateSet:SetCallback("OnClick", function()
        print("Clicked Create Set")
    end)
    BiSTracker.MainFrame.TopRightButtonGroup.CreateSet:SetCallback("OnEnter", function()
        GameTooltip:SetOwner(BiSTracker.MainFrame.TopRightButtonGroup.RemoveSet.frame, "ANCHOR_RIGHT")
        GameTooltip:SetText("Create Custom Set")
    end)
    BiSTracker.MainFrame.TopRightButtonGroup.CreateSet:SetCallback("OnLeave", function()
        GameTooltip:SetText("")
    end)

    BiSTracker.MainFrame.TopRightButtonGroup.RemoveSet:SetCallback("OnClick", function()
        print("Clicked Remove Set")
    end)
    BiSTracker.MainFrame.TopRightButtonGroup.RemoveSet:SetCallback("OnEnter", function()
        GameTooltip:SetOwner(BiSTracker.MainFrame.TopRightButtonGroup.RemoveSet.frame, "ANCHOR_RIGHT")
        GameTooltip:SetText("Delete Custom Set")
    end)
    BiSTracker.MainFrame.TopRightButtonGroup.RemoveSet:SetCallback("OnLeave", function()
        GameTooltip:SetText("")
    end)

    BiSTracker.MainFrame.TopRightButtonGroup.CreateSet:SetDisabled(true)
    BiSTracker.MainFrame.TopRightButtonGroup.RemoveSet:SetDisabled(true)

    BiSTracker.MainFrame.SetName = CreateEditBox("Set Name", nil, true, false, 15, 100)
    BiSTracker.MainFrame.LeftSlots = CreateSimpleGroup("list", 45, 0)
    BiSTracker.MainFrame.BottomSlots = CreateSimpleGroup("flow", 136, 45)
    BiSTracker.MainFrame.BottomSlots:SetAutoAdjustHeight(false)
    BiSTracker.MainFrame.RightSlots = CreateSimpleGroup("list", 45, 0)
    BiSTracker.MainFrame.ActionsGroup = CreateSimpleGroup("flow", 0, 46)
    BiSTracker.MainFrame.ActionsGroup:SetFullWidth(true)

    BiSTracker.MainFrame.ActionsGroup.ClassDropdown = CreateDropdownMenu("Class", ClassList[BiSTracker.CurrentClass], ClassList, 95)
    BiSTracker.SelectedClass = BiSTracker.CurrentClass
    BiSTracker.MainFrame.ActionsGroup.ClassDropdown:SetCallback("OnValueChanged", function(self)
        BiSTracker.SelectedClass = self.list[self.value]
        BiSTracker.MainFrame:UpdateSetDropdown()
        BiSTracker.MainFrame:UpdateSetDisplay()
        if (BiSTracker.SelectedClass == "Custom") then
            BiSTracker.MainFrame.TopRightButtonGroup.CreateSet:SetDisabled(false)
            BiSTracker.MainFrame.TopRightButtonGroup.RemoveSet:SetDisabled(false)
            if (BiSTracker.SelectedSetName ~= nil) then
                BiSTracker.MainFrame.SetName:SetDisabled(false)
            end
        else
            BiSTracker.MainFrame.SetName:SetDisabled(true)
            BiSTracker.MainFrame.TopRightButtonGroup.CreateSet:SetDisabled(true)
            BiSTracker.MainFrame.TopRightButtonGroup.RemoveSet:SetDisabled(true)
        end
    end)
    
    local firstSetInClass, _ = next(BiSTracker.ClassSetList[BiSTracker.CurrentClass])
    BiSTracker.SelectedSetName = firstSetInClass
    BiSTracker.MainFrame.ActionsGroup.SetDropdown = CreateDropdownMenu("Set", firstSetInClass, BiSTracker.ClassSetList[BiSTracker.CurrentClass], 130)
    BiSTracker.MainFrame.ActionsGroup.SetDropdown:SetCallback("OnValueChanged", function(self)
        BiSTracker.SelectedSetName = self.list[self.value]
        BiSTracker.MainFrame:UpdateSetDisplay()
        if (BiSTracker.SelectedSetName ~= nil and BiSTracker.SelectedClass == "Custom") then
            BiSTracker.MainFrame.SetName:SetDisabled(false)
        else
            BiSTracker.MainFrame.SetName:SetDisabled(true)
        end
    end)
    
    BiSTracker.MainFrame.ActionsGroup:AddChild(BiSTracker.MainFrame.ActionsGroup.ClassDropdown)
    BiSTracker.MainFrame.ActionsGroup:AddChild(BiSTracker.MainFrame.ActionsGroup.SetDropdown)
    
    
    
    BiSTracker.MainFrame:AddChild(BiSTracker.MainFrame.TopLeftButtonGroup)
    BiSTracker.MainFrame:AddChild(BiSTracker.MainFrame.TopRightButtonGroup)
    BiSTracker.MainFrame:AddChild(BiSTracker.MainFrame.SetName)
    BiSTracker.MainFrame:AddChild(BiSTracker.MainFrame.LeftSlots)
    BiSTracker.MainFrame:AddChild(BiSTracker.MainFrame.BottomSlots)
    BiSTracker.MainFrame:AddChild(BiSTracker.MainFrame.RightSlots)
    BiSTracker.MainFrame:AddChild(BiSTracker.MainFrame.ActionsGroup)
    
    BiSTracker.MainFrame.DefaultSlotIcons = {
        Head = "Interface\\PaperDoll\\UI-PaperDoll-Slot-Head",
        Neck = "Interface\\PaperDoll\\UI-PaperDoll-Slot-Neck",
        Shoulder = "Interface\\PaperDoll\\UI-PaperDoll-Slot-Shoulder",
        Back = "Interface\\PaperDoll\\UI-PaperDoll-Slot-Chest",
        Chest = "Interface\\PaperDoll\\UI-PaperDoll-Slot-Chest",
        Shirt = "Interface\\PaperDoll\\UI-PaperDoll-Slot-Shirt",
        Tabard = "Interface\\PaperDoll\\UI-PaperDoll-Slot-Tabard",
        Wrists = "Interface\\PaperDoll\\UI-PaperDoll-Slot-Wrists",
        Hands = "Interface\\PaperDoll\\UI-PaperDoll-Slot-Hands",
        Waist = "Interface\\PaperDoll\\UI-PaperDoll-Slot-Waist",
        Legs = "Interface\\PaperDoll\\UI-PaperDoll-Slot-Legs",
        Feet = "Interface\\PaperDoll\\UI-PaperDoll-Slot-Feet",
        Finger = "Interface\\PaperDoll\\UI-PaperDoll-Slot-Finger",
        RFinger = "Interface\\PaperDoll\\UI-PaperDoll-Slot-Finger",
        Trinket = "Interface\\PaperDoll\\UI-PaperDoll-Slot-Trinket",
        RTrinket = "Interface\\PaperDoll\\UI-PaperDoll-Slot-Trinket",
        MainHand = "Interface\\PaperDoll\\UI-PaperDoll-Slot-MainHand",
        SecondaryHand = "Interface\\PaperDoll\\UI-PaperDoll-Slot-SecondaryHand",
        Relic = "Interface\\PaperDoll\\UI-PaperDoll-Slot-Relic"
    }
    
    BiSTracker.MainFrame.SlotItems = {
        Head = "",
        Neck = "",
        Shoulder = "",
        Back = "",
        Chest = "",
        Shirt = "",
        Tabard = "",
        Wrists = "",
        Hands = "",
        Waist = "",
        Legs = "",
        Feet = "",
        Finger = "",
        RFinger = "",
        Trinket = "",
        RTrinket = "",
        MainHand = "",
        SecondaryHand = "",
        Relic = ""
    }
    
    BiSTracker.MainFrame.Slots = {
        "Head",
        "Neck",
        "Shoulder",
        "Back",
        "Chest",
        "Shirt",
        "Tabard",
        "Wrists",
        "Hands",
        "Waist",
        "Legs",
        "Feet",
        "Finger",
        "RFinger",
        "Trinket",
        "RTrinket",
        "MainHand",
        "SecondaryHand",
        "Relic"
    }

    local slots = BiSTracker.MainFrame.Slots

    for key, value in pairs(slots) do
        if (type(key) == "number") then
            BiSTracker.MainFrame.Slots[value] = CreateSlotIcon(BiSTracker.MainFrame.DefaultSlotIcons[value], 40, 40, 45, 45)
            if (key <= 8) then
                BiSTracker.MainFrame.LeftSlots:AddChild(BiSTracker.MainFrame.Slots[value])
            elseif (key <= 16) then
                BiSTracker.MainFrame.RightSlots:AddChild(BiSTracker.MainFrame.Slots[value])
            else
                BiSTracker.MainFrame.Slots[value].image:SetPoint("TOP", 0, 0)
                BiSTracker.MainFrame.BottomSlots:AddChild(BiSTracker.MainFrame.Slots[value])
            end
        end
    end


    BiSTracker.MainFrame.Model = CreateFrame("DressUpModel",nil,BiSTracker.MainFrame.frame)    
    BiSTracker.MainFrame.Model:SetScript("OnMousewheel", function(self, offset)
        if ((self:GetCameraDistance() - offset/10) > 0.35 and (self:GetCameraDistance() - offset/10) < 4) then
            self:SetCameraDistance(self:GetCameraDistance()-offset/10)
        end
    end)
    BiSTracker.MainFrame.Model:SetScript("OnMouseDown", function(self, button)
        self.DragButton = button
        self.IsDragging = true
        self.LastMousePosX, self.LastMousePosY = GetCursorPosition()
    end)
    BiSTracker.MainFrame.Model:SetScript("OnMouseUp", function(self, button)
        self.IsDragging = false
    end)
    BiSTracker.MainFrame.Model:SetScript("OnUpdate", function(self, timeLapsed)
        if (BiSTracker.MainFrame.Model.IsDragging and BiSTracker.MainFrame.Model.LastMousePosX ~= nil) then
            if (BiSTracker.MainFrame.Model.DragButton == "LeftButton") then
                local currentCursor = GetCursorPosition()
                local currentRotationInDegrees = (180/math.pi)*self:GetFacing()
                local newRotationInDegrees = 0
                newRotationInDegrees = currentRotationInDegrees + (currentCursor - self.LastMousePosX)

                if (newRotationInDegrees > 360) then
                    newRotationInDegrees = newRotationInDegrees - 360
                elseif (newRotationInDegrees < 0) then
                    newRotationInDegrees = 360 - newRotationInDegrees
                end
                local newRotationInRadiens = (math.pi/180)*newRotationInDegrees

                self:SetFacing(newRotationInRadiens)
                self.LastMousePosX, self.LastMousePosY = GetCursorPosition()
            elseif (self.DragButton == "RightButton") then
                local currentCursorX, currentCursorY = GetCursorPosition()
                local currentZ, currentX, currentY = self:GetPosition()
                local newX, newY = 0
                newX = currentX + ((currentCursorX - self.LastMousePosX) / 150 * self:GetCameraDistance())
                newY = currentY + ((currentCursorY - self.LastMousePosY) / 150 * self:GetCameraDistance())
                local maxX = 0.4
                local maxY = 0.6
                if (newX < -maxX * self:GetCameraDistance() or newX > maxX * self:GetCameraDistance()) then
                    if (newX > 0) then
                        newX = maxX * self:GetCameraDistance()
                    else
                        newX = -maxX * self:GetCameraDistance()
                    end
                end
                
                if (newY < -maxY * self:GetCameraDistance() or newY > maxY * self:GetCameraDistance()) then
                    if (newY > 0) then
                        newY = maxY * self:GetCameraDistance()
                    else
                        newY = -maxY * self:GetCameraDistance()
                    end
                end

                self:SetPosition(0, newX, newY)
                self.LastMousePosX, self.LastMousePosY = GetCursorPosition()
            end
        end
    end)

end