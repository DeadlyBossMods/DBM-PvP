local mod	= DBM:NewMod("z566", "DBM-PvP", 2)
local L		= mod:GetLocalizedStrings()

mod:SetRevision("@file-date-integer@")
mod:SetZone(DBM_DISABLE_ZONE_DETECTION)

mod:RegisterEvents(
	"ZONE_CHANGED_NEW_AREA"
)

local flagTimer = mod:NewTimer(7, "TimerFlag", "132483")

do
	local bgzone = false

	function mod:OnInitialize()
		if DBM:GetCurrentArea() == 566 or DBM:GetCurrentArea() == 968 then
			bgzone = true
			DBM:GetModByName("Battlegrounds"):SubscribeAssault(
				397,
				{},
				{0.01, 1, 2, 5, 10}
			)
			-- TODO: 566 standard, 968 rated
		elseif bgzone then
			bgzone = false
		end
	end

	function mod:ZONE_CHANGED_NEW_AREA()
		self:ScheduleMethod(1, "OnInitialize")
	end
end

do
	function mod:CHAT_MSG_BG_SYSTEM_ALLIANCE(arg1)
		if self.Options.ShowPointFrame then
			if arg1:match(L.FlagTaken) then
				local name = arg1:match(L.FlagTaken)
				if name then
					self.AllyFlag = name
					self.HordeFlag = nil
					self:UpdateFlagDisplay()
				end

			elseif arg1:match(L.FlagDropped) then
				self.AllyFlag = nil
				self.HordeFlag = nil
				self:UpdateFlagDisplay()

			elseif arg1:match(L.FlagCaptured) then
				flagTimer:Start()
				self.AllyFlag = nil
				self.HordeFlag = nil
				self:UpdateFlagDisplay()
			end
		end
	end

	function mod:CHAT_MSG_BG_SYSTEM_HORDE(arg1)
		if self.Options.ShowPointFrame then
			if arg1:match(L.FlagTaken) then
				local name = arg1:match(L.FlagTaken)
				if name then
					self.AllyFlag = nil
					self.HordeFlag = name
					self:UpdateFlagDisplay()
				end
			elseif arg1:match(L.FlagDropped) then
				self.AllyFlag = nil
				self.HordeFlag = nil
				self:UpdateFlagDisplay()
			elseif arg1:match(L.FlagCaptured) then
				flagTimer:Start()
				self.AllyFlag = nil
				self.HordeFlag = nil
				self:UpdateFlagDisplay()
			end
		end
	end

	function mod:CHAT_MSG_BG_SYSTEM_NEUTRAL(arg1)
		if arg1:match(L.FlagReset) then
			self.AllyFlag = nil
			self.HordeFlag = nil
			self:UpdateFlagDisplay()
		end
	end
end

function mod:UpdateFlagDisplay()
	if self.ScoreFrame1Text and self.ScoreFrame2Text then
		local newText
		local oldText = self.ScoreFrame1Text:GetText()
		local flagName = L.Flag or "Flag"
		if self.AllyFlag then
			if not oldText or oldText == "" then
				newText = "Flag: "..self.AllyFlag
			else
				newText = oldText:gsub("%((%d+)%).*", "%(%1%)  "..flagName..": "..self.AllyFlag)
			end
		elseif oldText and oldText ~= "" then
			newText = oldText:gsub("%((%d+)%).*", "%(%1%)")
		end
		self.ScoreFrame1Text:SetText(newText)
		newText = nil
		oldText = self.ScoreFrame2Text:GetText()
		if self.HordeFlag then
			if not oldText or oldText == "" then
				newText = "Flag: "..self.HordeFlag
			else
				newText = oldText:gsub("%((%d+)%).*", "%(%1%)  "..flagName..": "..self.HordeFlag)
			end
		elseif oldText and oldText ~= "" then
			newText = oldText:gsub("%((%d+)%).*", "%(%1%)")
		end
		self.ScoreFrame2Text:SetText(newText)
	end
end