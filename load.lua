local utils = ...



local function on_secondary_use (itemstack, placer, pointed_thing)
	if not utils.is_creative (placer) or
		not utils.check_privs (placer) then

		return nil
	end

	local spec =
	"formspec_version[3]"..
	"size[7.0,4.3,false]"..
	"field[1.0,1.5;5.0,0.8;map_name;Open;]\n"..
	"button_exit[2.25,2.5;2.5,0.8;load;Load]"

	minetest.show_formspec (placer:get_player_name (), "lwcreative_tools:load", spec)

	return itemstack
end



local function on_place (itemstack, placer, pointed_thing)
	if not utils.is_creative (placer) or
		not utils.check_privs (placer) then

		return nil
	end

	local on_rightclick = utils.get_on_rightclick (pointed_thing.under, placer)
	if on_rightclick then
		return on_rightclick (pointed_thing.under, utils.get_far_node (pointed_thing.under), placer, itemstack, pointed_thing)
	end

	return on_secondary_use (itemstack, placer, pointed_thing)
end



local function on_use (itemstack, user, pointed_thing)
	return nil
end



minetest.register_craftitem ("lwcreative_tools:load", {
	description = "Load",
	short_description = "Load",
	groups = { },
	inventory_image = "lwcreative_tools_load.png",
	wield_image = "lwcreative_tools_load.png",
	stack_max = 1,
	on_place = on_place,
	on_secondary_use = on_secondary_use,
	on_use = on_use,
})



minetest.register_on_player_receive_fields (function (player, formname, fields)
   if formname == "lwcreative_tools:load" and player and player:is_player () then

		if fields.load and type (fields.map_name) == "string" and fields.map_name:len () > 0 then
			if utils.load_player_map (player, fields.map_name) then
				utils.player_message (player, string.format ("Copy buffer loaded from %s", fields.map_name))
			else
				utils.player_error_message (player, string.format ("An error occurred loading %s!", fields.map_name))
			end
		end

		return nil
	end
end)
