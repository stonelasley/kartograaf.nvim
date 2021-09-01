local M = {}

M.debug = false
M.default_options = { noremap = true }

local is_string = function(val)
  if type(val) == "string" then
    return true
  end
    return false
end

local is_table = function(val)
  if type(val) == "table" then
    return true
  end
    return false
end

local split = function(inputstr, sep)
  if sep == nil then
    sep = "%s"
  end
  local t= {}
  for str in string.gmatch(inputstr, "([^"..sep.."]+)") do
    table.insert(t, str)
  end
  return t
end

local v = function(buffer, mode, lhs, rhs, map_options)
  if M.debug then
    if buffer == nil then
      print('vim.api.nvim_set_keymap('..mode..', '..lhs..', '..rhs..', '..vim.inspect(map_options, { newline = ''})..')')
    else
      print('vim.api.nvim_buf_set_keymap('..buffer..', '..mode..', '..lhs..', '..rhs..', '.. vim.inspect(map_options, { newline = ''})..')')
    end
  end
end

local prep_lhs = function (lhs, mod, prefix)
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

local map_tuple = function (mode, map, prefix, options, mod, buffer)
  local lhs = prep_lhs(map[1], mod, prefix)
  local rhs = map[2]
  local map_options = M.merge_table(options, map[3])
  if buffer ~= nil then
    v(buffer, mode, lhs, rhs, map_options)
    vim.api.nvim_buf_set_keymap(buffer, mode, lhs, rhs, map_options)
  else
    v(nil, mode, lhs, rhs, map_options)
    vim.api.nvim_set_keymap(mode, lhs, rhs, map_options)
  end
end

function M.is_map(map)
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

local set_if_not_nil = function(current, new)
  if new ~= nil then
    current = new
  end
  return current
end

function M.merge_table(target, source)
  local result = target
  if source ~= nil then
      result = vim.tbl_extend('force', target, source)
  end
  return result
end

function M.map(mappings)
  local buffer
  if mappings.debug ~= nil then M.debug = mappings.debug end
  if mappings.buffer ~= nil then buffer = mappings.buffer end
  local options = M.merge_table(M.default_options, mappings.options)


  for mode, modemaps in pairs(mappings) do
    -- if mappings is not table continue
    if not is_table (modemaps) then
      goto continue
    end
    local mode_opts = M.merge_table(options, modemaps.options)
    local scoped_buffer = set_if_not_nil(buffer, modemaps.buffer)

    for _, mapgroup in pairs(modemaps) do

      if not is_table (mapgroup) then
        goto continue
      end

      local mod = mapgroup.mod
      local prefix = mapgroup.prefix
      local group_opts = M.merge_table(mode_opts, mapgroup.options)
      if M.is_map(mapgroup) then
        map_tuple(mode, mapgroup, prefix, group_opts, mod, scoped_buffer)
      else
        for _, map in pairs(mapgroup) do
          if M.is_map(map) then
            local map_opts = M.merge_table(group_opts, map[3])
            map_tuple(mode, map, prefix, map_opts, mod, scoped_buffer)
          end
        end
      end
      ::continue::
    end
    ::continue::
  end
end

  return M
