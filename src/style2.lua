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
