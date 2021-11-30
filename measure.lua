local utils = ...



local function on_place (itemstack, placer, pointed_thing)
	if not utils.is_creative (placer) or
		not utils.check_privs (placer) then

		return nil
	end

	local meta = itemstack:get_meta ()

	if meta then
		local phase = meta:get_int ("phase")

		if phase == 1 then
			local look_dir, point_dir, under, above = utils.get_place_stats (placer, pointed_thing)

			if look_dir then
				local on_rightclick = utils.get_on_rightclick (under, placer)
				if on_rightclick then
					return on_rightclick (under, utils.get_far_node (under), placer, itemstack, pointed_thing)
				end

				local center = minetest.string_to_pos (meta:get_string ("center"))
				local rot = vector.dir_to_rotation (vector.direction (center, under))

				utils.player_message (placer,
											 string.format ("NS: %d EW: %d  H: %d A: %0.1f  L: %0.1f",
																 math.floor (under.z - center.z),
																 math.floor (under.x - center.x),
																 math.floor (under.y - center.y),
																 rot.y * -180 / math.pi,
																 vector.distance (center, under)))
			end
		else
			utils.player_error_message (placer, "Measure reference not set!")
		end
	end

	return itemstack
end



local function on_use (itemstack, user, pointed_thing)
	if not utils.is_creative (user) or
		not utils.check_privs (user) then

		return nil
	end

	local meta = itemstack:get_meta ()

	if user and user:is_player () and meta and
		pointed_thing and pointed_thing.type == "node" then

		meta:set_string ("center", minetest.pos_to_string (pointed_thing.under, 0))
		meta:set_int ("phase", 1)

		utils.player_message (user, string.format ("Set measure reference to %s",
																 minetest.pos_to_string (pointed_thing.under, 0)))
	end

	return itemstack
end



minetest.register_craftitem ("lwcreative_tools:measure", {
	description = "Measure",
	short_description = "Measure",
	groups = { },
	inventory_image = "lwcreative_tools_measure.png",
	wield_image = "lwcreative_tools_measure.png",
	stack_max = 1,
	on_place = on_place,
	on_use = on_use,
})
