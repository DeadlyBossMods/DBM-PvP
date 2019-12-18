local mod	= DBM:NewMod("z30", "DBM-PvP")

local pairs, ipairs, type, tonumber, select, math = pairs, ipairs, type, tonumber, select, math

mod:SetRevision("@file-date-integer@")
mod:SetZone(DBM_DISABLE_ZONE_DETECTION)

mod:AddBoolOption("AutoTurnIn")

mod:RegisterEvents(
	"ZONE_CHANGED_NEW_AREA"
)

local active_timers = {}
local uiMap

do
	local bgzone = false

	function mod:OnInitialize()
		if DBM:GetCurrentArea() == 30 or DBM:GetCurrentArea() == 2197 then--Regular AV (retail and classic), Korrak
			bgzone = true
			uiMap = C_Map.GetBestMapForUnit("player")
			self:RegisterShortTermEvents(
				"GOSSIP_SHOW",
				"QUEST_PROGRESS",
				"QUEST_COMPLETE",
				"AREA_POIS_UPDATED"
			)
		elseif bgzone then
			bgzone = false
			uiMap = nil
			self:UnregisterShortTermEvents()
			for i, timer in pairs(active_timers) do
				timer:Stop()
				active_timers[i] = nil
			end
		end
	end

	function mod:ZONE_CHANGED_NEW_AREA()
		self:ScheduleMethod(1, "OnInitialize")
	end
end

local quests = {
	[13442] = {
		{7386, 17423, 5},
		{6881, 17423},
	},
	[13236] = {
		{7385, 17306, 5},
		{6801, 17306},
	},
	[13257] = {6781, 17422, 20},
	[13176] = {6741, 17422, 20},
	[13577] = {7026, 17643},
	[13179] = {6825, 17326},
	[13438] = {6942, 17502},
	[13180] = {6826, 17327},
	[13181] = {6827, 17328},
	[13439] = {6941, 17503},
	[13437] = {6943, 17504},
	[13441] = {7002, 17642},
}

do
	if WOW_PROJECT_ID ~= WOW_PROJECT_CLASSIC then
		local tooltip = CreateFrame("GameTooltip", "DBM-PvP_Tooltip")
		tooltip:SetOwner(UIParent, "ANCHOR_NONE")
		tooltip:AddFontStrings(tooltip:CreateFontString("$parentText", nil, "GameTooltipText"), tooltip:CreateFontString("$parentTextRight", nil, "GameTooltipText"))

		local function getQuestName(id)
			tooltip:ClearLines()
			tooltip:SetHyperlink("quest:"..id)--Quest tooltip type doesn't exist until Wrath
			return _G[tooltip:GetName().."Text"]:GetText()
		end

		for _, v in pairs(quests) do
			if type(v[1]) == "table" then
				for _, v in ipairs(v) do
					v[1] = getQuestName(v[1]) or v[1]
				end
			else
				v[1] = getQuestName(v[1]) or v[1]
			end
		end
	end
end

do
	local UnitGUID, GetTitleText, CompleteQuest, GetQuestReward, GetGossipAvailableQuests, SelectGossipAvailableQuest, GetContainerNumSlots, GetContainerItemLink, GetContainerItemInfo, NUM_BAG_SLOTS = UnitGUID, GetTitleText, CompleteQuest, GetQuestReward, GetGossipAvailableQuests, SelectGossipAvailableQuest, GetContainerNumSlots, GetContainerItemLink, GetContainerItemInfo, NUM_BAG_SLOTS

	local function isQuestAutoTurnInQuest(name)
		for _, v in pairs(quests) do
			if type(v[1]) == "table" then
				for _, v in ipairs(v) do
					if v[1] == name then
						return true
					end
				end
			elseif v[1] == name then
				return true
			end
		end
	end

	local function acceptQuestByName(name)
		for i = 1, select("#", GetGossipAvailableQuests()), 5 do
			if select(i, GetGossipAvailableQuests()) == name then
				SelectGossipAvailableQuest(math.ceil(i / 5))
				break
			end
		end
	end

	local function checkItems(item, amount)
		local found = 0
		for bag = 0, NUM_BAG_SLOTS do
			for i = 1, GetContainerNumSlots(bag) do
				if tonumber((GetContainerItemLink(bag, i) or ""):match(":(%d+):") or 0) == item then
					found = found + select(2, GetContainerItemInfo(bag, i))
				end
			end
		end
		return found >= amount
	end

	function mod:GOSSIP_SHOW()
		if not self.Options.AutoTurnIn then
			return
		end
		local quest = quests[self:GetCIDFromGUID(UnitGUID("target") or "") or 0]
		if quest and type(quest[1]) == "table" then
			for _, v in ipairs(quest) do
				if checkItems(v[2], v[3] or 1) then
					acceptQuestByName(v[1])
					break
				end
			end
		elseif quest then
			if checkItems(quest[2], quest[3] or 1) then
				acceptQuestByName(quest[1])
			end
		end
	end

	function mod:QUEST_PROGRESS()
		if isQuestAutoTurnInQuest(GetTitleText()) then
			CompleteQuest()
		end
	end

	function mod:QUEST_COMPLETE()
		if isQuestAutoTurnInQuest(GetTitleText()) then
			GetQuestReward(0)
		end
	end
end

do
	-- the classic AV timer is 300 seconds or 5 minutes, may as well use this table for that too
	-- /script for i, x in pairs(C_AreaPoiInfo.GetAreaPOIForMap(1537)) do local a = C_AreaPoiInfo.GetAreaPOIInfo(1537, x); print(tostring(x)..':'..tostring(a.name)..'|'..tostring(a.atlasName or a.textureIndex)) end
	local CAP_MAPS = {
		-- AV in classic
		[1459] = {
			["Alliance"] = {
				-- [1] = 300,-- control mine ally
				[3] = 300,-- capping gy ally
				[8] = 300,-- capping tower ally
				-- [10] = 300,-- control tower ally
				-- [14] = 300,-- control gy ally
			},
			["Horde"] = {
				-- [2] = 300,-- control mine horde
				-- [9] = 300,-- control tower horde
				[11] = 300,-- capping tower horde
				-- [12] = 300,-- control gy horde
				[13] = 300,-- capping gy horde
			},
			-- [0] = 300,-- control mine npc
			-- [5] = 300,-- destroyed tower (ally & horde)
			-- [4] = 300,-- ?
			-- [6] = 300,-- ?
			-- [7] = 300,-- ?
		},
		-- Korrak in retail
		[1537] = {
			["Alliance"] = {
				[9] = 240,-- capping tower
				[4] = 240,-- capping gy
			},
			['Horde'] = {
				[12] = 240,-- capping tower
				[14] = 240,-- capping gy
			},
		},
		-- AV in retail
		-- [??] = {},
	}

	-- create a mapping for all for the above tables
	for i, x in pairs(CAP_MAPS) do
		local all_table = {}
		x['All'] = all_table
		for j, y in pairs(x) do
			if j == "Alliance" or j == 'Horde' then
				for state, duration in pairs(y) do
					all_table[state] = duration
				end
			end
		end
	end

	function mod:AREA_POIS_UPDATED(widget)
		DBM:Debug("dbmpvp: AREA_POIS_UPDATED "..tostring(widget), 2)
		if CAP_MAPS[uiMap] == nil then
			return
		end

		local CAPPING_INDEXES = CAP_MAPS[uiMap]["All"]
		local ALLY_CAPPING_INDEXES = CAP_MAPS[uiMap]["Alliance"]

		for i, x in pairs(C_AreaPoiInfo.GetAreaPOIForMap(uiMap)) do
			local poi = C_AreaPoiInfo.GetAreaPOIInfo(uiMap, x)
			local name = poi.name
			if CAPPING_INDEXES[poi.textureIndex] and active_timers[name] == nil then
				DBM:Debug("dbmpvp: apcre "..tostring(name)..", "..tostring(poi.textureIndex), 2)
				local is_alliance = ALLY_CAPPING_INDEXES[poi.textureIndex] and true
				local timeLeft = (
					-- GetAreaPOISecondsLeft doesn't work in retail?
					-- Classic never got GetAreaPOISecondsLeft, it still uses GetAreaPOITimeLeft which retail deprecated
					C_AreaPoiInfo.GetAreaPOISecondsLeft and C_AreaPoiInfo.GetAreaPOISecondsLeft(x)
					or C_AreaPoiInfo.GetAreaPOITimeLeft and C_AreaPoiInfo.GetAreaPOITimeLeft(x) and C_AreaPoiInfo.GetAreaPOITimeLeft(x)/60
					or CAPPING_INDEXES[poi.textureIndex]
				)
				local timer = mod:NewTimer(
					timeLeft,
					name,
					is_alliance and "132486" or "132485"
				)
				timer.keep = true
				timer:Start()
				active_timers[name] = timer
			elseif not CAPPING_INDEXES[poi.textureIndex] and active_timers[name] ~= nil then
				DBM:Debug("dbmpvp: apdel "..tostring(name)..", "..tostring(poi.textureIndex), 2)
				active_timers[name]:Stop()
				active_timers[name] = nil
			end
		end

	end
end
