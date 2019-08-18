if WOW_PROJECT_ID == WOW_PROJECT_CLASSIC then
	return
end
local mod	= DBM:NewMod("z726", "DBM-PvP")
local L		= mod:GetLocalizedStrings()

mod:SetRevision("@file-date-integer@")
mod:SetZone(DBM_DISABLE_ZONE_DETECTION)

mod:RegisterEvents(
	"ZONE_CHANGED_NEW_AREA"
)

do
	local SetCVar, GetCVar = C_CVar and C_CVar.SetCVar or SetCVar, C_CVar and C_CVar.GetCVar or GetCVar
	local bgzone = false
	local cachedShowCastbar, cachedShowFrames, cachedShowPets = GetCVar("showArenaEnemyCastbar"), GetCVar("showArenaEnemyFrames"), GetCVar("showArenaEnemyPets")

	function mod:OnInitialize()
		if DBM:GetCurrentArea() == 726 then
			bgzone = true
			self:RegisterShortTermEvents(
				"CHAT_MSG_BG_SYSTEM_ALLIANCE",
				"CHAT_MSG_BG_SYSTEM_HORDE",
				"CHAT_MSG_BG_SYSTEM_NEUTRAL"
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
			self:Stop()
		end
	end

	function mod:ZONE_CHANGED_NEW_AREA()
		self:ScheduleMethod(1, "OnInitialize")
	end
end

do
	local flagTimer			= mod:NewTimer(12, "TimerFlag", "132483")
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
