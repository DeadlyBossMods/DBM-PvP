local mod	= DBM:NewMod("Battlegrounds", "DBM-PvP", 2)
local L		= mod:GetLocalizedStrings()

local format, ipairs, tostring = format, ipairs, tostring
local IsInInstance, HasSoulstone, GetBattlefieldStatus, GetBattlefieldPortExpiration, PVP_TEAMSIZE, C_ChatInfo = IsInInstance, HasSoulstone, GetBattlefieldStatus, GetBattlefieldPortExpiration, PVP_TEAMSIZE, C_ChatInfo

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

local inviteTimer		= mod:NewTimer(60, "TimerInvite", "Interface\\Icons\\Spell_Holy_WeaponMastery", nil, false)
local remainingTimer	= mod:NewTimer(0, "TimerRemaining", 2457)

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

function mod:PLAYER_DEAD()
	local _, instanceType = IsInInstance()
	if instanceType == "pvp" and not HasSoulstone() and self.Options.AutoSpirit then
		RepopMe()
	end
end

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

function mod:UPDATE_BATTLEFIELD_STATUS(queueID)
	if self.Options.ShowInviteTimer then
		local status, mapName, _, _, _, teamSize = GetBattlefieldStatus(queueID)
		if status == "confirm"
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