BiSTracker:RegisterChatCommand("bistracker", "ChatCommand")
BiSTracker:RegisterChatCommand("bst", "ChatCommand")

BiSTracker.ChatCommands = {}

local L

BiSTracker.ChatCommands.HelpList = {}

function BiSTracker:InitChatCommands()
    L = BiSTracker.L[BiSTracker.Settings.Locale]
    BiSTracker.ChatCommands.HelpList = {
        Help = {
            Command = "/BST Help",
            Description = L["Shows this list"]
        },
        ToggleMinimapButton = {
            Command = "/BST ToggleMinimapButton",
            Description = L["Toggles the minimap button"]
        },
        TMB = {
            Command = "/BST TMB",
            Description = L["Short for /BST ToggleMinimapButton"]
        },
        Options = {
            Command = "/BST Options",
            Description = L["Opens the BiSTracker Options window"]
        }
    }
end


function BiSTracker.ChatCommands:Help() 
    BiSTracker:Print(L["|c00ffff00Version "] .. BiSTracker.Version .. L[" commands:"])
    BiSTracker:Print(L["|cffffff00/BiSTracker: |cffffffffToggles the BiSTracker window"])
    BiSTracker:Print(L["|cffffff00/BST: |cffffffffShort for /BiSTracker"])
    for key, value in pairs(BiSTracker.ChatCommands.HelpList) do
        BiSTracker:Print("|cffffff00" .. value.Command .. ": |cffffffff" .. value.Description)
    end
end

function BiSTracker.ChatCommands:ToggleMinimapButton()
    BiSTracker:ToggleMinimapButton()
end

function BiSTracker.ChatCommands:ToggleOptions()
    BiSTracker:ToggleOptions()
end

function BiSTracker:ChatCommand(msg)
    if (msg == nil or msg == "") then
        BiSTracker:ToggleMainFrame()
        return
    end
    local args = {}
    for token in string.gmatch(msg, "[^%s]+") do
        table.insert(args, token)
    end
    if (string.lower(args[1]) == "help") then
        BiSTracker.ChatCommands:Help()
        return
    end
    if (string.lower(args[1]) == "toggleminimapbutton" or string.lower(args[1]) == "tmb") then
        BiSTracker.ChatCommands:ToggleMinimapButton()
        return
    end
    if (string.lower(args[1]) == "options") then
        BiSTracker.ChatCommands:ToggleOptions()
        return
    end
    BiSTracker.ChatCommands:Help()
end