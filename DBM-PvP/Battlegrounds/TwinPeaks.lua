local mod	= DBM:NewMod("z726", "DBM-PvP", 2)
local L		= mod:GetLocalizedStrings()

mod:SetRevision("@file-date-integer@")
mod:SetZone(DBM_DISABLE_ZONE_DETECTION)

mod:RegisterEvents(
	"ZONE_CHANGED_NEW_AREA"
)

do
	local C_CVar = C_CVar
	local bgzone = false
	local cachedShowCastbar, cachedShowFrames, cachedShowPets = GetCVarBool("showArenaEnemyCastbar"), GetCVarBool("showArenaEnemyFrames"), GetCVarBool("showArenaEnemyPets")

	local function TwinPeaks_Initialize(self)
		if DBM:GetCurrentArea() == 726 then
			bgzone = true
			self:RegisterShortTermEvents(
				"CHAT_MSG_BG_SYSTEM_ALLIANCE",
				"CHAT_MSG_BG_SYSTEM_HORDE",
				"CHAT_MSG_BG_SYSTEM_NEUTRAL"
			)
			-- Fix for flag carriers not showing up
			C_CVar.SetCVar("showArenaEnemyCastbar", "1")
			C_CVar.SetCVar("showArenaEnemyFrames", "1")
			C_CVar.SetCVar("showArenaEnemyPets", "1")
		elseif bgzone then
			bgzone = false
			self:UnregisterShortTermEvents()
			C_CVar.SetCVar("showArenaEnemyCastbar", cachedShowCastbar)
			C_CVar.SetCVar("showArenaEnemyFrames", cachedShowFrames)
			C_CVar.SetCVar("showArenaEnemyPets", cachedShowPets)
		end
	end
	mod.OnInitialize = TwinPeaks_Initialize

	function mod:ZONE_CHANGED_NEW_AREA()
		self:Schedule(1, TwinPeaks_Initialize, self)
	end
end

do
	local string.find = string.find
	local flagTimer			= mod:NewTimer(12, "TimerFlag", "Interface\\Icons\\INV_Banner_02")
	local vulnerableTimer	= mod:NewNextTimer(60, 46392)

	local function updateflagcarrier(self, event, arg1)
		if string.match(arg1, L.ExprFlagCaptured) then
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
		if msg == L.Vulnerable1 or msg == L.Vulnerable2 or string.find(msg, L.Vulnerable1) or string.find(msg, L.Vulnerable2) then
			vulnerableTimer:Start()
		end
	end
end

do
	local tonumber = tonumber
	local remainingTimer = mod:NewTimer(0, "TimerRemaining", 2457)

	mod:Schedule(130, function()
		local info = GetIconAndTextWidgetVisualizationInfo(6)
		if info and info.state == 1 then
			local minutes, seconds = string.match(info.text, "(%d+):(%d+)")
			if minutes and seconds then
				remainingTimer:SetTimer(tonumber(seconds) + (tonumber(minutes) * 60) + 1)
				remainingTimer:Start()
			end
		end
	end, self)
end