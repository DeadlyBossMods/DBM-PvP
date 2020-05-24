std = "lua51"
max_line_length = false
exclude_files = {
	".luacheckrc"
}
ignore = {
	"211", -- Unused local variable
	"212", -- Unused argument
	"213", -- Unused loop variable
	"311", -- Value assigned to a local variable is unused
	"43.", -- Shadowing an upvalue, an upvalue argument, an upvalue loop variable.
	"542", -- An empty if branch
}
globals = {
	"_G",

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
	"GetCurrencyInfo",
	"GetItemCount",
	"GetLocale",
	"GetNumGossipActiveQuests",
	"GetNumGossipOptions",
	"GetPlayerFactionGroup",
	"GetQuestReward",
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
