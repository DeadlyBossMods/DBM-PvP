local mod		= DBM:NewMod("z2107", "DBM-PvP", 2)

mod:SetRevision("@file-date-integer@")
mod:SetZone(DBM_DISABLE_ZONE_DETECTION)

mod:RegisterEvents(
	"ZONE_CHANGED_NEW_AREA"
)

do
	local bgzone = false

	function mod:OnInitialize()
		local zoneID = DBM:GetCurrentArea()
		if zoneID == 1681 or zoneID == 2107 or zoneID == 2177 then--Classic Arathi, Winter, New, AI
			local assaultID
			if zoneID == 1681 then
				assaultID = 837
			elseif zoneID == 2107 then
				assaultID = 93
			elseif zoneID == 2177 then
				assaultID = 1383
			end
			DBM:GetModByName("Battlegrounds"):SubscribeAssault(
				assaultID,
				-- TODO: Get default ID's
				{Farm = 0, GoldMine = 0, LumberMill = 0, Stables = 0, Blacksmith = 0},
				{0.01, 10 / 12, 10 / 9, 10 / 6, 10 / 3, 30}
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