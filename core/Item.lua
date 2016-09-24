local addonName, addon = ...
local L = addon.L

--<GLOBALS
local _G = _G
local pairs = _G.pairs
local setmetatable = _G.setmetatable
local tinsert = _G.tinsert
local type = _G.type
local EJ_GetLootInfoByIndex = _G.EJ_GetLootInfoByIndex
--GLOBALS>

------------------------------
-- Prototype
------------------------------

local proto = {
    armorType = nil,
    encounterID = nil,
    icon = nil,
    id = nil,
    link = nil,
    name = nil,
    slot = nil,
    type = 'Item',
}
local meta = { __index = proto }

function proto:GetName()
    return self.name
end

------------------------------
-- Public methods
------------------------------
function addon:NewItem(o)
    --local itemID, encounterID, name, icon, slot, armorType, link = EJ_GetLootInfoByIndex(iLoot)
    o = o or {}
    local obj = setmetatable(o, meta)
    return obj
end

function addon:GetItems(encounter)
    if not encounter then return end
    local items = {}
    -- Loop through all items
    for index=1,encounter.numItems do
        -- Open journal to appropriate slot.
        --EncounterJournal_OpenJournal(15, encounter.instance.id, encounter.id, nil, nil, true)
        local id, encounterID, name, icon, slot, armorType, link = EJ_GetLootInfoByIndex(index)
        if id and name then
            local item = addon:NewItem({
                armorType = armorType,
                encounter = encounter,
                encounterID = encounterID,
                icon = icon,
                id = id,
                link = link,
                name = name,
                slot = slot,
            })
            tinsert(items, item)
        end
    end
    return items
end