﻿local mod
if WOW_PROJECT_ID == WOW_PROJECT_CLASSIC then
	mod	= DBM:NewMod("z489", "DBM-PvP", 2)
else
	mod	= DBM:NewMod("z2106", "DBM-PvP", 2)
ebd
local L		= mod:GetLocalizedStrings()

mod:SetRevision("@file-date-integer@")
mod:SetZone(DBM_DISABLE_ZONE_DETECTION)

mod:RegisterEvents(
	"ZONE_CHANGED_NEW_AREA"
)

do
	local SetCVar = C_CVar and C_CVar.SetCVar or SetCVar
	local bgzone = false
	local cachedShowCastbar, cachedShowFrames, cachedShowPets = C_CVar.GetCVarBool("showArenaEnemyCastbar"), C_CVar.GetCVarBool("showArenaEnemyFrames"), C_CVar.GetCVarBool("showArenaEnemyPets")

	function mod:OnInitialize()
		if DBM:GetCurrentArea() == 489 or DBM:GetCurrentArea() == 2106 then--Classic, Retail
			bgzone = true
			self:RegisterShortTermEvents(
				"CHAT_MSG_BG_SYSTEM_ALLIANCE",
				"CHAT_MSG_BG_SYSTEM_HORDE",
				"CHAT_MSG_BG_SYSTEM_NEUTRAL",
				"START_TIMER"
			)
			-- Fix for flag carriers not showing up
			SetCVar("showArenaEnemyCastbar", "1")
			SetCVar("showArenaEnemyFrames", "1")
			SetCVar("showArenaEnemyPets", "1")
		elseif bgzone then
			bgzone = false
			self:UnregisterShortTermEvents()
			SetCVar("showArenaEnemyCastbar", cachedShowCastbar)
			SetCVar("showArenaEnemyFrames", cachedShowFrames)
			SetCVar("showArenaEnemyPets", cachedShowPets)
		end
	end

	function mod:ZONE_CHANGED_NEW_AREA()
		self:ScheduleMethod(1, "OnInitialize")
	end
end

do
	local flagTimer			= mod:NewTimer(12, "TimerFlag", "132349")
	local vulnerableTimer	= mod:NewNextTimer(60, 46392)

	local function updateflagcarrier(_, _, arg1)
		if arg1:match(L.ExprFlagCaptured) then
			flagTimer:Start()
			vulnerableTimer:Cancel()
		end
	end

	function mod:CHAT_MSG_BG_SYSTEM_ALLIANCE(...)
		updateflagcarrier(self, "CHAT_MSG_BG_SYSTEM_ALLIANCE", ...)
	end

	function mod:CHAT_MSG_BG_SYSTEM_HORDE(...)
		updateflagcarrier(self, "CHAT_MSG_BG_SYSTEM_HORDE", ...)
	end

	function mod:CHAT_MSG_BG_SYSTEM_NEUTRAL(msg)
		if msg == L.Vulnerable1 or msg == L.Vulnerable2 or msg:find(L.Vulnerable1) or msg:find(L.Vulnerable2) then
			vulnerableTimer:Start()
		end
	end
end

do
	local tonumber = tonumber
	local C_UIWidgetManager = C_UIWidgetManager
	local remainingTimer = mod:NewTimer(0, "TimerRemaining", 2457)

	function mod:START_TIMER(_, timeSeconds)
		mod:Schedule(timeSeconds + 1, function()
			local info = C_UIWidgetManager.GetIconAndTextWidgetVisualizationInfo(630)
			if info and info.state == 1 then
				local minutes, seconds = info.text:match("(%d+):(%d+)")
				if minutes and seconds then
					remainingTimer:SetTimer(tonumber(seconds) + (tonumber(minutes) * 60) + 1)
					remainingTimer:Start()
				end
			end
		end, self)
	end
end
