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
	"WOW_PROJECT_BURNING_CRUSADE_CLASSIC",
	"WOW_PROJECT_CLASSIC",
	"WOW_PROJECT_MAINLINE",

	-- Lua functions
	"strsplit",
	"time",
	"table.wipe",

	-- API functions
	"C_AreaPoiInfo",
	"C_ChatInfo",
	"C_CurrencyInfo",
	"C_DeathInfo",
	"C_GossipInfo",
	"C_Map",
	"C_PvP",
	"C_Timer",
	"C_UIWidgetManager",
	"C_VignetteInfo",
	"CompleteQuest",
	"CreateFrame",
	"GetBattlefieldInstanceRunTime",
	"GetCurrencyInfo",
	"GetItemCount",
	"GetLocale",
	"GetNumBattlefieldVehicles",
	"GetNumGossipActiveQuests",
	"GetPlayerFactionGroup",
	"GetQuestReward",
	"GetServerTime",
	"GetTime",
	"IsInInstance",
	"IsQuestCompletable",
	"RepopMe",
	"SelectGossipActiveQuest",
	"SelectGossipAvailableQuest",
	"UnitFactionGroup",
	"UnitGUID",
	"UnitHealth",
	"UnitHealthMax"
}
