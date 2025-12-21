local M={}

local function set(_, user_config)
  local config=rawget(_,"config");
  local newconfig;
  if user_config then
    newconfig = vim.tbl_deep_extend('force', config, user_config)
    rawset(_,"config",newconfig);
  end
  return _;
end

function M.newconfig(tab)
  
  return setmetatable({config=tab}, {
    __index = function(_, k)
      return rawget(_,"config")[k]
    end,
    __call = set,
  })
end

return M;
