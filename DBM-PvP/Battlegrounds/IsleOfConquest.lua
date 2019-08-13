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
		end
	end

	function mod:ZONE_CHANGED_NEW_AREA()
		self:ScheduleMethod(1, "OnInitialize")
	end
end