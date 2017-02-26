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

----------------------------------------------------------------
-- CREATE UI ------------------------------------------------
----------------------------------------------------------------

local function AutoShotBar_Create()
	Table["posX"] = Table["posX"] *GetScreenWidth() /1000
	Table["posY"] = Table["posY"] *GetScreenHeight() /1000
	Table["Width"] = Table["Width"] *GetScreenWidth() /1000
	Table["Height"] = Table["Height"] *GetScreenHeight() /1000

	_G[ADDON_NAME.."_Frame_Timer"] = CreateFrame("Frame",nil,UIParent)
	local AutoShotFrame = _G[ADDON_NAME.."_Frame_Timer"]
	AutoShotFrame:SetFrameStrata("HIGH")
	AutoShotFrame:SetWidth(Table["Width"])
	AutoShotFrame:SetHeight(Table["Height"])
	AutoShotFrame:SetPoint("CENTER",UIParent,"CENTER",Table["posX"],Table["posY"])
	-- _G[ADDON_NAME.."_Frame_Timer"]:SetPoint("CENTER",UIParent,"CENTER",Table["posX"],Table["posY"])
	AutoShotFrame:SetAlpha(0)

	_G[ADDON_NAME.."_Time_Text"] = AutoShotFrame:CreateFontString(nil,"OVERLAY")
	_G[ADDON_NAME.."_Time_Text"]:SetFont("Interface\\AddOns\\"..ADDON_NAME.."\\Textures\\DorisPP.ttf", 14, "OUTLINE")

	local Time = _G[ADDON_NAME.."_Time_Text"]
	Time:SetPoint("CENTER", AutoShotFrame, "CENTER")

	_G[ADDON_NAME.."_Texture_Timer"] = AutoShotFrame:CreateTexture(nil,"OVERLAY")
	local Bar = _G[ADDON_NAME.."_Texture_Timer"]
	Bar:SetHeight(Table["Height"])
	Bar:SetTexture(TEXTURES.Bar)
	Bar:SetPoint("CENTER",AutoShotFrame,"CENTER")

	local Background = AutoShotFrame:CreateTexture(nil,"ARTWORK")
	Background:SetTexture(15/100, 15/100, 15/100, 1)
	Background:SetAllPoints(AutoShotFrame)

	_G[ADDON_NAME.."_Timer_Border"] = AutoShotFrame:CreateTexture(nil,"BORDER")
	_G[ADDON_NAME.."_Timer_Border"]:SetPoint("CENTER",AutoShotFrame,"CENTER")
	_G[ADDON_NAME.."_Timer_Border"]:SetWidth(Table["Width"] +3)
	_G[ADDON_NAME.."_Timer_Border"]:SetHeight(Table["Height"] +3)
	_G[ADDON_NAME.."_Timer_Border"]:SetTexture(0,0,0)

	_G[ADDON_NAME.."_Timer_Border2"] = AutoShotFrame:CreateTexture(nil,"BACKGROUND")
	_G[ADDON_NAME.."_Timer_Border2"]:SetPoint("CENTER",AutoShotFrame,"CENTER")
	_G[ADDON_NAME.."_Timer_Border2"]:SetWidth(Table["Width"] +6)
	_G[ADDON_NAME.."_Timer_Border2"]:SetHeight(Table["Height"] +6)
	_G[ADDON_NAME.."_Timer_Border2"]:SetTexture(1,1,1)
end

-- if( barframe.spell == SHT_AUTO_SHOT ) then
--   if(( not shtautoshot ) or ( shtcasting )) and ( not barframe.movetime ) and ( (barframe.endTime - time) <= 0.7 ) then
--     barframe.movetime = time;
--   elseif( barframe.movetime ) and (( shtautoshot ) and ( not shtcasting )) then
--     local deltaTime = time - barframe.movetime;
--     barframe.startTime = barframe.startTime + deltaTime;
--     barframe.endTime = barframe.endTime + deltaTime;
--     getglobal("SHunterTimersStatus"..id.."Bar"):SetMinMaxValues(barframe.startTime, barframe.endTime);
--     barframe:SetAlpha(SHTvars["overallalpha"]);
--     barframe.movetime = nil;
--   elseif(( not shtautoshot ) or ( shtcasting )) and ( barframe.movetime ) then
--     if( time - barframe.movetime) > 7 then
--       barframe.channeling = false;
--       barframe.fadeOut = true;
--       barframe.movetime = nil;
--     elseif( time - barframe.movetime ) > 4 then
--       local alpha = barframe:GetAlpha() - SHTvars["step"];
--       if( alpha > (0.3*SHTvars["overallalpha"]) ) then
--         barframe:SetAlpha(alpha);
--       end
--     end
--     return;
--   end
-- end


----------------------------------------------------------------
-- CREATE UI ------------------------------------------------
----------------------------------------------------------------

local function AutoShotBar2_Create()
	Table2["posX"] = Table2["posX"] *GetScreenWidth() /1000
	Table2["posY"] = Table2["posY"] *GetScreenHeight() /1000
	Table2["Width"] = Table2["Width"] *GetScreenWidth() /1000
	Table2["Height"] = Table2["Height"] *GetScreenHeight() /1000

  -- local Table = {
  -- 	["posX"] = 0,
  -- 	["posY"] = -50,
  -- 	["Width"] = 480,
  -- 	["Height"] = 15
  -- }

	_G[ADDON_NAME.."_Frame_Timer2"] = CreateFrame("Frame",nil,UIParent)
	local AutoShotFrame2 = _G[ADDON_NAME.."_Frame_Timer2"]
	AutoShotFrame2:SetFrameStrata("HIGH")
	AutoShotFrame2:SetWidth(Table2["Width"])
	AutoShotFrame2:SetHeight(Table2["Height"])
	AutoShotFrame2:SetPoint("CENTER",UIParent,"CENTER",Table2["posX"],Table2["posY"])
	-- _G[ADDON_NAME.."_Frame_Timer2"]:SetPoint("CENTER",UIParent,"CENTER",Table2["posX"],Table2["posY"])
	AutoShotFrame2:SetAlpha(0)

	_G[ADDON_NAME.."_Time_Text2"] = AutoShotFrame2:CreateFontString(nil,"OVERLAY")
	_G[ADDON_NAME.."_Time_Text2"]:SetFont("Interface\\AddOns\\"..ADDON_NAME.."\\Textures\\DorisPP.ttf", 14, "OUTLINE")
	-- _G[ADDON_NAME.."_Time_Text2"]:SetFont("Fonts\\FRIZQT__.ttf", 14, "OUTLINE")
	-- _G[ADDON_NAME.."_Time_Text2"]:SetFont("Interface\\AddOns\\LunaUnitFrames\\media\\fonts\\Luna.ttf", 14)

	local Time2 = _G[ADDON_NAME.."_Time_Text2"]
	Time2:SetPoint("CENTER", AutoShotFrame2, "CENTER")

  _G[ADDON_NAME.."_Cast_Marker"] = AutoShotFrame2:CreateTexture(nil,"BORDER")
  _G[ADDON_NAME.."_Cast_Marker"]:SetPoint("LEFT",AutoShotFrame2,"LEFT")
  _G[ADDON_NAME.."_Cast_Marker"]:SetWidth(Table2["Width"] - (Table2["Width"] * (_CAST_TIME/swingTime2)))
  _G[ADDON_NAME.."_Cast_Marker"]:SetHeight(Table2["Height"] +6)
  _G[ADDON_NAME.."_Cast_Marker"]:SetTexture(0,0,0)

  _G[ADDON_NAME.."_Cast_Marker2"] = AutoShotFrame2:CreateTexture(nil,"BORDER")
  _G[ADDON_NAME.."_Cast_Marker2"]:SetPoint("RIGHT",AutoShotFrame2,"RIGHT")
  _G[ADDON_NAME.."_Cast_Marker2"]:SetWidth(Table2["Width"] * (_CAST_TIME/swingTime2))
  _G[ADDON_NAME.."_Cast_Marker2"]:SetHeight(Table2["Height"] +6)
  _G[ADDON_NAME.."_Cast_Marker2"]:SetTexture(0,0,1)

  _G[ADDON_NAME.."Lag_Marker"] = AutoShotFrame2:CreateTexture(nil,"OVERLAY")
  _G[ADDON_NAME.."Lag_Marker"]:SetPoint("RIGHT",AutoShotFrame2,"RIGHT")
  _G[ADDON_NAME.."Lag_Marker"]:SetHeight(Table2["Height"] +10)
  _G[ADDON_NAME.."Lag_Marker"]:SetTexture(1,0,0)
  local _,_,latency = GetNetStats()
  _G[ADDON_NAME.."Lag_Marker"]:SetWidth((Table2["Width"] * (_CAST_TIME/swingTime2)) *(latency / 3000))

  -- _G[ADDON_NAME.."MultiShot_Marker"] = AutoShotFrame2:CreateTexture(nil,"BORDER")
  -- _G[ADDON_NAME.."MultiShot_Marker"]:SetPoint("RIGHT",AutoShotFrame2,"RIGHT")
  -- _G[ADDON_NAME.."MultiShot_Marker"]:SetHeight(Table2["Height"] +10)
  -- _G[ADDON_NAME.."MultiShot_Marker"]:SetTexture(1,0.8,0)
  -- _G[ADDON_NAME.."MultiShot_Marker"]:SetWidth((Table2["Width"] * 0.16))


	_G[ADDON_NAME.."_Texture_Timer2"] = AutoShotFrame2:CreateTexture(nil,"OVERLAY")
	local Bar2 = _G[ADDON_NAME.."_Texture_Timer2"]
	Bar2:SetHeight(Table2["Height"])
	Bar2:SetTexture(TEXTURES.Bar)
	Bar2:SetPoint("LEFT",AutoShotFrame2,"LEFT")

	local Background2 = AutoShotFrame2:CreateTexture(nil,"ARTWORK")
	Background2:SetTexture(15/100, 15/100, 15/100, 1)
	Background2:SetAllPoints(AutoShotFrame2)

	-- _G[ADDON_NAME.."_Timer_Border2"] = AutoShotFrame2:CreateTexture(nil,"BORDER")
	-- _G[ADDON_NAME.."_Timer_Border2"]:SetPoint("CENTER",AutoShotFrame2,"CENTER")
	-- _G[ADDON_NAME.."_Timer_Border2"]:SetWidth(Table2["Width"] +3)
	-- _G[ADDON_NAME.."_Timer_Border2"]:SetHeight(Table2["Height"] +3)
	-- _G[ADDON_NAME.."_Timer_Border2"]:SetTexture(0,0,0)
  --
	-- _G[ADDON_NAME.."_Timer_Border2"] = AutoShotFrame2:CreateTexture(nil,"BACKGROUND")
	-- _G[ADDON_NAME.."_Timer_Border2"]:SetPoint("CENTER",AutoShotFrame2,"CENTER")
	-- _G[ADDON_NAME.."_Timer_Border2"]:SetWidth(Table2["Width"] +6)
	-- _G[ADDON_NAME.."_Timer_Border2"]:SetHeight(Table2["Height"] +6)
	-- _G[ADDON_NAME.."_Timer_Border2"]:SetTexture(1,1,1)
end

----------------------------------------------------------------
-- UTILITIES ---------------------------------------------------
----------------------------------------------------------------
-- Check for global CD, look at serpent sting (no cd spell) and see if its on CD
local function GlobalCD_Check()
	local _,_,offset,numSpells = GetSpellTabInfo(GetNumSpellTabs())
	local numAllSpell = offset + numSpells
	for i=1,numAllSpell do
		local name = GetSpellName(i,"BOOKTYPE_SPELL")
		if ( name == "Serpent Sting" ) then
			sST,sSCD = GetSpellCooldown(i,"BOOKTYPE_SPELL")
		end
	end
end

-- Log commands into chat box
local function kas_log(msg)
	if DEFAULT_CHAT_FRAME then
		DEFAULT_CHAT_FRAME:AddMessage(LIGHTYELLOW_FONT_COLOR_CODE .. msg)
	end
end

local function round(num, numDecimalPlaces)
  return tonumber(string.format("%." .. (numDecimalPlaces or 0) .. "f", num))
end

----------------------------------------------------------------
-- AIMED SHOT --------------------------------------------------
----------------------------------------------------------------

local AimedTooltip = CreateFrame("GameTooltip","AimedTooltip",UIParent,"GameTooltipTemplate")
AimedTooltip:SetOwner(UIParent,"ANCHOR_NONE")

local AimedID

-- Get Aimed shot ID from spells
local function AimedID_Get()
	local _,_,offset,numSpells = GetSpellTabInfo(GetNumSpellTabs())
	local numAllSpell = offset + numSpells
	for spellID=1,numAllSpell do
		local name = GetSpellName(spellID,"BOOKTYPE_SPELL")
		if ( name == "Aimed Shot" ) then
			AimedID = spellID
		end
	end
end

-- Start Aimed Shot
local function Aimed_Start()
	aimedStart = GetTime()
	if ( swingStart == false ) then
		_G[ADDON_NAME.."_Frame_Timer"]:SetAlpha(0)
	end
	castStart = false

	--[[
	AimedTooltip:ClearLines()
	AimedTooltip:SetInventoryItem("player", 18)
	local speed_base = string.gsub(AimedTooltipTextRight3:GetText(),"Speed ","")
	local speed_haste = UnitRangedDamage("player")
	local castTime_Aimed = 3 * speed_haste / speed_base -- rapid 1.4 / quick 1.3 / berserking / spider 1.2
	]]
	local _,_,latency = GetNetStats()
	local castTime_Aimed = 3 + (latency / 100)
	for i=1,32 do
		if UnitBuff("player",i) == "Interface\\Icons\\Ability_Warrior_InnerRage" then
			castTime_Aimed = castTime_Aimed/1.3
		end
		if UnitBuff("player",i) == "Interface\\Icons\\Ability_Hunter_RunningShot" then
			castTime_Aimed = castTime_Aimed/1.4
		end
		if UnitBuff("player",i) == "Interface\\Icons\\Racial_Troll_Berserk" then
			 -- castTime_Aimed = castTime_Aimed/1.1
			if berserkValue == nil then
				currentHealth = UnitHealth("player")
				maxHealth = UnitHealthMax("player")
				percentHealth = currentHealth / maxHealth
				if(percentHealth >= 0.40) then
					berserkValue = (1.30 - percentHealth)/3
				else
					berserkValue = 0.30
				end
				castTime_Aimed = castTime_Aimed/berserkValue
			else
				castTime_Aimed = castTime_Aimed/1.1
			end
		end
		if UnitBuff("player",i) == "Interface\\Icons\\Inv_Trinket_Naxxramas04" then
			castTime_Aimed = castTime_Aimed/1.2
		end
	end
	--[[local _,_,latency = GetNetStats()
	latency = latency/1000
	castTime_Aimed = castTime_Aimed - latency]]

	if ( AIMED_CAST_BAR == true ) then
		CastingBarFrameStatusBar:SetStatusBarColor(1.0, 0.7, 0.0)
		CastingBarSpark:Show()
		CastingBarFrame.startTime = GetTime()
		CastingBarFrame.maxValue = CastingBarFrame.startTime + castTime_Aimed
		CastingBarFrameStatusBar:SetMinMaxValues(CastingBarFrame.startTime, CastingBarFrame.maxValue)
		CastingBarFrameStatusBar:SetValue(CastingBarFrame.startTime)
		CastingBarText:SetText("Aimed Shot   "..string.format("%.1f",castTime_Aimed))
		-- CastingBarText:SetText(castTime_Aimed)
		CastingBarFrame:SetAlpha(1.0)
		CastingBarFrame.holdTime = 0
		CastingBarFrame.casting = 1
		CastingBarFrame.fadeOut = nil
		CastingBarFrame:Show()
		CastingBarFrame.mode = "casting"
	end
end

local UseAction_Real = UseAction
function UseAction( slot, checkFlags, checkSelf )
	AimedTooltip:ClearLines()
	AimedTooltip:SetAction(slot)
	local spellName = AimedTooltipTextLeft1:GetText()
	if ( spellName == "Aimed Shot" ) then
		Aimed_Start()
	end
	UseAction_Real( slot, checkFlags, checkSelf )
end

local CastSpell_Real = CastSpell
function CastSpell(spellID, spellTab)
	AimedID_Get()
	if ( spellID == AimedID and spellTab == "BOOKTYPE_SPELL" ) then
		Aimed_Start()
	end
	CastSpell_Real(spellID,spellTab)
end

local CastSpellByName_Real = CastSpellByName
function CastSpellByName(spellName)
	if ( spellName == "Aimed Shot" ) then
		Aimed_Start()
	end
	CastSpellByName_Real(spellName)
end

----------------------------------------------------------------
-- CASTING FUNCTIONS -------------------------------------------
----------------------------------------------------------------

-- Casting shot start
local function Cast_Start()
	swingTime2 = UnitRangedDamage("player")

	local _,_,latency = GetNetStats()
  _G[ADDON_NAME.."Lag_Marker"]:SetWidth((Table2["Width"] * (_CAST_TIME/swingTime2)) *(latency / 2000))

	_G[ADDON_NAME.."_Texture_Timer"]:SetHeight(Table["Height"])
	_G[ADDON_NAME.."_Time_Text"]:SetPoint("CENTER", _G[ADDON_NAME.."_Texture_Timer"], "CENTER")
	_G[ADDON_NAME.."_Texture_Timer"]:SetVertexColor(0,0,0.8)
	_G[ADDON_NAME.."_Texture_Timer2"]:SetVertexColor(1,1,1)
	posX, posY = GetPlayerMapPosition("player")
	castStart = GetTime()
end

-- Casting update
local function Cast_Update()
	_G[ADDON_NAME.."_Frame_Timer"]:SetAlpha(0.5)
	_G[ADDON_NAME.."_Frame_Timer2"]:SetAlpha(0)
	local relative = GetTime() - castStart
	local relative2 = GetTime() - castStart
	if ( relative > _CAST_TIME ) then
		castStart = false
	elseif ( swingStart == false ) then
		_G[ADDON_NAME.."_Texture_Timer"]:SetWidth(Table["Width"] * relative/_CAST_TIME)
		_G[ADDON_NAME.."_Texture_Timer2"]:SetWidth(Table2["Width"] - (Table2["Width"] * (_CAST_TIME/swingTime2)) + ((Table2["Width"]) * relative/swingTime2))
		--_G[ADDON_NAME.."_Texture_Timer2"]:SetWidth(Table2["Width"] * relative/_CAST_TIME)
		-- _G[ADDON_NAME.."_Texture_Timer2"]:SetWidth((Table2["Width"] - (relative2 / swingTime2)) + ((Table2["Width"] - (relative/_CAST_TIME)) * (relative2 / swingTime2)))
		-- _G[ADDON_NAME.."_Texture_Timer2"]:SetWidth((Table2["Width"] - (Table2["Width"] / _CAST_TIME)) + ((Table2["Width"] - (relative/_CAST_TIME)) * (relative2 / swingTime2)))
		_G[ADDON_NAME.."_Time_Text"]:SetText("Casting   "..string.format("%.1f",relative).." / ".._CAST_TIME) -- "Aimed Shot   "..string.format("%.1f",castTime_Aimed)
		_G[ADDON_NAME.."_Time_Text2"]:SetText("Shooting   "..string.format("%.1f",swingTime2 - _CAST_TIME + relative).." / "..string.format("%.1f",swingTime2))
	end
end

-- Casting interrupted
local function Cast_Interrupted()
	_G[ADDON_NAME.."_Frame_Timer"]:SetAlpha(0)
	_G[ADDON_NAME.."_Frame_Timer2"]:SetAlpha(0)
	swingStart = false
	Cast_Start()
end

-- Auto shot start
local function Shot_Start()
	Cast_Start()
	shooting = true
end

-- Auto shot end
local function Shot_End()
	if ( swingStart == false ) then
		_G[ADDON_NAME.."_Frame_Timer"]:SetAlpha(0)
		_G[ADDON_NAME.."_Frame_Timer2"]:SetAlpha(0)
	end
	castStart = false
	shooting = false
end

-- Swing start
local function Swing_Start()
	swingTime = UnitRangedDamage("player") - _CAST_TIME
	_G[ADDON_NAME.."_Texture_Timer"]:SetVertexColor(1,1,1)
	_G[ADDON_NAME.."_Texture_Timer2"]:SetVertexColor(1,1,1)
	castStart = false
	swingStart = GetTime()
end

----------------------------------------------------------------
-- SLASH COMMANDS ----------------------------------------------
----------------------------------------------------------------

SLASH_KAS1 = "/kas"

function SlashCmdList.KAS(parameter)
	local _, _, name = strfind(parameter, '^%s*(.-)%s*$')

	local width = strmatch(parameter, '(w%s)')
	local height = strmatch(parameter, '(h%s)')
	local posY = strmatch(parameter, '(y%s)')
	local x = strmatch(parameter, '(x%s)')

	local num = strmatch(parameter,  '(%d+)')

	kas_log("kas param: " .. name)
	kas_log("table width first:" .. Table["Width"])

	if (name == "lock") then
		kas_log("locked")
		_G[ADDON_NAME.."_Frame_Timer"]:SetAlpha(0)
	end
	if(name == "unlock") then
		kas_log("unlocked")
		_G[ADDON_NAME.."_Frame_Timer"]:SetAlpha(1)
	end
	if(name == "aimed on") then
		kas_log("aimed shot cast bar on")
	end
	if(name == "aimed off") then
		kas_log("aimed shot cast bar off")
	end
	if(width ~= nil) then
		kas_log("kas width: " .. width)
		if(num ~= nil) then
			kas_log("kas num: " .. num)
			kas_log("table width before:" .. Table["Width"])
			Table["Width"] = num *GetScreenWidth() /1000
			kas_log("table width after:" .. Table["Width"])
			_G[ADDON_NAME.."_Frame_Timer"]:SetWidth(Table["Width"])
			_G[ADDON_NAME.."_Timer_Border"]:SetWidth(Table["Width"] +3)
			_G[ADDON_NAME.."_Timer_Border2"]:SetWidth(Table["Width"] +6)
		end
	end
	if(height ~= nil) then
		kas_log("kas height: " .. height)
		if(num ~= nil) then
			kas_log("kas num: " .. num)
			kas_log("table height before:" .. Table["Height"])
			Table["Height"] = num *GetScreenHeight() /1000
			kas_log("table height after:" .. Table["Height"])
			_G[ADDON_NAME.."_Frame_Timer"]:SetHeight(Table["Height"])
			_G[ADDON_NAME.."_Timer_Border"]:SetHeight(Table["Height"] +3)
			_G[ADDON_NAME.."_Timer_Border2"]:SetHeight(Table["Height"] +6)
		end
	end
	if(posY ~= nil) then
		kas_log("kas posY: " .. posY)
		if(num ~= nil) then
			kas_log("kas num: " .. num)
			kas_log("table posY before:" .. Table["posY"])
			Table["posY"] = num *GetScreenHeight() /1000
			kas_log("table y after:" .. Table["posY"])
			_G[ADDON_NAME.."_Frame_Timer"]:SetPoint("CENTER",UIParent,"CENTER",Table["posX"],Table["posY"])
			_G[ADDON_NAME.."_Timer_Border"]:SetPoint("CENTER",_G[ADDON_NAME.."_Frame_Timer"],"CENTER")
			_G[ADDON_NAME.."_Timer_Border2"]:SetPoint("CENTER",_G[ADDON_NAME.."_Frame_Timer"],"CENTER")
		end
	end
end

MainFrame:SetScript("OnEvent", function()
	if ( event == "PLAYER_LOGIN" ) then
		AutoShotBar_Create()
		AutoShotBar2_Create()
		DEFAULT_CHAT_FRAME:AddMessage("|cff00ccff"..ADDON_NAME.."|cffffffff Loaded")
	end
	if ( event == "START_AUTOREPEAT_SPELL" ) then
		Shot_Start()
	end
	if ( event == "STOP_AUTOREPEAT_SPELL" ) then
		Shot_End()
	end
	if ( event == "SPELLCAST_STOP" ) then
		if ( aimedStart ~= false ) then
			aimedStart = false
		end
		GlobalCD_Check()
		if ( sSCD == 1.5 ) then
			sSTold = sST
		end
	end
	if ( event == "CURRENT_SPELL_CAST_CHANGED" ) then
		if ( swingStart == false and aimedStart == false ) then
			interruptTime = GetTime()
			Cast_Interrupted()
		end
	end
	if ( event == "ITEM_LOCK_CHANGED" ) then
		if ( shooting == true ) then
			GlobalCD_Check()
			if ( aimedStart ~= false ) then
				_G[ADDON_NAME.."_Frame_Timer"]:SetAlpha(1)
				_G[ADDON_NAME.."_Frame_Timer2"]:SetAlpha(1)
				Cast_Start()
			elseif ( sSCD ~= 1.5 ) then
				Swing_Start()
			elseif ( sSTold == sST ) then
				Swing_Start()
			else
				sSTold = sST
			end
		end
	end
	if ( event == "UNIT_AURA" ) then
		for i=1,16 do
			if ( UnitBuff("player",i) == "Interface\\Icons\\Racial_Troll_Berserk" ) then
				if berserkValue == nil then
					currentHealth = UnitHealth("player")
					maxHealth = UnitHealthMax("player")
					percentHealth = currentHealth / maxHealth
					if(percentHealth >= 0.40) then
						berserkValue = (1.30 - percentHealth)/3
					else
						berserkValue = 0.30
					end
				end
			else
				berserkValue = nil
			end
		end
	end
end)

MainFrame:SetScript("OnUpdate", function()
	if shooting == true then
		if ( castStart ~= false ) then
			local cposX, cposY = GetPlayerMapPosition("player") -- player position atm
			 -- if player is still, go ahead and update --
			if ( posX == cposX and posY == cposY ) then
				Cast_Update()
			else
			-- cast interrupted --
				Cast_Interrupted()
			end
		end
	end
	if swingStart ~= false then
		local relative = GetTime() - swingStart
		_G[ADDON_NAME.."_Texture_Timer"]:SetWidth(Table["Width"] - (Table["Width"]*relative/swingTime))
		_G[ADDON_NAME.."_Texture_Timer2"]:SetWidth(Table2["Width"]*relative/swingTime2)
		_G[ADDON_NAME.."_Time_Text"]:SetText("Reloading   "..string.format("%.1f",swingTime - relative).." / "..string.format("%.1f",swingTime))
		_G[ADDON_NAME.."_Time_Text2"]:SetText("Windup   "..string.format("%.1f",relative).." / "..string.format("%.1f",swingTime2))
		if relative > swingTime then
			if shooting == true and aimedStart == false then
				Cast_Start()
			else
				_G[ADDON_NAME.."_Texture_Timer"]:SetWidth(0)
				_G[ADDON_NAME.."_Frame_Timer"]:SetAlpha(0)
				_G[ADDON_NAME.."_Texture_Timer2"]:SetWidth(0)
				_G[ADDON_NAME.."_Frame_Timer2"]:SetAlpha(0)
			end
			swingStart = false
		end
	end
end)
