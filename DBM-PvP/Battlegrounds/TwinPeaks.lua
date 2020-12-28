if WOW_PROJECT_ID == WOW_PROJECT_CLASSIC then
	return
end
local mod	= DBM:NewMod("z726", "DBM-PvP")

mod:SetRevision("@file-date-integer@")
mod:SetZone(DBM_DISABLE_ZONE_DETECTION)
mod:RegisterEvents("ZONE_CHANGED_NEW_AREA")

do
	local function doShit()
		if DBM:GetCurrentArea() == 726 then
			DBM:GetModByName("PvPGeneral"):SubscribeFlags()
		end
	end
	function mod:OnInitialize()
		self:Schedule(1, doShit)
	end

	function mod:ZONE_CHANGED_NEW_AREA()
		self:Schedule(1, doShit)
	end
end
