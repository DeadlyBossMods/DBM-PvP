if WOW_PROJECT_ID == WOW_PROJECT_CLASSIC then
	return
end
local mod	= DBM:NewMod("z761", "DBM-PvP")

mod:SetRevision("@file-date-integer@")
mod:SetZone(DBM_DISABLE_ZONE_DETECTION)
mod:RegisterEvents("ZONE_CHANGED_NEW_AREA")

do
	local function doShit(self)
		if DBM:GetCurrentArea() == 761 then
			DBM:GetModByName("PvPGeneral"):SubscribeAssault(275, 3)
		end
	end
	function mod:OnInitialize()
		self:Schedule(1, doShit, self)
	end

	function mod:ZONE_CHANGED_NEW_AREA()
		self:Schedule(1, doShit, self)
	end
end
