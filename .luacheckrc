---@diagnostic disable: lowercase-global
std = "lua51"
max_line_length = false
exclude_files = {
	".luacheckrc"
}
ignore = {
	"212", -- Unused argument
	"542", -- An empty if branch
}
globals = {
	-- DeadlyBossMods
	"DBM",
	"DBM_DISABLE_ZONE_DETECTION",

	-- WoW
	"AlwaysUpFrame1",
	"AlwaysUpFrame2",
	"FACTION_HORDE",
	"FACTION_ALLIANCE",
	"TimerTracker",
	"WOW_PROJECT_ID",
	"WOW_PROJECT_WRATH_CLASSIC",
	"WOW_PROJECT_BURNING_CRUSADE_CLASSIC",
	"WOW_PROJECT_CLASSIC",
	"WOW_PROJECT_MAINLINE",
	"NORMAL_FONT_COLOR",
	"BLUE_FONT_COLOR",
	"RED_FONT_COLOR",
	"GRAY_FONT_COLOR",

	-- Lua functions
	"strsplit",
	"time",
	"table.wipe",
	"tContains",
	"tinsert",
	"tremove",
	"date",

	-- API functions
	"C_AreaPoiInfo",
	"C_ChatInfo",
	"C_CurrencyInfo",
	"C_DateAndTime",
	"C_DeathInfo",
	"C_GossipInfo",
	"C_Map",
	"C_PvP",
	"C_Seasons",
	"C_Timer",
	"C_UIWidgetManager",
	"C_VignetteInfo",
	"CompleteQuest",
	"CreateFrame",
	"Enum",
	"GetBattlefieldInstanceRunTime",
	"GetCurrencyInfo",
	"GetItemCount",
	"GetLocale",
	"GetNumBattlefieldVehicles",
	"GetNumGossipActiveQuests",
	"GetPlayerFactionGroup",
	"GetQuestReward",
	"GetRealmName",
	"GetServerTime",
	"GetTime",
	"GetGameTime",
	"IsInInstance",
	"IsQuestCompletable",
	"RepopMe",
	"SelectGossipActiveQuest",
	"SelectGossipAvailableQuest",
	"UnitFactionGroup",
	"UnitGUID",
	"UnitHealth",
	"UnitHealthMax",
	"UnitName",
}
