local addonName, addon = ...
local L = addon.L

--<GLOBALS
local _G = _G
local pairs = _G.pairs
local setmetatable = _G.setmetatable
local type = _G.type
local EJ_GetNumTiers = _G.EJ_GetNumTiers
local EJ_GetTierInfo = _G.EJ_GetTierInfo
local EJ_SelectTier = _G.EJ_SelectTier
--GLOBALS>

------------------------------
-- Prototype
------------------------------

local proto = {
    index = nil,
    instances = {},
    name = nil,
    type = 'Tier',
}
local meta = { __index = proto }

function proto:AddInstance(instance)
    tinsert(self.instances, instance)
end

function proto:AddInstances()
    if not self:Select() then return end
    self.instances = addon:GetInstances(self)
end

function proto:GetName()
    return self.name
end

function proto:Select()
    if not self:Validate() then return end
    EJ_SelectTier(self.index)
    return true
end

--- Ensure data is valid.
function proto:Validate()
    return (self.index and self.name)
end

------------------------------
-- Public methods
------------------------------
function addon:NewTier(o)
    o = o or {}
    local obj = setmetatable(o, meta)
    obj:AddInstances()
    return obj
end

function addon:GetTiers()
    local numTiers = EJ_GetNumTiers()
    local tiers = {}
    for i=1, numTiers do
        local tierName = EJ_GetTierInfo(i)
        local tier = addon:NewTier{
            index = i,
            name = tierName,
        }
        tinsert(tiers, tier)
    end
    return tiers
end