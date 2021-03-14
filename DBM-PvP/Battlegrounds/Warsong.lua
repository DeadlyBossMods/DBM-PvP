local mod = DBM:NewMod(WOW_PROJECT_ID == WOW_PROJECT_CLASSIC and "z489" or "z2106", "DBM-PvP")

mod:SetRevision("@file-date-integer@")
mod:SetZone(DBM_DISABLE_ZONE_DETECTION)
mod:RegisterEvents("LOADING_SCREEN_DISABLED")

do
	local function Init()
		if DBM:GetCurrentArea() == 489 or DBM:GetCurrentArea() == 2106 then -- Classic, Retail
			DBM:GetModByName("PvPGeneral"):SubscribeFlags()
		end
	end

	function mod:LOADING_SCREEN_DISABLED()
		self:Schedule(1, Init)
	end
	mod.PLAYER_ENTERING_WORLD	= mod.LOADING_SCREEN_DISABLED
	mod.OnInitialize			= mod.LOADING_SCREEN_DISABLED
end
