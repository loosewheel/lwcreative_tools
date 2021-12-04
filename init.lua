local version = "0.1.5"
local mod_storage = minetest.get_mod_storage ()



lwcreative_tools = { }



function lwcreative_tools.version ()
	return version
end


local utils = { }
local modpath = minetest.get_modpath ("lwcreative_tools")

loadfile (modpath.."/settings.lua") (utils)
loadfile (modpath.."/utils.lua") (utils)
loadfile (modpath.."/undo.lua") (utils)
loadfile (modpath.."/area_fill.lua") (utils)
loadfile (modpath.."/area_replace.lua") (utils)
loadfile (modpath.."/area_substitute.lua") (utils)
loadfile (modpath.."/linear_fill.lua") (utils)
loadfile (modpath.."/linear_replace.lua") (utils)
loadfile (modpath.."/linear_substitute.lua") (utils)
loadfile (modpath.."/copy_cube.lua") (utils)
loadfile (modpath.."/copy.lua") (utils)
loadfile (modpath.."/paste_replace.lua") (utils)
loadfile (modpath.."/paste_fill.lua") (utils)
loadfile (modpath.."/measure.lua") (utils)
if utils.settings.use_storage then
loadfile (modpath.."/save.lua") (utils)
loadfile (modpath.."/load.lua") (utils)
end



minetest.register_privilege ("lwcreative_tools", {
	description = "Allow creative tool usage.",
	give_to_singleplayer = true,
	give_to_admin = true,
	on_grant = function (name, granter_name)
		return false
	end,
	on_revoke = function (name, revoker_name)
		return false
	end,
})



minetest.register_chatcommand ("lwctundo", {
	params = "", -- Short parameter description
	description = "Undo last creative tool action.", -- Full description
	privs = { lwcreative_tools = true }, -- Require the "privs" privilege to run
	func = function (name, param)
		if name then
			if not utils.undo_action (name) then
				return false, "Nothing to undo."
			end
		end

		return true
	end,
})



minetest.register_chatcommand ("lwctclear", {
	params = "", -- Short parameter description
	description = "Clear last creative tool action (free memory).", -- Full description
	privs = { lwcreative_tools = true }, -- Require the "privs" privilege to run
	func = function (name, param)
		if name then
			if not utils.clear_action (name) then
				return false, "Nothing to clear."
			end
		end

		return true
	end,
})



--
