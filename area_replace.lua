local utils = ...



local function replace (pos, item, radius, dir, player, pointed_thing, square)
	local action = utils.new_action (player:get_player_name ())
	local ptdir = vector.subtract (pointed_thing.under, pointed_thing.above)

	if action then
		local extend = (square and radius) or (radius + 1)

		for x = -extend, extend, 1 do
			for y = -extend, extend, 1 do
				local node_pos = vector.add (pos, utils.rotate_to_dir ({ x = x, y = y, z = 0 }, dir))
				local dist = vector.distance (pos, node_pos)

				if (dist <= radius or square) and not utils.is_protected (node_pos, player) then
					local node = utils.get_far_node (node_pos)
					local def = (node and utils.find_item_def (node.name)) or nil

					if (node and node.name ~= "air") and (def and (def.walkable or def.liquidtype ~= "none")) then
						local pt =
						{
							type = "node",
							under = vector.new (node_pos),
							above = vector.subtract (node_pos, ptdir)
						}

						if not action:place_node (node_pos, item, player, pt) then
							utils.commit_action (action)

							return
						end
					end
				end
			end
		end

		utils.commit_action (action)
	end
end



local function on_place (itemstack, placer, pointed_thing)
	if not utils.is_creative (placer) or
		not utils.check_privs (placer) then

		return nil
	end

	local stack, count = utils.get_item_stats (itemstack, placer)
	local look_dir, point_dir, under, above, param2 = utils.get_place_stats (placer, pointed_thing)

	if count and look_dir then
		local on_rightclick = utils.get_on_rightclick (under, placer)
		if on_rightclick then
			return on_rightclick (under, utils.get_far_node (under), placer, itemstack, pointed_thing)
		end

		if not stack then
			stack = "air"
		end

		replace (under, stack, count, point_dir, placer, pointed_thing, placer:get_player_control ().aux1)

		minetest.log ("action", string.format ("lwcreative_tools area replace by %s with %s at %s, radius %d",
															placer:get_player_name (),
															(type (stack) == "string" and stack) or stack:get_name (),
															minetest.pos_to_string (under, 0),
															count + 1))
	end
end



local function on_use (itemstack, user, pointed_thing)
	return utils.on_use (itemstack, user, pointed_thing, utils.settings.max_block_radius)
end



minetest.register_craftitem ("lwcreative_tools:replace", {
	description = "Area Replace",
	short_description = "Area Replace",
	groups = { },
	inventory_image = "lwcreative_tools_replace.png",
	wield_image = "lwcreative_tools_replace.png",
	stack_max = utils.settings.max_block_radius,
	liquids_pointable = true,
	on_place = on_place,
	on_use = on_use,
})
