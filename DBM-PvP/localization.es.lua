if GetLocale() ~= "esES" and GetLocale() ~= "esMX" then return end
local L

--------------------------
--  General BG Options  --
--------------------------
L = DBM:GetModLocalization("PvPGeneral")

L:SetGeneralLocalization({
	name	= "Opciones generales"
})

L:SetTimerLocalization({
	TimerCap		= "%s",
	TimerFlag		= "Reaparición de la bandera",
	TimerInvite		= "%s",
	TimerWin		= "Victoria en",
	TimerStart		= "Comenzando en",
	TimerShadow		= "Visión de las Sombras"
})

L:SetOptionLocalization({
	AutoSpirit			= "Liberar espíritu automáticamente",
	HideBossEmoteFrame	= "Ocultar marco de jefe de banda y botón de ciudadela en campos de batalla",
	ShowBasesToWin          = "Mostrar bases necesarias para ganar",
	TimerCap                = "Mostrar temporizador de captura",
	TimerFlag               = "Mostrar temporizador de reaparición de bandera",
	TimerStart              = "Mostrar temporizador hasta el inicio de la batalla",
	TimerShadow             = "Mostrar temporizador para la visión de las sombras",
	TimerWin                = "Mostrar temporizador de victoria",
	ShowRelativeGameTime    = "Rellenar temporizador de victoria en relación con el tiempo de inicio del campo de batalla (Si está desactivado, la barra siempre se verá llena)"
})

L:SetMiscLocalization({
	BgStart60			= "La batalla comienza en 1 minuto.",
	BgStart30			= "La batalla comienza en 30 segundos. ¡Preparaos!",
	ArenaInvite			= "Invitación a la arena",
	ExprFlagPickUp		= "¡(.+) ha cogido la bandera de la (%w+)!",
	ExprFlagCaptured	= "¡(.+) ha capturado la bandera de la (%w+)!",
	ExprFlagReturn		= "¡(.+) ha devuelto la bandera de la (%w+) a su base!",
	Vulnerable1			= "¡Los portadores de las banderas se han vuelto vulnerables a los ataques!",
	Vulnerable2			= "¡Los portadores de las banderas se han vuelto más vulnerables a los ataques!"
})


----------------------
--  Alterac Valley  --
----------------------
L = DBM:GetModLocalization("z30")

L:SetOptionLocalization({
	AutoTurnIn	= "Entregar misiones automáticamente"
	TimerBoss 	= "Mostrar temporizador de tiempo restante del jefe"
})

------------------------
--  Isle of Conquest  --
------------------------
L = DBM:GetModLocalization("z628")

L:SetWarningLocalization({
	WarnSiegeEngine		= "¡Máquina de asedio lista!",
	WarnSiegeEngineSoon	= "Máquina de asedio en ~10 s"
})

L:SetTimerLocalization({
	TimerSiegeEngine	= "Máquina de asedio lista"
})

L:SetOptionLocalization({
	TimerSiegeEngine	= "Mostrar temporizador para construcción de máquinas de asedio",
	WarnSiegeEngine		= "Mostrar aviso cuando una máquina de asedio esté lista",
	WarnSiegeEngineSoon	= "Mostrar aviso cuando una máquina de asedio esté casi lista",
	ShowGatesHealth		= "Mostrar salud de puertas dañadas (¡puede dar resultados erróneos al unirse a una batalla en curso!)"
})

L:SetMiscLocalization({
	GatesHealthFrame		= "Puertas dañadas",
	SiegeEngine				= "Máquina de asedio",
	GoblinStartAlliance		= "¿Ves esas bombas de seforio? Úsalas en las puertas mientras reparo la máquina de asedio.",
	GoblinStartHorde		= "Trabajaré en la máquina de asedio, solo cúbreme las espaldas. ¡Usa esas bombas de seforio en las puertas si las necesitas!",
	GoblinHalfwayAlliance	= "¡Ya casi estoy! Mantén a la Horda alejada. ¡No me enseñaron a luchar en la escuela de ingeniería!",
	GoblinHalfwayHorde		= "¡Ya casi estoy! Mantén a la Alianza alejada... ¡Luchar no entra en mi contrato!",
	GoblinFinishedAlliance	= "¡Mi mejor trabajo hasta ahora! ¡Esta máquina de asedio está lista para la acción!",
	GoblinFinishedHorde		= "¡La máquina de asedio está lista para la acción!",
	GoblinBrokenAlliance	= "¡¿Ya se ha roto?! No te preocupes. No es nada que no pueda arreglar.",
	GoblinBrokenHorde		= "¡¿Se ha vuelto a romper?1 Ya lo arreglo... Pero no esperes que esto lo cubra la garantía."
})

-------------------------
--  Silvershard Mines  --
-------------------------
L = DBM:GetModLocalization("z727")

L:SetTimerLocalization({
	TimerRespawn	= "Reaparición de vagoneta"
})

L:SetOptionLocalization({
	TimerRespawn	= "Mostrar temporizador de reaparición de vagoneta",
	TimerCart		= "Show cart cap timer"
})

L:SetMiscLocalization({
	Capture	= "ha capturado",
	Arrived	= "has llegado",
	Begun	= "ha comenzado"
})

-------------------------
--  Temple of Kotmogu  --
-------------------------
L = DBM:GetModLocalization("z998")

L:SetMiscLocalization({
	OrbTaken	= "¡(%S+) se ha hecho con el orbe (%S+)!",
	OrbReturn	= "¡El orbe (%S+) ha sido devuelto!"
})

----------------
--  Ashenvale --
----------------
L = DBM:GetModLocalization("m1440")

L:SetOptionLocalization({
	EstimatedStartTimer = "Mostrar temporizador para el inicio del evento",
	HealthFrame = "Mostrar marco de información con la salud del jefe, esto funciona sincronizando la salud en tu banda y a través del chat de gritos a otras bandas. Esto significa que solo funciona si hay al menos algunas bandas distribuidas en jefes con DBM-PvP instalado."
})

L:SetTimerLocalization({
	EstimatedStart = "Evento comienza"
})

-----------------
--  Blood Moon --
-----------------
L = DBM:GetModLocalization("m1434")

L:SetMiscLocalization({
	ParseTimeFromWidget = "(%d+)",
	ResTimerSelf = "Mostrar temporizador de resurrección para ti.",
	ResTimerParty = "Mostrar temporizador de resurrección para los miembros de tu grupo.",
	ResTimerPartyClassColors = "Utilizar colores de clase para los temporizadores de resurrección de los miembros de tu grupo."
})

