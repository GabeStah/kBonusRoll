local addonName, addon = ...

--<GLOBALS
local _G = _G
local GetLocale = _G.GetLocale
local pairs = _G.pairs
local rawset = _G.rawset
local setmetatable = _G.setmetatable
local tostring = _G.tostring
--GLOBALS>

local L = setmetatable({}, {
	__index = function(self, key)
		if key ~= nil then
			rawset(self, key, tostring(key))
		end
		return tostring(key)
	end,
})
addon.L = L

--------------------------------------------------------------------------------
-- Locales from localization system
--------------------------------------------------------------------------------

-- %Localization: kbonusroll
-- THE END OF THE FILE IS UPDATED BY https://github.com/Adirelle/wowaceTools/#updatelocalizationphp.
-- ANY CHANGE BELOW THESES LINES WILL BE LOST.
-- UPDATE THE TRANSLATIONS AT http://www.wowace.com/addons/kbonusroll/localization/
-- AND ASK THE AUTHOR TO UPDATE THIS FILE.

-- @noloc[[

------------------------ enUS ------------------------


-- core.lua
L["Click on a item to remove it from the list. You can drop an item on the empty slot to add it to the list."] = true
L["Debug"] = true
L["Description for Debug Threshold"] = true
L["Enabled"] = true
L["Filter as Whitelist"] = true
L["Filtered Items"] = true
L["If enabled, will output a message when an item is filtered."] = true
L["If enabled, will use the filtered item list as a whitelist, looting only the specified, filtered items."] = true
L["Items"] = true
L["List of items that are filtered (and thus ignored) when looting."] = true
L["Output Filter Messages"] = true
L["Threshold"] = true
L["Toggle Debug mode"] = true
L["Toggle if %s is enabled."] = true


------------------------ frFR ------------------------
-- no translation

------------------------ deDE ------------------------
-- no translation

------------------------ esMX ------------------------
-- no translation

------------------------ ruRU ------------------------
-- no translation

------------------------ esES ------------------------
-- no translation

------------------------ zhTW ------------------------
-- no translation

------------------------ zhCN ------------------------
-- no translation

------------------------ koKR ------------------------
-- no translation

------------------------ ptBR ------------------------
-- no translation

-- @noloc]]

-- Replace remaining true values by their key
for k,v in pairs(L) do if v == true then L[k] = k end end
