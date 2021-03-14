if WOW_PROJECT_ID == WOW_PROJECT_CLASSIC then
	return
end
local mod	= DBM:NewMod("z2118", "DBM-PvP")

mod:SetRevision("@file-date-integer@")
mod:SetZone(DBM_DISABLE_ZONE_DETECTION)

mod:RegisterEvents("LOADING_SCREEN_DISABLED")

do
	local function Init()
		if DBM:GetCurrentArea() == 2118 then
			-- TODO
		end
	end

	function mod:LOADING_SCREEN_DISABLED()
		self:Schedule(1, Init)
	end
	mod.PLAYER_ENTERING_WORLD	= mod.LOADING_SCREEN_DISABLED
	mod.OnInitialize			= mod.LOADING_SCREEN_DISABLED
end
