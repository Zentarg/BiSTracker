BiSTracker.Serializer = {}
BiSTracker.Serializer.GUI = {}
BiSTracker.Serializer.GUI.Tabs = {}

local LibBase64 = nil;

local L

local tabs

function BiSTracker.Serializer:SerializeData(setData)
    return LibBase64.Encode(BiSTracker:Serialize(setData))
end


local function CheckIfSlotContainsData(slot)
    if (slot == nil or type(slot.id) ~= "number" or type(slot.name) ~= "string" or type(slot.source) ~= "table" or type(slot.source.ID) ~= "number" or type(slot.source.SourceName) ~= "string" or type(slot.source.SourceType) ~= "string" or type(slot.source.DropChance) ~= "string" or type(slot.source.Zone) ~= "string") then
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
                BiSTracker:PrintError(L["The data to be imported did not match a BiSTracker set."])
                return false
            end
        end
        return setData
    end
    BiSTracker:PrintError(L["The string supplied was an incorrect format."])
    return false
end




local function CreateLabel(text, centered, r, g, b, font)
    local o = BiSTracker.AceGUI:Create("Label")
    o:SetText(text)
    if (centered ~= nil and centered ~= false) then
        o:SetJustifyH("TOP")
    end 
    if (font ~= nil) then
        o:SetFontObject(font)
    end
    if (r ~= nil and g ~= nil and b ~= nil) then
        o:SetColor(r, g, b)
    end
    return o
end

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
    local importText = CreateMultiLineEditBox("", L["Import String"], 15, 0, true)
    importText.width = "fill"

    --          New Set Name
    local setNameEdit = CreateEditBox("", L["New Set Name (Leave empty to inherit name)"], false, false, 15, 265)
    
    --          Import Button
    local importBtn = CreateButton(L["Import Set"], false, 100)
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
            BiSTracker:PrintError(L["A set already exists with the name |cffffff00"]..set.Name)
            setNameEdit:SetText("")
            return
        end

        BiSTracker.Settings.CustomSets[set.Name] = set
        BiSTracker.ClassSetList["Custom"][set.Name] = set.Name

        BiSTracker:Print(L["Successfully imported the set |cffffff00"]..set.Name)
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

    --          Import from existing set
    
        --      Set and Class dropdown
    local selectedClass = BiSTracker.SelectedClass
    local selectedSetName = ""
    local classList = {}
    
    for key, value in pairs(BiSData) do
        classList[key] = key
    end

    local firstSetInClass, _ = next(BiSTracker.ClassSetList[BiSTracker.CurrentClass])
    selectedSetName = firstSetInClass
    local setDropdown = CreateDropdownMenu(L["Set"], firstSetInClass, BiSTracker.ClassSetList[BiSTracker.CurrentClass], 170)
    setDropdown:SetCallback("OnValueChanged", function(self)
        selectedSetName = self.list[self.value]
    end)

    local classDropdown = CreateDropdownMenu(L["Class"], classList[selectedClass], classList, 95)
    classDropdown:SetCallback("OnValueChanged", function(self)
        selectedClass = self.list[self.value]
        setDropdown:SetList(BiSTracker.ClassSetList[selectedClass])
        local set, _ = next(BiSTracker.ClassSetList[selectedClass])
        setDropdown:SetValue(set)
        selectedSetName = set;
    end)


        --      Import Button

    local importPremadeSetBtn = CreateButton(L["Import Premade Set"], false, 160)
    importPremadeSetBtn:SetCallback("OnClick", function()
        local set = {}
        set.Name = selectedSetName;
        set.Slots = {}
        if (setNameEdit:GetText() ~= "") then
            set.Name = setNameEdit:GetText()
        end

        for key, value in pairs(BiSData[selectedClass][selectedSetName]) do
            set.Slots[key] = BiSTracker.ItemDB:GetItemWithID(value) or BiSTracker.Item:New(0, "", 0, "", "Kill", "0", "")
        end

        BiSTracker.Settings.CustomSets[set.Name] = set
        BiSTracker.ClassSetList["Custom"][set.Name] = set.Name

        BiSTracker:Print(L["Successfully imported the set |cffffff00"]..selectedSetName..L["|cffffffff as |cffffff00"]..set.Name)
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
    container:AddChild(classDropdown)
    container:AddChild(setDropdown)
    container:AddChild(importPremadeSetBtn)
    
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
        label:SetText(L["No custom sets to export."])
        container:AddChild(label)
        return
    end
    
    --          Set Dropdown
    setDropdown = CreateDropdownMenu(L["Set"], 1, sets, 200)
    setDropdown:SetCallback("OnValueChanged", function()
        exportText:SetText("")
    end)

    
    --          Export Text
    exportText = CreateMultiLineEditBox("", L["Export String (This is the string you use to import a set)"], 15, 0, true)
    exportText.width = "fill"

    --          Export Button
    exportBtn = CreateButton(L["Export Set"], false, 100)
    exportBtn:SetCallback("OnClick", function()
        local selectedSet = setDropdown.list[setDropdown.value]
        local set = BiSTracker.Settings.CustomSets[selectedSet]
        if (set == nil) then
           BiSTracker:PrintError(L["The selected set to export could not be found."])
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
    L = BiSTracker.L[BiSTracker.Settings.Locale]
    tabs = {
        {
            text = L["Import"],
            value = "Import"
        },
        {
            text = L["Export"],
            value = "Export"
        },
    }

    BiSTracker.Serializer.GUI = BiSTracker.AceGUI:Create("Window")
    BiSTracker.Serializer.GUI:ClearAllPoints()
    if (BiSTracker.db.profile.mainframe.connectedToCharacterFrame) then
        BiSTracker.Serializer.GUI:SetPoint("TOPLEFT", BiSTracker.MainFrame.frame, "TOPRIGHT")
    else
        BiSTracker.Serializer.GUI:SetPoint("TOPRIGHT", BiSTracker.MainFrame.frame, "TOPLEFT")
    end
    BiSTracker.Serializer.GUI.frame:SetParent(BiSTracker.MainFrame.frame)
    BiSTracker.Serializer.GUI:EnableResize(true)
    BiSTracker.Serializer.GUI:SetTitle(L["Import / Export"])
    BiSTracker.Serializer.GUI:SetHeight(450)
    BiSTracker.Serializer.GUI:SetWidth(500)
    BiSTracker.Serializer.GUI.frame:SetMinResize(500, 450)
    BiSTracker.Serializer.GUI.frame:SetMaxResize(500, 450)
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
