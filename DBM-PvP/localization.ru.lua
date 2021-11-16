if GetLocale() ~= "ruRU" then return end
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
	BgStart60			= "Битва начнется через 1 минуту.",
	BgStart30			= "Битва начнется через 30 секунд. Приготовиться!",
	ArenaInvite			= "Приглашение на Арену",
	ExprFlagPickUp		= "(.+) несет флаг (%w+)!",
	ExprFlagCaptured	= "(.+) захватывает флаг (%w+)!",
	ExprFlagReturn		= "(.+) возвращает на базу флаг (%w+)!",
	Vulnerable1			= "Персонажи, несущие флаг, стали более уязвимы!",
	Vulnerable2			= "Персонажи, несущие флаг, стали еще более уязвимы!"
})

----------------------
--  Alterac Valley  --
----------------------
L = DBM:GetModLocalization("z30")

L:SetOptionLocalization({
	AutoTurnIn	= "Автоматическая сдача заданий"
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
	GatesHealthFrame		= "Поврежденные ворота",
	SiegeEngine				= "Осадная машина",
	GoblinStartAlliance		= "Видите эти взрывчатые бомбы? Используйте их на воротах, пока я ремонтирую осадную машину!",
	GoblinStartHorde		= "Я буду работать над осадной машиной, я ты меня прикрывай. Вот, можешь пользоваться этими сефориевыми бомбами, если тебе надо взорвать ворота.",
	GoblinHalfwayAlliance	= "Я на полпути! Держите Орду подальше отсюда. В инженерном училище не учат боевым действиям!",
	GoblinHalfwayHorde		= "Я примерно на полпути! Держите Альянс подальше - драки не в моем контракте!",
	GoblinFinishedAlliance	= "Моя лучшая работа на данный момент! Эта осадная машина готова к действию!",
	GoblinFinishedHorde		= "Осадная машина готова к работе!",
	GoblinBrokenAlliance	= "Он уже сломан?! Не стоит беспокоиться. Я ничего не могу исправить.",
	GoblinBrokenHorde		= "Опять сломано?! Я исправлю это ... только не ожидайте, что гарантия покроет это."
})

-------------------------
--  Silvershard Mines  --
-------------------------
L = DBM:GetModLocalization("z727")

L:SetTimerLocalization({
	TimerRespawn	= "Восстановление вагонетки"
})

L:SetOptionLocalization({
	TimerRespawn	= "Отсчет времени до восстановления вагонетки",
	TimerCart		= "Таймер захвата повозки"
})

L:SetMiscLocalization({
	Capture	= "захвачена",
	Arrived	= "прибыл",
	Begun	= "начался"
})

-------------------------
--  Temple of Kotmogu  --
-------------------------
L = DBM:GetModLocalization("z998")

L:SetMiscLocalization({
	OrbTaken	= "(%S+) захватывает (%S+) сферу!",
	OrbReturn	= "(%S+) сфера возвращена!"
})
