local mod	= DBM:NewMod("z30", "DBM-PvP")
local L		= mod:GetLocalizedStrings()

mod:SetRevision("@file-date-integer@")
mod:SetZone(DBM_DISABLE_ZONE_DETECTION)
mod:RegisterEvents(
	"LOADING_SCREEN_DISABLED",
	"ZONE_CHANGED_NEW_AREA",
	"PLAYER_ENTERING_WORLD"
)

-- Hands in the battleground's item quests; only tested on Forever.
-- [questID] = {itemID, count}; IDs from QuestieDB (Forever), counts from Classic
local turnIn = DBM:IsForever() and mod:NewQuestTurnIn({
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
})

do
	local bgzone = false

	function mod:Init()
		local zoneID = DBM:GetCurrentArea()
		if not bgzone and (zoneID == 30 or zoneID == 2197) then -- Regular AV (retail and classic), Korrak
			bgzone = true
			self:RegisterShortTermEvents("CHAT_MSG_MONSTER_YELL")
			if turnIn then
				turnIn:Enable()
			end
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
			if turnIn then
				turnIn:Disable()
			end
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
