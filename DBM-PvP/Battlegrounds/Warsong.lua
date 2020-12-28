local mod = DBM:NewMod(WOW_PROJECT_ID == WOW_PROJECT_CLASSIC and "z489" or "z2106", "DBM-PvP")

mod:SetRevision("@file-date-integer@")
mod:SetZone(DBM_DISABLE_ZONE_DETECTION)
mod:RegisterEvents("ZONE_CHANGED_NEW_AREA")

do
	local function doShit()
		if DBM:GetCurrentArea() == 489 or DBM:GetCurrentArea() == 2106 then -- Classic, Retail
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
