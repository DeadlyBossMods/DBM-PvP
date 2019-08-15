if WOW_PROJECT_ID == WOW_PROJECT_CLASSIC then return end
local mod	= DBM:NewMod("z628", "DBM-PvP", 2)

mod:SetRevision("@file-date-integer@")
mod:SetZone(DBM_DISABLE_ZONE_DETECTION)

mod:RegisterEvents(
	"ZONE_CHANGED_NEW_AREA"
)

local bgzone = false
do
	function mod:OnInitialize()
		if DBM:GetCurrentArea() == 628 then
			bgzone = true
			DBM:GetModByName("Battlegrounds"):SubscribeAssault(
				169,
				-- TODO: Get default ID's
				{},
				-- TODO: Get respawn info
				{}
			)
		elseif bgzone then
			bgzone = false
			DBM:GetModByName("Battlegrounds"):UnsubscribeAssault()
			for _, v in ipairs(self.timers) do v:Stop() end
			self:Unschedule()
		end
	end

	function mod:ZONE_CHANGED_NEW_AREA()
		self:ScheduleMethod(1, "OnInitialize")
	end
end
