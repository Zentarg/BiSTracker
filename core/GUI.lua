BiSTracker.MainFrame = BiSTracker.AceGUI:Create("Window")
BiSTracker.MainFrame.EditSlot = BiSTracker.AceGUI:Create("Window")
BiSTracker.MainFrame.ConfirmDelete = BiSTracker.AceGUI:Create("Window")
BiSTracker.MainFrame:Hide()
BiSTracker.MainFrame.EditSlot:Hide()
BiSTracker.MainFrame.ConfirmDelete:Hide()

BiSTracker.ClassList = {}
BiSTracker.ClassSetList = {}

local L

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

local obtainMethods = {
    ["Kill"] = 1,
    ["Purchase"] = 2,
    ["Container"] = 3,
    ["Quest"] = 4,
    ["Recipe"] = 5,
    ["Unknown"] = 6
}

local function UpdateModelFrame()
	BiSTracker.MainFrame.Model:SetAllPoints(BiSTracker.MainFrame.frame)
	BiSTracker.MainFrame.Model:SetModelScale(0.75)
	BiSTracker.MainFrame.Model:SetUnit("PLAYER")
	BiSTracker.MainFrame.Model:SetCustomCamera(1)
	BiSTracker.MainFrame.Model:SetPosition(0,0,0)
	BiSTracker.MainFrame.Model:SetLight(true, false, 0, 0.8, -1, 1, 1, 1, 1, 0.3, 1, 1, 1)
end

function BiSTracker.MainFrame.ConfirmDelete:RemoveSet(setName)
    if (setName ~= nil) then
        BiSTracker.MainFrame.ConfirmDelete.Values.Text:SetText(L["Are you sure you want to delete the set |cffff0000"]..setName.."|r?")
        BiSTracker.MainFrame.ConfirmDelete:Show()
    end
end

local function AddSourceToTooltip(value)
    GameTooltip:AddDoubleLine("---------::","::---------")
    GameTooltip:AddDoubleLine(L["Item ID:"], "|cffffffff" .. value.id)
    GameTooltip:AddLine(" ")
    local hasItem = BiSTracker:CharacterHasItem(value.id)
    local sourceType = value.source.SourceType
    if (sourceType == "Kill") then
        GameTooltip:AddDoubleLine(L["Kill npc:"], value.source.SourceName .. L[" |cffffffff(ID: "] .. value.source.ID ..")")
        GameTooltip:AddDoubleLine(L["Located in:"], value.source.Zone)
        GameTooltip:AddDoubleLine(L["Drop chance:"], value.source.DropChance .. "%")
        GameTooltip:AddLine(" ")
    elseif (sourceType == "Purchase") then
        GameTooltip:AddDoubleLine(L["Sold by:"], value.source.SourceName .. L[" |cffffffff(ID: "] .. value.source.ID ..")")
        GameTooltip:AddDoubleLine(L["Located in:"], value.source.Zone)
        GameTooltip:AddLine(" ")
    elseif (sourceType == "Quest") then
        local questTitle = value.source.SourceName
        if (questTitle == "") then
            questTitle = C_QuestLog.GetQuestInfo(value.source.ID)
        end
        if (questTitle == nil) then
            questTitle = L["Quest Not Found"]
        end
        GameTooltip:AddDoubleLine(L["Quest:"], questTitle .. L[" |cffffffff(ID: "] .. value.source.ID .. ")")
        GameTooltip:AddDoubleLine(L["Located in:"], value.source.Zone)
        GameTooltip:AddLine(" ")
    elseif (sourceType == "Container") then
        GameTooltip:AddDoubleLine(L["Contained in:"], value.source.SourceName .. L[" |cffffffff(ID: "] .. value.source.ID ..")")
        GameTooltip:AddDoubleLine(L["Located in:"], value.source.Zone)
        GameTooltip:AddDoubleLine(L["Drop chance:"], value.source.DropChance .. "%")
        GameTooltip:AddLine(" ")
    elseif (sourceType == "Recipe") then
        GameTooltip:SetHyperlink("Spell: |Hspell:" .. value.source.ID .."|h|r|cff71d5ff[" .. GetSpellLink(value.source.ID) .. "]|r|h")
        GameTooltip:AddDoubleLine("---------::","::---------")
        GameTooltip:AddDoubleLine(L["Item ID:"], "|cffffffff" .. value.id)
        GameTooltip:AddLine(" ")
    elseif (sourceType == "Unknown") then
        GameTooltip:AddLine(L["No source information found."])
        GameTooltip:AddLine(" ")
    end
    if (hasItem) then
        GameTooltip:AddLine(L["|cff00ff00You have this item."])
    else
        GameTooltip:AddLine(L["|cffff0000You do not have this item."])

    end
    GameTooltip:AddDoubleLine("---------::","::---------")
end

function BiSTracker.MainFrame:UpdateSetDisplay()
    if (BiSTracker.db.profile.mainframe.compact) then
        BiSTracker.MainFrame.SetName:SetText(BiSTracker.SelectedSetName)
        if (BiSTracker.SelectedSetName == nil) then
            for k, v in pairs(BiSTracker.MainFrame.CompactSlots) do
                if (type(k) == "number") then
                    BiSTracker.MainFrame.CompactSlots[v].icon:SetImage(BiSTracker.MainFrame.DefaultSlotIcons[v])
                    BiSTracker.MainFrame.CompactSlots[v].frame:SetCallback("OnEnter", function()
                        GameTooltip:SetText("")
                    end)
                end
            end
        else
            local SelectedSetSlots = None
            if (BiSTracker.SelectedClass ~= "Custom") then
                SelectedSetSlots = BiSData[BiSTracker.SelectedClass][BiSTracker.SelectedSetName]
            else
                SelectedSetSlots = BiSTracker.Settings.CustomSets[BiSTracker.SelectedSetName].Slots
            end
            local errorOccured = false
            for key, value in pairs(SelectedSetSlots) do
                if (BiSTracker.SelectedClass ~= "Custom") then
                    value = BiSTracker.ItemDB:GetItemWithID(value)
                end
                if (value == nil or value.id == 0 or value.id == nil) then
                    BiSTracker.MainFrame.CompactSlots[key].icon:SetImage(BiSTracker.MainFrame.DefaultSlotIcons[key])
                    BiSTracker.MainFrame.CompactSlots[key].label:SetCallback("OnEnter", function()
                    end)
                    BiSTracker.MainFrame.CompactSlots[key].icon:SetCallback("OnEnter", function()
                    end)
                    BiSTracker.MainFrame.CompactSlots[key].label:SetText("Empty")
                    BiSTracker.MainFrame.CompactSlots[key].acquired:SetDisabled(true)
                else
                    local _,itemLink,_,_,_,_,_,_,_,itemTexture,_,_,_,_,_,_,_ = GetItemInfo(value.id)
                    if (itemLink == nil) then
                        errorOccured = true
                        BiSTracker.MainFrame.CompactSlots[key].icon:SetImage(BiSTracker.MainFrame.DefaultSlotIcons[key])
                        BiSTracker.MainFrame.CompactSlots[key].icon:SetCallback("OnEnter", function()
                            GameTooltip:SetOwner(BiSTracker.MainFrame.CompactSlots[key].frame, "ANCHOR_RIGHT")
                            GameTooltip:SetText(L["|cffff0000An error occured while loading this item.\nPlease try reloading the set."])
                        end)
                        BiSTracker.MainFrame.CompactSlots[key].label:SetCallback("OnEnter", function()
                            GameTooltip:SetOwner(BiSTracker.MainFrame.CompactSlots[key].frame, "ANCHOR_RIGHT")
                            GameTooltip:SetText(L["|cffff0000An error occured while loading this item.\nPlease try reloading the set."])
                        end)
                        BiSTracker.MainFrame.CompactSlots[key].label:SetText(L["|cffff0000Error loading item, please try reloading."])
                        BiSTracker.MainFrame.CompactSlots[key].acquired:SetDisabled(true)
                    else
                        BiSTracker.MainFrame.CompactSlots[key].acquired:SetDisabled(false)
                        local hasItem = BiSTracker:CharacterHasItem(value.id)
                        if (hasItem) then
                            BiSTracker.MainFrame.CompactSlots[key].acquired:SetImage("Interface\\RaidFrame\\ReadyCheck-Ready");
                        else
                            BiSTracker.MainFrame.CompactSlots[key].acquired:SetImage("Interface\\RaidFrame\\ReadyCheck-NotReady");
                        end
                        BiSTracker.MainFrame.CompactSlots[key].icon:SetImage(itemTexture)
                        BiSTracker.MainFrame.CompactSlots[key].icon:SetCallback("OnEnter", function()
                            if (IsControlKeyDown()) then
                                ShowInspectCursor()
                            end
                            BiSTracker.IsHoveringItemSlot = true

                            GameTooltip:SetOwner(BiSTracker.MainFrame.CompactSlots[key].frame, "ANCHOR_RIGHT", 15)
                            GameTooltip:SetHyperlink(itemLink)

                            AddSourceToTooltip(value)
                            GameTooltip:Show()
                        end)
                        BiSTracker.MainFrame.CompactSlots[key].label:SetCallback("OnEnter", function()
                            if (IsControlKeyDown()) then
                                ShowInspectCursor()
                            end
                            BiSTracker.IsHoveringItemSlot = true

                            GameTooltip:SetOwner(BiSTracker.MainFrame.CompactSlots[key].frame, "ANCHOR_RIGHT", 15)
                            GameTooltip:SetHyperlink(itemLink)

                            
                            AddSourceToTooltip(value)
                            GameTooltip:Show()
                        end)
                        BiSTracker.MainFrame.CompactSlots[key].acquired:SetCallback("OnEnter", function()
                            GameTooltip:SetOwner(BiSTracker.MainFrame.CompactSlots[key].frame, "ANCHOR_RIGHT", 15)
                            if (hasItem) then
                                GameTooltip:AddLine(L["|cff00ff00You have this item."])
                            else
                                GameTooltip:AddLine(L["|cffff0000You do not have this item."])
                            end
                            GameTooltip:Show()
                        end)
                        BiSTracker.MainFrame.CompactSlots[key].label:SetText(itemLink)
                    end
                end
            end
            if (errorOccured == true) then
                BiSTracker:PrintError(L["An item in the |cffffff00"].. BiSTracker.SelectedClass ..L["|r set |cffffff00"] .. BiSTracker.SelectedSetName .. L["|r didn't load correctly. Please try reloading the set."])
            end
        end
    else
        UpdateModelFrame()
        BiSTracker.MainFrame.SetName:SetText(BiSTracker.SelectedSetName)
        BiSTracker.MainFrame.Model:Undress()
        if (BiSTracker.SelectedSetName == nil) then
            for k, v in pairs(BiSTracker.MainFrame.Slots) do
                if (type(k) == "number") then
                    BiSTracker.MainFrame.Slots[v]:SetImage(BiSTracker.MainFrame.DefaultSlotIcons[v])
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
                SelectedSetSlots = BiSTracker.Settings.CustomSets[BiSTracker.SelectedSetName].Slots
            end
            local errorOccured = false
            for key, value in pairs(SelectedSetSlots) do
                if (BiSTracker.SelectedClass ~= "Custom") then
                    value = BiSTracker.ItemDB:GetItemWithID(value)
                end
                if (value == nil or value.id == 0 or value.id == nil) then
                    BiSTracker.MainFrame.Slots[key]:SetImage(BiSTracker.MainFrame.DefaultSlotIcons[key])
                    BiSTracker.MainFrame.Slots[key]:SetCallback("OnEnter", function()
                    end)
                    BiSTracker.MainFrame.Model:UndressSlot(GetInventorySlotInfo(inventorySlotName[key]))
                else
                    local _,itemLink,_,_,_,_,_,_,_,itemTexture,_,_,_,_,_,_,_ = GetItemInfo(value.id)
                    if (itemLink == nil) then
                        errorOccured = true
                        BiSTracker.MainFrame.Model:UndressSlot(GetInventorySlotInfo(inventorySlotName[key]))
                        BiSTracker.MainFrame.Slots[key]:SetImage(BiSTracker.MainFrame.DefaultSlotIcons[key])
                        BiSTracker.MainFrame.Slots[key]:SetCallback("OnEnter", function()
                            GameTooltip:SetOwner(BiSTracker.MainFrame.Slots[key].frame, "ANCHOR_RIGHT")
                            GameTooltip:SetText(L["|cffff0000An error occured while loading this item.\nPlease try reloading the set."])
                        end)
                    else
                        local hasItem = BiSTracker:CharacterHasItem(value.id)
                        if (key ~= "Relic" or BiSTracker.SelectedClass == "Hunter") then
                            BiSTracker.MainFrame.Model:TryOn(itemLink)
                        end
                        BiSTracker.MainFrame.Slots[key]:SetImage(itemTexture)
                        BiSTracker.MainFrame.Slots[key]:SetCallback("OnEnter", function()
                            if (IsControlKeyDown()) then
                                ShowInspectCursor()
                            end
                            BiSTracker.IsHoveringItemSlot = true

                            GameTooltip:SetOwner(BiSTracker.MainFrame.Slots[key].frame, "ANCHOR_RIGHT")
                            GameTooltip:SetHyperlink(itemLink)
                            
                            AddSourceToTooltip(value)
                            GameTooltip:Show()
                        end)

                    end
                end
            end
            if (errorOccured == true) then
                BiSTracker:PrintError(L["An item in the |cffffff00"].. BiSTracker.SelectedClass ..L["|r set |cffffff00"] .. BiSTracker.SelectedSetName .. L["|r didn't load correctly. Please try reloading the set."])
            end
        end
    end
end

local function CreateIcon(imageHeight, imageWidth, height, width, image)
    local o = BiSTracker.AceGUI:Create("Icon")
    o:SetImageSize(imageHeight, imageWidth)
    o:SetHeight(height)
    o:SetWidth(width)
    o:SetImage(image)
    return o
end

local function CreateButton(text, disabled, width)
    local o = BiSTracker.AceGUI:Create("Button")
    o:SetText(text)
    o:SetDisabled(disabled)
    o:SetWidth(width)
    return o
end

local function CreateLabel(text, centered, r, g, b, font)
    local o = BiSTracker.AceGUI:Create("Label")
    o:SetText(text)
    if (centered ~= nil and centered ~= false) then
        o:SetJustifyH("TOP")
    end 
    if (font ~= nil) then
        o:SetFontObject(font)
    end
    if (r ~= nil and g ~= nil and b ~= nil) then
        o:SetColor(r, g, b)
    end
    return o
end

local function CreateInteractiveLabel(text, centered, r, g, b, font)
    local o = BiSTracker.AceGUI:Create("InteractiveLabel")
    o:SetText(text)
    if (centered ~= nil and centered ~= false) then
        o:SetJustifyH("TOP")
    end 
    if (font ~= nil) then
        o:SetFontObject(font)
    end
    if (r ~= nil and g ~= nil and b ~= nil) then
        o:SetColor(r, g, b)
    end
    return o
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

local function ObtainMethodValueChanged(self)
    local val = self:GetValue()
    BiSTracker.MainFrame.EditSlot.Values.ObtainID.frame:Show()
    BiSTracker.MainFrame.EditSlot.Values.ObtainID:SetText("")
    BiSTracker.MainFrame.EditSlot.Values.NpcName:SetText("")
    BiSTracker.MainFrame.EditSlot.Values.DropChance:SetText("")
    BiSTracker.MainFrame.EditSlot.Values.Zone:SetText("")

    BiSTracker.MainFrame.EditSlot.Values.NpcName.frame:Hide()
    BiSTracker.MainFrame.EditSlot.Values.DropChance.frame:Hide()
    BiSTracker.MainFrame.EditSlot.Values.Zone.frame:Hide()

    if (val == 1) then
        BiSTracker.MainFrame.EditSlot.Values.NpcName.frame:Show()
        BiSTracker.MainFrame.EditSlot.Values.DropChance.frame:Show()
        BiSTracker.MainFrame.EditSlot.Values.Zone.frame:Show()
        BiSTracker.MainFrame.EditSlot.Values.ObtainID:SetLabel(L["Npc ID"])
        BiSTracker.MainFrame.EditSlot.Values.NpcName:SetLabel(L["Npc Name"])
    elseif (val == 2) then
        BiSTracker.MainFrame.EditSlot.Values.NpcName.frame:Show()
        BiSTracker.MainFrame.EditSlot.Values.Zone.frame:Show()
        BiSTracker.MainFrame.EditSlot.Values.ObtainID:SetLabel(L["Npc ID"])
        BiSTracker.MainFrame.EditSlot.Values.NpcName:SetLabel(L["Npc Name"])
    elseif (val == 3) then
        BiSTracker.MainFrame.EditSlot.Values.NpcName.frame:Show()
        BiSTracker.MainFrame.EditSlot.Values.Zone.frame:Show()
        BiSTracker.MainFrame.EditSlot.Values.ObtainID:SetLabel(L["Container ID"])
        BiSTracker.MainFrame.EditSlot.Values.NpcName:SetLabel(L["Container Name"])
    elseif (val == 4) then
        BiSTracker.MainFrame.EditSlot.Values.Zone.frame:Show()
        BiSTracker.MainFrame.EditSlot.Values.ObtainID:SetLabel(L["Quest ID"])
    elseif (val == 5) then
        BiSTracker.MainFrame.EditSlot.Values.ObtainID:SetLabel(L["Recipe ID"])
    elseif (val == 6) then
        BiSTracker.MainFrame.EditSlot.Values.ObtainID.frame:Hide()
    end
end

function BiSTracker.MainFrame:UpdateSetDropdown(set)
    BiSTracker.MainFrame.ActionsGroup.SetDropdown:SetList(BiSTracker.ClassSetList[BiSTracker.SelectedClass])
    if (set == nil) then
        set, _ = next(BiSTracker.ClassSetList[BiSTracker.SelectedClass])
    end
    BiSTracker.MainFrame.ActionsGroup.SetDropdown:SetValue(set)
    BiSTracker.SelectedSetName = set
end

local function CreateSlotIcon(slot, image, imagex, imagey, width, height)
    local o = CreateIcon(imagex, imagey, width, height, image)

    o:SetCallback("OnClick", function()
        if (IsControlKeyDown()) then
            local itemLink
            if (BiSTracker.SelectedClass == "Custom") then
                _, itemLink = GetItemInfo(BiSTracker.Settings.CustomSets[BiSTracker.SelectedSetName].Slots[slot].id)
            else
                _, itemLink = GetItemInfo(BiSData[BiSTracker.SelectedClass][BiSTracker.SelectedSetName][slot])
            end
            DressUpItemLink(itemLink)
            return
        end
        if (IsShiftKeyDown()) then
            local itemLink
            if (BiSTracker.SelectedClass == "Custom") then
                _, itemLink = GetItemInfo(BiSTracker.Settings.CustomSets[BiSTracker.SelectedSetName].Slots[slot].id)
            else
                _, itemLink = GetItemInfo(BiSData[BiSTracker.SelectedClass][BiSTracker.SelectedSetName][slot])
            end
            ChatEdit_InsertLink(itemLink)
            return
        end
        if (BiSTracker.SelectedClass == "Custom") then
            BiSTracker.MainFrame.EditSlot:ResetWindow()
            BiSTracker.MainFrame.EditSlot:SetTitle("Edit " .. slot)
            BiSTracker.MainFrame.EditSlot.SelectedSlot = slot
            local slotValues = BiSTracker.Settings.CustomSets[BiSTracker.SelectedSetName].Slots[slot]
            BiSTracker.MainFrame.EditSlot.Values.ObtainMethod:SetValue(obtainMethods[slotValues.source.SourceType])
            ObtainMethodValueChanged(BiSTracker.MainFrame.EditSlot.Values.ObtainMethod)
            BiSTracker.MainFrame.EditSlot.Values.ID:SetText(slotValues.id)
            BiSTracker.MainFrame.EditSlot.Values.ObtainID:SetText(slotValues.source.ID)
            BiSTracker.MainFrame.EditSlot.Values.NpcName:SetText(slotValues.source.SourceName)
            BiSTracker.MainFrame.EditSlot.Values.DropChance:SetText(slotValues.source.DropChance)
            BiSTracker.MainFrame.EditSlot.Values.Zone:SetText(slotValues.source.Zone)
            BiSTracker.MainFrame.EditSlot:Show()
        end
    end)

    o:SetCallback("OnLeave", function()
        SetCursor(nil)
        BiSTracker.IsHoveringItemSlot = false
        GameTooltip:SetText("")
    end)

    return o
end
function BiSTracker.MainFrame.EditSlot:ResetWindow()
    for key, value in pairs(BiSTracker.MainFrame.EditSlot.Values) do
        if (key ~= "CancelButton" and key ~= "SaveButton") then
            if (key ~= "ObtainMethod") then
                value:SetText("")
            else
                value:SetValue(1)
            end
        end
    end
    BiSTracker.MainFrame.EditSlot:SetTitle(L["Edit Slot"])
    BiSTracker.MainFrame.EditSlot.Values.ObtainID:SetLabel(L["Npc ID"])
    BiSTracker.MainFrame.EditSlot.Values.NpcName.frame:Show()
    BiSTracker.MainFrame.EditSlot.Values.DropChance.frame:Show()
    BiSTracker.MainFrame.EditSlot.Values.Zone.frame:Show()
    BiSTracker.MainFrame.EditSlot:Hide()
end

local function InitFrame(frame, enableResize, title, height, width, layout)
    frame:EnableResize(enableResize)
    frame:SetTitle(title)
    frame:SetHeight(height)
    frame:SetWidth(width)
    frame:SetLayout(layout)
end



local function InitCompactUI()
    local mainFrameHeight = 110
    InitFrame(BiSTracker.MainFrame, false, "BiS Tracker", mainFrameHeight, 310, "BiSTrackerSheetCompact")
    BiSTracker.MainFrame.CompactSlots = {}
    BiSTracker.MainFrame.CompactSlotsGroup = CreateSimpleGroup("List", 280, 0)

    local listHeight = 0;

    for k,v in pairs(BiSTracker.MainFrame.Slots) do
        if (type(k) == "number") then
            local listItem = CreateSimpleGroup("BiSTrackerCompactListItem", 280, 0)
            listItem.icon = CreateSlotIcon(v, BiSTracker.MainFrame.DefaultSlotIcons[v], 15, 15, 15, 15)
            listItem.label = CreateInteractiveLabel(v)
            listItem.label:SetWidth(240)
            listItem.icon:SetCallback("OnLeave", function()
                GameTooltip:SetText("")
            end)

            listItem.label:SetCallback("OnLeave", function()
                GameTooltip:SetText("")
            end)

            listItem.label:SetCallback("OnClick", function(btn)
                if (IsControlKeyDown()) then
                    local itemLink
                    if (BiSTracker.SelectedClass == "Custom") then
                        _, itemLink = GetItemInfo(BiSTracker.Settings.CustomSets[BiSTracker.SelectedSetName].Slots[v].id)
                    else
                        _, itemLink = GetItemInfo(BiSData[BiSTracker.SelectedClass][BiSTracker.SelectedSetName][v])
                    end
                    DressUpItemLink(itemLink)
                    return
                end
                if (IsShiftKeyDown()) then
                    local itemLink
                    if (BiSTracker.SelectedClass == "Custom") then
                        _, itemLink = GetItemInfo(BiSTracker.Settings.CustomSets[BiSTracker.SelectedSetName].Slots[v].id)
                    else
                        _, itemLink = GetItemInfo(BiSData[BiSTracker.SelectedClass][BiSTracker.SelectedSetName][v])
                    end
                    ChatEdit_InsertLink(itemLink)
                    return
                end
                if (BiSTracker.SelectedClass == "Custom") then
                    BiSTracker.MainFrame.EditSlot:ResetWindow()
                    BiSTracker.MainFrame.EditSlot:SetTitle(L["Edit "] .. v)
                    BiSTracker.MainFrame.EditSlot.SelectedSlot = v
                    local slotValues = BiSTracker.Settings.CustomSets[BiSTracker.SelectedSetName].Slots[v]
                    BiSTracker.MainFrame.EditSlot.Values.ObtainMethod:SetValue(obtainMethods[slotValues.source.SourceType])
                    ObtainMethodValueChanged(BiSTracker.MainFrame.EditSlot.Values.ObtainMethod)
                    BiSTracker.MainFrame.EditSlot.Values.ID:SetText(slotValues.id)
                    BiSTracker.MainFrame.EditSlot.Values.ObtainID:SetText(slotValues.source.ID)
                    BiSTracker.MainFrame.EditSlot.Values.NpcName:SetText(slotValues.source.SourceName)
                    BiSTracker.MainFrame.EditSlot.Values.DropChance:SetText(slotValues.source.DropChance)
                    BiSTracker.MainFrame.EditSlot.Values.Zone:SetText(slotValues.source.Zone)
                    BiSTracker.MainFrame.EditSlot:Show()
                end
            end)

            listItem.acquired = CreateIcon(15, 15, 15, 15, "Interface\\RaidFrame\\ReadyCheck-NotReady")
            listItem.acquired:SetCallback("OnLeave", function()
                GameTooltip:SetText("")
            end)
            listItem:AddChild(listItem.icon)
            listItem:AddChild(listItem.label)
            listItem:AddChild(listItem.acquired)
            listItem:SetHeight(18)
            
            listHeight = listHeight + 18;
            BiSTracker.MainFrame.CompactSlots[v] = listItem
            BiSTracker.MainFrame.CompactSlotsGroup:AddChild(listItem)
        end
    end


    BiSTracker.MainFrame.ActionsGroup = CreateSimpleGroup("flow", 0, 46)
    BiSTracker.MainFrame.ActionsGroup:SetFullWidth(true)

    BiSTracker.SelectedClass = BiSTracker.CurrentClass
    BiSTracker.MainFrame.ActionsGroup.ClassDropdown = CreateDropdownMenu(L[" Class"], BiSTracker.ClassList[BiSTracker.SelectedClass], BiSTracker.ClassList, 95)
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
    BiSTracker.MainFrame.ActionsGroup.SetDropdown = CreateDropdownMenu(L[" Set"], firstSetInClass, BiSTracker.ClassSetList[BiSTracker.CurrentClass], 190)
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

    local MainFrameAddChildren = {
        "CompactSlotsGroup",
        "ActionsGroup"
    }

    for key, value in pairs(MainFrameAddChildren) do
        BiSTracker.MainFrame:AddChild(BiSTracker.MainFrame[value])
    end

    BiSTracker.MainFrame:SetHeight(mainFrameHeight + listHeight)

end



local function InitFullUI()
    InitFrame(BiSTracker.MainFrame, true, "BiS Tracker", 520, 300, "BiSTrackerSheet")
    
    BiSTracker.MainFrame.frame:SetMinResize(300,520)

    BiSTracker.MainFrame.LeftSlots = CreateSimpleGroup("list", 45, 0)
    BiSTracker.MainFrame.BottomSlots = CreateSimpleGroup("flow", 136, 45)
    BiSTracker.MainFrame.BottomSlots:SetAutoAdjustHeight(false)
    BiSTracker.MainFrame.RightSlots = CreateSimpleGroup("list", 45, 0)
    BiSTracker.MainFrame.ActionsGroup = CreateSimpleGroup("flow", 0, 46)
    BiSTracker.MainFrame.ActionsGroup:SetFullWidth(true)

    BiSTracker.SelectedClass = BiSTracker.CurrentClass
    BiSTracker.MainFrame.ActionsGroup.ClassDropdown = CreateDropdownMenu(L[" Class"], BiSTracker.ClassList[BiSTracker.SelectedClass], BiSTracker.ClassList, 95)
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
    BiSTracker.MainFrame.ActionsGroup.SetDropdown = CreateDropdownMenu(L[" Set"], firstSetInClass, BiSTracker.ClassSetList[BiSTracker.CurrentClass], 170)
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

    local MainFrameAddChildren = {
        "LeftSlots",
        "BottomSlots",
        "RightSlots",
        "ActionsGroup"
    }

    for key, value in pairs(MainFrameAddChildren) do
        BiSTracker.MainFrame:AddChild(BiSTracker.MainFrame[value])
    end

    for key, value in pairs(BiSTracker.MainFrame.Slots) do
        if (type(key) == "number") then
            BiSTracker.MainFrame.Slots[value] = CreateSlotIcon(value, BiSTracker.MainFrame.DefaultSlotIcons[value], 40, 40, 45, 45)
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

function BiSTracker:InitUI()
    L = BiSTracker.L[BiSTracker.Settings.Locale]
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


    BiSTracker.MainFrame:SetCallback("OnClose", function()
        BiSTracker.MainFrame.EditSlot:Hide()
        BiSTracker.Serializer.GUI:Hide()
        if (BiSTracker.MainFrame.characterFrameToggle ~= nil) then
            BiSTracker.MainFrame.characterFrameToggle:SetImage("Interface\\AddOns\\BiSTracker\\assets\\open")
        end
    end)
    BiSTracker.MainFrame:SetCallback("OnShow", function()
        BiSTracker.MainFrame:UpdateSetDisplay()
        if (BiSTracker.MainFrame.characterFrameToggle ~= nil) then
            BiSTracker.MainFrame.characterFrameToggle:SetImage("Interface\\AddOns\\BiSTracker\\assets\\close")
        end
    end)

    if (self.db.profile.mainframe.connectedToCharacterFrame) then
        BiSTracker.MainFrame.characterFrameToggle = CreateIcon(25, 25, 25, 25, "Interface\\AddOns\\BiSTracker\\assets\\open")
        BiSTracker.MainFrame.characterFrameToggle:SetCallback("OnClick", function(self)
            BiSTracker:ToggleMainFrame()
            if (BiSTracker.MainFrame:IsVisible()) then
                self:SetImage("Interface\\AddOns\\BiSTracker\\assets\\close")
            else
                self:SetImage("Interface\\AddOns\\BiSTracker\\assets\\open")
            end
        end)
        BiSTracker.MainFrame.characterFrameToggle:SetCallback("OnEnter", function()
            GameTooltip:SetOwner(BiSTracker.MainFrame.characterFrameToggle.frame, "ANCHOR_RIGHT")
            GameTooltip:SetText(L["Toggle BiSTracker window"])
        end)
        BiSTracker.MainFrame.characterFrameToggle:SetCallback("OnLeave", function()
            GameTooltip:SetText("")
        end)


        BiSTracker.MainFrame.characterFrameToggle.frame:SetParent(CharacterFrame)
        BiSTracker.MainFrame.characterFrameToggle:SetPoint("TOPRIGHT", CharacterFrame, "TOPRIGHT", BiSTracker.db.profile.mainframe.mainframeToggleButtonXPosition, BiSTracker.db.profile.mainframe.mainframeToggleButtonYPosition)
        BiSTracker.MainFrame.characterFrameToggle.frame:Show()
        
        BiSTracker.MainFrame:ClearAllPoints()
        BiSTracker.MainFrame.frame:SetParent(CharacterFrame)
        BiSTracker.MainFrame:SetPoint("TOPLEFT", CharacterFrame, "TOPRIGHT", -35, -10)
    end

    InitFrame(BiSTracker.MainFrame.EditSlot, false, L["Edit Slot"], 335, 250, "BiSTrackerEditSlot")
    BiSTracker.MainFrame.EditSlot:ClearAllPoints()
    BiSTracker.MainFrame.EditSlot:SetPoint("TOPLEFT", BiSTracker.MainFrame.frame, "TOPRIGHT")
    BiSTracker.MainFrame.EditSlot:SetCallback("OnClose", function()
        BiSTracker.MainFrame.EditSlot:ResetWindow()
    end)

    InitFrame(BiSTracker.MainFrame.ConfirmDelete, false, L["Confirm Deletion"], 100, 250, "BiSTrackerConfirmDelete")
    BiSTracker.MainFrame.ConfirmDelete:ClearAllPoints()
    BiSTracker.MainFrame.ConfirmDelete:SetPoint("BOTTOMRIGHT", BiSTracker.MainFrame.frame, "TOPRIGHT")

    BiSTracker.MainFrame.ConfirmDelete.ValuesOrder = {
        "Text",
        "CancelButton",
        "ConfirmButton"
    }

    BiSTracker.MainFrame.ConfirmDelete.Values = {
        Text = CreateLabel(L["Are you sure you want to delete this set?"], true, 1, 1, 1, GameFontHighlight),
        CancelButton = CreateButton(L["Cancel"], false, 100),
        ConfirmButton = CreateButton(L["Confirm"], false, 100)
    }
    BiSTracker.MainFrame.ConfirmDelete.Values.CancelButton:SetCallback("OnClick", function()
        BiSTracker.MainFrame.ConfirmDelete:Hide()
    end)
    BiSTracker.MainFrame.ConfirmDelete.Values.ConfirmButton:SetCallback("OnClick", function()
        BiSTracker.ClassSetList["Custom"][BiSTracker.SelectedSetName] = nil
        BiSTracker.Settings.CustomSets[BiSTracker.SelectedSetName] = nil
        BiSTracker.MainFrame:UpdateSetDropdown()
        BiSTracker.MainFrame:UpdateSetDisplay()
        if (BiSTracker.SelectedSetName == nil) then
            BiSTracker.MainFrame.SetName:SetDisabled(true)
        end
        BiSTracker.MainFrame.ConfirmDelete:Hide()
        BiSTracker.MainFrame.EditSlot:ResetWindow()
    end)

    for key, value in pairs(BiSTracker.MainFrame.ConfirmDelete.ValuesOrder) do
        BiSTracker.MainFrame.ConfirmDelete:AddChild(BiSTracker.MainFrame.ConfirmDelete.Values[value])
    end

    BiSTracker.MainFrame.EditSlot.SelectedSlot = ""

    BiSTracker.MainFrame.EditSlot.ValuesOrder = {
        "ID",
        "ObtainMethod",
        "ObtainID",
        "Zone",
        "NpcName",
        "DropChance",
        "CancelButton",
        "SaveButton"
    }


    BiSTracker.MainFrame.EditSlot.Values = {
        ID = CreateEditBox("", L["Item ID"], false, false, 0, 200),
        ObtainMethod = CreateDropdownMenu(L["Obtain Method"], 1, {"Kill", "Purchase", "Container", "Quest", "Recipe", "Unknown"}, 200),
        ObtainID = CreateEditBox("", L["Npc ID"], false, false, 0, 200),
        Zone = CreateEditBox("", L["Zone"], false, false, 0, 200),
        NpcName = CreateEditBox("", L["Npc Name"], false, false, 0, 200),
        DropChance = CreateEditBox("", L["Drop Chance"], false, false, 0, 200),
        CancelButton = CreateButton(L["Cancel"], false, 100),
        SaveButton = CreateButton(L["Save"], false, 100)
    }

    BiSTracker.MainFrame.EditSlot.Values.ID:SetCallback("OnTextChanged", function(self, callback, val)
        val = tonumber(val)
        local item = BiSTracker.ItemDB:GetItemWithID(val)
        
        local sourceID, sourceName, sourceType, dropChance, zone = "", "", "Kill", "", ""

        if (item ~= nil) then
            sourceID, sourceName, sourceType, dropChance, zone = item.source.ID, item.source.SourceName, item.source.SourceType, item.source.DropChance, item.source.Zone
        end

        BiSTracker.MainFrame.EditSlot.Values.ObtainMethod:SetValue(obtainMethods[sourceType])
        ObtainMethodValueChanged(BiSTracker.MainFrame.EditSlot.Values.ObtainMethod)

        BiSTracker.MainFrame.EditSlot.Values.ObtainID:SetText(sourceID)
        BiSTracker.MainFrame.EditSlot.Values.NpcName:SetText(sourceName)
        BiSTracker.MainFrame.EditSlot.Values.DropChance:SetText(dropChance)
        BiSTracker.MainFrame.EditSlot.Values.Zone:SetText(zone)
    end)

    BiSTracker.MainFrame.EditSlot.Values.CancelButton:SetCallback("OnClick", function(self, button)
        BiSTracker.MainFrame.EditSlot:ResetWindow()
    end)

    BiSTracker.MainFrame.EditSlot.Values.SaveButton:SetCallback("OnClick", function(self, button)
        local values = BiSTracker.MainFrame.EditSlot.Values
        local newItem
        local itemID, obtainID, npcName, zone, dropChance
        local obtainMethods = {
            [1] = "Kill",
            [2] = "Purchase",
            [3] = "Container",
            [4] = "Quest",
            [5] = "Recipe",
            [6] = "Unknown"
        }
        itemID = tonumber(values.ID:GetText())
        obtainID = tonumber(values.ObtainID:GetText()) or 0
        zone = values.Zone:GetText() or ""
        npcName = values.NpcName:GetText() or ""
        dropChance = values.DropChance:GetText() or "0"
        newItem = BiSTracker.Item:New(itemID, "", obtainID, npcName, obtainMethods[BiSTracker.MainFrame.EditSlot.Values.ObtainMethod:GetValue()], dropChance, zone)
        BiSTracker.Settings.CustomSets[BiSTracker.SelectedSetName].Slots[BiSTracker.MainFrame.EditSlot.SelectedSlot] = newItem
        BiSTracker.MainFrame:UpdateSetDisplay()
        BiSTracker.MainFrame.EditSlot:ResetWindow()
    end)

    BiSTracker.MainFrame.EditSlot.Values.ObtainMethod:SetCallback("OnValueChanged", ObtainMethodValueChanged)

    for key, value in pairs(BiSTracker.MainFrame.EditSlot.ValuesOrder) do
        BiSTracker.MainFrame.EditSlot:AddChild(BiSTracker.MainFrame.EditSlot.Values[value])
    end

    BiSTracker.MainFrame.EditSlot.frame:SetParent(BiSTracker.MainFrame.frame)

    for key, value in pairs(BiSData) do
        BiSTracker.ClassList[key] = key
        BiSTracker.ClassSetList[key] = {}
        for k, v in pairs(value) do
            BiSTracker.ClassSetList[key][k] = k
        end
    end
    
    BiSTracker.ClassList["Custom"] = "Custom"
    BiSTracker.ClassSetList["Custom"] = {}
    for key, value in pairs(BiSTracker.Settings.CustomSets) do
        BiSTracker.ClassSetList["Custom"][key] = key
    end

    BiSTracker.MainFrame.TopLeftButtonGroup = CreateSimpleGroup("flow", 50, 20)
    BiSTracker.MainFrame.TopRightButtonGroup = CreateSimpleGroup("flow", 50, 20)
    
    BiSTracker.MainFrame.TopLeftButtonGroup.Reload = CreateIcon(20, 20, 25, 25, "Interface\\AddOns\\BiSTracker\\assets\\reload")
    BiSTracker.MainFrame.TopLeftButtonGroup.Reload:SetCallback("OnEnter", function()
        GameTooltip:SetOwner(BiSTracker.MainFrame.TopLeftButtonGroup.Reload.frame, "ANCHOR_RIGHT")
        GameTooltip:SetText(L["Reload"])
    end)
    BiSTracker.MainFrame.TopLeftButtonGroup.Reload:SetCallback("OnLeave", function()
        GameTooltip:SetText("")
    end)
    BiSTracker.MainFrame.TopLeftButtonGroup.Reload:SetCallback("OnClick", function()
        BiSTracker.MainFrame:UpdateSetDisplay()
    end)
    BiSTracker.MainFrame.TopLeftButtonGroup.ImportExport = CreateIcon(20, 20, 25, 25, "Interface\\AddOns\\BiSTracker\\assets\\importexport")
    BiSTracker.MainFrame.TopLeftButtonGroup.ImportExport:SetCallback("OnClick", function()
        if (BiSTracker.Serializer.GUI:IsVisible()) then
            BiSTracker.Serializer.GUI:Hide()
        else
            BiSTracker.Serializer.GUI:Show()
        end
    end)
    BiSTracker.MainFrame.TopLeftButtonGroup.ImportExport:SetCallback("OnEnter", function()
        GameTooltip:SetOwner(BiSTracker.MainFrame.TopLeftButtonGroup.Reload.frame, "ANCHOR_RIGHT")
        GameTooltip:SetText(L["Open Import/Export window"])
    end)
    BiSTracker.MainFrame.TopLeftButtonGroup.ImportExport:SetCallback("OnLeave", function()
        GameTooltip:SetText("")
    end)

    BiSTracker.MainFrame.TopLeftButtonGroup:AddChild(BiSTracker.MainFrame.TopLeftButtonGroup.Reload)
    BiSTracker.MainFrame.TopLeftButtonGroup:AddChild(BiSTracker.MainFrame.TopLeftButtonGroup.ImportExport)


    BiSTracker.MainFrame.TopRightButtonGroup.CreateSet = CreateIcon(20, 20, 25, 25, "Interface\\AddOns\\BiSTracker\\assets\\pen50")
    BiSTracker.MainFrame.TopRightButtonGroup.RemoveSet = CreateIcon(20, 20, 25, 25, "Interface\\AddOns\\BiSTracker\\assets\\delete")
    

    BiSTracker.MainFrame.TopRightButtonGroup:AddChild(BiSTracker.MainFrame.TopRightButtonGroup.CreateSet)
    BiSTracker.MainFrame.TopRightButtonGroup:AddChild(BiSTracker.MainFrame.TopRightButtonGroup.RemoveSet)
    BiSTracker.MainFrame.TopRightButtonGroup.CreateSet:SetCallback("OnClick", function()
        local newSetName = L["New Set"]
        while (BiSTracker.ClassSetList["Custom"][newSetName] ~= nil) do
            local n = tonumber(strsub(newSetName, 8))
            if (n == nil) then
                n = 1
            else
                n = n + 1
            end
            newSetName = L["New Set"] .. tostring(n)
        end

        -- local tempItem = BiSTracker.Item:New(0, 0, "", false, false, 0, false, 0, 0, "")
        local tempItem = BiSTracker.Item:New(0, "", 0, "", "", "", "")
        BiSTracker.ClassSetList["Custom"][newSetName] = newSetName
        BiSTracker.Settings.CustomSets[newSetName] = BiSTracker.Set:New(newSetName, tempItem, tempItem, tempItem, tempItem, tempItem, tempItem, tempItem, tempItem, tempItem, tempItem, tempItem, tempItem, tempItem, tempItem, tempItem, tempItem, tempItem, tempItem, tempItem)
        BiSTracker.MainFrame:UpdateSetDropdown(newSetName)
        BiSTracker.MainFrame:UpdateSetDisplay()
        BiSTracker.MainFrame.SetName:SetDisabled(false)
    end)
    BiSTracker.MainFrame.TopRightButtonGroup.CreateSet:SetCallback("OnEnter", function()
        GameTooltip:SetOwner(BiSTracker.MainFrame.TopRightButtonGroup.RemoveSet.frame, "ANCHOR_RIGHT")
        GameTooltip:SetText(L["Create Custom Set"])
    end)
    BiSTracker.MainFrame.TopRightButtonGroup.CreateSet:SetCallback("OnLeave", function()
        GameTooltip:SetText("")
    end)

    BiSTracker.MainFrame.TopRightButtonGroup.RemoveSet:SetCallback("OnClick", function()
        BiSTracker.MainFrame.ConfirmDelete:RemoveSet(BiSTracker.SelectedSetName)
    end)
    BiSTracker.MainFrame.TopRightButtonGroup.RemoveSet:SetCallback("OnEnter", function()
        GameTooltip:SetOwner(BiSTracker.MainFrame.TopRightButtonGroup.RemoveSet.frame, "ANCHOR_RIGHT")
        GameTooltip:SetText(L["Delete Custom Set"])
    end)
    BiSTracker.MainFrame.TopRightButtonGroup.RemoveSet:SetCallback("OnLeave", function()
        GameTooltip:SetText("")
    end)

    BiSTracker.MainFrame.TopRightButtonGroup.CreateSet:SetDisabled(true)
    BiSTracker.MainFrame.TopRightButtonGroup.RemoveSet:SetDisabled(true)

    BiSTracker.MainFrame.SetName = CreateEditBox(L["Set Name"], nil, true, false, 25, 160)
    BiSTracker.MainFrame.SetName:SetCallback("OnEnterPressed", function(self)
        local value = self:GetText()
        if (value == BiSTracker.SelectedSetName) then
            return
        end
        if (strlen(value) < 1) then
            BiSTracker:PrintError(L["Set name cannot be shorter than 1 character."])
            self:SetText(BiSTracker.SelectedSetName)
            return
        end
        if (BiSTracker.Settings.CustomSets[value] ~= nil and value ~= BiSTracker.SelectedSetName) then
            BiSTracker:PrintError(L["A set with the name |cffffff00"] .. value .. L[" |cffffffffalready exists."])
            self:SetText(BiSTracker.SelectedSetName)
            return
        end
        BiSTracker.ClassSetList["Custom"][value] = value
        BiSTracker.ClassSetList["Custom"][BiSTracker.SelectedSetName] = nil
        BiSTracker.Settings.CustomSets[value] = BiSTracker.Settings.CustomSets[BiSTracker.SelectedSetName]
        BiSTracker.Settings.CustomSets[BiSTracker.SelectedSetName] = nil
        BiSTracker.MainFrame:UpdateSetDropdown(value)
        BiSTracker.MainFrame:UpdateSetDisplay()
    end)

    local MainFrameAddChildren = {
        "TopLeftButtonGroup",
        "TopRightButtonGroup",
        "SetName"
    }

    for key, value in pairs(MainFrameAddChildren) do
        BiSTracker.MainFrame:AddChild(BiSTracker.MainFrame[value])
    end

    if (BiSTracker.db.profile.mainframe.compact) then
        InitCompactUI();
    else
        InitFullUI();
    end

end