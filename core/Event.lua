BiSTracker.Events = {
    MODIFIER_STATE_CHANGED = function(event, modifier, pressed)
        if (modifier == "LCTRL" or modifier == "RCTRL") then
            if (pressed == 1) then
                if (BiSTracker.IsHoveringItemSlot) then
                    ShowInspectCursor()
                end
            else
                SetCursor(nil)
            end
        end
    end,
}

function BiSTracker:RegisterEvents()
    for key, value in pairs(BiSTracker.Events) do
        BiSTracker:RegisterEvent(key, value)
    end
end