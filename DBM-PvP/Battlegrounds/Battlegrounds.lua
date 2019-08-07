local mod	= DBM:NewMod("Battlegrounds", "DBM-PvP", 2)
local L		= mod:GetLocalizedStrings()

local ipairs = ipairs
local IsInInstance, CreateFrame = IsInInstance, CreateFrame

mod:SetRevision("@file-date-integer@")
mod:SetZone(DBM_DISABLE_ZONE_DETECTION)

--mod:AddBoolOption("ColorByClass", true)
mod:AddBoolOption("ShowInviteTimer", true)
mod:AddBoolOption("ShowStartTimer", true)
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

	function mod:ZONE_CHANGED_NEW_AREA()
		local _, instanceType = IsInInstance()
		if instanceType == "pvp" then
			C_ChatInfo.SendAddonMessage("D4", "H", "INSTANCE_CHAT")
			self:Schedule(3, DBM.RequestTimers, DBM)
		end
		if self.Options.HideBossEmoteFrame then
			DBM:HideBlizzardEvents(instanceType == "pvp" and 1 or 0, true)
		end
		for i, v in ipairs(DBM:GetModByName("z30").timers) do v:Stop() end
		for i, v in ipairs(DBM:GetModByName("z2106").timers) do v:Stop() end
		for i, v in ipairs(DBM:GetModByName("z2107").timers) do v:Stop() end
		for i, v in ipairs(DBM:GetModByName("z566").timers) do v:Stop() end
		for i, v in ipairs(DBM:GetModByName("z628").timers) do v:Stop() end
		for i, v in ipairs(DBM:GetModByName("z726").timers) do v:Stop() end
		for i, v in ipairs(DBM:GetModByName("z727").timers) do v:Stop() end
		for i, v in ipairs(DBM:GetModByName("z761").timers) do v:Stop() end
		for i, v in ipairs(DBM:GetModByName("z998").timers) do v:Stop() end
		for i, v in ipairs(DBM:GetModByName("z1105").timers) do v:Stop() end
		DBM:GetModByName("z30"):Unschedule()
		DBM:GetModByName("z2106"):Unschedule()
		DBM:GetModByName("z2107"):Unschedule()
		DBM:GetModByName("z566"):Unschedule()
		DBM:GetModByName("z628"):Unschedule()
		DBM:GetModByName("z726"):Unschedule()
		DBM:GetModByName("z727"):Unschedule()
		DBM:GetModByName("z761"):Unschedule()
		DBM:GetModByName("z998"):Unschedule()
		DBM:GetModByName("z1105"):Unschedule()
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
	local remainingTimer = mod:NewTimer(0, "TimerRemaining", 2457)

	function mod:START_TIMER(_, timeSeconds)
		local _, instanceType = IsInInstance()
		if (instanceType == "pvp" or instanceType == "arena") and self.Options.ShowStartTimer then
			for _, bar in ipairs(TimerTracker.timerList) do
				bar.bar:Hide()
			end
			remainingTimer:SetTimer(timeSeconds)
			remainingTimer:Start()
		end
	end
end

do
	local format, tostring = format, tostring
	local GetBattlefieldStatus, GetBattlefieldPortExpiration, PVP_TEAMSIZE = GetBattlefieldStatus, GetBattlefieldPortExpiration, PVP_TEAMSIZE
	local inviteTimer = mod:NewTimer(60, "TimerInvite", "135986", nil, false)

	function mod:UPDATE_BATTLEFIELD_STATUS(queueID)
		if self.Options.ShowInviteTimer then
			local status, mapName, _, _, _, teamSize = GetBattlefieldStatus(queueID)
			if status == "confirm" then
				if size == "ARENASKIRMISH" then
					mapName = L.ArenaInvite .. " " .. format(PVP_TEAMSIZE, tostring(teamSize), tostring(teamSize))
				end
				local expiration = GetBattlefieldPortExpiration(queueID)
				if inviteTimer:GetTime(mapName) == 0 and expiration >= 3 then
					inviteTimer:Start(expiration, mapName)
				end
			elseif status == "none" then
				inviteTimer:Stop()
			end
		end
	end
end

-- Utility functions
local subscribedMapID = 0
local objectives, resPerSec

function mod:SubscribeAssault(mapID, objects, rezPerSec)
	mod:AddBoolOption("ShowEstimatedPoints", true, nil, function()
		if mod.Options.ShowGilneasEstimatedPoints and bgzone then
			mod:ShowEstimatedPoints()
		else
			mod:HideEstimatedPoints()
		end
	end)
	mod:AddBoolOption("ShowBasesToWin", false, nil, function()
		if mod.Options.ShowGilneasBasesToWin and bgzone then
			mod:ShowBasesToWin()
		else
			mod:HideBasesToWin()
		end
	end)
	if self.Options.ShowGilneasEstimatedPoints then
		self:ShowEstimatedPoints()
	end
	if self.Options.ShowGilneasBasesToWin then
		self:ShowBasesToWin()
	end
	self:RegisterShortTermEvents(
		"CHAT_MSG_BG_SYSTEM_HORDE",
		"CHAT_MSG_BG_SYSTEM_ALLIANCE",
		"CHAT_MSG_BG_SYSTEM_NEUTRAL"
	)
	subscribedMapID = mapID
	objectives = objects
	resPerSec = rezPerSec
end

function mod:UnsubscribeAssault()
	if self.Options.ShowGilneasEstimatedPoints then
		self:HideEstimatedPoints()
	end
	if self.Options.ShowGilneasBasesToWin then
		self:HideBasesToWin()
	end
	self:UnregisterShortTermEvents()
	subscribedMapID = 0
	objectives = nil
end

local get_gametime, update_gametime
do
	local gametime = 0
	function updateGametime()
		gametime = time()
	end
	function getGametime()
		local systime = GetBattlefieldInstanceRunTime()
		if systime > 0 then
			return systime / 1000
		else
			return time() - gametime
		end
	end
end

local winTimer = mod:NewTimer(30, "TimerWin", "134376")
local lastHordeScore, lastAllianceScore, lastHordeBases, lastAllianceBases = 0, 0, 0, 0

function mod:UpdateWinTimer()
	local allyTime = math.min(1500, (1500 - lastAllianceScore) / resPerSec[lastAllianceBases + 1])
	local hordeTime = math.min(1500, (1500 - lastHordeScore) / resPerSec[lastAllianceBases + 1])
	if allyTime == hordeTime then
		winTimer:Stop()
		if self.ScoreFrame1Text then
			self.ScoreFrame1Text:SetText("")
			self.ScoreFrame2Text:SetText("")
		end
	elseif allyTime > hordeTime then -- Horde wins
		if self.ScoreFrame1Text and self.ScoreFrame2Text then
			self.ScoreFrame1Text:SetText("(" .. math.floor(math.floor(((hordeTime * resPerSec[lastAllianceBases + 1]) + lastAllianceScore) / 10) * 10) .. ")")
			self.ScoreFrame2Text:SetText("(1500)")
		end
		winTimer:Update(getGametime(), getGametime() + hordeTime)
		winTimer:DisableEnlarge()
		winTimer:UpdateName(L.WinBarText:format(FACTION_HORDE))
		winTimer:SetColor(1, 0, 0)
		winTimer:UpdateIcon("Interface\\Icons\\INV_BannerPVP_01.blp")
	elseif hordeTime > allyTime then -- Alliance wins
		if self.ScoreFrame1Text and self.ScoreFrame2Text then
			self.ScoreFrame2Text:SetText("(" .. math.floor(math.floor(((allyTime * resPerSec[lastHordeBases + 1]) + lastHordeScore) / 10) * 10) .. ")")
			self.ScoreFrame1Text:SetText("(1500)")
		end
		winTimer:Update(getGametime(), getGametime() + allyTime)
		winTimer:DisableEnlarge()
		winTimer:UpdateName(L.WinBarText:format(FACTION_ALLIANCE))
		winTimer:SetColor(0, 0, 1)
		winTimer:UpdateIcon("Interface\\Icons\\INV_BannerPVP_02.blp")
	end
	if self.Options.ShowBasesToWin then
		local friendlyLast, enemyLast, friendlyBases, enemyBases
		if UnitFactionGroup("player") == "Alliance" then
			friendlyLast = lastAllianceScore
			enemyLast = lastHordeScore
			friendlyBases = lastAllianceBases
			enemyBases = lastHordeBases
		else
			friendlyLast = lastHordeScore
			enemyLast = lastAllianceScore
			friendlyBases = lastHordeBases
			enemyBases = lastAllianceBases
		end
		if (1500 - friendlyLast) / resPerSec[friendlyBases + 1] > (1500 - enemyLast) / resPerSec[enemyBases + 1] then
			local enemyTime, friendlyTime, baseLowest, enemyFinal, friendlyFinal
			for i = 1, 3 do
				enemyTime = (1500 - enemyLast) / resPerSec[3 - i]
				friendlyTime = (1500 - friendlyLast) / resPerSec[i]
				baseLowest = friendlyTime < enemyTime and friendlyTime or enemyTime
				enemyFinal = math.floor((enemyLast + math.floor(baseLowest * resPerSec[3] + 0.5)) / 10) * 10
				friendlyFinal = math.floor((friendlyLast + math.floor(baseLowest * resPerSec[i] + 0.5)) / 10) * 10
				if friendlyFinal >= 1500 and enemyFinal < 1500 then
					self.ScoreFrameToWinText:SetText(L.BasesToWin:format(i))
					break
				end
			end
		else
			self.ScoreFrameToWinText:SetText("")
		end
	end
end

do
	local pairs, ipairs, select, tonumber = pairs, ipairs, select, tonumber
	local C_AreaPoiInfo = C_AreaPoiInfo
	local winner_is = 0		-- 0 = nobody  1 = alliance  2 = horde
	local objectivesStore = {}
	local capTimer = mod:NewTimer(60, "TimerCap", "136002")

	local function getBasecount()
		local alliance, horde = 0, 0
		for k, v in pairs(objectivesStore) do
			if v == objectives[k] + 2 then
				alliance = alliance + 1
			elseif v == objectives[k] + 4 then
				horde = horde + 1
			end
		end
		return alliance, horde
	end

	local function getScore()
		-- TODO: GetWorldStateUIInfo is removed. Also need to update ID's
		local ally, horde = 2, 3
		for i = 1, 3 do
			if select(5, GetWorldStateUIInfo(i)) then
				if string.match(select(5, GetWorldStateUIInfo(i)), "Alliance") then
					ally = i
					horde = i + 1
					break
				end
			end
		end
		local allyScore	= tonumber(string.match((select(4, GetWorldStateUIInfo(ally)) or ""), L.ScoreExpr)) or 0
		local hordeScore = tonumber(string.match((select(4, GetWorldStateUIInfo(horde)) or ""), L.ScoreExpr)) or 0
		return allyScore, hordeScore
	end

	local function check_for_updates()
		if subscribedMapID == 0 then
			return
		end
		local allyScore, hordeScore = getScore()
		local allyBases, hordeBases = getBasecount()
		local callupdate = false
		if allyScore ~= lastAllianceScore then
			lastAllianceScore = allyScore
			if winner_is == 1 then
				callupdate = true
			end
		elseif hordeScore ~= lastHordeScore then
			lastHordeScore = hordeScore
			if winner_is == 2 then
				callupdate = true
			end
		end
		if lastAllianceBases ~= allyBases then
			lastAllianceBases = allyBases
			callupdate = true
		end
		if lastHordeBases ~= hordeBases then
			lastHordeBases = hordeBases
			callupdate = true
		end
		if callupdate or winner_is == 0 then
			self:UpdateWinTimer()
		end
		for _, areaPOIID in ipairs(C_AreaPoiInfo.GetAreaPOIForMap(subscribedMapID)) do
			local areaPOIInfo = C_AreaPoiInfo.GetAreaPOIInfo(subscribedMapID, areaPOIID)
			local infoName, infoTexture = areaPOIInfo.name, areaPOIInfo.textureIndex
			if name and textureIndex then
				local state, defaultState = objectivesStore[name], objectives[name]
				if state ~= textureIndex then
					capTimer:Stop(name)
					local isAllianceAssaulted = textureIndex == defaultState + 3
					if textureIndex == defaultState + 1 or isAllianceAssaulted then
						capTimer:Start(nil, name)
						if isAllianceAssaulted then
							capTimer:SetColor(0, 0, 1, name)
							capTimer:UpdateIcon("Interface\\Icons\\INV_BannerPVP_02.blp", name)
						else
							capTimer:SetColor(1, 0, 0, name)
							capTimer:UpdateIcon("Interface\\Icons\\INV_BannerPVP_01.blp", name)
						end
					end
					objectivesStore[name] = textureIndex
				end
			end
		end
	end

	local function schedule_check(self)
		self:Schedule(1, check_for_updates)
	end
	mod.CHAT_MSG_BG_SYSTEM_ALLIANCE = schedule_check
	mod.CHAT_MSG_BG_SYSTEM_HORDE = schedule_check
	mod.CHAT_MSG_BG_SYSTEM_NEUTRAL = schedule_check
end

function mod:ShowEstimatedPoints()
	if AlwaysUpFrame1 and AlwaysUpFrame2 then
		if not self.ScoreFrame1 then
			self.ScoreFrame1 = CreateFrame("Frame", nil, AlwaysUpFrame1)
			self.ScoreFrame1:SetHeight(10)
			self.ScoreFrame1:SetWidth(100)
			self.ScoreFrame1:SetPoint("LEFT", "AlwaysUpFrame1DynamicIconButton", "RIGHT", 4, 0)
			self.ScoreFrame1Text = self.ScoreFrame1:CreateFontString(nil, nil, "GameFontNormalSmall")
			self.ScoreFrame1Text:SetAllPoints(self.ScoreFrame1)
			self.ScoreFrame1Text:SetJustifyH("LEFT")
		end
		if not self.ScoreFrame2 then
			self.ScoreFrame2 = CreateFrame("Frame", nil, AlwaysUpFrame2)
			self.ScoreFrame2:SetHeight(10)
			self.ScoreFrame2:SetWidth(100)
			self.ScoreFrame2:SetPoint("LEFT", "AlwaysUpFrame2DynamicIconButton", "RIGHT", 4, 0)
			self.ScoreFrame2Text = self.ScoreFrame2:CreateFontString(nil, nil, "GameFontNormalSmall")
			self.ScoreFrame2Text:SetAllPoints(self.ScoreFrame2)
			self.ScoreFrame2Text:SetJustifyH("LEFT")
		end
		self.ScoreFrame1Text:SetText("")
		self.ScoreFrame1:Show()
		self.ScoreFrame2Text:SetText("")
		self.ScoreFrame2:Show()
	end
end

function mod:ShowBasesToWin()
	if not self.ScoreFrameToWin then
		self.ScoreFrameToWin = CreateFrame("Frame", nil, AlwaysUpFrame2)
		self.ScoreFrameToWin:SetHeight(10)
		self.ScoreFrameToWin:SetWidth(200)
		self.ScoreFrameToWin:SetPoint("TOPLEFT", "AlwaysUpFrame2", "BOTTOMLEFT", 22, 2)
		self.ScoreFrameToWinText = self.ScoreFrameToWin:CreateFontString(nil, nil, "GameFontNormalSmall")
		self.ScoreFrameToWinText:SetAllPoints(self.ScoreFrameToWin)
		self.ScoreFrameToWinText:SetJustifyH("LEFT")
	end
	self.ScoreFrameToWinText:SetText("")
	self.ScoreFrameToWin:Show()
end

function mod:HideEstimatedPoints()
	if self.ScoreFrame1 and self.ScoreFrame2 then
		self.ScoreFrame1:Hide()
		self.ScoreFrame2:Hide()
	end
end

function mod:HideBasesToWin()
	if self.ScoreFrameToWin then
		self.ScoreFrameToWin:Hide()
	end
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