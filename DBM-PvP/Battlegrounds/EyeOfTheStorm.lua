if DBM:GetTOC() < 20000 then
	return
end
local mod	= DBM:NewMod("z566", "DBM-PvP")

mod:SetRevision("@file-date-integer@")
mod:SetZone(DBM_DISABLE_ZONE_DETECTION)
mod:RegisterEvents("LOADING_SCREEN_DISABLED")

do
	local function Init()
		if DBM:GetCurrentArea() == 566 or DBM:GetCurrentArea() == 968 then
			local modz = DBM:GetModByName("PvPGeneral")
			modz:SubscribeAssault(DBM:GetCurrentArea() == 566 and 112 or 397, 4)
			modz:SubscribeFlags()
		end
	end

	function mod:LOADING_SCREEN_DISABLED()
		self:Schedule(1, Init)
	end
	mod.PLAYER_ENTERING_WORLD	= mod.LOADING_SCREEN_DISABLED
	mod.OnInitialize			= mod.LOADING_SCREEN_DISABLED
end
