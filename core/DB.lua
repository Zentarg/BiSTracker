local defaults = {
    profile = {
        minimap = {
            hide = false,
            minimapPos = 220,
            radius = 80
        },
        mainframe = {
            connectedToCharacterFrame = false
        }
    }
}

function BiSTracker:InitDB()
    local db = LibStub("AceDB-3.0"):New("BiSTrackerDB", defaults, true)
    BiSTracker.db = db
end