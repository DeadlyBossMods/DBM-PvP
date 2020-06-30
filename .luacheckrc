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
	"WOW_PROJECT_CLASSIC",

	-- API functions
	"C_AreaPoiInfo",
	"C_ChatInfo",
	"C_DeathInfo",
	"C_UIWidgetManager",
	"C_VignetteInfo",
	"CompleteQuest",
	"CreateFrame",
	"GetBattlefieldInstanceRunTime",
	"GetBattlefieldVehicleInfo",
	"GetCurrencyInfo",
	"GetItemCount",
	"GetLocale",
	"GetNumBattlefieldVehicles",
	"GetNumGossipActiveQuests",
	"GetNumGossipOptions",
	"GetPlayerFactionGroup",
	"GetQuestReward",
	"GetServerTime",
	"GetTime",
	"IsInInstance",
	"IsQuestCompletable",
	"RepopMe",
	"SelectGossipActiveQuest",
	"SelectGossipAvailableQuest",
	"SelectGossipOption",
	"UnitFactionGroup",
	"UnitGUID",
	"time"
}
