---@class ODAD : module
local M = {}


--#region Constatns
local random = math.random
--#endregion


--#region Settings
local __threshold_entity_HP = settings.global["ODAD_threshold_entity_HP"].value
local __chance = settings.global["ODAD_chance"].value
--#endregion


--#region Utils

local function check_stance_on_entity_damaged(event)
	local entity = event.entity
	local force = entity.force
	local killing_force = event.force
	if not force.get_cease_fire(killing_force) or killing_force == force then return end

	-- Find in list the teams
	-- local teams = storage.diplomacy.teams
	-- if teams then
	-- 	local found_1st = false
	-- 	local found_2nd = false
	-- 	for _, team in pairs(teams) do
	-- 		if force.name == team.name then
	-- 			found_1st = true
	-- 		elseif killing_force.name == team.name then
	-- 			found_2nd = true
	-- 		end
	-- 	end
	-- 	if not (found_1st and found_2nd) then return end
	-- end

	-- Change policy between teams and print information
	local cause = event.cause
	if not (cause and cause.valid) then

		if prototypes.entity[entity.name].max_health < __threshold_entity_HP then return end --entity.type == "rocket-silo"
		if not force.get_cease_fire(killing_force) then return end

		force.set_friend(killing_force, true)
		force.set_cease_fire(killing_force, true)
		killing_force.set_friend(force, true)
		killing_force.set_cease_fire(force, true)
		game.print({"team-changed-diplomacy", killing_force.name, force.name, {"enemy"}})
		killing_force.print({"player-changed-diplomacy", "ANY", force.name})
		force.print({"player-changed-diplomacy", "ANY", killing_force.name})
		return
	end

	if (prototypes.entity[entity.name].max_health < __threshold_entity_HP) then return end --entity.type == "rocket-silo"
	if not force.get_cease_fire(killing_force) then return end

	force.set_friend(killing_force, true)
	force.set_cease_fire(killing_force, true)
	killing_force.set_friend(force, true)
	killing_force.set_cease_fire(force, true)
	game.print({"team-changed-diplomacy", killing_force.name, force.name, {"enemy"}})
	if cause.type == "character" then
		killing_force.print({"player-changed-diplomacy", cause.player.name, force.name})
		force.print({"player-changed-diplomacy", cause.player.name, killing_force.name})
	elseif cause.type == "car" then
		local passenger = cause.get_passenger()
		local driver = cause.get_driver()
		if passenger and driver then
			killing_force.print({"player-changed-diplomacy", driver.player.name .. " & " .. passenger.player.name, force.name})
			force.print({"player-changed-diplomacy", driver.player.name .. " & " .. passenger.player.name, killing_force.name})
		elseif passenger then
			killing_force.print({"player-changed-diplomacy", passenger.player.name, force.name})
			force.print({"player-changed-diplomacy", passenger.player.name, killing_force.name})
		elseif driver then
			killing_force.print({"player-changed-diplomacy", driver.player.name, force.name})
			force.print({"player-changed-diplomacy", driver.player.name, killing_force.name})
		else
			killing_force.print({"player-changed-diplomacy", cause.localised_name, force.name})
			force.print({"player-changed-diplomacy", cause.localised_name, killing_force.name})
		end
	else
		killing_force.print({"player-changed-diplomacy", cause.localised_name, force.name})
		force.print({"player-changed-diplomacy", cause.localised_name, killing_force.name})
	end
end

local mod_settings = {
	ODAD_threshold_entity_HP = function(value)
		__threshold_entity_HP = value
	end,
	ODAD_chance = function(value)
		__chance = value
	end
}
local function on_runtime_mod_setting_changed(event)
	local f = mod_settings[event.setting]
	if f then f(settings.global[event.setting].value) end
end

--#endregion


--#region Functions of events

local function on_entity_damaged(event)
	if random(100) <= __chance then
		pcall(check_stance_on_entity_damaged, event)
	end
end

--#endregion


--#region Pre-game stage

local function set_filters()
	script.set_event_filter(defines.events.on_entity_damaged, {
		{filter = "final-damage-amount", comparison = ">", value = 1, mode = "and"},
		{filter = "type", type = "wall", invert = true, mode = "and"},
		{filter = "type", type = "gate", invert = true, mode = "and"},
		{filter = "type", type = "character", invert = true, mode = "and"},
		{filter = "type", type = "tree", invert = true, mode = "and"},
		{filter = "type", type = "unit", invert = true, mode = "and"},
		{filter = "type", type = "simple-entity", invert = true, mode = "and"},
		{filter = "damage-type", type = "fire", invert = true, mode = "and"},
		{filter = "damage-type", type = "acid", invert = true, mode = "and"},
		{filter = "damage-type", type = "physical", invert = true, mode = "and"}
	})
end

local function add_remote_interface()
	-- https://lua-api.factorio.com/latest/LuaRemote.html
	remote.remove_interface("ODAD") -- For safety
	remote.add_interface("ODAD", {})
end

M.on_init = set_filters
M.on_load = set_filters
M.on_mod_enabled = set_filters
M.on_mod_disabled = set_filters
M.add_remote_interface = add_remote_interface

--#endregion


M.events = {
	[defines.events.on_entity_damaged] = on_entity_damaged,
	[defines.events.on_runtime_mod_setting_changed] = on_runtime_mod_setting_changed
}
M.events_when_off = {
	[defines.events.on_runtime_mod_setting_changed] = on_runtime_mod_setting_changed
}


return M
