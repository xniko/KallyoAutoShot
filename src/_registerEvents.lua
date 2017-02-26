----------------------------------------------------------------
-- REGISTER EVENTS ---------------------------------------------
----------------------------------------------------------------
-- Start registering events and print the loading message.
-- function kas_OnLoad()
-- 	kas:RegisterEvent("PLAYER_ENTERING_WORLD")
-- 	kas:RegisterEvent("PLAYER_LOGIN")
-- 	kas:RegisterEvent("SPELLCAST_STOP")
-- 	kas:RegisterEvent("CURRENT_SPELL_CAST_CHANGED")
-- 	kas:RegisterEvent("START_AUTOREPEAT_SPELL")
-- 	kas:RegisterEvent("STOP_AUTOREPEAT_SPELL")
-- 	kas:RegisterEvent("ITEM_LOCK_CHANGED")
-- 	DEFAULT_CHAT_FRAME:AddMessage("kas loaded, type /kas for options.")
-- end

local Frame = CreateFrame("Frame")
Frame:RegisterAllEvents()
Frame:RegisterEvent("PLAYER_LOGIN")
Frame:RegisterEvent("SPELLCAST_STOP")
Frame:RegisterEvent("CURRENT_SPELL_CAST_CHANGED")
Frame:RegisterEvent("START_AUTOREPEAT_SPELL")
Frame:RegisterEvent("STOP_AUTOREPEAT_SPELL")
Frame:RegisterEvent("ITEM_LOCK_CHANGED")
