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
