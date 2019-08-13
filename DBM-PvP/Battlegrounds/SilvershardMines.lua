if WOW_PROJECT_ID == WOW_PROJECT_CLASSIC then
local mod	= DBM:NewMod("z727", "DBM-PvP", 2)
local L		= mod:GetLocalizedStrings()

mod:SetRevision("@file-date-integer@")
mod:SetZone(DBM_DISABLE_ZONE_DETECTION)

mod:RegisterEvents(
	"ZONE_CHANGED_NEW_AREA"
)

do
	local bgzone = false

	function mod:OnInitialize()
		if DBM:GetCurrentArea() == 727 then
			bgzone = true
			self:RegisterShortTermEvents(
				"CHAT_MSG_BG_SYSTEM_HORDE",
				"CHAT_MSG_BG_SYSTEM_ALLIANCE",
				"CHAT_MSG_BG_SYSTEM_NEUTRAL",
				"CHAT_MSG_RAID_BOSS_EMOTE"
			)
		elseif bgzone then
			bgzone = false
			self:UnregisterShortTermEvents()
		end
	end

	function mod:ZONE_CHANGED_NEW_AREA()
		self:ScheduleMethod(1, "OnInitialize")
	end
end

do
	local cartTimer	= mod:NewTimer(9.5, "TimerCart", "134376")
	local cartCount	= 0

	function mod:CHAT_MSG_RAID_BOSS_EMOTE(msg)
		if msg:find(L.Capture) then
			cartCount = cartCount + 1
			cartTimer:Start(nil, cartCount)
		end
	end
	mod.CHAT_MSG_BG_SYSTEM_ALLIANCE = mod.CHAT_MSG_RAID_BOSS_EMOTE
	mod.CHAT_MSG_BG_SYSTEM_HORDE = mod.CHAT_MSG_RAID_BOSS_EMOTE
	mod.CHAT_MSG_BG_SYSTEM_NEUTRAL = mod.CHAT_MSG_RAID_BOSS_EMOTE
end
