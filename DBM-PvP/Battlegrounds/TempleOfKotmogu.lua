if WOW_PROJECT_ID == WOW_PROJECT_CLASSIC then return end
local mod	= DBM:NewMod("z998", "DBM-PvP", 2)

mod:SetRevision("@file-date-integer@")
mod:SetZone(DBM_DISABLE_ZONE_DETECTION)

mod:RegisterEvents(
	"ZONE_CHANGED_NEW_AREA"
)

do
	local bgzone = false

	function mod:OnInitialize()
		if DBM:GetCurrentArea() == 998 then
			bgzone = true
			DBM:GetModByName("Battlegrounds"):SubscribeAssault(
				0,
				-- TODO: Get default ID's
				{},
				{0.01, 4.5 / 5, 9 / 5, 13.5 / 5, 18 / 5}
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
