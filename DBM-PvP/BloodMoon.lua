if WOW_PROJECT_ID ~= WOW_PROJECT_CLASSIC or not C_Seasons or C_Seasons.GetActiveSeason() ~= 2 then
	return
end
local MAP_STRANGLETHORN = 1434
local mod = DBM:NewMod("m" .. MAP_STRANGLETHORN, "DBM-PvP")
local L = mod:GetLocalizedStrings()

local pvpMod = DBM:GetModByName("PvPGeneral")

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

-- Observed start and end times (GetServerTime()), seems to be exactly 30 minutes but start/end is a bit random
-- 18:00:58 to 18:30:58
-- 21:00:48 to 21:30:47
-- 12:00:?? to 12:30:36
-- 21:00:38 to 21:30:38
-- 00:00:?? to 00:30:36
-- 12:00:16 to 12:30:17
-- 15:00:12 to 15:30:12

function mod:updateStartTimer()
	local remaining = pvpMod:GetTimeUntilWorldPvpEvent()
	local total = 3 * 60 * 60
	if remaining < 2.5 * 60 * 60 then
		startTimer:Update(total - remaining, total)
	else
		startTimer:Stop()
	end
end

local function debugTimeString()
	local time = date("*t", GetServerTime())
	local gameHour, gameMin = GetGameTime()
	return ("server time %02d:%02d:%02d, game time %02d:%02d"):format(time.hour, time.min, time.sec, gameHour, gameMin)
end

function mod:startEvent(timeRemaining)
	DBM:Debug("Start/update Stranglethorn event, " .. timeRemaining .. " minutes at " .. debugTimeString())
	if not self.eventRunning then
		startTimer:Stop()
	end
	self.eventRunning = true
	if not eventRunningTimer:IsStarted() and timeRemaining > 0 then -- Event start sometimes triggers for 0 minutes
		-- Event starts triggers two updates at the exact same time for 31 and 30
		-- Event goes for exactly 30 minutes after we first see an update like this
		if timeRemaining == 31 or timeRemaining == 30 then
			eventRunningTimer:Start()
		else
			-- We joined late, this is a bit messy because the widget updates and time remaining is only poorly correlated with actual timings.
			-- For example, event triggers like this are common:
			-- 3 minute at 28:35 server time, 1 minute at 29:38 server time, ended at 30:36 (2 min update was just skipped)
			-- 3 minute at 28:10 server time, 2 minute at 29:13 server time, 1 minute at 30:15 server time, ended at 30:17
			local remaining = pvpMod:GetTimeUntilWorldPvpEvent() - 2.5 * 60 * 60
			eventRunningTimer:Update(30 * 60 - remaining, 30 * 60)
		end
	end
end


function mod:stopEvent()
	DBM:Debug(("Detected end of Stranglethorn event or leaving zone, time remaining on timer: %.2f"):format(eventRunningTimer:GetRemaining()))
	startTimer:Stop()
	eventRunningTimer:Stop()
	self.eventRunning = false
	DBM:Debug("Event stopped at " .. debugTimeString())
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
		if info and info.state ~= Enum.IconAndTextWidgetState.Hidden and info.text then
			local timeRemaining = info.text:match(L.ParseTimeFromWidget)
			timeRemaining = tonumber(timeRemaining) or -1
			self:startEvent(timeRemaining)
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
