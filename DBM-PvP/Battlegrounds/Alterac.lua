local mod	= DBM:NewMod("z30", "DBM-PvP")
local L		= mod:GetLocalizedStrings()

mod:SetRevision("@file-date-integer@")
mod:SetZone(DBM_DISABLE_ZONE_DETECTION)
mod:RegisterEvents(
	"LOADING_SCREEN_DISABLED",
	"ZONE_CHANGED_NEW_AREA",
	"PLAYER_ENTERING_WORLD"
)

-- Quest turn-ins are only tested on Forever
local isForever = DBM:IsForever()

do
	local bgzone = false

	if isForever then
		-- Handing in quest items counts as a gossip action, so DBM's global auto gossip switch applies too
		mod:AddGossipOption(true, "Action")
	end

	function mod:RegisterBattlegroundEvents()
		self:RegisterShortTermEvents("CHAT_MSG_MONSTER_YELL")
		if isForever then
			-- Only inside the battleground; the handlers check the option, so toggling it takes effect at once
			self:RegisterShortTermEvents(
				"GOSSIP_SHOW",
				"QUEST_GREETING",
				"QUEST_DETAIL",
				"QUEST_PROGRESS",
				"QUEST_COMPLETE"
			)
		end
	end

	function mod:Init()
		local zoneID = DBM:GetCurrentArea()
		if not bgzone and (zoneID == 30 or zoneID == 2197) then -- Regular AV (retail and classic), Korrak
			bgzone = true
			self:RegisterBattlegroundEvents()
			local assaultID
			if zoneID == 30 then
				assaultID = not DBM:IsRetail() and 1459 or 91
			elseif zoneID == 2197 then
				assaultID = 1537
			end
			local generalMod = DBM:GetModByName("PvPGeneral")
			generalMod:SubscribeAssault(assaultID, 0)
			if not self.tracker then
				self.tracker = generalMod:NewHealthTracker()
				self.tracker:TrackHealth(11948, "AllianceBoss", BLUE_FONT_COLOR)
				self.tracker:TrackHealth(11949, "Balinda", BLUE_FONT_COLOR)
				self.tracker:TrackHealth(13419, "Ivus", BLUE_FONT_COLOR)
				self.tracker:TrackHealth(11946, "HordeBoss", RED_FONT_COLOR)
				self.tracker:TrackHealth(11947, "Galvangar", RED_FONT_COLOR)
				self.tracker:TrackHealth(13256, "Lokholar", RED_FONT_COLOR)
			end
		elseif bgzone and (zoneID ~= 30 and zoneID ~= 2197) then
			bgzone = false
			self:UnregisterShortTermEvents()
			self:Stop()
			if self.tracker then
				self.tracker:Cancel()
				self.tracker = nil
			end
		end
	end

	function mod:LOADING_SCREEN_DISABLED()
		self:ScheduleMethod(1, "Init")
	end
	mod.ZONE_CHANGED_NEW_AREA	= mod.LOADING_SCREEN_DISABLED
	mod.PLAYER_ENTERING_WORLD	= mod.LOADING_SCREEN_DISABLED
	mod.OnInitialize			= mod.LOADING_SCREEN_DISABLED
end

-- Hands in the battleground's item quests, using the same APIs as Questie's auto turn-in.
-- Quests are matched by ID, not by NPC: NPC GUIDs can be secret during a match.
do
	local ipairs, GetItemCount, GetQuestID = ipairs, C_Item and C_Item.GetItemCount or GetItemCount, GetQuestID
	local GetActiveQuests, GetAvailableQuests = C_GossipInfo.GetActiveQuests, C_GossipInfo.GetAvailableQuests
	local SelectGossipActiveQuest, SelectGossipAvailableQuest = C_GossipInfo.SelectActiveQuest, C_GossipInfo.SelectAvailableQuest
	-- The quest greeting selectors take the list position; the annotations (vscode-wow-api 0.22.3) are missing it
	---@type fun(index: number)
	local SelectActiveQuest = SelectActiveQuest
	---@type fun(index: number)
	local SelectAvailableQuest = SelectAvailableQuest

	-- [questID] = {itemID, count}; IDs from QuestieDB (Forever), counts from Classic
	local turnIns = {
		-- Alliance
		[7386] = {17423, 5},  -- Crystal Cluster: Storm Crystal (Archdruid Renferal)
		[6881] = {17423, 1},  -- Ivus the Forest Lord: Storm Crystal (Archdruid Renferal)
		[7223] = {17422, 20}, -- Armor Scraps (Murgot Deepforge)
		[6781] = {17422, 20}, -- More Armor Scraps (Murgot Deepforge)
		[6942] = {17502, 1},  -- Call of Air - Slidore's Fleet: Frostwolf Soldier's Medal
		[6941] = {17503, 1},  -- Call of Air - Vipore's Fleet: Frostwolf Lieutenant's Medal
		[6943] = {17504, 1},  -- Call of Air - Ichman's Fleet: Frostwolf Commander's Medal
		[7026] = {17643, 1},  -- Ram Riding Harnesses: Frostwolf Hide
		-- Horde
		[7385] = {17306, 5},  -- A Gallon of Blood: Stormpike Soldier's Blood (Primalist Thurloga)
		[6801] = {17306, 1},  -- Lokholar the Ice Lord: Stormpike Soldier's Blood (Primalist Thurloga)
		[7224] = {17422, 20}, -- Enemy Booty: Armor Scraps (Smith Regzar)
		[6741] = {17422, 20}, -- More Booty!: Armor Scraps (Smith Regzar)
		[6825] = {17326, 1},  -- Call of Air - Guse's Fleet: Stormpike Soldier's Flesh
		[6826] = {17327, 1},  -- Call of Air - Jeztor's Fleet: Stormpike Lieutenant's Flesh
		[6827] = {17328, 1},  -- Call of Air - Mulverick's Fleet: Stormpike Commander's Flesh
		[7002] = {17642, 1},  -- Ram Hide Harnesses: Alterac Ram Hide
	}

	---@param questID number?
	local function isTurnIn(questID)
		return questID and not DBM:issecretvalue(questID) and turnIns[questID] ~= nil
	end

	---@param questID number?
	local function haveItems(questID)
		local turnIn = isTurnIn(questID) and turnIns[questID]
		return turnIn and GetItemCount(turnIn[1]) >= turnIn[2]
	end

	-- Of several quests we have the items for, prefer the one taking the most (5 crystals over 1)
	local function bestAvailable(count, getQuestID)
		local best, bestCount
		for i = 1, count do
			local questID = getQuestID(i)
			if haveItems(questID) and (not bestCount or turnIns[questID][2] > bestCount) then
				best, bestCount = i, turnIns[questID][2]
			end
		end
		return best
	end

	local function skip(self)
		-- Shift (like Questie's default modifier) or DBM's global gossip opt-out keep the dialog manual
		return not self.Options.AutoGossipAction or DBM.Options.DontAutoGossip or IsShiftKeyDown()
	end

	function mod:GOSSIP_SHOW()
		if skip(self) then return end
		for _, quest in ipairs(GetActiveQuests()) do
			if quest.isComplete and isTurnIn(quest.questID) then
				SelectGossipActiveQuest(quest.questID)
				return
			end
		end
		local available = GetAvailableQuests()
		local index = bestAvailable(#available, function(i) return available[i].questID end)
		if index then
			SelectGossipAvailableQuest(available[index].questID)
		end
	end

	-- NPCs without gossip open the quest greeting instead
	function mod:QUEST_GREETING()
		if skip(self) then return end
		for i = 1, GetNumActiveQuests() do
			local _, isComplete = GetActiveTitle(i)
			if isComplete and isTurnIn(GetActiveQuestID(i)) then
				SelectActiveQuest(i)
				return
			end
		end
		-- Forever has the quest ID in position 5 (see Questie's QuestieCompat.GetQuestGreetingQuestID)
		local index = bestAvailable(GetNumAvailableQuests(), function(i) return (select(5, GetAvailableQuestInfo(i))) end)
		if index then
			SelectAvailableQuest(index)
		end
	end

	function mod:QUEST_DETAIL()
		if skip(self) then return end
		if haveItems(GetQuestID()) then
			AcceptQuest()
		end
	end

	function mod:QUEST_PROGRESS()
		if skip(self) then return end
		if isTurnIn(GetQuestID()) and IsQuestCompletable() then
			CompleteQuest()
		end
	end

	function mod:QUEST_COMPLETE()
		if skip(self) then return end
		if isTurnIn(GetQuestID()) and GetNumQuestChoices() <= 1 then
			GetQuestReward(1)
		end
	end
end

do
	local bossTimer	= mod:NewTimer(600, "TimerBoss")

	function mod:CHAT_MSG_MONSTER_YELL(msg, npc)
		local isAlly = msg == L.BossAlly or msg:match(L.BossAlly)
		if not isAlly and msg ~= L.BossHorde and not msg:match(L.BossHorde) then
			return
		end
		bossTimer:Start(nil, npc)
		if isAlly then
			bossTimer:SetColor({r=0, g=0, b=1})
			bossTimer:UpdateIcon("132486") -- Interface\\Icons\\INV_BannerPVP_02.blp
		else
			bossTimer:SetColor({r=1, g=0, b=0})
			bossTimer:UpdateIcon("132485") -- Interface\\Icons\\INV_BannerPVP_01.blp
		end
	end
end
