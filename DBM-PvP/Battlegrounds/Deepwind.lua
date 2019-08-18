if WOW_PROJECT_ID == WOW_PROJECT_CLASSIC then
	return
end
local mod	= DBM:NewMod("z1105", "DBM-PvP")

mod:SetRevision("@file-date-integer@")
mod:SetZone(DBM_DISABLE_ZONE_DETECTION)

mod:RegisterEvents(
	"ZONE_CHANGED_NEW_AREA"
)

do
	function mod:OnInitialize()
		if 1105 == DBM:GetCurrentArea() then
			DBM:GetModByName("DBM-PvP"):SubscribeAssault(
				519,
				-- TODO: Get default ID's
				{},
				{0.01, 8 / 5, 16 / 5, 32 / 5}
			)
		end
	end

	function mod:ZONE_CHANGED_NEW_AREA()
		self:ScheduleMethod(1, "OnInitialize")
	end
end
