BiSTracker = LibStub("AceAddon-3.0"):NewAddon("BiSTracker", "AceConsole-3.0", "AceEvent-3.0", "AceSerializer-3.0")
BiSTracker.AceGUI = LibStub("AceGUI-3.0")
local L
local ldb
local icon = LibStub("LibDBIcon-1.0")


local function InitMinimapButton()
    ldb = LibStub("LibDataBroker-1.1"):NewDataObject("BiSTracker", {
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
            Tip:AddLine(L["|cffffff00Left click:|r Toggle BiSTrackers main window"], 1, 1, 1)
            Tip:AddLine(L["|cffffff00Right click:|r Toggle BiSTrackers options window"], 1, 1, 1)
        end,
    })
    
end


function BiSTracker:ToggleMainFrame()
    if (BiSTracker.MainFrame:IsVisible()) then
        BiSTracker.MainFrame:Hide()
    else
        BiSTracker.MainFrame:Show()
    end
end

BiSTracker.Version = 4.9

BiSTracker.SelectedClass = ""
BiSTracker.SelectedSetName = ""
BiSTracker.CurrentClass = ""
BiSTracker.IsHoveringItemSlot = false

BiSTracker.Item = {
    id = 0,
    name = "",
    source = {
        ID=0,
        SourceName="",
        SourceType="",
        DropChance="",
        Zone=""
    }
}
BiSTracker.Item.__index = BiSTracker.Item
function BiSTracker.Item:New(id, name, sourceID, sourceName, sourceType, dropChance, zone)--npcID, npcName, kill, quest, questID, recipe, recipeID, dropchance, zone)
    local self = setmetatable({}, BiSTracker.Item)
    self.id = id
    self.name = name
    self.source = {}
    self.source.ID = sourceID
    self.source.SourceName = sourceName
    self.source.SourceType = sourceType
    self.source.DropChance = dropChance
    self.source.Zone = zone
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

function GetV1ItemObtainType(val)
    if (val.Obtain.Type == "By Killing") then
        return "Kill"
    elseif (val.Obtain.Type == "By Quest") then
        return "Quest"
    elseif (val.Obtain.Type == "By Profession") then
        return "Profession"
    end
end
function GetItemFromV1DataSlot(slot)
    return BiSTracker.Item:New(slot.itemID, "", 0, slot.Obtain.Method, GetV1ItemObtainType(slot), slot.Obtain.Drop, slot.Obtain.Zone)
end

function GetItemFromV2DataSlot(slot)
    local item = BiSTracker.Item:New(0, "", 0, "", "Kill", "0", "")
    if (slot == nil) then
        return item
    end

    if (slot.Obtain.Kill) then
        item = BiSTracker.Item:New(slot.ID, "", slot.Obtain.NpcID, slot.Obtain.NpcName, "Kill", slot.Obtain.DropChance, slot.Obtain.Zone)
    elseif (slot.Obtain.Quest) then
        item = BiSTracker.Item:New(slot.ID, "", slot.Obtain.QuestID, slot.Obtain.NpcName, "Quest", slot.Obtain.DropChance, slot.Obtain.Zone)
    elseif (slot.Obtain.Recipe) then
        item = BiSTracker.Item:New(slot.ID, "", slot.Obtain.RecipeID, slot.Obtain.NpcName, "Recipe", slot.Obtain.DropChance, slot.Obtain.Zone)
    else
        item = BiSTracker.Item:New(slot.ID, "", 0, "", "Unknown", "0", "")
    end

    return item
end


function BiSTracker:Init()

    if type(BiS_Settings) ~= "table" then
        BiS_Settings = {}
        BiS_Settings.CustomSets = {}
        BiS_Settings.Version = BiSTracker.Version
        BiS_Settings.Locale = "enUS"
        if (BiSTracker.L[GetLocale()] ~= nil) then
            BiS_Settings.Locale = GetLocale()
        end
        BiSTracker.Settings = BiS_Settings
    else
        BiSTracker.Settings = BiS_Settings
        if BiSTracker.Settings.Version == nil then --Migrate custom specs from 1.0 to 2.0
            BiSTracker.Settings.CustomSets = {}
            for key, value in pairs(BiSTracker.Settings.CustomSpecsData) do
                for _, item in pairs(value) do
                    BiSTracker.Settings.CustomSets[key] = BiSTracker.Set:New(
                    key, 
                    GetItemFromV1DataSlot(item.Head), 
                    GetItemFromV1DataSlot(item.Neck), 
                    GetItemFromV1DataSlot(item.Shoulder), 
                    GetItemFromV1DataSlot(item.Cloak), 
                    GetItemFromV1DataSlot(item.Chest), 
                    GetItemFromV1DataSlot(item.Wrist), 
                    GetItemFromV1DataSlot(item.Gloves), 
                    GetItemFromV1DataSlot(item.Waist), 
                    GetItemFromV1DataSlot(item.Legs), 
                    GetItemFromV1DataSlot(item.Boots), 
                    GetItemFromV1DataSlot(item.Ring1), 
                    GetItemFromV1DataSlot(item.Ring2), 
                    GetItemFromV1DataSlot(item.Trinket1), 
                    GetItemFromV1DataSlot(item.Trinket2), 
                    GetItemFromV1DataSlot(item.MainHand), 
                    GetItemFromV1DataSlot(item.OffHand), 
                    GetItemFromV1DataSlot(item.Ranged))
                end
            end
            BiSTracker.Settings.CustomSpecsData = nil;
            BiS_Settings = BiSTracker.Settings
        elseif BiSTracker.Settings.Version < 4.5 then
            for key, value in pairs(BiSTracker.Settings.CustomSets) do
                BiSTracker.Settings.CustomSets[key] = BiSTracker.Set:New(
                key,
                GetItemFromV2DataSlot(value.Slots.Head),
                GetItemFromV2DataSlot(value.Slots.Neck),
                GetItemFromV2DataSlot(value.Slots.Shoulder),
                GetItemFromV2DataSlot(value.Slots.Back),
                GetItemFromV2DataSlot(value.Slots.Chest),
                GetItemFromV2DataSlot(nil),
                GetItemFromV2DataSlot(nil),
                GetItemFromV2DataSlot(value.Slots.Wrists),
                GetItemFromV2DataSlot(value.Slots.Hands),
                GetItemFromV2DataSlot(value.Slots.Waist),
                GetItemFromV2DataSlot(value.Slots.Legs),
                GetItemFromV2DataSlot(value.Slots.Feet),
                GetItemFromV2DataSlot(value.Slots.Finger),
                GetItemFromV2DataSlot(value.Slots.RFinger),
                GetItemFromV2DataSlot(value.Slots.Trinket),
                GetItemFromV2DataSlot(value.Slots.RTrinket),
                GetItemFromV2DataSlot(value.Slots.MainHand),
                GetItemFromV2DataSlot(value.Slots.SecondaryHand),
                GetItemFromV2DataSlot(value.Slots.Relic)
                )
            end
        elseif BiSTracker.Settings.Version < 4.9 and BiSTracker.Settings.Locale == nil then
            BiSTracker.Settings.Locale = "enUS"
            if (BiSTracker.L[GetLocale()] ~= nil) then
                BiSTracker.Settings.Locale = GetLocale()
            end
        end
        BiS_Settings.Version = BiSTracker.Version
    end

    local _,englishClass,_ = UnitClass("player")

    BiSTracker.CurrentClass = englishClass:lower():gsub("^%l", string.upper)
    L = BiSTracker.L[BiSTracker.Settings.Locale]
end

function BiSTracker:InitEquippableDB()
    BiSTracker.ItemDB = LibStub and LibStub("LibEquippable-1.0", true)
end

function BiSTracker:OnInitialize()
    BiSTracker:InitLocale()
    BiSTracker:Init()

    BiSTracker:InitChatCommands()
    BiSTracker.InitDB()
    BiSTracker:RegisterEvents()
    BiSTracker:InitUI()
    BiSTracker:InitImportExport()
    BiSTracker:InitOptions()
    BiSTracker:InitEquippableDB()
    InitMinimapButton()
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