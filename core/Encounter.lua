local addonName, addon = ...
local L = addon.L

--<GLOBALS
local _G = _G
local pairs = _G.pairs
local setmetatable = _G.setmetatable
local tinsert = _G.tinsert
local type = _G.type
local EJ_GetEncounterInfoByIndex = _G.EJ_GetEncounterInfoByIndex
local EJ_GetNumLoot = _G.EJ_GetNumLoot
local EJ_SelectEncounter = _G.EJ_SelectEncounter
local EJ_SelectInstance = _G.EJ_SelectInstance
local EncounterJournal = _G.EncounterJournal
--GLOBALS>

------------------------------
-- Prototype
------------------------------

local proto = {
    description = nil,
    id = nil,
    instance = nil,
    items = {},
    link = nil,
    name = nil,
    rootSectionID = nil,
    type = 'Encounter',
}
local meta = { __index = proto }

function proto:AddItem(item)
    tinsert(self.items, item)
end

function proto:AddItems()
    -- Select self instance.
    if not self:Select() then return end
    self.items = addon:GetItems(self)
end

function proto:GetName()
    return self.name
end

--- Select the current encounter.
function proto:Select()
    if not self:Validate() then return end
    EJ_SelectEncounter(self.id)
    EncounterJournal_SetTab(2)
    self.numItems = EJ_GetNumLoot()
    -- Ensure items exist.
    if not self.numItems then return end
    return true
end

function proto:Validate()
    return (self.id and self.name)
end

------------------------------
-- Public methods
------------------------------
function addon:NewEncounter(o)
    o = o or {}
    local obj = setmetatable(o, meta)
    obj:AddItems()
    return obj
end

function addon:GetEncounters(difficulty)
    if not difficulty then return end
    local index = 1
    local name, description, id, rootSectionID, link = EJ_GetEncounterInfoByIndex(index)
    if id then
        local encounters = {}
        -- Loop through all instances.
        while id do
            -- New encounter.
            local encounter = addon:NewEncounter({
                description = description,
                difficulty = difficulty,
                id = id,
                link = link,
                name = name,
                rootSectionID = rootSectionID,
            })
            -- Add to instances.
            tinsert(encounters, encounter)
            -- Iterate index.
            index = index + 1
            name, description, id, rootSectionID, link = EJ_GetEncounterInfoByIndex(index)
        end
        return encounters
    end
end