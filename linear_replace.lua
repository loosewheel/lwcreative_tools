local utils = ...



local function replace (pos, item, length, dir, player, pointed_thing)
	local action = utils.new_action (player:get_player_name ())
	local ptdir = vector.subtract (pointed_thing.under, pointed_thing.above)

	if action then
		for i = 0, length - 1, 1 do
			local node_pos = vector.add (pos, utils.rotate_to_dir ({ x = 0, y = 0, z = i }, dir))
			local node = utils.get_far_node (node_pos)
			local pt =
			{
				type = "node",
				under = vector.new (node_pos),
				above = vector.subtract (node_pos, ptdir)
			}

			if node then
				if not action:place_node (node_pos, item, player, pt) then
					utils.commit_action (action)

					return false
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

		return itemstack
	end

	local stack, count = utils.get_item_stats (itemstack, placer)
	local look_dir, _, under, above = utils.get_place_stats (placer, pointed_thing)

	if count and look_dir then
		local on_rightclick = utils.get_on_rightclick (under, placer)
		if on_rightclick then
			return on_rightclick (under, utils.get_far_node (under), placer, itemstack, pointed_thing)
		end

		if not stack then
			stack = "air"
		end

		replace (under, stack, count, look_dir, placer, pointed_thing)

		minetest.log ("action", string.format ("lwcreative_tools linear replace by %s with %s at %s, length %d",
															placer:get_player_name (),
															(type (stack) == "string" and stack) or stack:get_name (),
															minetest.pos_to_string (above, 0),
															count + 1))
	end

	return itemstack
end



local function on_use (itemstack, user, pointed_thing)
	return utils.on_use (itemstack, user, pointed_thing, utils.settings.max_block_length)
end



minetest.register_craftitem ("lwcreative_tools:linear_replace", {
	description = "Linear Replace",
	short_description = "Linear Replace",
	groups = { },
	inventory_image = "lwcreative_tools_linear_replace.png",
	wield_image = "lwcreative_tools_linear_replace.png",
	stack_max = utils.settings.max_block_length,
	liquids_pointable = true,
	on_place = on_place,
	on_use = on_use,
})
