BiSTracker.MainFrame = BiSTracker.AceGUI:Create("Window")
--BiSTracker.MainFrame:SetParent(CharacterFrame)
BiSTracker.MainFrame:EnableResize(false)
BiSTracker.MainFrame:SetTitle("BiS Tracker")
BiSTracker.MainFrame:SetHeight(CharacterFrame:GetHeight()-2)
BiSTracker.MainFrame:SetLayout("Flow")
BiSTracker.MainFrame:SetWidth(250)


local function CreateSimpleGroup(layout, width, height)
    local o = BiSTracker.AceGUI:Create("SimpleGroup")
    o:SetLayout(layout)
    if (width ~= 0) then o:SetWidth(width) end
    if (height ~= 0) then o:SetHeight(height) end
    return o
end

BiSTracker.MainFrame.LeftSlots = CreateSimpleGroup("list", 45, 0)
BiSTracker.MainFrame.BottomSlots = CreateSimpleGroup("flow", 136, 45)
BiSTracker.MainFrame.BottomSlots:SetAutoAdjustHeight(false)
BiSTracker.MainFrame.RightSlots = CreateSimpleGroup("list", 45, 0)

BiSTracker.MainFrame:AddChild(BiSTracker.MainFrame.LeftSlots)
BiSTracker.MainFrame:AddChild(BiSTracker.MainFrame.BottomSlots)
BiSTracker.MainFrame:AddChild(BiSTracker.MainFrame.RightSlots)

local SlotPositions = {
    Head = {
        x = 0,
        y = 0
    },
    Neck = {
        x = 0,
        y = 0
    },
    Shoulders = {
        x = 0,
        y = 0
    }, 
    Back = {
        x = 0,
        y = 0
    }, 
    Chest = {
        x = 0,
        y = 0
    }, 
    Wrist = {
        x = 0,
        y = 0
    }, 
    Hands = {
        x = 0,
        y = 0
    }, 
    Waist = {
        x = 0,
        y = 0
    }, 
    Legs = {
        x = 0,
        y = 0
    }, 
    Feet = {
        x = 0,
        y = 0
    }, 
    Finger1 = {
        x = 0,
        y = 0
    }, 
    Finger2 = {
        x = 0,
        y = 0
    }, 
    Trinket1 = {
        x = 0,
        y = 0
    }, 
    Trinket2 = {
        x = 0,
        y = 0
    }, 
    Mainhand = {
        x = 0,
        y = 0
    }, 
    Offhand = {
        x = 0,
        y = 0
    }, 
    Relic = {
        x = 0,
        y = 0
    }
}

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
    BiSTracker.MainFrame.Slots[key] = BiSTracker.AceGUI:Create("Icon")
    BiSTracker.MainFrame.Slots[key]:SetImage(SlotIcons[value])
    BiSTracker.MainFrame.Slots[key]:SetImageSize(40,40)
    BiSTracker.MainFrame.Slots[key]:SetWidth(45)
    BiSTracker.MainFrame.Slots[key]:SetHeight(45)
    if (key <= 8) then
        BiSTracker.MainFrame.LeftSlots:AddChild(BiSTracker.MainFrame.Slots[key])
    elseif (key <= 16) then
        BiSTracker.MainFrame.RightSlots:AddChild(BiSTracker.MainFrame.Slots[key])
    else
        BiSTracker.MainFrame.BottomSlots:AddChild(BiSTracker.MainFrame.Slots[key])
    end
end


--[[
    TODO:
    Create new layout, specifically for the item sheet.
    AceGUI:RegisterLayout("BiSSheet",
        function(content, children)
            First child anchored to the left
            Second child anchored to the bottom plus a margin
            Third child anchored to the right
            Last child (Buttons) anchored to the bottom
        end)
]]