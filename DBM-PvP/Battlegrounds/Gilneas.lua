if WOW_PROJECT_ID == WOW_PROJECT_CLASSIC then return end
local mod	= DBM:NewMod("z761", "DBM-PvP", 2)

mod:SetRevision("@file-date-integer@")
mod:SetZone(DBM_DISABLE_ZONE_DETECTION)

mod:RegisterEvents(
	"ZONE_CHANGED_NEW_AREA"
)

do
	local bgzone = false

	function mod:OnInitialize()
		if DBM:GetCurrentArea() == 761 then
			bgzone = true
			DBM:GetModByName("Battlegrounds"):SubscribeAssault(
				275,
				{Lighthouse = 26, Mines = 16, Waterworks = 6},
				{0.01, 10 / 9, 10 / 3, 30}
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
