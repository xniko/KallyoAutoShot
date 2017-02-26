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
