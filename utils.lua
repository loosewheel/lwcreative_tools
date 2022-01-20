local utils = ...



if minetest.get_translator and minetest.get_translator ("lwcreative_tools") then
	utils.S = minetest.get_translator ("lwcreative_tools")
elseif minetest.global_exists ("intllib") then
   if intllib.make_gettext_pair then
      utils.S = intllib.make_gettext_pair ()
   else
      utils.S = intllib.Getter ()
   end
else
   utils.S = function (s) return s end
end



function utils.on_destroy (itemstack)
	local stack = ItemStack (itemstack)

	if stack and stack:get_count () > 0 then
		local def = utils.find_item_def (stack:get_name ())

		if def and def.on_destroy then
			def.on_destroy (stack)
		end
	end
end



function utils.player_message (player, msg)
	local name = nil

	if type (player) == "string" then
		name = player
	elseif player and player:is_player () then
		name = player:get_player_name ()
	else
		return
	end

	minetest.chat_send_player (name, tostring (msg))
end



function utils.player_error_message (player, msg)
	utils.player_message (player, minetest.colorize ("#FF0000FF", tostring (msg)))
end



function utils.get_far_node (pos)
	local node = minetest.get_node (pos)

	if node.name == "ignore" then
		minetest.get_voxel_manip ():read_from_map (pos, pos)

		node = minetest.get_node (pos)

		if node.name == "ignore" then
			return nil
		end
	end

	return node
end



function utils.is_creative (player)
	if minetest.settings:get_bool ("creative_mode") then
		return true
	end

	if player and player:is_player () then
		if minetest.is_creative_enabled (player:get_player_name ()) or
			minetest.check_player_privs (player, "creative") then

			return true
		end

		utils.player_error_message (player, "Must be in creative mode to use this tool.")
	end

	return false
end



function utils.is_protected (pos, player)
	local name = (player and player:get_player_name ()) or ""

	return minetest.is_protected (pos, name)
end



function utils.check_privs (player)
	local name = (player and player:get_player_name ()) or ""

	if name:len () > 0 then
		if minetest.get_player_privs (name).lwcreative_tools == true then
			return true
		end

		utils.player_error_message (name, "Privilege lwcreative_tools required to use this tool.")
	end

	return false
end



function utils.get_on_rightclick (pos, player)
	local node = utils.get_far_node (pos)

	if node then
		local def = minetest.registered_nodes[node.name]

		if def and def.on_rightclick and
			not (player and player:is_player () and
				  player:get_player_control ().sneak) then

				return def.on_rightclick
		end
	end

	return nil
end



function utils.find_item_def (name)
	local def = minetest.registered_items[name]

	if not def then
		def = minetest.registered_craftitems[name]
	end

	if not def then
		def = minetest.registered_nodes[name]
	end

	if not def then
		def = minetest.registered_tools[name]
	end

	return def
end



function utils.rotate_to_dir (pos, dir)
	local rot = vector.dir_to_rotation (vector.normalize (dir))

	return vector.rotate (pos, rot)
end



function utils.map_nodes (pos, radius, dir, match_node_name, buildable_to, liquid, square)
	local extend = (square and radius) or (radius + 1)
	local map = { min_x = -extend, max_x = extend,
					  min_y = -extend, max_y = extend }

	for x = -extend, extend, 1 do
		map[x] = { }

		for y = -extend, extend, 1 do
			local node_pos = vector.add (pos, utils.rotate_to_dir ({ x = x, y = y, z = 0 }, dir))
			local node = utils.get_far_node (node_pos)
			local def = (node and utils.find_item_def (node.name)) or nil
			local match = false

			if match_node_name then
				match = (node and node.name == match_node_name) or
						  (def and ((buildable_to and def.buildable_to) or
										(liquid and def.liquidtype ~= "none")))
			else
				match = (node and node.name ~= "air") or
						  (def and ((buildable_to and def.buildable_to) or
										(liquid and def.liquidtype ~= "none")))
			end

			map[x][y] = { match = match, pos = node_pos }
		end
	end

	return map
end



function utils.copy_section (pos1, pos2, param2)
	local map = nil

	if param2 == 3 or param2 == 1 then
		local incx = (pos2.z < pos1.z and -1) or 1
		local incy = (pos2.y < pos1.y and -1) or 1
		local incz = (pos2.x < pos1.x and -1) or 1
		local lenx = math.abs (pos2.z - pos1.z)
		local leny = math.abs (pos2.y - pos1.y)
		local lenz = math.abs (pos2.x - pos1.x)

		map = { lenx = lenx + 1, leny = leny + 1, lenz = lenz + 1, param2 = param2 }

		for y = 0, leny do
			map[y] = { }

			for z = 0, lenz do
				map[y][z] = { }

				for x = 0, lenx do
					local pos =
					{
						x = pos1.x + (z * incz),
						y = pos1.y + (y * incy),
						z = pos1.z + (x * incx)
					}

					local node_data = utils.get_node_data (pos)
					node_data.drops = nil

					map[y][z][x] = node_data
				end
			end
		end
	else
		local incx = (pos2.x < pos1.x and -1) or 1
		local incy = (pos2.y < pos1.y and -1) or 1
		local incz = (pos2.z < pos1.z and -1) or 1
		local lenx = math.abs (pos2.x - pos1.x)
		local leny = math.abs (pos2.y - pos1.y)
		local lenz = math.abs (pos2.z - pos1.z)

		map = { lenx = lenx + 1, leny = leny + 1, lenz = lenz + 1, param2 = param2 }

		for y = 0, leny do
			map[y] = { }

			for z = 0, lenz do
				map[y][z] = { }

				for x = 0, lenx do
					local pos =
					{
						x = pos1.x + (x * incx),
						y = pos1.y + (y * incy),
						z = pos1.z + (z * incz)
					}

					local node_data = utils.get_node_data (pos)
					node_data.drops = nil

					map[y][z][x] = node_data
				end
			end
		end
	end

	return map
end



local player_copy_buffer = { }



function utils.set_player_copy_buffer (player, pos1, pos2, param2)
	if player and player:is_player () then
		player_copy_buffer[player:get_player_name ()] = utils.copy_section (pos1, pos2, param2)

		return true
	end

	return false
end



function utils.get_player_copy_buffer (player)
	if player and player:is_player () then
		return player_copy_buffer[player:get_player_name ()]
	end

	return nil
end



local function for_file_path (s)
	s = tostring (s)

	s = s:gsub (":", "_")
	s = s:gsub ("?", "_")
	s = s:gsub ("*", "_")
	s = s:gsub ("/", "_")
	s = s:gsub ("\\", "_")

	return s
end



function utils.saved_maps_folder (player_name)
	local maps_folder = minetest.get_worldpath ().."/lwcreative_tools"

	minetest.mkdir (maps_folder)

	if type (player_name) == "string" then
		maps_folder = maps_folder.."/"..for_file_path (player_name)

		minetest.mkdir (maps_folder)
	end

	return maps_folder
end



function utils.save_map_exists (player, map_name)
	if type (map_name) == "string" and player and player:is_player () then
		local maps_folder = utils.saved_maps_folder (player:get_player_name ())

		if maps_folder then
			local map_file = maps_folder.."/"..for_file_path (map_name)
			local file = io.open (map_file, "r")

			if file then
				file:close ()

				return true
			end
		end
	end

	return false
end



function utils.save_map (player, map_name, map)
	if type (map_name) == "string" and player and player:is_player () then
		local maps_folder = utils.saved_maps_folder (player:get_player_name ())
		local success, result = pcall (minetest.serialize, map)

		if maps_folder and success and result then
			local map_file = maps_folder.."/"..for_file_path (map_name)
			local file = io.open (map_file, "w")

			if file then
				file:write (result)

				file:close ()

				return true
			end
		end
	end

	return false
end



function utils.load_map (player, map_name)
	local map = nil

	if type (map_name) == "string" and player and player:is_player () then
		local maps_folder = utils.saved_maps_folder (player:get_player_name ())

		if maps_folder then
			local map_file = maps_folder.."/"..for_file_path (map_name)
			local file = io.open (map_file, "r")

			if file then
				local contents = file:read ("*a")

				if contents then
					local success, result = pcall (minetest.deserialize, contents)

					if success then
						map = result
					end
				end

				file:close ()
			end
		end
	end

	return map
end



function utils.save_player_map (player, map_name)
	if type (map_name) == "string" and player and player:is_player () then
		local map = utils.get_player_copy_buffer (player)

		if map then
			return utils.save_map (player, map_name, map)
		end
	end

	return false
end



function utils.load_player_map (player, map_name)
	if type (map_name) == "string" and player and player:is_player () then
		local map = utils.load_map (player, map_name)

		if map then
			player_copy_buffer[player:get_player_name ()] = map

			return true
		end
	end

	return false
end



function utils.get_node_data (pos)
	local node = utils.get_far_node (pos)

	if node then
		if node.name ~= "air" then
			local def = utils.find_item_def (node.name)

			if def then
				local meta_table = nil
				local drops = nil

				local has_meta = minetest.find_nodes_with_meta (pos, pos)

				if has_meta and #has_meta > 0 then
					local meta = minetest.get_meta (pos)

					if not meta then
						return nil
					end

					meta_table = meta:to_table ()

					if meta_table and meta_table.inventory then
						for list, inv in pairs (meta_table.inventory) do
							if type (inv) == "table" then
								for slot, item in pairs (inv) do
									if type (item) == "userdata" then
										inv[slot] = item:to_string ()
									end
								end
							end
						end
					end
				end

				local items = minetest.get_node_drops (node, nil)

				if items then
					drops = { }

					for i = 1, #items do
						drops[i] = ItemStack (items[i])
					end
				end

				return { node = node, meta = meta_table, drops = drops }
			end
		else
			return { node = { name = "air" } }
		end
	end

	return nil
end



function utils.get_place_stats (player, pointed_thing)
	if player and player:is_player () and pointed_thing and
		pointed_thing.type == "node" then

		local above = vector.new (pointed_thing.above)
		local under = vector.new (pointed_thing.under)
		local param2 = minetest.dir_to_wallmounted (vector.normalize (player:get_look_dir ()))
		local look_dir = minetest.wallmounted_to_dir (param2)
		local point_dir = vector.direction (above, under)
		local node = utils.get_far_node (under)

		if not node then
			return nil
		end

		if node.name == "air" then
			return nil
		else
			local def = minetest.registered_nodes[node.name]

			if not def then
				return nil
			end

			if def.buildable_to and def.liquidtype == "none" then
				above = under
				under = vector.add (under, point_dir)
				node = utils.get_far_node (under)

				if not node then
					return nil
				end

				if node.name == "air" then
					return nil
				else
					def = minetest.registered_nodes[node.name]

					if not def then
						return nil
					end
				end
			end
		end

		return look_dir, point_dir, under, above, param2
	end

	return
end



function utils.get_item_stats (itemstack, player)
	if player and player:is_player () then
		local inv = player:get_inventory ()
		local list = player:get_wield_list ()
		local idx = player:get_wield_index ()

		if inv and idx > 1 then
			local count = itemstack:get_count ()
			local stack = inv:get_stack (list, idx - 1)

			if stack and not stack:is_empty () then
				if minetest.registered_nodes[stack:get_name ()] then
					return stack, count
				end
			else
				return nil, count
			end
		end
	end

	return nil, nil
end



function utils.on_use (itemstack, user, pointed_thing, limit)
	if user and user:is_player () then
		local meta = itemstack:get_meta ()
		local def = minetest.registered_items[itemstack:get_name ()]

		if meta and def then
			local count = itemstack:get_count ()
			local item_name = def.description

			if user:get_player_control ().sneak then
				if user:get_player_control ().aux1 then
					count = count - 10
				else
					count = count + 10
				end
			elseif user:get_player_control ().aux1 then
				count = count - 1
			else
				count = count + 1
			end

			if count < 1 then
				count = limit + count
			elseif count > limit then
				count = count % limit
			end

			itemstack:set_count (count)

			return itemstack
		end
	end

	return nil
end



--
