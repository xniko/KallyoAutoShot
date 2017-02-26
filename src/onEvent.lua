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
