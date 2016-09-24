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

local EJ_DIFFICULTIES =
{
	{ size = "5", prefix = PLAYER_DIFFICULTY1, difficultyID = 1 },
	{ size = "5", prefix = PLAYER_DIFFICULTY2, difficultyID = 2 },
	{ size = "5", prefix = PLAYER_DIFFICULTY6, difficultyID = 23 },
	{ size = "5", prefix = PLAYER_DIFFICULTY_TIMEWALKER, difficultyID = 24 },
	{ size = "25", prefix = PLAYER_DIFFICULTY3, difficultyID = 7 },
	{ size = "10", prefix = PLAYER_DIFFICULTY1, difficultyID = 3 },
	{ size = "10", prefix = PLAYER_DIFFICULTY2, difficultyID = 5 },
	{ size = "25", prefix = PLAYER_DIFFICULTY1, difficultyID = 4 },
	{ size = "25", prefix = PLAYER_DIFFICULTY2, difficultyID = 6 },
	{ prefix = PLAYER_DIFFICULTY3, difficultyID = 17 },
	{ prefix = PLAYER_DIFFICULTY1, difficultyID = 14 },
	{ prefix = PLAYER_DIFFICULTY2, difficultyID = 15 },
	{ prefix = PLAYER_DIFFICULTY6, difficultyID = 16 },
}

------------------------------
-- Prototype
------------------------------

local proto = {
    encounters = {},
    id = nil,
    name = nil,
    type = 'Difficulty',
}
local meta = { __index = proto }

function proto:AddEncounter(encounter)
    tinsert(self.encounters, item)
end

function proto:AddEncounters()
    -- Select self difficulty.
    if not self:Select() then return end
    self.encounters = addon:GetEncounters(self)
end

function proto:GetName()
    return self.name
end

--- Select the current encounter.
function proto:Select()
    if not self:Validate() then return end
    EJ_SetDifficulty(self.id)
    return true
end

function proto:Validate()
    return (self.id and self.name)
end

------------------------------
-- Public methods
------------------------------
function addon:NewDifficulty(o)
    o = o or {}
    local obj = setmetatable(o, meta)
    obj:AddEncounters()
    return obj
end

function addon:GetDifficulties(instance)
    if not instance then return end
    local difficulties = {}
    EJ_SelectInstance(instance.id)
    for i=1,#EJ_DIFFICULTIES do
		local entry = EJ_DIFFICULTIES[i]
		if EJ_IsValidInstanceDifficulty(entry.difficultyID) then
            local name = entry.size and string.format(ENCOUNTER_JOURNAL_DIFF_TEXT, entry.size, entry.prefix) or entry.prefix
			local difficulty = addon:NewDifficulty({
                id = entry.difficultyID,
                instance = instance,
                name = name,
            })
            tinsert(difficulties, difficulty)
		end
	end
    return difficulties
end