-- Assign Main Chunk passed values.
-- addonName: name of addon folder.
-- addon: empty table.
local addonName, addon = ...
local L = addon.L
LibStub('AceAddon-3.0'):NewAddon(addon, addonName,
    "AceConsole-3.0",
    "AceEvent-3.0",
    "kLib-1.0",
    "kLibColor-1.0",
    "kLibComm-1.0",
    "kLibItem-1.0",
    "kLibOptions-1.0",
    "kLibTimer-1.0",
    "kLibUtility-1.0",
    "kLibView-1.0")

local AceConfigDialog = LibStub('AceConfigDialog-3.0')

local _G, _ = _G, _
local table, tinsert, tremove, wipe, sort, date, time, random = table, table.insert, table.remove, wipe, sort, date, time, random
local math, tostring, string, strjoin, strlower, strsplit, strsub, strtrim, strupper, floor, tonumber = math, tostring, string, string.join, string.lower, string.split, string.sub, string.trim, string.upper, math.floor, tonumber
local select, pairs, print, next, type, unpack = select, pairs, print, next, type, unpack
local loadstring, assert, error = loadstring, assert, error

local EJ_GetNumTiers = _G.EJ_GetNumTiers
local EJ_GetTierInfo = _G.EJ_GetTierInfo
local EJ_SelectTier = _G.EJ_SelectTier

addon.defaults = {
	profile = {
        debug = {
			enabled = false,
			threshold = 1,
		},
		enabled = true,
        filtered = {},
        outputFiltering = true,
        isWhitelist = false,
	},
	global = {},
}

--- Generate the options table.
local function GetOptions(uiType, uiName)
    local handlerProto = setmetatable({
        SetItem = function(self, opt, item, added)
            if added then
                addon:AddItemToFilter(item)
            else
                addon:RemoveItemFromFilter(item)
            end
            AceConfigDialog:SelectGroup(addonName, "filtered")
        end
	}, { __index = {} })
	local handlerMeta = { __index = handlerProto }

    local optionProto = {
        type = "group",
        name = GetAddOnMetadata(addonName, "Title"),
        args = {
            desc = {
                type = "description",
                order = 0,
                name = GetAddOnMetadata(addonName, "Notes"),
            },
            debug = {
                name = L['Debug'],
                type = 'group',
                order = 99,
                args = {
                    enabled = {
                        name = L['Enabled'],
                        desc = L['Toggle Debug mode'],
                        type = 'toggle',
                        set = function(info,value) addon.db.profile.debug.enabled = value end,
                        get = function(info) return addon.db.profile.debug.enabled end,
                    },
                    threshold = {
                        name = L['Threshold'],
                        desc = L['Description for Debug Threshold'],
                        type = 'select',
                        values = {
                            [1] = 'Low',
                            [2] = 'Normal',
                            [3] = 'High',
                        },
                        style = 'dropdown',
                        set = function(info,value) addon.db.profile.debug.threshold = value end,
                        get = function(info) return addon.db.profile.debug.threshold end,
                    },
                },
                cmdHidden = true,
            },
            enabled = {
                name = L["Enabled"],
                desc = (L["Toggle if %s is enabled."]):format(addonName),
                type = "toggle",
                order = 1,
                get = function()
                    return addon.db.profile.enabled
                end,
                set = function()
                    addon.db.profile.enabled = not addon.db.profile.enabled
                    if addon.db.profile.enabled then
                        addon:Enable()
                    else
                        addon:Disable()
                    end
                end,
            },
            filtered = {
                name = L["Filtered Items"],
                type = "group",
                order = 1,
                args = {
                    desc = {
                        type = "description",
                        order = 0,
                        name = L["List of items that are filtered (and thus ignored) when looting."],
                    },
                    isWhitelist = {
                        name = L["Filter as Whitelist"],
                        desc = L["If enabled, will use the filtered item list as a whitelist, looting only the specified, filtered items."],
                        type = "toggle",
                        order = 1,
                        get = function()
                            return addon.db.profile.isWhitelist
                        end,
                        set = function()
                            addon.db.profile.isWhitelist = not addon.db.profile.isWhitelist
                        end,
                        width = 'normal',
                    },
                    outputFiltering = {
                        name = L["Output Filter Messages"],
                        desc = L["If enabled, will output a message when an item is filtered."],
                        type = "toggle",
                        order = 5,
                        get = function()
                            return addon.db.profile.outputFiltering
                        end,
                        set = function()
                            addon.db.profile.isWhitelist = not addon.db.profile.outputFiltering
                        end,
                        width = 'normal',
                    },
                    items = {
                        name = L['Items'],
                        desc = L['Click on a item to remove it from the list. You can drop an item on the empty slot to add it to the list.'],
                        type = 'multiselect',
                        dialogControl = 'ItemList',
                        order = 40,
                        get = function() return true end,
                        set = 'SetItem',
                        values = function() return addon.db.profile.filtered end,
                        width = 'full',
                    },
                },
            },
        },
    }
    local optionMeta = { __index = optionProto }

    return setmetatable({handler = setmetatable({values = {}}, handlerMeta)}, optionMeta)
end

function addon:OnEnable()
    -- If option to enable is set, register events.
    if self.db.profile.enabled then
        -- Register events
        self:RegisterEvents()

        local _, _, classID = UnitClass("player")
        local specID = GetSpecializationInfo(GetSpecialization())
        self:Debug(classID, specID, 1)
        C_LootJournal.SetClassAndSpecFilters(classID, specID)

        -- Load journal
        LoadAddOn('Blizzard_EncounterJournal')

        self.tiers = self:GetTiers()
        self:SummarizeData()
    else
        self:Disable()
    end
end

function addon:OnDisable()
    addon:UnregisterEvents()
end

function addon:OnInitialize()
    -- Load Database
    self.db = LibStub("AceDB-3.0"):New(("%sDB"):format(addonName), self.defaults, true)

    -- Options
	LibStub("AceConfigRegistry-3.0"):RegisterOptionsTable(addonName, GetOptions)
	LibStub("AceConfigDialog-3.0"):AddToBlizOptions(addonName, GetAddOnMetadata(addonName, "Title"))

    -- Register slash commands.
    self:RegisterChatCommand("kbr", 'OpenOptions')
    self:RegisterChatCommand("kbonusroll", 'OpenOptions')
end

--- Open options dialog window.
function addon:OpenOptions()
    AceConfigDialog:Open(addonName)
end

function addon:RegisterEvents()
    --self:RegisterEvent('LOOT_READY', 'ProcessLoot')
end

function addon:UnregisterEvents()
    --self:UnregisterEvent('LOOT_READY')
end

function addon:SummarizeData()
    -- Loop tiers
    local tierCount = 0
    local instanceCount = 0
    local encounterCount = 0
    local itemCount = 0
    for i, tier in pairs(self.tiers) do
        tierCount = tierCount + 1
        for iInstance, instance in pairs(tier.instances) do
            instanceCount = instanceCount + 1
            for iEncounter, encounter in pairs(instance.encounters) do
                encounterCount = encounterCount + 1
                for iItem, item in pairs(encounter.items) do
                    itemCount = itemCount + 1
                end
            end
        end
    end
    self:Debug(("Summary - Tiers: %d, Instances: %d, Encounters: %d, Items: %d"):format(
        tierCount,
        instanceCount,
        encounterCount,
        itemCount
    ))
end
--
----- Get the list of content tiers.
--function addon:GetTiers()
--
--end
--
--function addon:GetInstances(tier)
--    -- Set initial tier to latest tier if not specified.
--    if not tier then tier = self.tiers[#self.tiers] end
--    -- Select specified tier prior to query.
--    EJ_SelectTier(tier.id)
--    local instances = {}
--    local index = 1
--    local showRaid = true
--    local instanceID, name, description, _, buttonImage, _, _, link = EJ_GetInstanceByIndex(index, showRaid)
--    if instanceID then
--        -- Loop through all instances.
--        while instanceID do
--            -- Try Instance class
--            local instance = self:NewInstance({
--                id = instanceID,
--                name = name,
--                description = description,
--                buttonImage = buttonImage,
--                link = link,
--                raid = showRaid,
--                tier = tier,
--            })
--            self:Debug('GetInstances', '.name', instance.name, 1)
--            self:Debug('GetInstances', ':GetName()', instance:GetName(), 1)
--            self:Debug('GetInstances', '.description', instance.description, 1)
--            tinsert(instances, {
--                id = instanceID,
--                name = name,
--                description = description,
--                buttonImage = buttonImage,
--                link = link,
--                raid = showRaid,
--                tier = tier,
--            })
--            -- Iterate index.
--            index = index + 1
--            instanceID, name, description, _, buttonImage, _, _, link = EJ_GetInstanceByIndex(index, showRaid)
--        end
--        -- Return instance data.
--        return instances
--    end
--end
--
--function addon:GetLoot()
--    local loot = {}
--    for iTier, tier in pairs(self.tiers) do
--        -- Select current tier.
--        EJ_SelectTier(tier.id)
--        for iInstance, instance in pairs(self.instances) do
--            -- Select instance.
--            EJ_SelectInstance(instance.id)
--            for iLoot=1, EJ_GetNumLoot() do
--                local itemID, encounterID, name, icon, slot, armorType, link = EJ_GetLootInfoByIndex(iLoot)
--                tinsert(loot, {
--                    id = itemID,
--                    encounterID = encounterID,
--                    name = name,
--                    icon = icon,
--                    slot = slot,
--                    armorType = armorType,
--                    link = link,
--                    tier = tier,
--                    instance = instance,
--                })
--            end
--        end
--    end
--    return loot
--end