---@diagnostic disable: lowercase-global
std = "lua51"
max_line_length = false
exclude_files = {
	".luacheckrc"
}
ignore = {
	"212", -- Unused argument
	"542", -- An empty if branch
	"1..", -- Everything related to globals, the LuaLS check is better
}
