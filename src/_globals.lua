----------------------------------------------------------------
-- GLOBAL VARIABLES --------------------------------------------
----------------------------------------------------------------

local ADDON_NAME = "KallyoAutoShot"
local _G = getfenv(0)

local TEXTURES = {
	Bar = "Interface\\AddOns\\"..ADDON_NAME.."\\Textures\\Bar.tga",
}

local Table = {
	["posX"] = 0,
	["posY"] = -490,
	["Width"] = 1000,
	["Height"] = 10
}

local Table2 = {
	["posX"] = 0,
	["posY"] = -150,
	["Width"] = 200,
	["Height"] = 20
}

local _CAST_TIME = 0.65
local AIMED_CAST_BAR = true -- true / false
local castStart = false
local swingStart = false
local aimedStart = false
local shooting = false -- player adott pillantban lő-e
local posX, posY -- player position when starts Casting
local interruptTime -- luacheck: ignore -- Concussive shot miatt
local swingTime
local berserkValue = nil
local sST,sSCD = 0,0
local sSTold

local swingTime2 = UnitRangedDamage("player")
----------------------------------------------------------------
-- REGISTER EVENTS ---------------------------------------------
----------------------------------------------------------------

local MainFrame = CreateFrame("Frame")

MainFrame:RegisterAllEvents()
MainFrame:RegisterEvent("PLAYER_LOGIN")
MainFrame:RegisterEvent("SPELLCAST_STOP")
MainFrame:RegisterEvent("CURRENT_SPELL_CAST_CHANGED")
MainFrame:RegisterEvent("START_AUTOREPEAT_SPELL")
MainFrame:RegisterEvent("STOP_AUTOREPEAT_SPELL")
MainFrame:RegisterEvent("ITEM_LOCK_CHANGED")
