if WOW_PROJECT_ID == WOW_PROJECT_CLASSIC then
	return
end
local mod	= DBM:NewMod("z998", "DBM-PvP")

mod:SetRevision("@file-date-integer@")
mod:SetZone(DBM_DISABLE_ZONE_DETECTION)

mod:RegisterEvents(
	"ZONE_CHANGED_NEW_AREA"
)

--[[
[19:31:44] { ["areaPoiID"] = 2776,["name"] = Power Orb,["textureIndex"] = 45,["description"] = Uncontrolled,}
[19:31:44] { ["areaPoiID"] = 2775,["name"] = Power Orb,["textureIndex"] = 45,["description"] = Uncontrolled,}
[19:31:44] { ["areaPoiID"] = 2774,["name"] = Power Orb,["textureIndex"] = 45,["description"] = Uncontrolled,}
[19:31:44] { ["areaPoiID"] = 2777,["name"] = Power Orb,["textureIndex"] = 45,["description"] = Uncontrolled,}
]]--

do
	function mod:OnInitialize()
		if DBM:GetCurrentArea() == 998 then
			DBM:GetModByName("DBM-PvP"):SubscribeAssault(
				0,
				-- TODO: Get default ID's
				{},
				{0.01, 4.5 / 5, 9 / 5, 13.5 / 5, 18 / 5}
			)
		end
	end

	function mod:ZONE_CHANGED_NEW_AREA()
		self:ScheduleMethod(1, "OnInitialize")
	end
end
