local mod	= DBM:NewMod("z30", "DBM-PvP")

local pairs, ipairs, type, tonumber, select, math = pairs, ipairs, type, tonumber, select, math

mod:SetRevision("@file-date-integer@")
mod:SetZone(DBM_DISABLE_ZONE_DETECTION)

mod:AddBoolOption("AutoTurnIn")

mod:RegisterEvents(
	"ZONE_CHANGED_NEW_AREA"
)

do
	local bgzone = false

	function mod:OnInitialize()
		local zoneID = DBM:GetCurrentArea()
		if zoneID == 30 or zoneID == 2197 then--Regular AV (retail and classic), Korrak
			bgzone = true
			uiMap = C_Map.GetBestMapForUnit("player")
			self:RegisterShortTermEvents(
				"GOSSIP_SHOW",
				"QUEST_PROGRESS",
				"QUEST_COMPLETE"
			)
			self:ScheduleMethod(1, "AREA_POIS_UPDATED")
			local assaultID
			if zoneID == 30 then
				assaultID = WOW_PROJECT_ID == WOW_PROJECT_CLASSIC and 30 or 91
			elseif zoneID == 2197 then
				assaultID = 1537
			end
			local graveyards = WOW_PROJECT_ID == WOW_PROJECT_CLASSIC and {3, 14, 13, 12} or {4, 15, 14, 13}
			local towers = WOW_PROJECT_ID == WOW_PROJECT_CLASSIC and {8, 10, 11, 9} or {9, 11, 12, 10}
			DBM:GetModByName("PvPGeneral"):SubscribeAssault(
				assaultID,
				{
					-- Graveyards
					["Frostwolf Relief Hut"]	= graveyards,
					["Stonehearth Graveyard"]	= graveyards,
					["Frostwolf Graveyard"]		= graveyards,
					["Iceblood Graveyard"]		= graveyards,
					["Snowfall Graveyard"]		= graveyards,
					["Stormpike Aid Station"]	= graveyards,
					["Stormpike Graveyard"]		= graveyards,
					-- Horde Towers
					["East Frostwolf Tower"]	= towers,
					["West Frostwolf Tower"]	= towers,
					["Tower Point"]				= towers,
					["Iceblood Tower"]			= towers,
					-- Alliance towers
					["Stonehearth Bunker"]		= towers,
					["Icewing Bunker"]			= towers,
					["Dun Baldar North Bunker"]	= towers,
					["Dun Baldar South Bunker"]	= towers,
					-- Mines (There's no capping state, just own)
					--["Irondeep Mine"]			= {nil, 3, nil, 2}, -- Classic {nil, 2, nil, 1}
					--["Coldtooth Mine"]		= {nil, 3, nil, 2}, -- Classic {nil, 2, nil, 1}
				}
			)
		elseif bgzone then
			bgzone = false
			self:UnregisterShortTermEvents()
		end
	end

	function mod:ZONE_CHANGED_NEW_AREA()
		self:ScheduleMethod(1, "OnInitialize")
	end
end

do
	local UnitGUID, GetItemCount, GetNumGossipActiveQuests, SelectGossipActiveQuest, SelectGossipAvailableQuest, IsQuestCompletable, CompleteQuest, GetQuestReward = UnitGUID, GetItemCount, GetNumGossipActiveQuests, SelectGossipActiveQuest, SelectGossipAvailableQuest, IsQuestCompletable, CompleteQuest, GetQuestReward

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
