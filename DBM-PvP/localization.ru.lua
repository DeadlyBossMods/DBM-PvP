﻿if GetLocale() ~= "ruRU" then return end
local L

--------------------------
--  General BG Options  --
--------------------------
L = DBM:GetModLocalization("PvPGeneral")

L:SetGeneralLocalization({
	name = "Общие параметры"
})

L:SetTimerLocalization({
	TimerInvite = "%s"
})

L:SetOptionLocalization({
	ColorByClass		= "Показывать имена цветом класса в таблице очков",
	TimerInvite			= "Отсчет времени до входа на поле боя",
	AutoSpirit			= "Автоматически покидать тело",
	HideBossEmoteFrame	= "Скрыть фрейм эмоций рейдового босса"
})

L:SetMiscLocalization({
	BgStart60	= "Битва начнется через 1 минуту.",
	BgStart30	= "Битва начнется через 30 секунд. Приготовиться!",
	ArenaInvite	= "Приглашение на Арену"
})

--------------
--  Arenas  --
--------------
L = DBM:GetModLocalization("Arenas")

L:SetGeneralLocalization({
	name = "Арены"
})

L:SetTimerLocalization({
	TimerShadow	= "Сумеречное зрение"
})

L:SetOptionLocalization({
	TimerShadow	= "Отсчет времени до сумеречного зрения"
})

L:SetMiscLocalization({
	Start15	= "Пятнадцать секунд до начала боя на арене!",
	highmaulArena	= "The battle for supremacy begins in 30 seconds!"
})

----------------------
--  Seething Shore  --
----------------------
L = DBM:GetModLocalization("z1803")

L:SetTimerLocalization({
	TimerSpawn	= "%s"
})

L:SetOptionLocalization({
	TimerSpawn	= "Show azerite spawn timer"
})

----------------------
--  Alterac Valley  --
----------------------
L = DBM:GetModLocalization("z30")

L:SetTimerLocalization({
	TimerTower	= "%s",
	TimerGY		= "%s"
})

L:SetOptionLocalization({
	TimerTower	= "Отсчет времени до захвата башен",
	TimerGY		= "Отсчет времени до захвата кладбищ",
	AutoTurnIn	= "Автоматическая сдача заданий"
})

--------------------
--  Arathi Basin  --
--------------------
L = DBM:GetModLocalization("z529")

L:SetTimerLocalization({
	TimerCap	= "%s"
})

L:SetOptionLocalization({
	TimerWin				= "Отсчет времени до победы",
	TimerCap				= "Отсчет времени до захвата",
	ShowAbEstimatedPoints	= "Отображать предполагаемое кол-во очков, оставшееся до победы/поражения",
	ShowAbBasesToWin		= "Отображать кол-во баз, необходимое для победы"
})

L:SetMiscLocalization({
	ScoreExpr	= "(%d+)/1500",
	WinBarText	= "%s побеждает",
	BasesToWin	= "Баз для победы: %d"
})

---------------------
--  Deepwind Gorge --
---------------------
L = DBM:GetModLocalization("z1105")

L:SetTimerLocalization({
	TimerCap	= "%s"
})

L:SetOptionLocalization({
	TimerCap	= "Show capture timer",
	TimerWin	= "Show win timer"
})

L:SetMiscLocalization({
	ScoreExpr	= "(%d+)/1500",
	WinBarText	= "%s wins"
})

------------------------
--  Eye of the Storm  --
------------------------
L = DBM:GetModLocalization("z566")

L:SetTimerLocalization({
	TimerFlag	= "Восстановление флага"
})

L:SetOptionLocalization({
	TimerWin		= "Отсчет времени до победы",
	TimerFlag		= "Отсчет времени до восстановления флага",
	ShowPointFrame	= "Отображать флагоносца и предполагаемые очки"
})

L:SetMiscLocalization({
	ScoreExpr		= "(%d+)/1500",
	WinBarText		= "%s побеждает",
	Flag			= "Flag",
	FlagReset		= "Флаг возвращен на базу.",
	FlagTaken		= "(.+) захватывает флаг!",
	FlagCaptured	= "(.+) захватил флаг!",
	FlagDropped		= "Флаг уронили!"
})

---------------------
--  Warsong Gulch  --
---------------------
L = DBM:GetModLocalization("z489")

L:SetTimerLocalization({
	TimerStart	= "Битва начнется через",
	TimerFlag	= "Восстановление флага"
})

L:SetOptionLocalization({
	TimerStart					= "Отсчет времени до начала битвы",
	TimerFlag					= "Отсчет времени до восстановления флага",
	ShowFlagCarrier				= "Показывать флагоносца",
	ShowFlagCarrierErrorNote	= "Сообщение об ошибке выбора флагоносца в режиме боя"
})

L:SetMiscLocalization({
	InfoErrorText		= "Функция выбора флагоносца будет восстановлена после выхода из режима боя.",
	ExprFlagPickUp		= "(.+) несет флаг (%w+)!",
	ExprFlagCaptured	= "(.+) захватывает флаг (%w+)!",
	ExprFlagReturn		= "(.+) возвращает на базу флаг (%w+)!",
	FlagAlliance		= "Флаг Альянса: ",
	FlagHorde			= "Флаг Орды: ",
	FlagBase			= "База",
	Vulnerable1			= "Персонажи, несущие флаг, стали более уязвимы!",
	Vulnerable2			= "Персонажи, несущие флаг, стали еще более уязвимы!"
})

------------------------
--  Isle of Conquest  --
------------------------
L = DBM:GetModLocalization("z628")

L:SetWarningLocalization({
	WarnSiegeEngine		= "Осадная машина готова!",
	WarnSiegeEngineSoon	= "Осадная машина через ~10 сек"
})

L:SetTimerLocalization({
	TimerPOI			= "%s",
	TimerSiegeEngine	= "Осадная машина готова"
})

L:SetOptionLocalization({
	TimerPOI			= "Отсчет времени до захвата",
	TimerSiegeEngine	= "Отсчет времени до создания Осадной машины",
	WarnSiegeEngine		= "Предупреждение, когда создание Осадной машины завершено",
	WarnSiegeEngineSoon	= "Предупреждение, когда создание Осадной машины почти завершено",
	ShowGatesHealth		= "Отображать здоровье поврежденых ворот (значение здоровья может быть некорректным после захода в уже начавшееся поле боя!)"
})

L:SetMiscLocalization({
	GatesHealthFrame		= "Поврежденые ворота",
	SiegeEngine				= "Осадная машина",
	GoblinStartAlliance		= "See those seaforium bombs? Use them on the gates while I repair the siege engine!",
	GoblinStartHorde		= "Я буду работать над осадной машиной, я ты меня прикрывай. Вот, можешь пользоваться этими сефориевыми бомбами, если тебе надо взорвать ворота.",
	GoblinHalfwayAlliance	= "I'm halfway there! Keep the Horde away from here. They don't teach fighting in engineering school!",
	GoblinHalfwayHorde		= "I'm about halfway done! Keep the Alliance away - fighting's not in my contract!",
	GoblinFinishedAlliance	= "My finest work so far! This siege engine is ready for action!",
	GoblinFinishedHorde		= "The siege engine is ready to roll!",
	GoblinBrokenAlliance	= "It's broken already?! No worries. It's nothing I can't fix.",
	GoblinBrokenHorde		= "It's broken again?! I'll fix it... just don't expect the warranty to cover this"
})

------------------
--  Twin Peaks  --
------------------
L = DBM:GetModLocalization("z726")

L:SetTimerLocalization({
	TimerStart	= "Битва начнется через",
	TimerFlag	= "Восстановление флага"
})

L:SetOptionLocalization({
	TimerStart					= "Отсчет времени до начала битвы",
	TimerFlag					= "Отсчет времени до восстановления флага",
	ShowFlagCarrier				= "Показывать флагоносца",
	ShowFlagCarrierErrorNote	= "Сообщение об ошибке выбора флагоносца в режиме боя"
})

L:SetMiscLocalization({
	InfoErrorText		= "Функция выбора флагоносца будет восстановлена после выхода из режима боя.",
	ExprFlagPickUp		= "(.+) несет флаг (%w+)!",
	ExprFlagCaptured	= "(.+) захватывает флаг (%w+)!",
	ExprFlagReturn		= "(.+) возвращает на базу флаг (%w+)!",
	FlagAlliance		= "Флаг Альянса: ",
	FlagHorde			= "Флаг Орды: ",
	FlagBase			= "База",
	Vulnerable1			= "Персонажи, несущие флаг, стали более уязвимы!",
	Vulnerable2			= "Персонажи, несущие флаг, стали еще более уязвимы!"
})

------------------------------
--  The Battle for Gilneas  --
------------------------------
L = DBM:GetModLocalization("z761")

L:SetTimerLocalization({
	TimerCap	= "%s"
})

L:SetOptionLocalization({
	TimerWin					= "Отсчет времени до победы",
	TimerCap					= "Отсчет времени до захвата",
	ShowGilneasEstimatedPoints	= "Отображать предполагаемое кол-во очков, оставшееся до победы/поражения",
	ShowGilneasBasesToWin		= "Отображать кол-во баз, необходимое для победы"
})

L:SetMiscLocalization({
	ScoreExpr	= "(%d+)/1500",
	WinBarText	= "%s побеждает",
	BasesToWin	= "Баз для победы: %d"
})

-------------------------
--  Silvershard Mines  --
-------------------------
L = DBM:GetModLocalization("z727")

L:SetTimerLocalization({
	TimerRespawn	= "Восстановление вагонетки",
	TimerCart		= "%s"
})

L:SetOptionLocalization({
	TimerResapwn	= "тсчет времени до восстановления вагонетки",
	TimerCart		= "Show cart cap timer"
})

L:SetMiscLocalization({
	Capture	= "захвачена",
	Arrived	= "has arived",
	Begun	= "has begun"
})

-------------------------
--  Temple of Kotmogu  --
-------------------------
L = DBM:GetModLocalization("z998")

L:SetOptionLocalization({
	TimerWin					= "Отсчет времени до победы",
	ShowKotmoguEstimatedPoints	= "Отображать предполагаемое кол-во очков, оставшееся до победы/поражения",
	ShowKotmoguOrbsToWin		= "Отображать кол-во сфер, необходимое для победы"
})

L:SetMiscLocalization({
	OrbTaken	= "(%S+) захватывает (%S+) сферу!",
	OrbReturn	= "(%S+) сфера возвращена!",
	ScoreExpr	= "(%d+)/1500",
	WinBarText	= "Предположительно %s побеждает",
	OrbsToWin	= "Сфер для победы: %d"
})
