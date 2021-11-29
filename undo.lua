local utils = ...



local function remove_node (pos)
	local node_data = utils.get_node_data (pos)

	if node_data then
		local def = utils.find_item_def (node_data.node.name)

		if not def then
			return nil
		end

		if node_data.meta and node_data.drops and def and def.preserve_metadata then
			def.preserve_metadata (pos, node_data.node, minetest.get_meta (pos), node_data.drops)
		end

		minetest.remove_node (pos)

		return node_data
	end

	return nil
end



local function restore_node (pos, node_data)
	if node_data.node.name ~= "air" then
		local def = utils.find_item_def (node_data.node.name)

		if not def then
			return false
		end

		minetest.set_node (pos, node_data.node)

		if node_data.meta then
			local meta = minetest.get_meta (pos)

			if not meta then
				return false
			end

			meta:from_table (node_data.meta)
		end
	end

	return true
end



local function get_place_param2 (itemname, look_dir)
	local def = utils.find_item_def (itemname)

	if def and def.paramtype2 then
		if def.paramtype2 == "wallmounted" then
			return minetest.dir_to_wallmounted (look_dir)
		elseif def.paramtype2 == "facedir" then
			return minetest.dir_to_facedir (look_dir, false)
		end
	end

	return 0
end



local function place_node (pos, itemstack, placer, pointed_thing)
	if itemstack then
		local stack = ItemStack (itemstack)

		if stack then
			local def = utils.find_item_def (stack:get_name ())

			if not def then
				return nil
			end

			local placed = false

			if def and def.on_place then
				placed = pcall (def.on_place, stack, placer, pointed_thing)

				if placed and def.after_place_node then
					pcall (def.after_place_node, pt.under, placer, stack, pointed_thing)
				end
			end

			if not placed then
				local param2 = get_place_param2 (stack:get_name (), vector.normalize (placer:get_look_dir ()))

				minetest.set_node (pos, { name = stack:get_name (), param2 = param2 })

				if def.after_place_node then
					pcall (def.after_place_node, pos, placer, stack, pointed_thing)
				end
			end
		end
	end

	return utils.get_node_data (pos)
end



local function place_node_from_data (pos, node_data, rotation)
	if node_data.node.name ~= "air" then
		local def = utils.find_item_def (node_data.node.name)

		if not def then
			return false
		end

		local node = table.copy (node_data.node)

		-- adjust param2
		if def.paramtype2 == "wallmounted" or
			def.paramtype2 == "colorwallmounted" then

			if (node.param2 % 8) > 1 then
				local color = math.floor (node.param2 / 8) * 8

				local wall_to_face =
				{
					[2] = 1,
					[3] = 3,
					[4] = 0,
					[5] = 2
				}

				local face_to_wall =
				{
					[0] = 4,
					[1] = 2,
					[2] = 5,
					[3] = 3
				}

				node.param2 = face_to_wall[(wall_to_face[node.param2 % 8] + rotation) % 4] + color
			end

		elseif def.paramtype2 == "facedir" or
				 def.paramtype2 == "colorfacedir" then

			local color = math.floor (node.param2 / 32) * 32
			local axis = math.floor (node.param2 / 4) % 8

			if axis == 0 then
				node.param2 = (((node.param2 % 4) + rotation) % 4) + (axis * 4) + color
			elseif axis == 5 then
				node.param2 = ((((node.param2 % 4) + 4) - rotation) % 4) + (axis * 4) + color
			elseif axis >= 1 and axis <= 4 then
				local axis_to_face =
				{
					[1] = 0,
					[2] = 2,
					[3] = 1,
					[4] = 3
				}

				local face_to_axis =
				{
					[0] = 1,
					[1] = 3,
					[2] = 2,
					[3] = 4
				}

				node.param2 = (face_to_axis[(axis_to_face[axis] + rotation) % 4] * 4) +
									(node.param2 % 4) + color
			end

		end

		minetest.set_node (pos, node)

		if node_data.meta then
			local meta = minetest.get_meta (pos)

			if not meta then
				return false
			end

			meta:from_table (node_data.meta)
		end
	end

	return utils.get_node_data (pos)
end



local function destroy_buffer_drops (buffer)
	for i = #buffer, 1, -1 do
		local drops = buffer[i].drops

		if drops then
			for j = 1, #drops do
				utils.on_destroy (drops[j])
			end
		end
	end
end





local undo_entry = { }



-- constructor
function undo_entry:new (player_name)
	if type (player_name) ~= "string" or player_name:len () < 1 then
		return nil
	end

	local obj = { }

   setmetatable(obj, self)
   self.__index = self

	obj.player_name = player_name
	obj.buffer = { }

	return obj
end



function undo_entry:add (pos, placed, removed)
	self.buffer[#self.buffer + 1] =
	{
		placed = placed,
		removed = removed,
		pos = { x = pos.x, y = pos.y, z = pos.z }
	}
end





local undo_action = { }



-- constructor
function undo_action:new (player_name)
	if type (player_name) ~= "string" or player_name:len () < 1 then
		return nil
	end

	local obj = { }

   setmetatable(obj, self)
   self.__index = self

	obj.undo_entry = undo_entry:new (player_name)

	return obj
end



function undo_action:place_node (pos, itemstack, placer, pointed_thing)
	local stack = nil

	if not (type (itemstack) == "string" and itemstack == "air") then
		stack = ItemStack (itemstack)

		if not itemstack then
			-- unwind
			return false
		end
	end

	local removed = remove_node (vector.new (pos))

	if removed then
		local placed = place_node (vector.new (pos), stack, placer, pointed_thing)

		if placed then
			self.undo_entry:add (pos, placed, removed)

			return true
		end

		restore_node (pos, removed)
	end

	return false
end



function undo_action:place_node_from_data (pos, node_data, rotation)
	local removed = remove_node (vector.new (pos))

	if removed then
		local placed = place_node_from_data (vector.new (pos), node_data, rotation)

		if placed then
			self.undo_entry:add (pos, placed, removed)

			return true
		end

		restore_node (pos, removed)
	end

	return false
end





local undo = { }



-- constructor
function undo:new ()
	local obj = { }

   setmetatable(obj, self)
   self.__index = self

	obj.list = { }

	return obj
end



function undo:add_action (action)
	if action and action.undo_entry then
		-- check entries for player
		if utils.settings.undo_limit > 0 then
			local player_list = self.list[action.undo_entry.player_name]

			if not player_list then
				player_list = { }
				self.list[action.undo_entry.player_name] = player_list
			end

			if #player_list > (utils.settings.undo_limit - 1) then
				table.remove (player_list, #player_list)
			end

			table.insert (player_list, 1, action.undo_entry.buffer)
		end

		return true
	end
end



function undo:undo (player_name)
	local player_list = self.list[player_name]

	if player_list and #player_list > 0 then
		local buffer = player_list[1]

		if buffer then
			for i = #buffer, 1, -1 do
				local node = utils.get_far_node (buffer[i].pos)

				if node and node.name == buffer[i].placed.node.name then
					remove_node (buffer[i].pos)
					restore_node (buffer[i].pos, buffer[i].removed)
					destroy_buffer_drops (buffer[i])
				end
			end

			table.remove (player_list, 1)

			return true
		end
	end

	return false
end



function undo:clear (player_name)
	local player_list = self.list[player_name]

	if player_list and #player_list > 0 then
		table.remove (player_list, 1)

		return true
	end

	return false
end





local undo_obj = undo:new ()



function utils.new_action (player_name)
	return undo_action:new (player_name)
end



function utils.commit_action (action)
	return undo_obj:add_action (action)
end



function utils.undo_action (player_name)
	return undo_obj:undo (player_name)
end



function utils.clear_action (player_name)
	return undo_obj:clear (player_name)
end



--
