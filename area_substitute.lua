local utils = ...



local function substitute_node (map, x, y, action, pos, radius, item, dir, player, ptdir, square)
	if not map[x][y].match or utils.is_protected (map[x][y].pos, player) then
		map[x][y].match = false

		return true
	end

	local dist = vector.distance (pos, map[x][y].pos)

	if dist <= radius or square then
		local pt =
		{
			type = "node",
			under = vector.new (map[x][y].pos),
			above = vector.subtract (map[x][y].pos, ptdir)
		}

		if not action:place_node (map[x][y].pos, item, player, pt) then
			return false
		end

		map[x][y].match = false

		if (x + 1) <= map.max_x then
			if not substitute_node (map, x + 1, y, action, pos, radius, item, dir, player, ptdir, square) then
				return false
			end
		end

		if (x - 1) >= map.min_x then
			if not substitute_node (map, x - 1, y, action, pos, radius, item, dir, player, ptdir, square) then
				return false
			end
		end

		if (y + 1) <= map.max_y then
			if not substitute_node (map, x, y + 1, action, pos, radius, item, dir, player, ptdir, square) then
				return false
			end
		end

		if (y - 1) >= map.min_y then
			if not substitute_node (map, x, y - 1, action, pos, radius, item, dir, player, ptdir, square) then
				return false
			end
		end
	end

	return true
end



local function substitute (pos, item, radius, dir, player, pointed_thing, square)
	local node = utils.get_far_node (pos)

	if node then
		local action = utils.new_action (player:get_player_name ())

		if action then
			local map = utils.map_nodes (pos, radius, dir, node.name, false, false, square)
			local ptdir = vector.subtract (pointed_thing.under, pointed_thing.above)

			substitute_node (map, 0, 0, action, pos, radius, item, dir, player, ptdir, square)

			utils.commit_action (action)
		end
	end
end



local function on_place (itemstack, placer, pointed_thing)
	if not utils.is_creative (placer) or
		not utils.check_privs (placer) then

		return itemstack
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

		substitute (under, stack, count, point_dir, placer, pointed_thing, placer:get_player_control ().aux1)

		minetest.log ("action", string.format ("lwcreative_tools area substitute by %s with %s at %s, radius %d",
															placer:get_player_name (),
															(type (stack) == "string" and stack) or stack:get_name (),
															minetest.pos_to_string (under, 0),
															count + 1))
	end

	return itemstack
end



local function on_use (itemstack, user, pointed_thing)
	return utils.on_use (itemstack, user, pointed_thing, utils.settings.max_block_radius)
end



minetest.register_craftitem ("lwcreative_tools:substitute", {
	description = "Area Substitute",
	short_description = "Area Substitute",
	groups = { },
	inventory_image = "lwcreative_tools_substitute.png",
	wield_image = "lwcreative_tools_substitute.png",
	stack_max = utils.settings.max_block_radius,
	liquids_pointable = true,
	on_place = on_place,
	on_use = on_use,
})
