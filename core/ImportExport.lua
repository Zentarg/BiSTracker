BiSTracker.Serializer = {}
BiSTracker.Serializer.GUI = {}
BiSTracker.Serializer.GUI.Tabs = {}

local LibBase64 = nil;

function BiSTracker.Serializer:SerializeData(setData)
    return LibBase64.Encode(BiSTracker:Serialize(setData))
end


local function CheckIfSlotContainsData(slot)
    if (slot == nil or type(slot.ID) ~= "number" or type(slot.Obtain) ~= "table" or type(slot.Obtain.NpcID) ~= "number" or type(slot.Obtain.NpcName) ~= "string" or type(slot.Obtain.Kill) ~= "boolean"
    or type(slot.Obtain.Quest) ~= "boolean" or type(slot.Obtain.QuestID) ~= "number" or type(slot.Obtain.Recipe) ~= "boolean" or type(slot.Obtain.RecipeID) ~= "number"
    or (type(slot.Obtain.DropChance) ~= "number" and type(slot.Obtain.DropChance) ~= "string") or type(slot.Obtain.Zone) ~= "string") then
        return false
    end
    return true
end

function BiSTracker.Serializer.GUI:ToggleGUI()
    if (self.IsVisible()) then
        self:Hide()
    else
        self.Show()
    end
end

function BiSTracker.Serializer:DeserializeData(serializedString)
    serializedString = LibBase64.Decode(serializedString)
    local success, setData = BiSTracker:Deserialize(serializedString)
    if (success) then
        for key, value in pairs(BiSTracker.Set.Slots) do
            if (CheckIfSlotContainsData(setData.Slots[key]) == false) then
                BiSTracker:PrintError('The data to be imported did not match a BiSTracker set.')
                return false
            end
        end
        return setData
    end
    BiSTracker:PrintError('The string supplied was an incorrect format.')
    return false
end


local tabs = {
    {
        text = "Import",
        value = "Import"
    },
    {
        text = "Export",
        value = "Export"
    },
}

local function CreateMultiLineEditBox(text, label, numlines, maxLetters, disableButton)
    local o = BiSTracker.AceGUI:Create("MultiLineEditBox")
    o:SetText(text)
    o:SetLabel(label)
    o:SetNumLines(numlines)
    o:SetMaxLetters(maxLetters)
    o:DisableButton(disableButton)
    return o
end

local function CreateEditBox(text, label, disabled, disableButton, maxLetters, width)
    local o = BiSTracker.AceGUI:Create("EditBox")
    o:SetText(text)
    o:SetLabel(label)
    o:SetDisabled(disabled)
    o:DisableButton(disableButton)
    o:SetMaxLetters(maxLetters)
    o:SetWidth(width)
    return o
end

local function CreateDropdownMenu(label, defaultValue, children, width)
    local o = BiSTracker.AceGUI:Create("Dropdown")
    o:SetList(children)
    o:SetValue(defaultValue)
    o:SetLabel(label)
    o:SetWidth(width)
    return o
end

local function CreateButton(text, disabled, width)
    local o = BiSTracker.AceGUI:Create("Button")
    o:SetText(text)
    o:SetDisabled(disabled)
    o:SetWidth(width)
    return o
end

local function DrawImportTab(container)
    
    --          Import Text
    local importText = CreateMultiLineEditBox("", "Import String", 15, 0, true)
    importText.width = "fill"

    --          New Set Name
    local setNameEdit = CreateEditBox("", "New Set Name (Leave empty to inherit name)", false, false, 15, 250)
    
    --          Import Button
    local importBtn = CreateButton("Import Set", false, 100)
    importBtn:SetCallback("OnClick", function()
        local serializedString = importText:GetText()
        if (string.len(serializedString) == 0) then
            return
        end
        local set = BiSTracker.Serializer:DeserializeData(serializedString)

        if (string.len(setNameEdit:GetText()) > 0) then
            set.Name = setNameEdit:GetText()
        end

        if (BiSTracker.ClassSetList["Custom"][set.Name] ~= nil) then
            BiSTracker:PrintError("A set already exists with the name |cffffff00"..set.Name)
            setNameEdit:SetText("")
            return
        end

        BiSTracker.Settings.CustomSets[set.Name] = set
        BiSTracker.ClassSetList["Custom"][set.Name] = set.Name

        BiSTracker:Print("Successfully imported the set |cffffff00"..set.Name)
        setNameEdit:SetText("")

        if (BiSTracker.MainFrame:IsVisible() == false) then
            BiSTracker:ToggleMainFrame()
        end
        BiSTracker.SelectedClass = "Custom"
        BiSTracker.MainFrame.ActionsGroup.ClassDropdown:SetValue(BiSTracker.SelectedClass)
        BiSTracker.MainFrame:UpdateSetDropdown(set.Name)
        BiSTracker.MainFrame:UpdateSetDisplay()
        BiSTracker.MainFrame.TopRightButtonGroup.CreateSet:SetDisabled(false)
        BiSTracker.MainFrame.TopRightButtonGroup.RemoveSet:SetDisabled(false)
        BiSTracker.MainFrame.SetName:SetDisabled(false)
    end)



    container:AddChild(importText)
    container:AddChild(setNameEdit)
    container:AddChild(importBtn)
    
end

local function DrawExportTab(container)
    local label, setDropdown, exportText, exportBtn
    local sets = {}
    for key, value in pairs(BiSTracker.Settings.CustomSets) do
        table.insert(sets, key)
    end
    
    -- If no sets to export
    if (sets[1] == nil) then
        label = BiSTracker.AceGUI:Create("Label")
        label:SetText("No custom sets to export.")
        container:AddChild(label)
        return
    end
    
    --          Set Dropdown
    setDropdown = CreateDropdownMenu("Set", 1, sets, 200)
    setDropdown:SetCallback("OnValueChanged", function()
        exportText:SetText("")
    end)

    
    --          Export Text
    exportText = CreateMultiLineEditBox("", "Export String (This is the string you use to import a set)", 15, 0, true)
    exportText.width = "fill"

    --          Export Button
    exportBtn = CreateButton("Export Set", false, 100)
    exportBtn:SetCallback("OnClick", function()
        local selectedSet = setDropdown.list[setDropdown.value]
        local set = BiSTracker.Settings.CustomSets[selectedSet]
        if (set == nil) then
           BiSTracker:PrintError("The selected set to export could not be found.")
           BiSTracker.Serializer.GUI.Tabs:SelectTab("Export")
           return
        end
        exportText:SetText(BiSTracker.Serializer:SerializeData(set))
        exportText:SetFocus()
        exportText:HighlightText(0, string.len(exportText:GetText()))
    end)
    
    
    container:AddChild(setDropdown)
    container:AddChild(exportBtn)
    container:AddChild(exportText)
end

local function SelectTab(container, event, group)
    container:ReleaseChildren()
    if group == "Import" then
        DrawImportTab(container)
    elseif group == "Export" then
        DrawExportTab(container)
    end
end



function BiSTracker:InitImportExport()
    LibBase64 =  LibStub("LibBase64-1.0")
    BiSTracker.Serializer.GUI = BiSTracker.AceGUI:Create("Window")
    if (BiSTracker.db.profile.mainframe.connectedToCharacterFrame) then
        BiSTracker.Serializer.GUI:SetPoint("TOPLEFT", BiSTracker.MainFrame.frame, "TOPRIGHT")
    else
        BiSTracker.Serializer.GUI:SetPoint("TOPRIGHT", BiSTracker.MainFrame.frame, "TOPLEFT")
    end
    BiSTracker.Serializer.GUI.frame:SetParent(BiSTracker.MainFrame.frame)
    BiSTracker.Serializer.GUI:EnableResize(true)
    BiSTracker.Serializer.GUI:SetTitle("Import / Export")
    BiSTracker.Serializer.GUI:SetHeight(390)
    BiSTracker.Serializer.GUI:SetWidth(500)
    BiSTracker.Serializer.GUI.frame:SetMinResize(400, 390)
    BiSTracker.Serializer.GUI.frame:SetMaxResize(600, 390)
    BiSTracker.Serializer.GUI:Hide()

    BiSTracker.Serializer.GUI.Tabs = BiSTracker.AceGUI:Create("TabGroup")
    BiSTracker.Serializer.GUI.Tabs:SetTabs(tabs)
    BiSTracker.Serializer.GUI.Tabs:SetLayout("Flow");
    BiSTracker.Serializer.GUI.Tabs.width = "fill"
    BiSTracker.Serializer.GUI.Tabs.height = "fill"
    BiSTracker.Serializer.GUI.Tabs:SetCallback("OnGroupSelected", SelectTab)
    BiSTracker.Serializer.GUI.Tabs:SelectTab("Import")



    BiSTracker.Serializer.GUI:AddChild(BiSTracker.Serializer.GUI.Tabs)
end
