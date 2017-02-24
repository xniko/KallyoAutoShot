--[[
	#1 Cast_Interrupt reset


	# Nostalrius Bug
		--> "ITEM_LOCK CHANGED" van a "SPELLCAST_STOP" helyett
		--> reportolva van már nostalrius bugtrackeren, ha fixelik cseréljem le "SPELLCAST_STOP"-ra
		--> https://report.nostalrius.org/plugins/tracker/?aid=310
]]


----------------------------------------------------------------
-- GLOBAL VARIABLES --------------------------------------------
----------------------------------------------------------------

local AddOn = "kallyo_AutoShot"
local _G = getfenv(0)

local Textures = {
	Bar = "Interface\\AddOns\\"..AddOn.."\\Textures\\Bar.tga",
}
local Table = {
	["posX"] = 0;
	["posY"] = -490;
	["Width"] = 1000;
	["Height"] = 10;
}
-- local Table = {
-- 	["posX"] = 0;
-- 	["posY"] = -50;
-- 	["Width"] = 480;
-- 	["Height"] = 15;
-- }

local _CAST_TIME = 0.65
local AimedCastBar = true; -- true / false
local castStart = false;
local swingStart = false;
local aimedStart = false;
local shooting = false; -- player adott pillantban lő-e
local posX, posY -- player position when starts Casting
local interruptTime -- Concussive shot miatt
local swingTime
local berserkValue = nil
local sST,sSCD = 0,0
local sSTold

----------------------------------------------------------------
-- CREATE UI ------------------------------------------------
----------------------------------------------------------------


local function AutoShotBar_Create()
	Table["posX"] = Table["posX"] *GetScreenWidth() /1000;
	Table["posY"] = Table["posY"] *GetScreenHeight() /1000;
	Table["Width"] = Table["Width"] *GetScreenWidth() /1000;
	Table["Height"] = Table["Height"] *GetScreenHeight() /1000;

	_G[AddOn.."_Frame_Timer"] = CreateFrame("Frame",nil,UIParent);
	local Frame = _G[AddOn.."_Frame_Timer"];
	Frame:SetFrameStrata("HIGH");
	Frame:SetWidth(Table["Width"]);
	Frame:SetHeight(Table["Height"]);
	Frame:SetPoint("CENTER",UIParent,"CENTER",Table["posX"],Table["posY"]);
	Frame:SetAlpha(0);

	_G[AddOn.."_Time_Text"] = Frame:CreateFontString(nil,"OVERLAY");
	local Time = _G[AddOn.."_Time_Text"];
	Time:SetPoint("CENTER", Frame, "CENTER");

	_G[AddOn.."_Texture_Timer"] = Frame:CreateTexture(nil,"OVERLAY");
	local Bar = _G[AddOn.."_Texture_Timer"];
	Bar:SetHeight(Table["Height"]);
	Bar:SetTexture(Textures.Bar);
	Bar:SetPoint("CENTER",Frame,"CENTER");

	local Background = Frame:CreateTexture(nil,"ARTWORK");
	Background:SetTexture(15/100, 15/100, 15/100, 1);
	Background:SetAllPoints(Frame);

	local Border = Frame:CreateTexture(nil,"BORDER");
	Border:SetPoint("CENTER",Frame,"CENTER");
	Border:SetWidth(Table["Width"] +3);
	Border:SetHeight(Table["Height"] +3);
	Border:SetTexture(0,0,0);

	local Border = Frame:CreateTexture(nil,"BACKGROUND");
	Border:SetPoint("CENTER",Frame,"CENTER");
	Border:SetWidth(Table["Width"] +6);
	Border:SetHeight(Table["Height"] +6);
	Border:SetTexture(1,1,1);
end

----------------------------------------------------------------
-- UTILITIES ---------------------------------------------------
----------------------------------------------------------------
-- Check for global CD, look at serpent sting (no cd spell) and see if its on CD
local function GlobalCD_Check()
	local _,_,offset,numSpells = GetSpellTabInfo(GetNumSpellTabs())
	local numAllSpell = offset + numSpells;
	for i=1,numAllSpell do
		local name = GetSpellName(i,"BOOKTYPE_SPELL");
		if ( name == "Serpent Sting" ) then
			sST,sSCD = GetSpellCooldown(i,"BOOKTYPE_SPELL")
		end
	end
end

----------------------------------------------------------------
-- CASTING FUNCTIONS -------------------------------------------
----------------------------------------------------------------

-- Casting shot start
local function Cast_Start()
	_G[AddOn.."_Texture_Timer"]:SetVertexColor(0,0,0.8);
	posX, posY = GetPlayerMapPosition("player");
	castStart = GetTime();
end

-- Casting update
local function Cast_Update()
	_G[AddOn.."_Frame_Timer"]:SetAlpha(0.5);
	local relative = GetTime() - castStart
	if ( relative > _CAST_TIME ) then
		castStart = false;
	elseif ( swingStart == false ) then
		_G[AddOn.."_Texture_Timer"]:SetWidth(Table["Width"] * relative/_CAST_TIME);
		_G[AddOn.."_Time_Text"]:SetText(relative);
	end
end

-- Casting interrupted
local function Cast_Interrupted()
	_G[AddOn.."_Frame_Timer"]:SetAlpha(0);
	swingStart = false;
	Cast_Start();
end

-- Auto shot start
local function Shot_Start()
	Cast_Start();
	shooting = true;
end

-- Auto shot end
local function Shot_End()
	if ( swingStart == false ) then
		_G[AddOn.."_Frame_Timer"]:SetAlpha(0);
	end
	castStart = false
	shooting = false
end

-- Swing start
local function Swing_Start()
	swingTime = UnitRangedDamage("player") - _CAST_TIME;
	_G[AddOn.."_Texture_Timer"]:SetVertexColor(1,1,1);

	castStart = false
	swingStart = GetTime();
end

----------------------------------------------------------------
-- AIMED SHOT --------------------------------------------------
----------------------------------------------------------------

local AimedTooltip = CreateFrame("GameTooltip","AimedTooltip",UIParent,"GameTooltipTemplate");
AimedTooltip:SetOwner(UIParent,"ANCHOR_NONE");

local AimedID
local function AimedID_Get()
	local _,_,offset,numSpells = GetSpellTabInfo(GetNumSpellTabs())
	local numAllSpell = offset + numSpells;
	for spellID=1,numAllSpell do
		local name = GetSpellName(spellID,"BOOKTYPE_SPELL");
		if ( name == "Aimed Shot" ) then
			AimedID = spellID
		end
	end
end

local function Aimed_Start()
	aimedStart = GetTime()
	if ( swingStart == false ) then
		_G[AddOn.."_Frame_Timer"]:SetAlpha(0);
	end
	castStart = false

	--[[
	AimedTooltip:ClearLines();
	AimedTooltip:SetInventoryItem("player", 18)
	local speed_base = string.gsub(AimedTooltipTextRight3:GetText(),"Speed ","")
	local speed_haste = UnitRangedDamage("player");
	local castTime_Aimed = 3 * speed_haste / speed_base -- rapid 1.4 / quick 1.3 / berserking / spider 1.2
	]]
	local _,_,latency = GetNetStats();
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
				currentHealth = UnitHealth("player");
				maxHealth = UnitHealthMax("player");
				percentHealth = currentHealth / maxHealth;
				if(percentHealth >= 0.40) then
					berserkValue = (1.30 - percentHealth)/3;
				else
					berserkValue = 0.30;
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
	--[[local _,_,latency = GetNetStats();
	latency = latency/1000;
	castTime_Aimed = castTime_Aimed - latency;]]

	if ( AimedCastBar == true ) then
		CastingBarFrameStatusBar:SetStatusBarColor(1.0, 0.7, 0.0);
		CastingBarSpark:Show();
		CastingBarFrame.startTime = GetTime();
		CastingBarFrame.maxValue = CastingBarFrame.startTime + castTime_Aimed;
		CastingBarFrameStatusBar:SetMinMaxValues(CastingBarFrame.startTime, CastingBarFrame.maxValue);
		CastingBarFrameStatusBar:SetValue(CastingBarFrame.startTime);
		CastingBarText:SetText("Aimed Shot   "..string.format("%.2f",castTime_Aimed));
		-- CastingBarText:SetText(castTime_Aimed);
		CastingBarFrame:SetAlpha(1.0);
		CastingBarFrame.holdTime = 0;
		CastingBarFrame.casting = 1;
		CastingBarFrame.fadeOut = nil;
		CastingBarFrame:Show();
		CastingBarFrame.mode = "casting";
	end
end

UseAction_Real = UseAction;
function UseAction( slot, checkFlags, checkSelf )
	AimedTooltip:ClearLines();
	AimedTooltip:SetAction(slot);
	local spellName = AimedTooltipTextLeft1:GetText();
	if ( spellName == "Aimed Shot" ) then
		Aimed_Start()
	end
	UseAction_Real( slot, checkFlags, checkSelf );
end

CastSpell_Real = CastSpell;
function CastSpell(spellID, spellTab)
	AimedID_Get();
	if ( spellID == AimedID and spellTab == "BOOKTYPE_SPELL" ) then
		Aimed_Start()
	end
	CastSpell_Real(spellID,spellTab);
end

CastSpellByName_Real = CastSpellByName;
function CastSpellByName(spellName)
	if ( spellName == "Aimed Shot" ) then
		Aimed_Start()
	end
	CastSpellByName_Real(spellName)
end

----------------------------------------------------------------
-- MENU ------------------------------------------------
----------------------------------------------------------------
-- Make the menu visible or invisible.
function kasMenu_Toggle()
	if kas:IsVisible() then
		kas:Hide()
	else
		kas:Show()
	end
end

-- Slash Command

SLASH_KAS1 = "/kas"

function SlashCmdList.KAS(parameter)
	local _, _, name = strfind(parameter, '^%s*(.-)%s*$')
	local width = strmatch(parameter, '(w%s)')
	local num = strmatch(parameter,  '(%d+)')

	kas_log("kas param: " .. name)
	kas_log("table width first:" .. Table["Width"])

	if (name == "lock") then
		kas_log("locked")
		_G[AddOn.."_Frame_Timer"]:SetAlpha(0);
	end
	if(name == "unlock") then
		kas_log("unlocked")
		_G[AddOn.."_Frame_Timer"]:SetAlpha(1);
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
			Table["Width"] = num *GetScreenWidth() /1000;
			kas_log("table width after:" .. Table["Width"])
			_G[AddOn.."_Frame_Timer"]:SetWidth(num);
		end
	end
end


-- Change the config file when a click happens.
function kas_CheckButton_OnClick()
	local t = this:GetText();
	if this:GetChecked() then
		kasConfig[t] = true
	else
		kasConfig[t] = false
	end
end

-- Load the check button setting on show.
function kas_ButtonInitialize()
	local name = this:GetText()
	if kasConfig then
		if kasConfig[name] then
			this:SetChecked(true);
		end
	end
end

function kas_log(msg)
	if DEFAULT_CHAT_FRAME then
		DEFAULT_CHAT_FRAME:AddMessage(LIGHTYELLOW_FONT_COLOR_CODE .. msg)
	end
end

----------------------------------------------------------------
-- REGISTER EVENTS ---------------------------------------------
----------------------------------------------------------------
-- Start registering events and print the loading message.
function kas_OnLoad()
	kas:RegisterEvent("PLAYER_ENTERING_WORLD")
	kas:RegisterEvent("PLAYER_LOGIN")
	kas:RegisterEvent("SPELLCAST_STOP")
	kas:RegisterEvent("CURRENT_SPELL_CAST_CHANGED")
	kas:RegisterEvent("START_AUTOREPEAT_SPELL")
	kas:RegisterEvent("STOP_AUTOREPEAT_SPELL")
	kas:RegisterEvent("ITEM_LOCK_CHANGED")
	DEFAULT_CHAT_FRAME:AddMessage("kas loaded, type /kas for options.")
end

----------------------------------------------------------------
-- ON UPDATE FUNCTION ------------------------------------------
----------------------------------------------------------------
function kas_OnUpdate()
	if shooting == true then
		if ( castStart ~= false ) then
			local cposX, cposY = GetPlayerMapPosition("player") -- player position atm
			 -- if player is still, go ahead and update --
			if ( posX == cposX and posY == cposY ) then
				Cast_Update();
			else
			-- cast interrupted --
				Cast_Interrupted();
			end
		end
	end
	if swingStart ~= false then
		local relative = GetTime() - swingStart
		_G[AddOn.."_Texture_Timer"]:SetWidth(Table["Width"] - (Table["Width"]*relative/swingTime));
		if relative > swingTime then
			if shooting == true and aimedStart == false then
				Cast_Start();
			else
				_G[AddOn.."_Texture_Timer"]:SetWidth(0);
				_G[AddOn.."_Frame_Timer"]:SetAlpha(0);
			end
			swingStart = false
		end
	end
end

----------------------------------------------------------------
-- ON EVENT ----------------------------------------------------
----------------------------------------------------------------
-- local Frame = CreateFrame("Frame");
-- Frame:RegisterAllEvents()
-- Frame:RegisterEvent("PLAYER_LOGIN")
-- Frame:RegisterEvent("SPELLCAST_STOP")
-- Frame:RegisterEvent("CURRENT_SPELL_CAST_CHANGED")
-- Frame:RegisterEvent("START_AUTOREPEAT_SPELL")
-- Frame:RegisterEvent("STOP_AUTOREPEAT_SPELL")
-- Frame:RegisterEvent("ITEM_LOCK_CHANGED")
-- Frame:SetScript("OnEvent",function()
-- 	-- function kas_OnEvent(event)
-- 	-- When player enters the world, init
-- 	if (event == "PLAYER_LOGIN") then
-- 		this:UnregisterEvent("PLAYER_ENTERING_WORLD")
-- 		AutoShotBar_Create();
-- 		DEFAULT_CHAT_FRAME:AddMessage("|cff00ccff"..AddOn.."|cffffffff Loaded");
-- 		if not kasConfig then
-- 			kasConfig = {
-- 				["posX"] = 0,
-- 				["posY"] = -200,
-- 				["Width"] = 480,
-- 				["Height"] = 15
-- 			}
-- 		end
-- 	-- Auto repeating spell event? started auto shot
-- 	elseif (event == "START_AUTOREPEAT_SPELL") then
-- 		Shot_Start();
-- 	-- Auto repeating spell stop? stopped auto shot
-- 	elseif (event == "STOP_AUTOREPEAT_SPELL") then
-- 		Shot_End();
-- 	-- Spell cast stopped? aimed shot stopped`
-- 	elseif (event == "SPELLCAST_STOP") then
-- 		if aimedStart ~= false then
-- 			aimedStart = false
-- 		end
-- 		GlobalCD_Check()
-- 		if sSCD == 1.5 then
-- 			sSTold = sST
-- 		end
-- 	elseif (event == "CURRENT_SPELL_CAST_CHANGED") then
-- 		Shot_Start();
-- 	elseif (event == "ITEM_LOCK_CHANGED") then
-- 		if shooting then
-- 			GlobalCD_Check();
-- 			if aimedStart ~= false then
-- 			_G[AddOn.."_Frame_Timer"]:SetAlpha(1)
-- 			Cast_Start();
-- 		elseif sSCD ~= 1.5 then
-- 			Swing_Start();
-- 		elseif sSTold == sST then
-- 			Swing_Start();
-- 		else
-- 			sSTold = sST
-- 		end
-- 	elseif (event == "UNIT_AURA") then
-- 		for i = 1, 16 do
-- 			if UnitBuff("player", i) == "Interface\\Icons\\Racial_Troll_Berserk" then
-- 				if berserkValue == nil then
-- 					currentHealth = UnitHealth("player");
-- 					maxHealth = UnitHealthMax("player");
-- 					percentHealth = currentHealth / maxHealth;
-- 					if(percentHealth >= 0.40) then
-- 						berserkValue = (1.30 - percentHealth)/3;
-- 					else
-- 						berserkValue = 0.30;
-- 					end
-- 				end
-- 			else
-- 				berserkValue = nil
-- 			end
-- 		end
-- 	end
-- end)
local Frame = CreateFrame("Frame");
Frame:RegisterAllEvents()
Frame:RegisterEvent("PLAYER_LOGIN")
Frame:RegisterEvent("SPELLCAST_STOP")
Frame:RegisterEvent("CURRENT_SPELL_CAST_CHANGED")
Frame:RegisterEvent("START_AUTOREPEAT_SPELL")
Frame:RegisterEvent("STOP_AUTOREPEAT_SPELL")
Frame:RegisterEvent("ITEM_LOCK_CHANGED")
Frame:SetScript("OnEvent",function()
	if ( event == "PLAYER_LOGIN" ) then
		AutoShotBar_Create();
		DEFAULT_CHAT_FRAME:AddMessage("|cff00ccff"..AddOn.."|cffffffff Loaded");
	end
	if ( event == "START_AUTOREPEAT_SPELL" ) then
		Shot_Start();
	end
	if ( event == "STOP_AUTOREPEAT_SPELL" ) then
		Shot_End();
	end
	if ( event == "SPELLCAST_STOP" ) then
		if ( aimedStart ~= false ) then
			aimedStart = false
		end
		GlobalCD_Check();
		if ( sSCD == 1.5 ) then
			sSTold = sST
		end
	end
	if ( event == "CURRENT_SPELL_CAST_CHANGED" ) then
		if ( swingStart == false and aimedStart == false ) then
			interruptTime = GetTime()
			Cast_Interrupted();
		end
	end
	if ( event == "ITEM_LOCK_CHANGED" ) then
		if ( shooting == true ) then
			GlobalCD_Check();
			if ( aimedStart ~= false ) then
				_G[AddOn.."_Frame_Timer"]:SetAlpha(1);
				Cast_Start();
			elseif ( sSCD ~= 1.5 ) then
				Swing_Start();
			elseif ( sSTold == sST ) then
				Swing_Start();
			else
				sSTold = sST;
			end
		end
	end
	if ( event == "UNIT_AURA" ) then
		for i=1,16 do
			if ( UnitBuff("player",i) == "Interface\\Icons\\Racial_Troll_Berserk" ) then
				if berserkValue == nil then
					currentHealth = UnitHealth("player");
					maxHealth = UnitHealthMax("player");
					percentHealth = currentHealth / maxHealth;
					if(percentHealth >= 0.40) then
						berserkValue = (1.30 - percentHealth)/3;
					else
						berserkValue = 0.30;
					end
				end
			else
				berserkValue = nil
			end
		end
	end
end)
Frame:SetScript("OnUpdate",function()
	if shooting == true then
		if ( castStart ~= false ) then
			local cposX, cposY = GetPlayerMapPosition("player") -- player position atm
			 -- if player is still, go ahead and update --
			if ( posX == cposX and posY == cposY ) then
				Cast_Update();
			else
			-- cast interrupted --
				Cast_Interrupted();
			end
		end
	end
	if swingStart ~= false then
		local relative = GetTime() - swingStart
		_G[AddOn.."_Texture_Timer"]:SetWidth(Table["Width"] - (Table["Width"]*relative/swingTime));
		if relative > swingTime then
			if shooting == true and aimedStart == false then
				Cast_Start();
			else
				_G[AddOn.."_Texture_Timer"]:SetWidth(0);
				_G[AddOn.."_Frame_Timer"]:SetAlpha(0);
			end
			swingStart = false;
		end
	end
end)
