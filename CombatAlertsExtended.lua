local em = GetEventManager()

local base_CombatAlertsCombatEvent = CombatAlerts.CombatEvent
local base_CombatAlertsPoll = CombatAlerts.Poll
local base_CombatAlertsPlayerActivated = CombatAlerts.PlayerActivated
local base_CombatAlertsStartListenting = CombatAlerts.StartListening
local base_CombatAlertsStopListenting = CombatAlerts.StopListening

CombatAlerts.at = {}
CombatAlerts.bloodforge = {}
CombatAlerts.scalecaller.ratAchEnabled = false
CombatAlerts.scalecaller.isRatAchFailed = false
CombatAlerts.bloodforge.nirnAchEnabled = false
CombatAlerts.bloodforge.isAchFailed = false

if CombatAlertsExtended == nil then CombatAlertsExtended = {} end

CombatAlertsExtended.savedVariablesDefault = {
	Settings = {
		CoralAerie = {
			MentalWound = true,
			BlastPowder = true,
			Tether = true
		},
		ShipwrightsRegret = {
			Flame = true,
			SoulBomb = true
		},
		Others = {
			PustulentProblems = true,
			CoolingYourHeels = true,
			DSRRunestones = true
		}
	}
}

CombatAlertsExtended.icons = {}
CombatAlertsExtended.langs = {}
CombatAlertsExtended.selectedLang = {}
CombatAlertsExtended.langs.ru = {
	ADDONMENU_CORALAERIE_HEADER = "Коралловое гнездо",
	ADDONMENU_SHIPWRIGHTSREGRET_HEADER = "Горе корабела",
	ADDONMENU_OTHERS_HEADER = "Прочее",
	ADDONMENU_CORALAERIE_MENTALWOUND = "Разрушение разума",
	ADDONMENU_CORALAERIE_MENTALWOUND_TOOLTIP = "Переключить отображение таймера умения 'Разрушение разума'",
	ADDONMENU_CORALAERIE_BLASTPOWDER = "Blast Powder",
	ADDONMENU_CORALAERIE_BLASTPOWDER_TOOLTIP = "Переключить отображение умения 'Blast Powder'",
	ADDONMENU_CORALAERIE_TETHER = "Связь",
	ADDONMENU_CORALAERIE_TETHER_TOOLTIP = "Переключить отображение таймера умения 'Связь'",
	ADDONMENU_SHIPWRIGHTSREGRET_FLAME = "Пламя",
	ADDONMENU_SHIPWRIGHTSREGRET_FLAME_TOOLTIP = "Переключить отображение умения склетов 'Пламя'",
	ADDONMENU_SHIPWRIGHTSREGRET_SOULBOMB = "Мина душ",
	ADDONMENU_SHIPWRIGHTSREGRET_SOULBOMB_TOOLTIP = "Переключить отображение рекомендуемого стака игроков во время способности 'Мина душ'",
	ADDONMENU_OTHERS_PUSTULENTPROBLEMS = "Достижение 'Гнойные проблемы'",
	ADDONMENU_OTHERS_PUSTULENTPROBLEMS_TOOLTIP = "Переключить отслеживание выполения достижения 'Гнойные проблемы' Пика призывательницы дракона",
	ADDONMENU_OTHERS_COOLINGYOURHEELS = "Достижение 'Ноги в холоде'",
	ADDONMENU_OTHERS_COOLINGYOURHEELS_TOOLTIP = "Переключить отслеживание выполения достижения 'Ноги в холоде' Кузницы кровавого корня",
	ADDONMENU_OTHERS_DSRRUNESTONES = "Скрытые руны DSR",
	ADDONMENU_OTHERS_DSRRUNESTONES_TOOLTIP = "Переключить отображение 3д-меток в триале DSR, где может быть найдена руна (требуется OdySupportIcons)"
}
CombatAlertsExtended.langs.en = {
	ADDONMENU_CORALAERIE_HEADER = "Coral Aerie",
	ADDONMENU_SHIPWRIGHTSREGRET_HEADER = "Shipwright's Regret",
	ADDONMENU_OTHERS_HEADER = "Others",
	ADDONMENU_CORALAERIE_MENTALWOUND = "Mental Wound",
	ADDONMENU_CORALAERIE_MENTALWOUND_TOOLTIP = "Switch cast timer display for Varallion's 'Tether' HM ability",
	ADDONMENU_CORALAERIE_BLASTPOWDER = "Blast Powder",
	ADDONMENU_CORALAERIE_BLASTPOWDER_TOOLTIP = "Switch cast display for Sarydil's 'Blast Powder' ability",
	ADDONMENU_CORALAERIE_TETHER = "Tether",
	ADDONMENU_CORALAERIE_TETHER_TOOLTIP = "Switch cast timer display for Varallion's 'Tether' HM ability",
	ADDONMENU_SHIPWRIGHTSREGRET_FLAME = "Flame",
	ADDONMENU_SHIPWRIGHTSREGRET_FLAME_TOOLTIP = "Switch cast warning for skeleton's 'Flame' ability",
	ADDONMENU_SHIPWRIGHTSREGRET_SOULBOMB = "Soul Bomb",
	ADDONMENU_SHIPWRIGHTSREGRET_SOULBOMB_TOOLTIP = "Switch hint with recommended group stack for Foreman Bradiggan's 'Soul bomb' HM",
	ADDONMENU_OTHERS_PUSTULENTPROBLEMS = "'Pustulent Problems' achievement",
	ADDONMENU_OTHERS_PUSTULENTPROBLEMS_TOOLTIP = "Switch tracking of 'Pustulent Problems' achievement",
	ADDONMENU_OTHERS_COOLINGYOURHEELS = "'Cooling Your Heels' achievement",
	ADDONMENU_OTHERS_COOLINGYOURHEELS_TOOLTIP = "Switch tracking of 'Cooling Your Heels' achievement",
	ADDONMENU_OTHERS_DSRRUNESTONES = "Hidden runes DSR",
	ADDONMENU_OTHERS_DSRRUNESTONES_TOOLTIP = "Switch 3D-markers in the DSR trial, where you can find runestones (requires OdySupportIcons)"
}

function CombatAlerts.StartListening()
	local db = CombatAlertsExtended.savedVariables.Settings
	
	if ((CombatAlerts.zoneId == 1344) and (OSI ~= nil) and (db.Others.DSRRunestones)) then
		CombatAlertsExtended.DreadSailRunestones(false)
	end
	base_CombatAlertsStartListenting()
end

function CombatAlerts.StopListening()
	local db = CombatAlertsExtended.savedVariables.Settings
	if ((CombatAlerts.zoneId == 1344) and (OSI ~= nil) and (db.Others.DSRRunestones)) then
		CombatAlertsExtended.DreadSailRunestones(true)
	end
	
	base_CombatAlertsStopListenting()
end


function CombatAlertsExtended.DreadSailRunestones(mode)
	local runestonesPositions = {
		["rune1"] = {x = 20411, y = 36785, z = 39579, texture = "odysupporticons/icons/arrow.dds", size = 150, color = {1,1,1}},
		["rune2"] = {x = 12978, y = 37345, z = 29165, texture = "odysupporticons/icons/arrow.dds", size = 150, color = {1,1,1}},
		["rune3"] = {x = 41489, y = 36788, z = 23992, texture = "odysupporticons/icons/arrow.dds", size = 150, color = {1,1,1}},
		["rune4"] = {x = 41213, y = 36806, z = 11735, texture = "odysupporticons/icons/arrow.dds", size = 150, color = {1,1,1}},
		["rune5"] = {x = 46656, y = 36825, z = 30250, texture = "odysupporticons/icons/arrow.dds", size = 150, color = {1,1,1}},
		["rune6"] = {x = 127720, y = 38008, z = 160150, texture = "odysupporticons/icons/arrow.dds", size = 150, color = {1,1,1}},
		["rune7"] = {x = 142091, y = 38249, z = 165583, texture = "odysupporticons/icons/arrow.dds", size = 150, color = {1,1,1}},
		["rune8"] = {x = 146410, y = 38236, z = 177617, texture = "odysupporticons/icons/arrow.dds", size = 150, color = {1,1,1}},
		["rune9"] = {x = 147747, y = 38229, z = 160142, texture = "odysupporticons/icons/arrow.dds", size = 150, color = {1,1,1}},
		["rune10"] = {x = 156722, y = 40509, z = 151923, texture = "odysupporticons/icons/arrow.dds", size = 150, color = {1,1,1}}
	}
	
	if (mode) then
		local function enableIcon(name)
			local iconData = runestonesPositions[name]
			local icon = OSI.CreatePositionIcon(iconData.x, iconData.y, iconData.z, iconData.texture, iconData.size, iconData.color)
			CombatAlertsExtended.icons[name] = icon
		end
		
		if (CombatAlertsExtended.icons["rune1"] == nil) then
			enableIcon("rune1")
			enableIcon("rune2")
			enableIcon("rune3")
			enableIcon("rune4")
			enableIcon("rune5")
			enableIcon("rune6")
			enableIcon("rune7")
			enableIcon("rune8")
			enableIcon("rune9")
			enableIcon("rune10")
		end
	else
		if (CombatAlertsExtended.icons["rune1"] ~= nil) then
			OSI.DiscardPositionIcon(CombatAlertsExtended.icons["rune1"])
			OSI.DiscardPositionIcon(CombatAlertsExtended.icons["rune2"])
			OSI.DiscardPositionIcon(CombatAlertsExtended.icons["rune3"])
			OSI.DiscardPositionIcon(CombatAlertsExtended.icons["rune4"])
			OSI.DiscardPositionIcon(CombatAlertsExtended.icons["rune5"])
			OSI.DiscardPositionIcon(CombatAlertsExtended.icons["rune6"])
			OSI.DiscardPositionIcon(CombatAlertsExtended.icons["rune7"])
			OSI.DiscardPositionIcon(CombatAlertsExtended.icons["rune8"])
			OSI.DiscardPositionIcon(CombatAlertsExtended.icons["rune9"])
			OSI.DiscardPositionIcon(CombatAlertsExtended.icons["rune10"])
			CombatAlertsExtended.icons = {}
		end
	end
end

function CombatAlertsExtended.AddonLoaded( event, addon )

	if addon ~= "CombatAlertsExtended" then return end
	
	if (GetCVar("language.2") == "ru") then
		CombatAlertsExtended.selectedLang = CombatAlertsExtended.langs.ru
	else
		CombatAlertsExtended.selectedLang = CombatAlertsExtended.langs.en
	end
	
	CombatAlertsExtended.savedVariables = ZO_SavedVars:NewAccountWide("CombatAlertsExtended_data", 3, nil, CombatAlertsExtended.savedVariablesDefault, nil)
	CombatAlertsExtended.LoadAddonMenu()
	em:UnregisterForEvent("CombatAlertsExtendedLoaded", EVENT_ADD_ON_LOADED)
end

function CombatAlertsExtended.LoadAddonMenu()
	local db = CombatAlertsExtended.savedVariables.Settings
	local lang = CombatAlertsExtended.selectedLang
	
	local panelData = {
		type = "panel",
		name = "Combat Alerts Extended",
		displayName = "Combat Alerts Extended",
		author = "DrSova",
		version = "1.0.2",
		slashCommand = "/cae",	--(optional) will register a keybind to open to this panel
		registerForRefresh = true,	--boolean (optional) (will refresh all options controls when a setting is changed and when the panel is shown)
		registerForDefaults = true,	--boolean (optional) (will set all options controls back to default values)
	}
	
	local optionsTable = {
		{
			type = "header",
			name = lang.ADDONMENU_CORALAERIE_HEADER
		},
		{
			type = "checkbox",
			name = lang.ADDONMENU_CORALAERIE_MENTALWOUND,
			tooltip = lang.ADDONMENU_CORALAERIE_MENTALWOUND_TOOLTIP,
			default = true,
			getFunc = function() return db.CoralAerie.MentalWound end,
			setFunc = function(value) db.CoralAerie.MentalWound = value end,
		},
		{
			type = "checkbox",
			name = lang.ADDONMENU_CORALAERIE_BLASTPOWDER,
			tooltip = lang.ADDONMENU_CORALAERIE_BLASTPOWDER_TOOLTIP,
			default = true,
			getFunc = function() return db.CoralAerie.BlastPowder end,
			setFunc = function(value) db.CoralAerie.BlastPowder = value end,
		},
		{
			type = "checkbox",
			name = lang.ADDONMENU_CORALAERIE_TETHER,
			tooltip = lang.ADDONMENU_CORALAERIE_TETHER_TOOLTIP,
			default = true,
			getFunc = function() return db.CoralAerie.Tether end,
			setFunc = function(value) db.CoralAerie.Tether = value end,
		},
		{
			type = "header",
			name = lang.ADDONMENU_SHIPWRIGHTSREGRET_HEADER
		},
		{
			type = "checkbox",
			name = lang.ADDONMENU_SHIPWRIGHTSREGRET_FLAME,
			tooltip = lang.ADDONMENU_SHIPWRIGHTSREGRET_FLAME_TOOLTIP,
			default = true,
			getFunc = function() return db.ShipwrightsRegret.Flame end,
			setFunc = function(value) db.ShipwrightsRegret.Flame = value end,
		},
		{
			type = "checkbox",
			name = lang.ADDONMENU_SHIPWRIGHTSREGRET_SOULBOMB,
			tooltip = lang.ADDONMENU_SHIPWRIGHTSREGRET_SOULBOMB_TOOLTIP,
			default = true,
			getFunc = function() return db.ShipwrightsRegret.SoulBomb end,
			setFunc = function(value) db.ShipwrightsRegret.SoulBomb = value end,
		},
		{
			type = "header",
			name = lang.ADDONMENU_OTHERS_HEADER
		},
		{
			type = "checkbox",
			name = lang.ADDONMENU_OTHERS_PUSTULENTPROBLEMS,
			tooltip = lang.ADDONMENU_OTHERS_PUSTULENTPROBLEMS_TOOLTIP,
			default = true,
			getFunc = function() return db.Others.PustulentProblems end,
			setFunc = function(value) db.Others.PustulentProblems = value end,
		},
		{
			type = "checkbox",
			name = lang.ADDONMENU_OTHERS_COOLINGYOURHEELS,
			tooltip = lang.ADDONMENU_OTHERS_COOLINGYOURHEELS_TOOLTIP,
			default = true,
			getFunc = function() return db.Others.CoolingYourHeels end,
			setFunc = function(value) db.Others.CoolingYourHeels = value end,
		},
		{
			type = "checkbox",
			name = lang.ADDONMENU_OTHERS_DSRRUNESTONES,
			tooltip = lang.ADDONMENU_OTHERS_DSRRUNESTONES_TOOLTIP,
			default = true,
			getFunc = function() return db.Others.DSRRunestones end,
			setFunc = function(value) db.Others.DSRRunestones = value end,
		}
	}

	local menu = LibAddonMenu2
	if not LibAddonMenu2 then return end
	
	local panel = menu:RegisterAddonPanel("CombatAlertsExtended_Options", panelData)
	menu:RegisterOptionControls("CombatAlertsExtended_Options", optionsTable)
end

function CombatAlerts.PlayerActivated( eventCode, initial )
	local db = CombatAlertsExtended.savedVariables.Settings
	CombatAlerts.zoneId = GetZoneId(GetUnitZoneIndex("player"))
	
	
	if (CombatAlerts.zoneId == 1344 and (db.Others.DSRRunestones)) then
		if (OSI ~= nil) then
			CombatAlertsExtended.DreadSailRunestones(true)
		end
	else
		CombatAlertsExtended.DreadSailRunestones(false)
	end
	
	if (CombatAlerts.zoneId == 1010 and db.Others.PustulentProblems) then
		if (not CombatAlerts.scalecaller.ratAchEnabled) then
			CombatAlerts.scalecaller.ratAchEnabled = true
			CombatAlerts.AlertChat(LocalizeString("Starting tracking |H1:achievement:1984:0:0|h|h"));
		end
	elseif (CombatAlerts.zoneId == 973 and db.Others.CoolingYourHeels) then
		if (not CombatAlerts.bloodforge.nirnAchEnabled) then
			local BloodForgeAchievement = function( eventCode, result, isError, abilityName, abilityGraphic, abilityActionSlotType, sourceName, sourceType, targetName, targetType, hitValue, powerType, damageType, log, sourceUnitId, targetUnitId, abilityId )
				
				if (abilityId == 87303 and targetType == COMBAT_UNIT_TYPE_PLAYER) then 
					CombatAlerts.AlertChat(string.format("Failed |H1:achievement:1816:0:0|h|h"))
					CombatAlerts.scalecaller.isAchFailed = true
					EVENT_MANAGER:UnregisterForEvent("CombatAlertsExtended_Bloodforge", EVENT_COMBAT_EVENT)
				end
			end
			
			CombatAlerts.bloodforge.nirnAchEnabled = true
			CombatAlerts.AlertChat(LocalizeString("Starting tracking |H1:achievement:1816:0:0|h|h"));
			EVENT_MANAGER:RegisterForEvent("CombatAlertsExtended_Bloodforge", EVENT_COMBAT_EVENT, BloodForgeAchievement)
		end
	else
		CombatAlerts.scalecaller.ratAchEnabled = false
		CombatAlerts.scalecaller.isRatAchFailed = false
		CombatAlerts.bloodforge.nirnAchEnabled = false
		CombatAlerts.bloodforge.isAchFailed = false
	end
	base_CombatAlertsPlayerActivated(eventCode, initial)
end

function CombatAlerts.CombatEvent( eventCode, result, isError, abilityName, abilityGraphic, abilityActionSlotType, sourceName, sourceType, targetName, targetType, hitValue, powerType, damageType, log, sourceUnitId, targetUnitId, abilityId )
	local overwritten = false;
	local db = CombatAlertsExtended.savedVariables.Settings
	
	-- some test
	if (abilityId == 118852) then
		-- CHAT_ROUTER:AddSystemMessage(string.format("event %d result %d abilityName %s sourceName %s sourceType %d hitValue %d powerType %d damageType %d sourceUnitId %d targetUnitId %d abilityId %d targetName %s targetType %s",eventCode, result, abilityName, sourceName, sourceType, hitValue, powerType, damageType, sourceUnitId, targetUnitId, abilityId, targetName, targetType))
	end
	
	-- Ascending Tide
	
	if (result == ACTION_RESULT_BEGIN and abilityId == 165849 and hitValue == 1000 and db.ShipwrightsRegret.Flame) then 
		CombatAlerts.Alert(nil, GetAbilityName(abilityId), 0xFFD700FF, SOUNDS.DUEL_START, 1500)
		overwritten = true
	elseif (result == ACTION_RESULT_EFFECT_GAINED and abilityId == CombatAlertsData.at.bomb2 and db.ShipwrightsRegret.SoulBomb) then
		if (CombatAlerts.units[targetUnitId]) then
			targetName = CombatAlerts.units[targetUnitId].name
		end
		table.insert(CombatAlerts.tide.bombs, targetName)
		if (#CombatAlerts.tide.bombs > 1) then
			
			CombatAlerts.unitsName = {}
			clean_units = {}
			
			for i = 1, GetGroupSize() do
				local unitTag = GetGroupUnitTagByIndex(i)
				local name = GetUnitDisplayName(unitTag)
				table.insert(CombatAlerts.unitsName,name)
			end
			
			local t = {}
			for i = 1, #CombatAlerts.tide.bombs do
				t[CombatAlerts.tide.bombs[i]] = true;
			end
			for i = #CombatAlerts.unitsName, 1, -1 do
				if t[CombatAlerts.unitsName[i]] then
					table.remove(CombatAlerts.unitsName, i)
				end
			end
			clean_units = CombatAlerts.unitsName;
			table.sort(clean_units)
			table.sort(CombatAlerts.tide.bombs)
			
			first_pair = table.concat({CombatAlerts.tide.bombs[1], clean_units[1]}, " + ")
			second_pair = table.concat({CombatAlerts.tide.bombs[2], clean_units[2]}, " + ")
			
			if ((CombatAlerts.tide.bombs[1] == GetDisplayName()) or (clean_units[1] == GetDisplayName())) then 
				CombatAlerts.Alert(GetFormattedAbilityName(abilityId), first_pair, 0xCC3399FF, SOUNDS.CHAMPION_POINTS_COMMITTED, 7000)
			else 
				CombatAlerts.Alert(GetFormattedAbilityName(abilityId), second_pair, 0xCC3399FF, SOUNDS.CHAMPION_POINTS_COMMITTED, 7000)
			end
			CombatAlerts.tide.bombs = { }
			CombatAlerts.unitsName = { }
			clean_units = { }
		end
		overwritten = true
	elseif (result == ACTION_RESULT_EFFECT_GAINED and (abilityId == 163148 or abilityId == 163152) and db.CoralAerie.MentalWound) then
		if (CombatAlerts.panel.tag ~= "varallion") then
			CombatAlerts.TogglePanel(true, "DOT", true, true)
			CombatAlerts.panel.tag = "varallion"
		end
		CombatAlerts.at.dotStarted = GetGameTimeMilliseconds()
	elseif (result == ACTION_RESULT_BEGIN and abilityId == 158909 and db.CoralAerie.BlastPowder) then
		CombatAlerts.AlertCast(abilityId, nil, hitValue + 1000, { -2, 2 })
		overwritten = true
	elseif (result == ACTION_RESULT_EFFECT_GAINED and CombatAlertsData.at.links[abilityId] and db.CoralAerie.MentalWound) then
		if (CombatAlerts.units[targetUnitId]) then
			targetName = CombatAlerts.units[targetUnitId].name
		end
		if (CombatAlertsData.at.links[abilityId] == 1) then
			CombatAlerts.tide.link1 = targetName
		else
			CombatAlerts.Alert(GetFormattedAbilityName(abilityId), string.format("%s / %s", CombatAlerts.tide.link1, targetName), 0xCC3399FF, SOUNDS.CHAMPION_POINTS_COMMITTED, 2000)
			CombatAlerts.CastAlertsStart(CombatAlertsData.sunspire.meteorIcon, string.format("%s / %s", CombatAlerts.tide.link1, targetName), 28000, nil, nil, { 28000, "", 1, 0, 1, 0.5, nil })
			CombatAlerts.tide.link1 = ""
		end
		overwritten = true
		
	--ScaleCaller Peak
	elseif (result == ACTION_RESULT_DAMAGE and abilityId == 100285 and CombatAlerts.scalecaller.ratAchEnabled and not CombatAlerts.scalecaller.isRatAchFailed) then
		if (CombatAlerts.units[targetUnitId]) then
			targetName = CombatAlerts.units[targetUnitId].name
		end
		
		CombatAlerts.AlertChat(string.format("Failed |H1:achievement:1984:0:0|h|h by %s", targetName))
		CombatAlerts.scalecaller.isRatAchFailed = true
	end
	
	if (overwritten) then
		return
	end
	
	base_CombatAlertsCombatEvent( eventCode, result, isError, abilityName, abilityGraphic, abilityActionSlotType, sourceName, sourceType, targetName, targetType, hitValue, powerType, damageType, log, sourceUnitId, targetUnitId, abilityId )
end

function CombatAlerts.Poll()
	local db = CombatAlertsExtended.savedVariables.Settings
	
	-- Coral Aerie
	if (CombatAlerts.zoneId == 1301 and db.CoralAerie.MentalWound) then
		local currentTime = GetGameTimeMilliseconds()
		
		if (CombatAlerts.panel.tag == "varallion") then 
			time = CombatAlerts.at.dotStarted - currentTime

			if (time < -30000) then
				CombatAlerts.panel.rows[1].data:SetText("INCOMING")
				CombatAlerts.panel.SetRowColor(1, 1, 0, 0, 1)
			else
				CombatAlerts.panel.rows[1].data:SetText(string.format("NEXT: %ss", zo_floor((30000 - (-1 * time)) / 1000)))
				CombatAlerts.panel.SetRowColor(1, 0, 1, 0, 1)
			end
		end
		
	end
	
	base_CombatAlertsPoll()
end

em:RegisterForEvent("CombatAlertsExtendedLoaded", EVENT_ADD_ON_LOADED, CombatAlertsExtended.AddonLoaded)