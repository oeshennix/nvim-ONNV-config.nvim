local M={}
function M.load(module)
  return require("nvimonnvconfig.modules."..module);
end
return M;
