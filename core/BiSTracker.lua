--local BiSTracker = BiSTracker;

--[[if type(BiS_Settings) ~= "table" then
    BiS_Settings = {}
    BiS_Settings["CustomSpecs"] = customSpecs;
else

    if BiS_Settings["version"] == nil then
        for key, value in pairs(BiS_Settings["CustomSpecsData"]) do
            print(key);
        end
    end




    if BiS_Settings["CustomSpecs"] ~= nil then
        customSpecs = BiS_Settings["CustomSpecs"];
    else
        BiS_Settings["CustomSpecs"] = customSpecs;
    end
end]]

--BiSitemTest = BiSTracker.Item:New({}, 63900, 500, true, false, false, 20, "orgrimmar")


BiStest = {
    ["CustomSpecsData"] = {
        ["test"] = {
        }
    }
}





--[[if type(BiS_Settings) ~= "table" then
    BiS_Settings = {}
    BiS_Settings["CustomSpecsData"] = customSpecData;
    BiS_Settings["CustomSpecs"] = customSpecs;
else
    if BiS_Settings["CustomSpecsData"] ~= nil and BiS_Settings["CustomSpecs"] ~= nil then
        customSpecData = BiS_Settings["CustomSpecsData"];
        customSpecs = BiS_Settings["CustomSpecs"];
    else
        BiS_Settings["CustomSpecsData"] = customSpecData;
        BiS_Settings["CustomSpecs"] = customSpecs;
    end
end]]