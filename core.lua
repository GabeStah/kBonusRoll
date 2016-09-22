local ADDON_NAME = 'kBonusRoll'
local _G, _ = _G, _
local table, tinsert, tremove, wipe, sort, date, time, random = table, table.insert, table.remove, wipe, sort, date, time, random
local math, tostring, string, strjoin, strlower, strsplit, strsub, strtrim, strupper, floor, tonumber = math, tostring, string, string.join, string.lower, string.split, string.sub, string.trim, string.upper, math.floor, tonumber
local select, pairs, print, next, type, unpack = select, pairs, print, next, type, unpack
local loadstring, assert, error = loadstring, assert, error
local addon = LibStub("AceAddon-3.0"):NewAddon(ADDON_NAME,
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
            AceConfigDialog:SelectGroup(ADDON_NAME, "filtered")
        end
	}, { __index = {} })
	local handlerMeta = { __index = handlerProto }

    local optionProto = {
        type = "group",
        name = GetAddOnMetadata(ADDON_NAME, "Title"),
        args = {
            desc = {
                type = "description",
                order = 0,
                name = GetAddOnMetadata(ADDON_NAME, "Notes"),
            },
            debug = {
                name = 'Debug',
                type = 'group',
                order = 99,
                args = {
                    enabled = {
                        name = 'Enabled',
                        type = 'toggle',
                        desc = 'Toggle Debug mode',
                        set = function(info,value) addon.db.profile.debug.enabled = value end,
                        get = function(info) return addon.db.profile.debug.enabled end,
                    },
                    threshold = {
                        name = 'Threshold',
                        desc = 'Description for Debug Threshold',
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
                name = "Enabled",
                desc = ("Toggle if %s is enabled."):format(ADDON_NAME),
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
                name = "Filtered Items",
                type = "group",
                order = 1,
                args = {
                    desc = {
                        type = "description",
                        order = 0,
                        name = "List of items that are filtered (and thus ignored) when looting.",
                    },
                    isWhitelist = {
                        name = "Filter as Whitelist",
                        desc = "If enabled, will use the filtered item list as a whitelist, looting only the specified, filtered items.",
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
                        name = "Output Filter Messages",
                        desc = "If enabled, will output a message when an item is filtered.",
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
                        name = 'Items',
                        desc = 'Click on a item to remove it from the list. You can drop an item on the empty slot to add it to the list.',
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
    else
        self:Disable()
    end
end

function addon:OnDisable()
    addon:UnregisterEvents()
end

function addon:OnInitialize()
    -- Load Database
    self.db = LibStub("AceDB-3.0"):New(("%sDB"):format(ADDON_NAME), self.defaults, true)

    -- Options
	LibStub("AceConfigRegistry-3.0"):RegisterOptionsTable(ADDON_NAME, GetOptions)
	LibStub("AceConfigDialog-3.0"):AddToBlizOptions(ADDON_NAME, GetAddOnMetadata(ADDON_NAME, "Title"))

    -- Register slash commands.
    self:RegisterChatCommand("kbr", 'OpenOptions')
    self:RegisterChatCommand("kbonusroll", 'OpenOptions')
end

--- Open options dialog window.
function addon:OpenOptions()
    AceConfigDialog:Open(ADDON_NAME)
end

function addon:RegisterEvents()
    --self:RegisterEvent('LOOT_READY', 'ProcessLoot')
end

function addon:UnregisterEvents()
    --self:UnregisterEvent('LOOT_READY')
end