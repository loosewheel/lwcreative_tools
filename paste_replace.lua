local utils = ...



function paste_replace (pos, map, dir, player, param2)
	local action = utils.new_action (player:get_player_name ())

	if action then
		for y = 0, map.leny - 1 do
			for z = 0, map.lenz - 1 do
				for x = 0, map.lenx - 1 do
					local node_pos = vector.add (pos, utils.rotate_to_dir ({ x = x, y = y, z = z }, dir))
					local node = utils.get_far_node (node_pos)

					if node then
						if not action:place_node_from_data (node_pos, map[y][z][x], (param2 - map.param2 + 4) % 4) then
							utils.commit_action (action)

							return false
						end
					end
				end
			end
		end

		utils.commit_action (action)

		return true
	end

	return false
end



local function on_place (itemstack, placer, pointed_thing)
	if not utils.is_creative (placer) or
		not utils.check_privs (placer) then

		return nil
	end

	local count = itemstack:get_count ()
	local look_dir, point_dir, under, above = utils.get_place_stats (placer, pointed_thing)

	if look_dir.x ~= 0 or look_dir.z ~= 0 then
		look_dir.y = 0
		local param2 = minetest.dir_to_facedir (vector.normalize (look_dir))

		if count and look_dir then
			local on_rightclick = utils.get_on_rightclick (under, placer)
			if on_rightclick then
				return on_rightclick (under, utils.get_far_node (under), placer, itemstack, pointed_thing)
			end

			local map = utils.get_player_copy_buffer (placer)

			if map then
				paste_replace (under, map, look_dir, placer, param2)

				minetest.log ("action", string.format ("lwcreative_tools paste replace by %s at %s",
																	placer:get_player_name (),
																	minetest.pos_to_string (under, 0)))
			end
		end
	end
end



minetest.register_craftitem ("lwcreative_tools:paste_replace", {
	description = "Paste Replace",
	short_description = "Paste Replace",
	groups = { },
	inventory_image = "lwcreative_tools_paste_replace.png",
	wield_image = "lwcreative_tools_paste_replace.png",
	stack_max = 1,
	on_place = on_place,
})
