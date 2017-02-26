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
