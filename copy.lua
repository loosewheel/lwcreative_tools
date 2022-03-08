local utils = ...



local function on_place (itemstack, placer, pointed_thing)
	if not utils.is_creative (placer) or
		not utils.check_privs (placer) then

		return itemstack
	end

	local meta = itemstack:get_meta ()

	if meta then
		local phase = meta:get_int ("phase")

		if phase == 1 then
			local look_dir, _, under = utils.get_place_stats (placer, pointed_thing)

			if look_dir then
				local on_rightclick = utils.get_on_rightclick (under, placer)
				if on_rightclick then
					return on_rightclick (under, utils.get_far_node (under), placer, itemstack, pointed_thing)
				end

				local pos1 = minetest.string_to_pos (meta:get_string ("pos1"))
				local pos2 = table.copy (under)

				if pos2.y < pos1.y then
					local y = pos2.y
					pos2.y = pos1.y
					pos1.y = y
				end

				if (math.abs (pos2.x - pos1.x) * math.abs (pos2.y - pos1.y) *
					 math.abs (pos2.z - pos1.z)) > utils.settings.max_copy_volume then

					utils.player_error_message (placer, "Volume to large to copy! Copy cancelled.")
					meta:set_int ("phase", 0)

					return itemstack
				end

				local param2 = 0

				if pos2.x >= pos1.x and pos2.z < pos1.z then
					param2 = 1
				elseif pos2.x < pos1.x and pos2.z < pos1.z then
					param2 = 2
				elseif pos2.x < pos1.x and pos2.z >= pos1.z then
					param2 = 3
				end

				meta:set_int ("phase", 0)

				if utils.set_player_copy_buffer (placer, pos1, pos2, param2) then
					utils.player_message (placer, string.format ("Copied %s to %s",
																				minetest.pos_to_string (pos1, 0),
																				minetest.pos_to_string (pos2, 0)))

					minetest.log ("action", string.format ("lwcreative_tools copy by %s, %s to %s",
																		placer:get_player_name (),
																		minetest.pos_to_string (under, 0),
																		minetest.pos_to_string (pos2, 0)))
				end
			end

		else
			local _, _, under = utils.get_place_stats (placer, pointed_thing)

			if under then
				local on_rightclick = utils.get_on_rightclick (under, placer)
				if on_rightclick then
					return on_rightclick (under, utils.get_far_node (under), placer, itemstack, pointed_thing)
				end

				meta:set_string ("pos1", minetest.pos_to_string (under, 0))
				meta:set_int ("phase", 1)

				utils.player_message (placer, string.format ("Set first position of copy %s",
																			minetest.pos_to_string (under, 0)))
			end
		end
	end

	return itemstack
end



local function on_use (itemstack, user, pointed_thing)
	return nil
end



minetest.register_craftitem ("lwcreative_tools:copy", {
	description = "Copy",
	short_description = "Copy",
	groups = { },
	inventory_image = "lwcreative_tools_copy.png",
	wield_image = "lwcreative_tools_copy.png",
	stack_max = 1,
	on_place = on_place,
	on_use = on_use,
})
