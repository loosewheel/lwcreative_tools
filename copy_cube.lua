local utils = ...



local function on_place (itemstack, placer, pointed_thing)
	if not utils.is_creative (placer) or
		not utils.check_privs (placer) then

		return nil
	end

	local count = itemstack:get_count ()
	local look_dir, point_dir, under, above = utils.get_place_stats (placer, pointed_thing)
	local param2 = minetest.dir_to_facedir (vector.normalize (placer:get_look_dir ()))

	if count and look_dir then
		local on_rightclick = utils.get_on_rightclick (under, placer)
		if on_rightclick then
			return on_rightclick (under, utils.get_far_node (under), placer, itemstack, pointed_thing)
		end

		local pos2 =
			vector.add (under,
							utils.rotate_to_dir ({ x = count - 1, y = count - 1, z = count - 1 },
														look_dir))

		if utils.set_player_copy_buffer (placer, under, pos2, param2) then
			minetest.chat_send_player (placer:get_player_name (),
												string.format ("Copied %s to %s",
																	minetest.pos_to_string (under, 0),
																	minetest.pos_to_string (pos2, 0)))

			minetest.log ("action", string.format ("lwcreative_tools copy by %s, %s to %s",
																placer:get_player_name (),
																minetest.pos_to_string (under, 0),
																minetest.pos_to_string (pos2, 0)))
		end
	end
end



local function on_use (itemstack, user, pointed_thing)
	return utils.on_use (itemstack, user, pointed_thing, utils.settings.max_copy_cube)
end



minetest.register_craftitem ("lwcreative_tools:copy_cube", {
	description = "Copy Cube",
	short_description = "Copy Cube",
	groups = { },
	inventory_image = "lwcreative_tools_copy_cube.png",
	wield_image = "lwcreative_tools_copy_cube.png",
	stack_max = utils.settings.max_copy_cube,
	on_place = on_place,
	on_use = on_use,
})
