if WOW_PROJECT_ID == WOW_PROJECT_CLASSIC then
	return
end
local mod	= DBM:NewMod("z2245", "DBM-PvP") -- Previously zone 1105

mod:SetRevision("@file-date-integer@")
mod:SetZone(DBM_DISABLE_ZONE_DETECTION)

mod:RegisterEvents(
	"ZONE_CHANGED_NEW_AREA"
)

do
	function mod:OnInitialize()
		if DBM:GetCurrentArea() == 2245 then -- Previously zone 1105
			DBM:GetModByName("PvPGeneral"):SubscribeAssault(
				1576, -- Previously 519, now 1576
				{["Quarry"] = {17,19}, ["Farm"] = {32,34},  ["Market"] = {208,209}, ["Ruins"] = {213,214}, ["Shrine"] = {218, 219}},
				{1e-300, 10 / 12, 10 / 9, 10 / 6, 10 / 3, 30}
			)
		end
	end

	function mod:ZONE_CHANGED_NEW_AREA()
		self:ScheduleMethod(1, "OnInitialize")
	end
end
