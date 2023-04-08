-------------------------------------**     LibEquippable     **-------------------------------------
-- This library provides access to all equippable items in WOTLK, TBC & Classic, as well as        --
-- their methods of acquisition. All acquisition methods are taken from tbc.wowhead.com, so        --
-- some items might have lacking information.                                                      --
--                                                                                                 --
--                                                                                                 --
-- Source types:                                                                                   --
--  Kill                                                                                           --
--  Quest                                                                                          --
--  Recipe                                                                                         --
--  Container                                                                                      --
--  Purchase                                                                                       --
--  Unknown                                                                                        --
--                                                                                                 --
--                                                                                                 --
-------------------------------------**  All Rights Reserved  **-------------------------------------

local LE_MAJOR, LE_MINOR = "LibEquippable-1.0", 1
local LE, oldminor = LibStub:NewLibrary(LE_MAJOR, LE_MINOR)

if not LE then return end

local ItemDB = {}

local ItemNameDB = {}

function LE:RegisterDBItems(items)
    for k, v in pairs(items) do
        ItemDB[k] = v
    end
end

function LE:RegisterNameDBItems(items)
    for k, v in pairs(items) do
        ItemNameDB[k] = v
    end
end

function LE:GetItemWithName(name)
    return ItemDB[ItemNameDB[name]]
end

function LE:GetItemWithID(id)
    return ItemDB[id]
end