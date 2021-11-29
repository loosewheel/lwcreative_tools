local utils = ...


utils.settings = { }

utils.settings.max_block_radius =
	tonumber(minetest.settings:get ("lwcreative_tools_max_block_radius", true) or 20)

utils.settings.max_block_length =
	tonumber(minetest.settings:get ("lwcreative_tools_max_block_length", true) or 50)

utils.settings.max_copy_cube =
	tonumber(minetest.settings:get ("lwcreative_tools_max_copy_cube", true) or 40)

utils.settings.max_copy_volume =
	tonumber(minetest.settings:get ("lwcreative_tools_max_copy_volume", true) or 64000)

utils.settings.undo_limit =
	tonumber(minetest.settings:get ("lwcreative_tools_undo_limit", true) or 10)

utils.settings.use_storage =
	minetest.settings:get_bool ("lwcreative_tools_use_storage", true)



--
