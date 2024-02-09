if WOW_PROJECT_ID ~= WOW_PROJECT_CLASSIC or not C_Seasons or C_Seasons.GetActiveSeason() ~= 2 then
	return
end
local MAP_STRANGLETHORN = 1434
local mod = DBM:NewMod("m" .. MAP_STRANGLETHORN, "DBM-PvP")
local L = mod:GetLocalizedStrings()

mod:SetRevision("@file-date-integer@")
mod:SetZone(DBM_DISABLE_ZONE_DETECTION)
mod:RegisterEvents(
	"LOADING_SCREEN_DISABLED",
	"ZONE_CHANGED_NEW_AREA",
	"PLAYER_ENTERING_WORLD",
	"UPDATE_UI_WIDGET",
	"UNIT_AURA player"
)

local startTimer = mod:NewNextTimer(0, 436097)
local eventRunningTimer = mod:NewBuffActiveTimer(30 * 60, 436097)

local widgetIDs = {
	[5608] = true, -- Event active (shows up after ~5 minutes)
	[5609] = true, -- Event not active
}

function mod:updateStartTimer()
	-- C_DateAndTime.GetServerTimeLocal() returns a time zone that is neither the server's time nor my time?
	local time = date("*t", GetServerTime())
	local hour = time.hour + time.min / 60 + time.sec / 60 / 60
	local remaining = (3 - (hour % 3)) * 60 * 60
	local total = 3 * 60 * 60
	if remaining < 2.5 * 60 * 60 then
		startTimer:Update(total - remaining, total)
	else
		startTimer:Stop()
	end
end

function mod:startEvent(timeRemaining)
	if not self.eventRunning then
		DBM:Debug("Detected start/update of Stranglethorn event")
		startTimer:Stop()
	end
	self.eventRunning = true
	eventRunningTimer:Update((30 - timeRemaining) * 60, 30 * 60)
end

function mod:stopEvent()
	DBM:Debug("Detected end of Stranglethorn event or leaving zone")
	startTimer:Stop()
	self.eventRunning = false
end

function mod:checkEventState()
	local eventRunning = C_UIWidgetManager.GetIconAndTextWidgetVisualizationInfo(5608)
	local eventNotRunning = C_UIWidgetManager.GetIconAndTextWidgetVisualizationInfo(5609)
	local eventRunningShown = eventRunning and eventRunning.state ~= Enum.IconAndTextWidgetState.Hidden
	local eventNotRunningShown = eventNotRunning and eventNotRunning.state ~= Enum.IconAndTextWidgetState.Hidden
	if eventNotRunningShown then
		if self.eventRunning then
			self.eventRunning = false
			self:stopEvent()
		end
	end
	if eventNotRunningShown or (not eventNotRunningShown and not eventRunningShown) then
		self:updateStartTimer()
	end
end

function mod:UPDATE_UI_WIDGET(tbl)
	if not self.inZone then
		return
	end
	if tbl and widgetIDs[tbl.widgetID] then
		self:checkEventState()
	end
	if tbl.widgetID == 5608 then
		local info = C_UIWidgetManager.GetIconAndTextWidgetVisualizationInfo(5608)
		if info and info.state ~= Enum.IconAndTextWidgetState.Hidden then
			local timeRemaining = info.text:match(L.ParseTimeFromWidget)
			timeRemaining = tonumber(timeRemaining) or -1
			self:startEvent(timeRemaining + 1) -- Event goes on for a minute after it updates to 0 minutes remaining
		end
	end
end

function mod:enterStranglethorn()
	self.inZone = true
	self:checkEventState()
	self:updateStartTimer()
end

function mod:leaveStranglethorn()
	self.inZone = false
	self:stopEvent()
	startTimer:Stop()
	startTimer:Stop()
end

function mod:ZoneChanged()
	local map = C_Map.GetBestMapForUnit("player")
	if map == MAP_STRANGLETHORN and not self.inZone then
		self:enterStranglethorn()
	elseif map ~= MAP_STRANGLETHORN and self.inZone then
		self:leaveStranglethorn()
	end
end
mod.LOADING_SCREEN_DISABLED = mod.ZoneChanged
mod.ZONE_CHANGED_NEW_AREA   = mod.ZoneChanged
mod.PLAYER_ENTERING_WORLD   = mod.ZoneChanged
mod.OnInitialize            = mod.ZoneChanged
