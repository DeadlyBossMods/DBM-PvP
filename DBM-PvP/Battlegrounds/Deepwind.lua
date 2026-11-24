-- 泰坦重铸时光服-时光2-法师-旺仔芒果/椰奶冻-2026.11.13--
local mod	= DBM:NewMod("z2245", "DBM-PvP", nil, nil, function(t)
	if not t or t == "" or t == "z2245" then
		local L = DBM:GetModLocalization("z2245")
		return (L and L.general and L.general.name) or "深风峡谷"
	end
	return t
end) -- Added in MoP

mod:SetRevision("@file-date-integer@")
mod:SetZone(DBM_DISABLE_ZONE_DETECTION)
mod:RegisterEvents(
	"LOADING_SCREEN_DISABLED",
	"ZONE_CHANGED_NEW_AREA",
	"PLAYER_ENTERING_WORLD"
)

do
	local bgzone = false

	local function Init()
		local zoneID = DBM:GetCurrentArea()
		if not bgzone and zoneID == 2245 then
			bgzone = true
			local pvpGeneral = DBM:GetModByName("PvPGeneral")
			pvpGeneral:SubscribeAssault(1576, 5)
		elseif bgzone and zoneID ~= 2245 then
			bgzone = false
		end
	end

	function mod:LOADING_SCREEN_DISABLED()
		self:Schedule(1, Init)
	end
	mod.ZONE_CHANGED_NEW_AREA	= mod.LOADING_SCREEN_DISABLED
	mod.PLAYER_ENTERING_WORLD	= mod.LOADING_SCREEN_DISABLED
	mod.OnInitialize			= mod.LOADING_SCREEN_DISABLED
end
