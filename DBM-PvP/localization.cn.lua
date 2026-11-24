-- 泰坦重铸时光服-时光2-法师-旺仔芒果/椰奶冻-2026.11.13--
if GetLocale() ~= "zhCN" then return end
local L
--------------------------
--  General BG Options  --
--------------------------
L = DBM:GetModLocalization("PvPGeneral")

L:SetGeneralLocalization({
	name	= "常规设置"
})

L:SetTimerLocalization({
	TimerCap		= "%s",
	TimerFlag		= "旗帜重置",
	TimerInvite		= "%s",
	TimerWin		= "胜利时间",
	TimerStart		= "开始时间",
	TimerRemaining	= "剩余时间: ",
	TimerShadow		= "暗影之眼"
})

L:SetOptionLocalization({
	AutoSpirit			= "自动释放灵魂",
	ColorByClass		= "得分板上玩家按职业着色",
	HideBossEmoteFrame	= "在战场时隐藏团队首领表情框体/公会信息等",
	ShowBasesToWin		= "显示获胜需要占领的资源点",
	ShowEstimatedPoints	= "显示战斗开始/结束时双方资源统计",
	ShowFlagCarrier		= "显示旗帜携带者",
	TimerCap			= "计时条：占领资源",
	TimerFlag			= "计时条：旗帜重置",
	TimerInvite			= "计时条：进入战场",
	TimerStart			= "计时条：比赛开始计时",
	TimerRemaining		= "计时条：比赛开始和结束的剩余时间",
	TimerShadow			= "计时条：暗影之眼",
	TimerWin			= "计时条：胜利时间",
	ShowRelativeGameTime= "计时条：战场开始到获胜的计时（如果禁用，则计时条总是看起来满了）"
})

L:SetMiscLocalization({
BgStart120          = "战斗将在2分钟后开始。",
	BgStart60           = "战斗将在1分钟内开始。",
	BgStart30           = "战斗将在30秒钟内开始。做好准备！",
BgStart120era       = "距离战斗开始还有2分钟。",
BgStart60era        = "距离战斗开始还有1分钟。",
BgStart30era        = "距离战斗开始还有30秒。",
	ArenaStart60		= "竞技场战斗将在1分钟后开始！",
	ArenaStart30		= "竞技场战斗将在30秒后开始！",
	ArenaStart15		= "竞技场战斗将在15秒后开始！",
	ArenaInvite			= "竞技场邀请",
	BasesToWin			= "胜利需要占领资源点: %d",
	WinBarText			= "%s 获胜",
	BasesToWinHeader	= "DBM-PvP",
	-- TODO: Implement the flag carrying system
	FlagReset			= "旗帜被重新放置了！",
	FlagTaken			= "(.+) 夺走了旗帜！",
FlagCaptured		= "(.+) 夺得了旗帜！",
	FlagDropped			= "旗帜被扔掉了！",
	--
ExprFlagPickUp		= "(.+) 的旗帜被 (.+) 拔起了！",
ExprFlagCaptured	= "(.+) 夺取了 (.+) 的旗帜！",
ExprFlagReturn		= "(.+) 的旗帜被 (.+) 还到了它的基地中！",
	Vulnerable1			= "旗帜携带者已变的容易受到攻击！",
	Vulnerable2			= "旗帜携带者越来越容易受到攻击！",
	-- Alterac/IsleOfConquest/Ashenvale bosses
	InfoFrameHeader		= "[DBM] 首领生命值",
	HordeBoss			= "部落首领",
	AllianceBoss		= "联盟首领",
	Galvangar			= "加尔范",
	Balinda				= "巴琳达",
	Ivus				= "伊弗斯",
	Lokholar			= "洛克霍拉",
	RunestoneBoss		= "符文石",
	GlaiveBoss			= "战刃",
	ResearchBoss		= "研究",
	MoonwellBoss		= "月亮井",
	ShredderBoss		= "伐木机",
	CatapultBoss		= "投石车",
	LumberBoss			= "木材",
	BonfireBoss			= "篝火",
	-- Ashran bosses
	Tremblade			= "大元帅泰布雷德",
	Volrath				= "高阶督军沃拉斯",
	Fangraal			= "范格拉",
	Kronus				= "克洛努斯",
	-- Health sync frame
	Stale               = "（过期）",
})

----------------------
--  Seething Shore  --
----------------------
L = DBM:GetModLocalization("z1803")

L:SetGeneralLocalization({
	name	= "涌泉海滩"
})

L:SetTimerLocalization({
	TimerSpawn		= "%s"
})

L:SetOptionLocalization({
	TimerSpawn	= "显示艾泽里特矿产计时器"
})

----------------------
--  Alterac Valley  --
----------------------
L = DBM:GetModLocalization("z30")

L:SetGeneralLocalization({
	name	= "奥特兰克山谷"
})

L:SetTimerLocalization({
	TimerBoss	= "%s"
})

L:SetOptionLocalization({
	AutoTurnIn	= "自动递交任务物品",
	TimerBoss	= "显示首领剩余时间计时条"
})

L:SetMiscLocalization({
	BossHorde	= "是谁胆敢召唤洛克霍拉？",
	BossAlly	= "邪恶，邪恶的凡人！森林在哭泣。元素在毁灭中退缩。伊弗斯必须将你们从这个世界清除！"
})

--------------
--  Ashran  --
--------------
L = DBM:GetModLocalization("z1191")

L:SetGeneralLocalization({
	name	= "阿什兰"
})

L:SetOptionLocalization({
	AutoTurnIn	= "自动递交任务物品"
})

------------------------
--  Isle of Conquest  --
------------------------
L = DBM:GetModLocalization("z628")

L:SetGeneralLocalization({
	name	= "征服之岛"
})

L:SetWarningLocalization({
	WarnSiegeEngine		= "攻城机具准备好了！",
	WarnSiegeEngineSoon	= "10秒后 攻城机具就绪"
})

L:SetTimerLocalization({
	TimerSiegeEngine	= "攻城机具修复"
})

L:SetOptionLocalization({
	TimerSiegeEngine	= "计时条：攻城器的建造",
	WarnSiegeEngine		= "警报：攻城器准备就绪",
	WarnSiegeEngineSoon	= "预警：攻城器准备就绪",
	ShowGatesHealth		= "生命值框：城门破损状况（中途加入战场，该数据可能不准确）"
})

L:SetMiscLocalization({
	GatesHealthFrame		= "城门破损状况",
	SiegeEngine				= "攻城器",
	GoblinStartAlliance		= "看到那些爆盐炸弹了吗？当我维修攻城机具的时候用它们来轰破大门！",
	GoblinStartHorde		= "修理攻城机具的工作就交给我，帮我看着点就够了。如果你想要轰破大门的话，尽管把那些爆盐炸弹拿去用吧！",
	GoblinHalfwayAlliance	= "我已经修好一半了！别让部落靠近。工程学院可没有教我们如何作战喔！",
	GoblinHalfwayHorde		= "我已经修好一半了！别让联盟靠近 - 我的合约里可没有作战这一条！",
	GoblinFinishedAlliance	= "我有史以来最得意的作品！这台攻城机具已经可以上场啰！",
	GoblinFinishedHorde		= "这台攻城机具已经可以上场啦！",
	GoblinBrokenAlliance	= "这么快就坏啦？！别担心，再坏的情况我都可以修得好。",
	GoblinBrokenHorde		= "又坏掉了吗？！让我来修理吧……但别指望产品的保固会帮你支付这一切。"
})

-------------------------
--  Silvershard Mines  --
-------------------------
L = DBM:GetModLocalization("z727")

L:SetGeneralLocalization({
	name	= "碎银矿脉"
})

L:SetTimerLocalization({
	TimerRespawn	= "矿车刷新",
	TimerCart		= "%s"
})

L:SetOptionLocalization({
	TimerRespawn	= "显示矿车刷新计时",
	TimerCart		= "显示矿车占领计时条"
})

L:SetMiscLocalization({
	Capture	= "已控制",
	Arrived	= "已到达",
	Begun	= "已经开始"
})

-------------------------
--  Temple of Kotmogu  --
-------------------------
L = DBM:GetModLocalization("z998")

L:SetGeneralLocalization({
	name	= "寇魔古寺"
})

L:SetOptionLocalization({
	ShowOrbCarriers	= "显示框体"
})

L:SetMiscLocalization({
	OrbTaken	= "(%S+) 取走了 (%S+) 的球！",
	OrbReturn	= " (%S+) 宝珠被放回了！"
})

-------------------------
--  Deepwind Gorge  --
-------------------------
L = DBM:GetModLocalization("z2245")

L:SetGeneralLocalization({
	name	= "深风峡谷"
})

----------------
--  Ashenvale --
----------------
L = DBM:GetModLocalization("m1440")

L:SetGeneralLocalization({
	name	= "灰谷"
})

L:SetOptionLocalization({
	EstimatedStartTimer = "显示事件开始时间计时条",
	HealthFrame         = "显示首领生命值信息框，此功能通过团队同步和喊话频道与其他团队同步生命值。这意味着只有当安装了DBM-PvP的团队分布在不同首领附近时才能生效。"
})

L:SetTimerLocalization({
	EstimatedStart = "事件开始"
})

-----------------
--  Blood Moon --
-----------------
L = DBM:GetModLocalization("m1434")

L:SetGeneralLocalization({
	name	= "血月"
})

L:SetMiscLocalization({
	ParseTimeFromWidget = "(%d+)",
	ResTimerSelf = "为你显示复活计时条。",
	ResTimerParty = "为你的队友显示复活计时条。",
	ResTimerPartyClassColors = "为队友的复活计时条使用职业颜色。"
})