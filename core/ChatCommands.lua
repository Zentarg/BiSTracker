BiSTracker:RegisterChatCommand("bistracker", "ChatCommand")
BiSTracker:RegisterChatCommand("bst", "ChatCommand")

BiSTracker.ChatCommands = {}

BiSTracker.ChatCommands.HelpList = {
    Help = {
        Command = "/BST Help",
        Description = "Shows this list"
    }
}

function BiSTracker.ChatCommands:Help() 
    BiSTracker:Print("|c00ffff00Version " .. BiSTracker.Version .. " commands:")
    BiSTracker:Print("|cffffff00/BiSTracker: |cffffffffToggles the BiSTracker window")
    BiSTracker:Print("|cffffff00/BST: |cffffffffShort for /BiSTracker")
    for key, value in pairs(BiSTracker.ChatCommands.HelpList) do
        BiSTracker:Print("|cffffff00" .. value.Command .. ": |cffffffff" .. value.Description)
    end
end

function BiSTracker:ChatCommand(msg)
    if (msg == nil or msg == "") then
        if (BiSTracker.MainFrame:IsVisible()) then
            BiSTracker.MainFrame:Hide()
        else
            BiSTracker.MainFrame:Show()
        end
    end
    local args = {}
    for token in string.gmatch(msg, "[^%s]+") do
        table.insert(args, token)
        print(token)
    end
    if (args[1] == "help") then
        BiSTracker.ChatCommands:Help()
    end
end