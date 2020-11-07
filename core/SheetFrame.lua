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

function BiSTracker.MainFrame:UpdateSetDisplay()
    print("Update Set Display")
    BiSTracker.MainFrame.SetName:SetText(BiSTracker.SelectedSetName)
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
    
    local SlotIcons = {
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

    for key, value in pairs(BiSTracker.MainFrame.Slots) do
        print(key)
        BiSTracker.MainFrame.Slots[key] = CreateSlotIcon(SlotIcons[value], 40, 40, 45, 45)
        if (key <= 8) then
            BiSTracker.MainFrame.LeftSlots:AddChild(BiSTracker.MainFrame.Slots[key])
        elseif (key <= 16) then
            BiSTracker.MainFrame.RightSlots:AddChild(BiSTracker.MainFrame.Slots[key])
        else
            BiSTracker.MainFrame.BottomSlots:AddChild(BiSTracker.MainFrame.Slots[key])
        end
    end

end