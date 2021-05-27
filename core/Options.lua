BiSTracker.Options = {}
BiSTracker.Options.GUI = {}
BiSTracker.Options.GUI.Tabs = {}

local tabs = {
    {
        text = "General",
        value = "General"
    },
    {
        text = "Main Window",
        value = "MainFrame"
    }
}

local function CreateSlider(label, value, minValue, maxValue, step, isPercent, isDisabled)
    local o = BiSTracker.AceGUI:Create("Slider")
    o:SetLabel(label)
    o:SetSliderValues(minValue, maxValue, step)
    o:SetValue(value)
    o:SetIsPercent(isPercent)
    o:SetDisabled(isDisabled)
    return o
end

local function CreateButton(text, disabled, width)
    local o = BiSTracker.AceGUI:Create("Button")
    o:SetText(text)
    o:SetDisabled(disabled)
    o:SetWidth(width)
    return o
end

local function CreateCheckbox(label, description, image, value, type, disabled)
    local o = BiSTracker.AceGUI:Create("CheckBox")
    o:SetLabel(label)
    o:SetDescription(description)
    if image ~= nil then
        o:SetImage(image)   
    end
    o:SetValue(value)
    o:SetType(type)
    o:SetDisabled(disabled)
    return o
end


local function DrawGeneralTab(container)
    --Disable Minimap Button
    local mb = CreateCheckbox("Disable Minimap Button", "", nil, BiSTracker.db.profile.minimap.hide, "checkbox", false)
    mb:SetCallback("OnValueChanged", function(self, event, value)
        BiSTracker.ChatCommands:ToggleMinimapButton()
    end)

    container:AddChild(mb)
end

local function DrawMainFrameTab(container)
    --Connect mainframe to characterframe
    local mf = CreateCheckbox("Connect to CharacterFrame", "*Requires reload", nil, BiSTracker.db.profile.mainframe.connectedToCharacterFrame, "checkbox", false)
    mf:SetCallback("OnValueChanged", function(self, event, value)
        BiSTracker.db.profile.mainframe.connectedToCharacterFrame = value
    end)
    mf:SetFullWidth(true)

    --Compact UI
    local compact = CreateCheckbox("Use Compact View", "*Requires Reload", nil, BiSTracker.db.profile.mainframe.compact, "checkbox", false)
    compact:SetCallback("OnValueChanged", function(self, event, value)
        BiSTracker.db.profile.mainframe.compact = value;
    end)

    --MainFrame Toggle Button X value (CharacterFrame)
    local mftx = CreateSlider("CharacterFrame toggle button X Pos", BiSTracker.db.profile.mainframe.mainframeToggleButtonXPosition, -290, -30, 5, false, not BiSTracker.db.profile.mainframe.connectedToCharacterFrame)
    mftx:SetCallback("OnValueChanged", function(self, event, value)
        BiSTracker.db.profile.mainframe.mainframeToggleButtonXPosition = value
        BiSTracker.MainFrame.characterFrameToggle:SetPoint("TOPRIGHT", CharacterFrame, "TOPRIGHT", value, BiSTracker.db.profile.mainframe.mainframeToggleButtonYPosition)
    end)
    mftx:SetHeight(60)
    mftx:SetFullWidth(true)

    --MainFrame Toggle Button Y value (CharacterFrame)
    local mfty = CreateSlider("CharacterFrame toggle button Y Pos", BiSTracker.db.profile.mainframe.mainframeToggleButtonYPosition, -45, -30, 1, false, not BiSTracker.db.profile.mainframe.connectedToCharacterFrame)
    mfty:SetCallback("OnValueChanged", function(self, event, value)
        BiSTracker.db.profile.mainframe.mainframeToggleButtonYPosition = value
        BiSTracker.MainFrame.characterFrameToggle:SetPoint("TOPRIGHT", CharacterFrame, "TOPRIGHT", BiSTracker.db.profile.mainframe.mainframeToggleButtonXPosition, value)
    end)
    mfty:SetHeight(60)
    mfty:SetFullWidth(true)

    --Reload Btn
    local reloadBtn = CreateButton("Reload UI", false, 120)
    reloadBtn:SetPoint("BOTTOMRIGHT", BiSTracker.Options.GUI.frame, "BOTTOMRIGHT")
    reloadBtn:SetCallback("OnClick", function()
        ReloadUI()
    end)

    container:AddChild(mf)
    container:AddChild(compact)
    container:AddChild(mftx)
    container:AddChild(mfty)
    container:AddChild(reloadBtn)
end

local function SelectTab(container, event, group)
    container:ReleaseChildren()
    if group == "General" then
        DrawGeneralTab(container)
    elseif group == "MainFrame" then
        DrawMainFrameTab(container)
    end
end


function BiSTracker:InitOptions()
    BiSTracker.Options.GUI = BiSTracker.AceGUI:Create("Window")
    BiSTracker.Options.GUI:EnableResize(false)
    BiSTracker.Options.GUI:SetTitle("BiSTracker Options")
    BiSTracker.Options.GUI:SetHeight(320)
    BiSTracker.Options.GUI:SetWidth(300)
    BiSTracker.Options.GUI:SetFullHeight(true)
    
    BiSTracker.Options.GUI.Tabs = BiSTracker.AceGUI:Create("TabGroup")
    BiSTracker.Options.GUI.Tabs:SetTabs(tabs)
    BiSTracker.Options.GUI.Tabs:SetFullWidth(true)
    BiSTracker.Options.GUI.Tabs:SetFullHeight(true)
    BiSTracker.Options.GUI.Tabs:SetCallback("OnGroupSelected", SelectTab)
    BiSTracker.Options.GUI.Tabs:SelectTab("General")
    
    BiSTracker.Options.GUI:SetCallback("OnClose", function()
        BiSTracker.Options.GUI.Tabs:ReleaseChildren()
    end)
    BiSTracker.Options.GUI:SetCallback("OnShow", function()
        BiSTracker.Options.GUI.Tabs:SelectTab("General")
    end)

    BiSTracker.Options.GUI:AddChild(BiSTracker.Options.GUI.Tabs)
    
    BiSTracker.Options.GUI:Hide()
end