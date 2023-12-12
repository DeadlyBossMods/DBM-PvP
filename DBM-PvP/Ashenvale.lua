if WOW_PROJECT_ID ~= WOW_PROJECT_CLASSIC or not C_Seasons or C_Seasons.GetActiveSeason() < 2 then
	return
end
local MAP_ASHENVALE = 1440
local mod = DBM:NewMod("m" .. MAP_ASHENVALE, "DBM-PvP")
local L = mod:GetLocalizedStrings()

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

local startTimer = mod:NewStageTimer(0, 20230, "EstimatedStart", nil, "EstimatedStartTimer", nil, nil, nil, true) -- last arg is "keep"

local widgetIDs = {
	[5360] = true, -- Alliance progress
	[5361] = true, -- Horde progress
	[5367] = true, -- Alliance bosses remaining
	[5368] = true, -- Horde bosses remaining
	[5378] = true, -- Event time remaining
}

mod.stateTracking = {}

function mod:resetStateTracking()
	self.stateTracking = {
		alliance = {},
		horde = {},
	}
end
mod:resetStateTracking()

---@return number|nil
---@return number|nil
local function getEstimate(data)
	if #data < 3 then return end
	local latest = data[#data]
	for i = #data - 2, 1, -1 do -- estimate based on at least 2 ticks
		local entry = data[i]
		local timeDiff = latest.time - entry.time
		if timeDiff > 120 then -- and at least 2 minutes
			local rate = (latest.percent - entry.percent) / timeDiff
			if rate == 0 then
				-- shouldn't happen, but avoid stupid errors when returning infinity
				return
			end
			local totalTime = 100 / rate
			local remaining = (100 - latest.percent) / rate
			return remaining, totalTime
		end
	end
end

function mod:updateStartTimer()
	-- Raw data dump example: https://docs.google.com/spreadsheets/d/15K8YfAKg0_cho0Ebj8iOlCCFbwoWj-QLcrDpZBpmuaA/edit#gid=0
	-- Layering can mess this up, we may want to detect large discontinuities in the data and just abort in that case
	-- TODO: we may want to consider rate limiting the timer update if it jumps around a lot
	-- however, these events here only gets triggered like once per minute and the rate is very stable (see data above)
	-- so I haven't observed jumpiness on the timer yet
	local aRemaining, aTotal = getEstimate(self.stateTracking.alliance)
	local hRemaining, hTotal = getEstimate(self.stateTracking.horde)
	if not aRemaining or not hRemaining or not aTotal or not hTotal then
		return
	end
	-- TODO: we can use the estimates to estimate the start time, this should yield the same result if the estimate is good
	-- TODO: some people on reddit claimed that once one faction reaches 100% their progress gets added to the other one
	-- but all events that I've seen since I started on this code have been very balanced, so I couldn't observe this effect
	local remaining = math.max(aRemaining, hRemaining)
	local total = math.max(aTotal, hTotal)
	if total > 6 * 60 * 60 then -- estimates of > 6 hours total time are probably bad and useless anyways
		DBM:Debug("Got total time estimate of " .. total .. ", discarding")
		return
	end
	startTimer:Update(total - remaining, total)
	if remaining > 180 then
		startTimer:UpdateName(L.TimerEstimate)
	else -- last few minutes feel a bit random
		startTimer:UpdateName(L.TimerSoon)
	end
end

function mod:startEvent()
	DBM:Debug("Detected start of Ashenvale event")
	startTimer:Stop()
	local generalMod = DBM:GetModByName("PvPGeneral")
	generalMod:StopTrackHealth()
	generalMod:TrackHealth(212804, "RunestoneBoss", true, "YELL", BLUE_FONT_COLOR)
	generalMod:TrackHealth(212707, "GlaiveBoss", true, "YELL", BLUE_FONT_COLOR)
	generalMod:TrackHealth(212803, "ResearchBoss", true, "YELL", BLUE_FONT_COLOR)
	generalMod:TrackHealth(212970, "MoonwellBoss", true, "YELL", BLUE_FONT_COLOR)
	generalMod:TrackHealth(212801, "ShredderBoss", true, "YELL", RED_FONT_COLOR)
	generalMod:TrackHealth(212730, "CatapultBoss", true, "YELL", RED_FONT_COLOR)
	generalMod:TrackHealth(212802, "LumberBoss", true, "YELL", RED_FONT_COLOR)
	generalMod:TrackHealth(212969, "BonfireBoss", true, "YELL", RED_FONT_COLOR)
end

function mod:stopEvent()
	DBM:Debug("Detected end of Ashenvale event or leaving zone")
	startTimer:Stop()
	local generalMod = DBM:GetModByName("PvPGeneral")
	generalMod:StopTrackHealth()
	self:resetStateTracking()
end

function mod:checkEventState()
	local eventTime = C_UIWidgetManager.GetIconAndTextWidgetVisualizationInfo(5378)
	if eventTime and eventTime.state ~= Enum.IconAndTextWidgetState.Hidden then
		if not self.eventRunning then
			self.eventRunning = true
			self:startEvent()
		end
	elseif self.eventRunning then
		self.eventRunning = false
		self:stopEvent()
	end
end

function mod:UPDATE_UI_WIDGET(tbl)
	if not self.inZone then
		return
	end
	if tbl and widgetIDs[tbl.widgetID] then
		self:checkEventState()
	end
	if tbl.widgetID == 5360 or tbl.widgetID == 5361 then
		local info = C_UIWidgetManager.GetIconAndTextWidgetVisualizationInfo(tbl.widgetID)
		local percent = info and info.text and info.text:match("(%d+)")
		if percent then
			percent = tonumber(percent)
			local data = tbl.widgetID == 5360 and self.stateTracking.alliance or self.stateTracking.horde
			if data[#data] and data[#data].percent >= 100 then
				-- stop updating once it reaches 100. yes it can go down by a few percent(who knows why?), but we don't care
				return
			end
			local time = GetTime()
			-- Updates sometimes trigger multiple times with the new and old value mixed together
			-- These duplicate triggers happen on the same frame and the latest value seems to be the current one
			if data[#data] and data[#data].time == time then
				data[#data] = nil
			end
			if not data[#data] or data[#data].percent ~= percent then
				data[#data + 1] = {time = GetTime(), percent = percent}
				self:updateStartTimer()
			end
		end
	end
end

function mod:enterAshenvale()
	self.inZone = true
	self:checkEventState()
end

function mod:leaveAshenvale()
	self.inZone = false
	self:stopEvent()
end

function mod:ZoneChanged()
	local map = C_Map.GetBestMapForUnit("player")
	if map == MAP_ASHENVALE and not self.inZone then
		self:enterAshenvale()
	elseif map ~= MAP_ASHENVALE and self.inZone then
		self:leaveAshenvale()
	end
end
mod.LOADING_SCREEN_DISABLED = mod.ZoneChanged
mod.ZONE_CHANGED_NEW_AREA   = mod.ZoneChanged
mod.PLAYER_ENTERING_WORLD   = mod.ZoneChanged
mod.OnInitialize            = mod.ZoneChanged

function mod:DebugExportState()
	local export = {"Time,Alliance,Horde"}
	local a, h = 1, 1
	while true do
		local entryA = self.stateTracking.alliance[a]
		local entryH = self.stateTracking.horde[h]
		if not entryA and not entryH then
			break
		end
		if not entryH or entryA and entryA.time < entryH.time then
			export[#export + 1] = entryA.time .. "," .. entryA.percent
			a = a + 1
		else
			export[#export + 1] = entryH.time .. ",," .. entryH.percent
			h = h + 1
		end
	end
	DBM:ShowUpdateReminder(nil, nil, "CSV dump of progress data for last event", table.concat(export, "\n"))
end
