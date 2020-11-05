BiSTracker = {}
BiSTracker.Name = "BiSTracker"
BiSTracker.Version = 2.0

BiSTracker.Item = {
    ID = 0,
    Obtain = {
        NpcID = 0,
        NpcName = "", -- LEGACY
        Kill = false,
        Quest = false,
        Recipe = false,
        DropChance = 0,
        Zone = ""
    }
}
BiSTracker.Item.__index = BiSTracker.Item

function BiSTracker.Item:New(id, npcID, npcName, kill, quest, recipe, dropchance, zone)
    local self = setmetatable({}, BiSTracker.Item)
    self.ID = id
    self.Obtain = {}
    self.Obtain.NpcID = npcID
    self.Obtain.NpcName = npcName -- LEGACY
    self.Obtain.Kill = kill
    self.Obtain.Quest = quest
    self.Obtain.Recipe = recipe
    self.Obtain.DropChance = dropchance
    self.Obtain.Zone = zone
    return self;
end

BiSTracker.Set = {
    Name = "",
    Slots = {
        Head = {
        },
        Neck = {
        },
        Shoulders = {
        },
        Back = {
        },
        Chest = {
        },
        Wrist = {
        },
        Hands = {
        },
        Waist = {
        },
        Legs = {
        },
        Feet = {
        },
        Finger1 = {
        },
        Finger2 = {
        },
        Trinket1 = {
        },
        Trinket2 = {
        },
        MainHand = {
        },
        OffHand = {
        },
        Relic = {
        }
    }
}

BiSTracker.Set.__index = BiSTracker.Set

function BiSTracker.Set:New (name, head, neck, shoulders, back, chest, wrist, hands, waist, legs, feet, finger1, finger2, trinket1, trinket2, mainhand, offhand, relic)
    local self = setmetatable({}, BiSTracker.Set)
    self.Name = name
    self.Slots = {}
    self.Slots.Head = head
    self.Slots.Neck = neck
    self.Slots.Shoulders = shoulders
    self.Slots.Back = back
    self.Slots.Chest = chest
    self.Slots.Wrist = wrist
    self.Slots.Hands = hands
    self.Slots.Waist = waist
    self.Slots.Legs = legs
    self.Slots.Feet = feet
    self.Slots.Finger1 = finger1
    self.Slots.Finger2 = finger2
    self.Slots.Trinket1 = trinket1
    self.Slots.Trinket2 = trinket2
    self.Slots.MainHand = mainhand
    self.Slots.OffHand = offhand
    self.Slots.Relic = relic
    return self
end

BiSTracker.EventListener = CreateFrame("Frame")


function ItemIsObtainType(val, type)
    return val.Obtain.Type and type or false
end

function GetItemFromOldDataSlot(slot)
    return BiSTracker.Item:New(slot.itemID, 0, slot.Obtain.Method, ItemIsObtainType(slot, "By Killing"), ItemIsObtainType(slot, "By Quest"), ItemIsObtainType(slot, "By Profession"), slot.Obtain.Drop, slot.Obtain.Zone)
end

function BiSTracker:Init()
    BiSTracker.Settings = BiS_Settings
    if type(BiSTracker.Settings) ~= "table" then
        BiS_Settings = {}
        BiS_Settings.CustomSpecs = {}
        BiS_Settings.Version = BiSTracker.Version
        BiS_Settings.AttachedToCharacterFrame = true
    else
        print(BiSTracker.Settings.Version)
        if BiSTracker.Settings.Version == nil then --Migrate custom specs from 1.0 to 2.0
            BiSTracker.Settings.CustomSpecs = {}
            for key, value in pairs(BiSTracker.Settings.CustomSpecsData) do
                print(key)
                for _, item in pairs(value) do
                    BiSTracker.Settings.CustomSpecs[key] = BiSTracker.Set:New(
                    key, 
                    GetItemFromOldDataSlot(item.Head), 
                    GetItemFromOldDataSlot(item.Neck), 
                    GetItemFromOldDataSlot(item.Shoulder), 
                    GetItemFromOldDataSlot(item.Cloak), 
                    GetItemFromOldDataSlot(item.Chest), 
                    GetItemFromOldDataSlot(item.Wrist), 
                    GetItemFromOldDataSlot(item.Gloves), 
                    GetItemFromOldDataSlot(item.Waist), 
                    GetItemFromOldDataSlot(item.Legs), 
                    GetItemFromOldDataSlot(item.Boots), 
                    GetItemFromOldDataSlot(item.Ring1), 
                    GetItemFromOldDataSlot(item.Ring2), 
                    GetItemFromOldDataSlot(item.Trinket1), 
                    GetItemFromOldDataSlot(item.Trinket2), 
                    GetItemFromOldDataSlot(item.MainHand), 
                    GetItemFromOldDataSlot(item.OffHand), 
                    GetItemFromOldDataSlot(item.Ranged))
                end
            end
            BiSTracker.Settings.CustomSpecsData = "Deprecated";
            BiS_Settings = BiSTracker.Settings
        end
        BiS_Settings.Version = BiSTracker.Version
    end
    if (BiSTracker.Settings.AttachedToCharacterFrame) then
        BiSTracker.MainFrame = CreateFrame("Frame", "BiSMainFrame", CharacterFrame, "BiSFrameTemplate");
    else
        BiSTracker.MainFrame = CreateFrame("Frame", "BiSMainFrame", UIParent, "BiSFrameTemplate");
    end
end

BiSTracker.EventListener:RegisterEvent("ADDON_LOADED")
BiSTracker.EventListener:SetScript("OnEvent", function(self, event, arg1, ...)
    if (event == "ADDON_LOADED" and BiSTracker.Name == arg1) then
        BiSTracker:Init()
    end
end)