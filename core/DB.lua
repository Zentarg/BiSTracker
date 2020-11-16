local defaults = {
    profile = {
        minimap = {
            hide = false,
            minimapPos = 220,
            radius = 80
        },
        mainframe = {
            connectedToCharacterFrame = false,
            mainframeToggleButtonXPosition = -50,
            mainframeToggleButtonYPosition = -42.5
        }
    }
}

function BiSTracker:InitDB()
    local db = LibStub("AceDB-3.0"):New("BiSTrackerDB", defaults, true)
    BiSTracker.db = db
end