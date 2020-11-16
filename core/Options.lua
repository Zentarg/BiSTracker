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
    },
}

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

    container:AddChild(mf)
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
    BiSTracker.Options.GUI:EnableResize(true)
    BiSTracker.Options.GUI:SetTitle("BiSTracker Options")
    BiSTracker.Options.GUI:SetHeight(220)
    BiSTracker.Options.GUI:SetWidth(300)
    BiSTracker.Options.GUI.frame:SetMinResize(300, 180)
    BiSTracker.Options.GUI.frame:SetMaxResize(500, 350)
    BiSTracker.Options.GUI:SetFullHeight(true)
    --BiSTracker.Options.GUI:Hide()

    BiSTracker.Options.GUI.Tabs = BiSTracker.AceGUI:Create("TabGroup")
    BiSTracker.Options.GUI.Tabs:SetTabs(tabs)
    BiSTracker.Options.GUI.Tabs:SetFullWidth(true)
    BiSTracker.Options.GUI.Tabs:SetFullHeight(true)
    BiSTracker.Options.GUI.Tabs:SetCallback("OnGroupSelected", SelectTab)
    BiSTracker.Options.GUI.Tabs:SelectTab("General")

    BiSTracker.Options.GUI:AddChild(BiSTracker.Options.GUI.Tabs)

end