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
