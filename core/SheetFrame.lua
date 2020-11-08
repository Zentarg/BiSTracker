BiSTracker.MainFrame = BiSTracker.AceGUI:Create("Window")
BiSTracker.MainFrame:Hide()

local ClassList = {}
local ClassSetList = {}

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
                frame:SetPoint("TOP", content)
            elseif i == 2 then
                frame:SetPoint("TOPLEFT", content, 0, -10)
            elseif i == 3 then
                frame:SetPoint("BOTTOM", content, 0, 45)
            elseif i == 4 then
                frame:SetPoint("TOPRIGHT", content, 0, -10)
            elseif i == 5 then
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
                print(key)
                print(inventorySlotName[key])
                BiSTracker.MainFrame.Model:UndressSlot(GetInventorySlotInfo(inventorySlotName[key]))
                BiSTracker.MainFrame.Slots[key]:SetImage(BiSTracker.MainFrame.DefaultSlotIcons[key])
                BiSTracker.MainFrame.Slots[key]:SetCallback("OnEnter", function()
                    GameTooltip:SetOwner(BiSTracker.MainFrame.Slots[key].frame, "ANCHOR_RIGHT")
                    GameTooltip:SetText("|cffff0000An error occured while loading this item.\nPlease try reloading the set.")
                end)
            else
                BiSTracker.MainFrame.Model:TryOn(itemLink)
                BiSTracker.MainFrame.Slots[key]:SetImage(itemTexture)
                BiSTracker.MainFrame.Slots[key]:SetCallback("OnEnter", function()
                    GameTooltip:SetOwner(BiSTracker.MainFrame.Slots[key].frame, "ANCHOR_RIGHT")
                    GameTooltip:SetHyperlink(itemLink)
                end)

            end
        end
    end
    if (errorOccured == true) then
        BiSTracker:Print("|cffff0000An error occured while loading an item in the |cffffff00" .. BiSTracker.SelectedClass .. "|cffff0000 set |cffffff00" .. BiSTracker.SelectedSetName .. "|cffff0000. Please try reloading the set.")
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
    BiSTracker.MainFrame.ActionsGroup.SetDropdown:SetList(ClassSetList[BiSTracker.SelectedClass])
    BiSTracker.MainFrame.ActionsGroup.SetDropdown:SetValue(1)
    BiSTracker.SelectedSetName = BiSTracker.MainFrame.ActionsGroup.SetDropdown.list[1]
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

function BiSTracker:InitUI()
    BiSTracker.MainFrame:EnableResize(false)
    BiSTracker.MainFrame:SetTitle("BiS Tracker")
    BiSTracker.MainFrame:SetHeight(490)
    BiSTracker.MainFrame:SetLayout("BiSTrackerSheet")
    BiSTracker.MainFrame:SetWidth(250)
    
    
    for key, value in pairs(BiSData) do
        table.insert(ClassList, key)
        ClassSetList[key] = {}
        for k, v in pairs(value) do
            ClassSetList[key][k] = k
        end
    end
    
    table.insert(ClassList, "Custom")
    ClassSetList["Custom"] = {}
    for key, value in pairs(BiSTracker.Settings.CustomSpecs) do
        ClassSetList["Custom"][key] = key
    end



    
    BiSTracker.MainFrame.SetName = CreateEditBox("Set Name", nil, true, true, 15, 100)
    BiSTracker.MainFrame.LeftSlots = CreateSimpleGroup("list", 45, 0)
    BiSTracker.MainFrame.BottomSlots = CreateSimpleGroup("flow", 136, 45)
    BiSTracker.MainFrame.BottomSlots:SetAutoAdjustHeight(false)
    BiSTracker.MainFrame.RightSlots = CreateSimpleGroup("list", 45, 0)
    BiSTracker.MainFrame.ActionsGroup = CreateSimpleGroup("flow", 0, 46)
    BiSTracker.MainFrame.ActionsGroup:SetFullWidth(true)

    BiSTracker.MainFrame.ActionsGroup.ClassDropdown = CreateDropdownMenu("Class", 1, ClassList, 80)
    BiSTracker.MainFrame.ActionsGroup.ClassDropdown:SetCallback("OnValueChanged", function(self)
        BiSTracker.SelectedClass = self.list[self.value]
        BiSTracker.MainFrame:UpdateSetDropdown()
        BiSTracker.MainFrame:UpdateSetDisplay()
    end)
    BiSTracker.MainFrame.ActionsGroup.SetDropdown = CreateDropdownMenu("Set", 1, ClassSetList[0], 100)
    BiSTracker.MainFrame.ActionsGroup.SetDropdown:SetCallback("OnValueChanged", function(self)
        BiSTracker.SelectedSetName = self.list[self.value]
        BiSTracker.MainFrame:UpdateSetDisplay()
    end)
    
    BiSTracker.MainFrame.ActionsGroup:AddChild(BiSTracker.MainFrame.ActionsGroup.ClassDropdown)
    BiSTracker.MainFrame.ActionsGroup:AddChild(BiSTracker.MainFrame.ActionsGroup.SetDropdown)
    
    
    
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
                BiSTracker.MainFrame.BottomSlots:AddChild(BiSTracker.MainFrame.Slots[value])
            end
        end
    end

    BiSTracker.MainFrame.Model = CreateFrame("DressUpModel",nil,BiSTracker.MainFrame.frame)
    
    BiSTracker.MainFrame.Model:SetScript("OnMousewheel", function(self, offset)
        self:SetCameraDistance(self:GetCameraDistance()-offset/10)
    end)
    BiSTracker.MainFrame.Model:SetScript("OnMouseDown", function(self, button)
        BiSTracker.MainFrame.Model.IsDragging = true
        BiSTracker.MainFrame.Model.LastMousePos = GetCursorPosition()
    end)
    BiSTracker.MainFrame.Model:SetScript("OnMouseUp", function(self, button)
        BiSTracker.MainFrame.Model.IsDragging = false
    end)
    BiSTracker.MainFrame.Model:SetScript("OnUpdate", function(self, timeLapsed)
        if (BiSTracker.MainFrame.Model.IsDragging and BiSTracker.MainFrame.Model.LastMousePos ~= nil) then
            local currentCursor = GetCursorPosition()
            local currentRotationInDegrees = (180/math.pi)*BiSTracker.MainFrame.Model:GetFacing()
            local newRotationInDegrees = 0



            newRotationInDegrees = currentRotationInDegrees + (currentCursor - BiSTracker.MainFrame.Model.LastMousePos)

            if (newRotationInDegrees > 360) then
                newRotationInDegrees = newRotationInDegrees - 360
            elseif (newRotationInDegrees < 0) then
                newRotationInDegrees = 360 - newRotationInDegrees
            end
            local newRotationInRadiens = (math.pi/180)*newRotationInDegrees

            BiSTracker.MainFrame.Model:SetFacing(newRotationInRadiens)
            BiSTracker.MainFrame.Model.LastMousePos = GetCursorPosition()
        end
    end)

end