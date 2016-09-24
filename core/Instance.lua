local addonName, addon = ...
local L = addon.L

--<GLOBALS
local _G = _G
local pairs = _G.pairs
local setmetatable = _G.setmetatable
local type = _G.type
local tinsert = _G.tinsert
local EJ_GetInstanceByIndex = _G.EJ_GetInstanceByIndex
local EJ_SelectInstance = _G.EJ_SelectInstance
local EJ_SelectTier = _G.EJ_SelectTier
--GLOBALS>

------------------------------
-- Prototype
------------------------------

local proto = {
    buttonImage = nil,
    description = nil,
    encounters = {},
    id = nil,
    link = nil,
    name = nil,
    raid = nil,
    type = 'Instance',
}
local meta = { __index = proto }

function proto:AddDifficulty(difficulty)
    tinsert(self.difficulties, difficulty)
end

function proto:AddDifficulties()
    -- Select self instance.
    if not self:Select() then return end
    self.difficulties = addon:GetDifficulties(self)
end

function proto:GetName()
    return self.name
end

function proto:Select()
    if not self:Validate() then return end
    EJ_SelectInstance(self.id)
    return true
end

function proto:Validate()
    return (self.id and self.name)
end

------------------------------
-- Public methods
------------------------------
function addon:NewInstance(o)
    o = o or {}
    local obj = setmetatable(o, meta)
    obj:AddEncounters()
    return obj
end

function addon:GetInstances(tier)
    if not tier then return end
    EJ_SelectTier(tier.index)
    local index = 1
    local showRaid = true
    local id, name, description, _, buttonImage, _, _, link = EJ_GetInstanceByIndex(index, showRaid)
    if id then
        local instances = {}
        -- Loop through all instances.
        while id do
            -- Try Instance class
            local instance = addon:NewInstance({
                buttonImage = buttonImage,
                description = description,
                id = id,
                link = link,
                name = name,
                raid = showRaid,
                tier = tier,
            })
            tinsert(instances, instance)
            -- Iterate index.
            index = index + 1
            id, name, description, _, buttonImage, _, _, link = EJ_GetInstanceByIndex(index, showRaid)
        end
        return instances
    end
end