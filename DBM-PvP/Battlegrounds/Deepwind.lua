if WOW_PROJECT_ID == WOW_PROJECT_CLASSIC then return end
local mod	= DBM:NewMod("z1105", "DBM-PvP", 2)

mod:SetRevision("@file-date-integer@")
mod:SetZone(DBM_DISABLE_ZONE_DETECTION)

mod:RegisterEvents(
	"ZONE_CHANGED_NEW_AREA"
)

do
	local bgzone = false

	function mod:OnInitialize()
		if 1105 == DBM:GetCurrentArea() then
			bgzone = true
			DBM:GetModByName("Battlegrounds"):SubscribeAssault(
				519,
				-- TODO: Get default ID's
				{},
				{0.01, 8 / 5, 16 / 5, 32 / 5}
			)
			bgzone = true
		elseif bgzone then
			bgzone = false
			self:UnregisterShortTermEvents()
			for _, v in ipairs(self.timers) do v:Stop() end
			self:Unschedule()
		end
	end

	function mod:ZONE_CHANGED_NEW_AREA()
		self:ScheduleMethod(1, "OnInitialize")
	end
end
