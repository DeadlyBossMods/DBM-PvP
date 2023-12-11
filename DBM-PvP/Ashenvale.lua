if WOW_PROJECT_ID ~= WOW_PROJECT_CLASSIC or not C_Seasons or C_Seasons.GetActiveSeason() < 2 then
	return
end
local MAP_ASHENVALE = 1440
local mod = DBM:NewMod("m" .. MAP_ASHENVALE, "DBM-PvP")

mod:SetRevision("@file-date-integer@")
-- TODO: we could teach this thing to handle outdoor zones instead of only instances
-- when implementing this make sure that the stop functions are called properly, i.e., that ZONE_CHANGED_NEW_AREA still fires when leaving
mod:SetZone(DBM_DISABLE_ZONE_DETECTION)
mod:RegisterEvents(
	"LOADING_SCREEN_DISABLED",
	"ZONE_CHANGED_NEW_AREA",
	"PLAYER_ENTERING_WORLD",
	"UPDATE_UI_WIDGET"
)

local widgetIDs = {
	[5360] = true, -- Alliance progress
	[5361] = true, -- Horde progress
	[5367] = true, -- Alliance bosses remaining
	[5368] = true, -- Horde bosses remaining
	[5378] = true, -- Event time remaining
}

function mod:StartEvent()
	DBM:Debug("Detected start of Ashenvale event")
	local generalMod = DBM:GetModByName("PvPGeneral")
	generalMod:StopTrackHealth()
	generalMod:TrackHealth(212804, "RunestoneBoss", true, "YELL")
	generalMod:TrackHealth(212707, "GlaiveBoss", true, "YELL")
	generalMod:TrackHealth(212803, "ResearchBoss", true, "YELL")
	generalMod:TrackHealth(212970, "MoonwellBoss", true, "YELL")
	generalMod:TrackHealth(212801, "ShredderBoss", true, "YELL")
	generalMod:TrackHealth(212730, "CatapultBoss", true, "YELL")
	generalMod:TrackHealth(212802, "LumberBoss", true, "YELL")
	generalMod:TrackHealth(212969, "BonfireBoss", true, "YELL")
end

function mod:StopEvent()
	DBM:Debug("Detected end of Ashenvale event or leaving zone")
	local generalMod = DBM:GetModByName("PvPGeneral")
	generalMod:StopTrackHealth()
end

function mod:CheckEventState()
	local eventTime = C_UIWidgetManager.GetIconAndTextWidgetVisualizationInfo(5378)
	if eventTime and eventTime.state ~= Enum.IconAndTextWidgetState.Hidden then
		if not self.eventRunning then
			self.eventRunning = true
			self:StartEvent()
		end
	elseif self.eventRunning then
		self.eventRunning = false
		self:StopEvent()
	end
end

function mod:UPDATE_UI_WIDGET(tbl)
	if not self.inZone then
		return
	end
	if tbl and widgetIDs[tbl.widgetID] then
		self:CheckEventState()
	end
end

function mod:EnterAshenvale()
	self.inZone = true
	self:CheckEventState()
end

function mod:LeaveAshenvale()
	self.inZone = false
	self:StopEvent()
end

function mod:ZoneChanged()
	local map = C_Map.GetBestMapForUnit("player")
	if map == MAP_ASHENVALE and not self.inZone then
		self:EnterAshenvale()
	elseif map ~= MAP_ASHENVALE and self.inZone then
		self:LeaveAshenvale()
	end
end
mod.LOADING_SCREEN_DISABLED = mod.ZoneChanged
mod.ZONE_CHANGED_NEW_AREA   = mod.ZoneChanged
mod.PLAYER_ENTERING_WORLD   = mod.ZoneChanged
mod.OnInitialize            = mod.ZoneChanged
