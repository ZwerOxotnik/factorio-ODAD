if script.level.campaign_name then return end

if script.active_mods["switchable_mods"] then
	require("__switchable_mods__/event_handler_vSM").add_lib(require("models/ODAD"))
else
	require("event_handler").add_lib(require("models/ODAD"))
end
