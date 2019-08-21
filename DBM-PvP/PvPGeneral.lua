local mod	= DBM:NewMod("PvPGeneral", "DBM-PvP")
local L		= mod:GetLocalizedStrings()

local ipairs, math = ipairs, math
local IsInInstance, CreateFrame = IsInInstance, CreateFrame

mod:SetRevision("@file-date-integer@")
mod:SetZone(DBM_DISABLE_ZONE_DETECTION)

--mod:AddBoolOption("ColorByClass", true)
mod:AddBoolOption("HideBossEmoteFrame", false)
mod:AddBoolOption("AutoSpirit", false)

mod:RegisterEvents(
	"ZONE_CHANGED_NEW_AREA",
	"PLAYER_ENTERING_WORLD",
	"PLAYER_DEAD",
	"START_TIMER",
	"UPDATE_BATTLEFIELD_STATUS"
)

do
	local C_ChatInfo = C_ChatInfo
	local bgzone = false

	function mod:ZONE_CHANGED_NEW_AREA()
		local _, instanceType = IsInInstance()
		if instanceType == "pvp" or instanceType == "arena" then
			C_ChatInfo.SendAddonMessage("D4", "H", "INSTANCE_CHAT")
			self:Schedule(3, DBM.RequestTimers, DBM)
			if not bgzone and self.Options.HideBossEmoteFrame then
				DBM:HideBlizzardEvents(1, true)
			end
			bgzone = true
		elseif bgzone then
			bgzone = false
			self:UnsubscribeAssault()
			if self.Options.HideBossEmoteFrame then
				DBM:HideBlizzardEvents(0, true)
			end
		end
	end
	mod.PLAYER_ENTERING_WORLD	= mod.ZONE_CHANGED_NEW_AREA
	mod.OnInitialize			= mod.ZONE_CHANGED_NEW_AREA
end

do
	local C_DeathInfo = C_DeathInfo

	function mod:PLAYER_DEAD()
		local _, instanceType = IsInInstance()
		if instanceType == "pvp" and not C_DeathInfo.GetSelfResurrectOptions() and self.Options.AutoSpirit then
			RepopMe()
		end
	end
end

do
	local tonumber = tonumber
	local C_UIWidgetManager, TimerTracker = C_UIWidgetManager, TimerTracker
	local remainingTimer	= mod:NewTimer(0, "TimerRemaining", 2457)
	local timerShadow		= mod:NewNextTimer(90, 34709)
	local timerDamp			= mod:NewCastTimer(300, 110310)

	function mod:START_TIMER(_, timeSeconds)
		local _, instanceType = IsInInstance()
		if (instanceType == "pvp" or instanceType == "arena" or instanceType == "scenario") and self.Options.TimerRemaining then
			for _, bar in ipairs(TimerTracker.timerList) do
				bar.bar:Hide()
			end
			remainingTimer:SetTimer(timeSeconds)
			remainingTimer:Start()
		end
		self:Schedule(timeSeconds + 1, function()
			if instanceType == "arena" then
				timerShadow:Start()
				timerDamp:Start()
			end
			local info = C_UIWidgetManager.GetIconAndTextWidgetVisualizationInfo(6)
			if info and info.state == 1 and self.Options.TimerRemaining then
				local minutes, seconds = info.text:match("(%d+):(%d+)")
				if minutes and seconds then
					remainingTimer:SetTimer(tonumber(seconds) + (tonumber(minutes) * 60) + 1)
					remainingTimer:Start()
				end
			end
		end, self)
	end
end

do
	local format, tostring = format, tostring
	local GetBattlefieldStatus, GetBattlefieldPortExpiration, PVP_TEAMSIZE = GetBattlefieldStatus, GetBattlefieldPortExpiration, PVP_TEAMSIZE
	local inviteTimer = mod:NewTimer(60, "TimerInvite", "135986")

	function mod:UPDATE_BATTLEFIELD_STATUS(queueID)
		if self.Options.TimerInvite then
			local status, mapName, _, _, _, teamSize = GetBattlefieldStatus(queueID)
			if status == "confirm" then
				if teamSize == "ARENASKIRMISH" then
					mapName = L.ArenaInvite .. " " .. format(PVP_TEAMSIZE, tostring(teamSize), tostring(teamSize))
				end
				local expiration = GetBattlefieldPortExpiration(queueID)
				if inviteTimer:GetTime(mapName) == 0 and expiration >= 3 then
					inviteTimer:Start(expiration, mapName)
				end
			elseif status == "none" or status == "active" then
				inviteTimer:Stop()
			end
		end
	end
end

-- Utility functions
local scoreFrame1, scoreFrame2, scoreFrameToWin, scoreFrame1Text, scoreFrame2Text, scoreFrameToWinText

local function ShowEstimatedPoints()
	if AlwaysUpFrame1 and AlwaysUpFrame2 then
		if not scoreFrame1 then
			scoreFrame1 = CreateFrame("Frame", nil, AlwaysUpFrame1)
			scoreFrame1:SetHeight(10)
			scoreFrame1:SetWidth(100)
			scoreFrame1:SetPoint("LEFT", "AlwaysUpFrame1DynamicIconButton", "RIGHT", 4, 0)
			scoreFrame1Text = scoreFrame1:CreateFontString(nil, nil, "GameFontNormalSmall")
			scoreFrame1Text:SetAllPoints(scoreFrame1)
			scoreFrame1Text:SetJustifyH("LEFT")
		end
		if not scoreFrame2 then
			scoreFrame2 = CreateFrame("Frame", nil, AlwaysUpFrame2)
			scoreFrame2:SetHeight(10)
			scoreFrame2:SetWidth(100)
			scoreFrame2:SetPoint("LEFT", "AlwaysUpFrame2DynamicIconButton", "RIGHT", 4, 0)
			scoreFrame2Text = scoreFrame2:CreateFontString(nil, nil, "GameFontNormalSmall")
			scoreFrame2Text:SetAllPoints(scoreFrame2)
			scoreFrame2Text:SetJustifyH("LEFT")
		end
		scoreFrame1Text:SetText("")
		scoreFrame1:Show()
		scoreFrame2Text:SetText("")
		scoreFrame2:Show()
	end
end

local function ShowBasesToWin()
	if not scoreFrameToWin then
		scoreFrameToWin = CreateFrame("Frame", nil, AlwaysUpFrame2)
		scoreFrameToWin:SetHeight(10)
		scoreFrameToWin:SetWidth(200)
		scoreFrameToWin:SetPoint("TOPLEFT", "AlwaysUpFrame2", "BOTTOMLEFT", 22, 2)
		scoreFrameToWinText = scoreFrameToWin:CreateFontString(nil, nil, "GameFontNormalSmall")
		scoreFrameToWinText:SetAllPoints(scoreFrameToWin)
		scoreFrameToWinText:SetJustifyH("LEFT")
	end
	scoreFrameToWinText:SetText("")
	scoreFrameToWin:Show()
end

local function HideEstimatedPoints()
	if scoreFrame1 and scoreFrame2 then
		scoreFrame1:Hide()
		scoreFrame2:Hide()
	end
end

local function HideBasesToWin()
	if scoreFrameToWin then
		scoreFrameToWin:Hide()
	end
end

local subscribedMapID = 0
local objectives, resPerSec
local objectivesStore = {}

function mod:SubscribeAssault(mapID, objects, rezPerSec)
	self:AddBoolOption("ShowEstimatedPoints", true, nil, function()
		if self.Options.ShowEstimatedPoints then
			ShowEstimatedPoints()
		else
			HideEstimatedPoints()
		end
	end)
	self:AddBoolOption("ShowBasesToWin", false, nil, function()
		if self.Options.ShowBasesToWin then
			ShowBasesToWin()
		else
			HideBasesToWin()
		end
	end)
	if self.Options.ShowEstimatedPoints then
		ShowEstimatedPoints()
	end
	if self.Options.ShowBasesToWin then
		ShowBasesToWin()
	end
	self:RegisterShortTermEvents(
		"AREA_POS_UPDATED",
		"UPDATE_UI_WIDGET"
	)
	subscribedMapID = mapID
	objectives = objects
	resPerSec = rezPerSec
	objectivesStore = {}
end

function mod:UnsubscribeAssault()
	HideEstimatedPoints()
	HideBasesToWin()
	self:UnregisterShortTermEvents()
	self:Stop()
	subscribedMapID = 0
end

do
	local GetTime, UnitFactionGroup, FACTION_HORDE, FACTION_ALLIANCE = GetTime, UnitFactionGroup, FACTION_HORDE, FACTION_ALLIANCE
	local winTimer = mod:NewTimer(30, "TimerWin", "134376")

	function mod:UpdateWinTimer(maxScore, allianceScore, hordeScore, allianceBases, hordeBases)
		local gameTime = GetTime()
		local allyTime = math.min(maxScore, (maxScore - allianceScore) / resPerSec[allianceBases + 1])
		local hordeTime = math.min(maxScore, (maxScore - hordeScore) / resPerSec[hordeBases + 1])
		if allyTime == hordeTime then
			winTimer:Stop()
			if scoreFrame1Text then
				scoreFrame1Text:SetText("")
				scoreFrame2Text:SetText("")
			end
		elseif allyTime > hordeTime then
			if scoreFrame1Text and scoreFrame2Text then
				scoreFrame1Text:SetText("(" .. math.floor(math.floor(((hordeTime * resPerSec[allianceBases + 1]) + allianceScore) / 10) * 10) .. ")")
				scoreFrame2Text:SetText("(" .. maxScore .. ")")
			end
			winTimer:Update(gameTime, gameTime + hordeTime)
			winTimer:DisableEnlarge()
			winTimer:UpdateName(L.WinBarText:format(FACTION_HORDE))
			winTimer:SetColor({1, 0, 0})
			winTimer:UpdateIcon("132485") -- Interface\\Icons\\INV_BannerPVP_01.blp
		elseif hordeTime > allyTime then
			if scoreFrame1Text and scoreFrame2Text then
				scoreFrame2Text:SetText("(" .. math.floor(math.floor(((allyTime * resPerSec[hordeBases + 1]) + hordeScore) / 10) * 10) .. ")")
				scoreFrame1Text:SetText("(" .. maxScore .. ")")
			end
			winTimer:Update(gameTime, gameTime + allyTime)
			winTimer:DisableEnlarge()
			winTimer:UpdateName(L.WinBarText:format(FACTION_ALLIANCE))
			winTimer:SetColor({0, 0, 1})
			winTimer:UpdateIcon("132486") -- Interface\\Icons\\INV_BannerPVP_02.blp
		end
		if self.Options.ShowBasesToWin then
			local friendlyLast, enemyLast, friendlyBases, enemyBases
			if UnitFactionGroup("player") == "Alliance" then
				friendlyLast = allianceScore
				enemyLast = hordeScore
				friendlyBases = allianceBases
				enemyBases = hordeBases
			else
				friendlyLast =hordeScore
				enemyLast = allianceScore
				friendlyBases = hordeBases
				enemyBases = allianceBases
			end
			if (maxScore - friendlyLast) / resPerSec[friendlyBases + 1] > (maxScore - enemyLast) / resPerSec[enemyBases + 1] then
				local enemyTime, friendlyTime, baseLowest, enemyFinal, friendlyFinal
				for i = 1, 3 do
					enemyTime = (maxScore - enemyLast) / resPerSec[3 - i]
					friendlyTime = (maxScore - friendlyLast) / resPerSec[i]
					baseLowest = friendlyTime < enemyTime and friendlyTime or enemyTime
					enemyFinal = math.floor((enemyLast + math.floor(baseLowest * resPerSec[3] + 0.5)) / 10) * 10
					friendlyFinal = math.floor((friendlyLast + math.floor(baseLowest * resPerSec[i] + 0.5)) / 10) * 10
					if friendlyFinal >= maxScore and enemyFinal < maxScore then
						scoreFrameToWinText:SetText(L.BasesToWin:format(i))
						break
					end
				end
			else
				scoreFrameToWinText:SetText("")
			end
		end
	end

	local pairs = pairs
	local C_AreaPoiInfo, C_UIWidgetManager = C_AreaPoiInfo, C_UIWidgetManager
	local capTimer = mod:NewTimer(60, "TimerCap", "136002")

	function mod:AREA_POS_UPDATED(widget)
		if subscribedMapID == 0 or (widget and widget.widgetID ~= 1671) then
			return
		end
		local isAtlas = false
		for _, areaPOIID in ipairs(C_AreaPoiInfo.GetAreaPOIForMap(subscribedMapID)) do
			local areaPOIInfo = C_AreaPoiInfo.GetAreaPOIInfo(subscribedMapID, areaPOIID)
			local infoName, atlasName, infoTexture = areaPOIInfo.name, areaPOIInfo.atlasName, areaPOIInfo.textureIndex
			if infoName then
				local isAllyCapped, isHordeCapped, checkState
				if atlasName then
					isAtlas = true
					isAllyCapped = atlasName:find('leftIcon')
					isHordeCapped = atlasName:find('rightIcon')
					checkState = atlasName
				elseif infoTexture then
					local capStates = objectives[infoName]
					if capStates then
						isAllyCapped = infoTexture == capStates[1]
						isHordeCapped = infoTexture == capStates[2]
						checkState = infoTexture
					end
				end
				if objectivesStore[infoName] ~= checkState then
					capTimer:Stop(infoName)
					if isAllyCapped or isHordeCapped then
						capTimer:Start(nil, infoName)
						if isAllyCapped then
							capTimer:SetColor({0, 0, 1}, infoName)
							capTimer:UpdateIcon("132485", infoName) -- Interface\\Icons\\INV_BannerPVP_02.blp
						else
							capTimer:SetColor({1, 0, 0}, infoName)
							capTimer:UpdateIcon("132486", infoName) -- Interface\\Icons\\INV_BannerPVP_01.blp
						end
					end
					objectivesStore[infoName] = checkState
				end
			end
		end
		local allyBases, hordeBases = 0, 0
		if isAtlas then
			for _, v in ipairs(objectivesStore) do
				if v:find('leftIcon') then
					allyBases = allyBases + 1
				elseif v:find('rightIcon') then
					hordeBases = hordeBases + 1
				end
			end
		else
			for k, v in pairs(objectivesStore) do
				local obj = objectives[k]
				if not obj then
					return -- Object is missing from the table???
				end
				if v == obj[1] + 1 then
					allyBases = allyBases + 1
				elseif v == obj[2] + 1 then
					hordeBases = hordeBases + 1
				end
			end
		end
		local info = C_UIWidgetManager.GetDoubleStatusBarWidgetVisualizationInfo(1671)
		self:UpdateWinTimer(info.leftBarMax, info.leftBarValue, info.rightBarValue, allyBases, hordeBases)
	end

	mod.UPDATE_UI_WIDGET = mod.AREA_POS_UPDATED
end

--[[
hooksecurefunc("WorldStateScoreFrame_Update", function() --re-color the players in the score frame
	if not mod.Options.ColorByClass then
		return
	end
	local isArena = IsActiveBattlefieldArena()
	for i = 1, MAX_WORLDSTATE_SCORE_BUTTONS do
		local index = (FauxScrollFrame_GetOffset(WorldStateScoreScrollFrame) or 0) + i
		local name, _, _, _, _, faction, _, _, classToken = GetBattlefieldScore(index)
		if (name ~= UnitName("player")) and classToken and RAID_CLASS_COLORS[classToken] and _G["WorldStateScoreButton"..i.."NameText"] then
			_G["WorldStateScoreButton"..i.."NameText"]:SetTextColor(RAID_CLASS_COLORS[classToken].r, RAID_CLASS_COLORS[classToken].g, RAID_CLASS_COLORS[classToken].b)
			local playerName = _G["WorldStateScoreButton"..i.."NameText"]:GetText()
			if playerName then
				local _, _, playerName, playerServer = string.find(playerName, "([^%-]+)%-(.+)")
				if playerServer and playerName then
					if faction == 0 then
						if isArena then --green team
							_G["WorldStateScoreButton"..i.."NameText"]:SetText(playerName.."|cffffffff-|r|cff19ff19"..playerServer.."|r")
						else --horde
							_G["WorldStateScoreButton"..i.."NameText"]:SetText(playerName.."|cffffffff-|r|cffff1919"..playerServer.."|r")
						end
					else
						if isArena then --golden team
							_G["WorldStateScoreButton"..i.."NameText"]:SetText(playerName.."|cffffffff-|r|cffffd100"..playerServer.."|r")
						else --alliance
							_G["WorldStateScoreButton"..i.."NameText"]:SetText(playerName.."|cffffffff-|r|cff00adf0"..playerServer.."|r")
						end
					end
				end
			end
		end
	end
end)
--]]
