local base_CombatAlertsCombatEvent = CombatAlerts.CombatEvent

function CombatAlerts.CombatEvent( eventCode, result, isError, abilityName, abilityGraphic, abilityActionSlotType, sourceName, sourceType, targetName, targetType, hitValue, powerType, damageType, log, sourceUnitId, targetUnitId, abilityId )
	local overwritten = false;
	
	-- some test
	if (result == ACTION_RESULT_BEGIN and abilityId == 165849) then
		-- CHAT_ROUTER:AddSystemMessage(string.format("event %d result %d abilityName %s sourceName %s sourceType %d hitValue %d powerType %d damageType %d sourceUnitId %d targetUnitId %d abilityId %d",eventCode, result, abilityName, sourceName, sourceType, hitValue, powerType, damageType, sourceUnitId, targetUnitId, abilityId))
	end
	
	-- Ascending Tide
	
	if (result == ACTION_RESULT_BEGIN and abilityId == 165849 and hitValue == 1000) then 
		CombatAlerts.Alert(nil, GetAbilityName(abilityId), 0xFFD700FF, SOUNDS.DUEL_START, 1500)
		overwritten = true
	elseif (result == ACTION_RESULT_EFFECT_GAINED and abilityId == CombatAlertsData.at.bomb2) then
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
	elseif (result == ACTION_RESULT_BEGIN and abilityId == 158909) then
		CombatAlerts.AlertCast(abilityId, nil, hitValue + 1000, { -2, 2 })
		overwritten = true
	elseif (result == ACTION_RESULT_EFFECT_GAINED and CombatAlertsData.at.links[abilityId]) then
		if (CombatAlerts.units[targetUnitId]) then
			targetName = CombatAlerts.units[targetUnitId].name
		end
		if (CombatAlertsData.at.links[abilityId] == 1) then
			CombatAlerts.tide.link1 = targetName
		else
			CombatAlerts.Alert(GetFormattedAbilityName(abilityId), string.format("%s / %s", CombatAlerts.tide.link1, targetName), 0xCC3399FF, SOUNDS.CHAMPION_POINTS_COMMITTED, 2000)
			CombatAlerts.CastAlertsStart(GetAbilityIcon(abilityId), string.format("%s / %s", CombatAlerts.tide.link1, targetName), 28000, nil, nil, { 28000, "", 1, 0, 1, 0.5, nil })
			CombatAlerts.tide.link1 = ""
		end
		overwritten = true
	end
	
	if (overwritten) then
		return
	end
	
	base_CombatAlertsCombatEvent( eventCode, result, isError, abilityName, abilityGraphic, abilityActionSlotType, sourceName, sourceType, targetName, targetType, hitValue, powerType, damageType, log, sourceUnitId, targetUnitId, abilityId )
end