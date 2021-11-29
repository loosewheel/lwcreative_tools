local utils = ...



local function fill_node (map, x, y, action, pos, radius, item, dir, player, ptdir)
	if not map[x][y].match or utils.is_protected (map[x][y].pos, player) then
		map[x][y].match = false

		return true
	end

	local dist = vector.distance (pos, map[x][y].pos)

	if dist <= radius then
		local under_pos = vector.add (map[x][y].pos, utils.rotate_to_dir ({ x = 0, y = 0, z = 1 }, dir))
		local node = utils.get_far_node (under_pos)
		local def = (node and utils.find_item_def (node.name)) or nil

		if (node and node.name ~= "air") and (def and def.walkable) then
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
				if not fill_node (map, x + 1, y, action, pos, radius, item, dir, player, ptdir) then
					return false
				end
			end

			if (x - 1) >= map.min_x then
				if not fill_node (map, x - 1, y, action, pos, radius, item, dir, player, ptdir) then
					return false
				end
			end

			if (y + 1) <= map.max_y then
				if not fill_node (map, x, y + 1, action, pos, radius, item, dir, player, ptdir) then
					return false
				end
			end

			if (y - 1) >= map.min_y then
				if not fill_node (map, x, y - 1, action, pos, radius, item, dir, player, ptdir) then
					return false
				end
			end
		end
	end


	return true
end



local function fill (pos, item, radius, dir, player, pointed_thing)
	local action = utils.new_action (player:get_player_name ())

	if action then
		local map = utils.map_nodes (pos, radius, dir, "air", true)
		local ptdir = vector.subtract (pointed_thing.under, pointed_thing.above)

		fill_node (map, 0, 0, action, pos, radius, item, dir, player, ptdir)

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

		fill (above, stack, count, point_dir, placer, pointed_thing)

		minetest.log ("action", string.format ("lwcreative_tools area fill by %s with %s at %s, radius %d",
															placer:get_player_name (),
															(type (stack) == "string" and stack) or stack:get_name (),
															minetest.pos_to_string (above, 0),
															count + 1))
	end
end



local function on_use (itemstack, user, pointed_thing)
	return utils.on_use (itemstack, user, pointed_thing, utils.settings.max_block_radius)
end



minetest.register_craftitem ("lwcreative_tools:fill", {
	description = "Area Fill",
	short_description = "Area Fill",
	groups = { },
	inventory_image = "lwcreative_tools_fill.png",
	wield_image = "lwcreative_tools_fill.png",
	stack_max = utils.settings.max_block_radius,
	on_place = on_place,
	on_use = on_use,
})
