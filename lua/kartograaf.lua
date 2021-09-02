local M = {}

M.debug = false
M.default_options = { noremap = true }

local function is_string(val)
  return type(val) == "string"
end

local function is_table(val)
  return type(val) == "table"
end

local function split(inputstr, sep)
  if sep == nil then
    sep = "%s"
  end
  local t= {}
  for str in string.gmatch(inputstr, "([^"..sep.."]+)") do
    table.insert(t, str)
  end
  return t
end

local function v(buffer, mode, lhs, rhs, map_options)
  if M.debug then
    if buffer == nil then
      print('vim.api.nvim_set_keymap('..mode..', '..lhs..', '..rhs..', '..vim.inspect(map_options, { newline = ''})..')')
    else
      print('vim.api.nvim_buf_set_keymap('..buffer..', '..mode..', '..lhs..', '..rhs..', '.. vim.inspect(map_options, { newline = ''})..')')
    end
  end
end

local function merge_table(target, source)
  local result = target
  if source ~= nil then
      result = vim.tbl_extend('force', target, source)
  end
  return result
end

local function prep_lhs(lhs, mod, prefix)
  if mod ~= nil then
    local mod_split = split(lhs, ',')
    if mod_split[2] == nil then
      lhs = '<'..mod..'-'..lhs..'>'
    else
      lhs = '<'..mod..'-'..mod_split[1]..'><'..mod..'-'..mod_split[2]..'>'
    end
  end
  if prefix ~= nil then
    lhs = prefix..lhs
  end
  return lhs
end

local function set_keymap(mode, lhs, rhs, options, buffer)
  v(nil, mode, lhs, rhs, options)
  if buffer ~= nil then
    vim.api.nvim_buf_set_keymap(buffer, mode, lhs, rhs, options)
  else
    vim.api.nvim_set_keymap(mode, lhs, rhs, options)
  end
end

local function apply_map_entry(mode, map, prefix, options, mod, buffer)
  local lhs = prep_lhs(map[1], mod, prefix)
  local map_options = merge_table(options, map[3])
  set_keymap(mode, lhs, map[2], map_options, buffer)
end

local function is_map(map)
  if map == nil then
    return false
  end
  if not is_table(map) then
    return false
  end
  if not is_string(map[1]) then
    return false
  end
  if not is_string(map[2]) then
    return false
  end
  return (map[1] ~= nil and map[2] ~= nil)
end

local function try_set (current, new)
  if new ~= nil then
    current = new
  end
  return current
end


local function try_map(mode, map, mod, prefix, options, buffer)
  if is_map(map) then
    local map_opts = merge_table(options, map[3])
    apply_map_entry(mode, map, prefix, map_opts, mod, buffer)
    return true
  end
  return false
end

local function apply_mapping_group (mode, mapgroup, options, buffer)

  if is_table (mapgroup) then

    local mod = mapgroup.mod
    local prefix = mapgroup.prefix
    local group_opts = merge_table(options, mapgroup.options)

    if not try_map(mode, mapgroup, mod, prefix, group_opts, buffer) then
      for _, map in pairs(mapgroup) do
        try_map(mode, map, mod, prefix, group_opts, buffer)
      end
    end
  end

end

function M.map(mappings)
  local buffer
  if mappings.buffer ~= nil then buffer = mappings.buffer end
  local options = merge_table(M.default_options, mappings.options)

  for mode, modemaps in pairs(mappings) do
    if is_table (modemaps) then
      local mode_opts = merge_table(options, modemaps.options)
      local scoped_buffer = try_set(buffer, modemaps.buffer)

      for _, mapgroup in pairs(modemaps) do
        apply_mapping_group(mode, mapgroup, mode_opts, scoped_buffer)
      end
    end
  end
end

function M.setup(settings)
  M.debug = settings.debug
  M.options = merge_table(settings.options)
end

return M
