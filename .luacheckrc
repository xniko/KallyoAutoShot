files['src/*.lua'].global = false
files['src/*.lua'].unused = false
files['.luacheckrc'].global = false

globals = {
  -- Addon globals
  'SLASH_KAS1','SlashCmdList',
	-- WoW API
	'getfenv', 'GetScreenWidth','GetScreenHeight','CreateFrame','UIParent','DEFAULT_CHAT_FRAME','UIParent','GetSpellTabInfo',
  'GetNumSpellTabs','GetSpellName','GetTime','GetNetStats','UnitBuff','UnitHealth','CastingBarText','AimedTooltipTextLeft1','UnitHealthMax','currentHealth',
  'maxHealth','percentHealth','CastingBarFrameStatusBar', 'CastingBarSpark','CastingBarFrame','UseAction','CastSpell','CastSpellByName',
  'GetPlayerMapPosition','UnitRangedDamage','GetSpellCooldown','LIGHTYELLOW_FONT_COLOR_CODE',
	-- Lua API
	"bit", "ceil", "floor", "format", "ipairs", "math", "min", "pairs", "print", "select", "string", "table",
	"tinsert", "type", 'strfind','strmatch',
}
