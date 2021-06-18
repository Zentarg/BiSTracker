-- LOCALE FILE
-- ADD A NEW TABLE PER LOCALE AND THE ADDON WILL HANDLE THE REST


-- L["LOCALE"]["STRING_KEY"] = "TRANSLATION"

local L = {}

-- ENGLISH / DEFAULT

L["enUS"] = {}
-- Chat Commands
L["enUS"]["Shows this list"] = "Shows this list"
L["enUS"]["Toggles the minimap button"] = "Toggles the minimap button"
L["enUS"]["Short for /BST ToggleMinimapButton"] = "Short for /BST ToggleMinimapButton"
L["enUS"]["Opens the BiSTracker Options window"] = "Opens the BiSTracker Options window"
L["enUS"]["|c00ffff00Version "] = "|c00ffff00Version "
L["enUS"][" commands:"] = " commands:"
L["enUS"]["|cffffff00/BiSTracker: |cffffffffToggles the BiSTracker window"] = "|cffffff00/BiSTracker: |cffffffffToggles the BiSTracker window"
L["enUS"]["|cffffff00/BST: |cffffffffShort for /BiSTracker"] = "|cffffff00/BST: |cffffffffShort for /BiSTracker"
-- Error
L["enUS"]["|cffff0000An error has occured: |cffffffff"] = "|cffff0000An error has occured: |cffffffff"
-- GUI
L["enUS"]["Are you sure you want to delete the set |cffff0000"] = "Are you sure you want to delete the set |cffff0000"
L["enUS"]["Item ID:"] = "Item ID:"
L["enUS"]["Kill npc:"] = "Kill npc:"
L["enUS"]["Located in:"] = "Located in:"
L["enUS"]["Drop chance:"] = "Drop chance:"
L["enUS"][" |cffffffff(ID: "] = " |cffffffff(ID: "
L["enUS"]["Sold by:"] = "Sold by:"
L["enUS"]["Quest Not Found"] = "Quest Not Found"
L["enUS"]["Quest:"] = "Quest:"
L["enUS"]["Contained in:"] = "Contained in:"
L["enUS"]["No source information found."] = "No source information found."
L["enUS"]["|cff00ff00You have this item."] = "|cff00ff00You have this item."
L["enUS"]["|cffff0000You do not have this item."] = "|cffff0000You do not have this item."
L["enUS"]["|cffff0000An error occured while loading this item.\nPlease try reloading the set."] = "|cffff0000An error occured while loading this item.\nPlease try reloading the set."
L["enUS"]["|cffff0000Error loading item, please try reloading."] = "|cffff0000Error loading item, please try reloading."
L["enUS"]["An item in the |cffffff00"] = "An item in the |cffffff00"
L["enUS"]["|r set |cffffff00"] = "|r set |cffffff00"
L["enUS"]["|r didn't load correctly. Please try reloading the set."] = "|r didn't load correctly. Please try reloading the set."
L["enUS"]["Npc ID"] = "Npc ID"
L["enUS"]["Npc Name"] = "Npc Name"
L["enUS"]["Container ID"] = "Container ID"
L["enUS"]["Container Name"] = "Container Name"
L["enUS"]["Quest ID"] = "Quest ID"
L["enUS"]["Recipe ID"] = "Recipe ID"
L["enUS"]["Edit Slot"] = "Edit Slot"
L["enUS"]["Confirm Deletion"] = "Confirm Deletion"
L["enUS"]["Edit "] = "Edit "
L["enUS"][" Class"] = " Class"
L["enUS"][" Set"] = " Set"
L["enUS"]["Toggle BiSTracker window"] = "Toggle BiSTracker window"
L["enUS"]["Are you sure you want to delete this set?"] = "Are you sure you want to delete this set?"
L["enUS"]["Zone"] = "Zone"
L["enUS"]["Drop Chance"] = "Drop Chance"
L["enUS"]["Cancel"] = "Cancel"
L["enUS"]["Save"] = "Save"
L["enUS"]["Obtain Method"] = "Obtain Method"
L["enUS"]["Item ID"] = "Item ID"
L["enUS"]["Reload"] = "Reload"
L["enUS"]["Open Import/Export window"] = "Open Import/Export window"
L["enUS"]["New Set"] = "New Set"
L["enUS"]["Create Custom Set"] = "Create Custom Set"
L["enUS"]["Delete Custom Set"] = "Delete Custom Set"
L["enUS"]["Set Name"] = "Set Name"
L["enUS"]["Set name cannot be shorter than 1 character."] = "Set name cannot be shorter than 1 character."
L["enUS"]["A set with the name |cffffff00"] = "A set with the name |cffffff00"
L["enUS"][" |cffffffffalready exists."] = " |cffffffffalready exists."
-- Import Export
L["enUS"]["The data to be imported did not match a BiSTracker set."] = "The data to be imported did not match a BiSTracker set."
L["enUS"]["The string supplied was an incorrect format."] = "The string supplied was an incorrect format."
L["enUS"]["Import String"] = "Import String"
L["enUS"]["Import"] = "Import"
L["enUS"]["Export"] = "Export"
L["enUS"]["New Set Name (Leave empty to inherit name)"] = "New Set Name (Leave empty to inherit name)"
L["enUS"]["A set already exists with the name |cffffff00"] = "A set already exists with the name |cffffff00"
L["enUS"]["Successfully imported the set |cffffff00"] = "Successfully imported the set |cffffff00"
L["enUS"]["|cffffffff as |cffffff00"] = "|cffffffff as |cffffff00"
L["enUS"]["No custom sets to export."] = "No custom sets to export."
L["enUS"]["Export String (This is the string you use to import a set)"] = "Export String (This is the string you use to import a set)"
L["enUS"]["The selected set to export could not be found."] = "The selected set to export could not be found."
L["enUS"]["Import / Export"] = "Import / Export"
L["enUS"]["Set"] = "Set"
L["enUS"]["Class"] = "Class"
-- Init
L["enUS"]["|cffffff00Left click:|r Toggle BiSTrackers main window"] = "|cffffff00Left click:|r Toggle BiSTrackers main window"
L["enUS"]["|cffffff00Right click:|r Toggle BiSTrackers options window"] = "|cffffff00Right click:|r Toggle BiSTrackers options window"
-- Options
L["enUS"]["General"] = "General"
L["enUS"]["Main Window"] = "Main Window"
L["enUS"]["Disable Minimap Button"] = "Disable Minimap Button"
L["enUS"]["Use Compact View"] = "Use Compact View"
L["enUS"]["Connect to CharacterFrame"] = "Connect to CharacterFrame"
L["enUS"]["*Requires reload"] = "*Requires reload"
L["enUS"]["CharacterFrame toggle button X Pos"] = "CharacterFrame toggle button X Pos"
L["enUS"]["CharacterFrame toggle button Y Pos"] = "CharacterFrame toggle button Y Pos"
L["enUS"]["Reload UI"] = "Reload UI"
L["enUS"]["BiSTracker Options"] = "BiSTracker Options"



function BiSTracker:InitLocale()
    print("Init Locale")
    if (L[GetLocale()] ~= nil) then
        BiSTracker.Locale = GetLocale()
    end
    BiSTracker.L = L
end
