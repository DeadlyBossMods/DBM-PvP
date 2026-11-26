local mod	= DBM:NewMod("z2997", "DBM-PvP") -- WoW Forever, plays like Eye of the Storm

mod:SetRevision("@file-date-integer@")
mod:SetZone(DBM_DISABLE_ZONE_DETECTION)
mod:RegisterEvents(
	"LOADING_SCREEN_DISABLED",
	"ZONE_CHANGED_NEW_AREA",
	"PLAYER_ENTERING_WORLD"
)

local capTimer	= mod:NewTimer(60, "TimerCap", "136002") -- Interface\\icons\\spell_misc_hellifrepvphonorholdfavor.blp
local flagTimer	= mod:NewTimer(24, "TimerFlag", "132483") -- Interface\\icons\\inv_banner_02.blp

-- Everything comes from widgets, so this works in every locale (measured on Forever 1.60.1):
-- * 7860: one icon row per faction. Each base has an icon in state 1 while that faction assaults it and 2 while it
--   owns it; the flag icon (the one without a second tooltip) is in state 1 while that faction carries the flag.
-- * 7467: score bar, Alliance left. Bases add 2/3/4/50 points every 2 s (1 to 4 bases), a flag capture adds 75/85/100/200.
local CAP_POINTS_WIDGET, SCORE_WIDGET = 7860, 7467
local UI_MAP_ID = 2524
local BASE_POIS = {8768, 8771, 8772, 8773} -- Camp, Ruins, Abandoned Tower, Shipwreck Cove
local CAPTURE_TIME = 60
local FLAG_RESPAWN_AFTER_CAPTURE = 24 -- 22.2 to 24.4 s observed
local FLAG_RESPAWN_AFTER_DROP = 12
local MAX_TICK_POINTS = 50 -- a bigger jump is a flag capture (possibly together with a tick)
-- Resources per second by bases held, index 1 = no base
local RES_PER_SEC = {1e-300, 1, 1.5, 2, 25}

local GetDoubleStateIconRowVisualizationInfo = C_UIWidgetManager.GetDoubleStateIconRowVisualizationInfo
local GetDoubleStatusBarWidgetVisualizationInfo = C_UIWidgetManager.GetDoubleStatusBarWidgetVisualizationInfo
local GetAreaPOIInfo = C_AreaPoiInfo.GetAreaPOIInfo
local GetTime = GetTime

local SIDES = {
	{key = "leftIcons", faction = "Alliance", color = {r = 0, g = 0, b = 1}, icon = "132486"}, -- Interface\\Icons\\INV_BannerPVP_02.blp
	{key = "rightIcons", faction = "Horde", color = {r = 1, g = 0, b = 0}, icon = "132485"}, -- Interface\\Icons\\INV_BannerPVP_01.blp
}

local bgzone = false
local iconStates, carrying, lastCapture, lastDrop, scores, bases, baseNames = {}, {}, {}, {}, {}, {}, {}
-- Loaded into a running match (e.g. a reload): an assault already in progress has an unknown start, so no timer
local joinedRunningMatch = false

local function resetState()
	iconStates, carrying, lastCapture, lastDrop, scores, bases, baseNames = {}, {}, {}, {}, {}, {}, {}
	joinedRunningMatch = false
end

-- The icon tooltips ("Alliance has captured Ruins") contain the localized base name, which the POIs know as well
local function baseName(tooltip)
	if not baseNames[tooltip] then
		baseNames[tooltip] = tooltip
		for _, poiID in ipairs(BASE_POIS) do
			local poi = GetAreaPOIInfo(UI_MAP_ID, poiID)
			if poi and poi.name and tooltip:find(poi.name, 1, true) then
				baseNames[tooltip] = poi.name
				break
			end
		end
	end
	return baseNames[tooltip]
end

local function startFlagTimer(time, side)
	flagTimer:Start(time)
	if side then
		flagTimer:SetColor(side.color)
		flagTimer:UpdateIcon(side.icon)
	end
end

-- Called shortly after the carrier's flag icon reset: a capture or a drop. The score bar (updated in the same frame)
-- tells the two apart. Only this starts the flag timer, never the score alone.
function mod:CheckFlagReset(side)
	local resetTime = lastDrop[side.faction]
	if not resetTime then return end
	local elapsed = GetTime() - resetTime
	if math.abs(resetTime - (lastCapture[side.faction] or 0)) <= 2 then
		startFlagTimer(FLAG_RESPAWN_AFTER_CAPTURE - elapsed, side)
	else
		startFlagTimer(FLAG_RESPAWN_AFTER_DROP - elapsed)
	end
end

local function updateCapPoints(self)
	local info = GetDoubleStateIconRowVisualizationInfo(CAP_POINTS_WIDGET)
	if not info then return end
	for _, side in ipairs(SIDES) do
		local owned = 0
		local states = iconStates[side.faction] or {}
		iconStates[side.faction] = states
		for i, icon in ipairs(info[side.key] or {}) do
			local state, previous = icon.iconState, states[i]
			if previous == nil and not joinedRunningMatch then
				previous = 0 -- the widget's first update can be the first assault
			end
			if icon.state2Tooltip == "" then
				-- flag icon
				local isCarrying = state == 1
				if isCarrying and not carrying[side.faction] then
					flagTimer:Stop()
				elseif not isCarrying and carrying[side.faction] then
					lastDrop[side.faction] = GetTime()
					self:ScheduleMethod(0.5, "CheckFlagReset", side)
				end
				carrying[side.faction] = isCarrying
			else
				if state == 2 then
					owned = owned + 1
				end
				if previous and state ~= previous then
					local name = baseName(icon.state2Tooltip)
					if state == 1 then
						capTimer:Start(CAPTURE_TIME, name)
						capTimer:SetColor(side.color, nil, name)
						capTimer:UpdateIcon(side.icon, name)
					elseif previous == 1 then
						capTimer:Stop(name) -- captured or defended
					end
				end
			end
			states[i] = state
		end
		bases[side.faction] = owned
	end
end

local function updateScores()
	local info = GetDoubleStatusBarWidgetVisualizationInfo(SCORE_WIDGET)
	if not info then return end
	for _, side in ipairs(SIDES) do
		local score = side.faction == "Alliance" and info.leftBarValue or info.rightBarValue
		local previous = scores[side.faction]
		if previous and score - previous > MAX_TICK_POINTS then
			lastCapture[side.faction] = GetTime()
		end
		scores[side.faction] = score
	end
	if bases.Alliance and bases.Horde then
		local generalMod = DBM:GetModByName("PvPGeneral")
		generalMod:UpdateWinTimer(info.leftBarMax, scores.Alliance, scores.Horde, bases.Alliance, bases.Horde)
	end
end

function mod:UPDATE_UI_WIDGET(widget)
	local widgetID = widget and widget.widgetID
	if widgetID == CAP_POINTS_WIDGET then
		updateCapPoints(self)
	elseif widgetID == SCORE_WIDGET then
		updateScores()
	end
end

function mod:Init()
	local zoneID = DBM:GetCurrentArea()
	if not bgzone and zoneID == 2997 then
		bgzone = true
		resetState()
		local generalMod = DBM:GetModByName("PvPGeneral")
		generalMod:SubscribeWinTimer(#BASE_POIS, RES_PER_SEC)
		local score = GetDoubleStatusBarWidgetVisualizationInfo(SCORE_WIDGET)
		joinedRunningMatch = score ~= nil and (score.leftBarValue > 0 or score.rightBarValue > 0)
		self:RegisterShortTermEvents("UPDATE_UI_WIDGET")
		-- Start from the current state, e.g. after a reload during the match
		updateCapPoints(self)
		updateScores()
	elseif bgzone and zoneID ~= 2997 then
		bgzone = false
		self:UnregisterShortTermEvents()
		self:Stop()
		resetState()
	end
end

function mod:LOADING_SCREEN_DISABLED()
	self:ScheduleMethod(1, "Init")
end
mod.ZONE_CHANGED_NEW_AREA	= mod.LOADING_SCREEN_DISABLED
mod.PLAYER_ENTERING_WORLD	= mod.LOADING_SCREEN_DISABLED
mod.OnInitialize			= mod.LOADING_SCREEN_DISABLED
