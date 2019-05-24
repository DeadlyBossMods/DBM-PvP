-- Warsong mod v3.0
-- rewrite by Nitram and Tandanu
--
-- thanks to LeoLeal, DiabloHu and Са°ЧТВ


local mod		= DBM:NewMod("z2106", "DBM-PvP", 2)
local L			= mod:GetLocalizedStrings()

mod:SetRevision("@file-date-integer@")
mod:SetZone(DBM_DISABLE_ZONE_DETECTION)

local bgzone = false
mod:RegisterEvents(
	"ZONE_CHANGED_NEW_AREA"
)

--local startTimer		= mod:NewTimer(62, "TimerStart", "132349")
local flagTimer			= mod:NewTimer(12, "TimerFlag", "132483")
local vulnerableTimer	= mod:NewNextTimer(60, 46392)

do
	local function WSG_Initialize(self)
		if DBM:GetCurrentArea() == 489 or DBM:GetCurrentArea() == 2106 then--Old, New
			bgzone = true
			self:RegisterShortTermEvents(
				"CHAT_MSG_BG_SYSTEM_ALLIANCE",
				"CHAT_MSG_BG_SYSTEM_HORDE",
				"CHAT_MSG_BG_SYSTEM_NEUTRAL"
			)

		elseif bgzone then
			bgzone = false
			self:UnregisterShortTermEvents()
		end
	end
	mod.OnInitialize = WSG_Initialize

	function mod:ZONE_CHANGED_NEW_AREA()
		self:Schedule(1, WSG_Initialize, self)
	end
end

function mod:CHAT_MSG_BG_SYSTEM_NEUTRAL(msg)
	if msg == L.Vulnerable1 or msg == L.Vulnerable2 or msg:find(L.Vulnerable1) or msg:find(L.Vulnerable2) then
		vulnerableTimer:Start()
	end
end

do
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
end
