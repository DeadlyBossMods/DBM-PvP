local mod	= DBM:NewMod("z761", "DBM-PvP", 2)
local L		= mod:GetLocalizedStrings()

mod:SetRevision("@file-date-integer@")
mod:SetZone(DBM_DISABLE_ZONE_DETECTION)

mod:RegisterEvents(
	"ZONE_CHANGED_NEW_AREA"
)

do
	local bgzone = false

	local function Gilneas_Initialize(self)
		if DBM:GetCurrentArea() == 761 then
			bgzone = true
			DBM:GetModByName("Battlegrounds"):SubscribeAssault(
				275,
				{Lighthouse = 26, Mines = 16, Waterworks = 6},
				{0.01, 10 / 9, 10 / 3, 30}
			)
		elseif bgzone then
			bgzone = false
			DBM:GetModByName("Battlegrounds"):UnsubscribeAssault()
		end
	end
	mod.OnInitialize = Gilneas_Initialize

	function mod:ZONE_CHANGED_NEW_AREA()
		self:Schedule(1, Gilneas_Initialize, self)
	end
end