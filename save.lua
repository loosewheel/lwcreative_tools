local utils = ...



local function on_secondary_use (itemstack, placer, pointed_thing)
	if not utils.is_creative (placer) or
		not utils.check_privs (placer) then

		return nil
	end

	local spec =
	"formspec_version[3]"..
	"size[7.0,4.3,false]"..
	"field[1.0,1.0;5.0,0.8;map_name;Save as;]\n"..
	"button_exit[2.25,2.5;2.5,0.8;save;Save]"

	minetest.show_formspec (placer:get_player_name (), "lwcreative_tools:save", spec)

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



minetest.register_craftitem ("lwcreative_tools:save", {
	description = "Save",
	short_description = "Save",
	groups = { },
	inventory_image = "lwcreative_tools_save.png",
	wield_image = "lwcreative_tools_save.png",
	stack_max = 1,
	on_place = on_place,
	on_secondary_use = on_secondary_use,
	on_use = on_use,
})



minetest.register_on_player_receive_fields (function (player, formname, fields)
   if formname == "lwcreative_tools:save" and player and player:is_player () then

		if fields.save and type (fields.map_name) == "string" and fields.map_name:len () > 0 then
			if utils.save_player_map (player, fields.map_name) then
				minetest.chat_send_player (player:get_player_name (),
													string.format ("Copy buffer saved as %s", fields.map_name))

				minetest.log ("action", string.format ("lwcreative_tools %s saved by %s",
																	fields.map_name,
																	player:get_player_name ()))
			else
				minetest.chat_send_player (player:get_player_name (),
													string.format ("An error occurred saving %s", fields.map_name))
			end
		end

		return nil
	end
end)
