BiSTracker = LibStub("AceAddon-3.0"):NewAddon("BiSTracker", "AceConsole-3.0", "AceEvent-3.0", "AceSerializer-3.0")
BiSTracker.AceGUI = LibStub("AceGUI-3.0")
local ldb = LibStub("LibDataBroker-1.1"):NewDataObject("BiSTracker", {
    type = "data source",
    text = "BiSTracker",
    icon = "Interface\\Addons\\BiSTracker\\Assets\\icon",
    OnClick = function(Tip, button)
        if button == "LeftButton"  then
            BiSTracker:ToggleMainFrame()
        elseif button == "RightButton" then
            BiSTracker:ToggleOptions()
        end
    end,
    OnTooltipShow = function(Tip)
        if not Tip or not Tip.AddLine then
            return
        end
        Tip:AddLine("BiSTracker")
        Tip:AddLine("|cffffff00Left click:|r Toggle BiSTrackers main window", 1, 1, 1)
        Tip:AddLine("|cffffff00Right click:|r Toggle BiSTrackers options window", 1, 1, 1)
    end,
})
local icon = LibStub("LibDBIcon-1.0")




function BiSTracker:ToggleMainFrame()
    if (BiSTracker.MainFrame:IsVisible()) then
        BiSTracker.MainFrame:Hide()
    else
        BiSTracker.MainFrame:Show()
    end
end

BiSTracker.Version = 3.3

BiSTracker.SelectedClass = ""
BiSTracker.SelectedSetName = ""
BiSTracker.CurrentClass = ""
BiSTracker.IsHoveringItemSlot = false

BiSTracker.Item = {
    ID = 0,
    Obtain = {
        NpcID = 0,
        NpcName = "",
        Kill = false,
        Quest = false,
        QuestID = 0,
        Recipe = false,
        RecipeID = 0,
        DropChance = 0,
        Zone = ""
    }
}
BiSTracker.Item.__index = BiSTracker.Item
function BiSTracker.Item:New(id, npcID, npcName, kill, quest, questID, recipe, recipeID, dropchance, zone)
    local self = setmetatable({}, BiSTracker.Item)
    self.ID = id
    self.Obtain = {}
    self.Obtain.NpcID = npcID
    self.Obtain.NpcName = npcName -- LEGACY
    self.Obtain.Kill = kill
    self.Obtain.Quest = quest
    self.Obtain.QuestID = questID
    self.Obtain.Recipe = recipe
    self.Obtain.RecipeID = recipeID
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
        Shoulder = {
        },
        Back = {
        },
        Chest = {
        },
        Shirt = {
        },
        Tabard = {
        },
        Wrists = {
        },
        Hands = {
        },
        Waist = {
        },
        Legs = {
        },
        Feet = {
        },
        Finger = {
        },
        RFinger = {
        },
        Trinket = {
        },
        RTrinket = {
        },
        MainHand = {
        },
        SecondaryHand = {
        },
        Relic = {
        }
    }
}
BiSTracker.Set.__index = BiSTracker.Set
function BiSTracker.Set:New (name, head, neck, shoulder, back, chest, shirt, tabard, wrists, hands, waist, legs, feet, finger, rfinger, trinket, rtrinket, mainhand, secondaryhand, relic)
    local self = setmetatable({}, BiSTracker.Set)
    self.Name = name
    self.Slots = {}
    self.Slots.Head = head
    self.Slots.Neck = neck
    self.Slots.Shoulder = shoulder
    self.Slots.Back = back
    self.Slots.Chest = chest
    self.Slots.Shirt = shirt
    self.Slots.Tabard = tabard
    self.Slots.Wrists = wrists
    self.Slots.Hands = hands
    self.Slots.Waist = waist
    self.Slots.Legs = legs
    self.Slots.Feet = feet
    self.Slots.Finger = finger
    self.Slots.RFinger = rfinger
    self.Slots.Trinket = trinket
    self.Slots.RTrinket = rtrinket
    self.Slots.MainHand = mainhand
    self.Slots.SecondaryHand = secondaryhand
    self.Slots.Relic = relic
    return self
end

function ItemIsObtainType(val, type)
    return val.Obtain.Type and type or false
end
function GetItemFromOldDataSlot(slot)
    return BiSTracker.Item:New(slot.itemID, 0, slot.Obtain.Method, ItemIsObtainType(slot, "By Killing"), ItemIsObtainType(slot, "By Quest"), 0, ItemIsObtainType(slot, "By Profession"), 0, slot.Obtain.Drop, slot.Obtain.Zone)
end


function BiSTracker:Init()
    if type(BiS_Settings) ~= "table" or BiS_Settings.CustomSpecsData == nil then
        BiS_Settings = {}
        BiS_Settings.CustomSets = {}
        BiS_Settings.Version = BiSTracker.Version
        BiSTracker.Settings = BiS_Settings
    else
        BiSTracker.Settings = BiS_Settings
        if BiSTracker.Settings.Version == nil then --Migrate custom specs from 1.0 to 2.0
            BiSTracker.Settings.CustomSets = {}
            for key, value in pairs(BiSTracker.Settings.CustomSpecsData) do
                for _, item in pairs(value) do
                    BiSTracker.Settings.CustomSets[key] = BiSTracker.Set:New(
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
            BiSTracker.Settings.CustomSpecsData = nil;
            BiS_Settings = BiSTracker.Settings
        end
        BiS_Settings.Version = BiSTracker.Version
    end

    local _,englishClass,_ = UnitClass("player")

    BiSTracker.CurrentClass = englishClass:lower():gsub("^%l", string.upper)

    BiSTracker:InitUI()
end

function BiSTracker:OnInitialize()
    BiSTracker.InitDB()
    BiSTracker:RegisterEvents()
    BiSTracker:Init()
    BiSTracker:InitImportExport()
    BiSTracker:InitOptions()
    icon:Register("BiSTracker", ldb, self.db.profile.minimap)
end

function BiSTracker:ToggleOptions()
    if BiSTracker.Options.GUI:IsVisible() then
        BiSTracker.Options.GUI:Hide()
    else
        BiSTracker.Options.GUI:Show()
    end
end

function BiSTracker:ToggleMinimapButton()
    self.db.profile.minimap.hide = not self.db.profile.minimap.hide
    if self.db.profile.minimap.hide then
        icon:Hide("BiSTracker")
    else
        icon:Show("BiSTracker")
    end
end