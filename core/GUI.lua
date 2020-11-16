BiSTracker.MainFrame = BiSTracker.AceGUI:Create("Window")
BiSTracker.MainFrame.EditSlot = BiSTracker.AceGUI:Create("Window")
BiSTracker.MainFrame.ConfirmDelete = BiSTracker.AceGUI:Create("Window")
BiSTracker.MainFrame:Hide()
BiSTracker.MainFrame.EditSlot:Hide()
BiSTracker.MainFrame.ConfirmDelete:Hide()

local ClassList = {}
BiSTracker.ClassSetList = {}


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

function BiSTracker.MainFrame.ConfirmDelete:RemoveSet(setName)
    if (setName ~= nil) then
        BiSTracker.MainFrame.ConfirmDelete.Values.Text:SetText("Are you sure you want to delete the set |cffff0000"..setName.."|r?")
        BiSTracker.MainFrame.ConfirmDelete:Show()
    end
end

function BiSTracker.MainFrame:UpdateSetDisplay()
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
            if (value.ID == 0 or value.ID == nil) then
                BiSTracker.MainFrame.Slots[key]:SetImage(BiSTracker.MainFrame.DefaultSlotIcons[key])
                BiSTracker.MainFrame.Slots[key]:SetCallback("OnEnter", function()
                end)
                BiSTracker.MainFrame.Model:UndressSlot(GetInventorySlotInfo(inventorySlotName[key]))
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
                    local hasItem = BiSTracker:CharacterHasItem(value.ID)
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

                        GameTooltip:AddDoubleLine("---------::","::---------")
                        if (value.Obtain.Kill) then
                            GameTooltip:AddDoubleLine("Kill npc:", value.Obtain.NpcName .. " |cffffffff(ID: " .. value.Obtain.NpcID ..")")
                            GameTooltip:AddDoubleLine("Acquired in: ", value.Obtain.Zone)
                            GameTooltip:AddDoubleLine("Drop chance: ", value.Obtain.DropChance .. "%")
                            GameTooltip:AddLine(" ")
                        elseif(value.Obtain.Quest) then
                            local questTitle = C_QuestLog.GetQuestInfo(value.Obtain.QuestID)
                            if (questTitle == nil) then
                                questTitle = "QuestName Not Found"
                            end
                            GameTooltip:AddDoubleLine("Quest:", questTitle .. " |cffffffff(ID: " .. value.Obtain.QuestID .. ")")
                            GameTooltip:AddDoubleLine("Quest Location: ", value.Obtain.Zone)
                            GameTooltip:AddLine(" ")
                        elseif(value.Obtain.Recipe) then
                            GameTooltip:SetHyperlink("Spell: |Hspell:" .. value.Obtain.RecipeID .."|h|r|cff71d5ff[" .. GetSpellLink(value.Obtain.RecipeID) .. "]|r|h")
                            GameTooltip:AddDoubleLine("---------::","::---------")
                        else
                            GameTooltip:AddDoubleLine("Acquired in:", "Unknown (Possibly PVP)")
                        end
                        if (hasItem) then
                            GameTooltip:AddLine("|cff00ff00You have this item.")
                        else
                            GameTooltip:AddLine("|cffff0000You do not have this item.")

                        end
                        GameTooltip:AddDoubleLine("---------::","::---------")
                        GameTooltip:Show()
                    end)

                end
            end
        end
        if (errorOccured == true) then
            BiSTracker:PrintError("An item in the |cffffff00".. BiSTracker.SelectedClass .."|r set |cffffff00" .. BiSTracker.SelectedSetName .. "|r didn't load correctly. Please try reloading the set.")
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
                _, itemLink = GetItemInfo(BiSTracker.Settings.CustomSets[BiSTracker.SelectedSetName].Slots[slot].ID)
            else
                _, itemLink = GetItemInfo(BiSData[BiSTracker.SelectedClass][BiSTracker.SelectedSetName][slot].ID)
            end
            DressUpItemLink(itemLink)
            return
        end
        if (IsShiftKeyDown()) then
            local itemLink
            if (BiSTracker.SelectedClass == "Custom") then
                _, itemLink = GetItemInfo(BiSTracker.Settings.CustomSets[BiSTracker.SelectedSetName].Slots[slot].ID)
            else
                _, itemLink = GetItemInfo(BiSData[BiSTracker.SelectedClass][BiSTracker.SelectedSetName][slot].ID)
            end
            ChatEdit_InsertLink(itemLink)
            return
        end
        if (BiSTracker.SelectedClass == "Custom") then
            BiSTracker.MainFrame.EditSlot:ResetWindow()
            BiSTracker.MainFrame.EditSlot:SetTitle("Edit " .. slot)
            BiSTracker.MainFrame.EditSlot.SelectedSlot = slot
            local slotValues = BiSTracker.Settings.CustomSets[BiSTracker.SelectedSetName].Slots[slot]
            BiSTracker.MainFrame.EditSlot.Values.ID:SetText(slotValues.ID)
            if (slotValues.Obtain.Kill) then
                BiSTracker.MainFrame.EditSlot.Values.ObtainMethod:SetValue(1)
                BiSTracker.MainFrame.EditSlot.Values.ObtainID:SetText(slotValues.Obtain.NpcID)
                BiSTracker.MainFrame.EditSlot.Values.NpcName:SetText(slotValues.Obtain.NpcName)
                BiSTracker.MainFrame.EditSlot.Values.DropChance:SetText(slotValues.Obtain.DropChance)
            elseif (slotValues.Obtain.Quest) then
                BiSTracker.MainFrame.EditSlot.Values.ObtainMethod:SetValue(2)
                BiSTracker.MainFrame.EditSlot.Values.ObtainID:SetText(slotValues.Obtain.QuestID)
            elseif (slotValues.Obtain.Recipe) then
                BiSTracker.MainFrame.EditSlot.Values.ObtainMethod:SetValue(3)
                BiSTracker.MainFrame.EditSlot.Values.ObtainID:SetText(slotValues.Obtain.RecipeID)
            end
            BiSTracker.MainFrame.EditSlot.Values.Zone:SetText(slotValues.Obtain.Zone)
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
    BiSTracker.MainFrame.EditSlot:SetTitle("Edit Slot")
    BiSTracker.MainFrame.EditSlot.Values.ObtainID:SetLabel("Npc ID")
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

function BiSTracker:InitUI()
    InitFrame(BiSTracker.MainFrame, true, "BiS Tracker", 520, 250, "BiSTrackerSheet")
    BiSTracker.MainFrame.frame:SetMinResize(250,520)
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
            GameTooltip:SetText("Toggle BiSTracker window")
        end)
        BiSTracker.MainFrame.characterFrameToggle:SetCallback("OnLeave", function()
            GameTooltip:SetText("")
        end)


        BiSTracker.MainFrame.characterFrameToggle.frame:SetParent(CharacterFrame)
        BiSTracker.MainFrame.characterFrameToggle:SetPoint("TOPRIGHT", CharacterFrame, "TOPRIGHT", BiSTracker.db.profile.mainframe.mainframeToggleButtonXPosition, BiSTracker.db.profile.mainframe.mainframeToggleButtonYPosition)
        BiSTracker.MainFrame.characterFrameToggle.frame:Show()

        BiSTracker.MainFrame.frame:SetParent(CharacterFrame)
        BiSTracker.MainFrame:SetPoint("TOPLEFT", CharacterFrame, "TOPRIGHT", -35, -10)
    end

    InitFrame(BiSTracker.MainFrame.EditSlot, false, "Edit Slot", 335, 250, "BiSTrackerEditSlot")
    BiSTracker.MainFrame.EditSlot:SetPoint("TOPLEFT", BiSTracker.MainFrame.frame, "TOPRIGHT")
    BiSTracker.MainFrame.EditSlot:SetCallback("OnClose", function()
        BiSTracker.MainFrame.EditSlot:ResetWindow()
    end)

    InitFrame(BiSTracker.MainFrame.ConfirmDelete, false, "Confirm Deletion", 100, 250, "BiSTrackerConfirmDelete")
    BiSTracker.MainFrame.ConfirmDelete:SetPoint("BOTTOMRIGHT", BiSTracker.MainFrame.frame, "TOPRIGHT")

    BiSTracker.MainFrame.ConfirmDelete.ValuesOrder = {
        "Text",
        "CancelButton",
        "ConfirmButton"
    }
    
    BiSTracker.MainFrame.ConfirmDelete.Values = {
        Text = CreateLabel("Are you sure you want to delete this set?", true, 1, 1, 1, GameFontHighlight),
        CancelButton = CreateButton("Cancel", false, 100),
        ConfirmButton = CreateButton("Confirm", false, 100)
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
        ID = CreateEditBox("", "Item ID", false, false, 0, 200),
        ObtainMethod = CreateDropdownMenu("Obtain Method", 1, {"By Killing", "By Quest", "By Recipe"}, 200),
        ObtainID = CreateEditBox("", "Npc ID", false, false, 0, 200),
        Zone = CreateEditBox("", "Zone", false, false, 0, 200),
        NpcName = CreateEditBox("", "Npc Name", false, false, 0, 200),
        DropChance = CreateEditBox("", "Drop Chance", false, false, 0, 200),
        CancelButton = CreateButton("Cancel", false, 100),
        SaveButton = CreateButton("Save", false, 100)
    }

    BiSTracker.MainFrame.EditSlot.Values.CancelButton:SetCallback("OnClick", function(self, button)
        BiSTracker.MainFrame.EditSlot:ResetWindow()
    end)

    BiSTracker.MainFrame.EditSlot.Values.SaveButton:SetCallback("OnClick", function(self, button)
        local values = BiSTracker.MainFrame.EditSlot.Values
        local newItem
        local itemID, obtainID, npcName, zone, dropChance
        itemID = tonumber(values.ID:GetText())
        obtainID = tonumber(values.ObtainID:GetText()) or 0
        zone = values.Zone:GetText() or ""
        if (values.ObtainMethod:GetValue() == 1) then
            npcName = values.NpcName:GetText() or ""
            dropChance = tonumber(values.DropChance:GetText()) or 0
            newItem = BiSTracker.Item:New(itemID, obtainID, npcName, true, false, 0, false, 0, dropChance, zone)
        elseif (values.ObtainMethod:GetValue() == 2) then
            newItem = BiSTracker.Item:New(itemID, 0, "", false, true, obtainID, false, 0, 0, zone)
        elseif (values.ObtainMethod:GetValue() == 3) then
            newItem = BiSTracker.Item:New(itemID, 0, "", false, false, 0, true, obtainID, 0, zone)
        end
        BiSTracker.Settings.CustomSets[BiSTracker.SelectedSetName].Slots[BiSTracker.MainFrame.EditSlot.SelectedSlot] = newItem
        BiSTracker.MainFrame:UpdateSetDisplay()
        BiSTracker.MainFrame.EditSlot:ResetWindow()
    end)

    BiSTracker.MainFrame.EditSlot.Values.ObtainMethod:SetCallback("OnValueChanged", function(self)
        BiSTracker.MainFrame.EditSlot.Values.ObtainID:SetText("")
        BiSTracker.MainFrame.EditSlot.Values.NpcName:SetText("")
        BiSTracker.MainFrame.EditSlot.Values.DropChance:SetText("")
        BiSTracker.MainFrame.EditSlot.Values.Zone:SetText("")
        
        if (self:GetValue() ~= 1) then
            BiSTracker.MainFrame.EditSlot.Values.NpcName.frame:Hide()
            BiSTracker.MainFrame.EditSlot.Values.DropChance.frame:Hide()
        else
            BiSTracker.MainFrame.EditSlot.Values.NpcName.frame:Show()
            BiSTracker.MainFrame.EditSlot.Values.DropChance.frame:Show()
        end
        if (self:GetValue() ~= 3) then
            BiSTracker.MainFrame.EditSlot.Values.Zone.frame:Show()
        else
            BiSTracker.MainFrame.EditSlot.Values.Zone.frame:Hide()
        end


        if (self:GetValue() == 1) then
            BiSTracker.MainFrame.EditSlot.Values.ObtainID:SetLabel("Npc ID")
        elseif (self:GetValue() == 2) then
            BiSTracker.MainFrame.EditSlot.Values.ObtainID:SetLabel("Quest ID")
        elseif (self:GetValue() == 3) then
            BiSTracker.MainFrame.EditSlot.Values.ObtainID:SetLabel("Recipe ID")
        end
    end)


    for key, value in pairs(BiSTracker.MainFrame.EditSlot.ValuesOrder) do
        BiSTracker.MainFrame.EditSlot:AddChild(BiSTracker.MainFrame.EditSlot.Values[value])
    end
    for key, value in pairs(BiSData) do
        ClassList[key] = key
        BiSTracker.ClassSetList[key] = {}
        for k, v in pairs(value) do
            BiSTracker.ClassSetList[key][k] = k
        end
    end
    
    ClassList["Custom"] = "Custom"
    BiSTracker.ClassSetList["Custom"] = {}
    for key, value in pairs(BiSTracker.Settings.CustomSets) do
        BiSTracker.ClassSetList["Custom"][key] = key
    end

    BiSTracker.MainFrame.TopLeftButtonGroup = CreateSimpleGroup("flow", 50, 20)
    BiSTracker.MainFrame.TopRightButtonGroup = CreateSimpleGroup("flow", 50, 20)
    
    BiSTracker.MainFrame.TopLeftButtonGroup.Reload = CreateIcon(20, 20, 25, 25, "Interface\\AddOns\\BiSTracker\\assets\\reload")
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
        GameTooltip:SetText("Open Import/Export window")
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
        local newSetName = "New Set"
        while (BiSTracker.ClassSetList["Custom"][newSetName] ~= nil) do
            local n = tonumber(strsub(newSetName, 8))
            if (n == nil) then
                n = 1
            else
                n = n + 1
            end
            newSetName = "New Set" .. tostring(n)
        end

        local tempItem = BiSTracker.Item:New(0, 0, "", false, false, 0, false, 0, 0, "")
        BiSTracker.ClassSetList["Custom"][newSetName] = newSetName
        BiSTracker.Settings.CustomSets[newSetName] = BiSTracker.Set:New(newSetName, tempItem, tempItem, tempItem, tempItem, tempItem, tempItem, tempItem, tempItem, tempItem, tempItem, tempItem, tempItem, tempItem, tempItem, tempItem, tempItem, tempItem, tempItem, tempItem)
        BiSTracker.MainFrame:UpdateSetDropdown(newSetName)
        BiSTracker.MainFrame:UpdateSetDisplay()
        BiSTracker.MainFrame.SetName:SetDisabled(false)
    end)
    BiSTracker.MainFrame.TopRightButtonGroup.CreateSet:SetCallback("OnEnter", function()
        GameTooltip:SetOwner(BiSTracker.MainFrame.TopRightButtonGroup.RemoveSet.frame, "ANCHOR_RIGHT")
        GameTooltip:SetText("Create Custom Set")
    end)
    BiSTracker.MainFrame.TopRightButtonGroup.CreateSet:SetCallback("OnLeave", function()
        GameTooltip:SetText("")
    end)

    BiSTracker.MainFrame.TopRightButtonGroup.RemoveSet:SetCallback("OnClick", function()
        BiSTracker.MainFrame.ConfirmDelete:RemoveSet(BiSTracker.SelectedSetName)
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
    BiSTracker.MainFrame.SetName:SetCallback("OnEnterPressed", function(self)
        local value = self:GetText()
        if (strlen(value) < 1) then
            BiSTracker:PrintError("Set name cannot be shorter than 1 character.")
            self:SetText(BiSTracker.SelectedSetName)
            return
        end
        if (BiSTracker.Settings.CustomSets[value] ~= nil and value ~= BiSTracker.SelectedSetName) then
            BiSTracker:PrintError("A set with the name |cffffff00" .. value .. " |cffffffffalready exists.")
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


    BiSTracker.MainFrame.LeftSlots = CreateSimpleGroup("list", 45, 0)
    BiSTracker.MainFrame.BottomSlots = CreateSimpleGroup("flow", 136, 45)
    BiSTracker.MainFrame.BottomSlots:SetAutoAdjustHeight(false)
    BiSTracker.MainFrame.RightSlots = CreateSimpleGroup("list", 45, 0)
    BiSTracker.MainFrame.ActionsGroup = CreateSimpleGroup("flow", 0, 46)
    BiSTracker.MainFrame.ActionsGroup:SetFullWidth(true)

    BiSTracker.SelectedClass = BiSTracker.CurrentClass
    BiSTracker.MainFrame.ActionsGroup.ClassDropdown = CreateDropdownMenu("Class", ClassList[BiSTracker.SelectedClass], ClassList, 95)
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
    
    local MainFrameAddChildren = {
        "TopLeftButtonGroup",
        "TopRightButtonGroup",
        "SetName",
        "LeftSlots",
        "BottomSlots",
        "RightSlots",
        "ActionsGroup"
    }

    for key, value in pairs(MainFrameAddChildren) do
        BiSTracker.MainFrame:AddChild(BiSTracker.MainFrame[value])
    end
    
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
