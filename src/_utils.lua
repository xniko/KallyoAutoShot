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
