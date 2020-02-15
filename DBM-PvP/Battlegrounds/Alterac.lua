local mod	= DBM:NewMod("z30", "DBM-PvP")

local pairs, ipairs, type, tonumber, select, math = pairs, ipairs, type, tonumber, select, math

mod:SetRevision("@file-date-integer@")
mod:SetZone(DBM_DISABLE_ZONE_DETECTION)

mod:AddBoolOption("AutoTurnIn")

mod:RegisterEvents(
	"ZONE_CHANGED_NEW_AREA"
)

local active_states = {}
local uiMap
local poiTimer = mod:NewTimer(300, 'TimerCap')
poiTimer.keep = true

do
	local bgzone = false

	function mod:OnInitialize()
		if DBM:GetCurrentArea() == 30 or DBM:GetCurrentArea() == 2197 then--Regular AV (retail and classic), Korrak
			-- mapID: 30 and 91 or 1537 -- Regular AV (retail and classic), Korrak
			bgzone = true
			uiMap = C_Map.GetBestMapForUnit("player")
			self:RegisterShortTermEvents(
				"GOSSIP_SHOW",
				"QUEST_PROGRESS",
				"QUEST_COMPLETE",
				"AREA_POIS_UPDATED"
			)
			self:ScheduleMethod(1, "AREA_POIS_UPDATED")
		elseif bgzone then
			bgzone = false
			uiMap = nil
			self:UnregisterShortTermEvents()
			poiTimer:Stop()
			active_states = {}
		end
	end

	function mod:ZONE_CHANGED_NEW_AREA()
		self:ScheduleMethod(1, "OnInitialize")
	end
end

local quests = {
	[13442] = { -- Archdruid Renferal [A]
		{17423, 5}, -- Storm Crystal
		{17423, 1}, -- Storm Crystal
	},
	[13257] = {17422, 20}, -- Murgot Deepforge / Armor Scraps[A]
	[13438] = {17502, 1}, -- Wing Commander Slidore / Frostwolf Soldier's Medal [A]
	[13439] = {17503, 1}, -- Wing Commander Vipore / Frostwolf Lieutenant's Medal [A]
	[13437] = {17504, 1}, -- Wing Commander Ichman / Frostwolf Commander's Medal [A]
	[13577] = {17643, 1}, -- Stormpike Ram Rider Commander / Frostwolf Hide [A]
	[13236] = { -- Primalist Thurloga [H]
		{17306, 5}, -- Stormpike Soldier's Blood
		{17306, 1}, -- Stormpike Soldier's Blood
	},
	[13176] = {17422, 20}, -- Smith Regzar / Armor Scraps [H]
	[13179] = {17326, 1}, -- Wing Commander Guse / Stormpike Soldier's Flesh [H]
	[13180] = {17327, 1}, -- Wing Commander Jeztor / Stormpike Lieutenant's Flesh [H]
	[13181] = {17328, 1}, -- Wing Commander Mulverick / Stormpike Commander's Flesh [H]
	[13441] = {17642, 1}, -- Frostwolf Wolf Rider Commander / Alterac Ram Hide [H]
}

do
	local UnitGUID, GetItemCount, GetNumGossipActiveQuests, SelectGossipActiveQuest, SelectGossipAvailableQuest, IsQuestCompletable, CompleteQuest, GetQuestReward = UnitGUID, GetItemCount, GetNumGossipActiveQuests, SelectGossipActiveQuest, SelectGossipAvailableQuest, IsQuestCompletable, CompleteQuest, GetQuestReward

	function mod:GOSSIP_SHOW()
		if not self.Options.AutoTurnIn then
			return
		end
		local quest = quests[self:GetCIDFromGUID(UnitGUID("target") or "") or 0]
		if quest and type(quest[1]) == "table" then
			for _, v in ipairs(quest) do
				local num = GetItemCount(v[1])
				if num > 0 then
					if GetNumGossipActiveQuests() == 1 then
						SelectGossipActiveQuest(1)
					else
						SelectGossipAvailableQuest((v[2] == 5 and num >= 5) and 2 or 1)
					end
					break
				end
			end
		elseif quest then
			if GetItemCount(quest[1]) > quest[2] then
				SelectGossipAvailableQuest(1)
			end
		end
	end

	function mod:QUEST_PROGRESS()
		self:GOSSIP_SHOW()
		if IsQuestCompletable() then
			CompleteQuest()
		end
	end

	function mod:QUEST_COMPLETE()
		GetQuestReward(0)
	end
end

do
	-- the classic AV timer is 300 seconds or 5 minutes, may as well use this table for that too
	-- /script for i, x in pairs(C_AreaPoiInfo.GetAreaPOIForMap(1537)) do local a = C_AreaPoiInfo.GetAreaPOIInfo(1537, x); print(tostring(x)..':'..tostring(a.name)..'|'..tostring(a.atlasName or a.textureIndex)) end
	local CAP_MAPS = {
		-- AV in classic
		[1459] = {
			["Alliance"] = {
				-- [1] = 304,-- control mine ally
				[3] = 304,-- capping gy ally
				[8] = 304,-- capping tower ally
				-- [10] = 304,-- control tower ally
				-- [14] = 304,-- control gy ally
			},
			["Horde"] = {
				-- [2] = 304,-- control mine horde
				-- [9] = 304,-- control tower horde
				[11] = 304,-- capping tower horde
				-- [12] = 304,-- control gy horde
				[13] = 304,-- capping gy horde
			},
			-- [0] = 304,-- control mine npc
			-- [5] = 304,-- destroyed tower (ally & horde)
			-- [4] = 304,-- ?
			-- [6] = 304,-- ?
			-- [7] = 304,-- ?
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

		for i, areaPoiID in pairs(C_AreaPoiInfo.GetAreaPOIForMap(uiMap)) do
			local poi = C_AreaPoiInfo.GetAreaPOIInfo(uiMap, areaPoiID)
			local name = poi.name
			local state = poi.textureIndex

			if CAPPING_INDEXES[state] and active_states[name] ~= state then
				DBM:Debug("dbmpvp: apcre "..tostring(name)..", "..tostring(state), 2)
				local is_alliance = ALLY_CAPPING_INDEXES[state] and true
				local timeLeft = (
					-- GetAreaPOISecondsLeft doesn't work in retail?
					-- Classic never got GetAreaPOISecondsLeft, it still uses GetAreaPOITimeLeft which retail deprecated
					C_AreaPoiInfo.GetAreaPOISecondsLeft and C_AreaPoiInfo.GetAreaPOISecondsLeft(areaPoiID)
					or C_AreaPoiInfo.GetAreaPOITimeLeft and C_AreaPoiInfo.GetAreaPOITimeLeft(areaPoiID) and C_AreaPoiInfo.GetAreaPOITimeLeft(areaPoiID) * 60
					or CAPPING_INDEXES[state]
				)
				local bar = poiTimer:Start(
					timeLeft,
					name
				)
				bar:SetText(name)
				bar:SetIcon(is_alliance and "132486" or "132485")
				active_states[name] = state
			elseif not CAPPING_INDEXES[state] and active_states[name] ~= nil then
				DBM:Debug("dbmpvp: apdel "..tostring(name)..", "..tostring(state), 2)
				active_states[name] = nil
				poiTimer:Stop(name)
			end
		end
	end
end
